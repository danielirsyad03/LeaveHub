<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // =========================================================
    // CHECK LOGIN
    // =========================================================

    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    // =========================================================
    // CHECK ROLE
    // =========================================================

    String userRole = session.getAttribute("userRole") == null
            ? ""
            : session.getAttribute("userRole").toString();

    if (!"HR".equalsIgnoreCase(userRole.trim())) {
        response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mengakses halaman ini."
        );
        return;
    }

    // =========================================================
    // SESSION USER INFORMATION
    // =========================================================

    String userName = session.getAttribute("userName") == null
            ? "HR Admin"
            : session.getAttribute("userName").toString();

    // =========================================================
    // DATA FROM SERVLET
    // =========================================================

    List<Map<String, Object>> returns =
            (List<Map<String, Object>>) request.getAttribute("returns");

    if (returns == null) {
        returns = new ArrayList<>();
    }

    Integer totalReturns =
            (Integer) request.getAttribute("totalReturns");

    Integer pendingReturns =
            (Integer) request.getAttribute("pendingReturns");

    Integer approvedReturns =
            (Integer) request.getAttribute("approvedReturns");

    Integer rejectedReturns =
            (Integer) request.getAttribute("rejectedReturns");

    if (totalReturns == null) totalReturns = 0;
    if (pendingReturns == null) pendingReturns = 0;
    if (approvedReturns == null) approvedReturns = 0;
    if (rejectedReturns == null) rejectedReturns = 0;

    // =========================================================
    // MESSAGES
    // =========================================================

    String success =
            request.getParameter("success");

    String error =
            request.getParameter("error");

    // =========================================================
    // DATE FORMAT
    // =========================================================

    SimpleDateFormat dateFormat =
            new SimpleDateFormat("dd/MM/yyyy");

    SimpleDateFormat timeFormat =
            new SimpleDateFormat("hh:mm a");
