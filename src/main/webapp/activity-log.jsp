<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // =========================================================
    // SESSION
    // =========================================================

    String activityName =
        session.getAttribute("name") == null
            ? "Pengguna"
            : String.valueOf(session.getAttribute("name"));

    // =========================================================
    // REQUEST DATA
    // =========================================================

    @SuppressWarnings("unchecked")
List<Map<String, Object>> logs =
    (List<Map<String, Object>>) request.getAttribute("logs");

    java.util.List<String> actions =
            new java.util.ArrayList<>();

    Object actionsAttribute = request.getAttribute("actions");

    if (actionsAttribute instanceof java.util.List<?>) {

        for (Object item : (java.util.List<?>) actionsAttribute) {

            if (item instanceof String) {
                actions.add((String) item);
            }
        }
    }

    String search =
        request.getAttribute("search") == null
            ? ""
            : String.valueOf(request.getAttribute("search"));

    String selectedAction =
        request.getAttribute("selectedAction") == null
            ? ""
            : String.valueOf(request.getAttribute("selectedAction"));

    String selectedRole =
        request.getAttribute("selectedRole") == null
            ? ""
            : String.valueOf(request.getAttribute("selectedRole"));

    String dateFrom =
        request.getAttribute("dateFrom") == null
            ? ""
            : String.valueOf(request.getAttribute("dateFrom"));

    String dateTo =
        request.getAttribute("dateTo") == null
            ? ""
            : String.valueOf(request.getAttribute("dateTo"));

    int currentPage =
        request.getAttribute("currentPage") == null
            ? 1
            : (Integer) request.getAttribute("currentPage");

    int totalPages =
        request.getAttribute("totalPages") == null
            ? 1
            : (Integer) request.getAttribute("totalPages");

    int totalRecords =
        request.getAttribute("totalRecords") == null
            ? 0
            : (Integer) request.getAttribute("totalRecords");


    // =========================================================
    // ESCAPE HTML
    // =========================================================

    java.util.function.Function<Object, String> escapeHtml =
        value -> {

            if (value == null) {
                return "";
            }

            String text = String.valueOf(value);

            return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
        };


     // =========================================================
     // ACTION LABEL
     // =========================================================

     java.util.function.Function<String, String> actionLabel =
         value -> {

             if (value == null || value.isBlank()) {
                 return "—";
             }

             String actionValue =
                 value.trim().toUpperCase();

             switch (actionValue) {

                 // =================================================
                 // AKAUN / PENGGUNA
                 // =================================================

                 case "REGISTER_ACCOUNT":
                     return "Daftar Akaun";

                 case "ADD_USER":
                 case "ADD_STAFF":
                     return "Tambah Staf";

                 case "EDIT_USER":
                 case "EDIT_STAFF":
                 case "UPDATE_USER":
                 case "UPDATE_STAFF":
                     return "Kemaskini Staf";

                 case "DELETE_USER":
                 case "DELETE_STAFF":
                     return "Padam Staf";

                 case "LOGIN":
                     return "Log Masuk";

                 case "LOGIN_FAILED":
                     return "Percubaan Log Masuk Gagal";

                 case "LOGOUT":
                     return "Log Keluar";

                 case "CHANGE_PASSWORD":
                     return "Tukar Kata Laluan";

                 // =================================================
                 // KEHADIRAN
                 // =================================================

                 case "ATTENDANCE CHECK IN":
                 case "ATTENDANCE_CHECK_IN":
                 case "ATTENDANCE_CHECKIN":
                     return "Check In Kehadiran";

                 case "ATTENDANCE CHECK OUT":
                 case "ATTENDANCE_CHECK_OUT":
                 case "ATTENDANCE_CHECKOUT":
                     return "Check Out Kehadiran";


                 // =================================================
                 // PERMOHONAN CUTI
                 // =================================================

                 case "SUBMIT_LEAVE":
                 case "CREATE_LEAVE":
                 case "APPLY_LEAVE":
                     return "Hantar Permohonan Cuti";

                 case "UPDATE_LEAVE":
                     return "Kemaskini Permohonan Cuti";

                 case "CANCEL_LEAVE":
                     return "Batal Permohonan Cuti";

                 case "HOD_SUPPORT_LEAVE":
                 case "SUPPORT_LEAVE":
                     return "Sokong Permohonan Cuti";

                 case "HOD_NOT_SUPPORT_LEAVE":
                 case "NOT_SUPPORT_LEAVE":
                     return "Tidak Sokong Permohonan Cuti";

                 case "MANAGEMENT_APPROVE_LEAVE":
                 case "APPROVE_LEAVE":
                     return "Lulus Permohonan Cuti";

                 case "MANAGEMENT_REJECT_LEAVE":
                 case "REJECT_LEAVE":
                     return "Tolak Permohonan Cuti";

                 case "CHANGE_LEAVE_DECISION":
                     return "Ubah Keputusan Cuti";


                 // =================================================
                 // CUTI UMUM
                 // =================================================

                 case "ADD_PUBLIC_HOLIDAY":
                     return "Tambah Cuti Umum";

                 case "EDIT_PUBLIC_HOLIDAY":
                 case "UPDATE_PUBLIC_HOLIDAY":
                     return "Kemaskini Cuti Umum";

                 case "DELETE_PUBLIC_HOLIDAY":
                     return "Padam Cuti Umum";

                 case "ACTIVATE_PUBLIC_HOLIDAY":
                     return "Aktifkan Cuti Umum";

                 case "DEACTIVATE_PUBLIC_HOLIDAY":
                     return "Nyahaktifkan Cuti Umum";


                 // =================================================
                 // INVENTORI - ITEM
                 // =================================================

                 case "ADD_INVENTORY":
                 case "ADD_INVENTORY_ITEM":
                     return "Tambah Inventori";

                 case "EDIT_INVENTORY":
                 case "UPDATE_INVENTORY":
                 case "UPDATE_INVENTORY_ITEM":
                 case "INVENTORY_UPDATE":
                     return "Kemaskini Inventori";

                 case "DELETE_INVENTORY":
                 case "DELETE_INVENTORY_ITEM":
                     return "Padam Inventori";


                 // =================================================
                 // INVENTORI - STOK
                 // =================================================

                 case "INVENTORY_STOCK_IN":
                 case "STOCK_IN":
                     return "Stok Masuk";

                 case "INVENTORY_STOCK_OUT":
                 case "STOCK_OUT":
                     return "Stok Keluar";

                 case "INVENTORY_ADJUSTMENT":
                 case "ADJUST_INVENTORY":
                 case "ADJUST_INVENTORY_STOCK":
                     return "Pelarasan Stok";


                 // =================================================
                 // PERMOHONAN INVENTORI
                 // =================================================

                 case "CREATE_INVENTORY_REQUEST":
                 case "APPLY_INVENTORY":
                 case "REQUEST_INVENTORY":
                     return "Hantar Permohonan Inventori";

                 case "APPROVE_INVENTORY_REQUEST":
                     return "Lulus Permohonan Inventori";

                 case "REJECT_INVENTORY_REQUEST":
                     return "Tolak Permohonan Inventori";

                 case "CANCEL_INVENTORY_REQUEST":
                     return "Batal Permohonan Inventori";


                 // =================================================
                 // PEMULANGAN INVENTORI
                 // =================================================

                 case "CREATE_INVENTORY_RETURN":
                 case "REQUEST_INVENTORY_RETURN":
                 case "INVENTORY_RETURN_REQUEST":
                     return "Hantar Permohonan Pemulangan Inventori";

                 case "APPROVE_INVENTORY_RETURN":
                     return "Lulus Pemulangan Inventori";

                 case "REJECT_INVENTORY_RETURN":
                     return "Tolak Pemulangan Inventori";

                 case "CANCEL_INVENTORY_RETURN":
                     return "Batal Pemulangan Inventori";

                 case "INVENTORY_RETURN":
                     return "Pemulangan Inventori";

                 // =================================================
                 // KENDERAAN
                 // =================================================

                 case "CREATE_VEHICLE_APPLICATION":
                     return "Hantar Permohonan Kenderaan";

                 case "APPROVE_VEHICLE_APPLICATION":
                     return "Lulus Permohonan Kenderaan";

                 case "REJECT_VEHICLE_APPLICATION":
                     return "Tolak Permohonan Kenderaan";

                 case "CANCEL_VEHICLE_APPLICATION":
                     return "Batal Permohonan Kenderaan";

                 case "CREATE_VEHICLE_CHANGE":
                     return "Hantar Perubahan Tempahan Kenderaan";

                 case "RECORD_VEHICLE_RETURN":
                     return "Rekod Pemulangan Kenderaan";

                 case "APPROVE_VEHICLE_CHANGE":
                     return "Lulus Perubahan Tempahan Kenderaan";

                 case "REJECT_VEHICLE_CHANGE":
                     return "Tolak Perubahan Tempahan Kenderaan";

                 case "CREATE_VEHICLE":
                     return "Tambah Kenderaan";

                 case "UPDATE_VEHICLE":
                     return "Kemaskini Kenderaan";

                 case "DELETE_VEHICLE":
                     return "Padam Kenderaan";


                 // =================================================
                 // CETAK
                 // =================================================

                 case "PRINT_ACTIVITY_LOG":
                     return "Cetak Log Aktiviti";

                 case "PRINT_INVENTORY_LIST":
                     return "Cetak Senarai Inventori";

                 case "PRINT_LEAVE":
                 case "PRINT_LEAVE_FORM":
                     return "Cetak Borang Permohonan Cuti";

                 case "PRINT_LEAVE_LIST":
                 case "PRINT_LEAVE_APPLICATION_LIST":
                     return "Cetak Senarai Permohonan Cuti";

                 case "PRINT_STAFF_LIST":
                     return "Cetak Senarai Staf";

                 case "PRINT_INVENTORY_REQUEST":
                     return "Cetak Permohonan Inventori";

                 case "PRINT_INVENTORY_TRANSACTION":
                 case "PRINT_INVENTORY_TRANSACTIONS":
                 case "PRINT_INVENTORY_TRANSACTION_HISTORY":
                     return "Cetak Sejarah Transaksi Inventori";


                 // =================================================
                 // PENGUMUMAN
                 // =================================================

                 case "ADD_ANNOUNCEMENT":
                     return "Tambah Pengumuman";

                 case "EDIT_ANNOUNCEMENT":
                 case "UPDATE_ANNOUNCEMENT":
                     return "Kemaskini Pengumuman";

                 case "DELETE_ANNOUNCEMENT":
                     return "Padam Pengumuman";

                 case "ADD_COMPANY_EVENT":
                     return "Tambah Aktiviti Syarikat";

                 case "UPDATE_COMPANY_EVENT":
                     return "Kemaskini Aktiviti Syarikat";

                 case "DELETE_COMPANY_EVENT":
                     return "Padam Aktiviti Syarikat";

                 case "UPDATE_ATTENDANCE_RECORD":
                     return "Kemaskini Rekod Kehadiran";

                 case "RECORD_MEDICAL_DENTAL_CLAIM":
                     return "Rekod Tuntutan Perubatan/Pergigian";

                 case "UPDATE_MEDICAL_DENTAL_ALLOCATION":
                     return "Kemaskini Peruntukan Perubatan/Pergigian";


                 // =================================================
                 // CARRY FORWARD
                 // =================================================

                 case "UPDATE_CARRY_FORWARD":
                     return "Kemaskini Carry Forward";

                 case "PROCESS_CARRY_FORWARD":
                     return "Proses Carry Forward";


                 // =================================================
                 // FALLBACK
                 // =================================================

                 default:
                     return actionValue
                         .replace("_", " ");
             }
         };


    // =========================================================
    // ROLE LABEL
    // =========================================================

    java.util.function.Function<Object, String> roleLabel =
        value -> {

            if (value == null) {
                return "—";
            }

            String roleValue =
                String.valueOf(value)
                    .trim()
                    .toUpperCase();

            switch (roleValue) {

                case "STAFF":
                    return "Staf";

                case "HOD":
                    return "Ketua Unit";

                case "HR":
                    return "HR";

                case "ADMIN":
                    return "Pentadbir";

                case "MANAGEMENT":
                    return "Pengurusan";

                default:
                    return roleValue.isBlank()
                        ? "—"
                        : roleValue;
            }
        };


    // =========================================================
    // REFERENCE LABEL
    // =========================================================

    java.util.function.Function<String, String> referenceLabel =
        value -> {

            if (value == null || value.isBlank()) {
                return "";
            }

            switch (value.trim().toUpperCase()) {

                case "LEAVE_APPLICATION":
                    return "Permohonan Cuti";

                case "LEAVE_LIST":
                    return "Senarai Permohonan Cuti";

                case "PUBLIC_HOLIDAY":
                    return "Cuti Umum";

                case "USER":
                    return "Pengguna";

                case "STAFF":
                    return "Staf";

                case "STAFF_LIST":
                    return "Senarai Staf";

                case "ANNOUNCEMENT":
                    return "Pengumuman";

                case "COMPANY_EVENT":
                    return "Aktiviti Syarikat";

                case "ATTENDANCE":
                    return "Kehadiran";

                case "MEDICAL_DENTAL_CLAIM":
                    return "Tuntutan Perubatan/Pergigian";

                case "MEDICAL_DENTAL_BENEFIT":
                    return "Peruntukan Perubatan/Pergigian";

                case "VEHICLE":
                    return "Kenderaan";

                case "VEHICLE_APPLICATION":
                    return "Permohonan Kenderaan";

                case "VEHICLE_APPLICATION_CHANGE":
                    return "Perubahan Tempahan Kenderaan";

                case "INVENTORY_REQUEST":
                    return "Permohonan Inventori";

                case "INVENTORY_RETURN":
                    return "Pemulangan Inventori";

                case "INVENTORY_ITEM":
                case "INVENTORY":
                    return "Inventori";

                case "INVENTORY_TRANSACTION":
                    return "Transaksi Inventori";

                case "INVENTORY_TRANSACTION_HISTORY":
                    return "Sejarah Transaksi Inventori";

                case "ACTIVITY_LOG":
                    return "Log Aktiviti";

                case "CARRY_FORWARD":
                    return "Carry Forward";

                default:
                    return value.replace("_", " ");
            }
        };


    // =========================================================
    // DATE FORMAT
    // =========================================================

    DateTimeFormatter activityDateFormatter =
        DateTimeFormatter.ofPattern(
            "dd/MM/yyyy HH:mm:ss"
        );


    // =========================================================
    // PRINT URL
    // =========================================================

    String printUrl =
        request.getContextPath()
        + "/print-activity-log"
        + "?search="
        + URLEncoder.encode(search, "UTF-8")
        + "&action="
        + URLEncoder.encode(selectedAction, "UTF-8")
        + "&role="
        + URLEncoder.encode(selectedRole, "UTF-8")
        + "&dateFrom="
        + URLEncoder.encode(dateFrom, "UTF-8")
        + "&dateTo="
        + URLEncoder.encode(dateTo, "UTF-8");
