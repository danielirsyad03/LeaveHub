<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.*" %>

<%@ page import="java.text.SimpleDateFormat" %>

<%@ page import="java.sql.Timestamp" %>



<%

    String ctx = request.getContextPath();



    /* =========================================================

       LOGIN / USER

       \========================================================= */



    Object userObj = session.getAttribute("user");



    if (userObj == null && session.getAttribute("userId") == null) {

        response.sendRedirect(ctx + "/");

        return;

    }



    String userName = (String) session.getAttribute("userName");

    String userRole = (String) session.getAttribute("userRole");



    if (userName == null || userName.trim().isEmpty()) {

        userName = "HR Admin";

    }



    String roleDisplay = "Pentadbir Sistem";



    if (userRole != null) {

        if ("HOD".equalsIgnoreCase(userRole)) {

            roleDisplay = "Ketua Unit";

        } else if ("STAFF".equalsIgnoreCase(userRole)) {

            roleDisplay = "Staf";

        } else if ("HR".equalsIgnoreCase(userRole)) {

            roleDisplay = "Pentadbir Sistem";

        }

    }



    String userInitial =

        userName.isEmpty()

            ? "H"

            : userName.substring(0, 1).toUpperCase();





    /* =========================================================

       TRANSACTION DATA

       \========================================================= */



    @SuppressWarnings("unchecked")

    List<Map<String, Object>> transactions =

        (List<Map<String, Object>>)

        request.getAttribute("transactions");



    if (transactions == null) {

        transactions = new ArrayList<>();

    }





    Integer totalTransactions =

        (Integer) request.getAttribute("totalTransactions");



    Integer totalStockIn =

        (Integer) request.getAttribute("totalStockIn");



    Integer totalStockOut =

        (Integer) request.getAttribute("totalStockOut");



    Integer totalReturn =

        (Integer) request.getAttribute("totalReturn");



    Integer totalAdjustment =

        (Integer) request.getAttribute("totalAdjustment");





    if (totalTransactions == null) {

        totalTransactions = transactions.size();

    }



    if (totalStockIn == null) {

        totalStockIn = 0;

    }



    if (totalStockOut == null) {

        totalStockOut = 0;

    }



    if (totalReturn == null) {

        totalReturn = 0;

    }



    if (totalAdjustment == null) {

        totalAdjustment = 0;

    }





    /* =========================================================

       FILTER VALUES

       \========================================================= */



    String search =

        request.getAttribute("search") == null

            ? request.getParameter("search")

            : request.getAttribute("search").toString();



    String type =

        request.getAttribute("selectedType") == null

            ? request.getParameter("type")

            : request.getAttribute("selectedType").toString();



    String dateFrom =

        request.getAttribute("dateFrom") == null

            ? request.getParameter("dateFrom")

            : request.getAttribute("dateFrom").toString();



    String dateTo =

        request.getAttribute("dateTo") == null

            ? request.getParameter("dateTo")

            : request.getAttribute("dateTo").toString();



    if (search == null) search = "";

    if (type == null) type = "";

    if (dateFrom == null) dateFrom = "";

    if (dateTo == null) dateTo = "";

%>



<!DOCTYPE html>



<html lang="ms">