%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Pemulangan Inventori - PKB</title>

    
    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css?v=20260927-inventory-request">

    <style>
        /* Page-only scale. Sidebar remains controlled by css/style.css */
        main { min-width: 0; }
        main .page-header, main .stats, main .content-card, main .alert { font-size: 13px; }


        /* =====================================================
           RESET
           ===================================================== */

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html,
        body {
            width: 100%;
            min-height: 100%;
        }

        body {
            font-family:
                Inter,
                "Segoe UI",
                Arial,
                sans-serif;

            background: #f5f7fb;
            color: #14213d;

            overflow-x: hidden;
        }

        button,
        input,
        textarea,
        select {
            font: inherit;
        }

        button {
            cursor: pointer;
        }

        a {
            text-decoration: none;
            color: inherit;
        }


        /* =====================================================
           HEADER
           ===================================================== */

        .page-header {
            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 24px;
        }

        .page-title {
            font-size: 29px;
            font-weight: 800;

            color: #13203a;

            line-height: 1.2;
        }

        .page-subtitle {
            margin-top: 7px;

            color: #8390a4;

            font-size: 14px;
        }

        .header-actions {
            display: flex;
            align-items: center;

            gap: 10px;
        }

        .header-icon {
            width: 46px;
            height: 46px;

            border: 1px solid #e1e5eb;

            border-radius: 12px;

            background: #ffffff;

            display: flex;
            align-items: center;
            justify-content: center;

            color: #66758a;

            font-size: 18px;
        }

        .header-user {
            min-height: 46px;

            display: flex;
            align-items: center;

            gap: 10px;

            background: #ffffff;

            border: 1px solid #e1e5eb;

            border-radius: 12px;

            padding: 6px 14px 6px 7px;
        }

        .header-avatar {
            width: 34px;
            height: 34px;

            border-radius: 9px;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #fff4eb;

            border: 1px solid #f2ded0;

            color: #981b2c;

            font-size: 12px;
            font-weight: 800;
        }

        .header-name {
            font-size: 13px;
            font-weight: 700;
        }

        .header-role {
            font-size: 10px;
            color: #8c98aa;

            margin-top: 2px;
        }


        /* =====================================================
           ALERT
           ===================================================== */

        .alert {
            width: 100%;

            border-radius: 10px;

            padding: 13px 15px;

            margin-bottom: 20px;

            font-size: 13px;
            font-weight: 600;
        }

        .alert-success {
            background: #edf9f2;

            border: 1px solid #c8ead5;

            color: #14733c;
        }

        .alert-error {
            background: #fff1f2;

            border: 1px solid #f4c7cc;

            color: #b42335;
        }


        /* =====================================================
           STAT CARDS
           ===================================================== */

        .stats {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 20px;
        }

        .stat-card {
            background: #ffffff;

            border: 1px solid #e2e6ec;

            border-radius: 14px;

            min-height: 115px;

            padding: 19px 20px;

            position: relative;

            overflow: hidden;
        }

        .stat-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;

            width: 3px;
            height: 100%;

            background: #981b2c;
        }

        .stat-label {
            font-size: 12px;
            font-weight: 700;

            color: #8490a2;

            text-transform: uppercase;
        }

        .stat-number {
            margin-top: 8px;

            font-size: 29px;
            line-height: 1;

            font-weight: 800;

            color: #15213b;
        }

        .stat-desc {
            margin-top: 8px;

            font-size: 11px;

            color: #9ba5b4;
        }


        /* =====================================================
           CONTENT CARD
           ===================================================== */

        .content-card {
            width: 100%;

            background: #ffffff;

            border: 1px solid #e1e5eb;

            border-radius: 16px;

            overflow: hidden;

            box-shadow:
                0 10px 30px
                rgba(31, 42, 68, .04);
        }

        .content-header {
            padding: 21px 22px;

            border-bottom: 1px solid #edf0f4;

            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 20px;

            flex-wrap: wrap;
        }

        .content-title {
            font-size: 18px;
            font-weight: 800;

            color: #14213d;
        }

        .content-subtitle {
            margin-top: 5px;

            font-size: 12px;

            color: #8c98aa;
        }


        /* =====================================================
           SEARCH
           ===================================================== */

        .search-box {
            width: 330px;
            max-width: 100%;

            position: relative;
        }

        .search-box input {
            width: 100%;

            height: 44px;

            border: 1px solid #dfe4ea;

            border-radius: 11px;

            outline: none;

            padding:
                0
                15px
                0
                42px;

            color: #26354d;

            background: #ffffff;
        }

        .search-box input:focus {
            border-color: #b75a68;

            box-shadow:
                0 0 0 3px
                rgba(152, 27, 44, .07);
        }

        .search-icon {
            position: absolute;

            left: 15px;
            top: 50%;

            transform: translateY(-50%);

            color: #94a0b1;
        }


        /* =====================================================
           FILTER TABS
           ===================================================== */

        .filter-row {
            padding: 15px 22px;

            border-bottom: 1px solid #edf0f4;

            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 15px;

            flex-wrap: wrap;
        }

        .record-info {
            font-size: 12px;

            color: #8490a3;
        }

        .record-info strong {
            color: #981b2c;
        }

        .filter-tabs {
            display: flex;
            gap: 7px;

            flex-wrap: wrap;
        }

        .filter-btn {
            border: 1px solid #e1e5eb;

            background: #ffffff;

            color: #647289;

            border-radius: 20px;

            padding: 7px 12px;

            font-size: 11px;
            font-weight: 700;
        }

        .filter-btn:hover,
        .filter-btn.active {
            color: #981b2c;

            border-color: #e7bec5;

            background: #fff4f5;
        }


        /* =====================================================
           RETURN LIST
           ===================================================== */

        .return-list {
            width: 100%;
        }

        .return-item {
            padding: 20px 22px;

            border-bottom: 1px solid #edf0f4;

            display: grid;

            grid-template-columns:
                minmax(180px, 1.3fr)
                minmax(130px, .8fr)
                minmax(105px, .6fr)
                minmax(140px, .8fr)
                minmax(115px, .7fr)
                minmax(180px, 1fr);

            gap: 18px;

            align-items: center;
        }

        .return-item:last-child {
            border-bottom: 0;
        }

        .return-item:hover {
            background: #fcfcfd;
        }

        .column-title {
            display: none;
        }

        .item-name {
            font-size: 14px;
            font-weight: 800;

            color: #15213b;
        }

        .item-code {
            margin-top: 5px;

            font-size: 11px;

            color: #929dad;
        }

        .staff-name {
            font-size: 13px;
            font-weight: 700;

            color: #25334a;
        }

        .staff-email {
            margin-top: 4px;

            font-size: 11px;

            color: #97a2b1;

            word-break: break-word;
        }

        .qty-box {
            display: inline-flex;

            align-items: center;

            gap: 4px;

            padding: 6px 9px;

            background: #fff6f6;

            border: 1px solid #f0d6da;

            border-radius: 9px;

            color: #981b2c;

            font-size: 12px;
        }

        .qty-box strong {
            font-size: 15px;
        }

        .date-main {
            font-size: 12px;
            font-weight: 600;

            color: #334158;
        }

        .date-time {
            margin-top: 4px;

            font-size: 11px;

            color: #9aa4b2;
        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status {
            display: inline-flex;

            align-items: center;

            gap: 6px;

            border-radius: 20px;

            padding: 6px 10px;

            font-size: 11px;
            font-weight: 700;

            white-space: nowrap;
        }

        .status::before {
            content: "";

            width: 6px;
            height: 6px;

            border-radius: 50%;
        }

        .status-pending {
            color: #a26b00;

            background: #fff7df;

            border: 1px solid #f2dfaa;
        }

        .status-pending::before {
            background: #d49a16;
        }

        .status-approved {
            color: #147544;

            background: #eaf8f0;

            border: 1px solid #cbe9d8;
        }

        .status-approved::before {
            background: #1b9a5c;
        }

        .status-rejected {
            color: #b32638;

            background: #fff0f2;

            border: 1px solid #f2cdd2;
        }

        .status-rejected::before {
            background: #d13a4e;
        }


        /* =====================================================
           ACTION
           ===================================================== */

        .action-buttons {
            display: flex;

            gap: 7px;

            flex-wrap: wrap;
        }

        .btn {
            border-radius: 8px;

            padding: 8px 11px;

            font-size: 11px;
            font-weight: 700;

            border: 1px solid transparent;
        }

        .btn-approve {
            background: #eaf8f0;

            color: #147544;

            border-color: #c7e7d5;
        }

        .btn-approve:hover {
            background: #dcf3e6;
        }

        .btn-reject {
            background: #fff1f2;

            color: #b42335;

            border-color: #f0cbd0;
        }

        .btn-reject:hover {
            background: #ffe5e8;
        }

        .processed-text {
            font-size: 11px;

            color: #8c98a8;

            line-height: 1.5;
        }


        /* =====================================================
           EMPTY
           ===================================================== */

        .empty-state {
            text-align: center;

            padding: 65px 20px;
        }

        .empty-icon {
            width: 58px;
            height: 58px;

            margin: 0 auto 15px;

            border-radius: 15px;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #f7f8fa;

            color: #9ba6b5;

            font-size: 25px;
        }

        .empty-title {
            font-size: 16px;
            font-weight: 700;

            color: #334158;
        }

        .empty-desc {
            margin-top: 6px;

            font-size: 12px;

            color: #97a2b1;
        }


        /* =====================================================
           MODAL
           ===================================================== */

        .modal-overlay {
            position: fixed;

            inset: 0;

            background:
                rgba(19, 29, 48, .52);

            backdrop-filter: blur(2px);

            display: none;

            align-items: center;
            justify-content: center;

            padding: 20px;

            z-index: 9999;
        }

        .modal-overlay.show {
            display: flex;
        }

        .modal {
            width: 520px;
            max-width: 100%;

            background: #ffffff;

            border-radius: 16px;

            box-shadow:
                0 24px 70px
                rgba(15, 23, 42, .22);

            overflow: hidden;
        }

        .modal-header {
            padding: 20px 22px;

            border-bottom: 1px solid #edf0f4;

            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 15px;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 800;

            color: #15213b;
        }

        .modal-subtitle {
            margin-top: 5px;

            font-size: 12px;

            color: #8c98a8;
        }

        .modal-close {
            width: 34px;
            height: 34px;

            border-radius: 8px;

            border: 1px solid #e1e5eb;

            background: #ffffff;

            color: #758297;

            font-size: 17px;
        }

        .modal-body {
            padding: 22px;
        }

        .return-summary {
            background: #f8f9fb;

            border: 1px solid #e5e8ed;

            border-radius: 12px;

            padding: 15px;

            margin-bottom: 18px;
        }

        .summary-row {
            display: flex;

            justify-content: space-between;

            gap: 20px;

            margin-bottom: 10px;

            font-size: 12px;
        }

        .summary-row:last-child {
            margin-bottom: 0;
        }

        .summary-label {
            color: #8995a6;
        }

        .summary-value {
            color: #243249;

            font-weight: 700;

            text-align: right;
        }

        .form-group {
            margin-top: 15px;
        }

        .form-label {
            display: block;

            margin-bottom: 7px;

            font-size: 12px;
            font-weight: 700;

            color: #435168;
        }

        .form-label span {
            color: #a2aab6;
            font-weight: 400;
        }

        textarea {
            width: 100%;
            min-height: 100px;

            resize: vertical;

            padding: 12px 13px;

            border: 1px solid #dfe4ea;

            border-radius: 10px;

            outline: none;

            color: #344259;
        }

        textarea:focus {
            border-color: #b75a68;

            box-shadow:
                0 0 0 3px
                rgba(152, 27, 44, .06);
        }

        .modal-footer {
            padding: 15px 22px;

            border-top: 1px solid #edf0f4;

            display: flex;

            justify-content: flex-end;

            gap: 9px;

            background: #fcfcfd;
        }

        .btn-cancel {
            padding: 10px 16px;

            border: 1px solid #dfe4ea;

            background: #ffffff;

            color: #59677b;

            border-radius: 9px;

            font-size: 12px;
            font-weight: 700;
        }

        .btn-confirm {
            padding: 10px 17px;

            border: 0;

            border-radius: 9px;

            color: #ffffff;

            font-size: 12px;
            font-weight: 700;

            background: #981b2c;
        }

        .btn-confirm.approve {
            background: #16794a;
        }

        .btn-confirm.reject {
            background: #b42335;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1250px) {

.return-item {
                grid-template-columns:
                    minmax(160px, 1.2fr)
                    minmax(120px, .8fr)
                    90px
                    120px
                    110px
                    minmax(150px, 1fr);

                gap: 12px;
            }
        }


        @media (max-width: 1050px) {

.stats {
                grid-template-columns:
                    repeat(
                        2,
                        minmax(0, 1fr)
                    );
            }

            .return-item {
                grid-template-columns:
                    repeat(
                        2,
                        minmax(0, 1fr)
                    );

                gap: 17px;

                align-items: flex-start;
            }

            .column-title {
                display: block;

                margin-bottom: 5px;

                font-size: 10px;

                font-weight: 700;

                color: #9ba5b4;

                text-transform: uppercase;
            }
        }


        @media (max-width: 760px) {

.page-header {
                flex-direction: column;
            }

            .stats {
                grid-template-columns: 1fr;
            }

            .content-header {
                align-items: stretch;
            }

            .search-box {
                width: 100%;
            }

            .return-item {
                grid-template-columns: 1fr;
            }

            .header-actions {
                width: 100%;
            }
        }



        /* =====================================================
           STANDARD PKB PAGE SCALE - MATCH INVENTORY REQUEST ADMIN
           ===================================================== */
        body { font-size: 13px; }

.page-header {
            margin-bottom: 20px;
            align-items: flex-start;
        }

        .page-title {
            font-size: 26px;
            font-weight: 700;
            letter-spacing: -0.4px;
        }

        .page-subtitle {
            margin-top: 5px;
            font-size: 13px;
            font-weight: 400;
        }

        .stats { gap: 12px; margin-bottom: 18px; }
        .stat-card { min-height: 88px; padding: 14px 16px; border-radius: 12px; }
        .stat-label { font-size: 10px; font-weight: 600; }
        .stat-number { margin-top: 5px; font-size: 23px; font-weight: 700; }
        .stat-desc { margin-top: 5px; font-size: 10px; font-weight: 400; }

        .content-card { border-radius: 14px; box-shadow: 0 6px 22px rgba(31,42,68,.035); }
        .content-header { padding: 17px 18px; }
        .content-title { font-size: 16px; font-weight: 700; }
        .content-subtitle { font-size: 11px; font-weight: 400; }
        .search-box { height: 39px; font-size: 12px; }
        .toolbar { padding: 12px 18px; }
        .filter-btn { min-height: 31px; padding: 6px 13px; font-size: 10px; font-weight: 600; }

        .return-record { font-size: 12px; }
        .item-name, .staff-name { font-size: 12px; font-weight: 600; }
        .item-code, .staff-email, .date-time, .processed-info { font-size: 10px; font-weight: 400; }
        .quantity-badge, .status-badge { font-size: 10px; font-weight: 600; }
        .btn-action { font-size: 10px; font-weight: 600; }

        @media (max-width: 900px) {

}

/* =====================================================
   STANDARD MODAL FONT SIZE
   Sama dengan saiz standard page PKB
   ===================================================== */

/* Keseluruhan modal */
.modal {
    font-size: 13px !important;
}

/* Header modal */
.modal-title {
    font-size: 16px !important;
    font-weight: 700 !important;
    line-height: 1.3 !important;
}

.modal-subtitle {
    margin-top: 4px !important;
    font-size: 11px !important;
    font-weight: 400 !important;
    line-height: 1.5 !important;
}

/* Kotak maklumat */
.return-summary {
    padding: 14px !important;
}

/* Setiap baris */
.summary-row {
    gap: 18px !important;
    margin-bottom: 9px !important;
    font-size: 12px !important;
    line-height: 1.45 !important;
}

/* Label:
   Staf
   Barang
   Kuantiti Dipulangkan
   Catatan Staf
*/
.summary-label {
    flex: 0 0 145px !important;

    color: #8995a6 !important;

    font-size: 11px !important;
    font-weight: 400 !important;
    line-height: 1.45 !important;
}

/* Value:
   Nama staf
   Nama barang
   4 Unit
   Catatan
*/
.summary-value {
    flex: 1 !important;

    color: #243249 !important;

    font-size: 12px !important;
    font-weight: 600 !important;
    line-height: 1.45 !important;

    text-align: right !important;

    overflow-wrap: anywhere;
}

/* Pastikan strong tidak membesarkan font */
.summary-value strong,
.return-summary strong {
    font-size: inherit !important;
    font-weight: 600 !important;
}

/* Catatan HR */
.form-label {
    font-size: 11px !important;
    font-weight: 600 !important;
}

.form-label span {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Textarea */
.modal textarea {
    min-height: 90px !important;

    padding: 10px 12px !important;

    font-size: 11px !important;
    font-weight: 400 !important;
    line-height: 1.5 !important;
}

.modal textarea::placeholder {
    font-size: 11px !important;
    font-weight: 400 !important;
}

/* Footer */
.modal-footer {
    padding: 13px 20px !important;
}

/* Button */
.modal .btn-cancel,
.modal .btn-confirm {
    min-height: 36px !important;

    padding: 8px 14px !important;

    font-size: 11px !important;
    font-weight: 600 !important;
}

/* Close X */
.modal-close {
    width: 32px !important;
    height: 32px !important;

    font-size: 16px !important;
    font-weight: 400 !important;
}
    </style>

</head>


<body>

<div class="app">
    <!-- STANDARD PKB SIDEBAR -->
    <%@ include file="includes/sidebar.jspf" %>


    <!-- =====================================================
         MAIN CONTENT
         ===================================================== -->

    <main>


        <!-- =================================================
             HEADER
             ================================================= -->

        <div class="page-header">

            <div>

                <h1 class="page-title">
                    Pemulangan Inventori
                </h1>

                <div class="page-subtitle">
                    Semak dan urus permohonan pemulangan barang inventori staf.
                </div>

            </div>


            <%@ include file="includes/header-actions.jspf" %>

        </div>



        <!-- =================================================
             SUCCESS / ERROR
             ================================================= -->

        <% if (success != null && !success.isBlank()) { %>

            <div class="alert alert-success">
                <%= success %>
            </div>

        <% } %>


        <% if (error != null && !error.isBlank()) { %>

            <div class="alert alert-error">
                <%= error %>
            </div>

        <% } %>



        <!-- =================================================
             STATISTICS
             ================================================= -->

        <section class="stats">

            <div class="stat-card">

                <div class="stat-label">
                    Semua Pemulangan
                </div>

                <div class="stat-number">
                    <%= totalReturns %>
                </div>

                <div class="stat-desc">
                    Keseluruhan permohonan
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    Menunggu Tindakan
                </div>

                <div class="stat-number">
                    <%= pendingReturns %>
                </div>

                <div class="stat-desc">
                    Perlu diproses
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    Diluluskan
                </div>

                <div class="stat-number">
                    <%= approvedReturns %>
                </div>

                <div class="stat-desc">
                    Pemulangan diterima
                </div>

            </div>


            <div class="stat-card">

                <div class="stat-label">
                    Ditolak
                </div>

                <div class="stat-number">
                    <%= rejectedReturns %>
                </div>

                <div class="stat-desc">
                    Pemulangan tidak diterima
                </div>

            </div>

        </section>



        <!-- =================================================
             LIST
             ================================================= -->

        <section class="content-card">


            <div class="content-header">

                <div>

                    <div class="content-title">
                        Permohonan Pemulangan Barang
                    </div>

                    <div class="content-subtitle">
                        Permohonan yang menunggu tindakan dipaparkan terlebih dahulu.
                    </div>

                </div>


                <div class="search-box">

                    <span class="search-icon">
                        ⌕
                    </span>

                    <input
                        type="text"
                        id="searchInput"
                        placeholder="Cari staf, barang, kod..."
                        oninput="applyFilters()"
                    >

                </div>

            </div>



            <!-- FILTER -->

            <div class="filter-row">

                <div class="record-info">

                    Memaparkan
                    <strong id="visibleCount">
                        <%= totalReturns %>
                    </strong>
                    permohonan

                </div>


                <div class="filter-tabs">

                    <button
                        type="button"
                        class="filter-btn active"
                        data-status="ALL"
                        onclick="setFilter(this)"
                    >
                        Semua
                    </button>

                    <button
                        type="button"
                        class="filter-btn"
                        data-status="PENDING"
                        onclick="setFilter(this)"
                    >
                        Menunggu
                    </button>

                    <button
                        type="button"
                        class="filter-btn"
                        data-status="APPROVED"
                        onclick="setFilter(this)"
                    >
                        Diluluskan
                    </button>

                    <button
                        type="button"
                        class="filter-btn"
                        data-status="REJECTED"
                        onclick="setFilter(this)"
                    >
                        Ditolak
                    </button>

                </div>

            </div>



            <!-- =================================================
                 DATA
                 ================================================= -->

            <div class="return-list" id="returnList">


                <% if (returns.isEmpty()) { %>


                    <div class="empty-state">

                        <div class="empty-icon">
                            ↩
                        </div>

                        <div class="empty-title">
                            Tiada permohonan pemulangan
                        </div>

                        <div class="empty-desc">
                            Permohonan pemulangan barang oleh staf akan dipaparkan di sini.
                        </div>

                    </div>


                <% } else { %>


                    <% for (Map<String, Object> row : returns) {

                        int returnId =
                                ((Number) row.get("id")).intValue();

                        int requestId =
                                ((Number) row.get("request_id")).intValue();

                        int quantity =
                                ((Number) row.get("quantity")).intValue();

                        String status =
                                row.get("status") == null
                                        ? ""
                                        : row.get("status").toString();

                        String itemName =
                                row.get("item_name") == null
                                        ? "-"
                                        : row.get("item_name").toString();

                        String itemCode =
                                row.get("item_code") == null
                                        ? "-"
                                        : row.get("item_code").toString();

                        String staffName =
                                row.get("staff_name") == null
                                        ? "-"
                                        : row.get("staff_name").toString();

                        String staffEmail =
                                row.get("staff_email") == null
                                        ? "-"
                                        : row.get("staff_email").toString();

                        String unit =
                                row.get("unit") == null
                                        ? "Unit"
                                        : row.get("unit").toString();

                        String remarks =
                                row.get("remarks") == null
                                        ? ""
                                        : row.get("remarks").toString();

                        String reviewerName =
                                row.get("reviewer_name") == null
                                        ? ""
                                        : row.get("reviewer_name").toString();

                        Timestamp requestedAt =
                                (Timestamp) row.get("requested_at");

                        Timestamp reviewedAt =
                                (Timestamp) row.get("reviewed_at");

                        String displayDate =
                                requestedAt == null
                                        ? "-"
                                        : dateFormat.format(requestedAt);

                        String displayTime =
                                requestedAt == null
                                        ? ""
                                        : timeFormat.format(requestedAt);

                        String statusLabel;

                        if ("APPROVED".equalsIgnoreCase(status)) {
                            statusLabel = "Diluluskan";

                        } else if ("REJECTED".equalsIgnoreCase(status)) {
                            statusLabel = "Ditolak";

                        } else {
                            statusLabel = "Menunggu";
                        }

                        String searchText =
                                (
                                    staffName
                                    + " "
                                    + staffEmail
                                    + " "
                                    + itemName
                                    + " "
                                    + itemCode
                                    + " "
                                    + status
                                ).toLowerCase();

                    %>


                    <div
                        class="return-item return-record"
                        data-status="<%= status %>"
                        data-search="<%= searchText.replace("\"", "&quot;") %>"
                    >


                        <!-- ITEM -->

                        <div>

                            <span class="column-title">
                                Barang
                            </span>

                            <div class="item-name">
                                <%= itemName %>
                            </div>

                            <div class="item-code">
                                Kod: <%= itemCode %>
                            </div>

                        </div>



                        <!-- STAFF -->

                        <div>

                            <span class="column-title">
                                Staf
                            </span>

                            <div class="staff-name">
                                <%= staffName %>
                            </div>

                            <div class="staff-email">
                                <%= staffEmail %>
                            </div>

                        </div>



                        <!-- QUANTITY -->

                        <div>

                            <span class="column-title">
                                Kuantiti
                            </span>

                            <div class="qty-box">

                                <strong>
                                    <%= quantity %>
                                </strong>

                                <%= unit %>

                            </div>

                        </div>



                        <!-- DATE -->

                        <div>

                            <span class="column-title">
                                Tarikh Permohonan
                            </span>

                            <div class="date-main">
                                <%= displayDate %>
                            </div>

                            <div class="date-time">
                                <%= displayTime %>
                            </div>

                        </div>



                        <!-- STATUS -->

                        <div>

                            <span class="column-title">
                                Status
                            </span>


                            <% if ("APPROVED".equalsIgnoreCase(status)) { %>

                                <span class="status status-approved">
                                    Diluluskan
                                </span>


                            <% } else if ("REJECTED".equalsIgnoreCase(status)) { %>

                                <span class="status status-rejected">
                                    Ditolak
                                </span>


                            <% } else { %>

                                <span class="status status-pending">
                                    Menunggu
                                </span>

                            <% } %>

                        </div>



                        <!-- ACTION -->

                        <div>

                            <span class="column-title">
                                Tindakan
                            </span>


                            <% if ("PENDING".equalsIgnoreCase(status)) { %>


                                <div class="action-buttons">


                                    <button
                                        type="button"
                                        class="btn btn-approve"

                                        onclick="openActionModal(
                                            'approve',
                                            '<%= returnId %>',
                                            '<%= requestId %>',
                                            '<%= itemName.replace("'", "\\'") %>',
                                            '<%= itemCode.replace("'", "\\'") %>',
                                            '<%= staffName.replace("'", "\\'") %>',
                                            '<%= quantity %>',
                                            '<%= unit.replace("'", "\\'") %>',
                                            '<%= remarks.replace("'", "\\'").replace("\r", " ").replace("\n", " ") %>'
                                        )"
                                    >
                                        ✓ Luluskan
                                    </button>


                                    <button
                                        type="button"
                                        class="btn btn-reject"

                                        onclick="openActionModal(
                                            'reject',
                                            '<%= returnId %>',
                                            '<%= requestId %>',
                                            '<%= itemName.replace("'", "\\'") %>',
                                            '<%= itemCode.replace("'", "\\'") %>',
                                            '<%= staffName.replace("'", "\\'") %>',
                                            '<%= quantity %>',
                                            '<%= unit.replace("'", "\\'") %>',
                                            '<%= remarks.replace("'", "\\'").replace("\r", " ").replace("\n", " ") %>'
                                        )"
                                    >
                                        × Tolak
                                    </button>


                                </div>


                            <% } else { %>


                                <div class="processed-text">

                                    Diproses

                                    <% if (!reviewerName.isBlank()) { %>

                                        oleh
                                        <strong>
                                            <%= reviewerName %>
                                        </strong>

                                    <% } %>


                                    <% if (reviewedAt != null) { %>

                                        <br>

                                        <%= dateFormat.format(reviewedAt) %>

                                    <% } %>

                                </div>


                            <% } %>

                        </div>


                    </div>


                    <% } %>


                <% } %>


            </div>

        </section>


    </main>

