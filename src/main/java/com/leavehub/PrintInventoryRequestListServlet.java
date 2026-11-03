package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


@WebServlet("/print-inventory-request-list")
public class PrintInventoryRequestListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // SESSION + HR CHECK
        // =====================================================

        HttpSession session =
                request.getSession(false);


        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        String role =
                session.getAttribute("userRole") == null
                    ? ""
                    : session.getAttribute("userRole")
                        .toString()
                        .trim()
                        .toUpperCase();


        if (!"HR".equals(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        String printedBy =
                session.getAttribute("userName") == null
                    ? "Pentadbir Sistem"
                    : session.getAttribute("userName")
                        .toString();


        // =====================================================
        // SQL
        // =====================================================

        String sql = """

            SELECT
                r.id,
                r.quantity,
                r.purpose,
                r.status,
                r.remarks,
                r.requested_at,
                r.reviewed_at,

                u.name AS staff_name,
                u.email AS staff_email,

                i.item_code,
                i.item_name,
                i.category,
                i.item_type,

                reviewer.name AS reviewer_name

            FROM inventory_requests r

            JOIN users u
                ON r.user_id = u.id

            JOIN inventory_items i
                ON r.item_id = i.id

            LEFT JOIN users reviewer
                ON r.reviewed_by = reviewer.id

            ORDER BY
                r.requested_at DESC

        """;


        response.setContentType(
            "text/html;charset=UTF-8"
        );


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery();

            PrintWriter out =
                    response.getWriter()
        ) {


            String printedDate =
                    LocalDateTime.now()
                        .format(
                            DateTimeFormatter.ofPattern(
                                "dd/MM/yyyy HH:mm"
                            )
                        );


            // =================================================
            // HTML START
            // =================================================

            out.println("""
                <!DOCTYPE html>

                <html lang="ms">

                <head>

                    <meta charset="UTF-8">

                    <meta
                        name="viewport"
                        content="width=device-width, initial-scale=1.0"
                    >

                    <title>
                        Senarai Permohonan Inventori
                    </title>


                    <style>

                        /* =====================================
                           GLOBAL
                           ===================================== */

                        * {
                            box-sizing: border-box;
                        }


                        html,
                        body {
                            width: 100%;
                            max-width: 100%;
                            overflow-x: hidden;
                        }


                        body {
                            margin: 0;

                            padding: 24px;

                            background: #f6f7fa;

                            color: #172033;

                            font-family:
                                "Segoe UI",
                                Arial,
                                sans-serif;
                        }


                        /* =====================================
                           TOP ACTION BAR
                           ===================================== */

                        .top-actions-wrapper {
                            width: 100%;

                            max-width: 1500px;

                            margin:
                                0 auto 14px;
                        }


                        .actions {
                            width: 100%;

                            display: flex;

                            align-items: center;

                            justify-content: flex-end;

                            gap: 10px;

                            padding: 12px 14px;

                            background: #ffffff;

                            border:
                                1px solid #e6e9ef;

                            border-radius: 12px;

                            box-shadow:
                                0 4px 15px
                                rgba(0,0,0,.045);
                        }


                        .actions-info {
                            min-width: 0;

                            margin-right: auto;
                        }


                        .actions-info strong {
                            display: block;

                            color: #172033;

                            font-size: 13px;

                            font-weight: 700;
                        }


                        .actions-info span {
                            display: block;

                            margin-top: 2px;

                            color: #8490a3;

                            font-size: 10px;
                        }


                        /* =====================================
                           BUTTONS
                           ===================================== */

                        .btn {
                            min-height: 38px;

                            display: inline-flex;

                            align-items: center;

                            justify-content: center;

                            padding:
                                0 17px;

                            border-radius: 8px;

                            font-family: inherit;

                            font-size: 11px;

                            font-weight: 700;

                            line-height: 1;

                            text-decoration: none;

                            cursor: pointer;

                            transition:
                                background .15s ease,
                                border-color .15s ease,
                                color .15s ease,
                                transform .15s ease,
                                box-shadow .15s ease;
                        }


                        .btn:hover {
                            transform:
                                translateY(-1px);
                        }


                        .btn-print {
                            background: #8d1f2d;

                            border:
                                1px solid #8d1f2d;

                            color: #ffffff;

                            box-shadow:
                                0 3px 8px
                                rgba(141,31,45,.13);
                        }


                        .btn-print:hover {
                            background: #761824;

                            border-color: #761824;

                            box-shadow:
                                0 4px 10px
                                rgba(141,31,45,.18);
                        }


                        .btn-back {
                            background: #ffffff;

                            border:
                                1px solid #d8dde4;

                            color: #515c6d;
                        }


                        .btn-back:hover {
                            background: #f7f8fa;

                            border-color: #c9ced6;

                            color: #303a49;
                        }


                        /* =====================================
                           PAGE / DOCUMENT
                           ===================================== */

                        .page {
                            width: 100%;

                            max-width: 1500px;

                            margin: auto;

                            padding: 30px;

                            background: #ffffff;

                            border:
                                1px solid #e6e9ef;

                            border-radius: 14px;

                            box-shadow:
                                0 6px 22px
                                rgba(0,0,0,.06);
                        }


                        /* =====================================
                           HEADER
                           ===================================== */

                        .header {
                            width: 100%;

                            display: flex;

                            flex-direction: row;

                            align-items: center;

                            gap: 20px;

                            padding-bottom: 18px;

                            border-bottom:
                                3px solid #8d1f2d;
                        }


                        .logo {
                            width: 150px;

                            height: auto;

                            flex-shrink: 0;

                            object-fit: contain;
                        }


                        .company {
                            min-width: 0;

                            flex: 1;
                        }


                        .company h1 {
                            margin: 0;

                            color: #8d1f2d;

                            font-size: 24px;

                            font-weight: 700;
                        }


                        .company p {
                            margin:
                                4px 0 0;

                            color: #8490a3;

                            font-size: 12px;
                        }


                        /* =====================================
                           TITLE
                           ===================================== */

                        .title {
                            margin:
                                24px 0 18px;

                            text-align: center;
                        }


                        .title h2 {
                            margin: 0;

                            color: #172033;

                            font-size: 21px;

                            font-weight: 700;
                        }


                        .title p {
                            margin:
                                5px 0 0;

                            color: #8490a3;

                            font-size: 12px;
                        }


                        /* =====================================
                           META
                           ===================================== */

                        .meta {
                            width: 100%;

                            display: grid;

                            grid-template-columns:
                                repeat(
                                    3,
                                    minmax(0, 1fr)
                                );

                            gap: 10px;

                            margin-bottom: 18px;
                        }


                        .meta-box {
                            min-width: 0;

                            min-height: 58px;

                            padding:
                                10px 12px;

                            background: #fafafa;

                            border:
                                1px solid #e6e9ef;

                            border-radius: 8px;
                        }


                        .meta-label {
                            display: block;

                            margin-bottom: 3px;

                            color: #8490a3;

                            font-size: 9px;

                            font-weight: 700;

                            text-transform: uppercase;
                        }


                        .meta-value {
                            display: block;

                            color: #172033;

                            font-size: 11px;

                            font-weight: 700;

                            overflow-wrap: anywhere;
                        }


                        /* =====================================
                           TABLE WRAPPER
                           ===================================== */

                        .table-wrapper {
                            width: 100%;

                            max-width: 100%;

                            overflow: hidden;

                            border-radius: 5px;
                        }


                        /* =====================================
                           TABLE
                           ===================================== */

                        table {
                            width: 100%;

                            max-width: 100%;

                            border-collapse:
                                collapse;

                            table-layout:
                                fixed;
                        }


                        th {
                            padding:
                                9px 6px;

                            background: #8d1f2d;

                            border:
                                1px solid #701722;

                            color: #ffffff;

                            font-size: 9px;

                            font-weight: 700;

                            line-height: 1.35;

                            text-align: left;

                            vertical-align: middle;

                            overflow-wrap: anywhere;
                        }


                        td {
                            padding:
                                8px 6px;

                            border:
                                1px solid #dfe3e9;

                            color: #414b5c;

                            font-size: 9px;

                            line-height: 1.45;

                            vertical-align: top;

                            word-wrap:
                                break-word;

                            overflow-wrap:
                                anywhere;
                        }


                        tbody tr:nth-child(even) {
                            background: #fafafa;
                        }


                        .center {
                            text-align: center;
                        }


                        .staff {
                            font-weight: 700;

                            color: #222c3d;
                        }


                        /* =====================================
                           STATUS
                           ===================================== */

                        .approved {
                            color: #23724c;

                            font-weight: 700;
                        }


                        .rejected {
                            color: #a72d39;

                            font-weight: 700;
                        }


                        .pending {
                            color: #9a7118;

                            font-weight: 700;
                        }


                        /* =====================================
                           SUMMARY
                           ===================================== */

                        .summary {
                            margin-top: 15px;

                            padding-top: 12px;

                            border-top:
                                1px solid #e2e5e9;

                            color: #414b5c;

                            font-size: 10px;
                        }


                        .summary strong {
                            color: #172033;
                        }


                        /* =====================================
                           FOOTER
                           ===================================== */

                        .footer {
                            margin-top: 24px;

                            padding-top: 12px;

                            border-top:
                                1px solid #e2e5e9;

                            color: #8490a3;

                            font-size: 9px;

                            text-align: center;
                        }


                        /* =====================================
                           RESPONSIVE - SCREEN SAHAJA
                           ===================================== */

                        @media screen and (max-width: 800px) {

                            body {
                                padding: 12px;
                            }


                            .actions {
                                flex-wrap: wrap;
                            }


                            .actions-info {
                                width: 100%;

                                margin-right: 0;

                                margin-bottom: 3px;
                            }


                            .btn {
                                flex: 1;
                            }


                            .page {
                                padding: 18px;
                            }


                            .header {
                                gap: 14px;
                            }


                            .logo {
                                width: 110px;
                            }


                            .company h1 {
                                font-size: 20px;
                            }


                            .meta {
                                grid-template-columns: 1fr;
                            }
                        }


                        /* =====================================
                           PRINT SETTINGS
                           ===================================== */

                        @page {
                            size: A4 landscape;

                            margin: 8mm;
                        }


                        @media print {

                            /* =================================
                               DOCUMENT
                               ================================= */

                            html,
                            body {
                                width:
                                    100% !important;

                                max-width:
                                    none !important;

                                margin:
                                    0 !important;

                                padding:
                                    0 !important;

                                overflow:
                                    visible !important;

                                background:
                                    #ffffff !important;

                                color:
                                    #172033 !important;

                                font-family:
                                    "Segoe UI",
                                    Arial,
                                    sans-serif !important;

                                -webkit-print-color-adjust:
                                    exact !important;

                                print-color-adjust:
                                    exact !important;
                            }


                            /* =================================
                               HIDE ACTION BUTTONS
                               ================================= */

                            .top-actions-wrapper,
                            .actions {
                                display:
                                    none !important;
                            }


                            /* =================================
                               PAGE
                               KEKALKAN PADDING SEPERTI SCREEN
                               ================================= */

                            .page {
                                width:
                                    100% !important;

                                max-width:
                                    none !important;

                                margin:
                                    0 !important;

                                padding:
                                    30px !important;

                                background:
                                    #ffffff !important;

                                border:
                                    none !important;

                                border-radius:
                                    0 !important;

                                box-shadow:
                                    none !important;
                            }


                            /* =================================
                               HEADER
                               KEKALKAN LAYOUT ASAL
                               ================================= */

                            .header {
                                width:
                                    100% !important;

                                display:
                                    flex !important;

                                flex-direction:
                                    row !important;

                                align-items:
                                    center !important;

                                gap:
                                    20px !important;

                                padding-bottom:
                                    18px !important;

                                border-bottom:
                                    3px solid #8d1f2d !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            .logo {
                                width:
                                    150px !important;

                                height:
                                    auto !important;

                                flex:
                                    0 0 150px !important;

                                object-fit:
                                    contain !important;
                            }


                            .company {
                                min-width:
                                    0 !important;

                                flex:
                                    1 !important;
                            }


                            .company h1 {
                                margin:
                                    0 !important;

                                color:
                                    #8d1f2d !important;

                                font-size:
                                    24px !important;

                                font-weight:
                                    700 !important;
                            }


                            .company p {
                                margin:
                                    4px 0 0 !important;

                                color:
                                    #8490a3 !important;

                                font-size:
                                    12px !important;
                            }


                            /* =================================
                               TITLE
                               ================================= */

                            .title {
                                margin:
                                    24px 0 18px !important;

                                text-align:
                                    center !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            .title h2 {
                                margin:
                                    0 !important;

                                color:
                                    #172033 !important;

                                font-size:
                                    21px !important;

                                font-weight:
                                    700 !important;
                            }


                            .title p {
                                margin:
                                    5px 0 0 !important;

                                color:
                                    #8490a3 !important;

                                font-size:
                                    12px !important;
                            }


                            /* =================================
                               META
                               PAKSA 3 KOLUM
                               ================================= */

                            .meta {
                                width:
                                    100% !important;

                                display:
                                    grid !important;

                                grid-template-columns:
                                    repeat(
                                        3,
                                        minmax(0, 1fr)
                                    ) !important;

                                gap:
                                    10px !important;

                                margin-bottom:
                                    18px !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            .meta-box {
                                min-width:
                                    0 !important;

                                min-height:
                                    58px !important;

                                padding:
                                    10px 12px !important;

                                background:
                                    #fafafa !important;

                                border:
                                    1px solid #e6e9ef !important;

                                border-radius:
                                    8px !important;
                            }


                            .meta-label {
                                display:
                                    block !important;

                                margin-bottom:
                                    3px !important;

                                color:
                                    #8490a3 !important;

                                font-size:
                                    9px !important;

                                font-weight:
                                    700 !important;

                                text-transform:
                                    uppercase !important;
                            }


                            .meta-value {
                                display:
                                    block !important;

                                color:
                                    #172033 !important;

                                font-size:
                                    11px !important;

                                font-weight:
                                    700 !important;

                                overflow-wrap:
                                    anywhere !important;
                            }


                            /* =================================
                               TABLE WRAPPER
                               ================================= */

                            .table-wrapper {
                                width:
                                    100% !important;

                                max-width:
                                    100% !important;

                                overflow:
                                    visible !important;

                                border-radius:
                                    5px !important;
                            }


                            /* =================================
                               TABLE
                               ================================= */

                            table {
                                width:
                                    100% !important;

                                max-width:
                                    100% !important;

                                min-width:
                                    0 !important;

                                border-collapse:
                                    collapse !important;

                                table-layout:
                                    fixed !important;
                            }


                            th {
                                padding:
                                    9px 6px !important;

                                background:
                                    #8d1f2d !important;

                                border:
                                    1px solid #701722 !important;

                                color:
                                    #ffffff !important;

                                font-size:
                                    9px !important;

                                font-weight:
                                    700 !important;

                                line-height:
                                    1.35 !important;

                                text-align:
                                    left !important;

                                vertical-align:
                                    middle !important;

                                overflow-wrap:
                                    anywhere !important;
                            }


                            td {
                                padding:
                                    8px 6px !important;

                                border:
                                    1px solid #dfe3e9 !important;

                                color:
                                    #414b5c !important;

                                font-size:
                                    9px !important;

                                line-height:
                                    1.45 !important;

                                vertical-align:
                                    top !important;

                                word-wrap:
                                    break-word !important;

                                overflow-wrap:
                                    anywhere !important;
                            }


                            tbody tr:nth-child(even) {
                                background:
                                    #fafafa !important;
                            }


                            .center {
                                text-align:
                                    center !important;
                            }


                            .staff {
                                color:
                                    #222c3d !important;

                                font-weight:
                                    700 !important;
                            }


                            /* =================================
                               STATUS COLORS
                               ================================= */

                            .approved {
                                color:
                                    #23724c !important;

                                font-weight:
                                    700 !important;
                            }


                            .rejected {
                                color:
                                    #a72d39 !important;

                                font-weight:
                                    700 !important;
                            }


                            .pending {
                                color:
                                    #9a7118 !important;

                                font-weight:
                                    700 !important;
                            }


                            /* =================================
                               REPEAT TABLE HEADER
                               ================================= */

                            thead {
                                display:
                                    table-header-group !important;
                            }


                            tfoot {
                                display:
                                    table-footer-group !important;
                            }


                            /* =================================
                               JANGAN POTONG ROW
                               ================================= */

                            tr {
                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            /* =================================
                               SUMMARY
                               ================================= */

                            .summary {
                                margin-top:
                                    15px !important;

                                padding-top:
                                    12px !important;

                                border-top:
                                    1px solid #e2e5e9 !important;

                                color:
                                    #414b5c !important;

                                font-size:
                                    10px !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            .summary strong {
                                color:
                                    #172033 !important;
                            }


                            /* =================================
                               FOOTER
                               ================================= */

                            .footer {
                                margin-top:
                                    24px !important;

                                padding-top:
                                    12px !important;

                                border-top:
                                    1px solid #e2e5e9 !important;

                                color:
                                    #8490a3 !important;

                                font-size:
                                    9px !important;

                                text-align:
                                    center !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }
                        }

                    </style>

                </head>


                <body>


                <!-- ==========================================
                     TOP ACTION BAR
                     ========================================== -->

                <div class="top-actions-wrapper">

                    <div class="actions">


                        <div class="actions-info">

                            <strong>
                                Senarai Permohonan Inventori
                            </strong>

                            <span>
                                Cetak atau kembali ke Pengurusan Permohonan Inventori
                            </span>

                        </div>


                        <button
                            type="button"
                            class="btn btn-print"
                            onclick="window.print()"
                        >
                            Cetak Senarai
                        </button>
            """);


            out.println(
                "<a class=\"btn btn-back\" href=\""
                + request.getContextPath()
                + "/inventory-request-admin\">"
                + "Kembali"
                + "</a>"
            );


            out.println("""
                    </div>

                </div>


                <!-- ==========================================
                     PRINT DOCUMENT
                     ========================================== -->

                <div class="page">


                    <div class="header">
            """);


            // =================================================
            // LOGO
            // =================================================

            out.println(
                "<img class=\"logo\" src=\""
                + request.getContextPath()
                + "/images/logo-pkb.png\" "
                + "alt=\"Permodalan Kedah Berhad\">"
            );


            // =================================================
            // COMPANY
            // =================================================

            out.println("""
                        <div class="company">

                            <h1>
                                Permodalan Kedah Berhad
                            </h1>

                            <p>
                                PKB Staff Management System
                            </p>

                        </div>

                    </div>


                    <!-- ======================================
                         TITLE
                         ====================================== -->

                    <div class="title">

                        <h2>
                            Senarai Permohonan Inventori
                        </h2>

                        <p>
                            Rekod permohonan inventori staf
                        </p>

                    </div>


                    <!-- ======================================
                         META
                         ====================================== -->

                    <div class="meta">
            """);


            out.println(
                metaBox(
                    "Dicetak Oleh",
                    printedBy
                )
            );


            out.println(
                metaBox(
                    "Peranan",
                    "Pentadbir Sistem"
                )
            );


            out.println(
                metaBox(
                    "Tarikh Cetakan",
                    printedDate
                )
            );


            out.println("""
                    </div>


                    <!-- ======================================
                         TABLE
                         ====================================== -->

                    <div class="table-wrapper">

                    <table>

                        <thead>

                            <tr>

                                <th style="width:4%;">
                                    Bil.
                                </th>

                                <th style="width:12%;">
                                    Nama Staf
                                </th>

                                <th style="width:11%;">
                                    Kod / Inventori
                                </th>

                                <th style="width:7%;">
                                    Kuantiti
                                </th>

                                <th style="width:17%;">
                                    Tujuan
                                </th>

                                <th style="width:11%;">
                                    Tarikh Mohon
                                </th>

                                <th style="width:10%;">
                                    Status
                                </th>

                                <th style="width:14%;">
                                    Catatan
                                </th>

                                <th style="width:14%;">
                                    Disemak Oleh
                                </th>

                            </tr>

                        </thead>


                        <tbody>
            """);


            // =================================================
            // COUNTERS
            // =================================================

            int count = 0;

            int pending = 0;

            int approved = 0;

            int rejected = 0;


            // =================================================
            // DATA
            // =================================================

            while (rs.next()) {

                count++;


                String staffName =
                        safe(
                            rs.getString(
                                "staff_name"
                            )
                        );


                String itemCode =
                        safe(
                            rs.getString(
                                "item_code"
                            )
                        );


                String itemName =
                        safe(
                            rs.getString(
                                "item_name"
                            )
                        );


                int quantity =
                        rs.getInt(
                            "quantity"
                        );


                String purpose =
                        safe(
                            rs.getString(
                                "purpose"
                            )
                        );


                String remarks =
                        safe(
                            rs.getString(
                                "remarks"
                            )
                        );


                String reviewer =
                        safe(
                            rs.getString(
                                "reviewer_name"
                            )
                        );


                String status =
                        normalize(
                            rs.getString(
                                "status"
                            )
                        );


                // =============================================
                // COUNT STATUS
                // =============================================

                if ("APPROVED".equals(status)) {

                    approved++;

                } else if (
                    "REJECTED".equals(status)
                ) {

                    rejected++;

                } else {

                    pending++;
                }


                String statusLabel =
                        requestStatusLabel(
                            status
                        );


                String statusClass =
                        requestStatusClass(
                            status
                        );


                // =============================================
                // REQUEST DATE
                // =============================================

                String requestedAt =
                        rs.getTimestamp(
                            "requested_at"
                        ) == null
                            ? "—"
                            : rs
                                .getTimestamp(
                                    "requested_at"
                                )
                                .toLocalDateTime()
                                .format(
                                    DateTimeFormatter
                                        .ofPattern(
                                            "dd/MM/yyyy HH:mm"
                                        )
                                );


                // =============================================
                // REVIEW DATE
                // =============================================

                String reviewedAt =
                        rs.getTimestamp(
                            "reviewed_at"
                        ) == null
                            ? ""
                            : rs
                                .getTimestamp(
                                    "reviewed_at"
                                )
                                .toLocalDateTime()
                                .format(
                                    DateTimeFormatter
                                        .ofPattern(
                                            "dd/MM/yyyy HH:mm"
                                        )
                                );


                // =============================================
                // REVIEWER TEXT
                // =============================================

                String reviewerText;


                if (reviewer.isBlank()) {

                    reviewerText =
                            "—";

                } else {

                    reviewerText =
                            escape(reviewer);


                    if (!reviewedAt.isBlank()) {

                        reviewerText +=
                                "<br>"
                                + escape(reviewedAt);
                    }
                }


                // =============================================
                // TABLE ROW
                // =============================================

                out.println("<tr>");


                // BIL

                out.println(
                    "<td class=\"center\">"
                    + count
                    + "</td>"
                );


                // NAMA STAFF

                out.println(
                    "<td class=\"staff\">"
                    + escape(staffName)
                    + "</td>"
                );


                // ITEM

                out.println(
                    "<td>"
                    + escape(itemCode)
                    + "<br>"
                    + escape(itemName)
                    + "</td>"
                );


                // KUANTITI

                out.println(
                    "<td class=\"center\">"
                    + quantity
                    + "</td>"
                );


                // TUJUAN

                out.println(
                    "<td>"
                    + escape(
                        purpose.isBlank()
                            ? "—"
                            : purpose
                    )
                    + "</td>"
                );


                // TARIKH MOHON

                out.println(
                    "<td>"
                    + escape(requestedAt)
                    + "</td>"
                );


                // STATUS

                out.println(
                    "<td class=\""
                    + statusClass
                    + "\">"
                    + escape(statusLabel)
                    + "</td>"
                );


                // CATATAN

                out.println(
                    "<td>"
                    + escape(
                        remarks.isBlank()
                            ? "—"
                            : remarks
                    )
                    + "</td>"
                );


                // DISEMAK OLEH

                out.println(
                    "<td>"
                    + reviewerText
                    + "</td>"
                );


                out.println("</tr>");
            }


            // =================================================
            // EMPTY DATA
            // =================================================

            if (count == 0) {

                out.println("""
                    <tr>

                        <td
                            colspan="9"
                            style="
                                text-align:center;
                                padding:25px;
                            "
                        >
                            Tiada rekod permohonan inventori.
                        </td>

                    </tr>
                """);
            }


            out.println("""
                        </tbody>

                    </table>

                    </div>
            """);


            // =================================================
            // SUMMARY
            // =================================================

            out.println(
                "<div class=\"summary\">"
                +
                "<strong>Jumlah:</strong> "
                + count
                +
                " &nbsp;&nbsp; | &nbsp;&nbsp; "
                +
                "<strong>Menunggu:</strong> "
                + pending
                +
                " &nbsp;&nbsp; | &nbsp;&nbsp; "
                +
                "<strong>Diluluskan:</strong> "
                + approved
                +
                " &nbsp;&nbsp; | &nbsp;&nbsp; "
                +
                "<strong>Ditolak:</strong> "
                + rejected
                +
                "</div>"
            );


            // =================================================
            // FOOTER
            // =================================================

            out.println("""
                    <div class="footer">
                        Dokumen ini dijana oleh PKB Staff Management System.
                    </div>

                </div>

                </body>

                </html>
            """);


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menyediakan senarai permohonan inventori untuk cetakan.",
                e
            );
        }
    }


    // =========================================================
    // HELPERS
    // =========================================================

    private String safe(
            String value) {

        return value == null
                ? ""
                : value.trim();
    }


    private String normalize(
            String value) {

        return value == null
                ? ""
                : value
                    .trim()
                    .toUpperCase();
    }


    private String escape(
            String value) {

        if (value == null) {
            return "";
        }


        return value
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    }


    // =========================================================
    // REQUEST STATUS LABEL
    // =========================================================

    private String requestStatusLabel(
            String status) {

        switch (status) {

            case "APPROVED":
                return "Diluluskan";

            case "REJECTED":
                return "Ditolak";

            case "PENDING":
                return "Menunggu";

            default:
                return status;
        }
    }


    // =========================================================
    // REQUEST STATUS CLASS
    // =========================================================

    private String requestStatusClass(
            String status) {

        switch (status) {

            case "APPROVED":
                return "approved";

            case "REJECTED":
                return "rejected";

            default:
                return "pending";
        }
    }


    // =========================================================
    // META BOX
    // =========================================================

    private String metaBox(
            String label,
            String value) {

        return
            "<div class=\"meta-box\">"
            +
            "<span class=\"meta-label\">"
            + escape(label)
            + "</span>"
            +
            "<span class=\"meta-value\">"
            + escape(value)
            + "</span>"
            +
            "</div>";
    }
}