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
import java.sql.Timestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.ArrayList;
import java.util.List;


@WebServlet("/print-activity-log")
public class PrintActivityLogServlet extends HttpServlet {

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

        if (session == null
                || session.getAttribute("userId") == null) {

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


        // =====================================================
        // HR ONLY
        // =====================================================

        if (!"HR".equals(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Anda tidak mempunyai kebenaran untuk mencetak Log Aktiviti."
            );

            return;
        }


        String userName =
                session.getAttribute("userName") == null
                        ? "Pengguna"
                        : session.getAttribute("userName")
                            .toString()
                            .trim();


        if (userName.isBlank()) {
            userName = "Pengguna";
        }


        // =====================================================
        // FILTER PARAMETERS
        // =====================================================

        String search =
                clean(
                    request.getParameter("search")
                );


        String action =
                clean(
                    request.getParameter("action")
                ).toUpperCase();


        String selectedRole =
                clean(
                    request.getParameter("role")
                ).toUpperCase();


        String dateFrom =
                clean(
                    request.getParameter("dateFrom")
                );


        String dateTo =
                clean(
                    request.getParameter("dateTo")
                );


        // =====================================================
        // VALIDATE ACTION
        // =====================================================

        if (!action.isBlank()
                && !action.matches("[A-Z0-9_]+")) {

            action = "";
        }


        // =====================================================
        // VALIDATE ROLE
        // =====================================================

        if (!selectedRole.isBlank()
                && !"STAFF".equals(selectedRole)
                && !"HOD".equals(selectedRole)
                && !"HR".equals(selectedRole)
                && !"MANAGEMENT".equals(selectedRole)) {

            selectedRole = "";
        }


        // =====================================================
        // VALIDATE DATES
        // =====================================================

        if (!isValidDate(dateFrom)) {
            dateFrom = "";
        }

        if (!isValidDate(dateTo)) {
            dateTo = "";
        }


        // =====================================================
        // SWAP INVALID DATE RANGE
        // =====================================================

        if (!dateFrom.isBlank()
                && !dateTo.isBlank()) {

            LocalDate from =
                    LocalDate.parse(dateFrom);

            LocalDate to =
                    LocalDate.parse(dateTo);


            if (from.isAfter(to)) {

                String temp = dateFrom;

                dateFrom = dateTo;

                dateTo = temp;
            }
        }


        // =====================================================
        // SQL
        // =====================================================

        StringBuilder sql =
                new StringBuilder(
                    """
                    SELECT
                        id,
                        user_name,
                        user_role,
                        action,
                        description,
                        reference_type,
                        reference_id,
                        ip_address,
                        created_at
                    FROM activity_logs
                    WHERE 1 = 1
                    """
                );


        List<Object> parameters =
                new ArrayList<>();


        // =====================================================
        // SEARCH
        // =====================================================

        if (!search.isBlank()) {

            sql.append(
                """
                AND
                (
                    user_name LIKE ?
                    OR user_role LIKE ?
                    OR action LIKE ?
                    OR description LIKE ?
                    OR reference_type LIKE ?
                    OR reference_id LIKE ?
                    OR ip_address LIKE ?
                )
                """
            );


            String keyword =
                    "%"
                    + search
                    + "%";


            for (int i = 0; i < 7; i++) {
                parameters.add(keyword);
            }
        }


        // =====================================================
        // ACTION FILTER
        // =====================================================

        if (!action.isBlank()) {

            sql.append(
                " AND action = ? "
            );

            parameters.add(action);
        }


        // =====================================================
        // ROLE FILTER
        // =====================================================

        if (!selectedRole.isBlank()) {

            sql.append(
                " AND user_role = ? "
            );

            parameters.add(selectedRole);
        }


        // =====================================================
        // DATE FROM
        // =====================================================

        if (!dateFrom.isBlank()) {

            sql.append(
                " AND created_at >= ? "
            );

            parameters.add(
                dateFrom + " 00:00:00"
            );
        }


        // =====================================================
        // DATE TO
        // =====================================================

        if (!dateTo.isBlank()) {

            sql.append(
                " AND created_at < DATE_ADD(?, INTERVAL 1 DAY) "
            );

            parameters.add(
                dateTo + " 00:00:00"
            );
        }


        // =====================================================
        // ORDER
        // =====================================================

        sql.append(
            """
            ORDER BY
                created_at DESC,
                id DESC
            """
        );


        // =====================================================
        // RESPONSE
        // =====================================================

        response.setContentType(
                "text/html;charset=UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(
                        sql.toString()
                    );

            PrintWriter out =
                    response.getWriter()
        ) {

            // =================================================
            // SQL PARAMETERS
            // =================================================

            int index = 1;

            for (Object parameter : parameters) {

                ps.setObject(
                        index++,
                        parameter
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
                        Cetak Log Aktiviti
                    </title>


                    <style>

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

                            background: #f4f5f7;

                            color: #263143;

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
                                1px solid #e2e5e9;

                            border-radius: 12px;

                            box-shadow:
                                0 4px 15px
                                rgba(0,0,0,.045);
                        }


                        .actions-info {
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
                           BUTTON
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
                            border:
                                1px solid #8d1f2d;

                            background: #8d1f2d;

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
                            border:
                                1px solid #d8dde4;

                            background: #ffffff;

                            color: #515c6d;
                        }


                        .btn-back:hover {
                            background: #f7f8fa;

                            border-color: #c9ced6;

                            color: #303a49;
                        }


                        /* =====================================
                           DOCUMENT PAGE
                           ===================================== */

                        .page {
                            width: 100%;

                            max-width: 1500px;

                            margin: auto;

                            padding: 30px;

                            background: #ffffff;

                            border:
                                1px solid #e2e5e9;

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

                            gap: 22px;

                            padding-bottom: 20px;

                            border-bottom:
                                3px solid #8d1f2d;
                        }


                        .logo {
                            width: 150px;

                            height: auto;

                            flex-shrink: 0;
                        }


                        .company {
                            flex: 1;
                        }


                        .company h1 {
                            margin: 0;

                            color: #8d1f2d;

                            font-size: 25px;

                            font-weight: 700;
                        }


                        .company p {
                            margin:
                                5px 0 0;

                            color: #737e90;

                            font-size: 13px;
                        }


                        /* =====================================
                           TITLE
                           ===================================== */

                        .title {
                            margin:
                                24px 0 20px;

                            text-align: center;
                        }


                        .title h2 {
                            margin: 0;

                            color: #172033;

                            font-size: 22px;

                            font-weight: 700;
                        }


                        .title p {
                            margin:
                                6px 0 0;

                            color: #7d8796;

                            font-size: 12px;
                        }


                        /* =====================================
                           META INFORMATION
                           ===================================== */

                        .meta {
                            display: grid;

                            grid-template-columns:
                                repeat(3, 1fr);

                            gap: 12px;

                            margin-bottom: 16px;
                        }


                        .meta-box {
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

                            letter-spacing: .2px;
                        }


                        .meta-value {
                            color: #30394a;

                            font-size: 12px;

                            font-weight: 600;
                        }


                        /* =====================================
                           FILTER INFORMATION
                           ===================================== */

                        .filter-info {
                            margin-bottom: 16px;

                            padding:
                                11px 13px;

                            background: #fff8f8;

                            border:
                                1px solid #f0dfe2;

                            border-radius: 8px;

                            color: #596273;

                            font-size: 11px;

                            line-height: 1.6;
                        }


                        .filter-info strong {
                            color: #8d1f2d;

                            font-weight: 700;
                        }


                        /* =====================================
                           TABLE
                           ===================================== */

                        .table-wrapper {
                            width: 100%;

                            overflow: hidden;

                            border-radius: 5px;
                        }


                        table {
                            width: 100%;

                            border-collapse: collapse;

                            table-layout: fixed;
                        }


                        th {
                            padding:
                                10px 8px;

                            background: #8d1f2d;

                            border:
                                1px solid #761925;

                            color: #ffffff;

                            font-size: 10px;

                            font-weight: 700;

                            line-height: 1.35;

                            text-align: left;

                            vertical-align: middle;
                        }


                        td {
                            padding:
                                9px 8px;

                            border:
                                1px solid #dfe2e7;

                            color: #424c5d;

                            font-size: 10.5px;

                            line-height: 1.5;

                            vertical-align: top;

                            word-break: normal;

                            overflow-wrap: anywhere;
                        }


                        tbody tr:nth-child(even) {
                            background: #fafafa;
                        }


                        tbody tr:hover {
                            background: #fffafa;
                        }


                        .date-cell {
                            color: #505a6a;

                            white-space: normal;
                        }


                        .user-cell {
                            color: #253044;

                            font-weight: 600;
                        }


                        .role-cell {
                            color: #505b6d;
                        }


                        .action-cell {
                            color: #303b4d;

                            font-weight: 600;
                        }


                        .description-cell {
                            color: #424c5d;
                        }


                        .ip-cell {
                            color: #626d7f;

                            font-size: 10px;
                        }


                        .reference {
                            margin-top: 4px;

                            color: #8c96a6;

                            font-size: 9.5px;

                            line-height: 1.4;
                        }


                        .empty {
                            padding: 28px !important;

                            color: #7d8796;

                            font-size: 12px !important;

                            text-align: center;
                        }


                        .summary {
                            margin-top: 16px;

                            padding-top: 13px;

                            border-top:
                                1px solid #dddddd;

                            color: #4b5668;

                            font-size: 11px;
                        }


                        .summary strong {
                            color: #172033;

                            font-weight: 700;
                        }


                        .footer {
                            margin-top: 24px;

                            padding-top: 13px;

                            border-top:
                                1px solid #dddddd;

                            color: #8a929f;

                            font-size: 10px;

                            text-align: center;
                        }


                        /* =====================================
                           RESPONSIVE
                           ===================================== */

                        @media (max-width: 1000px) {

                            body {
                                padding: 15px;
                            }


                            .page {
                                padding: 20px;
                            }


                            th {
                                font-size: 9.5px;

                                padding:
                                    9px 6px;
                            }


                            td {
                                font-size: 10px;

                                padding:
                                    8px 6px;
                            }
                        }


                        @media (max-width: 700px) {

                            .actions {
                                flex-wrap: wrap;
                            }


                            .actions-info {
                                width: 100%;

                                margin-right: 0;

                                margin-bottom: 4px;
                            }


                            .btn {
                                flex: 1;
                            }


                            .meta {
                                grid-template-columns: 1fr;
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
                        }


                        /* =====================================
                           PRINT
                           ===================================== */

                        @page {
                            size: A4 landscape;

                            margin: 8mm;
                        }


                        @media print {

                            html,
                            body {
                                width: 100%;

                                overflow: visible;
                            }


                            body {
                                padding: 0;

                                background: #ffffff;

                                font-size: 10pt;
                            }


                            .top-actions-wrapper,
                            .actions {
                                display: none !important;
                            }


                            .page {
                                width: 100%;

                                max-width: none;

                                margin: 0;

                                padding: 0;

                                border: 0;

                                border-radius: 0;

                                box-shadow: none;
                            }


                            th {
                                padding: 7px 6px;

                                font-size: 8.5pt;
                            }


                            td {
                                padding: 7px 6px;

                                font-size: 8pt;

                                line-height: 1.35;
                            }


                            .reference {
                                font-size: 7.5pt;
                            }


                            .meta-label {
                                font-size: 8pt;
                            }


                            .meta-value {
                                font-size: 9pt;
                            }


                            .summary {
                                font-size: 9pt;
                            }


                            .footer {
                                font-size: 8pt;
                            }


                            thead {
                                display: table-header-group;
                            }


                            tr {
                                page-break-inside: avoid;
                            }
                        }

                    </style>

                </head>


                <body>


                <div class="top-actions-wrapper">

                    <div class="actions">


                        <div class="actions-info">

                            <strong>
                                Log Aktiviti Sistem
                            </strong>

                            <span>
                                Cetak rekod audit atau kembali ke halaman Log Aktiviti
                            </span>

                        </div>


                        <button
                            type="button"
                            class="btn btn-print"
                            onclick="window.print()"
                        >
                            Cetak Log Aktiviti
                        </button>

                """
            );


            // =================================================
            // BACK BUTTON
            // =================================================

            out.println(
                "<a "
                +
                "class=\"btn btn-back\" "
                +
                "href=\""
                +
                request.getContextPath()
                +
                "/activity-log\""
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


                <div class="page">

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
                + request.getContextPath()
                + "/images/logo-pkb.png\" alt=\"PKB\">"
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

                </div>

                """
            );


            // =================================================
            // TITLE
            // =================================================

            out.println(
                """

                <div class="title">

                    <h2>
                        Log Aktiviti Sistem
                    </h2>

                    <p>
                        Rekod Audit Trail PKB Staff Management System
                    </p>

                </div>

                """
            );


            String printDate =
                    LocalDateTime.now()
                        .format(
                            DateTimeFormatter.ofPattern(
                                "dd/MM/yyyy HH:mm"
                            )
                        );


            // =================================================
            // META
            // =================================================

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
                    "HR"
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


            // =================================================
            // FILTER INFORMATION
            // =================================================

            boolean hasFilter =
                    !search.isBlank()
                    ||
                    !action.isBlank()
                    ||
                    !selectedRole.isBlank()
                    ||
                    !dateFrom.isBlank()
                    ||
                    !dateTo.isBlank();


            if (hasFilter) {

                StringBuilder filterText =
                        new StringBuilder();


                if (!search.isBlank()) {

                    appendFilter(
                        filterText,
                        "Carian",
                        search
                    );
                }


                if (!action.isBlank()) {

                    appendFilter(
                        filterText,
                        "Aktiviti",
                        actionLabel(action)
                    );
                }


                if (!selectedRole.isBlank()) {

                    appendFilter(
                        filterText,
                        "Peranan",
                        roleLabel(selectedRole)
                    );
                }


                if (!dateFrom.isBlank()) {

                    appendFilter(
                        filterText,
                        "Tarikh Mula",
                        formatInputDate(dateFrom)
                    );
                }


                if (!dateTo.isBlank()) {

                    appendFilter(
                        filterText,
                        "Tarikh Akhir",
                        formatInputDate(dateTo)
                    );
                }


                out.println(
                    "<div class=\"filter-info\">"
                    +
                    "<strong>Filter Cetakan:</strong> "
                    +
                    escape(filterText.toString())
                    +
                    "</div>"
                );
            }


            // =================================================
            // TABLE
            // =================================================

            out.println(
                """

                <div class="table-wrapper">

                    <table>

                        <thead>

                            <tr>

                                <th style="width:11%;">
                                    Tarikh & Masa
                                </th>

                                <th style="width:12%;">
                                    Pengguna
                                </th>

                                <th style="width:9%;">
                                    Peranan
                                </th>

                                <th style="width:17%;">
                                    Aktiviti
                                </th>

                                <th style="width:40%;">
                                    Keterangan
                                </th>

                                <th style="width:11%;">
                                    IP
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

                while (rs.next()) {

                    count++;


                    Timestamp createdAt =
                            rs.getTimestamp(
                                "created_at"
                            );


                    String dateText =
                            createdAt == null
                                ? "-"
                                : createdAt
                                    .toLocalDateTime()
                                    .format(
                                        DateTimeFormatter.ofPattern(
                                            "dd/MM/yyyy HH:mm:ss"
                                        )
                                    );


                    String logUserName =
                            safe(
                                rs.getString(
                                    "user_name"
                                )
                            );


                    String logRole =
                            roleLabel(
                                rs.getString(
                                    "user_role"
                                )
                            );


                    String logAction =
                            actionLabel(
                                rs.getString(
                                    "action"
                                )
                            );


                    String description =
                            safe(
                                rs.getString(
                                    "description"
                                )
                            );


                    if (description.isBlank()) {
                        description = "-";
                    }


                    String referenceType =
                            safe(
                                rs.getString(
                                    "reference_type"
                                )
                            );


                    String referenceId =
                            safe(
                                rs.getString(
                                    "reference_id"
                                )
                            );


                    String ipAddress =
                            safe(
                                rs.getString(
                                    "ip_address"
                                )
                            );


                    // =========================================
                    // NORMALIZE LOCALHOST IP
                    // =========================================

                    if ("0:0:0:0:0:0:0:1".equals(ipAddress)
                            || "::1".equals(ipAddress)) {

                        ipAddress = "127.0.0.1";
                    }


                    if (ipAddress.isBlank()) {
                        ipAddress = "-";
                    }


                    StringBuilder descriptionHtml =
                            new StringBuilder();


                    descriptionHtml.append(
                        escape(description)
                    );


                    if (!referenceType.isBlank()
                            || !referenceId.isBlank()) {

                        descriptionHtml.append(
                            "<div class=\"reference\">Rujukan: "
                        );


                        if (!referenceType.isBlank()) {

                            descriptionHtml.append(
                                escape(
                                    referenceLabel(
                                        referenceType
                                    )
                                )
                            );
                        }


                        if (!referenceId.isBlank()) {

                            descriptionHtml.append(
                                " #"
                            );

                            descriptionHtml.append(
                                escape(referenceId)
                            );
                        }


                        descriptionHtml.append(
                            "</div>"
                        );
                    }


                    // =========================================
                    // TABLE ROW
                    // =========================================

                    out.println("<tr>");


                    out.println(
                        "<td class=\"date-cell\">"
                        + escape(dateText)
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"user-cell\">"
                        + escape(logUserName)
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"role-cell\">"
                        + escape(logRole)
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"action-cell\">"
                        + escape(logAction)
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"description-cell\">"
                        + descriptionHtml
                        + "</td>"
                    );


                    out.println(
                        "<td class=\"ip-cell\">"
                        + escape(ipAddress)
                        + "</td>"
                    );


                    out.println("</tr>");
                }
            }


            // =================================================
            // EMPTY
            // =================================================

            if (count == 0) {

                out.println(
                    """

                    <tr>

                        <td
                            colspan="6"
                            class="empty"
                        >
                            Tiada rekod Log Aktiviti.
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
                +
                count
                +
                " rekod"
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

                </div>


                </body>

                </html>

                """
            );


            // =================================================
            // AUDIT TRAIL
            // =================================================

            String auditDescription =
                    "Mencetak Log Aktiviti"
                    +
                    " ("
                    +
                    count
                    +
                    " rekod)";


            try {

                ActivityLogUtil.log(
                    request,
                    "PRINT_ACTIVITY_LOG",
                    auditDescription,
                    "ACTIVITY_LOG",
                    null
                );

            } catch (SQLException auditException) {

                auditException.printStackTrace();
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menyediakan Log Aktiviti untuk cetakan.",
                e
            );
        }
    }


    // =========================================================
    // CLEAN
    // =========================================================

    private String clean(String value) {

        return value == null
                ? ""
                : value.trim();
    }


    // =========================================================
    // VALID DATE
    // =========================================================

    private boolean isValidDate(String value) {

        if (value == null
                || value.isBlank()) {

            return false;
        }


        try {

            LocalDate.parse(value);

            return true;

        } catch (Exception e) {

            return false;
        }
    }


    // =========================================================
    // SAFE
    // =========================================================

    private String safe(String value) {

        return value == null
                ? ""
                : value.trim();
    }


    // =========================================================
    // ESCAPE
    // =========================================================

    private String escape(String value) {

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
    // ROLE LABEL
    // =========================================================

    private String roleLabel(String role) {

        String value =
                safe(role)
                    .toUpperCase();


        switch (value) {

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
                return value.isBlank()
                        ? "-"
                        : value;
        }
    }


    // =========================================================
    // ACTION LABEL
    // =========================================================

    private String actionLabel(String action) {

        String value =
                safe(action)
                    .toUpperCase();


        switch (value) {

            // =================================================
            // AKAUN / AUTH
            // =================================================

            case "LOGIN":
                return "Log Masuk";

            case "LOGIN_FAILED":
                return "Percubaan Log Masuk Gagal";

            case "LOGOUT":
                return "Log Keluar";

            case "REGISTER_ACCOUNT":
            case "REGISTER_USER":
                return "Daftar Akaun";

            case "ADD_STAFF":
            case "ADD_USER":
                return "Tambah Staf";

            case "EDIT_STAFF":
            case "UPDATE_STAFF":
            case "EDIT_USER":
                return "Kemaskini Staf";

            case "DELETE_STAFF":
            case "DELETE_USER":
                return "Padam Staf";

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
            // CUTI
            // =================================================

            case "SUBMIT_LEAVE":
            case "CREATE_LEAVE":
            case "APPLY_LEAVE":
                return "Permohonan Cuti";

            case "EDIT_LEAVE":
            case "UPDATE_LEAVE":
                return "Kemaskini Permohonan Cuti";

            case "CANCEL_LEAVE":
                return "Batal Permohonan Cuti";

            case "PRINT_LEAVE":
            case "PRINT_LEAVE_FORM":
                return "Cetak Borang Permohonan Cuti";

            case "PRINT_LEAVE_LIST":
            case "PRINT_LEAVE_APPLICATION_LIST":
                return "Cetak Senarai Permohonan Cuti";

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

            case "UPDATE_LEAVE_BALANCE":
                return "Kemaskini Kuota Cuti";


            // =================================================
            // CUTI UMUM
            // =================================================

            case "ADD_PUBLIC_HOLIDAY":
                return "Tambah Cuti Umum";

            case "EDIT_PUBLIC_HOLIDAY":
            case "UPDATE_PUBLIC_HOLIDAY":
                return "Kemaskini Cuti Umum";

            case "ACTIVATE_PUBLIC_HOLIDAY":
                return "Aktifkan Cuti Umum";

            case "DEACTIVATE_PUBLIC_HOLIDAY":
                return "Nyahaktifkan Cuti Umum";

            case "DELETE_PUBLIC_HOLIDAY":
                return "Padam Cuti Umum";


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
            // INVENTORI - PERMOHONAN
            // =================================================

            case "CREATE_INVENTORY_REQUEST":
            case "APPLY_INVENTORY":
            case "REQUEST_INVENTORY":
                return "Permohonan Inventori";

            case "APPROVE_INVENTORY_REQUEST":
                return "Lulus Permohonan Inventori";

            case "REJECT_INVENTORY_REQUEST":
                return "Tolak Permohonan Inventori";

            case "CANCEL_INVENTORY_REQUEST":
                return "Batal Permohonan Inventori";


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
            // INVENTORI - PEMULANGAN
            // =================================================

            case "CREATE_INVENTORY_RETURN":
            case "REQUEST_INVENTORY_RETURN":
            case "INVENTORY_RETURN_REQUEST":
                return "Permohonan Pemulangan Inventori";

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

            case "PRINT_STAFF_LIST":
                return "Cetak Senarai Staf";

            case "PRINT_INVENTORY_LIST":
                return "Cetak Senarai Inventori";

            case "PRINT_INVENTORY_REQUEST":
                return "Cetak Permohonan Inventori";

            case "PRINT_INVENTORY_TRANSACTION":
            case "PRINT_INVENTORY_TRANSACTIONS":
            case "PRINT_INVENTORY_TRANSACTION_HISTORY":
                return "Cetak Sejarah Transaksi Inventori";

            case "PRINT_ACTIVITY_LOG":
                return "Cetak Log Aktiviti";


            // =================================================
            // CARRY FORWARD
            // =================================================

            case "UPDATE_CARRY_FORWARD":
                return "Kemaskini Carry Forward";

            case "PROCESS_CARRY_FORWARD":
                return "Proses Carry Forward";


            // =================================================
            // DEFAULT
            // =================================================

            default:

                if (value.isBlank()) {
                    return "-";
                }

                return value.replace("_", " ");
        }
    }


    // =========================================================
    // REFERENCE LABEL
    // =========================================================

    private String referenceLabel(String referenceType) {

        String value =
                safe(referenceType)
                    .toUpperCase();


        switch (value) {

            // =================================================
            // CUTI
            // =================================================

            case "LEAVE_APPLICATION":
                return "Permohonan Cuti";

            case "LEAVE_LIST":
                return "Senarai Permohonan Cuti";


            // =================================================
            // CUTI UMUM
            // =================================================

            case "PUBLIC_HOLIDAY":
                return "Cuti Umum";


            // =================================================
            // PENGGUNA
            // =================================================

            case "USER":
                return "Pengguna";

            case "STAFF":
                return "Staf";

            case "STAFF_LIST":
                return "Senarai Staf";


            // =================================================
            // PENGUMUMAN
            // =================================================

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


            // =================================================
            // INVENTORI
            // =================================================

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


            // =================================================
            // LOG AKTIVITI
            // =================================================

            case "ACTIVITY_LOG":
                return "Log Aktiviti";


            // =================================================
            // CARRY FORWARD
            // =================================================

            case "CARRY_FORWARD":
                return "Carry Forward";


            // =================================================
            // DEFAULT
            // =================================================

            default:

                if (value.isBlank()) {
                    return "-";
                }

                return value.replace("_", " ");
        }
    }


    // =========================================================
    // FORMAT INPUT DATE
    // =========================================================

    private String formatInputDate(String value) {

        try {

            return LocalDate
                .parse(value)
                .format(
                    DateTimeFormatter.ofPattern(
                        "dd/MM/yyyy"
                    )
                );

        } catch (Exception e) {

            return value;
        }
    }


    // =========================================================
    // APPEND FILTER
    // =========================================================

    private void appendFilter(
            StringBuilder builder,
            String label,
            String value) {

        if (builder.length() > 0) {
            builder.append(" | ");
        }


        builder
            .append(label)
            .append(": ")
            .append(value);
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
}