</div>



<!-- =========================================================
     ACTION MODAL
     ========================================================= -->

<div
    class="modal-overlay"
    id="actionModal"
>

    <div class="modal">


        <div class="modal-header">

            <div>

                <div
                    class="modal-title"
                    id="modalTitle"
                >
                    Proses Pemulangan
                </div>

                <div
                    class="modal-subtitle"
                    id="modalSubtitle"
                >
                    Semak maklumat sebelum meneruskan.
                </div>

            </div>


            <button
                type="button"
                class="modal-close"
                onclick="closeModal()"
            >
                ×
            </button>

        </div>



        <form
            method="post"
            action="<%= request.getContextPath() %>/inventory-return-admin"
            id="returnForm"
        >


            <input
                type="hidden"
                name="action"
                id="modalAction"
            >


            <input
                type="hidden"
                name="return_id"
                id="modalReturnId"
            >



            <div class="modal-body">


                <div class="return-summary">


                    <div class="summary-row">

                        <span class="summary-label">
                            Staf
                        </span>

                        <span
                            class="summary-value"
                            id="modalStaff"
                        >
                            -
                        </span>

                    </div>


                    <div class="summary-row">

                        <span class="summary-label">
                            Barang
                        </span>

                        <span
                            class="summary-value"
                            id="modalItem"
                        >
                            -
                        </span>

                    </div>


                    <div class="summary-row">

                        <span class="summary-label">
                            Kuantiti Dipulangkan
                        </span>

                        <span
                            class="summary-value"
                            id="modalQuantity"
                        >
                            -
                        </span>

                    </div>


                    <div class="summary-row">

                        <span class="summary-label">
                            Catatan Staf
                        </span>

                        <span
                            class="summary-value"
                            id="modalStaffRemarks"
                        >
                            -
                        </span>

                    </div>


                </div>



                <div class="form-group">

                    <label
                        class="form-label"
                        for="adminRemarks"
                    >

                        Catatan HR

                        <span id="remarksOptional">
                            (Pilihan)
                        </span>

                    </label>


                    <textarea
                        id="adminRemarks"
                        name="admin_remarks"
                        placeholder="Masukkan catatan..."
                    ></textarea>

                </div>


            </div>



            <div class="modal-footer">


                <button
                    type="button"
                    class="btn-cancel"
                    onclick="closeModal()"
                >
                    Batal
                </button>


                <button
                    type="submit"
                    class="btn-confirm"
                    id="confirmButton"
                >
                    Teruskan
                </button>


            </div>


        </form>

    </div>

