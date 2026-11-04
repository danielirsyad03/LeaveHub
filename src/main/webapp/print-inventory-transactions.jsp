<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>

<%
    // =========================================================
    // SESSION
    // =========================================================
    String userName = (String) session.getAttribute("name");
    String userRole = (String) session.getAttribute("role");

    if (userName == null || userName.trim().isEmpty()) {
        userName = "HR Admin";
    }

    String roleDisplay = "Pentadbir Sistem";

    if (userRole != null) {
        if ("HR".equalsIgnoreCase(userRole)
                || "ADMIN".equalsIgnoreCase(userRole)) {
            roleDisplay = "Pentadbir Sistem";

        } else if ("HOD".equalsIgnoreCase(userRole)) {
            roleDisplay = "Ketua Unit";

        } else if ("STAFF".equalsIgnoreCase(userRole)) {
            roleDisplay = "Staf";
        }
    }

    // =========================================================
    // TRANSACTION LIST
    // =========================================================
    java.util.List<java.util.Map<String, Object>> transactions =
        new java.util.ArrayList<>();

Object transactionsAttribute =
        request.getAttribute("transactions");

if (transactionsAttribute instanceof java.util.List<?>) {

    for (Object item : (java.util.List<?>) transactionsAttribute) {

        if (item instanceof java.util.Map<?, ?>) {

            java.util.Map<String, Object> transaction =
                    new java.util.HashMap<>();

            for (java.util.Map.Entry<?, ?> entry :
                    ((java.util.Map<?, ?>) item).entrySet()) {

                if (entry.getKey() instanceof String) {

                    transaction.put(
                            (String) entry.getKey(),
                            entry.getValue()
                    );
                }
            }

            transactions.add(transaction);
        }
    }
}

    // =========================================================
    // DATE FORMAT
    // =========================================================
    SimpleDateFormat printDateFormat =
            new SimpleDateFormat("dd/MM/yyyy HH:mm");

    String printDate =
            printDateFormat.format(new Date());

    SimpleDateFormat dateFormat =
            new SimpleDateFormat("dd/MM/yyyy");

    SimpleDateFormat timeFormat =
            new SimpleDateFormat("hh:mm a");

    // =========================================================
    // HTML ESCAPE
    // =========================================================
    java.util.function.Function<Object, String> esc = value -> {

        if (value == null) {
            return "-";
        }

        String s = String.valueOf(value);

        if (s.trim().isEmpty()) {
            return "-";
        }

        return s
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    };

    // =========================================================
    // VALUE HELPER
    // =========================================================
    java.util.function.BiFunction<Map<String,Object>, String[], Object> getValue =
        (map, keys) -> {

            if (map == null) {
                return null;
            }

            for (String key : keys) {
                if (map.containsKey(key) && map.get(key) != null) {
                    return map.get(key);
                }
            }

            return null;
        };

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Cetak Sejarah Transaksi Inventori - PKB</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <style>

        /* =====================================================
           RESET
        ===================================================== */

        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f6f8;
            color: #14213a;
            font-size: 14px;
        }


        /* =====================================================
           SCREEN TOOLBAR
        ===================================================== */

        .screen-toolbar {
            margin: 24px 30px 20px;
            padding: 16px 18px;

            background: #ffffff;

            border: 1px solid #dfe4ea;
            border-radius: 14px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            box-shadow:
                0 8px 24px rgba(15, 23, 42, 0.04);
        }

        .toolbar-text h2 {
            margin: 0 0 5px;

            color: #101b30;

            font-size: 20px;
            font-weight: 700;
        }

        .toolbar-text p {
            margin: 0;

            color: #8190a8;

            font-size: 13px;
        }

        .toolbar-actions {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .btn {
            min-height: 44px;

            padding: 0 20px;

            border-radius: 9px;
            border: 1px solid transparent;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            gap: 9px;

            font-family: inherit;
            font-size: 13px;
            font-weight: 700;

            text-decoration: none;

            cursor: pointer;

            transition: 0.2s ease;
        }

        .btn-print {
            background: #a8172b;
            border-color: #a8172b;
            color: #ffffff;

            box-shadow:
                0 6px 16px rgba(168, 23, 43, 0.18);
        }

        .btn-print:hover {
            background: #8f1224;
            border-color: #8f1224;
        }

        .btn-back {
            background: #ffffff;
            border-color: #d8e0e9;
            color: #253650;
        }

        .btn-back:hover {
            background: #f8fafc;
        }

        .btn i {
            font-size: 14px;
        }


        /* =====================================================
           PRINT DOCUMENT
        ===================================================== */

        .print-page {
            margin: 0 30px 30px;
        }

        .paper {
            width: 100%;

            background: #ffffff;

            border: 1px solid #dfe4ea;
            border-radius: 14px;

            padding: 34px 38px 28px;

            box-shadow:
                0 8px 24px rgba(15, 23, 42, 0.04);
        }


        /* =====================================================
           COMPANY HEADER
        ===================================================== */

        .company-header {
            display: flex;
            align-items: center;

            gap: 26px;

            padding: 0 8px 20px;

            border-bottom:
                3px solid #99182c;
        }

        .company-logo {
            width: 170px;
            flex-shrink: 0;
        }

        .company-logo img {
            display: block;

            width: 100%;
            height: auto;

            object-fit: contain;
        }

        .company-info h2 {
            margin: 0 0 6px;

            color: #99182c;

            font-size: 28px;
            line-height: 1.15;
            font-weight: 700;
        }

        .company-info p {
            margin: 0;

            color: #71809a;

            font-size: 14px;
        }


        /* =====================================================
           DOCUMENT TITLE
        ===================================================== */

        .document-title {
            padding: 30px 0 22px;

            text-align: center;
        }

        .document-title h1 {
            margin: 0 0 8px;

            color: #101b30;

            font-size: 27px;
            font-weight: 700;

            line-height: 1.2;
        }

        .document-title p {
            margin: 0;

            color: #8491a6;

            font-size: 13px;
        }


        /* =====================================================
           META INFORMATION
        ===================================================== */

        .meta-grid {
            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 20px;
        }

        .meta-box {
            min-height: 72px;

            padding: 15px 16px;

            display: flex;
            flex-direction: column;
            justify-content: center;

            background: #fbfcfd;

            border: 1px solid #dce2e9;
            border-radius: 9px;
        }

        .meta-label {
            display: block;

            margin-bottom: 7px;

            color: #7a879b;

            font-size: 11px;
            font-weight: 700;

            text-transform: uppercase;
        }

        .meta-value {
            color: #172238;

            font-size: 14px;
            font-weight: 600;
        }


        /* =====================================================
           TABLE
        ===================================================== */

        .table-wrapper {
            width: 100%;

            overflow-x: auto;

            border: 1px solid #dce2e8;
            border-radius: 8px;
        }

        table {
            width: 100%;
            min-width: 1150px;

            border-collapse: collapse;
            table-layout: fixed;
        }

        th {
            padding: 13px 10px;

            background: #a51d32;
            color: #ffffff;

            border-right:
                1px solid rgba(255,255,255,0.16);

            font-size: 11px;
            font-weight: 700;

            text-align: left;
            vertical-align: middle;
        }

        th:last-child {
            border-right: none;
        }

        td {
            padding: 14px 10px;

            border-right:
                1px solid #dfe4ea;

            border-bottom:
                1px solid #dfe4ea;

            color: #47566d;

            font-size: 12px;

            vertical-align: middle;

            word-break: break-word;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        td:last-child {
            border-right: none;
        }

        .date-main,
        .item-name {
            color: #152239;

            font-weight: 700;
            font-size: 12px;
        }

        .date-time,
        .item-meta {
            margin-top: 4px;

            color: #8793a6;

            font-size: 10px;
        }

        .date-time {
            text-transform: lowercase;
        }


        /* =====================================================
           TYPE BADGES
        ===================================================== */

        .type-badge {
            display: inline-flex;

            align-items: center;
            justify-content: center;

            padding: 6px 10px;

            border-radius: 999px;

            font-size: 10px;
            font-weight: 700;

            white-space: nowrap;
        }

        .stock-in {
            color: #087a52;
            background: #e9f8f1;
            border: 1px solid #c9ebdc;
        }

        .stock-out {
            color: #c02235;
            background: #fff0f2;
            border: 1px solid #f3ccd2;
        }

        .return {
            color: #2766ae;
            background: #edf5ff;
            border: 1px solid #d1e2f6;
        }

        .adjustment {
            color: #7444b5;
            background: #f4edff;
            border: 1px solid #e0d2f6;
        }


        /* =====================================================
           QUANTITY
        ===================================================== */

        .qty {
            font-weight: 700;
            font-size: 12px;
        }

        .qty-in {
            color: #087a52;
        }

        .qty-out {
            color: #c02235;
        }

        .qty-return {
            color: #2766ae;
        }

        .qty-adjustment {
            color: #7444b5;
        }


        /* =====================================================
           STOCK CHANGE
        ===================================================== */

        .stock-change {
            display: flex;
            align-items: center;

            gap: 7px;

            white-space: nowrap;
        }

        .stock-before,
        .stock-arrow {
            color: #8793a6;
        }

        .stock-after {
            color: #172238;
            font-weight: 700;
        }


        /* =====================================================
           REFERENCE
        ===================================================== */

        .reference {
            color: #b3152b;

            font-weight: 700;
            font-size: 11px;
        }


        /* =====================================================
           EMPTY ROW
        ===================================================== */

        .empty-row {
            padding: 30px !important;

            text-align: center;

            color: #8793a6;
        }


        /* =====================================================
           FOOTER
        ===================================================== */

        .document-footer {
            margin-top: 15px;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            color: #8190a6;

            font-size: 11px;
        }

        .document-footer strong {
            color: #172238;
        }


        /* =====================================================
           RESPONSIVE
        ===================================================== */

        @media (max-width: 900px) {

            .screen-toolbar {
                margin: 15px;

                flex-direction: column;
                align-items: flex-start;
            }

            .toolbar-actions {
                width: 100%;
            }

            .btn {
                flex: 1;
            }

            .print-page {
                margin: 0 15px 20px;
            }

            .paper {
                padding: 24px 20px;
            }

            .company-header {
                gap: 16px;
            }

            .company-logo {
                width: 125px;
            }

            .company-info h2 {
                font-size: 21px;
            }

            .meta-grid {
                grid-template-columns: 1fr;
            }
        }


        /* =====================================================
           PRINT - A4 LANDSCAPE
        ===================================================== */

        @page {
            size: A4 landscape;
            margin: 10mm;
        }

        @media print {

            html,
            body {
                width: 100%;

                margin: 0 !important;
                padding: 0 !important;

                background: #ffffff !important;

                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }

            body {
                font-family:
                    Arial,
                    Helvetica,
                    sans-serif;

                color: #172238 !important;

                /*
                 * IMPORTANT:
                 * Saiz asas cetakan dibesarkan.
                 */
                font-size: 9pt !important;
            }

            .no-print {
                display: none !important;
            }

            .print-page {
                width: 100%;

                margin: 0 !important;
                padding: 0 !important;
            }

            .paper {
                width: 100%;
                max-width: none;

                margin: 0 !important;

                padding:
                    3mm
                    2mm
                    4mm !important;

                background: #ffffff !important;

                border: none !important;
                border-radius: 0 !important;

                box-shadow: none !important;
            }


            /* ============================
               COMPANY HEADER
            ============================ */

            .company-header {
                display: flex !important;
                align-items: center !important;

                gap: 5mm !important;

                padding:
                    0
                    1mm
                    4mm !important;

                border-bottom:
                    2px solid #99182c !important;
            }

            .company-logo {
                width: 31mm !important;
                flex: 0 0 31mm !important;
            }

            .company-logo img {
                display: block !important;

                width: 31mm !important;
                max-width: 31mm !important;

                height: auto !important;
            }

            .company-info h2 {
                margin:
                    0
                    0
                    1mm !important;

                color: #99182c !important;

                font-size: 15pt !important;
                font-weight: 700 !important;

                line-height: 1.15 !important;
            }

            .company-info p {
                margin: 0 !important;

                color: #71809a !important;

                font-size: 8pt !important;
            }


            /* ============================
               TITLE
            ============================ */

            .document-title {
                padding:
                    5mm
                    0
                    4mm !important;

                text-align: center !important;
            }

            .document-title h1 {
                margin:
                    0
                    0
                    1mm !important;

                color: #101b30 !important;

                font-size: 14pt !important;
                font-weight: 700 !important;

                line-height: 1.2 !important;
            }

            .document-title p {
                margin: 0 !important;

                color: #8491a6 !important;

                font-size: 8pt !important;
            }


            /* ============================
               PRINT INFORMATION
            ============================ */

            .meta-grid {
                width: 100% !important;

                display: grid !important;

                grid-template-columns:
                    repeat(3, minmax(0, 1fr)) !important;

                gap: 3mm !important;

                margin:
                    0
                    0
                    4mm !important;
            }

            .meta-box {
                min-height: 15mm !important;

                padding:
                    2.5mm
                    3mm !important;

                display: flex !important;
                flex-direction: column !important;
                justify-content: center !important;

                background: #fbfcfd !important;

                border:
                    1px solid #dce2e9 !important;

                border-radius:
                    2mm !important;
            }

            .meta-label {
                display: block !important;

                margin:
                    0
                    0
                    1.2mm !important;

                color: #7a879b !important;

                font-size: 7pt !important;
                font-weight: 700 !important;
            }

            .meta-value {
                display: block !important;

                color: #172238 !important;

                font-size: 9pt !important;
                font-weight: 600 !important;
            }


            /* ============================
               TABLE
            ============================ */

            .table-wrapper {
                width: 100% !important;

                overflow: visible !important;

                border:
                    1px solid #dce2e8 !important;

                border-radius:
                    1.5mm !important;
            }

            table {
                width: 100% !important;

                min-width: 0 !important;

                table-layout: fixed !important;

                border-collapse: collapse !important;

                font-size: 8pt !important;
            }

            thead {
                display: table-header-group !important;
            }

            th {
                padding:
                    2.2mm
                    1.4mm !important;

                background:
                    #a51d32 !important;

                color:
                    #ffffff !important;

                font-size:
                    7.5pt !important;

                font-weight:
                    700 !important;

                vertical-align:
                    middle !important;
            }

            td {
                padding:
                    2.2mm
                    1.4mm !important;

                color:
                    #47566d !important;

                font-size:
                    8pt !important;

                vertical-align:
                    middle !important;
            }

            .date-main,
            .item-name {
                font-size:
                    8pt !important;

                font-weight:
                    700 !important;
            }

            .date-time,
            .item-meta {
                margin-top:
                    0.5mm !important;

                font-size:
                    7pt !important;
            }

            .type-badge {
                padding:
                    0.8mm
                    1.3mm !important;

                font-size:
                    7pt !important;
            }

            .qty {
                font-size:
                    8pt !important;
            }

            .reference {
                font-size:
                    7.5pt !important;
            }


            /* ============================
               FOOTER
            ============================ */

            .document-footer {
                margin-top:
                    3mm !important;

                font-size:
                    7pt !important;
            }


            /* ============================
               PREVENT BROKEN ROW
            ============================ */

            tr {
                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }
        }

/* =========================================================
   TABLE - STANDARD & TIDAK TERLALU BOLD
   ========================================================= */

table {
    font-size: 10px !important;
}

/* Header table sahaja semi-bold */
table th {
    padding: 9px 8px !important;

    font-size: 9px !important;
    font-weight: 600 !important;

    line-height: 1.3 !important;
}

/* Semua maklumat dalam table */
table td {
    padding: 9px 8px !important;

    font-size: 10px !important;
    font-weight: 400 !important;

    line-height: 1.35 !important;
}

/* Paksa STRONG/B yang sedia ada supaya tidak bold */
table td strong,
table td b {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Tarikh */
table td .date,
table td .transaction-date {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Nama barang */
table td .item-name,
table td .item-title {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Kuantiti */
table td .quantity {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Nama staf / dilakukan oleh */
table td .staff-name,
table td .performed-by {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Perubahan stok */
table td .stock-change,
table td .stock-before,
table td .stock-after {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Rujukan */
table td .reference {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Catatan */
table td .remarks {
    font-size: 10px !important;
    font-weight: 400 !important;
}

/* Maklumat kecil seperti masa dan kod barang */
table td small,
table td .small-text,
table td .item-code,
table td .time {
    font-size: 8.5px !important;
    font-weight: 400 !important;
    line-height: 1.3 !important;
}

/* Badge jenis transaksi masih perlu sedikit emphasis */
.badge,
.status-badge,
.transaction-status {
    font-size: 8.5px !important;
    font-weight: 500 !important;
    padding: 4px 8px !important;
}
    </style>

</head>

<body>


<!-- =========================================================
     SCREEN TOOLBAR
========================================================= -->

<div class="screen-toolbar no-print">

    <div class="toolbar-text">

        <h2>Sejarah Transaksi Inventori</h2>

        <p>
            Cetak rekod transaksi inventori atau kembali ke halaman sejarah transaksi.
        </p>

    </div>


    <div class="toolbar-actions">

        <button type="button"
                class="btn btn-print"
                onclick="window.print();">

            <i class="fa-solid fa-print"></i>

            <span>Cetak Rekod</span>

        </button>


        <a href="<%= contextPath %>/inventory-transactions"
           class="btn btn-back">

            Kembali

        </a>

    </div>

</div>



<!-- =========================================================
     PRINT DOCUMENT
========================================================= -->

<div class="print-page">

    <div class="paper">


        <!-- =================================================
             COMPANY HEADER
        ================================================== -->

        <div class="company-header">

            <div class="company-logo">

                <img
                    src="<%= contextPath %>/images/logo-pkb.png"
                    alt="PKB">

            </div>


            <div class="company-info">

                <h2>
                    Permodalan Kedah Berhad
                </h2>

                <p>
                    PKB Staff Management System
                </p>

            </div>

        </div>



        <!-- =================================================
             DOCUMENT TITLE
        ================================================== -->

        <div class="document-title">

            <h1>
                Sejarah Transaksi Inventori
            </h1>

            <p>
                Rekod Pergerakan Stok Inventori PKB
            </p>

        </div>



        <!-- =================================================
             PRINT INFORMATION
        ================================================== -->

        <div class="meta-grid">

            <div class="meta-box">

                <span class="meta-label">
                    Dicetak Oleh
                </span>

                <span class="meta-value">
                    <%= esc.apply(userName) %>
                </span>

            </div>


            <div class="meta-box">

                <span class="meta-label">
                    Peranan
                </span>

                <span class="meta-value">
                    <%= esc.apply(roleDisplay) %>
                </span>

            </div>


            <div class="meta-box">

                <span class="meta-label">
                    Tarikh Cetakan
                </span>

                <span class="meta-value">
                    <%= esc.apply(printDate) %>
                </span>

            </div>

        </div>



        <!-- =================================================
             TRANSACTION TABLE
        ================================================== -->

        <div class="table-wrapper">

            <table>

                <colgroup>
                    <col style="width:10%;">
                    <col style="width:15%;">
                    <col style="width:10%;">
                    <col style="width:7%;">
                    <col style="width:11%;">
                    <col style="width:11%;">
                    <col style="width:11%;">
                    <col style="width:9%;">
                    <col style="width:16%;">
                </colgroup>


                <thead>

                    <tr>

                        <th>Tarikh / Masa</th>
                        <th>Barang</th>
                        <th>Jenis</th>
                        <th>Kuantiti</th>
                        <th>Perubahan Stok</th>
                        <th>Penerima / Staf</th>
                        <th>Dilakukan Oleh</th>
                        <th>Rujukan</th>
                        <th>Catatan</th>

                    </tr>

                </thead>


                <tbody>

                <%
                    if (transactions.isEmpty()) {
                %>

                    <tr>

                        <td colspan="9"
                            class="empty-row">

                            Tiada rekod transaksi inventori.

                        </td>

                    </tr>

                <%
                    } else {

                        for (Map<String, Object> tx : transactions) {


                            Object createdObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "created_at",
                                        "createdAt",
                                        "transaction_date",
                                        "date"
                                    }
                                );


                            String displayDate = "-";
                            String displayTime = "-";


                            if (createdObj != null) {

                                try {

                                    Date d = null;

                                    if (createdObj instanceof Timestamp) {

                                        d = new Date(
                                            ((Timestamp) createdObj)
                                                .getTime()
                                        );

                                    } else if (createdObj instanceof Date) {

                                        d = (Date) createdObj;
                                    }

                                    if (d != null) {

                                        displayDate =
                                            dateFormat.format(d);

                                        displayTime =
                                            timeFormat.format(d)
                                                .toLowerCase();
                                    }

                                } catch (Exception ignored) {
                                }
                            }


                            Object itemNameObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "item_name",
                                        "itemName",
                                        "name"
                                    }
                                );


                            Object itemCodeObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "item_code",
                                        "itemCode",
                                        "code"
                                    }
                                );


                            Object categoryObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "category_name",
                                        "category",
                                        "item_category"
                                    }
                                );


                            Object typeObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "transaction_type",
                                        "transactionType",
                                        "type"
                                    }
                                );


                            Object quantityObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "quantity",
                                        "qty"
                                    }
                                );


                            Object beforeObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "stock_before",
                                        "stockBefore"
                                    }
                                );


                            Object afterObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "stock_after",
                                        "stockAfter"
                                    }
                                );


                            Object receiverObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "receiver_name",
                                        "receiverName",
                                        "staff_name",
                                        "staffName",
                                        "requester_name",
                                        "requesterName"
                                    }
                                );


                            Object performedObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "performed_by_name",
                                        "performedByName",
                                        "performed_name",
                                        "admin_name",
                                        "performed_by"
                                    }
                                );


                            Object referenceObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "reference",
                                        "reference_no",
                                        "referenceNo",
                                        "request_reference",
                                        "request_code"
                                    }
                                );


                            Object remarksObj =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "remarks",
                                        "remark",
                                        "notes",
                                        "note"
                                    }
                                );


                            String transactionType =
                                typeObj == null
                                    ? ""
                                    : String.valueOf(typeObj);


                            String typeLabel = "Pelarasan";
                            String typeClass = "adjustment";
                            String qtyClass = "qty-adjustment";
                            String qtyPrefix = "";


                            if ("STOCK_IN".equalsIgnoreCase(
                                    transactionType)) {

                                typeLabel = "Stok Masuk";
                                typeClass = "stock-in";
                                qtyClass = "qty-in";
                                qtyPrefix = "+";

                            } else if (
                                "STOCK_OUT".equalsIgnoreCase(
                                    transactionType)) {

                                typeLabel = "Stok Keluar";
                                typeClass = "stock-out";
                                qtyClass = "qty-out";
                                qtyPrefix = "-";

                            } else if (
                                "RETURN".equalsIgnoreCase(
                                    transactionType)) {

                                typeLabel = "Pemulangan";
                                typeClass = "return";
                                qtyClass = "qty-return";
                                qtyPrefix = "+";

                            } else if (
                                "ADJUSTMENT".equalsIgnoreCase(
                                    transactionType)) {

                                typeLabel = "Pelarasan";
                                typeClass = "adjustment";
                                qtyClass = "qty-adjustment";
                            }


                            Object unitValue =
                                getValue.apply(
                                    tx,
                                    new String[]{
                                        "unit",
                                        "item_unit"
                                    }
                                );

                            String unitObj =
                                unitValue == null
                                    ? ""
                                    : String.valueOf(unitValue);


                            String quantityText =
                                quantityObj == null
                                    ? "-"
                                    : qtyPrefix
                                      + String.valueOf(quantityObj);


                            if (!unitObj.trim().isEmpty()) {

                                quantityText +=
                                    " " + unitObj;
                            }


                            String itemMeta = "";


                            if (itemCodeObj != null
                                    && !String.valueOf(itemCodeObj)
                                        .trim()
                                        .isEmpty()) {

                                itemMeta +=
                                    String.valueOf(itemCodeObj);
                            }


                            if (categoryObj != null
                                    && !String.valueOf(categoryObj)
                                        .trim()
                                        .isEmpty()) {

                                if (!itemMeta.isEmpty()) {
                                    itemMeta += " · ";
                                }

                                itemMeta +=
                                    String.valueOf(categoryObj);
                            }
                %>


                    <tr>

                        <!-- DATE -->
                        <td>

                            <div class="date-main">
                                <%= esc.apply(displayDate) %>
                            </div>

                            <div class="date-time">
                                <%= esc.apply(displayTime) %>
                            </div>

                        </td>


                        <!-- ITEM -->
                        <td>

                            <div class="item-name">
                                <%= esc.apply(itemNameObj) %>
                            </div>

                            <div class="item-meta">
                                <%= itemMeta.isEmpty()
                                        ? "-"
                                        : esc.apply(itemMeta) %>
                            </div>

                        </td>


                        <!-- TYPE -->
                        <td>

                            <span class="type-badge <%= typeClass %>">
                                <%= typeLabel %>
                            </span>

                        </td>


                        <!-- QUANTITY -->
                        <td>

                            <span class="qty <%= qtyClass %>">
                                <%= esc.apply(quantityText) %>
                            </span>

                        </td>


                        <!-- STOCK CHANGE -->
                        <td>

                            <div class="stock-change">

                                <span class="stock-before">
                                    <%= esc.apply(beforeObj) %>
                                </span>

                                <span class="stock-arrow">
                                    →
                                </span>

                                <span class="stock-after">
                                    <%= esc.apply(afterObj) %>
                                </span>

                            </div>

                        </td>


                        <!-- RECEIVER -->
                        <td>
                            <%= esc.apply(receiverObj) %>
                        </td>


                        <!-- PERFORMED BY -->
                        <td>
                            <%= esc.apply(performedObj) %>
                        </td>


                        <!-- REFERENCE -->
                        <td>

                            <span class="reference">
                                <%= esc.apply(referenceObj) %>
                            </span>

                        </td>


                        <!-- REMARK -->
                        <td>
                            <%= esc.apply(remarksObj) %>
                        </td>

                    </tr>


                <%
                        }
                    }
                %>

                </tbody>

            </table>

        </div>



        <!-- =================================================
             FOOTER
        ================================================== -->

        <div class="document-footer">

            <div>
                Jumlah Rekod:
                <strong>
                    <%= transactions.size() %>
                </strong>
            </div>


            <div>
                Dijana oleh PKB Staff Management System
            </div>

        </div>


    </div>

</div>

</body>
</html>