<head>



    <meta charset="UTF-8">



    <meta

        name="viewport"

        content="width=device-width, initial-scale=1.0"

    >



    <title>Sejarah Transaksi Inventori - PKB</title>





    <!-- =========================================================

         GLOBAL CSS

         \========================================================= -->



    <link

        rel="stylesheet"

        href="<%= ctx %>/css/style.css?v=20260914-unified"

    >





    <style>



        /* =====================================================

           PAGE HEADER

           \===================================================== */



        .transaction-page-header {

            display: flex;

            align-items: flex-start;

            justify-content: space-between;

            gap: 20px;

            margin-bottom: 22px;

        }



        .transaction-page-header h1 {

            margin: 0 0 6px;

            font-size: 28px;

            line-height: 1.2;

            color: #081a35;

        }



        .transaction-page-header p {

            margin: 0;

            font-size: 14px;

            font-weight: 400;

            color: #8794a8;

        }





        /* =====================================================

           SUMMARY

           \===================================================== */



        .transaction-summary-grid {

            display: grid;

            grid-template-columns: repeat(5, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 20px;

        }



        .transaction-summary-card {

            position: relative;



            display: flex;

            align-items: center;



            gap: 14px;



            min-height: 96px;



            padding: 18px 16px;



            background: #ffffff;



            border: 1px solid #e1e6ed;

            border-radius: 14px;



            overflow: hidden;

        }



        .transaction-summary-card::before {

            content: "";



            position: absolute;



            top: 0;

            bottom: 0;

            left: 0;



            width: 3px;

        }



        .transaction-summary-card.total::before {

            background: #b51d32;

        }



        .transaction-summary-card.in::before {

            background: #249a69;

        }



        .transaction-summary-card.out::before {

            background: #d73a4a;

        }



        .transaction-summary-card.return::before {

            background: #3579b9;

        }



        .transaction-summary-card.adjust::before {

            background: #d79c12;

        }





        .transaction-summary-icon {

            width: 44px;

            height: 44px;



            flex: 0 0 44px;



            display: flex;

            align-items: center;

            justify-content: center;



            border-radius: 12px;

        }



        .transaction-summary-card.total .transaction-summary-icon {

            color: #b51d32;

            background: #fff1f3;

        }



        .transaction-summary-card.in .transaction-summary-icon {

            color: #16835a;

            background: #edf8f3;

        }



        .transaction-summary-card.out .transaction-summary-icon {

            color: #cf3446;

            background: #fff1f2;

        }



        .transaction-summary-card.return .transaction-summary-icon {

            color: #3477b5;

            background: #eef6ff;

        }



        .transaction-summary-card.adjust .transaction-summary-icon {

            color: #c68808;

            background: #fff7e7;

        }





        .transaction-summary-info {

            min-width: 0;

        }



        .transaction-summary-label {

            display: block;



            margin-bottom: 4px;



            color: #71809a;



            font-size: 11px;

            font-weight: 600;



            text-transform: uppercase;

        }



        .transaction-summary-info strong {

            display: block;



            color: #071b38;



            font-size: 24px;

            line-height: 1;

            font-weight: 600;

        }



        .transaction-summary-info small {

            display: block;



            margin-top: 6px;



            color: #8c98ac;



            font-size: 11px;

            font-weight: 400;

        }





        /* =====================================================

           MAIN CARD

           \===================================================== */



        .transaction-card {

            width: 100%;



            background: #ffffff;



            border: 1px solid #e1e6ed;

            border-radius: 14px;



            overflow: hidden;

        }



        .transaction-card-header {

            min-height: 86px;



            display: flex;

            align-items: center;

            justify-content: space-between;



            gap: 20px;



            padding: 20px 22px;



            border-bottom: 1px solid #e8ecf1;

        }



        .transaction-card-header h2 {

            margin: 0 0 5px;



            color: #081a35;



            font-size: 19px;

            font-weight: 600;

        }



        .transaction-card-header p {

            margin: 0;



            color: #8995a8;



            font-size: 13px;

            font-weight: 400;

        }





        /* =====================================================

           PRINT BUTTON

           \===================================================== */



        .transaction-print-btn {

            display: inline-flex;

            align-items: center;

            justify-content: center;



            gap: 8px;



            min-height: 42px;



            padding: 0 17px;



            border: 1px solid #dfb55b;

            border-radius: 10px;



            background: #fffaf0;



            color: #8a6516;



            font-family: inherit;

            font-size: 13px;

            font-weight: 600;



            text-decoration: none;



            white-space: nowrap;



            cursor: pointer;



            transition:

                background .18s ease,

                border-color .18s ease,

                transform .18s ease;

        }



        .transaction-print-btn:hover {

            background: #fff4dc;

            border-color: #d7a63e;

            transform: translateY(-1px);

        }



        .transaction-print-btn svg {

            width: 17px;

            height: 17px;

            flex: 0 0 17px;

        }





        /* =====================================================

           FILTER

           \===================================================== */



        .transaction-filter {

            display: grid;



            grid-template-columns:

                minmax(240px, 1.55fr)

                minmax(160px, .85fr)

                minmax(150px, .75fr)

                minmax(150px, .75fr)

                auto

                auto

                minmax(145px, auto);



            align-items: center;



            gap: 10px;



            padding: 14px 16px;



            background: #fbfcfd;



            border-bottom: 1px solid #e7ebf0;

        }





        .transaction-search {

            position: relative;

        }



        .transaction-search svg {

            position: absolute;



            left: 13px;

            top: 50%;



            transform: translateY(-50%);



            color: #9aa7ba;



            pointer-events: none;

        }



        .transaction-search input {

            width: 100%;

            padding-left: 42px !important;

        }





        .transaction-filter input,

        .transaction-filter select {

            box-sizing: border-box;



            width: 100%;

            height: 42px;



            padding: 0 13px;



            border: 1px solid #dce3eb;

            border-radius: 9px;



            background: #ffffff;



            color: #43516a;



            font-family: inherit;

            font-size: 13px;

            font-weight: 400;



            outline: none;

        }



        .transaction-filter input:focus,

        .transaction-filter select:focus {

            border-color: #b7c1ce;



            box-shadow:

                0 0 0 3px

                rgba(183, 25, 48, .05);

        }





        .transaction-search-btn {

            height: 42px;



            padding: 0 18px;



            border: none;

            border-radius: 9px;



            background: #b71930;



            color: #ffffff;



            font-family: inherit;

            font-size: 13px;

            font-weight: 600;



            cursor: pointer;

        }



        .transaction-search-btn:hover {

            background: #9f1529;

        }





        .transaction-reset-btn {

            height: 42px;



            display: inline-flex;

            align-items: center;

            justify-content: center;



            padding: 0 16px;



            border: 1px solid #dce3eb;

            border-radius: 9px;



            background: #ffffff;



            color: #506078;



            font-size: 13px;

            font-weight: 500;



            text-decoration: none;

        }



        .transaction-reset-btn:hover {

            background: #f7f9fb;

        }





        .transaction-record-count {

            text-align: right;



            color: #8b98ab;



            font-size: 12px;

            font-weight: 400;



            white-space: nowrap;

        }



        .transaction-record-count strong {

            color: #b71930;

            font-weight: 600;

        }





        /* =====================================================

           TABLE

           STANDARD FONT - SAMA SEPERTI PAGE INVENTORI

           \===================================================== */



        .transaction-table-wrapper {

            width: 100%;

            overflow-x: auto;

        }



        .transaction-table {

            width: 100%;



            border-collapse: collapse;



            table-layout: auto;

        }



        .transaction-table thead {

            background: #f7f9fb;

        }



        .transaction-table th {

            padding: 13px 10px;



            border-bottom: 1px solid #dde3ea;



            text-align: left;



            color: #687891;



            font-size: 10px;

            font-weight: 600;



            white-space: nowrap;

        }



        .transaction-table td {

            padding: 13px 10px;



            border-bottom: 1px solid #e8ecf1;



            color: #43516a;



            font-size: 12px;

            font-weight: 400;



            line-height: 1.4;



            vertical-align: middle;

        }



        .transaction-table tbody tr:last-child td {

            border-bottom: none;

        }



        .transaction-table tbody tr:hover {

            background: #fcfdfe;

        }





        /* MAIN TEXT */
        .transaction-table td > strong {

            color: #25334a;



            font-size: 12px;

            font-weight: 600;



            line-height: 1.35;

        }





        /* SECONDARY TEXT */
        .transaction-table td small {

            display: block;



            margin-top: 3px;



            color: #8997ab;



            font-size: 10px;

            font-weight: 400;



            line-height: 1.35;

        }





        /* TARIKH */
        .transaction-table td:first-child strong {

            font-size: 12px;

            font-weight: 600;

            color: #25334a;

        }



        .transaction-table td:first-child small {

            font-size: 10px;

            font-weight: 400;

            color: #8997ab;

        }





        /* BARANG */
        .transaction-table td:nth-child(2) strong {

            font-size: 12px;

            font-weight: 600;

            color: #25334a;

        }





        /* QUANTITY */
        .transaction-table td:nth-child(4) strong {

            font-size: 12px;

            font-weight: 600;

        }





        /* STOCK CHANGE */
        .transaction-table td:nth-child(5) {

            font-size: 12px;

            font-weight: 400;

        }



        .transaction-table td:nth-child(5) strong {

            font-size: 12px;

            font-weight: 600;

            color: #25334a;

        }





        /* RECEIVER */
        .transaction-table td:nth-child(6) strong {

            font-size: 12px;

            font-weight: 600;

            color: #25334a;

        }





        /* PERFORMED BY */
        .transaction-table td:nth-child(7) strong {

            font-size: 12px;

            font-weight: 600;

            color: #25334a;

        }





        /* CATATAN */
        .transaction-table td:nth-child(9) {

            color: #526078;



            font-size: 11px;

            font-weight: 400;



            line-height: 1.5;

        }





        /* =====================================================

           STATUS

           \===================================================== */



        .transaction-status {

            display: inline-flex;

            align-items: center;



            gap: 6px;



            padding: 5px 9px;



            border-radius: 999px;



            font-size: 10px;

            font-weight: 600;



            white-space: nowrap;

        }



        .transaction-status-dot {

            width: 5px;

            height: 5px;



            border-radius: 50%;



            background: currentColor;

        }



        .status-in {

            color: #147653;



            background: #ebf8f2;



            border: 1px solid #ccebdd;

        }



        .status-out {

            color: #c42b3c;



            background: #fff0f2;



            border: 1px solid #f3ced4;

        }



        .status-return {

            color: #316fa9;



            background: #edf5fd;



            border: 1px solid #d2e3f4;

        }



        .status-adjust {

            color: #8053b5;



            background: #f5effb;



            border: 1px solid #e4d8f2;

        }



        .quantity-positive {

            color: #087744 !important;

        }



        .quantity-negative {

            color: #c3132c !important;

        }



        .stock-before {

            color: #8a98ac;

            font-size: 12px;

            font-weight: 400;

        }



        .stock-arrow {

            margin: 0 5px;



            color: #a2adbd;



            font-size: 12px;

            font-weight: 400;

        }



        .transaction-reference {

            color: #a71428 !important;



            font-size: 12px !important;

            font-weight: 600 !important;



            line-height: 1.35;

        }





        /* =====================================================

           EMPTY

           \===================================================== */



        .transaction-empty {

            padding: 45px 20px !important;



            text-align: center !important;



            color: #8793a7 !important;



            font-weight: 400 !important;

        }





        /* =====================================================

           RESPONSIVE

           \===================================================== */



        @media (max-width: 1250px) {



            .transaction-summary-grid {

                grid-template-columns:

                    repeat(3, 1fr);

            }



            .transaction-filter {

                grid-template-columns:

                    1fr 1fr 1fr;

            }



            .transaction-record-count {

                text-align: left;

            }

        }





        @media (max-width: 850px) {



            .transaction-summary-grid {

                grid-template-columns:

                    1fr 1fr;

            }



            .transaction-filter {

                grid-template-columns: 1fr;

            }



            .transaction-card-header {

                flex-direction: column;

                align-items: flex-start;

            }



            .transaction-print-btn {

                width: 100%;

            }



            .transaction-record-count {

                text-align: left;

            }

        }





        @media (max-width: 550px) {



            .transaction-summary-grid {

                grid-template-columns: 1fr;

            }



            .transaction-page-header {

                flex-direction: column;

            }

        }


        /* Compact phone layout used across the other LeaveHub pages. */
        @media (max-width: 600px) {
            .topbar {
                position: relative;
                display: block;
                min-height: 48px;
                padding-right: 0;
                margin-bottom: 18px;
            }

            .topbar > div:first-child {
                width: calc(100% - 108px);
                max-width: calc(100% - 108px);
            }

            .topbar h1 {
                width: 100%;
                max-width: 100%;
                margin: 0 0 6px;
                font-size: 22px;
                line-height: 1.2;
            }

            .topbar p {
                width: 100%;
                font-size: 13px;
                line-height: 1.45;
            }

            .pkb-header-actions {
                position: absolute;
                top: 0;
                right: 0;
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 8px;
                width: 100px;
            }

            .pkb-user-name {
                display: none;
            }

            .transaction-summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 10px;
                margin-bottom: 14px;
            }

            .transaction-summary-card {
                min-height: 90px;
                padding: 12px 10px;
                gap: 9px;
                align-items: flex-start;
            }

            .transaction-summary-icon {
                width: 34px;
                height: 34px;
                flex: 0 0 34px;
            }

            .transaction-summary-icon svg {
                width: 18px;
                height: 18px;
            }

            .transaction-summary-label {
                font-size: 10px;
                line-height: 1.25;
            }

            .transaction-summary-info strong {
                font-size: 21px;
                line-height: 1.1;
            }

            .transaction-summary-info small {
                font-size: 10px;
                line-height: 1.3;
            }

            .transaction-card-header {
                gap: 10px;
            }

            .transaction-print-btn {
                width: 100%;
            }

            .transaction-table-wrapper {
                overflow: visible;
                border: 0;
                background: transparent;
            }

            .transaction-table,
            .transaction-table tbody {
                display: block;
                width: 100%;
            }

            .transaction-table thead {
                display: none;
            }

            .transaction-table tbody tr {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 10px 12px;
                margin-bottom: 10px;
                padding: 14px;
                border: 1px solid #e0e5ed;
                border-left: 4px solid #a51e32;
                border-radius: 14px;
                background: #fff;
                box-shadow: 0 5px 14px rgba(15, 35, 65, .05);
            }

            .transaction-table tbody tr:hover {
                background: #fff;
            }

            .transaction-table td {
                display: flex;
                min-width: 0;
                flex-direction: column;
                align-items: flex-start;
                gap: 3px;
                padding: 0;
                border: 0 !important;
                font-size: 12px;
                overflow-wrap: anywhere;
            }

            .transaction-table td::before {
                color: #8794a8;
                font-size: 9px;
                font-weight: 700;
                letter-spacing: .04em;
                text-transform: uppercase;
            }

            .transaction-table td:nth-child(1)::before { content: "Tarikh / Masa"; }
            .transaction-table td:nth-child(2)::before { content: "Barang"; }
            .transaction-table td:nth-child(3)::before { content: "Jenis"; }
            .transaction-table td:nth-child(4)::before { content: "Kuantiti"; }
            .transaction-table td:nth-child(5)::before { content: "Perubahan Stok"; }
            .transaction-table td:nth-child(6)::before { content: "Penerima / Staf"; }
            .transaction-table td:nth-child(7)::before { content: "Dilakukan Oleh"; }
            .transaction-table td:nth-child(8)::before { content: "Rujukan"; }
            .transaction-table td:nth-child(9)::before { content: "Catatan"; }

            .transaction-table td:nth-child(2),
            .transaction-table td:nth-child(9) {
                grid-column: 1 / -1;
            }

            .transaction-table td > strong,
            .transaction-table td small {
                max-width: 100%;
                overflow-wrap: anywhere;
            }

            .transaction-table .transaction-empty {
                display: block;
                grid-column: 1 / -1;
                padding: 20px 8px !important;
                text-align: center !important;
            }
        }



    </style>