</div>



<script>

    // =========================================================
    // FILTER
    // =========================================================

    let currentStatus =
            "ALL";


    function setFilter(button) {

        document
            .querySelectorAll(
                ".filter-btn"
            )
            .forEach(btn => {

                btn.classList.remove(
                    "active"
                );

            });


        button.classList.add(
            "active"
        );


        currentStatus =
                button.dataset.status;


        applyFilters();
    }


    function applyFilters() {

        const search =
                document
                    .getElementById(
                        "searchInput"
                    )
                    .value
                    .trim()
                    .toLowerCase();


        const records =
                document
                    .querySelectorAll(
                        ".return-record"
                    );


        let visible =
                0;


        records.forEach(record => {

            const status =
                    record.dataset.status;

            const text =
                    record.dataset.search
                    || "";


            const statusMatch =
                    currentStatus === "ALL"
                    ||
                    status === currentStatus;


            const searchMatch =
                    search === ""
                    ||
                    text.includes(search);


            if (
                statusMatch
                &&
                searchMatch
            ) {

                record.style.display =
                        "";

                visible++;


            } else {

                record.style.display =
                        "none";
            }

        });


        const counter =
                document.getElementById(
                    "visibleCount"
                );


        if (
            counter
        ) {

            counter.textContent =
                    visible;
        }
    }



    // =========================================================
    // MODAL
    // =========================================================

    function openActionModal(
        action,
        returnId,
        requestId,
        itemName,
        itemCode,
        staffName,
        quantity,
        unit,
        remarks
    ) {

        const modal =
                document.getElementById(
                    "actionModal"
                );


        const title =
                document.getElementById(
                    "modalTitle"
                );


        const subtitle =
                document.getElementById(
                    "modalSubtitle"
                );


        const confirm =
                document.getElementById(
                    "confirmButton"
                );


        const textarea =
                document.getElementById(
                    "adminRemarks"
                );


        const optional =
                document.getElementById(
                    "remarksOptional"
                );


        document
            .getElementById(
                "modalAction"
            )
            .value =
                action;


        document
            .getElementById(
                "modalReturnId"
            )
            .value =
                returnId;


        document
            .getElementById(
                "modalStaff"
            )
            .textContent =
                staffName;


        document
            .getElementById(
                "modalItem"
            )
            .textContent =
                itemName
                + " ("
                + itemCode
                + ")";


        document
            .getElementById(
                "modalQuantity"
            )
            .textContent =
                quantity
                + " "
                + unit;


        document
            .getElementById(
                "modalStaffRemarks"
            )
            .textContent =
                remarks
                    ? remarks
                    : "-";


        textarea.value =
                "";


        if (
            action === "approve"
        ) {

            title.textContent =
                    "Luluskan Pemulangan";


            subtitle.textContent =
                    "Stok barang akan dimasukkan semula ke dalam inventori.";


            confirm.textContent =
                    "Luluskan Pemulangan";


            confirm.className =
                    "btn-confirm approve";


            textarea.placeholder =
                    "Contoh: Barang diterima dalam keadaan baik";


            textarea.required =
                    false;


            optional.textContent =
                    "(Pilihan)";


        } else {

            title.textContent =
                    "Tolak Pemulangan";


            subtitle.textContent =
                    "Masukkan sebab permohonan pemulangan ditolak.";


            confirm.textContent =
                    "Tolak Pemulangan";


            confirm.className =
                    "btn-confirm reject";


            textarea.placeholder =
                    "Masukkan sebab pemulangan ditolak";


            textarea.required =
                    true;


            optional.textContent =
                    "(Wajib)";
        }


        modal.classList.add(
            "show"
        );
    }


    function closeModal() {

        document
            .getElementById(
                "actionModal"
            )
            .classList
            .remove(
                "show"
            );
    }


    // =========================================================
    // CLOSE WHEN CLICK OUTSIDE
    // =========================================================

    document
        .getElementById(
            "actionModal"
        )
        .addEventListener(
            "click",
            function(event) {

                if (
                    event.target === this
                ) {

                    closeModal();
                }
            }
        );


    // =========================================================
    // ESC
    // =========================================================

    document.addEventListener(
        "keydown",
        function(event) {

            if (
                event.key === "Escape"
            ) {

                closeModal();
            }
        }
    );

</script>


</body>

</html>