<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%!
    private String htmlEscape(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private String getValue(
            Map<String, Object> item,
            String... keys) {

        if (item == null || keys == null) {
            return "";
        }

        for (String key : keys) {
            Object value = item.get(key);

            if (value != null) {
                String text = value.toString().trim();

                if (!text.isEmpty()) {
                    return text;
                }
            }
        }

        return "";
    }

    private String formatWholeDays(Object value) {

        if (value == null) {
            return "—";
        }

        if (value instanceof Number) {
            return String.valueOf(
                    ((Number) value).intValue()
            );
        }

        try {
            double number =
                    Double.parseDouble(
                            value.toString().trim()
                    );

            return String.valueOf((int) number);

        } catch (Exception e) {
            return "—";
        }
    }
%>

<%
    // =========================================================
    // SESSION
    // =========================================================

    if (session.getAttribute("userId") == null) {

        response.sendRedirect(
                request.getContextPath() + "/"
        );

        return;
    }


    String name =
            (String) session.getAttribute("userName");


    if (name == null || name.isBlank()) {
        name = "Pengguna";
    }


    // =========================================================
    // DATA
    // =========================================================

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> applications =
            (List<Map<String, Object>>)
                    request.getAttribute("applications");


    String success =
            request.getParameter("success");

    String error =
            request.getParameter("error");


    // =========================================================
    // SUMMARY
    // =========================================================

    int totalApplications = 0;
    int pendingApplications = 0;
    int approvedApplications = 0;
    int rejectedApplications = 0;


    if (applications != null) {

        totalApplications =
                applications.size();


        for (Map<String, Object> appItem : applications) {

            String summaryStatus =
                    getValue(
                            appItem,
                            "status",
                            "managementDecision"
                    ).toUpperCase();


            if (
                    summaryStatus.equals("PENDING")
                    ||
                    summaryStatus.equals("RETURNED")
                    ||
                    summaryStatus.equals("PENDING_HEAD")
                    ||
                    summaryStatus.equals("PENDING_HOD")
                    ||
                    summaryStatus.equals("PENDING_ADMIN")
                    ||
                    summaryStatus.equals("PENDING_MANAGEMENT")
            ) {

                pendingApplications++;

            } else if (
                    summaryStatus.equals("APPROVED")
            ) {

                approvedApplications++;

            } else if (
                    summaryStatus.equals("REJECTED")
            ) {

                rejectedApplications++;
            }
        }
    }
%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>Permohonan Saya - PKB</title>

    <link
            rel="stylesheet"
            href="<%= request.getContextPath() %>/css/style.css?v=20260927-applications-final"
    >


    <style>

        /* =====================================================
           GLOBAL
           ===================================================== */

        * {
            box-sizing: border-box;
        }

        html,
        body {
            width: 100%;
            max-width: 100%;
            margin: 0;
            overflow-x: hidden;
        }

        .app {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }

        main {
            min-width: 0;
            max-width: 100%;
            overflow-x: hidden;
        }

        .applications-page {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }


        /* =====================================================
           PAGE HEADER
           ===================================================== */

        .applications-header {

            display: flex;

            align-items: flex-start;
            justify-content: space-between;

            gap: 20px;

            width: 100%;

            margin-bottom: 20px;
        }


        .applications-title {
            min-width: 0;
        }


        .applications-title h1 {

            margin: 0 0 5px;

            color: #172033;

            font-size: 26px;
            font-weight: 700;

            line-height: 1.2;

            letter-spacing: -0.3px;
        }


        .applications-title p {

            margin: 0;

            color: #7d8799;

            font-size: 13px;
            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           HEADER RIGHT
           ===================================================== */

        .header-actions {

            display: flex;

            align-items: center;
            justify-content: flex-end;

            gap: 10px;

            flex-shrink: 0;
        }


        /* =====================================================
           NOTIFICATION BUTTON
           ===================================================== */

        .notification-btn {

            position: relative;

            display: flex;

            align-items: center;
            justify-content: center;

            width: 44px;
            height: 44px;

            padding: 0;

            border: 1px solid #e4e7ec;
            border-radius: 11px;

            background: #ffffff;

            color: #667085;

            text-decoration: none;

            box-shadow:
                    0 4px 14px
                    rgba(27, 36, 53, .05);

            transition: .15s ease;
        }


        .notification-btn:hover {

            background: #fff8f8;

            border-color: #e4c7cb;

            color: #8d1f2d;

            transform: translateY(-1px);
        }


        .notification-btn svg {

            width: 19px;
            height: 19px;

            fill: none;

            stroke: currentColor;

            stroke-width: 1.8;

            stroke-linecap: round;
            stroke-linejoin: round;
        }


        /* =====================================================
           USER
           ===================================================== */

        .header-user {

            display: flex;

            align-items: center;

            gap: 9px;

            min-height: 44px;

            padding:
                    5px
                    13px
                    5px
                    6px;

            border: 1px solid #e4e7ec;
            border-radius: 11px;

            background: #ffffff;

            box-shadow:
                    0 4px 14px
                    rgba(27, 36, 53, .05);
        }


        .header-user-avatar {

            display: flex;

            align-items: center;
            justify-content: center;

            width: 32px;
            height: 32px;

            flex-shrink: 0;

            border: 1px solid #efd8d5;
            border-radius: 8px;

            background:
                    linear-gradient(
                            135deg,
                            #fff0f2,
                            #fff8e7
                    );

            color: #8d1f2d;

            font-size: 12px;
            font-weight: 700;

            text-transform: uppercase;
        }


        .header-user-name {

            display: block;

            max-width: 180px;

            color: #172033;

            font-size: 12px;
            font-weight: 600;

            line-height: 1.25;

            white-space: nowrap;

            overflow: hidden;

            text-overflow: ellipsis;
        }


        /* =====================================================
           ALERT
           ===================================================== */

        .page-alert {

            width: 100%;

            margin-bottom: 16px;

            padding: 11px 14px;

            border-radius: 9px;

            font-size: 12px;
            font-weight: 400;

            line-height: 1.5;
        }


        .page-alert-success {

            background: #edf8f1;

            border: 1px solid #cee9d8;

            color: #287246;
        }


        .page-alert-error {

            background: #fff1f2;

            border: 1px solid #efd0d5;

            color: #a62e3a;
        }


        /* =====================================================
           SUMMARY
           ===================================================== */

        .application-summary-strip {

            display: grid;

            grid-template-columns:
                    repeat(4, minmax(0, 1fr));

            gap: 12px;

            width: 100%;

            margin-bottom: 20px;
        }


        .summary-mini-card {

            position: relative;

            min-width: 0;
            min-height: 78px;

            padding: 13px 15px;

            border: 1px solid #e7e9ef;
            border-radius: 12px;

            background: #ffffff;

            box-shadow:
                    0 4px 14px
                    rgba(27, 36, 53, .04);
        }


        .summary-mini-card::before {

            content: "";

            position: absolute;

            left: 0;

            top: 12px;
            bottom: 12px;

            width: 3px;

            border-radius:
                    0
                    4px
                    4px
                    0;

            background:
                    linear-gradient(
                            180deg,
                            #8d1f2d,
                            #d5a12b
                    );
        }


        .summary-mini-card span {

            display: block;

            color: #7c8698;

            font-size: 10.5px;
            font-weight: 600;

            text-transform: uppercase;

            letter-spacing: .25px;
        }


        .summary-mini-card strong {

            display: block;

            margin-top: 6px;

            color: #172033;

            font-size: 22px;
            font-weight: 700;

            line-height: 1;
        }


        /* =====================================================
           HISTORY CONTAINER
           ===================================================== */

        .history-shell {

            width: 100%;
            max-width: 100%;

            min-width: 0;

            background: #ffffff;

            border: 1px solid #e7e9ef;
            border-radius: 15px;

            box-shadow:
                    0 6px 20px
                    rgba(31, 41, 61, .05);

            overflow: hidden;
        }


        .history-shell-header {

            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 14px;

            padding: 16px 18px;

            border-bottom:
                    1px solid #eceef2;

            background:
                    linear-gradient(
                            180deg,
                            #ffffff,
                            #fcfcfd
                    );
        }


        .history-shell-title h2 {

            margin: 0 0 4px;

            color: #172033;

            font-size: 17px;
            font-weight: 600;

            line-height: 1.3;
        }


        .history-shell-title p {

            margin: 0;

            color: #8a93a3;

            font-size: 11.5px;

            line-height: 1.4;
        }


        /* =====================================================
           TABLE
           ===================================================== */

        .applications-table-wrap {

            width: 100%;
            max-width: 100%;

            overflow-x: hidden;
        }


        .applications-table {

            width: 100%;

            table-layout: fixed;

            border-collapse: collapse;
        }


        .applications-table th,
        .applications-table td {

            min-width: 0;

            padding:
                    12px
                    10px;

            border-bottom:
                    1px solid #eef0f3;

            vertical-align: top;

            overflow-wrap: anywhere;
            word-break: normal;
        }


        .applications-table th {

            background: #fafbfc;

            color: #727c8e;

            font-size: 10px;
            font-weight: 600;

            line-height: 1.3;

            text-align: left;

            text-transform: uppercase;

            letter-spacing: .2px;
        }


        .applications-table td {

            color: #3d4658;

            font-size: 11.5px;
            font-weight: 400;

            line-height: 1.5;
        }


        .applications-table tbody tr:last-child td {
            border-bottom: 0;
        }


        .applications-table tbody tr:hover td {
            background: #fdfdfd;
        }


        /* =====================================================
           COLUMN WIDTHS
           ===================================================== */

        .applications-table th:nth-child(1),
        .applications-table td:nth-child(1) {
            width: 13%;
        }

        .applications-table th:nth-child(2),
        .applications-table td:nth-child(2) {
            width: 15%;
        }

        .applications-table th:nth-child(3),
        .applications-table td:nth-child(3) {
            width: 15%;
        }

        .applications-table th:nth-child(4),
        .applications-table td:nth-child(4) {
            width: 8%;
        }

        .applications-table th:nth-child(5),
        .applications-table td:nth-child(5) {
            width: 13%;
        }

        .applications-table th:nth-child(6),
        .applications-table td:nth-child(6) {
            width: 20%;
        }

        .applications-table th:nth-child(7),
        .applications-table td:nth-child(7) {
            width: 16%;
        }


        /* =====================================================
           TABLE TEXT
           ===================================================== */

        .application-reference {

            display: block;

            color: #172033;

            font-size: 11px;
            font-weight: 600;

            line-height: 1.4;
        }


        .application-date {

            display: block;

            margin-top: 3px;

            color: #929aaa;

            font-size: 10px;
        }


        .leave-type-name {

            display: block;

            color: #293246;

            font-size: 11.5px;
            font-weight: 600;

            line-height: 1.4;
        }


        .leave-type-other {

            display: block;

            margin-top: 3px;

            color: #8a93a3;

            font-size: 10px;
        }


        .date-range {

            color: #414a5c;

            font-size: 11px;

            line-height: 1.5;
        }


        .days-value {

            color: #172033;

            font-size: 11.5px;
            font-weight: 600;
        }


        /* =====================================================
           STATUS BADGE
           ===================================================== */

        .status-badge {

            display: inline-flex;

            align-items: center;
            justify-content: center;

            min-height: 24px;

            padding: 4px 9px;

            border-radius: 999px;

            font-size: 9.5px;
            font-weight: 600;

            line-height: 1.1;

            white-space: nowrap;
        }


        .status-pending {

            background: #fff6df;

            color: #8b650c;
        }


        .status-approved {

            background: #eaf8ef;

            color: #247445;
        }


        .status-rejected {

            background: #fff0f1;

            color: #a92e3a;
        }


        .status-cancelled {

            background: #f0f2f5;

            color: #687284;
        }


        /* =====================================================
           STATUS DETAIL
           ===================================================== */

        .status-detail {

            display: flex;

            flex-direction: column;

            gap: 7px;
        }


        .status-line {

            display: grid;

            grid-template-columns:
                    minmax(0, 1fr)
                    minmax(0, 1.1fr);

            gap: 8px;

            align-items: start;
        }


        .status-line span {

            color: #8a93a3;

            font-size: 10px;
            font-weight: 400;
        }


        .status-line strong {

            font-size: 10px;
            font-weight: 600;

            line-height: 1.4;
        }


        .decision-pending {
            color: #91690d;
        }

        .decision-approved {
            color: #247445;
        }

        .decision-rejected {
            color: #a92e3a;
        }

        .decision-cancelled {
            color: #687284;
        }


        .remark-box,
        .rejection-box {

            margin-top: 4px;

            padding: 7px 8px;

            border-radius: 7px;

            font-size: 9.5px;

            line-height: 1.45;
        }


        .remark-box {

            background: #f7f8fa;

            border:
                    1px solid #e7e9ed;

            color: #667085;
        }


        .rejection-box {

            background: #fff5f6;

            border:
                    1px solid #efd5d9;

            color: #9e3440;
        }


        /* =====================================================
           ACTION BUTTONS
           ===================================================== */

        .application-actions {

            display: flex;

            flex-direction: column;

            align-items: stretch;

            gap: 7px;

            width: 100%;
        }


        .application-actions .btn,
        .application-actions button {

            display: flex;

            align-items: center;
            justify-content: center;

            width: 100%;

            min-height: 34px;

            padding:
                    7px
                    10px !important;

            border-radius: 7px;

            font-family: inherit;

            font-size: 10px !important;
            font-weight: 600 !important;

            line-height: 1.2;

            text-align: center;

            text-decoration: none;

            cursor: pointer;

            transition: .15s ease;
        }


        .print-btn {

            border:
                    1px solid #8d1f2d !important;

            background:
                    #8d1f2d !important;

            color:
                    #ffffff !important;
        }


        .print-btn:hover {

            background:
                    #731823 !important;
        }


        .edit-btn {

            border:
                    1px solid #d7dbe2 !important;

            background:
                    #ffffff !important;

            color:
                    #525c6f !important;
        }


        .edit-btn:hover {

            border-color:
                    #c6cbd4 !important;

            background:
                    #f8f9fb !important;
        }


        .cancel-action-btn {

            border:
                    1px solid #ebcdd1 !important;

            background:
                    #fff6f7 !important;

            color:
                    #a62f3b !important;
        }


        .cancel-action-btn:hover {

            border-color:
                    #dfb8be !important;

            background:
                    #ffedef !important;
        }


        .inline-form {

            width: 100%;

            margin: 0;
        }


        .action-note {

            display: block;

            padding: 5px 4px;

            color: #9098a7;

            font-size: 9.5px;

            line-height: 1.4;

            text-align: center;
        }


        /* =====================================================
           EMPTY STATE
           ===================================================== */

        .empty-state {

            padding:
                    48px
                    20px !important;

            text-align: center;
        }


        .empty-icon {

            display: flex;

            align-items: center;
            justify-content: center;

            width: 46px;
            height: 46px;

            margin:
                    0
                    auto
                    12px;

            border-radius: 12px;

            background:
                    linear-gradient(
                            135deg,
                            #fff0f2,
                            #fff8e7
                    );

            color: #8d1f2d;

            font-size: 20px;
        }


        .empty-state strong {

            display: block;

            margin-bottom: 5px;

            color: #273044;

            font-size: 13px;
            font-weight: 600;
        }


        .empty-state p {

            margin:
                    0
                    auto
                    14px;

            color: #8b94a3;

            font-size: 11px;

            line-height: 1.5;
        }


        .new-application-btn {

            display: inline-flex;

            align-items: center;
            justify-content: center;

            min-height: 38px;

            padding:
                    8px
                    15px !important;

            border:
                    1px solid #8d1f2d !important;

            border-radius: 9px;

            background:
                    linear-gradient(
                            135deg,
                            #8d1f2d,
                            #a72a3b
                    ) !important;

            color:
                    #ffffff !important;

            font-size:
                    11px !important;

            font-weight:
                    600 !important;

            text-decoration: none;

            box-shadow:
                    0 5px 14px
                    rgba(141, 31, 45, .15);

            transition: .15s ease;
        }


        .new-application-btn:hover {

            background:
                    linear-gradient(
                            135deg,
                            #701722,
                            #8d1f2d
                    ) !important;

            transform:
                    translateY(-1px);
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1000px) {

            .application-summary-strip {

                grid-template-columns:
                        repeat(
                                2,
                                minmax(0, 1fr)
                        );
            }


            .applications-table th,
            .applications-table td {

                padding:
                        10px
                        7px;
            }


            .applications-table th {
                font-size: 9px;
            }


            .applications-table td {
                font-size: 10.5px;
            }
        }


        @media (max-width: 760px) {

            .applications-header {

                align-items: stretch;

                flex-direction: column;
            }


            .header-actions {
                justify-content: flex-start;
            }


            .applications-title h1 {
                font-size: 22px;
            }


            .application-summary-strip {

                grid-template-columns:
                        1fr
                        1fr;
            }


            .history-shell {
                overflow: visible;
            }


            .applications-table,
            .applications-table thead,
            .applications-table tbody,
            .applications-table th,
            .applications-table td,
            .applications-table tr {

                display: block;

                width: 100%;
            }


            .applications-table thead {
                display: none;
            }


            .applications-table tr {

                padding:
                        12px
                        14px;

                border-bottom:
                        1px solid #eceef2;
            }


            .applications-table td {

                width:
                        100% !important;

                padding:
                        6px
                        0;

                border-bottom: 0;
            }


            .application-actions {

                flex-direction: row;

                flex-wrap: wrap;
            }


            .application-actions .btn,
            .application-actions form {

                flex:
                        1
                        1
                        120px;
            }
        }


        @media (max-width: 480px) {
    .applications-header {
        position: relative;
        display: block;
        min-height: 44px;
    }

    .applications-title {
        min-width: 0;
        padding-right: 104px;
    }

    .header-actions {
        position: absolute;
        top: 0;
        right: 0;
        z-index: 2;
        width: max-content;
        gap: 7px;
    }

    .header-user {
        min-width: 0;
        flex: 0 0 auto;
        padding: 5px;
    }

    .header-user-name { display: none; }

    .applications-title h1 { font-size: 21px; }
    .applications-title p { font-size: 12px; }

    .application-summary-strip {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 9px;
        margin-bottom: 14px;
    }

    .summary-mini-card {
        min-height: 68px;
        padding: 11px 12px;
        border-radius: 11px;
    }

    .summary-mini-card span { font-size: 9px; line-height: 1.35; }
    .summary-mini-card strong { margin-top: 5px; font-size: 20px; }

    .history-shell { border-radius: 12px; }
    .history-shell-header { padding: 13px 14px; }
    .history-shell-title h2 { font-size: 16px; }
    .history-shell-title p { font-size: 11px; }

    .applications-table tr:not(:has(.empty-state)) {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 7px 8px;
        padding: 11px 12px;
    }

    .applications-table tr:not(:has(.empty-state)) td {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 3px;
        width: auto !important;
        min-width: 0;
        padding: 7px 8px;
        border: 1px solid #eef0f4;
        border-radius: 8px;
        background: #fcfcfd;
        font-size: 11px;
        line-height: 1.4;
        overflow-wrap: anywhere;
    }

    .applications-table tr:not(:has(.empty-state)) td::before {
        color: #8790a0;
        font-size: 9px;
        font-weight: 700;
        line-height: 1.3;
        text-transform: uppercase;
    }

    .applications-table tr:not(:has(.empty-state)) td:nth-child(1),
    .applications-table tr:not(:has(.empty-state)) td:nth-child(3),
    .applications-table tr:not(:has(.empty-state)) td:nth-child(5),
    .applications-table tr:not(:has(.empty-state)) td:nth-child(6),
    .applications-table tr:not(:has(.empty-state)) td:nth-child(7) {
        grid-column: 1 / -1;
    }

    .applications-table td:nth-child(1)::before { content: "No. Permohonan"; }
    .applications-table td:nth-child(2)::before { content: "Jenis Cuti"; }
    .applications-table td:nth-child(3)::before { content: "Tarikh"; }
    .applications-table td:nth-child(4)::before { content: "Jumlah"; }
    .applications-table td:nth-child(5)::before { content: "Alasan"; }
    .applications-table td:nth-child(6)::before { content: "Status / Keputusan"; }
    .applications-table td:nth-child(7)::before { content: "Tindakan"; }

    .applications-table td.empty-state {
        display: block !important;
        grid-column: 1 / -1;
        padding: 20px 14px;
    }

    .application-actions {
        width: 100%;
        gap: 8px;
    }

    .application-actions .btn,
    .application-actions form {
        flex: 1 1 120px;
        min-width: 0;
    }
}

    </style>

</head>


<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>


    <main>

        <div class="applications-page">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="applications-header">


                <div class="applications-title">

                    <h1>
                        Permohonan Saya
                    </h1>

                    <p>
                        Semak status, keputusan dan sejarah permohonan cuti anda
                    </p>

                </div>


                <div class="header-actions">


                    <!-- NOTIFICATION -->

                    <a
                            href="<%= request.getContextPath() %>/notifications"
                            class="notification-btn"
                            title="Notifikasi"
                            aria-label="Notifikasi"
                    >

                        <svg
                                viewBox="0 0 24 24"
                                aria-hidden="true"
                        >

                            <path
                                    d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9">
                            </path>

                            <path
                                    d="M13.73 21a2 2 0 0 1-3.46 0">
                            </path>

                        </svg>

                    </a>


                    <!-- USER -->

                    <div class="header-user">

                        <div class="header-user-avatar">

                            <%=
                                htmlEscape(
                                        name.substring(0, 1)
                                                .toUpperCase()
                                )
                            %>

                        </div>


                        <span class="header-user-name">

                            <%= htmlEscape(name) %>

                        </span>

                    </div>

                </div>

            </div>


            <!-- =================================================
                 ALERT SUCCESS
                 ================================================= -->

            <%
                if (
                        success != null
                        &&
                        !success.isBlank()
                ) {
            %>

            <div class="page-alert page-alert-success">

                <%
                    if (
                            "cancelled".equalsIgnoreCase(success)
                    ) {
                %>

                Permohonan cuti berjaya dibatalkan.

                <%
                    } else if (
                            "updated".equalsIgnoreCase(success)
                    ) {
                %>

                Permohonan cuti berjaya dikemas kini.

                <%
                    } else if (
                            "submitted".equalsIgnoreCase(success)
                    ) {
                %>

                Permohonan cuti berjaya dihantar.

                <%
                    } else {
                %>

                Tindakan berjaya dilaksanakan.

                <%
                    }
                %>

            </div>

            <%
                }
            %>


            <!-- =================================================
                 ALERT ERROR
                 ================================================= -->

            <%
                if (
                        error != null
                        &&
                        !error.isBlank()
                ) {
            %>

            <div class="page-alert page-alert-error">

                <%
                    if (
                            "cancel".equalsIgnoreCase(error)
                    ) {
                %>

                Permohonan tidak dapat dibatalkan.

                <%
                    } else if (
                            "notfound".equalsIgnoreCase(error)
                    ) {
                %>

                Rekod permohonan tidak ditemui.

                <%
                    } else {
                %>

                Tindakan tidak dapat dilaksanakan.
                Sila cuba semula.

                <%
                    }
                %>

            </div>

            <%
                }
            %>


            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="application-summary-strip">


                <div class="summary-mini-card">

                    <span>
                        Jumlah Permohonan
                    </span>

                    <strong>
                        <%= totalApplications %>
                    </strong>

                </div>


                <div class="summary-mini-card">

                    <span>
                        Dalam Proses
                    </span>

                    <strong>
                        <%= pendingApplications %>
                    </strong>

                </div>


                <div class="summary-mini-card">

                    <span>
                        Diluluskan
                    </span>

                    <strong>
                        <%= approvedApplications %>
                    </strong>

                </div>


                <div class="summary-mini-card">

                    <span>
                        Tidak Diluluskan
                    </span>

                    <strong>
                        <%= rejectedApplications %>
                    </strong>

                </div>


            </div>


            <!-- =================================================
                 HISTORY
                 ================================================= -->

            <section class="history-shell">


                <div class="history-shell-header">

                    <div class="history-shell-title">

                        <h2>
                            Sejarah Permohonan Cuti
                        </h2>

                        <p>
                            Semua permohonan cuti yang pernah anda hantar
                        </p>

                    </div>

                </div>


                <div class="applications-table-wrap">


                    <table class="applications-table">


                        <thead>

                        <tr>

                            <th>No. Permohonan</th>

                            <th>Jenis Cuti</th>

                            <th>Tarikh</th>

                            <th>Jumlah</th>

                            <th>Alasan</th>

                            <th>Status / Keputusan</th>

                            <th>Tindakan</th>

                        </tr>

                        </thead>


                        <tbody>


                        <%
                            if (
                                    applications == null
                                    ||
                                    applications.isEmpty()
                            ) {
                        %>


                        <!-- =====================================
                             EMPTY
                             ===================================== -->

                        <tr>

                            <td
                                    colspan="7"
                                    class="empty-state"
                            >

                                <div class="empty-icon">
                                    ◷
                                </div>

                                <strong>
                                    Tiada permohonan cuti
                                </strong>

                                <p>
                                    Anda masih belum membuat sebarang permohonan cuti.
                                </p>

                                <a
                                        href="<%= request.getContextPath() %>/apply"
                                        class="new-application-btn"
                                >
                                    + Buat Permohonan Cuti
                                </a>

                            </td>

                        </tr>


                        <%
                            } else {


                                for (
                                        Map<String, Object> appItem :
                                        applications
                                ) {


                                    // =========================================
                                    // ID
                                    // =========================================

                                    String applicationId =
                                            getValue(
                                                    appItem,
                                                    "id"
                                            );


                                    // =========================================
                                    // APPLICATION NUMBER
                                    // =========================================

                                    String applicationNo =
                                            getValue(
                                                    appItem,
                                                    "applicationNo",
                                                    "referenceNo"
                                            );


                                    if (applicationNo.isBlank()) {
                                        applicationNo =
                                                applicationId;
                                    }


                                    // =========================================
                                    // CREATED DATE
                                    // =========================================

                                    String createdDate =
                                            getValue(
                                                    appItem,
                                                    "createdDate",
                                                    "created_at"
                                            );


                                    // =========================================
                                    // LEAVE TYPE
                                    // =========================================

                                    String leaveType =
                                            getValue(
                                                    appItem,
                                                    "type",
                                                    "leaveType"
                                            );


                                    String otherLeaveType =
                                            getValue(
                                                    appItem,
                                                    "otherLeaveType",
                                                    "other_type"
                                            );


                                    // =========================================
                                    // DATE
                                    // =========================================

                                    String startDateValue =
                                            getValue(
                                                    appItem,
                                                    "start",
                                                    "startDate"
                                            );


                                    String endDateValue =
                                            getValue(
                                                    appItem,
                                                    "end",
                                                    "endDate"
                                            );


                                    // =========================================
                                    // DURATION
                                    // =========================================

                                    Object durationObject =
                                            appItem.get("duration");


                                    if (durationObject == null) {
                                        durationObject =
                                                appItem.get(
                                                        "durationDays"
                                                );
                                    }


                                    String durationDays =
                                            formatWholeDays(
                                                    durationObject
                                            );


                                    // =========================================
                                    // REASON
                                    // =========================================

                                    String reason =
                                            getValue(
                                                    appItem,
                                                    "reason"
                                            );


                                    // =========================================
                                    // MAIN STATUS
                                    // =========================================

                                    String status =
                                            getValue(
                                                    appItem,
                                                    "status"
                                            ).toUpperCase();


                                    if (status.isBlank()) {
                                        status = "PENDING";
                                    }


                                    // =========================================
                                    // HOD DECISION
                                    // =========================================

                                    String hodDecision =
                                            getValue(
                                                    appItem,
                                                    "hodDecision",
                                                    "hodStatus"
                                            ).toUpperCase();


                                    // =========================================
                                    // HOD REMARK
                                    // =========================================

                                    String hodRemarks =
                                            getValue(
                                                    appItem,
                                                    "hodRemarks",
                                                    "hodRemark"
                                            );


                                    // =========================================
                                    // MANAGEMENT DECISION
                                    // =========================================

                                    String managementDecision =
                                            getValue(
                                                    appItem,
                                                    "managementDecision",
                                                    "managementStatus"
                                            ).toUpperCase();


                                    // =========================================
                                    // MANAGEMENT REMARK
                                    // =========================================

                                    String managementRemarks =
                                            getValue(
                                                    appItem,
                                                    "managementRemarks",
                                                    "rejectionReason"
                                            );


                                    // =========================================
                                    // MAIN STATUS DISPLAY
                                    // =========================================

                                    String statusClass =
                                            "status-pending";

                                    String statusLabel =
                                            "Dalam Proses";


                                    if (
                                            "APPROVED".equals(status)
                                    ) {

                                        statusClass =
                                                "status-approved";

                                        statusLabel =
                                                "Diluluskan";


                                    } else if (
                                            "REJECTED".equals(status)
                                    ) {

                                        statusClass =
                                                "status-rejected";

                                        statusLabel =
                                                "Tidak Diluluskan";


                                    } else if (
                                            "CANCELLED".equals(status)
                                    ) {

                                        statusClass =
                                                "status-cancelled";

                                        statusLabel =
                                                "Dibatalkan";


                                    } else if (
                                            "RETURNED".equals(status)
                                    ) {

                                        statusClass =
                                                "status-pending";

                                        statusLabel =
                                                "Perlu Dikemas Kini";
                                    }


                                    // =========================================
                                    // HOD DISPLAY
                                    // =========================================

                                    String hodLabel =
                                            "Menunggu";

                                    String hodClass =
                                            "decision-pending";


                                    if (
                                            "SUPPORTED".equals(hodDecision)
                                            ||
                                            "APPROVED".equals(hodDecision)
                                    ) {

                                        hodLabel =
                                                "Disokong";

                                        hodClass =
                                                "decision-approved";


                                    } else if (
                                            "REJECTED".equals(hodDecision)
                                            ||
                                            "NOT_SUPPORTED".equals(
                                                    hodDecision
                                            )
                                    ) {

                                        hodLabel =
                                                "Tidak Disokong";

                                        hodClass =
                                                "decision-rejected";
                                    }


                                    // =========================================
                                    // MANAGEMENT DISPLAY
                                    // =========================================

                                    String managementLabel =
                                            "Menunggu";

                                    String managementClass =
                                            "decision-pending";


                                    if (
                                            "APPROVED".equals(
                                                    managementDecision
                                            )
                                            ||
                                            "APPROVED".equals(status)
                                    ) {

                                        managementLabel =
                                                "Diluluskan";

                                        managementClass =
                                                "decision-approved";


                                    } else if (
                                            "REJECTED".equals(
                                                    managementDecision
                                            )
                                            ||
                                            "REJECTED".equals(status)
                                    ) {

                                        managementLabel =
                                                "Tidak Diluluskan";

                                        managementClass =
                                                "decision-rejected";


                                    } else if (
                                            "CANCELLED".equals(status)
                                    ) {

                                        managementLabel =
                                                "Dibatalkan";

                                        managementClass =
                                                "decision-cancelled";
                                    }


                                    // =========================================
                                    // ACTION
                                    // =========================================

                                    boolean canEdit =
                                            "PENDING".equals(status)
                                            ||
                                            "RETURNED".equals(status)
                                            ||
                                            "PENDING_HEAD".equals(status)
                                            ||
                                            "PENDING_HOD".equals(status);


                                    boolean canCancel =
                                            !"CANCELLED".equals(status)
                                            &&
                                            !"REJECTED".equals(status);

                        %>


                        <!-- =====================================
                             APPLICATION ROW
                             ===================================== -->

                        <tr>


                            <!-- APPLICATION NUMBER -->

                            <td>

                                <span class="application-reference">

                                    <%= htmlEscape(applicationNo) %>

                                </span>


                                <%
                                    if (
                                            createdDate != null
                                            &&
                                            !createdDate.isBlank()
                                    ) {
                                %>

                                <span class="application-date">

                                    <%= htmlEscape(createdDate) %>

                                </span>

                                <%
                                    }
                                %>

                            </td>


                            <!-- LEAVE TYPE -->

                            <td>

                                <span class="leave-type-name">

                                    <%= htmlEscape(leaveType) %>

                                </span>


                                <%
                                    if (
                                            otherLeaveType != null
                                            &&
                                            !otherLeaveType.isBlank()
                                    ) {
                                %>

                                <span class="leave-type-other">

                                    <%= htmlEscape(otherLeaveType) %>

                                </span>

                                <%
                                    }
                                %>

                            </td>


                            <!-- DATE -->

                            <td>

                                <div class="date-range">

                                    <%= htmlEscape(startDateValue) %>


                                    <%
                                        if (
                                                endDateValue != null
                                                &&
                                                !endDateValue.isBlank()
                                                &&
                                                !endDateValue.equals(
                                                        startDateValue
                                                )
                                        ) {
                                    %>

                                    <br>
                                    hingga
                                    <br>

                                    <%= htmlEscape(endDateValue) %>

                                    <%
                                        }
                                    %>

                                </div>

                            </td>


                            <!-- DURATION -->

                            <td>

                                <span class="days-value">

                                    <%= htmlEscape(durationDays) %>

                                </span>

                                hari

                            </td>


                            <!-- REASON -->

                            <td>

                                <%
                                    if (
                                            reason == null
                                            ||
                                            reason.isBlank()
                                    ) {
                                %>

                                <span style="color:#98a0ae;">
                                    -
                                </span>

                                <%
                                    } else {
                                %>

                                <%= htmlEscape(reason) %>

                                <%
                                    }
                                %>

                            </td>


                            <!-- STATUS -->

                            <td>

                                <div class="status-detail">


                                    <!-- MAIN STATUS -->

                                    <div>

                                        <span
                                                class="status-badge <%= statusClass %>"
                                        >

                                            <%= htmlEscape(statusLabel) %>

                                        </span>

                                    </div>


                                    <!-- HOD -->

                                    <div class="status-line">

                                        <span>
                                            Ketua Unit
                                        </span>

                                        <strong
                                                class="<%= hodClass %>"
                                        >

                                            <%= htmlEscape(hodLabel) %>

                                        </strong>

                                    </div>


                                    <!-- MANAGEMENT -->

                                    <div class="status-line">

                                        <span>
                                            Pengurusan
                                        </span>

                                        <strong
                                                class="<%= managementClass %>"
                                        >

                                            <%= htmlEscape(managementLabel) %>

                                        </strong>

                                    </div>


                                    <!-- HOD REMARK -->

                                    <%
                                        if (
                                                hodRemarks != null
                                                &&
                                                !hodRemarks.isBlank()
                                        ) {
                                    %>

                                    <div class="remark-box">

                                        <strong>
                                            Catatan Ketua Unit:
                                        </strong>

                                        <br>

                                        <%= htmlEscape(hodRemarks) %>

                                    </div>

                                    <%
                                        }
                                    %>


                                    <!-- MANAGEMENT REMARK -->

                                    <%
                                        if (
                                                managementRemarks != null
                                                &&
                                                !managementRemarks.isBlank()
                                        ) {
                                    %>

                                    <div class="rejection-box">

                                        <strong>
                                            Catatan Pengurusan:
                                        </strong>

                                        <br>

                                        <%= htmlEscape(managementRemarks) %>

                                    </div>

                                    <%
                                        }
                                    %>


                                </div>

                            </td>


                            <!-- ACTION -->

                            <td>

                                <div class="application-actions">


                                    <!-- PRINT -->

                                    <a
                                            href="<%= request.getContextPath() %>/print-leave?id=<%= htmlEscape(applicationId) %>"
                                            class="btn print-btn"
                                    >
                                        Cetak
                                    </a>


                                    <!-- EDIT -->

                                    <%
                                        if (canEdit) {
                                    %>

                                    <a
                                            href="<%= request.getContextPath() %>/apply?id=<%= htmlEscape(applicationId) %>"
                                            class="btn edit-btn"
                                    >
                                        Kemaskini
                                    </a>

                                    <%
                                        }
                                    %>


                                    <!-- CANCEL -->

                                    <%
                                        if (canCancel) {
                                    %>

                                    <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/applications"
                                            class="inline-form"
                                            onsubmit="return confirmCancelApplication();"
                                    >

                                        <input
                                                type="hidden"
                                                name="action"
                                                value="cancel"
                                        >

                                        <input
                                                type="hidden"
                                                name="id"
                                                value="<%= htmlEscape(applicationId) %>"
                                        >

                                        <button
                                                type="submit"
                                                class="cancel-action-btn"
                                        >
                                            Batal
                                        </button>

                                    </form>

                                    <%
                                        }
                                    %>


                                    <%
                                        if (
                                                !canEdit
                                                &&
                                                !canCancel
                                        ) {
                                    %>

                                    <span class="action-note">

                                        Tiada tindakan lanjut

                                    </span>

                                    <%
                                        }
                                    %>


                                </div>

                            </td>


                        </tr>


                        <%
                                }
                            }
                        %>


                        </tbody>

                    </table>

                </div>

            </section>


        </div>

    </main>

</div>


<script>

    // =========================================================
    // CONFIRM CANCEL
    // =========================================================

    function confirmCancelApplication() {

        return confirm(
            "Adakah anda pasti mahu membatalkan permohonan cuti ini?"
        );
    }


    // =========================================================
    // PREVENT DOUBLE SUBMIT
    // =========================================================

    document.addEventListener(
        "DOMContentLoaded",
        function () {

            const forms =
                document.querySelectorAll(
                    ".inline-form"
                );


            forms.forEach(
                function (form) {

                    form.addEventListener(
                        "submit",
                        function () {

                            const button =
                                form.querySelector(
                                    "button[type='submit']"
                                );


                            if (!button) {
                                return;
                            }


                            setTimeout(
                                function () {

                                    button.disabled = true;

                                    button.textContent =
                                        "Memproses...";

                                },
                                50
                            );

                        }
                    );

                }
            );

        }
    );

</script>


</body>

</html>