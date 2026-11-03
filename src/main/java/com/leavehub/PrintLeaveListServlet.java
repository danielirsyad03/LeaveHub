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


@WebServlet("/print-leave-list")
public class PrintLeaveListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {


        // =====================================================
        // SESSION
        // =====================================================

        HttpSession session =
                req.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        int currentUserId;


        try {

            currentUserId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );

        } catch (Exception e) {

            session.invalidate();

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        String role =
                session.getAttribute("userRole") == null
                    ? ""
                    : session
                        .getAttribute("userRole")
                        .toString()
                        .trim()
                        .toUpperCase();


        String currentUserName =
                session.getAttribute("userName") == null
                    ? "Pengguna"
                    : session
                        .getAttribute("userName")
                        .toString()
                        .trim();


        if (currentUserName.isBlank()) {
            currentUserName = "Pengguna";
        }


        // =====================================================
        // ACCESS CONTROL
        //
        // HR          -> semua permohonan
        // MANAGEMENT  -> semua permohonan
        // HOD         -> staf di bawah seliaan sahaja
        // STAFF       -> tidak dibenarkan
        // =====================================================

        boolean isHR =
                "HR".equals(role);


        boolean isHOD =
                "HOD".equals(role);


        boolean isManagement =
                "MANAGEMENT".equals(role);


        if (
            !isHR
            &&
            !isHOD
            &&
            !isManagement
        ) {

            resp.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mencetak senarai permohonan cuti."
            );

            return;
        }


        // =====================================================
        // SQL ASAS
        // =====================================================

        String baseSql =
                """

                SELECT

                    l.id,
                    l.application_no,
                    l.start_date,
                    l.end_date,
                    l.duration,
                    l.status,
                    l.reason,

                    COALESCE(
                        lt.leave_type_name,
                        l.leave_type
                    ) AS leave_type_name,

                    l.other_leave_type,

                    u.name AS staff_name,
                    u.position,
                    u.department,

                    h.name AS hod_name,

                    ha.decision AS hod_decision,

                    ma.decision AS management_decision,
                    mu.name AS management_name

                FROM leave_applications l

                JOIN users u
                    ON l.user_id = u.id

                LEFT JOIN leave_types lt
                    ON l.leave_type_id = lt.leave_type_id

                LEFT JOIN users h
                    ON u.hod_id = h.id

                LEFT JOIN leave_approvals ha
                    ON ha.approval_id = (

                        SELECT MAX(ha2.approval_id)

                        FROM leave_approvals ha2

                        WHERE ha2.leave_id = l.id

                        AND ha2.approval_level = 'HEAD_OF_UNIT'
                    )

                LEFT JOIN leave_approvals ma
                    ON ma.approval_id = (

                        SELECT MAX(ma2.approval_id)

                        FROM leave_approvals ma2

                        WHERE ma2.leave_id = l.id

                        AND ma2.approval_level = 'MANAGEMENT'
                    )

                LEFT JOIN users mu
                    ON ma.approver_id = mu.id

                """;


        // =====================================================
        // ROLE BASED SQL
        // =====================================================

        String sql;


        if (isHOD) {

            sql =
                    baseSql
                    +
                    """

                    WHERE u.hod_id = ?

                    ORDER BY
                        l.submitted_at DESC

                    """;

        } else {

            sql =
                    baseSql
                    +
                    """

                    ORDER BY
                        l.submitted_at DESC

                    """;
        }


        // =====================================================
        // RESPONSE
        // =====================================================

        resp.setContentType(
            "text/html;charset=UTF-8"
        );

        resp.setCharacterEncoding(
            "UTF-8"
        );


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            PrintWriter out =
                    resp.getWriter()
        ) {


            // =================================================
            // HOD PARAMETER
            // =================================================

            if (isHOD) {

                ps.setInt(
                    1,
                    currentUserId
                );
            }


            // =================================================
            // HTML START
            // =================================================

            out.println(
                """

                <!DOCTYPE html>

                <html lang="ms">

                <head>

                    <meta charset="UTF-8">

                    <meta
                        name="viewport"
                        content="width=device-width, initial-scale=1.0"
                    >

                    <title>
                        Senarai Permohonan Cuti
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

                            margin: 0;
                            padding: 0;

                            overflow-x: hidden;
                        }


                        body {
                            padding: 24px;

                            background: #f4f5f7;

                            color: #202938;

                            font-family:
                                "Segoe UI",
                                Arial,
                                sans-serif;

                            font-size: 14px;
                        }


                        /* =====================================
                           TOP ACTION BAR
                           ===================================== */

                        .top-actions-wrapper {
                            width: 100%;

                            max-width: 1450px;

                            margin:
                                0 auto 14px;
                        }


                        .top-actions {
                            width: 100%;

                            display: flex;

                            align-items: center;

                            justify-content: flex-end;

                            gap: 10px;

                            padding:
                                12px 14px;

                            background: #ffffff;

                            border:
                                1px solid #e1e4e8;

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

                            font-size: 14px;

                            font-weight: 700;
                        }


                        .actions-info span {
                            display: block;

                            margin-top: 3px;

                            color: #7d8796;

                            font-size: 11px;
                        }


                        /* =====================================
                           BUTTONS
                           ===================================== */

                        .btn {
                            min-height: 40px;

                            display: inline-flex;

                            align-items: center;

                            justify-content: center;

                            padding:
                                0 18px;

                            border-radius: 8px;

                            font-family: inherit;

                            font-size: 12px;

                            font-weight: 700;

                            line-height: 1;

                            text-decoration: none;

                            white-space: nowrap;

                            cursor: pointer;

                            transition:
                                all .15s ease;
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
                                rgba(141,31,45,.14);
                        }


                        .btn-print:hover {
                            background: #701722;

                            border-color: #701722;
                        }


                        .btn-back {
                            background: #ffffff;

                            border:
                                1px solid #d8dde4;

                            color: #515c6d;
                        }


                        .btn-back:hover {
                            background: #f6f7fa;

                            border-color: #c9ced6;
                        }


                        /* =====================================
                           PRINT PAGE
                           ===================================== */

                        .print-page {
                            width: 100%;

                            max-width: 1450px;

                            margin: auto;

                            padding: 30px;

                            background: #ffffff;

                            border:
                                1px solid #e1e4e8;

                            border-radius: 14px;

                            box-shadow:
                                0 5px 20px
                                rgba(0,0,0,.06);
                        }


                        /* =====================================
                           HEADER
                           ===================================== */

                        .header {
                            display: flex;

                            align-items: center;

                            gap: 20px;

                            padding-bottom: 20px;

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
                            flex: 1;

                            min-width: 0;
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

                            color: #70798a;

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

                            color: #7d8796;

                            font-size: 12px;
                        }


                        /* =====================================
                           META
                           ===================================== */

                        .meta {
                            display: grid;

                            grid-template-columns:
                                repeat(3, minmax(0, 1fr));

                            gap: 10px;

                            margin-bottom: 18px;
                        }


                        .meta-box {
                            min-width: 0;

                            padding:
                                10px 12px;

                            background: #fafafa;

                            border:
                                1px solid #e4e6ea;

                            border-radius: 7px;
                        }


                        .meta-label {
                            display: block;

                            margin-bottom: 4px;

                            color: #8a93a2;

                            font-size: 9px;

                            font-weight: 700;

                            text-transform: uppercase;
                        }


                        .meta-value {
                            color: #30394a;

                            font-size: 11px;

                            font-weight: 600;

                            overflow-wrap: anywhere;
                        }


                        /* =====================================
                           TABLE
                           ===================================== */

                        .table-wrapper {
                            width: 100%;

                            max-width: 100%;

                            overflow: hidden;

                            border-radius: 5px;
                        }


                        table {
                            width: 100%;

                            max-width: 100%;

                            border-collapse: collapse;

                            table-layout: fixed;
                        }


                        th {
                            padding:
                                9px 6px;

                            background: #8d1f2d;

                            border:
                                1px solid #7a1926;

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
                                1px solid #dfe2e7;

                            color: #424c5d;

                            font-size: 9px;

                            line-height: 1.4;

                            vertical-align: top;

                            word-wrap: break-word;

                            overflow-wrap: anywhere;
                        }


                        tbody tr:nth-child(even) {
                            background: #fafafa;
                        }


                        tbody tr:hover {
                            background: #fffafa;
                        }


                        .number {
                            text-align: center;
                        }


                        /* =====================================
                           STATUS
                           ===================================== */

                        .status {
                            font-weight: 700;
                        }


                        .approved {
                            color: #23724c;
                        }


                        .rejected {
                            color: #a72d39;
                        }


                        .pending {
                            color: #9a7118;
                        }


                        .cancelled {
                            color: #6d7581;
                        }


                        /* =====================================
                           EMPTY
                           ===================================== */

                        .empty-state {
                            padding:
                                25px !important;

                            color: #7d8796;

                            text-align: center;
                        }


                        /* =====================================
                           SUMMARY
                           ===================================== */

                        .summary {
                            margin-top: 15px;

                            padding-top: 12px;

                            border-top:
                                1px solid #dddddd;

                            color: #4b5668;

                            font-size: 10px;
                        }


                        .summary strong {
                            color: #172033;
                        }


                        /* =====================================
                           FOOTER
                           ===================================== */

                        .footer {
                            margin-top: 25px;

                            padding-top: 12px;

                            border-top:
                                1px solid #dddddd;

                            color: #8a929f;

                            font-size: 9px;

                            text-align: center;
                        }


                        /* =====================================
                           RESPONSIVE SCREEN ONLY
                           ===================================== */

                        @media screen and (max-width: 900px) {

                            body {
                                padding: 12px;
                            }


                            .print-page {
                                padding: 18px;
                            }


                            .top-actions {
                                flex-wrap: wrap;
                            }


                            .actions-info {
                                width: 100%;

                                margin-right: 0;
                            }


                            .logo {
                                width: 110px;
                            }


                            .company h1 {
                                font-size: 19px;
                            }


                            .meta {
                                grid-template-columns: 1fr;
                            }


                            th {
                                font-size: 8px;

                                padding:
                                    7px 4px;
                            }


                            td {
                                font-size: 8px;

                                padding:
                                    7px 4px;
                            }
                        }


                        /* =====================================
                           PRINT
                           KEKALKAN LAYOUT DESKTOP
                           ===================================== */

                        @page {
                            size: A4 landscape;
                            margin: 8mm;
                        }


                        @media print {

                            html,
                            body {
                                width: 100% !important;
                                max-width: none !important;

                                margin: 0 !important;
                                padding: 0 !important;

                                overflow: visible !important;

                                background: #ffffff !important;

                                color: #202938 !important;

                                font-family:
                                    "Segoe UI",
                                    Arial,
                                    sans-serif !important;

                                font-size: 14px !important;

                                -webkit-print-color-adjust:
                                    exact !important;

                                print-color-adjust:
                                    exact !important;
                            }


                            /* HIDE BUTTON AREA */

                            .top-actions-wrapper {
                                display: none !important;
                            }


                            /* DOCUMENT */

                            .print-page {
                                width: 100% !important;

                                max-width: none !important;

                                margin: 0 !important;

                                padding: 30px !important;

                                background: #ffffff !important;

                                border: none !important;

                                border-radius: 0 !important;

                                box-shadow: none !important;
                            }


                            /* HEADER */

                            .header {
                                display: flex !important;

                                flex-direction:
                                    row !important;

                                align-items:
                                    center !important;

                                gap: 20px !important;

                                padding-bottom:
                                    20px !important;

                                border-bottom:
                                    3px solid #8d1f2d !important;

                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            .logo {
                                width: 150px !important;

                                height: auto !important;

                                flex-shrink:
                                    0 !important;

                                object-fit:
                                    contain !important;
                            }


                            .company {
                                flex: 1 !important;

                                min-width: 0 !important;
                            }


                            .company h1 {
                                margin: 0 !important;

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
                                    #70798a !important;

                                font-size:
                                    12px !important;
                            }


                            /* TITLE */

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
                                margin: 0 !important;

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
                                    #7d8796 !important;

                                font-size:
                                    12px !important;
                            }


                            /* META - FORCE 3 COLUMNS */

                            .meta {
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

                                padding:
                                    10px 12px !important;

                                background:
                                    #fafafa !important;

                                border:
                                    1px solid #e4e6ea !important;

                                border-radius:
                                    7px !important;
                            }


                            .meta-label {
                                display:
                                    block !important;

                                margin-bottom:
                                    4px !important;

                                color:
                                    #8a93a2 !important;

                                font-size:
                                    9px !important;

                                font-weight:
                                    700 !important;

                                text-transform:
                                    uppercase !important;
                            }


                            .meta-value {
                                color:
                                    #30394a !important;

                                font-size:
                                    11px !important;

                                font-weight:
                                    600 !important;

                                overflow-wrap:
                                    anywhere !important;
                            }


                            /* TABLE */

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
                                    1px solid #7a1926 !important;

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

                                word-wrap:
                                    break-word !important;

                                overflow-wrap:
                                    anywhere !important;
                            }


                            td {
                                padding:
                                    8px 6px !important;

                                border:
                                    1px solid #dfe2e7 !important;

                                color:
                                    #424c5d !important;

                                font-size:
                                    9px !important;

                                line-height:
                                    1.4 !important;

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


                            tbody tr:hover {
                                background:
                                    inherit !important;
                            }


                            .number {
                                text-align:
                                    center !important;
                            }


                            /* STATUS */

                            .status {
                                font-weight:
                                    700 !important;
                            }


                            .approved {
                                color:
                                    #23724c !important;
                            }


                            .rejected {
                                color:
                                    #a72d39 !important;
                            }


                            .pending {
                                color:
                                    #9a7118 !important;
                            }


                            .cancelled {
                                color:
                                    #6d7581 !important;
                            }


                            /* EMPTY */

                            .empty-state {
                                padding:
                                    25px !important;

                                color:
                                    #7d8796 !important;

                                text-align:
                                    center !important;
                            }


                            /* REPEAT HEADER */

                            thead {
                                display:
                                    table-header-group !important;
                            }


                            tfoot {
                                display:
                                    table-footer-group !important;
                            }


                            /* DON'T SPLIT ROW */

                            tr {
                                page-break-inside:
                                    avoid !important;

                                break-inside:
                                    avoid !important;
                            }


                            /* SUMMARY */

                            .summary {
                                margin-top:
                                    15px !important;

                                padding-top:
                                    12px !important;

                                border-top:
                                    1px solid #dddddd !important;

                                color:
                                    #4b5668 !important;

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


                            /* FOOTER */

                            .footer {
                                margin-top:
                                    25px !important;

                                padding-top:
                                    12px !important;

                                border-top:
                                    1px solid #dddddd !important;

                                color:
                                    #8a929f !important;

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


                <!-- =========================================
                     TOP ACTION BAR
                     ========================================= -->

                <div class="top-actions-wrapper">

                    <div class="top-actions">


                        <div class="actions-info">

                            <strong>
                                Senarai Permohonan Cuti
                            </strong>

                            <span>
                                Cetak senarai permohonan cuti atau kembali ke halaman sebelumnya
                            </span>

                        </div>


                        <button
                            type="button"
                            class="btn btn-print"
                            onclick="window.print()"
                        >
                            Cetak Senarai
                        </button>

                """
            );


            // =================================================
            // BACK BUTTON
            // =================================================

            String backUrl;


            if (isHOD) {

                backUrl =
                        req.getContextPath()
                        + "/hod-staff";

            } else {

                backUrl =
                        req.getContextPath()
                        + "/admin";
            }


            out.println(
                "<a "
                +
                "class=\"btn btn-back\" "
                +
                "href=\""
                + backUrl
                + "\""
                +
                ">"
                +
                "Kembali"
                +
                "</a>"
            );


            out.println(
                """

                    </div>

                </div>


                <!-- =========================================
                     DOCUMENT
                     ========================================= -->

                <div class="print-page">

                """
            );


            // =================================================
            // HEADER
            // =================================================

            out.println(
                "<div class=\"header\">"
            );


            out.println(
                "<img class=\"logo\" src=\""
                + req.getContextPath()
                + "/images/logo-pkb.png\" "
                + "alt=\"PKB\">"
            );


            out.println(
                """

                <div class="company">

                    <h1>
                        Permodalan Kedah Berhad
                    </h1>

                    <p>
                        PKB Staff Management System
                    </p>

                </div>

                """
            );


            out.println(
                "</div>"
            );


            // =================================================
            // TITLE
            // =================================================

            String printTitle;


            if (isHOD) {

                printTitle =
                        "Senarai Permohonan Cuti Staf Di Bawah Seliaan";

            } else {

                printTitle =
                        "Senarai Permohonan Cuti Staf";
            }


            out.println(
                "<div class=\"title\">"
                +
                "<h2>"
                + escape(printTitle)
                + "</h2>"
                +
                "<p>"
                + "Rekod permohonan cuti Permodalan Kedah Berhad"
                + "</p>"
                +
                "</div>"
            );


            // =================================================
            // META
            // =================================================

            String printedDate =
                    LocalDateTime.now()
                        .format(
                            DateTimeFormatter.ofPattern(
                                "dd/MM/yyyy HH:mm"
                            )
                        );


            String roleLabel;


            if (isManagement) {

                roleLabel =
                        "Pengurusan";

            } else if (isHOD) {

                roleLabel =
                        "Ketua Unit";

            } else {

                roleLabel =
                        "Pentadbir Sistem";
            }


            out.println(
                "<div class=\"meta\">"
            );


            out.println(
                metaBox(
                    "Dicetak Oleh",
                    currentUserName
                )
            );


            out.println(
                metaBox(
                    "Peranan",
                    roleLabel
                )
            );


            out.println(
                metaBox(
                    "Tarikh Cetakan",
                    printedDate
                )
            );


            out.println(
                "</div>"
            );


            // =================================================
            // TABLE START
            // =================================================

            out.println(
                """

                <div class="table-wrapper">

                <table>

                    <thead>

                        <tr>

                            <th style="width:3%;">
                                Bil.
                            </th>

                            <th style="width:9%;">
                                No. Permohonan
                            </th>

                            <th style="width:11%;">
                                Nama Staf
                            </th>

                            <th style="width:10%;">
                                Jabatan
                            </th>

                            <th style="width:9%;">
                                Jenis Cuti
                            </th>

                            <th style="width:10%;">
                                Tarikh
                            </th>

                            <th style="width:5%;">
                                Hari
                            </th>

                            <th style="width:9%;">
                                Ketua Unit
                            </th>

                            <th style="width:10%;">
                                Sokongan KU
                            </th>

                            <th style="width:10%;">
                                Pengurusan
                            </th>

                            <th style="width:8%;">
                                Status
                            </th>

                        </tr>

                    </thead>

                    <tbody>

                """
            );


            int count = 0;


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                while (
                    rs.next()
                ) {

                    count++;


                    String applicationNo =
                            safe(
                                rs.getString(
                                    "application_no"
                                )
                            );


                    String staffName =
                            safe(
                                rs.getString(
                                    "staff_name"
                                )
                            );


                    String department =
                            departmentName(
                                rs.getString(
                                    "department"
                                )
                            );


                    String leaveType =
                            safe(
                                rs.getString(
                                    "leave_type_name"
                                )
                            );


                    String otherLeaveType =
                            safe(
                                rs.getString(
                                    "other_leave_type"
                                )
                            );


                    if (
                        "Lain-lain".equalsIgnoreCase(
                            leaveType
                        )
                        &&
                        !otherLeaveType.isBlank()
                    ) {

                        leaveType =
                                "Lain-lain - "
                                + otherLeaveType;
                    }


                    String dateText =
                            formatDate(
                                rs.getDate(
                                    "start_date"
                                )
                            )
                            +
                            " hingga "
                            +
                            formatDate(
                                rs.getDate(
                                    "end_date"
                                )
                            );


                    int duration =
                            rs.getInt(
                                "duration"
                            );


                    String hodName =
                            safe(
                                rs.getString(
                                    "hod_name"
                                )
                            );


                    if (
                        hodName.isBlank()
                    ) {

                        hodName = "-";
                    }


                    String hodDecision =
                            normalize(
                                rs.getString(
                                    "hod_decision"
                                )
                            );


                    String managementDecision =
                            normalize(
                                rs.getString(
                                    "management_decision"
                                )
                            );


                    String managementName =
                            safe(
                                rs.getString(
                                    "management_name"
                                )
                            );


                    String status =
                            normalize(
                                rs.getString(
                                    "status"
                                )
                            );


                    String statusLabel =
                            statusLabel(
                                status
                            );


                    String statusClass =
                            statusClass(
                                status
                            );


                    String managementText =
                            managementDecisionLabel(
                                managementDecision
                            );


                    if (
                        !managementName.isBlank()
                        &&
                        (
                            "APPROVED".equals(
                                managementDecision
                            )
                            ||
                            "REJECTED".equals(
                                managementDecision
                            )
                        )
                    ) {

                        managementText +=
                                " - "
                                + managementName;
                    }


                    // =========================================
                    // ROW
                    // =========================================

                    out.println(
                        "<tr>"
                    );


                    out.println(
                        "<td class=\"number\">"
                        + count
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(applicationNo)
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(staffName)
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(department)
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(leaveType)
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(dateText)
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"number\">"
                        + duration
                        + "</td>"
                    );


                    out.println(
                        "<td>"
                        + escape(hodName)
                        + "</td>"
                    );


                    out.println(
                    	    "<td>"
                    	    + escape(
                    	        "-".equals(hodName)
                    	            ? "-"
                    	            : hodDecisionLabel(
                    	                hodDecision
                    	            )
                    	    )
                    	    + "</td>"
                    	);


                    out.println(
                        "<td>"
                        + escape(
                            managementText
                        )
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"status "
                        + statusClass
                        + "\">"
                        + escape(statusLabel)
                        + "</td>"
                    );


                    out.println(
                        "</tr>"
                    );
                }
            }


            // =================================================
            // EMPTY STATE
            // =================================================

            if (
                count == 0
            ) {

                out.println(
                    """

                    <tr>

                        <td
                            colspan="11"
                            class="empty-state"
                        >

                            Tiada rekod permohonan cuti.

                        </td>

                    </tr>

                    """
                );
            }


            out.println(
                """

                    </tbody>

                </table>

                </div>

                """
            );


            // =================================================
            // SUMMARY
            // =================================================

            out.println(
                "<div class=\"summary\">"
                +
                "<strong>Jumlah Rekod:</strong> "
                + count
                + " permohonan"
                +
                "</div>"
            );


            // =================================================
            // FOOTER
            // =================================================

            out.println(
                """

                <div class="footer">

                    Dokumen ini dijana oleh
                    PKB Staff Management System.

                </div>

                """
            );


            // =================================================
            // CLOSE DOCUMENT + HTML
            // =================================================

            out.println(
                """

                </div>


                </body>

                </html>

                """
            );


            // =================================================
            // AUDIT TRAIL
            // =================================================

            String auditDescription;


            if (isHOD) {

                auditDescription =
                        "Mencetak senarai permohonan cuti staf di bawah seliaan"
                        + " ("
                        + count
                        + " rekod)";

            } else {

                auditDescription =
                        "Mencetak senarai permohonan cuti staf"
                        + " ("
                        + count
                        + " rekod)";
            }


            try {

                ActivityLogUtil.log(
                    req,
                    "PRINT_LEAVE_LIST",
                    auditDescription,
                    "LEAVE_LIST",
                    null
                );

            } catch (
                SQLException auditException
            ) {

                auditException.printStackTrace();
            }


        } catch (
            SQLException e
        ) {

            throw new ServletException(
                "Tidak dapat menyediakan senarai permohonan cuti untuk cetakan.",
                e
            );
        }
    }


    // =========================================================
    // NORMALIZE
    // =========================================================

    private String normalize(
            String value) {


        if (
            value == null
        ) {

            return "";
        }


        return value
            .trim()
            .toUpperCase();
    }


    // =========================================================
    // SAFE STRING
    // =========================================================

    private String safe(
            String value) {


        return value == null
            ? ""
            : value.trim();
    }


    // =========================================================
    // HTML ESCAPE
    // =========================================================

    private String escape(
            String value) {


        if (
            value == null
        ) {

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
    // DATE FORMAT
    // =========================================================

    private String formatDate(
            java.sql.Date date) {


        if (
            date == null
        ) {

            return "-";
        }


        return date
            .toLocalDate()
            .format(
                DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy"
                )
            );
    }


    // =========================================================
    // DEPARTMENT LABEL
    // =========================================================

    private String departmentName(
            String department) {


        if (
            department == null
            ||
            department.isBlank()
        ) {

            return "-";
        }


        switch (
            department
                .trim()
                .toUpperCase()
        ) {


            case "PENTADBIRAN_KORPORAT":

                return
                    "Pentadbiran dan Korporat";


            case "KEWANGAN":

                return
                    "Kewangan";


            case "PEMBANGUNAN_PERNIAGAAN_OPERASI":

                return
                    "Pembangunan Perniagaan dan Operasi";


            default:

                return department;
        }
    }


    // =========================================================
    // APPLICATION STATUS LABEL
    // =========================================================

    private String statusLabel(
            String status) {


        switch (
            status
        ) {


            case "PENDING_MANAGEMENT":
            case "PENDING_HEAD":
            case "PENDING_ADMIN":
            case "PENDING":

                return
                    "Menunggu Pengurusan";


            case "APPROVED":

                return
                    "Diluluskan";


            case "REJECTED":

                return
                    "Tidak Diluluskan";


            case "CANCELLED":

                return
                    "Dibatalkan";


            default:

                return status;
        }
    }


    // =========================================================
    // STATUS CSS
    // =========================================================

    private String statusClass(
            String status) {


        switch (
            status
        ) {


            case "APPROVED":

                return
                    "approved";


            case "REJECTED":

                return
                    "rejected";


            case "CANCELLED":

                return
                    "cancelled";


            default:

                return
                    "pending";
        }
    }


    // =========================================================
    // HOD DECISION
    // =========================================================

    private String hodDecisionLabel(
            String decision) {


        switch (
            decision
        ) {


            case "SUPPORTED":

                return
                    "Disokong";


            case "NOT_SUPPORTED":

                return
                    "Tidak Disokong";


            case "PENDING":
            case "":

                return
                    "Belum Disemak";


            default:

                return decision;
        }
    }


    // =========================================================
    // MANAGEMENT DECISION
    // =========================================================

    private String managementDecisionLabel(
            String decision) {


        switch (
            decision
        ) {


            case "APPROVED":

                return
                    "Diluluskan";


            case "REJECTED":

                return
                    "Tidak Diluluskan";


            case "PENDING":
            case "":

                return
                    "Menunggu Keputusan";


            default:

                return decision;
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