%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Log Aktiviti - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20261004-activity-log"
    >

    <style>

        /* =====================================================
           PAGE
           ===================================================== */

        .activity-header {
            margin-bottom: 18px;
        }

        .activity-card {
            overflow: hidden;
            margin-bottom: 24px;
            background: #ffffff;
            border: 1px solid #e4e8f0;
            border-radius: 14px;
            box-shadow: 0 6px 20px rgba(31,41,61,.04);
        }


        /* =====================================================
           CARD HEADER
           ===================================================== */

        .activity-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 18px 20px;
            border-bottom: 1px solid #e8edf3;
        }

        .activity-card-header h2 {
            margin: 0;
            font-size: 17px;
            font-weight: 600;
            color: #172033;
        }

        .activity-card-header-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .activity-total {
            display: inline-flex;
            align-items: center;
            min-height: 36px;
            padding: 0 13px;
            border-radius: 9px;
            background: #f5f7fa;
            color: #637083;
            font-size: 12px;
            font-weight: 500;
        }

        .activity-print-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: 0 14px;
            border-radius: 9px;
            background: #a9102c;
            color: #ffffff;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
        }

        .activity-print-btn:hover {
            background: #8f0d25;
        }


        /* =====================================================
           FILTER
           ===================================================== */

        .activity-filter {
            display: grid;
            grid-template-columns:
                minmax(200px, 1.5fr)
                minmax(170px, 1fr)
                minmax(140px, .8fr)
                minmax(140px, .8fr)
                minmax(140px, .8fr)
                auto;
            gap: 10px;
            padding: 16px 20px;
            border-bottom: 1px solid #e8edf3;
            background: #fbfcfe;
        }

        .activity-filter input,
        .activity-filter select {
            width: 100%;
            height: 38px;
            padding: 0 11px;
            border: 1px solid #dce2ea;
            border-radius: 8px;
            outline: none;
            background: #ffffff;
            color: #3d4859;
            font-size: 12px;
            font-weight: 400;
        }

        .activity-filter input:focus,
        .activity-filter select:focus {
            border-color: #a9102c;
            box-shadow: 0 0 0 2px rgba(169,16,44,.07);
        }

        .activity-filter-actions {
            display: flex;
            align-items: center;
            gap: 7px;
        }

        .activity-btn {
            height: 38px;
            padding: 0 14px;
            border: 0;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .activity-btn.primary {
            background: #a9102c;
            color: #ffffff;
        }

        .activity-btn.secondary {
            background: #eef1f5;
            color: #4b5668;
        }


        /* =====================================================
           TABLE
           ===================================================== */

        .activity-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .activity-table {
            width: 100%;
            min-width: 1050px;
            border-collapse: collapse;
            table-layout: auto;
        }

        .activity-table thead th {
            padding: 11px 12px;
            background: #f7f8fa;
            border-bottom: 1px solid #e3e7ed;

            color: #536073;

            font-size: 11px;
            font-weight: 600;

            text-align: left;
            white-space: nowrap;
        }

        .activity-table tbody td {
            padding: 11px 12px;

            border-bottom: 1px solid #edf0f4;

            color: #455267;

            font-size: 12px;

            /*
             * IMPORTANT:
             * Maklumat dalam table tidak bold.
             */
            font-weight: 400;

            line-height: 1.45;

            vertical-align: top;
        }

        .activity-table tbody tr:last-child td {
            border-bottom: 0;
        }

        .activity-table tbody tr:hover {
            background: #fbfcfd;
        }


        /* =====================================================
           TABLE COLUMN SIZE
           ===================================================== */

        .activity-table th:nth-child(1),
        .activity-table td:nth-child(1) {
            width: 125px;
        }

        .activity-table th:nth-child(2),
        .activity-table td:nth-child(2) {
            width: 135px;
        }

        .activity-table th:nth-child(3),
        .activity-table td:nth-child(3) {
            width: 90px;
        }

        .activity-table th:nth-child(4),
        .activity-table td:nth-child(4) {
            width: 180px;
        }

        .activity-table th:nth-child(6),
        .activity-table td:nth-child(6) {
            width: 125px;
        }


        /* =====================================================
           TABLE CONTENT
           ===================================================== */

        .activity-name {
            color: #273347;
            font-size: 12px;
            font-weight: 400;
        }

        .activity-role {
            display: inline-flex;
            align-items: center;

            padding: 4px 8px;

            border-radius: 20px;

            background: #f1f3f6;

            color: #5e6a7c;

            font-size: 10.5px;
            font-weight: 500;
        }

        .activity-action {
            display: inline-flex;
            align-items: center;

            padding: 5px 8px;

            border-radius: 7px;

            background: #fff1f3;

            color: #9e1730;

            font-size: 10.5px;
            font-weight: 500;

            line-height: 1.3;
        }

        .activity-reference {
            margin-top: 5px;

            color: #8a96a8;

            font-size: 10.5px;
            font-weight: 400;
        }

        .activity-ip {
            color: #788497;
            font-size: 11px;
            font-weight: 400;
        }

        .activity-empty {
            padding: 35px !important;
            text-align: center;
            color: #8a94a5 !important;
            font-weight: 400 !important;
        }


        /* =====================================================
           PAGINATION
           ===================================================== */

        .activity-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 14px;

            padding: 15px 20px;

            border-top: 1px solid #e8edf3;

            background: #ffffff;
        }

        .activity-pagination-info {
            color: #778296;
            font-size: 11.5px;
            font-weight: 400;
        }

        .activity-pagination-links {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .activity-page-link {
            min-width: 32px;
            height: 32px;

            padding: 0 9px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border: 1px solid #e0e5ec;
            border-radius: 7px;

            background: #ffffff;

            color: #526074;

            text-decoration: none;

            font-size: 11px;
            font-weight: 400;
        }

        .activity-page-link:hover {
            border-color: #a9102c;
            color: #a9102c;
        }

        .activity-page-link.active {
            background: #a9102c;
            border-color: #a9102c;
            color: #ffffff;
            font-weight: 500;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1200px) {

            .activity-filter {
                grid-template-columns: 1fr 1fr 1fr;
            }

            .activity-filter-actions {
                width: 100%;
            }
        }

        @media (max-width: 700px) {

            .activity-filter {
                grid-template-columns: 1fr;
            }

            .activity-filter-actions {
                width: 100%;
            }

            .activity-filter-actions .activity-btn {
                flex: 1;
            }

            .activity-pagination {
                align-items: flex-start;
                flex-direction: column;
            }

            .activity-card-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .activity-card-header-right {
                width: 100%;
                justify-content: space-between;
            }
        }

        @media (max-width: 700px) {
            main {
                width: auto;
                max-width: 100%;
                min-width: 0;
                margin-left: 0;
                padding: 74px 13px 28px;
            }

            .activity-header {
                position: relative;
                display: block;
                min-height: 48px;
                padding-right: 98px;
                margin-bottom: 18px;
            }

            .activity-header > div:first-child { width: 100%; }
            .activity-header h1 { font-size: 23px; line-height: 1.2; }
            .activity-header p { font-size: 13px; line-height: 1.45; }

            .pkb-header-actions {
                position: absolute;
                top: 0;
                right: 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .pkb-user-name { display: none; }
            .activity-card-header { gap: 10px; padding: 14px; }
            .activity-filter { gap: 8px; padding: 12px; }

            .activity-table-wrap {
                overflow: visible;
                padding: 0 10px;
            }

            .activity-table,
            .activity-table tbody {
                display: block;
                width: 100%;
                min-width: 0;
            }

            .activity-table thead { display: none; }

            .activity-table tbody tr {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 10px 12px;
                margin-bottom: 10px;
                padding: 13px;
                border: 1px solid #e1e6ed;
                border-left: 4px solid #a9102c;
                border-radius: 12px;
                background: #fff;
                box-shadow: 0 4px 12px rgba(31,41,61,.045);
            }

            .activity-table tbody td {
                display: flex;
                min-width: 0;
                flex-direction: column;
                align-items: flex-start;
                gap: 3px;
                padding: 0;
                border: 0 !important;
                font-size: 11px;
                overflow-wrap: anywhere;
            }

            .activity-table tbody td::before {
                color: #8794a8;
                font-size: 9px;
                font-weight: 700;
                letter-spacing: .04em;
                text-transform: uppercase;
            }

            .activity-table tbody td:nth-child(1)::before { content: "Tarikh & Masa"; }
            .activity-table tbody td:nth-child(2)::before { content: "Pengguna"; }
            .activity-table tbody td:nth-child(3)::before { content: "Peranan"; }
            .activity-table tbody td:nth-child(4)::before { content: "Aktiviti"; }
            .activity-table tbody td:nth-child(5)::before { content: "Keterangan"; }
            .activity-table tbody td:nth-child(6)::before { content: "IP"; }

            .activity-table tbody td:nth-child(5),
            .activity-table tbody td.activity-empty {
                grid-column: 1 / -1;
            }

            .activity-table tbody td.activity-empty {
                display: block;
                padding: 18px 8px !important;
                text-align: center;
            }

            .activity-pagination { padding: 12px; }
        }

    </style>

</head>

<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <!-- =====================================================
             TOP BAR
             ===================================================== -->

        <div class="topbar activity-header">

            <div>

                <h1>Log Aktiviti</h1>

                <p>
                    Rekod aktiviti dan perubahan penting dalam sistem
                </p>

            </div>

            <%@ include file="includes/header-actions.jspf" %>

        </div>


        <!-- =====================================================
             CARD
             ===================================================== -->

        <div class="activity-card">


            <!-- =================================================
                 CARD HEADER
                 ================================================= -->

            <div class="activity-card-header">

                <h2>
                    Rekod Audit Trail
                </h2>

                <div class="activity-card-header-right">

                    <a
                        href="<%= escapeHtml.apply(printUrl) %>"
                        class="activity-print-btn"
                    >
                        Cetak Log Aktiviti
                    </a>

                    <span class="activity-total">
                        <%= totalRecords %> Rekod
                    </span>

                </div>

            </div>


            <!-- =================================================
                 FILTER
                 ================================================= -->

            <form
                method="get"
                action="<%= request.getContextPath() %>/activity-log"
                class="activity-filter"
            >

                <input
                    type="text"
                    name="search"
                    value="<%= escapeHtml.apply(search) %>"
                    placeholder="Cari nama, aktiviti, rujukan atau IP..."
                >


                <select name="action">

                    <option value="">
                        Semua Aktiviti
                    </option>

                    <%
                        if (actions != null) {

                            for (String itemAction : actions) {
                    %>

                    <option
                        value="<%= escapeHtml.apply(itemAction) %>"
                        <%= itemAction.equalsIgnoreCase(selectedAction)
                            ? "selected"
                            : ""
                        %>
                    >

                        <%= escapeHtml.apply(
                            actionLabel.apply(itemAction)
                        ) %>

                    </option>

                    <%
                            }
                        }
                    %>

                </select>


                <select name="role">

                    <option value="">
                        Semua Peranan
                    </option>

                    <option
                        value="STAFF"
                        <%= "STAFF".equalsIgnoreCase(selectedRole)
                            ? "selected"
                            : ""
                        %>
                    >
                        Staf
                    </option>

                    <option
                        value="HOD"
                        <%= "HOD".equalsIgnoreCase(selectedRole)
                            ? "selected"
                            : ""
                        %>
                    >
                        Ketua Unit
                    </option>

                    <option
                        value="HR"
                        <%= "HR".equalsIgnoreCase(selectedRole)
                            ? "selected"
                            : ""
                        %>
                    >
                        HR
                    </option>

                    <option
                        value="MANAGEMENT"
                        <%= "MANAGEMENT".equalsIgnoreCase(selectedRole)
                            ? "selected"
                            : ""
                        %>
                    >
                        Pengurusan
                    </option>

                </select>


                <input
                    type="date"
                    name="dateFrom"
                    value="<%= escapeHtml.apply(dateFrom) %>"
                    title="Tarikh mula"
                >


                <input
                    type="date"
                    name="dateTo"
                    value="<%= escapeHtml.apply(dateTo) %>"
                    title="Tarikh akhir"
                >


                <div class="activity-filter-actions">

                    <button
                        type="submit"
                        class="activity-btn primary"
                    >
                        Tapis
                    </button>

                    <a
                        href="<%= request.getContextPath() %>/activity-log"
                        class="activity-btn secondary"
                    >
                        Reset
                    </a>

                </div>

            </form>


            <!-- =================================================
                 TABLE
                 ================================================= -->

            <div class="activity-table-wrap">

                <table class="activity-table">

                    <thead>

                    <tr>

                        <th>
    Tarikh &amp; Masa
</th>

                        <th>
                            Pengguna
                        </th>

                        <th>
                            Peranan
                        </th>

                        <th>
                            Aktiviti
                        </th>

                        <th>
                            Keterangan
                        </th>

                        <th>
                            IP
                        </th>

                    </tr>

                    </thead>


                    <tbody>

                    <%

                        if (
                            logs != null
                            &&
                            !logs.isEmpty()
                        ) {

                            for (
                                Map<String, Object> log :
                                logs
                            ) {


                                // =================================
                                // DATE
                                // =================================

                                java.sql.Timestamp createdAt =
                                    (java.sql.Timestamp)
                                    log.get("createdAt");


                                String formattedDate =
                                    createdAt == null
                                        ? "—"
                                        : createdAt
                                            .toLocalDateTime()
                                            .format(
                                                activityDateFormatter
                                            );


                                // =================================
                                // REFERENCE
                                // =================================

                                String referenceType =
                                    log.get("referenceType") == null
                                        ? ""
                                        : String.valueOf(
                                            log.get("referenceType")
                                        );


                                String referenceId =
                                    log.get("referenceId") == null
                                        ? ""
                                        : String.valueOf(
                                            log.get("referenceId")
                                        );


                                // =================================
                                // ACTION
                                // =================================

                                String actionValue =
                                    log.get("action") == null
                                        ? ""
                                        : String.valueOf(
                                            log.get("action")
                                        );


                                // =================================
                                // IP
                                // =================================

                                String ipAddress =
                                    log.get("ipAddress") == null
                                        ? "—"
                                        : String.valueOf(
                                            log.get("ipAddress")
                                        );


                                /*
                                 * Tukar localhost IPv6
                                 * kepada paparan yang lebih kemas.
                                 */

                                if (
                                    "0:0:0:0:0:0:0:1"
                                        .equals(ipAddress)
                                    ||
                                    "::1".equals(ipAddress)
                                ) {

                                    ipAddress =
                                        "127.0.0.1";
                                }

                    %>


                    <tr>


                        <!-- DATE -->

                        <td>

                            <%= escapeHtml.apply(
                                formattedDate
                            ) %>

                        </td>


                        <!-- USER -->

                        <td>

                            <span class="activity-name">

                                <%= escapeHtml.apply(
                                    log.get("userName")
                                ) %>

                            </span>

                        </td>


                        <!-- ROLE -->

                        <td>

                            <span class="activity-role">

                                <%= escapeHtml.apply(
                                    roleLabel.apply(
                                        log.get("userRole")
                                    )
                                ) %>

                            </span>

                        </td>


                        <!-- ACTION -->

                        <td>

                            <span class="activity-action">

                                <%= escapeHtml.apply(
                                    actionLabel.apply(
                                        actionValue
                                    )
                                ) %>

                            </span>

                        </td>


                        <!-- DESCRIPTION -->

                        <td>

                            <%= escapeHtml.apply(
                                log.get("description")
                            ) %>


                            <%

                                if (
                                    !referenceType.isBlank()
                                    ||
                                    !referenceId.isBlank()
                                ) {

                            %>


                            <div class="activity-reference">

                                Rujukan:

                                <%= escapeHtml.apply(
                                    referenceLabel.apply(
                                        referenceType
                                    )
                                ) %>


                                <%

                                    if (
                                        !referenceId.isBlank()
                                    ) {

                                %>

                                #<%= escapeHtml.apply(
                                    referenceId
                                ) %>

                                <%
                                    }
                                %>

                            </div>


                            <%
                                }
                            %>

                        </td>


                        <!-- IP -->

                        <td>

                            <span class="activity-ip">

                                <%= escapeHtml.apply(
                                    ipAddress
                                ) %>

                            </span>

                        </td>


                    </tr>


                    <%

                            }

                        } else {

                    %>


                    <tr>

                        <td
                            colspan="6"
                            class="activity-empty"
                        >

                            Belum ada rekod aktiviti.

                        </td>

                    </tr>


                    <%

                        }

                    %>


                    </tbody>

                </table>

            </div>


            <!-- =================================================
                 PAGINATION
                 ================================================= -->

            <%

                if (
                    totalPages > 1
                ) {

            %>


            <div class="activity-pagination">


                <div class="activity-pagination-info">

                    Halaman

                    <%= currentPage %>

                    daripada

                    <%= totalPages %>

                    &nbsp;•&nbsp;

                    <%= totalRecords %>

                    rekod

                </div>


                <div class="activity-pagination-links">


                    <%

                        if (
                            currentPage > 1
                        ) {

                            String previousUrl =
                                request.getContextPath()
                                + "/activity-log"
                                + "?page="
                                + (currentPage - 1)
                                + "&search="
                                + URLEncoder.encode(
                                    search,
                                    "UTF-8"
                                )
                                + "&action="
                                + URLEncoder.encode(
                                    selectedAction,
                                    "UTF-8"
                                )
                                + "&role="
                                + URLEncoder.encode(
                                    selectedRole,
                                    "UTF-8"
                                )
                                + "&dateFrom="
                                + URLEncoder.encode(
                                    dateFrom,
                                    "UTF-8"
                                )
                                + "&dateTo="
                                + URLEncoder.encode(
                                    dateTo,
                                    "UTF-8"
                                );

                    %>


                    <a
                        href="<%= escapeHtml.apply(previousUrl) %>"
                        class="activity-page-link"
                    >
                        ‹
                    </a>


                    <%
                        }
                    %>


                    <%

                        int startPage =
                            Math.max(
                                1,
                                currentPage - 2
                            );

                        int endPage =
                            Math.min(
                                totalPages,
                                currentPage + 2
                            );


                        for (
                            int pageNumber = startPage;
                            pageNumber <= endPage;
                            pageNumber++
                        ) {


                            String pageUrl =
                                request.getContextPath()
                                + "/activity-log"
                                + "?page="
                                + pageNumber
                                + "&search="
                                + URLEncoder.encode(
                                    search,
                                    "UTF-8"
                                )
                                + "&action="
                                + URLEncoder.encode(
                                    selectedAction,
                                    "UTF-8"
                                )
                                + "&role="
                                + URLEncoder.encode(
                                    selectedRole,
                                    "UTF-8"
                                )
                                + "&dateFrom="
                                + URLEncoder.encode(
                                    dateFrom,
                                    "UTF-8"
                                )
                                + "&dateTo="
                                + URLEncoder.encode(
                                    dateTo,
                                    "UTF-8"
                                );

                    %>


                    <a
                        href="<%= escapeHtml.apply(pageUrl) %>"
                        class="activity-page-link <%= pageNumber == currentPage ? "active" : "" %>"
                    >

                        <%= pageNumber %>

                    </a>


                    <%

                        }

                    %>


                    <%

                        if (
                            currentPage < totalPages
                        ) {


                            String nextUrl =
                                request.getContextPath()
                                + "/activity-log"
                                + "?page="
                                + (currentPage + 1)
                                + "&search="
                                + URLEncoder.encode(
                                    search,
                                    "UTF-8"
                                )
                                + "&action="
                                + URLEncoder.encode(
                                    selectedAction,
                                    "UTF-8"
                                )
                                + "&role="
                                + URLEncoder.encode(
                                    selectedRole,
                                    "UTF-8"
                                )
                                + "&dateFrom="
                                + URLEncoder.encode(
                                    dateFrom,
                                    "UTF-8"
                                )
                                + "&dateTo="
                                + URLEncoder.encode(
                                    dateTo,
                                    "UTF-8"
                                );

                    %>


                    <a
                        href="<%= escapeHtml.apply(nextUrl) %>"
                        class="activity-page-link"
                    >
                        ›
                    </a>


                    <%

                        }

                    %>


                </div>

            </div>


            <%

                }

            %>


        </div>

    </main>

</div>

</body>

</html>