</head>





<body>





<div class="app">





    <!-- =====================================================

         SIDEBAR

         \===================================================== -->



    <%@ include file="includes/sidebar.jspf" %>





    <!-- =====================================================

         MAIN

         \===================================================== -->



    <main>





        <!-- =================================================

             TOP BAR

             \================================================= -->



        <div class="topbar">





            <div>



                <h1>

                    Sejarah Transaksi Inventori

                </h1>



                <p>

                    Rekod lengkap pergerakan stok inventori syarikat.

                </p>



            </div>





            <%@ include file="includes/header-actions.jspf" %>





        </div>





        <!-- =================================================

             SUMMARY CARDS

             \================================================= -->



        <div class="transaction-summary-grid">





            <!-- JUMLAH -->



            <div class="transaction-summary-card total">



                <div class="transaction-summary-icon">



                    <svg

                        width="22"

                        height="22"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >

                        <path d="M4 19V9"></path>

                        <path d="M10 19V5"></path>

                        <path d="M16 19v-7"></path>

                        <path d="M22 19H2"></path>

                    </svg>



                </div>





                <div class="transaction-summary-info">



                    <span class="transaction-summary-label">

                        Jumlah Transaksi

                    </span>



                    <strong>

                        <%= totalTransactions %>

                    </strong>



                    <small>

                        Semua rekod

                    </small>



                </div>



            </div>





            <!-- STOK MASUK -->



            <div class="transaction-summary-card in">



                <div class="transaction-summary-icon">



                    <svg

                        width="22"

                        height="22"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >

                        <path d="M12 19V5"></path>

                        <path d="M6 11l6-6 6 6"></path>

                    </svg>



                </div>





                <div class="transaction-summary-info">



                    <span class="transaction-summary-label">

                        Stok Masuk

                    </span>



                    <strong>

                        <%= totalStockIn %>

                    </strong>



                    <small>

                        Tambahan stok

                    </small>



                </div>



            </div>





            <!-- STOK KELUAR -->



            <div class="transaction-summary-card out">



                <div class="transaction-summary-icon">



                    <svg

                        width="22"

                        height="22"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >

                        <path d="M12 5v14"></path>

                        <path d="M18 13l-6 6-6-6"></path>

                    </svg>



                </div>





                <div class="transaction-summary-info">



                    <span class="transaction-summary-label">

                        Stok Keluar

                    </span>



                    <strong>

                        <%= totalStockOut %>

                    </strong>



                    <small>

                        Barang dikeluarkan

                    </small>



                </div>



            </div>





            <!-- PEMULANGAN -->



            <div class="transaction-summary-card return">



                <div class="transaction-summary-icon">



                    <svg

                        width="22"

                        height="22"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >

                        <path d="M9 14l-4-4 4-4"></path>

                        <path d="M5 10h9a5 5 0 0 1 5 5v3"></path>

                    </svg>



                </div>





                <div class="transaction-summary-info">



                    <span class="transaction-summary-label">

                        Pemulangan

                    </span>



                    <strong>

                        <%= totalReturn %>

                    </strong>



                    <small>

                        Barang dipulangkan

                    </small>



                </div>



            </div>





            <!-- PELARASAN -->



            <div class="transaction-summary-card adjust">



                <div class="transaction-summary-icon">



                    <svg

                        width="22"

                        height="22"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >

                        <path d="M4 7h10"></path>

                        <path d="M18 7h2"></path>

                        <path d="M14 4v6"></path>



                        <path d="M4 17h2"></path>

                        <path d="M10 17h10"></path>

                        <path d="M10 14v6"></path>

                    </svg>



                </div>





                <div class="transaction-summary-info">



                    <span class="transaction-summary-label">

                        Pelarasan

                    </span>



                    <strong>

                        <%= totalAdjustment %>

                    </strong>



                    <small>

                        Pelarasan stok

                    </small>



                </div>



            </div>





        </div>





        <!-- =================================================

             TRANSACTION CARD

             \================================================= -->



        <section class="transaction-card">





            <!-- HEADER -->



            <div class="transaction-card-header">





                <div>



                    <h2>

                        Rekod Transaksi

                    </h2>



                    <p>

                        Senarai pergerakan stok inventori yang direkodkan dalam sistem.

                    </p>



                </div>





                <a

                    href="<%= ctx %>/print-inventory-transactions"

                    class="transaction-print-btn"

                >



                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        aria-hidden="true"
                    >
                        <polyline points="6 9 6 2 18 2 18 9"></polyline>
                        <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
                        <rect x="6" y="14" width="12" height="8"></rect>
                        <line x1="17" y1="12" x2="17.01" y2="12"></line>
                    </svg>



                    Cetak Rekod



                </a>





            </div>





            <!-- =================================================

                 FILTER

                 \================================================= -->



            <form

                method="get"

                action="<%= ctx %>/inventory-transactions"

                class="transaction-filter"

            >





                <div class="transaction-search">



                    <svg

                        width="18"

                        height="18"

                        viewBox="0 0 24 24"

                        fill="none"

                        stroke="currentColor"

                        stroke-width="1.8"

                        stroke-linecap="round"

                        stroke-linejoin="round"

                    >



                        <circle

                            cx="11"

                            cy="11"

                            r="8"

                        ></circle>



                        <path

                            d="m21 21-4.35-4.35"

                        ></path>



                    </svg>





                    <input

                        type="text"

                        name="search"

                        value="<%= search %>"

                        placeholder="Cari barang, staf, pegawai..."

                    >



                </div>





                <select name="type">



                    <option

                        value=""

                        <%= type.isEmpty() ? "selected" : "" %>

                    >

                        Semua Transaksi

                    </option>



                    <option

                        value="STOCK_IN"

                        <%= "STOCK_IN".equals(type) ? "selected" : "" %>

                    >

                        Stok Masuk

                    </option>



                    <option

                        value="STOCK_OUT"

                        <%= "STOCK_OUT".equals(type) ? "selected" : "" %>

                    >

                        Stok Keluar

                    </option>



                    <option

                        value="RETURN"

                        <%= "RETURN".equals(type) ? "selected" : "" %>

                    >

                        Pemulangan

                    </option>



                    <option

                        value="ADJUSTMENT"

                        <%= "ADJUSTMENT".equals(type) ? "selected" : "" %>

                    >

                        Pelarasan

                    </option>


                    <option

                        value="DELETE_INVENTORY"

                        <%= "DELETE_INVENTORY".equals(type) ? "selected" : "" %>

                    >

                        Padam Inventori

                    </option>



                </select>





                <input

                    type="date"

                    name="dateFrom"

                    value="<%= dateFrom %>"

                >





                <input

                    type="date"

                    name="dateTo"

                    value="<%= dateTo %>"

                >





                <button

                    type="submit"

                    class="transaction-search-btn"

                >

                    Cari

                </button>





                <a

                    href="<%= ctx %>/inventory-transactions"

                    class="transaction-reset-btn"

                >

                    Reset

                </a>





                <div class="transaction-record-count">



                    <strong>

                        <%= transactions.size() %>

                    </strong>



                    daripada



                    <%= totalTransactions %>



                    rekod



                </div>





            </form>





            <!-- =================================================

                 TABLE

                 \================================================= -->



            <div class="transaction-table-wrapper">



                <table class="transaction-table">





                    <thead>



                        <tr>



                            <th>TARIKH / MASA</th>



                            <th>BARANG</th>



                            <th>JENIS</th>



                            <th>KUANTITI</th>



                            <th>PERUBAHAN STOK</th>



                            <th>PENERIMA / STAF</th>



                            <th>DILAKUKAN OLEH</th>



                            <th>RUJUKAN</th>



                            <th>CATATAN</th>



                        </tr>



                    </thead>





                    <tbody>



                    <%

                        if (transactions.isEmpty()) {

                    %>





                        <tr>



                            <td

                                colspan="9"

                                class="transaction-empty"

                            >

                                Tiada rekod transaksi inventori ditemui.

                            </td>



                        </tr>





                    <%

                        } else {



                            for (Map<String, Object> tx : transactions) {





                                /* TRANSACTION TYPE */
                                String transactionType =

                                    tx.get("transaction_type") == null

                                        ? ""

                                        : tx.get("transaction_type").toString();





                                String badgeClass = "status-adjust";

                                String badgeText = "Pelarasan";





                                if ("STOCK_IN".equalsIgnoreCase(transactionType)) {



                                    badgeClass = "status-in";

                                    badgeText = "Stok Masuk";



                                } else if ("STOCK_OUT".equalsIgnoreCase(transactionType)) {



                                    badgeClass = "status-out";

                                    badgeText = "Stok Keluar";



                                } else if ("RETURN".equalsIgnoreCase(transactionType)) {



                                    badgeClass = "status-return";

                                    badgeText = "Pemulangan";



                                } else if ("ADJUSTMENT".equalsIgnoreCase(transactionType)) {



                                    badgeClass = "status-adjust";

                                    badgeText = "Pelarasan";

                                } else if ("DELETE_INVENTORY".equalsIgnoreCase(transactionType)) {



                                    badgeClass = "status-out";

                                    badgeText = "Padam Inventori";

                                }





                                /* QUANTITY */
                                Object qtyObj = tx.get("quantity");



                                int qty = 0;



                                if (qtyObj instanceof Number) {

                                    qty = ((Number) qtyObj).intValue();

                                }





                                String qtyPrefix = "";



                                if (

                                    "STOCK_IN".equalsIgnoreCase(transactionType)

                                    ||

                                    "RETURN".equalsIgnoreCase(transactionType)

                                ) {



                                    qtyPrefix = "+";



                                } else if (

                                    "STOCK_OUT".equalsIgnoreCase(transactionType)

                                ) {



                                    qtyPrefix = "-";

                                }





                                String quantityClass = "";



                                if (

                                    "STOCK_IN".equalsIgnoreCase(transactionType)

                                    ||

                                    "RETURN".equalsIgnoreCase(transactionType)

                                ) {



                                    quantityClass = "quantity-positive";



                                } else if (

                                    "STOCK_OUT".equalsIgnoreCase(transactionType)

                                ) {



                                    quantityClass = "quantity-negative";

                                }





                                /* DATE / TIME */
                                Timestamp createdAt = null;



                                Object createdObj =

                                    tx.get("created_at");



                                if (createdObj instanceof Timestamp) {



                                    createdAt =

                                        (Timestamp) createdObj;

                                }





                                String displayDate = "-";

                                String displayTime = "";





                                if (createdAt != null) {



                                    SimpleDateFormat dateFormat =

                                        new SimpleDateFormat(

                                            "dd/MM/yyyy"

                                        );



                                    SimpleDateFormat timeFormat =

                                        new SimpleDateFormat(

                                            "hh:mm a"

                                        );



                                    displayDate =

                                        dateFormat.format(

                                            createdAt

                                        );



                                    displayTime =

                                        timeFormat

                                            .format(createdAt)

                                            .toLowerCase();

                                }





                                /* ITEM */
                                String itemName =

                                    tx.get("item_name") == null

                                        ? "-"

                                        : tx.get("item_name").toString();





                                String itemCode =

                                    tx.get("item_code") == null

                                        ? "-"

                                        : tx.get("item_code").toString();





                                String unit =

                                    tx.get("unit") == null

                                        ? "Unit"

                                        : tx.get("unit").toString();





                                if (

                                    unit == null

                                    ||

                                    unit.trim().isEmpty()

                                ) {



                                    unit = "Unit";

                                }





                                /* STOCK */
                                Object stockBefore =

                                    tx.get("stock_before");



                                Object stockAfter =

                                    tx.get("stock_after");





                                /* RECEIVER */
                                String receiver =

                                    tx.get("receiver_display") == null

                                        ? "-"

                                        : tx.get("receiver_display").toString();





                                String staffEmail =

                                    tx.get("staff_email") == null

                                        ? ""

                                        : tx.get("staff_email").toString();





                                /* PERFORMED BY */
                                String performedBy =

                                    tx.get("performed_by_display") == null

                                        ? "-"

                                        : tx.get("performed_by_display").toString();





                                String performedEmail =

                                    tx.get("performed_by_email") == null

                                        ? ""

                                        : tx.get("performed_by_email").toString();





                                /* REFERENCE */
                                String reference =

                                    tx.get("reference") == null

                                        ? "-"

                                        : tx.get("reference").toString();





                                /* REMARKS */
                                String remarks =

                                    tx.get("remarks") == null

                                        ? "-"

                                        : tx.get("remarks").toString();





                                if (

                                    remarks == null

                                    ||

                                    remarks.trim().isEmpty()

                                ) {



                                    remarks = "-";

                                }

                    %>





                        <tr>





                            <!-- TARIKH / MASA -->



                            <td>



                                <strong>

                                    <%= displayDate %>

                                </strong>



                                <small>

                                    <%= displayTime %>

                                </small>



                            </td>





                            <!-- BARANG -->



                            <td>



                                <strong>

                                    <%= itemName %>

                                </strong>



                                <small>

                                    <%= itemCode %>

                                </small>



                            </td>





                            <!-- JENIS -->



                            <td>



                                <span

                                    class="transaction-status <%= badgeClass %>"

                                >



                                    <span

                                        class="transaction-status-dot"

                                    ></span>



                                    <%= badgeText %>



                                </span>



                            </td>





                            <!-- KUANTITI -->



                            <td>



                                <strong

                                    class="<%= quantityClass %>"

                                >



                                    <%= "DELETE_INVENTORY".equalsIgnoreCase(transactionType)

                                        ? "—"

                                        : qtyPrefix + qty + " " + unit %>



                                </strong>



                            </td>





                            <!-- PERUBAHAN STOK -->



                            <td>



                                <% if ("DELETE_INVENTORY".equalsIgnoreCase(transactionType)) { %>

                                    <span class="stock-before">—</span>

                                <% } else { %>



                                    <span class="stock-before">



                                        <%= stockBefore == null

                                            ? "-"

                                            : stockBefore

                                        %>



                                    </span>





                                    <span class="stock-arrow">

                                        →

                                    </span>





                                    <strong>



                                        <%= stockAfter == null

                                            ? "-"

                                            : stockAfter

                                        %>



                                    </strong>



                                <% } %>



                            </td>





                            <!-- PENERIMA / STAF -->



                            <td>



                                <%

                                    if (

                                        receiver == null

                                        ||

                                        receiver.trim().isEmpty()

                                        ||

                                        "-".equals(receiver)

                                    ) {

                                %>



                                    -



                                <%

                                    } else {

                                %>



                                    <strong>

                                        <%= receiver %>

                                    </strong>





                                    <%

                                        if (

                                            staffEmail != null

                                            &&

                                            !staffEmail

                                                .trim()

                                                .isEmpty()

                                        ) {

                                    %>



                                        <small>

                                            <%= staffEmail %>

                                        </small>



                                    <%

                                        }

                                    %>



                                <%

                                    }

                                %>



                            </td>





                            <!-- DILAKUKAN OLEH -->



                            <td>



                                <%

                                    if (

                                        performedBy == null

                                        ||

                                        performedBy.trim().isEmpty()

                                        ||

                                        "-".equals(performedBy)

                                    ) {

                                %>



                                    -



                                <%

                                    } else {

                                %>



                                    <strong>

                                        <%= performedBy %>

                                    </strong>





                                    <%

                                        if (

                                            performedEmail != null

                                            &&

                                            !performedEmail

                                                .trim()

                                                .isEmpty()

                                        ) {

                                    %>



                                        <small>

                                            <%= performedEmail %>

                                        </small>



                                    <%

                                        }

                                    %>



                                <%

                                    }

                                %>



                            </td>





                            <!-- RUJUKAN -->



                            <td>



                                <%

                                    if (

                                        reference != null

                                        &&

                                        !reference.trim().isEmpty()

                                        &&

                                        !"-".equals(reference)

                                    ) {

                                %>



                                    <strong

                                        class="transaction-reference"

                                    >

                                        <%= reference %>

                                    </strong>



                                <%

                                    } else {

                                %>



                                    -



                                <%

                                    }

                                %>



                            </td>





                            <!-- CATATAN -->



                            <td>



                                <%= remarks %>



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





    </main>





</div>





</body>



</html>&#x9;
