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

@WebServlet("/print-inventory-list")
public class PrintInventoryListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =========================================================
        // SESSION CHECK
        // =========================================================
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String role = session.getAttribute("userRole") == null
                ? ""
                : session.getAttribute("userRole")
                        .toString()
                        .trim()
                        .toUpperCase();

        if (!"HR".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String printedBy = session.getAttribute("userName") == null
                ? "HR Admin"
                : session.getAttribute("userName").toString();

        String printedDate = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        // =========================================================
        // SQL
        // =========================================================
        String sql = """
            SELECT
                item_code,
                item_name,
                category,
                item_type,
                quantity,
                available_quantity,
                item_condition,
                location,
                status
            FROM inventory_items
            ORDER BY item_name ASC, item_code ASC
        """;

        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            PrintWriter out = response.getWriter()
        ) {

            // =====================================================
            // HTML + CSS
            // =====================================================
            out.println("""
<!DOCTYPE html>
<html lang="ms">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Cetak Senarai Inventori - PKB</title>

    <style>

        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            padding: 0;
            width: 100%;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #172033;
        }

        body {
            background: #f5f7fa;
            padding: 24px;
        }

        /* =====================================================
           ACTION BAR
           ===================================================== */

        .action-bar {
            width: 100%;
            max-width: 1500px;
            margin: 0 auto 18px;
            padding: 17px 20px;

            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;

            background: #ffffff;
            border: 1px solid #e1e5eb;
            border-radius: 14px;
        }

        .action-title h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #172033;
        }

        .action-title p {
            margin: 5px 0 0;
            font-size: 13px;
            color: #8490a3;
        }

        .action-buttons {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .btn {
            height: 42px;
            padding: 0 20px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            border-radius: 8px;

            font-family: inherit;
            font-size: 13px;
            font-weight: 600;

            text-decoration: none;
            cursor: pointer;
        }

        .btn-print {
            border: 1px solid #a80f26;
            background: #a80f26;
            color: white;
        }

        .btn-print:hover {
            background: #8d0d20;
        }

        .btn-back {
            border: 1px solid #dce1e8;
            background: white;
            color: #172033;
        }

        .btn-back:hover {
            background: #f7f8fa;
        }

        /* =====================================================
           DOCUMENT
           ===================================================== */

        .document {
            width: 100%;
            max-width: 1500px;
            margin: auto;

            padding: 36px 38px;

            background: #ffffff;

            border: 1px solid #e1e5eb;
            border-radius: 14px;
        }

        /* =====================================================
           COMPANY HEADER
           ===================================================== */

        .company-header {
            display: flex;
            align-items: center;
            gap: 22px;

            padding-bottom: 20px;
            border-bottom: 3px solid #8d1f2d;
        }

        .company-logo {
            width: 180px;
            height: auto;
            object-fit: contain;
            flex-shrink: 0;
        }

        .company-info h1 {
            margin: 0;

            color: #99152a;

            font-size: 26px;
            font-weight: 700;
        }

        .company-info p {
            margin: 5px 0 0;

            color: #7b8798;

            font-size: 13px;
        }

        /* =====================================================
           DOCUMENT TITLE
           ===================================================== */

        .document-title {
            margin: 25px 0 22px;
            text-align: center;
        }

        .document-title h2 {
            margin: 0;

            color: #111827;

            font-size: 22px;
            font-weight: 700;
        }

        .document-title p {
            margin: 6px 0 0;

            color: #8490a3;

            font-size: 12px;
        }

        /* =====================================================
           META INFORMATION
           ===================================================== */

        .meta-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);

            gap: 12px;

            margin-bottom: 22px;
        }

        .meta-box {
            min-height: 68px;

            padding: 13px 15px;

            background: #fafbfc;

            border: 1px solid #dfe4ea;
            border-radius: 8px;
        }

        .meta-label {
            display: block;

            margin-bottom: 5px;

            color: #758197;

            font-size: 10px;
            font-weight: 700;

            text-transform: uppercase;
        }

        .meta-value {
            display: block;

            color: #111827;

            font-size: 13px;
            font-weight: 700;
        }

        /* =====================================================
           TABLE
           ===================================================== */

        .table-container {
            width: 100%;
            overflow: hidden;

            border: 1px solid #dfe4ea;
            border-radius: 7px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        thead {
            background: #a80f26;
        }

        th {
            padding: 11px 8px;

            background: #a80f26;
            color: #ffffff;

            border-right: 1px solid rgba(255,255,255,.18);

            font-size: 11px;
            font-weight: 700;

            text-align: left;
            vertical-align: middle;
        }

        th:last-child {
            border-right: none;
        }

        td {
            padding: 10px 8px;

            border-top: 1px solid #dfe4ea;
            border-right: 1px solid #dfe4ea;

            color: #465166;

            font-size: 11px;
            line-height: 1.4;

            vertical-align: middle;

            overflow-wrap: anywhere;
        }

        td:last-child {
            border-right: none;
        }

        tbody tr:nth-child(even) {
            background: #fafbfc;
        }

        .center {
            text-align: center;
        }

        .item-code {
            font-weight: 600;
            color: #334155;
        }

        .item-name {
            font-weight: 700;
            color: #111827;
        }

        /* =====================================================
           STATUS
           ===================================================== */

        .status {
            font-weight: 700;
        }

        .available {
            color: #168653;
        }

        .low {
            color: #b07800;
        }

        .out {
            color: #c6283c;
        }

        /* =====================================================
           SUMMARY
           ===================================================== */

        .summary {
            display: flex;
            align-items: center;
            gap: 25px;

            margin-top: 16px;

            color: #667085;

            font-size: 11px;
        }

        .summary strong {
            color: #172033;
        }

        /* =====================================================
           FOOTER
           ===================================================== */

        .footer {
            margin-top: 22px;
            padding-top: 13px;

            border-top: 1px solid #e1e5eb;

            color: #8490a3;

            font-size: 10px;

            text-align: right;
        }

        /* =====================================================
           MOBILE
           ===================================================== */

        @media screen and (max-width: 800px) {

            body {
                padding: 12px;
            }

            .action-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .action-buttons {
                width: 100%;
            }

            .btn {
                flex: 1;
            }

            .document {
                padding: 20px;
            }

            .company-logo {
                width: 125px;
            }

            .company-info h1 {
                font-size: 20px;
            }

            .meta-grid {
                grid-template-columns: 1fr;
            }
        }

        /* =====================================================
           PRINT SETTINGS
           ===================================================== */

        @page {
            size: A4 landscape;
            margin: 8mm;
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

            .action-bar {
                display: none !important;
            }

            .document {
                width: 100% !important;
                max-width: none !important;

                margin: 0 !important;
                padding: 5mm !important;

                border: none !important;
                border-radius: 0 !important;
            }

            .company-header {
                gap: 15px !important;
                padding-bottom: 12px !important;
            }

            .company-logo {
                width: 135px !important;
            }

            .company-info h1 {
                font-size: 20px !important;
            }

            .company-info p {
                font-size: 10px !important;
            }

            .document-title {
                margin: 15px 0 13px !important;
            }

            .document-title h2 {
                font-size: 17px !important;
            }

            .document-title p {
                font-size: 9px !important;
            }

            .meta-grid {
                grid-template-columns: repeat(3, 1fr) !important;
                gap: 8px !important;
                margin-bottom: 13px !important;
            }

            .meta-box {
                min-height: 48px !important;
                padding: 8px 10px !important;
            }

            .meta-label {
                font-size: 8px !important;
                margin-bottom: 3px !important;
            }

            .meta-value {
                font-size: 10px !important;
            }

            table {
                width: 100% !important;
                table-layout: fixed !important;
            }

            th {
                padding: 7px 5px !important;
                font-size: 8.5px !important;
                line-height: 1.25 !important;
            }

            td {
                padding: 7px 5px !important;
                font-size: 8.5px !important;
                line-height: 1.3 !important;
            }

            thead {
                display: table-header-group;
            }

            tr {
                break-inside: avoid;
                page-break-inside: avoid;
            }

            .summary {
                margin-top: 10px !important;
                font-size: 9px !important;
            }

            .footer {
                margin-top: 12px !important;
                padding-top: 8px !important;
                font-size: 8px !important;
            }
        }

    </style>
</head>

<body>

    <div class="action-bar">

        <div class="action-title">
            <h2>Senarai Inventori</h2>
            <p>Cetak senarai inventori atau kembali ke halaman Pengurusan Inventori.</p>
        </div>

        <div class="action-buttons">

            <button
                type="button"
                class="btn btn-print"
                onclick="window.print()">
                Cetak Senarai
            </button>
""");

            // =====================================================
            // BACK BUTTON
            // =====================================================

            out.println(
                "<a class=\"btn btn-back\" href=\""
                + request.getContextPath()
                + "/inventory-admin\">Kembali</a>"
            );

            out.println("""
        </div>

    </div>


    <div class="document">

        <div class="company-header">
""");

            // =====================================================
            // LOGO
            // =====================================================

            out.println(
                "<img class=\"company-logo\" src=\""
                + request.getContextPath()
                + "/images/logo-pkb.png\" "
                + "alt=\"Logo Permodalan Kedah Berhad\">"
            );

            out.println("""
            <div class="company-info">
                <h1>Permodalan Kedah Berhad</h1>
                <p>PKB Staff Management System</p>
            </div>

        </div>


        <div class="document-title">

            <h2>Senarai Inventori</h2>

            <p>
                Rekod inventori Permodalan Kedah Berhad
            </p>

        </div>


        <div class="meta-grid">
""");

            out.println(metaBox("Dicetak Oleh", printedBy));
            out.println(metaBox("Peranan", "Pentadbir Sistem"));
            out.println(metaBox("Tarikh Cetakan", printedDate));

            out.println("""
        </div>


        <div class="table-container">

            <table>

                <thead>

                    <tr>

                        <th style="width:4%;">
                            Bil.
                        </th>

                        <th style="width:10%;">
                            Kod
                        </th>

                        <th style="width:18%;">
                            Nama Inventori
                        </th>

                        <th style="width:12%;">
                            Kategori
                        </th>

                        <th style="width:12%;">
                            Jenis
                        </th>

                        <th style="width:7%;">
                            Jumlah
                        </th>

                        <th style="width:8%;">
                            Tersedia
                        </th>

                        <th style="width:10%;">
                            Keadaan
                        </th>

                        <th style="width:9%;">
                            Lokasi
                        </th>

                        <th style="width:10%;">
                            Status
                        </th>

                    </tr>

                </thead>

                <tbody>
""");

            // =====================================================
            // TABLE DATA
            // =====================================================

            int count = 0;
            int totalQuantity = 0;
            int totalAvailable = 0;

            while (rs.next()) {

                count++;

                String itemCode = safe(rs.getString("item_code"));
                String itemName = safe(rs.getString("item_name"));
                String category = safe(rs.getString("category"));
                String itemType = safe(rs.getString("item_type"));

                int quantity = rs.getInt("quantity");
                int availableQuantity = rs.getInt("available_quantity");

                String condition = safe(rs.getString("item_condition"));
                String location = safe(rs.getString("location"));
                String status = normalize(rs.getString("status"));

                totalQuantity += quantity;
                totalAvailable += availableQuantity;

                out.println("<tr>");

                out.println(
                    "<td class=\"center\">"
                    + count
                    + "</td>"
                );

                out.println(
                    "<td class=\"item-code\">"
                    + escape(itemCode)
                    + "</td>"
                );

                out.println(
                    "<td class=\"item-name\">"
                    + escape(itemName)
                    + "</td>"
                );

                out.println(
                    "<td>"
                    + escape(category)
                    + "</td>"
                );

                out.println(
                    "<td>"
                    + escape(itemTypeLabel(itemType))
                    + "</td>"
                );

                out.println(
                    "<td class=\"center\">"
                    + quantity
                    + "</td>"
                );

                out.println(
                    "<td class=\"center\">"
                    + availableQuantity
                    + "</td>"
                );

                out.println(
                    "<td>"
                    + escape(conditionLabel(condition))
                    + "</td>"
                );

                out.println(
                    "<td>"
                    + escape(
                        location.isBlank()
                            ? "—"
                            : location
                    )
                    + "</td>"
                );

                out.println(
                    "<td class=\"status "
                    + stockStatusClass(status)
                    + "\">"
                    + escape(stockStatusLabel(status))
                    + "</td>"
                );

                out.println("</tr>");
            }

            // =====================================================
            // EMPTY TABLE
            // =====================================================

            if (count == 0) {

                out.println("""
                    <tr>
                        <td
                            colspan="10"
                            style="
                                text-align:center;
                                padding:25px;
                            ">
                            Tiada rekod inventori.
                        </td>
                    </tr>
                """);
            }

            out.println("""
                </tbody>

            </table>

        </div>
""");

            // =====================================================
            // SUMMARY
            // =====================================================

            out.println(
                "<div class=\"summary\">"

                + "<span><strong>Jumlah Rekod:</strong> "
                + count
                + "</span>"

                + "<span><strong>Jumlah Unit:</strong> "
                + totalQuantity
                + "</span>"

                + "<span><strong>Unit Tersedia:</strong> "
                + totalAvailable
                + "</span>"

                + "</div>"
            );

            // =====================================================
            // FOOTER
            // =====================================================

            out.println("""
        <div class="footer">
            Dijana oleh PKB Staff Management System
        </div>

    </div>

</body>
</html>
""");

            // =====================================================
            // AUDIT LOG
            // =====================================================

            try {

                ActivityLogUtil.log(
                    con,
                    request,
                    "PRINT_INVENTORY_LIST",
                    "Mencetak senarai inventori",
                    "INVENTORY",
                    null
                );

            } catch (SQLException e) {
                e.printStackTrace();
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menyediakan senarai inventori untuk cetakan.",
                e
            );
        }
    }


    // =============================================================
    // HELPERS
    // =============================================================

    private String safe(String value) {

        return value == null
                ? ""
                : value.trim();
    }


    private String normalize(String value) {

        return value == null
                ? ""
                : value.trim().toUpperCase();
    }


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


    private String itemTypeLabel(String type) {

        if ("ASSET".equalsIgnoreCase(type)) {
            return "Aset";
        }

        if ("CONSUMABLE".equalsIgnoreCase(type)) {
            return "Bahan Guna Habis";
        }

        return type;
    }


    private String conditionLabel(String condition) {

        if (condition == null || condition.isBlank()) {
            return "—";
        }

        switch (condition.trim().toUpperCase()) {

            case "GOOD":
                return "Baik";

            case "FAIR":
                return "Sederhana";

            case "DAMAGED":
                return "Rosak";

            case "POOR":
                return "Kurang Baik";

            default:
                return condition;
        }
    }


    private String stockStatusLabel(String status) {

        switch (status) {

            case "AVAILABLE":
                return "Tersedia";

            case "LOW_STOCK":
                return "Stok Rendah";

            case "OUT_OF_STOCK":
                return "Stok Habis";

            default:
                return status;
        }
    }


    private String stockStatusClass(String status) {

        switch (status) {

            case "AVAILABLE":
                return "available";

            case "LOW_STOCK":
                return "low";

            case "OUT_OF_STOCK":
                return "out";

            default:
                return "";
        }
    }


    private String metaBox(
            String label,
            String value) {

        return
            "<div class=\"meta-box\">"
            + "<span class=\"meta-label\">"
            + escape(label)
            + "</span>"
            + "<span class=\"meta-value\">"
            + escape(value)
            + "</span>"
            + "</div>";
    }
}