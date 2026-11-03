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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/print-staff-list")
public class PrintStaffListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // SESSION
        // =====================================================

        HttpSession session =
                request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        int userId;


        try {

            userId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );

        } catch (Exception e) {

            response.sendRedirect(
                request.getContextPath() + "/"
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


        String userName =
                session.getAttribute("userName") == null
                    ? "Pengguna"
                    : session
                        .getAttribute("userName")
                        .toString()
                        .trim();


        if (userName.isBlank()) {
            userName = "Pengguna";
        }


        boolean isHR =
                "HR".equals(role);


        boolean isHOD =
                "HOD".equals(role);


        // =====================================================
        // HR / HOD ONLY
        // =====================================================

        if (
            !isHR
            &&
            !isHOD
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mencetak senarai staf."
            );

            return;
        }


        // =====================================================
        // LOAD STAFF
        // =====================================================

        List<Map<String, Object>> staff =
                new ArrayList<>();


        String sql;


        if (isHR) {

            sql =
                """

                SELECT
                    u.name,
                    u.position,
                    u.email,
                    u.role,
                    u.department,
                    h.name AS hod_name

                FROM users u

                LEFT JOIN users h
                    ON u.hod_id = h.id

                ORDER BY

                    CASE u.role

                        WHEN 'HR'
                            THEN 1

                        WHEN 'MANAGEMENT'
                            THEN 2

                        WHEN 'HOD'
                            THEN 3

                        WHEN 'STAFF'
                            THEN 4

                        ELSE 5

                    END,

                    u.name ASC

                """;

        } else {

            sql =
                """

                SELECT
                    u.name,
                    u.position,
                    u.email,
                    u.role,
                    u.department,
                    h.name AS hod_name

                FROM users u

                LEFT JOIN users h
                    ON u.hod_id = h.id

                WHERE
                    u.role = 'STAFF'

                    AND
                    u.hod_id = ?

                ORDER BY
                    u.name ASC

                """;
        }


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {


            if (isHOD) {

                ps.setInt(
                    1,
                    userId
                );
            }


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                while (rs.next()) {

                    Map<String, Object> row =
                            new HashMap<>();


                    row.put(
                        "name",
                        rs.getString("name")
                    );


                    row.put(
                        "position",
                        rs.getString("position")
                    );


                    row.put(
                        "email",
                        rs.getString("email")
                    );


                    row.put(
                        "role",
                        rs.getString("role")
                    );


                    row.put(
                        "department",
                        rs.getString("department")
                    );


                    row.put(
                        "hodName",
                        rs.getString("hod_name")
                    );


                    staff.add(row);
                }
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menyediakan senarai staf untuk cetakan.",
                e
            );
        }


        // =====================================================
        // AUDIT TRAIL
        // =====================================================

        String auditDescription;


        if (isHOD) {

            auditDescription =
                    "Mencetak senarai staf di bawah seliaan"
                    +
                    " ("
                    +
                    staff.size()
                    +
                    " rekod)";

        } else {

            auditDescription =
                    "Mencetak senarai staf"
                    +
                    " ("
                    +
                    staff.size()
                    +
                    " rekod)";
        }


        try {

            ActivityLogUtil.log(
                request,
                "PRINT_STAFF_LIST",
                auditDescription,
                "STAFF_LIST",
                null
            );

        } catch (SQLException auditException) {

            auditException.printStackTrace();
        }


        // =====================================================
        // RESPONSE
        // =====================================================

        response.setContentType(
            "text/html;charset=UTF-8"
        );

        response.setCharacterEncoding(
            "UTF-8"
        );


        PrintWriter out =
                response.getWriter();


        String printDate =
                LocalDateTime.now()
                    .format(
                        DateTimeFormatter.ofPattern(
                            "dd/MM/yyyy HH:mm"
                        )
                    );


        String title =
                isHR
                    ? "Senarai Staf"
                    : "Senarai Staf Di Bawah Seliaan";


        String subtitle =
                isHR
                    ? "Rekod pengguna PKB Staff Management System"
                    : "Rekod staf di bawah seliaan Ketua Unit";


        String roleDisplay =
                isHR
                    ? "Pentadbir Sistem"
                    : "Ketua Unit";


        String backUrl =
                isHR
                    ? request.getContextPath() + "/staff"
                    : request.getContextPath() + "/hod-staff";


        // =====================================================
        // HTML
        // =====================================================

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
                    Senarai Staf - PKB
                </title>


                <style>

                    /* =========================================
                       GLOBAL
                       ========================================= */

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


                    body {
                        padding: 24px;

                        background: #f4f5f7;

                        color: #263143;

                        font-family:
                            "Segoe UI",
                            Arial,
                            sans-serif;

                        font-size: 14px;
                    }


                    /* =========================================
                       TOP ACTION BAR
                       ========================================= */

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


                    /* =========================================
                       BUTTONS
                       ========================================= */

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
                        border:
                            1px solid #8d1f2d;

                        background: #8d1f2d;

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
                        border:
                            1px solid #d8dde4;

                        background: #ffffff;

                        color: #515c6d;
                    }


                    .btn-back:hover {
                        background: #f6f7fa;

                        border-color: #c9ced6;
                    }


                    /* =========================================
                       DOCUMENT
                       ========================================= */

                    .page {
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


                    /* =========================================
                       COMPANY HEADER
                       ========================================= */

                    .header {
                        display: flex;

                        align-items: center;

                        gap: 22px;

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


                    .company-info {
                        min-width: 0;

                        flex: 1;
                    }


                    .company-info h1 {
                        margin: 0;

                        color: #8d1f2d;

                        font-size: 25px;

                        font-weight: 700;
                    }


                    .company-info p {
                        margin:
                            5px 0 0;

                        color: #737e90;

                        font-size: 13px;
                    }


                    /* =========================================
                       DOCUMENT TITLE
                       ========================================= */

                    .document-title {
                        margin:
                            24px 0 20px;

                        text-align: center;
                    }


                    .document-title h2 {
                        margin: 0;

                        color: #172033;

                        font-size: 22px;

                        font-weight: 700;
                    }


                    .document-title p {
                        margin:
                            6px 0 0;

                        color: #7d8796;

                        font-size: 12px;
                    }


                    /* =========================================
                       META
                       ========================================= */

                    .meta {
                        display: grid;

                        grid-template-columns:
                            repeat(3, minmax(0, 1fr));

                        gap: 12px;

                        margin-bottom: 18px;
                    }


                    .meta-box {
                        min-width: 0;

                        min-height: 60px;

                        padding:
                            11px 13px;

                        background: #fafafa;

                        border:
                            1px solid #e4e6ea;

                        border-radius: 8px;
                    }


                    .meta-label {
                        display: block;

                        margin-bottom: 5px;

                        color: #8a93a2;

                        font-size: 10px;

                        font-weight: 700;

                        text-transform: uppercase;
                    }


                    .meta-value {
                        color: #30394a;

                        font-size: 12px;

                        font-weight: 600;

                        overflow-wrap: anywhere;
                    }


                    /* =========================================
                       TABLE
                       ========================================= */

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
                            10px 9px;

                        background: #8d1f2d;

                        border:
                            1px solid #761925;

                        color: #ffffff;

                        font-size: 11px;

                        font-weight: 700;

                        line-height: 1.35;

                        text-align: left;

                        vertical-align: middle;
                    }


                    td {
                        padding:
                            10px 9px;

                        border:
                            1px solid #dfe2e7;

                        color: #424c5d;

                        font-size: 11px;

                        line-height: 1.45;

                        vertical-align: middle;

                        overflow-wrap: anywhere;
                    }


                    tbody tr:nth-child(even) {
                        background: #fafafa;
                    }


                    tbody tr:hover {
                        background: #fffafa;
                    }


                    .number-cell {
                        text-align: center;

                        color: #677182;

                        font-weight: 600;
                    }


                    .name-cell {
                        color: #172033;

                        font-weight: 600;
                    }


                    .role-badge {
                        display: inline-flex;

                        align-items: center;

                        justify-content: center;

                        padding:
                            4px 8px;

                        background: #f4f5f7;

                        border:
                            1px solid #e1e4e8;

                        border-radius: 20px;

                        color: #4e596a;

                        font-size: 10px;

                        font-weight: 600;
                    }


                    /* =========================================
                       EMPTY
                       ========================================= */

                    .empty-state {
                        padding:
                            28px !important;

                        color: #7d8796;

                        text-align: center;
                    }


                    /* =========================================
                       SUMMARY
                       ========================================= */

                    .summary {
                        display: flex;

                        align-items: center;

                        gap: 6px;

                        margin-top: 16px;

                        padding-top: 13px;

                        border-top:
                            1px solid #dddddd;

                        color: #4b5668;

                        font-size: 11px;
                    }


                    .summary strong {
                        color: #172033;
                    }


                    /* =========================================
                       FOOTER
                       ========================================= */

                    .footer {
                        margin-top: 24px;

                        padding-top: 13px;

                        border-top:
                            1px solid #dddddd;

                        color: #8a929f;

                        font-size: 10px;

                        text-align: center;
                    }


                    /* =========================================
                       RESPONSIVE
                       SCREEN SAHAJA
                       ========================================= */

                    @media screen and (max-width: 900px) {

                        body {
                            padding: 12px;
                        }


                        .page {
                            padding: 18px;
                        }


                        .top-actions {
                            flex-wrap: wrap;
                        }


                        .actions-info {
                            width: 100%;

                            margin-right: 0;
                        }


                        .header {
                            gap: 15px;
                        }


                        .logo {
                            width: 110px;
                        }


                        .company-info h1 {
                            font-size: 20px;
                        }


                        .meta {
                            grid-template-columns: 1fr;
                        }


                        th,
                        td {
                            padding:
                                7px 5px;

                            font-size: 9px;
                        }

                    }


                    /* =========================================
                       PRINT
                       KEKALKAN LAYOUT DESKTOP
                       ========================================= */

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

                            background:
                                #ffffff !important;

                            color:
                                #263143 !important;

                            font-family:
                                "Segoe UI",
                                Arial,
                                sans-serif !important;

                            font-size:
                                14px !important;

                            -webkit-print-color-adjust:
                                exact !important;

                            print-color-adjust:
                                exact !important;
                        }


                        /* =====================================
                           HIDE BUTTONS
                           ===================================== */

                        .top-actions-wrapper {
                            display:
                                none !important;
                        }


                        /* =====================================
                           MAIN DOCUMENT
                           ===================================== */

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


                        /* =====================================
                           HEADER
                           ===================================== */

                        .header {
                            display:
                                flex !important;

                            flex-direction:
                                row !important;

                            align-items:
                                center !important;

                            gap:
                                22px !important;

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
                            width:
                                150px !important;

                            height:
                                auto !important;

                            flex-shrink:
                                0 !important;

                            object-fit:
                                contain !important;
                        }


                        .company-info {
                            min-width:
                                0 !important;

                            flex:
                                1 !important;
                        }


                        .company-info h1 {
                            margin:
                                0 !important;

                            color:
                                #8d1f2d !important;

                            font-size:
                                25px !important;

                            font-weight:
                                700 !important;
                        }


                        .company-info p {
                            margin:
                                5px 0 0 !important;

                            color:
                                #737e90 !important;

                            font-size:
                                13px !important;
                        }


                        /* =====================================
                           DOCUMENT TITLE
                           ===================================== */

                        .document-title {
                            margin:
                                24px 0 20px !important;

                            text-align:
                                center !important;

                            page-break-inside:
                                avoid !important;

                            break-inside:
                                avoid !important;
                        }


                        .document-title h2 {
                            margin:
                                0 !important;

                            color:
                                #172033 !important;

                            font-size:
                                22px !important;

                            font-weight:
                                700 !important;
                        }


                        .document-title p {
                            margin:
                                6px 0 0 !important;

                            color:
                                #7d8796 !important;

                            font-size:
                                12px !important;
                        }


                        /* =====================================
                           META
                           KEKALKAN 3 KOTAK SEBARIS
                           ===================================== */

                        .meta {
                            display:
                                grid !important;

                            grid-template-columns:
                                repeat(
                                    3,
                                    minmax(0, 1fr)
                                ) !important;

                            gap:
                                12px !important;

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
                                60px !important;

                            padding:
                                11px 13px !important;

                            background:
                                #fafafa !important;

                            border:
                                1px solid #e4e6ea !important;

                            border-radius:
                                8px !important;
                        }


                        .meta-label {
                            display:
                                block !important;

                            margin-bottom:
                                5px !important;

                            color:
                                #8a93a2 !important;

                            font-size:
                                10px !important;

                            font-weight:
                                700 !important;

                            text-transform:
                                uppercase !important;
                        }


                        .meta-value {
                            color:
                                #30394a !important;

                            font-size:
                                12px !important;

                            font-weight:
                                600 !important;

                            overflow-wrap:
                                anywhere !important;
                        }


                        /* =====================================
                           TABLE
                           ===================================== */

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
                                10px 9px !important;

                            background:
                                #8d1f2d !important;

                            border:
                                1px solid #761925 !important;

                            color:
                                #ffffff !important;

                            font-size:
                                11px !important;

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
                                10px 9px !important;

                            border:
                                1px solid #dfe2e7 !important;

                            color:
                                #424c5d !important;

                            font-size:
                                11px !important;

                            line-height:
                                1.45 !important;

                            vertical-align:
                                middle !important;

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


                        .number-cell {
                            text-align:
                                center !important;

                            color:
                                #677182 !important;

                            font-weight:
                                600 !important;
                        }


                        .name-cell {
                            color:
                                #172033 !important;

                            font-weight:
                                600 !important;
                        }


                        .role-badge {
                            display:
                                inline-flex !important;

                            align-items:
                                center !important;

                            justify-content:
                                center !important;

                            padding:
                                4px 8px !important;

                            background:
                                #f4f5f7 !important;

                            border:
                                1px solid #e1e4e8 !important;

                            border-radius:
                                20px !important;

                            color:
                                #4e596a !important;

                            font-size:
                                10px !important;

                            font-weight:
                                600 !important;
                        }


                        /* =====================================
                           EMPTY
                           ===================================== */

                        .empty-state {
                            padding:
                                28px !important;

                            color:
                                #7d8796 !important;

                            text-align:
                                center !important;
                        }


                        /* =====================================
                           TABLE HEADER SETIAP PAGE
                           ===================================== */

                        thead {
                            display:
                                table-header-group !important;
                        }


                        tfoot {
                            display:
                                table-footer-group !important;
                        }


                        /* =====================================
                           JANGAN PECAHKAN ROW
                           ===================================== */

                        tr {
                            page-break-inside:
                                avoid !important;

                            break-inside:
                                avoid !important;
                        }


                        /* =====================================
                           SUMMARY
                           ===================================== */

                        .summary {
                            display:
                                flex !important;

                            align-items:
                                center !important;

                            gap:
                                6px !important;

                            margin-top:
                                16px !important;

                            padding-top:
                                13px !important;

                            border-top:
                                1px solid #dddddd !important;

                            color:
                                #4b5668 !important;

                            font-size:
                                11px !important;

                            page-break-inside:
                                avoid !important;

                            break-inside:
                                avoid !important;
                        }


                        .summary strong {
                            color:
                                #172033 !important;
                        }


                        /* =====================================
                           FOOTER
                           ===================================== */

                        .footer {
                            margin-top:
                                24px !important;

                            padding-top:
                                13px !important;

                            border-top:
                                1px solid #dddddd !important;

                            color:
                                #8a929f !important;

                            font-size:
                                10px !important;

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


            <!-- =============================================
                 TOP ACTION BAR
                 ============================================= -->

            <div class="top-actions-wrapper">

                <div class="top-actions">


                    <div class="actions-info">

                        <strong>
                            Senarai Staf
                        </strong>

                        <span>
                            Cetak senarai staf atau kembali ke halaman pengurusan staf
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


        // =====================================================
        // BACK BUTTON
        // =====================================================

        out.println(
            "<a class=\"btn btn-back\" href=\""
            +
            escape(backUrl)
            +
            "\">"
            +
            "Kembali"
            +
            "</a>"
        );


        out.println(
            """

                </div>

            </div>


            <!-- =============================================
                 PRINT DOCUMENT
                 ============================================= -->

            <div class="page">


                <div class="header">

            """
        );


        // =====================================================
        // LOGO
        // =====================================================

        out.println(
            "<img class=\"logo\" src=\""
            +
            request.getContextPath()
            +
            "/images/logo-pkb.png\" "
            +
            "alt=\"PKB\">"
        );


        // =====================================================
        // COMPANY
        // =====================================================

        out.println(
            """

                    <div class="company-info">

                        <h1>
                            Permodalan Kedah Berhad
                        </h1>

                        <p>
                            PKB Staff Management System
                        </p>

                    </div>

                </div>

            """
        );


        // =====================================================
        // TITLE
        // =====================================================

        out.println(
            "<div class=\"document-title\">"
            +
            "<h2>"
            +
            escape(title)
            +
            "</h2>"
            +
            "<p>"
            +
            escape(subtitle)
            +
            "</p>"
            +
            "</div>"
        );


        // =====================================================
        // META
        // =====================================================

        out.println(
            "<div class=\"meta\">"
        );


        out.println(
            metaBox(
                "Dicetak Oleh",
                userName
            )
        );


        out.println(
            metaBox(
                "Peranan",
                roleDisplay
            )
        );


        out.println(
            metaBox(
                "Tarikh Cetakan",
                printDate
            )
        );


        out.println(
            "</div>"
        );


        // =====================================================
        // TABLE
        // =====================================================

        out.println(
            """

            <div class="table-wrapper">

                <table>

                    <thead>

                        <tr>

                            <th style="width:5%;">
                                Bil.
                            </th>

                            <th style="width:16%;">
                                Nama
                            </th>

                            <th style="width:18%;">
                                Jawatan
                            </th>

                            <th style="width:17%;">
                                E-mel
                            </th>

                            <th style="width:13%;">
                                Peranan
                            </th>

                            <th style="width:19%;">
                                Jabatan
                            </th>

                            <th style="width:12%;">
                                Ketua Unit
                            </th>

                        </tr>

                    </thead>

                    <tbody>

            """
        );


        int number = 1;


        for (
            Map<String, Object> row :
            staff
        ) {


            out.println(
                "<tr>"
            );


            // BIL
            out.println(
                "<td class=\"number-cell\">"
                +
                number++
                +
                "</td>"
            );


            // NAMA
            out.println(
                "<td class=\"name-cell\">"
                +
                escape(
                    displayOrDash(
                        row.get("name")
                    )
                )
                +
                "</td>"
            );


            // JAWATAN
            out.println(
                "<td>"
                +
                escape(
                    displayOrDash(
                        row.get("position")
                    )
                )
                +
                "</td>"
            );


            // EMAIL
            out.println(
                "<td>"
                +
                escape(
                    displayOrDash(
                        row.get("email")
                    )
                )
                +
                "</td>"
            );


            // ROLE
            out.println(
                "<td>"
                +
                "<span class=\"role-badge\">"
                +
                escape(
                    roleName(
                        row.get("role")
                    )
                )
                +
                "</span>"
                +
                "</td>"
            );


            // DEPARTMENT
            out.println(
                "<td>"
                +
                escape(
                    departmentName(
                        row.get("department")
                    )
                )
                +
                "</td>"
            );


            // HOD
            out.println(
                "<td>"
                +
                escape(
                    displayOrDash(
                        row.get("hodName")
                    )
                )
                +
                "</td>"
            );


            out.println(
                "</tr>"
            );
        }


        // =====================================================
        // EMPTY
        // =====================================================

        if (staff.isEmpty()) {

            out.println(
                """

                <tr>

                    <td
                        colspan="7"
                        class="empty-state"
                    >
                        Tiada rekod staf.
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


        // =====================================================
        // SUMMARY
        // =====================================================

        out.println(
            "<div class=\"summary\">"
            +
            "<strong>Jumlah Rekod:</strong>"
            +
            "<span>"
            +
            staff.size()
            +
            " staf"
            +
            "</span>"
            +
            "</div>"
        );


        // =====================================================
        // FOOTER
        // =====================================================

        out.println(
            """

            <div class="footer">

                Dokumen ini dijana oleh
                PKB Staff Management System.

            </div>


            </div>


            </body>

            </html>

            """
        );
    }


    // =========================================================
    // ROLE DISPLAY
    // =========================================================

    private String roleName(
            Object value) {


        if (value == null) {
            return "-";
        }


        String role =
                value.toString()
                    .trim()
                    .toUpperCase();


        switch (role) {

            case "STAFF":
                return "Staf";

            case "HOD":
                return "Ketua Unit";

            case "HR":
                return "Pentadbir Sistem";

            case "MANAGEMENT":
                return "Pengurusan";

            default:
                return role;
        }
    }


    // =========================================================
    // DEPARTMENT DISPLAY
    // =========================================================

    private String departmentName(
            Object value) {


        if (value == null) {
            return "-";
        }


        String department =
                value.toString()
                    .trim()
                    .toUpperCase();


        switch (department) {

            case "PENTADBIRAN_KORPORAT":
                return "Pentadbiran dan Korporat";

            case "KEWANGAN":
                return "Kewangan";

            case "PEMBANGUNAN_PERNIAGAAN_OPERASI":
                return "Pembangunan Perniagaan dan Operasi";

            default:
                return value.toString();
        }
    }


    // =========================================================
    // DISPLAY OR DASH
    // =========================================================

    private String displayOrDash(
            Object value) {


        if (
            value == null
            ||
            value.toString().isBlank()
        ) {

            return "-";
        }


        return value
            .toString()
            .trim();
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
            +
            escape(label)
            +
            "</span>"
            +
            "<span class=\"meta-value\">"
            +
            escape(value)
            +
            "</span>"
            +
            "</div>";
    }


    // =========================================================
    // ESCAPE HTML
    // =========================================================

    private String escape(
            Object value) {


        if (value == null) {
            return "";
        }


        return value
            .toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
}