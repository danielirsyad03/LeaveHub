<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeSet" %>

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

    private String jsEscape(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n")
                .replace("</", "<\\/");
    }
%>

<%
    // =========================================================
    // SESSION
    // =========================================================

    String role = (String) session.getAttribute("userRole");
    String name = (String) session.getAttribute("userName");

    if (name == null || name.isBlank()) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }


    // =========================================================
    // INVENTORY DATA
    // =========================================================

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> items =
            (List<Map<String, Object>>) request.getAttribute("items");

    int totalItems = 0;
    int availableItems = 0;
    int lowStockItems = 0;
    int outOfStockItems = 0;

    Set<String> categories =
            new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);

    Set<String> locations =
            new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);


    // =========================================================
    // CALCULATE INVENTORY SUMMARY
    // =========================================================

    if (items != null) {

        totalItems = items.size();

        for (Map<String, Object> item : items) {

            String itemStatus =
                    item.get("status") == null
                            ? ""
                            : String.valueOf(item.get("status"));

            if ("AVAILABLE".equalsIgnoreCase(itemStatus)) {
                availableItems++;
            }
            else if ("LOW_STOCK".equalsIgnoreCase(itemStatus)) {
                lowStockItems++;
            }
            else if ("OUT_OF_STOCK".equalsIgnoreCase(itemStatus)) {
                outOfStockItems++;
            }


            // CATEGORY FILTER

            if (item.get("category") != null) {

                String category =
                        String.valueOf(
                            item.get("category")
                        ).trim();

                if (!category.isBlank()) {
                    categories.add(category);
                }
            }


            // LOCATION FILTER

            if (item.get("location") != null) {

                String location =
                        String.valueOf(
                            item.get("location")
                        ).trim();

                if (!location.isBlank()) {
                    locations.add(location);
                }
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

    <title>Inventori - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260927-inventory-v4"
    >


    <style>

        /* =========================================================
           GLOBAL
           NO HORIZONTAL SCROLL
        ========================================================= */

        html,
        body {
            width: 100%;
            max-width: 100%;

            margin: 0;
            padding: 0;

            overflow-x: hidden !important;
            overflow-y: auto;
        }

        body {
            min-width: 0 !important;
        }

        *,
        *::before,
        *::after {
            box-sizing: border-box;
        }

        img,
        svg {
            max-width: 100%;
        }

        .app {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            overflow-x: hidden !important;
        }

        main {
            min-width: 0 !important;
            max-width: 100% !important;

            overflow-x: hidden !important;
        }


        /* =========================================================
           INVENTORY PAGE
        ========================================================= */

        .inventory-page {
            width: 100%;
            max-width: 1400px;
            min-width: 0;

            margin: 0 auto;

            overflow-x: hidden;
        }

        .inventory-page * {
            box-sizing: border-box;
        }


        /* =========================================================
           PAGE HEADER
        ========================================================= */

        .inventory-page-header {
            width: 100%;
            min-width: 0;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 20px;
        }

        .inventory-page-title {
            min-width: 0;
        }

        .inventory-page-title h1 {
            margin: 0 0 5px;

            color: #172033;

            font-size: 26px;
            line-height: 1.25;
            font-weight: 700;

            letter-spacing: -.25px;
        }

        .inventory-page-title p {
            margin: 0;

            color: #8790a0;

            font-size: 13px;
            line-height: 1.5;
            font-weight: 400;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           USER
        ========================================================= */

        .inventory-user {
            flex: 0 0 auto;

            display: flex;
            align-items: center;

            gap: 9px;

            padding: 7px 11px;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 10px;

            box-shadow:
                0 3px 10px rgba(24, 32, 48, .035);
        }

        .inventory-user-avatar {
            width: 31px;
            height: 31px;

            flex: 0 0 31px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 8px;

            background: #fff5f6;

            border: 1px solid #efdadd;

            color: #8d1f2d;

            font-size: 12px;
            font-weight: 700;
        }

        .inventory-user-name {
            max-width: 200px;

            color: #384255;

            font-size: 12px;
            font-weight: 600;

            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }


        /* =========================================================
           SUMMARY
        ========================================================= */

        .inventory-summary {
            width: 100%;
            min-width: 0;

            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 13px;

            margin-bottom: 19px;
        }

        .inventory-summary-card {
            position: relative;

            width: 100%;
            min-width: 0;
            min-height: 90px;

            display: flex;
            align-items: center;

            gap: 13px;

            padding: 15px 16px;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 13px;

            box-shadow:
                0 4px 15px rgba(28, 37, 54, .04);

            overflow: hidden;
        }

        .inventory-summary-card::before {
            content: "";

            position: absolute;

            left: 0;
            top: 0;
            bottom: 0;

            width: 3px;

            background: #8d1f2d;
        }

        .inventory-summary-card.summary-available::before {
            background: #2d8a61;
        }

        .inventory-summary-card.summary-low::before {
            background: #d29a22;
        }

        .inventory-summary-card.summary-out::before {
            background: #c23948;
        }


        /* =========================================================
           SUMMARY ICON
        ========================================================= */

        .summary-icon {
            width: 42px;
            height: 42px;

            flex: 0 0 42px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 10px;

            background: #faf0f2;

            border: 1px solid #f0dce0;

            color: #8d1f2d;
        }

        .summary-available .summary-icon {
            background: #eef8f3;

            border-color: #d7ecdf;

            color: #25855a;
        }

        .summary-low .summary-icon {
            background: #fff7e9;

            border-color: #f2e1bd;

            color: #b87b0b;
        }

        .summary-out .summary-icon {
            background: #fff1f3;

            border-color: #efd7db;

            color: #ba3443;
        }

        .summary-icon svg {
            width: 19px;
            height: 19px;
        }


        /* =========================================================
           SUMMARY CONTENT
        ========================================================= */

        .summary-content {
            min-width: 0;
        }

        .summary-content span {
            display: block;

            margin-bottom: 3px;

            color: #8992a2;

            font-size: 10px;
            font-weight: 600;

            letter-spacing: .25px;

            text-transform: uppercase;

            overflow-wrap: anywhere;
        }

        .summary-content strong {
            display: block;

            color: #1e293b;

            font-size: 21px;
            line-height: 1.05;
            font-weight: 700;
        }

        .summary-content small {
            display: block;

            margin-top: 4px;

            color: #9aa2b0;

            font-size: 10px;
            font-weight: 400;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           INVENTORY CARD
        ========================================================= */

        .inventory-card {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 15px;

            box-shadow:
                0 6px 22px rgba(29, 39, 57, .045);

            overflow: hidden;
        }


        /* =========================================================
           CARD HEADER
        ========================================================= */

        .inventory-card-header {
            width: 100%;
            min-width: 0;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 18px;

            padding: 18px 20px;

            border-bottom: 1px solid #eceef2;
        }

        .inventory-heading {
            min-width: 0;
        }

        .inventory-heading h2 {
            margin: 0 0 4px;

            color: #1f2937;

            font-size: 17px;
            font-weight: 650;
        }

        .inventory-heading p {
            margin: 0;

            color: #9098a6;

            font-size: 12px;
            line-height: 1.5;
            font-weight: 400;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           TOOLBAR
        ========================================================= */

        .inventory-toolbar {
            width: 100%;
            min-width: 0;

            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 12px;

            padding: 12px 18px;

            background: #fafbfc;

            border-bottom: 1px solid #eceef2;
        }

        .inventory-toolbar-left {
            flex: 1 1 auto;

            min-width: 0;

            display: flex;
            align-items: center;
            flex-wrap: wrap;

            gap: 8px;
        }


        /* =========================================================
           SEARCH
        ========================================================= */

        .inventory-search {
            position: relative;

            flex: 1 1 230px;

            width: auto;
            min-width: 160px;
            max-width: 300px;
        }

        .inventory-search svg {
            position: absolute;

            top: 50%;
            left: 12px;

            width: 16px;
            height: 16px;

            color: #98a1af;

            transform: translateY(-50%);

            pointer-events: none;
        }

        .inventory-search input {
            width: 100%;
            max-width: 100%;
            height: 38px;

            padding: 0 12px 0 37px;

            background: #ffffff;

            border: 1px solid #dde1e7;
            border-radius: 8px;

            outline: none;

            color: #465064;

            font-size: 12px;
            font-weight: 400;

            transition:
                border-color .15s ease,
                box-shadow .15s ease;
        }

        .inventory-search input::placeholder {
            color: #a0a7b4;
        }

        .inventory-search input:focus {
            border-color: #a44a56;

            box-shadow:
                0 0 0 3px rgba(141, 31, 45, .06);
        }


        /* =========================================================
           FILTER
        ========================================================= */

        .filter-select {
            flex: 1 1 125px;

            width: auto;
            min-width: 110px;
            max-width: 160px;

            height: 38px;

            padding: 0 27px 0 10px;

            background: #ffffff;

            border: 1px solid #dde1e7;
            border-radius: 8px;

            outline: none;

            color: #5e687a;

            font-size: 11px;
            font-weight: 500;

            cursor: pointer;
        }

        .filter-select:focus {
            border-color: #a44a56;
        }


        /* =========================================================
           RESET
        ========================================================= */

        .reset-filter-btn {
            flex: 0 0 auto;

            height: 38px;

            padding: 0 12px;

            background: #ffffff;

            border: 1px solid #dde1e7;
            border-radius: 8px;

            color: #697386;

            font-size: 11px;
            font-weight: 600;

            cursor: pointer;

            transition: .15s ease;
        }

        .reset-filter-btn:hover {
            background: #fffafb;

            border-color: #d7b5ba;

            color: #8d1f2d;
        }


        /* =========================================================
           RESULT COUNT
        ========================================================= */

        .inventory-result-count {
            flex: 0 0 auto;

            color: #929aa8;

            font-size: 11px;

            white-space: nowrap;
        }

        .inventory-result-count strong {
            color: #8d1f2d;

            font-weight: 650;
        }


        /* =========================================================
           ERROR
        ========================================================= */

        .inventory-error {
            margin: 14px 18px;

            padding: 11px 13px;

            background: #fff1f3;

            border: 1px solid #efd2d7;
            border-radius: 8px;

            color: #a42e3a;

            font-size: 12px;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           TABLE WRAPPER
           IMPORTANT: NO HORIZONTAL SCROLL
        ========================================================= */

        .inventory-table-wrapper {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            overflow-x: hidden !important;
            overflow-y: visible;
        }


        /* =========================================================
           TABLE
        ========================================================= */

        .inventory-table {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;

            border-collapse: collapse;

            table-layout: fixed;
        }

        .inventory-table th,
        .inventory-table td {
            min-width: 0;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .inventory-table thead th {
            padding: 12px 8px;

            background: #f8f9fb;

            border-bottom: 1px solid #e7eaee;

            color: #7d8797;

            font-size: 10px;
            line-height: 1.3;
            font-weight: 600;

            letter-spacing: .12px;

            text-align: left;
            text-transform: uppercase;

            white-space: normal;
        }

        .inventory-table tbody td {
            padding: 14px 8px;

            border-bottom: 1px solid #edf0f3;

            color: #5c6678;

            font-size: 12px;
            line-height: 1.45;
            font-weight: 400;

            vertical-align: middle;

            white-space: normal;
        }


        /* =========================================================
           8 COLUMN WIDTHS
           TOTAL = 100%
        ========================================================= */

        .inventory-table th:nth-child(1),
        .inventory-table td:nth-child(1) {
            width: 9%;
        }

        .inventory-table th:nth-child(2),
        .inventory-table td:nth-child(2) {
            width: 21%;
        }

        .inventory-table th:nth-child(3),
        .inventory-table td:nth-child(3) {
            width: 12%;
        }

        .inventory-table th:nth-child(4),
        .inventory-table td:nth-child(4) {
            width: 13%;
        }

        .inventory-table th:nth-child(5),
        .inventory-table td:nth-child(5) {
            width: 10%;
        }

        .inventory-table th:nth-child(6),
        .inventory-table td:nth-child(6) {
            width: 10%;
        }

        .inventory-table th:nth-child(7),
        .inventory-table td:nth-child(7) {
            width: 11%;
        }

        .inventory-table th:nth-child(8),
        .inventory-table td:nth-child(8) {
            width: 14%;
        }

        .inventory-table tbody tr {
            transition:
                background .15s ease;
        }

        .inventory-table tbody tr:hover {
            background: #fdfbfb;
        }

        .inventory-table tbody tr:last-child td {
            border-bottom: none;
        }


        /* =========================================================
           ITEM CODE
        ========================================================= */

        .item-code {
            display: inline-flex;
            align-items: flex-start;

            gap: 6px;

            max-width: 100%;

            color: #3e485a;

            font-size: 13px;
            line-height: 1.35;
            font-weight: 600;

            white-space: normal;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .item-code::before {
            content: "";

            width: 5px;
            height: 5px;

            flex: 0 0 5px;

            margin-top: 4px;

            background: #d4a63a;

            border-radius: 50%;
        }


        /* =========================================================
           ITEM INFORMATION
        ========================================================= */

        .item-info {
            width: 100%;
            min-width: 0;
            max-width: 100%;
        }

        .item-info strong {
            display: block;

            margin-bottom: 4px;

            color: #273246;

            font-size: 13px;
            line-height: 1.35;
            font-weight: 600;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .item-info small {
            display: block;

            color: #929aa8;

            font-size: 8.5px;
            line-height: 1.45;
            font-weight: 400;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .item-brand {
            display: block;

            margin-top: 2px;

            color: #7d8797;

            font-size: 10.5px;
            line-height: 1.4;
            font-weight: 500;

            overflow-wrap: anywhere;
            word-break: break-word;
        }


        /* =========================================================
           CATEGORY
        ========================================================= */

        .category-label {
            display: block;

            max-width: 100%;

            color: #616c7f;

            font-size: 11.5px;
            line-height: 1.4;
            font-weight: 400;

            overflow-wrap: anywhere;
            word-break: break-word;
        }


        /* =========================================================
           VARIATION
        ========================================================= */

        .item-variation {
            width: 100%;
            min-width: 0;
        }

        .variation-line {
            display: block;

            margin-bottom: 5px;

            color: #596476;

            font-size: 9.5px;
            line-height: 1.3;

            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .variation-line:last-child {
            margin-bottom: 0;
        }

        .variation-label {
            display: block;

            margin-bottom: 1px;

            color: #9aa2b0;

            font-size: 8.5px;
            line-height: 1.2;
            font-weight: 600;

            letter-spacing: .15px;

            text-transform: uppercase;
        }

        .variation-value {
            display: block;

            color: #4d586b;

            font-size: 11px;
            font-weight: 500;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           STOCK
        ========================================================= */

        .stock-cell {
            width: 100%;
            min-width: 0;
        }

        .stock-main {
            display: flex;
            align-items: baseline;
            flex-wrap: wrap;

            gap: 4px;
        }

        .stock-main strong {
            color: #8d1f2d;

            font-size: 15px;
            line-height: 1;
            font-weight: 650;
        }

        .stock-main span {
            color: #657084;

            font-size: 10.5px;
            font-weight: 500;

            overflow-wrap: anywhere;
        }

        .stock-total {
            display: block;

            margin-top: 4px;

            color: #9ca4b1;

            font-size: 9.5px;
            line-height: 1.3;
            font-weight: 400;

            overflow-wrap: anywhere;
        }


        /* =========================================================
           LOCATION
        ========================================================= */

        .location-text {
            display: block;

            max-width: 100%;

            color: #616c7f;

            font-size: 11.5px;
            line-height: 1.4;
            font-weight: 400;

            overflow-wrap: anywhere;
            word-break: break-word;
        }


        /* =========================================================
           STATUS
        ========================================================= */

        .inventory-status {
            display: inline-flex;
            align-items: center;

            gap: 5px;

            max-width: 100%;

            padding: 6px 9px;

            border-radius: 999px;

            font-size: 10px;
            line-height: 1.25;
            font-weight: 600;

            white-space: normal;

            overflow-wrap: anywhere;
        }

        .inventory-status::before {
            content: "";

            width: 5px;
            height: 5px;

            flex: 0 0 5px;

            border-radius: 50%;
        }

        .inventory-status.available {
            background: #edf8f2;

            border: 1px solid #d3ebdf;

            color: #24734e;
        }

        .inventory-status.available::before {
            background: #27865b;
        }

        .inventory-status.low-stock {
            background: #fff6e6;

            border: 1px solid #eeddb8;

            color: #8e6516;
        }

        .inventory-status.low-stock::before {
            background: #c68b18;
        }

        .inventory-status.out-of-stock {
            background: #fff1f3;

            border: 1px solid #efd1d6;

            color: #a72e3a;
        }

        .inventory-status.out-of-stock::before {
            background: #ba3443;
        }


        /* =========================================================
           ACTION BUTTONS
        ========================================================= */

        .inventory-actions {
            width: 100%;
            min-width: 0;

            display: flex;
            align-items: center;
            flex-wrap: wrap;

            gap: 5px;

            white-space: normal;
        }

        .btn-view,
        .btn-request,
        .btn-disabled {
            min-height: 34px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            padding: 7px 11px;

            border-radius: 7px;

            font-size: 11px;
            line-height: 1.2;
            font-weight: 600;

            text-align: center;
            text-decoration: none;

            white-space: normal;

            transition: .15s ease;
        }

        .btn-view {
            background: #ffffff;

            border: 1px solid #d9dde4;

            color: #596476;

            cursor: pointer;
        }

        .btn-view:hover {
            background: #f8f9fb;

            border-color: #c4c9d1;

            color: #313b4d;
        }

        .btn-request {
            background: #8d1f2d;

            border: 1px solid #8d1f2d;

            color: #ffffff !important;

            box-shadow:
                0 2px 6px rgba(141, 31, 45, .12);
        }

        .btn-request:hover {
            background: #761824;

            border-color: #761824;
        }

        .btn-disabled {
            background: #f5f6f7;

            border: 1px solid #e3e6ea;

            color: #999faa;
        }


        /* =========================================================
           EMPTY STATE
        ========================================================= */

        .inventory-empty {
            padding: 50px 20px !important;

            text-align: center;
        }

        .inventory-empty-icon {
            width: 45px;
            height: 45px;

            display: flex;
            align-items: center;
            justify-content: center;

            margin: 0 auto 11px;

            border-radius: 12px;

            background: #fff5f6;

            color: #8d1f2d;
        }

        .inventory-empty-icon svg {
            width: 21px;
            height: 21px;
        }

        .inventory-empty strong {
            display: block;

            color: #414b5e;

            font-size: 13px;
            font-weight: 600;
        }

        .inventory-empty p {
            margin: 5px 0 0;

            color: #929aa8;

            font-size: 11px;
            line-height: 1.5;
        }


        /* =========================================================
           NO SEARCH RESULT
        ========================================================= */

        .no-search-result {
            display: none;

            padding: 35px 20px;

            text-align: center;

            border-top: 1px solid #edf0f3;
        }

        .no-search-result strong {
            display: block;

            margin-bottom: 4px;

            color: #465064;

            font-size: 13px;
            font-weight: 600;
        }

        .no-search-result span {
            color: #929aa8;

            font-size: 11px;
        }


        /* =========================================================
           MODAL OVERLAY
        ========================================================= */

        .inventory-modal-overlay {
            position: fixed;

            inset: 0;

            z-index: 99999;

            display: none;
            align-items: center;
            justify-content: center;

            width: 100%;
            max-width: 100%;

            padding: 22px;

            background: rgba(20, 25, 35, .50);

            backdrop-filter: blur(3px);

            overflow-x: hidden;
            overflow-y: auto;
        }

        .inventory-modal-overlay.show {
            display: flex;
        }


        /* =========================================================
           MODAL
        ========================================================= */

        .inventory-modal {
            width: min(720px, 100%);
            max-width: 100%;
            min-width: 0;

            max-height: calc(100vh - 44px);

            overflow-x: hidden;
            overflow-y: auto;

            background: #ffffff;

            border-radius: 15px;

            box-shadow:
                0 24px 65px rgba(17, 24, 39, .22);

            animation:
                inventoryModalIn .18s ease;
        }

        @keyframes inventoryModalIn {

            from {
                opacity: 0;

                transform:
                    translateY(7px)
                    scale(.985);
            }

            to {
                opacity: 1;

                transform:
                    translateY(0)
                    scale(1);
            }
        }


        /* =========================================================
           MODAL HEADER
        ========================================================= */

        .modal-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;

            gap: 15px;

            padding: 18px 20px 16px;

            border-bottom: 1px solid #eceef2;
        }

        .modal-title-area {
            min-width: 0;
        }

        .modal-code {
            display: block;

            margin-bottom: 4px;

            color: #ad8222;

            font-size: 10px;
            font-weight: 600;

            letter-spacing: .4px;

            text-transform: uppercase;

            overflow-wrap: anywhere;
        }

        .modal-title-area h3 {
            margin: 0;

            color: #202a3c;

            font-size: 18px;
            line-height: 1.3;
            font-weight: 650;

            overflow-wrap: anywhere;
        }

        .modal-title-area .inventory-status {
            margin-top: 9px;
        }

        .modal-close {
            width: 33px;
            height: 33px;

            flex: 0 0 33px;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #f7f8f9;

            border: 1px solid #e4e7eb;
            border-radius: 8px;

            color: #697386;

            font-size: 18px;
            font-weight: 400;

            cursor: pointer;
        }

        .modal-close:hover {
            background: #eef0f3;

            color: #313949;
        }


        /* =========================================================
           MODAL BODY
        ========================================================= */

        .modal-body {
            padding: 19px 20px;
        }

        .detail-section {
            margin-bottom: 20px;
        }

        .detail-section:last-child {
            margin-bottom: 0;
        }

        .detail-section-title {
            display: flex;
            align-items: center;

            gap: 7px;

            margin: 0 0 10px;

            color: #354052;

            font-size: 12px;
            font-weight: 600;
        }

        .detail-section-title::before {
            content: "";

            width: 3px;
            height: 13px;

            border-radius: 3px;

            background: #8d1f2d;
        }


        /* =========================================================
           DETAIL GRID
        ========================================================= */

        .detail-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 9px;
        }

        .detail-box {
            min-width: 0;

            padding: 11px 12px;

            background: #fafbfc;

            border: 1px solid #e8ebef;
            border-radius: 8px;
        }

        .detail-box label {
            display: block;

            margin-bottom: 4px;

            color: #969eab;

            font-size: 9px;
            font-weight: 600;

            letter-spacing: .25px;

            text-transform: uppercase;
        }

        .detail-box span {
            display: block;

            color: #4c5668;

            font-size: 12px;
            line-height: 1.45;
            font-weight: 500;

            overflow-wrap: anywhere;
            word-break: break-word;
        }


        /* =========================================================
           STOCK OVERVIEW
        ========================================================= */

        .stock-overview {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 9px;
        }

        .stock-overview-box {
            min-width: 0;

            padding: 14px;

            background: #fffafb;

            border: 1px solid #eadadd;
            border-radius: 9px;
        }

        .stock-overview-box label {
            display: block;

            margin-bottom: 5px;

            color: #929aa8;

            font-size: 9px;
            font-weight: 600;

            text-transform: uppercase;
        }

        .stock-overview-box strong {
            color: #8d1f2d;

            font-size: 21px;
            font-weight: 650;
        }

        .stock-overview-box span {
            margin-left: 3px;

            color: #6f798a;

            font-size: 11px;
            font-weight: 500;
        }


        /* =========================================================
           DESCRIPTION
        ========================================================= */

        .description-box {
            padding: 12px 13px;

            background: #fafbfc;

            border: 1px solid #e8ebef;
            border-radius: 8px;

            color: #596476;

            font-size: 12px;
            line-height: 1.6;
            font-weight: 400;

            white-space: pre-line;

            overflow-wrap: anywhere;
            word-break: break-word;
        }


        /* =========================================================
           MODAL FOOTER
        ========================================================= */

        .modal-footer {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            flex-wrap: wrap;

            gap: 7px;

            padding: 14px 20px;

            background: #fafbfc;

            border-top: 1px solid #eceef2;
        }

        .btn-close-footer {
            min-height: 34px;

            padding: 7px 14px;

            background: #ffffff;

            border: 1px solid #d9dde4;
            border-radius: 7px;

            color: #5e687a;

            font-size: 11px;
            font-weight: 600;

            cursor: pointer;
        }

        .modal-footer .btn-request {
            min-height: 34px;

            padding-left: 14px;
            padding-right: 14px;

            font-size: 11px;
        }

        @media (max-width: 1150px) {

            .inventory-toolbar {
                align-items: flex-start;
                flex-direction: column;
            }

            .inventory-toolbar-left {
                width: 100%;
            }

            .inventory-result-count {
                width: 100%;
                text-align: right;
            }

            .inventory-table thead th {
                padding-left: 5px;
                padding-right: 5px;
                font-size: 9.5px;
            }

            .inventory-table tbody td {
                padding-left: 6px;
                padding-right: 6px;
                font-size: 11px;
            }

            .item-info strong {
                font-size: 10.5px;
            }

            .inventory-status {
                padding-left: 7px;
                padding-right: 7px;
                font-size: 9.5px;
            }

            .btn-view,
            .btn-request,
            .btn-disabled {
                padding-left: 9px;
                padding-right: 9px;
                font-size: 10.5px;
            }
        }


        /* =========================================================
           RESPONSIVE - TABLET
           HIDE LOCATION FIRST
        ========================================================= */

        @media (max-width: 1000px) {

            .inventory-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }


            /* -----------------------------------------
               LOCATION COLUMN = COLUMN 6
            ----------------------------------------- */

            .inventory-table th:nth-child(6),
            .inventory-table td:nth-child(6) {
                display: none;
            }


            /* -----------------------------------------
               RECALCULATE WIDTHS
            ----------------------------------------- */

            .inventory-table th:nth-child(1),
            .inventory-table td:nth-child(1) {
                width: 11%;
            }

            .inventory-table th:nth-child(2),
            .inventory-table td:nth-child(2) {
                width: 24%;
            }

            .inventory-table th:nth-child(3),
            .inventory-table td:nth-child(3) {
                width: 13%;
            }

            .inventory-table th:nth-child(4),
            .inventory-table td:nth-child(4) {
                width: 14%;
            }

            .inventory-table th:nth-child(5),
            .inventory-table td:nth-child(5) {
                width: 11%;
            }

            .inventory-table th:nth-child(7),
            .inventory-table td:nth-child(7) {
                width: 12%;
            }

            .inventory-table th:nth-child(8),
            .inventory-table td:nth-child(8) {
                width: 15%;
            }
        }


        /* =========================================================
           RESPONSIVE - SMALL TABLET
        ========================================================= */

        @media (max-width: 760px) {

            .inventory-page-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .inventory-user {
                display: none;
            }

            .inventory-summary {
                grid-template-columns: 1fr;
            }


            /* -----------------------------------------
               TOOLBAR
            ----------------------------------------- */

            .inventory-toolbar-left {
                flex-direction: column;
                align-items: stretch;
            }

            .inventory-search,
            .filter-select,
            .reset-filter-btn {
                flex: none;

                width: 100%;
                max-width: none;
                min-width: 0;
            }

            .inventory-result-count {
                text-align: left;
            }


            /* -----------------------------------------
               HIDE CATEGORY = COLUMN 3

               LOCATION = COLUMN 6
               ALREADY HIDDEN
            ----------------------------------------- */

            .inventory-table th:nth-child(3),
            .inventory-table td:nth-child(3) {
                display: none;
            }


            /* -----------------------------------------
               RECALCULATE WIDTHS
            ----------------------------------------- */

            .inventory-table th:nth-child(1),
            .inventory-table td:nth-child(1) {
                width: 14%;
            }

            .inventory-table th:nth-child(2),
            .inventory-table td:nth-child(2) {
                width: 28%;
            }

            .inventory-table th:nth-child(4),
            .inventory-table td:nth-child(4) {
                width: 17%;
            }

            .inventory-table th:nth-child(5),
            .inventory-table td:nth-child(5) {
                width: 13%;
            }

            .inventory-table th:nth-child(7),
            .inventory-table td:nth-child(7) {
                width: 13%;
            }

            .inventory-table th:nth-child(8),
            .inventory-table td:nth-child(8) {
                width: 15%;
            }


            /* -----------------------------------------
               SMALLER TABLE TEXT
            ----------------------------------------- */

            .inventory-table thead th {
                padding: 9px 4px;

                font-size: 7px;
            }

            .inventory-table tbody td {
                padding: 10px 4px;

                font-size: 9px;
            }

            .item-info strong {
                font-size: 10px;
            }

            .item-brand {
                font-size: 8px;
            }

            .item-code {
                font-size: 8px;
            }

            .variation-label {
                font-size: 7px;
            }

            .variation-value {
                font-size: 8px;
            }

            .stock-main strong {
                font-size: 12px;
            }

            .stock-main span,
            .stock-total {
                font-size: 7.5px;
            }

            .inventory-status {
                padding: 4px 5px;

                font-size: 7.5px;
            }

            .btn-view,
            .btn-request,
            .btn-disabled {
                width: 100%;

                min-height: 27px;

                padding: 4px;

                font-size: 7.5px;
            }


            /* -----------------------------------------
               MODAL
            ----------------------------------------- */

            .detail-grid,
            .stock-overview {
                grid-template-columns: 1fr;
            }

            .inventory-modal-overlay {
                padding: 11px;
            }

            .modal-header,
            .modal-body,
            .modal-footer {
                padding-left: 15px;
                padding-right: 15px;
            }
        }


        /* =========================================================
           RESPONSIVE - PHONE
        ========================================================= */

        @media (max-width: 520px) {

            .inventory-page-title h1 {
                font-size: 22px;
            }

            .inventory-card-header {
                padding: 15px;
            }

            .inventory-toolbar {
                padding: 12px 15px;
            }


            /* -----------------------------------------
               HIDE CODE = COLUMN 1

               CATEGORY = COLUMN 3
               LOCATION = COLUMN 6
               ALREADY HIDDEN
            ----------------------------------------- */

            .inventory-table th:nth-child(1),
            .inventory-table td:nth-child(1) {
                display: none;
            }


            /* -----------------------------------------
               RECALCULATE WIDTHS
            ----------------------------------------- */

            .inventory-table th:nth-child(2),
            .inventory-table td:nth-child(2) {
                width: 32%;
            }

            .inventory-table th:nth-child(4),
            .inventory-table td:nth-child(4) {
                width: 20%;
            }

            .inventory-table th:nth-child(5),
            .inventory-table td:nth-child(5) {
                width: 15%;
            }

            .inventory-table th:nth-child(7),
            .inventory-table td:nth-child(7) {
                width: 15%;
            }

            .inventory-table th:nth-child(8),
            .inventory-table td:nth-child(8) {
                width: 18%;
            }
        }


        /* =========================================================
           RESPONSIVE - EXTRA SMALL PHONE
        ========================================================= */

        @media (max-width: 390px) {

            /*
             * STATUS CAN STILL BE VIEWED
             * THROUGH THE "LIHAT" MODAL.
             */

            .inventory-table th:nth-child(7),
            .inventory-table td:nth-child(7) {
                display: none;
            }


            .inventory-table th:nth-child(2),
            .inventory-table td:nth-child(2) {
                width: 40%;
            }

            .inventory-table th:nth-child(4),
            .inventory-table td:nth-child(4) {
                width: 23%;
            }

            .inventory-table th:nth-child(5),
            .inventory-table td:nth-child(5) {
                width: 17%;
            }

            .inventory-table th:nth-child(8),
            .inventory-table td:nth-child(8) {
                width: 20%;
            }
        }


        /* =========================================================
           FINAL OVERFLOW PROTECTION
        ========================================================= */

        html,
        body,
        .app,
        main,
        .inventory-page,
        .inventory-card,
        .inventory-table-wrapper {
            max-width: 100% !important;

            overflow-x: hidden !important;
        }

        .inventory-table {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 0 !important;

            table-layout: fixed !important;
        }


    </style>

</head>


<body>


<div class="app">


    <!-- =========================================================
         SIDEBAR
    ========================================================== -->

    <%@ include file="includes/sidebar.jspf" %>


    <!-- =========================================================
         MAIN
    ========================================================== -->

    <main>


        <div class="inventory-page">


            <!-- =================================================
                 PAGE HEADER
            ================================================== -->

            <div class="inventory-page-header">


                <div class="inventory-page-title">

                    <h1>
                        Inventori
                    </h1>

                    <p>
                        Semak maklumat dan ketersediaan inventori syarikat
                        sebelum membuat permohonan.
                    </p>

                </div>


                <div class="inventory-user">


                    <div class="inventory-user-avatar">

                        <%= htmlEscape(
                            name.substring(0, 1).toUpperCase()
                        ) %>

                    </div>


                    <span class="inventory-user-name">

                        <%= htmlEscape(name) %>

                    </span>


                </div>


            </div>


            <!-- =================================================
                 INVENTORY SUMMARY
            ================================================== -->

            <div class="inventory-summary">


                <!-- =============================================
                     TOTAL INVENTORY
                ============================================== -->

                <div class="inventory-summary-card">


                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <path
                                d="M4 7.5 12 3l8 4.5-8 4.5-8-4.5Z"
                            />

                            <path
                                d="M4 7.5V16l8 5 8-5V7.5"
                            />

                            <path
                                d="M12 12v9"
                            />
                        </svg>

                    </div>


                    <div class="summary-content">

                        <span>
                            Jumlah Inventori
                        </span>

                        <strong>
                            <%= totalItems %>
                        </strong>

                        <small>
                            Item direkodkan
                        </small>

                    </div>


                </div>


                <!-- =============================================
                     AVAILABLE
                ============================================== -->

                <div
                    class="
                        inventory-summary-card
                        summary-available
                    "
                >


                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <path
                                d="m5 12 4 4L19 6"
                            />
                        </svg>

                    </div>


                    <div class="summary-content">

                        <span>
                            Tersedia
                        </span>

                        <strong>
                            <%= availableItems %>
                        </strong>

                        <small>
                            Stok mencukupi
                        </small>

                    </div>


                </div>


                <!-- =============================================
                     LOW STOCK
                ============================================== -->

                <div
                    class="
                        inventory-summary-card
                        summary-low
                    "
                >


                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >

                            <path
                                d="M12 8v5"
                            />

                            <path
                                d="M12 17h.01"
                            />

                            <path
                                d="
                                    M10.3 3.7
                                    2.8 17
                                    a2 2 0 0 0
                                    1.7 3
                                    h15
                                    a2 2 0 0 0
                                    1.7-3
                                    L13.7 3.7
                                    a2 2 0 0 0
                                    -3.4 0Z
                                "
                            />

                        </svg>

                    </div>


                    <div class="summary-content">

                        <span>
                            Stok Rendah
                        </span>

                        <strong>
                            <%= lowStockItems %>
                        </strong>

                        <small>
                            Perlu perhatian
                        </small>

                    </div>


                </div>


                <!-- =============================================
                     OUT OF STOCK
                ============================================== -->

                <div
                    class="
                        inventory-summary-card
                        summary-out
                    "
                >


                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >

                            <circle
                                cx="12"
                                cy="12"
                                r="9"
                            />

                            <path
                                d="m9 9 6 6"
                            />

                            <path
                                d="m15 9-6 6"
                            />

                        </svg>

                    </div>


                    <div class="summary-content">

                        <span>
                            Kehabisan Stok
                        </span>

                        <strong>
                            <%= outOfStockItems %>
                        </strong>

                        <small>
                            Tidak tersedia
                        </small>

                    </div>


                </div>


            </div>


            <!-- =================================================
                 INVENTORY CARD
            ================================================== -->

            <div class="inventory-card">


                <!-- =============================================
                     CARD HEADER
                ============================================== -->

                <div class="inventory-card-header">


                    <div class="inventory-heading">

                        <h2>
                            Senarai Inventori
                        </h2>

                        <p>
                            Cari, tapis dan lihat maklumat
                            inventori syarikat.
                        </p>

                    </div>


                </div>


                <!-- =============================================
                     TOOLBAR
                ============================================== -->

                <div class="inventory-toolbar">


                    <div class="inventory-toolbar-left">


                        <!-- =====================================
                             SEARCH
                        ====================================== -->

                        <div class="inventory-search">


                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                            >

                                <circle
                                    cx="11"
                                    cy="11"
                                    r="7"
                                />

                                <path
                                    d="m20 20-3.5-3.5"
                                />

                            </svg>


                            <input
                                type="text"
                                id="inventorySearch"
                                placeholder="Cari kod, nama, jenama, warna, saiz..."
                                oninput="filterInventory()"
                            >


                        </div>


                        <!-- =====================================
                             CATEGORY FILTER
                        ====================================== -->

                        <select
                            id="categoryFilter"
                            class="filter-select"
                            onchange="filterInventory()"
                        >


                            <option value="">
                                Semua Kategori
                            </option>


                            <%
                                for (
                                    String category :
                                    categories
                                ) {
                            %>


                                <option
                                    value="<%= htmlEscape(category) %>"
                                >
                                    <%= htmlEscape(category) %>
                                </option>


                            <%
                                }
                            %>


                        </select>


                        <!-- =====================================
                             STATUS FILTER
                        ====================================== -->

                        <select
                            id="statusFilter"
                            class="filter-select"
                            onchange="filterInventory()"
                        >


                            <option value="">
                                Semua Status
                            </option>


                            <option value="AVAILABLE">
                                Tersedia
                            </option>


                            <option value="LOW_STOCK">
                                Stok Rendah
                            </option>


                            <option value="OUT_OF_STOCK">
                                Kehabisan Stok
                            </option>


                        </select>


                        <!-- =====================================
                             LOCATION FILTER
                        ====================================== -->

                        <select
                            id="locationFilter"
                            class="filter-select"
                            onchange="filterInventory()"
                        >


                            <option value="">
                                Semua Lokasi
                            </option>


                            <%
                                for (
                                    String location :
                                    locations
                                ) {
                            %>


                                <option
                                    value="<%= htmlEscape(location) %>"
                                >
                                    <%= htmlEscape(location) %>
                                </option>


                            <%
                                }
                            %>


                        </select>


                        <!-- =====================================
                             RESET
                        ====================================== -->

                        <button
                            type="button"
                            class="reset-filter-btn"
                            onclick="resetInventoryFilter()"
                        >
                            Reset
                        </button>


                    </div>


                    <!-- =========================================
                         RESULT COUNT
                    ========================================== -->

                    <div class="inventory-result-count">


                        Memaparkan


                        <strong id="visibleItemCount">
                            <%= totalItems %>
                        </strong>


                        daripada


                        <strong>
                            <%= totalItems %>
                        </strong>


                        item


                    </div>


                </div>


                <!-- =============================================
                     ERROR MESSAGE
                ============================================== -->

                <%
                    if (
                        request.getAttribute("error") != null
                    ) {
                %>


                    <div class="inventory-error">

                        <%= htmlEscape(
                            request.getAttribute("error")
                        ) %>

                    </div>


                <%
                    }
                %>


                <!-- =================================================
                     PART 2 ENDS HERE

                     PART 3 CONTINUES DIRECTLY BELOW THIS LINE.
                     DO NOT CLOSE inventory-card YET.
                ================================================== -->                <!-- =================================================
                     INVENTORY TABLE
                ================================================== -->

                <div class="inventory-table-wrapper">


                    <table class="inventory-table">


                        <!-- =========================================
                             TABLE HEADER
                        ========================================== -->

                        <thead>

                            <tr>

                                <th>
                                    Kod
                                </th>

                                <th>
                                    Maklumat Barang
                                </th>

                                <th>
                                    Kategori
                                </th>

                                <th>
                                    Variasi
                                </th>

                                <th>
                                    Stok
                                </th>

                                <th>
                                    Lokasi
                                </th>

                                <th>
                                    Status
                                </th>

                                <th>
                                    Tindakan
                                </th>

                            </tr>

                        </thead>


                        <!-- =========================================
                             TABLE BODY
                        ========================================== -->

                        <tbody id="inventoryTableBody">


                        <%
                            // =====================================
                            // CHECK INVENTORY
                            // =====================================

                            if (
                                items != null
                                &&
                                !items.isEmpty()
                            ) {


                                // =================================
                                // LOOP INVENTORY
                                // =================================

                                for (
                                    Map<String, Object> item :
                                    items
                                ) {


                                    // =============================
                                    // ID
                                    // =============================

                                    String id =
                                            item.get("id") == null
                                                    ? ""
                                                    : String.valueOf(
                                                        item.get("id")
                                                    );


                                    // =============================
                                    // ITEM CODE
                                    // =============================

                                    String itemCode =
                                            item.get("item_code") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("item_code")
                                                    ).trim();

                                    if (itemCode.isBlank()) {
                                        itemCode = "-";
                                    }


                                    // =============================
                                    // ITEM NAME
                                    // =============================

                                    String itemName =
                                            item.get("item_name") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("item_name")
                                                    ).trim();

                                    if (itemName.isBlank()) {
                                        itemName = "-";
                                    }


                                    // =============================
                                    // CATEGORY
                                    // =============================

                                    String category =
                                            item.get("category") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("category")
                                                    ).trim();

                                    if (category.isBlank()) {
                                        category = "-";
                                    }


                                    // =============================
                                    // ITEM TYPE
                                    // =============================

                                    String itemType =
                                            item.get("item_type") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("item_type")
                                                    ).trim();


                                    String itemTypeDisplay =
                                            itemType;


                                    if (
                                        "ASSET".equalsIgnoreCase(
                                            itemType
                                        )
                                    ) {

                                        itemTypeDisplay =
                                                "Aset";

                                    }
                                    else if (
                                        "CONSUMABLE".equalsIgnoreCase(
                                            itemType
                                        )
                                    ) {

                                        itemTypeDisplay =
                                                "Barang Guna Habis";

                                    }


                                    if (
                                        itemTypeDisplay == null
                                        ||
                                        itemTypeDisplay.isBlank()
                                    ) {

                                        itemTypeDisplay = "-";
                                    }


                                    // =============================
                                    // BRAND
                                    // =============================

                                    String brand =
                                            item.get("brand") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("brand")
                                                    ).trim();

                                    if (brand.isBlank()) {
                                        brand = "-";
                                    }


                                    // =============================
                                    // SIZE / VARIATION
                                    // =============================

                                    String size =
                                            item.get("size") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("size")
                                                    ).trim();

                                    if (size.isBlank()) {
                                        size = "-";
                                    }


                                    // =============================
                                    // COLOR
                                    // =============================

                                    String color =
                                            item.get("color") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("color")
                                                    ).trim();

                                    if (color.isBlank()) {
                                        color = "-";
                                    }


                                    // =============================
                                    // QUANTITY
                                    // =============================

                                    String quantity =
                                            item.get("quantity") == null
                                                    ? "0"
                                                    : String.valueOf(
                                                        item.get("quantity")
                                                    );


                                    // =============================
                                    // AVAILABLE QUANTITY
                                    // =============================

                                    String availableQuantity =
                                            item.get("available_quantity") == null
                                                    ? "0"
                                                    : String.valueOf(
                                                        item.get(
                                                            "available_quantity"
                                                        )
                                                    );


                                    // =============================
                                    // UNIT
                                    // =============================

                                    String unit =
                                            item.get("unit") == null
                                                    ? "Unit"
                                                    : String.valueOf(
                                                        item.get("unit")
                                                    ).trim();

                                    if (unit.isBlank()) {
                                        unit = "Unit";
                                    }


                                    // =============================
                                    // CONDITION
                                    // =============================

                                    String condition =
                                            item.get("item_condition") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get(
                                                            "item_condition"
                                                        )
                                                    ).trim();


                                    String conditionDisplay =
                                            condition;


                                    if (
                                        "GOOD".equalsIgnoreCase(
                                            condition
                                        )
                                        ||
                                        "Good".equalsIgnoreCase(
                                            condition
                                        )
                                    ) {

                                        conditionDisplay =
                                                "Baik";

                                    }
                                    else if (
                                        "FAIR".equalsIgnoreCase(
                                            condition
                                        )
                                        ||
                                        "Fair".equalsIgnoreCase(
                                            condition
                                        )
                                    ) {

                                        conditionDisplay =
                                                "Sederhana";

                                    }
                                    else if (
                                        "DAMAGED".equalsIgnoreCase(
                                            condition
                                        )
                                        ||
                                        "Damaged".equalsIgnoreCase(
                                            condition
                                        )
                                    ) {

                                        conditionDisplay =
                                                "Rosak";

                                    }
                                    else if (
                                        "MAINTENANCE".equalsIgnoreCase(
                                            condition
                                        )
                                        ||
                                        "UNDER_MAINTENANCE".equalsIgnoreCase(
                                            condition
                                        )
                                        ||
                                        "Under Maintenance".equalsIgnoreCase(
                                            condition
                                        )
                                    ) {

                                        conditionDisplay =
                                                "Dalam Penyelenggaraan";

                                    }


                                    if (
                                        conditionDisplay == null
                                        ||
                                        conditionDisplay.isBlank()
                                    ) {

                                        conditionDisplay = "-";
                                    }


                                    // =============================
                                    // LOCATION
                                    // =============================

                                    String location =
                                            item.get("location") == null
                                                    ? "-"
                                                    : String.valueOf(
                                                        item.get("location")
                                                    ).trim();

                                    if (location.isBlank()) {
                                        location = "-";
                                    }


                                    // =============================
                                    // DESCRIPTION
                                    // =============================

                                    String description =
                                            item.get("description") == null
                                                    ? ""
                                                    : String.valueOf(
                                                        item.get(
                                                            "description"
                                                        )
                                                    ).trim();


                                    // =============================
                                    // STATUS
                                    // =============================

                                    String status =
                                            item.get("status") == null
                                                    ? ""
                                                    : String.valueOf(
                                                        item.get("status")
                                                    ).trim();


                                    String statusDisplay =
                                            status;


                                    String statusClass =
                                            status
                                                .toLowerCase()
                                                .replace(
                                                    "_",
                                                    "-"
                                                );


                                    if (
                                        "AVAILABLE".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                                "Tersedia";

                                        statusClass =
                                                "available";

                                    }
                                    else if (
                                        "LOW_STOCK".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                                "Stok Rendah";

                                        statusClass =
                                                "low-stock";

                                    }
                                    else if (
                                        "OUT_OF_STOCK".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                                "Kehabisan Stok";

                                        statusClass =
                                                "out-of-stock";

                                    }


                                    if (
                                        statusDisplay == null
                                        ||
                                        statusDisplay.isBlank()
                                    ) {

                                        statusDisplay = "-";
                                    }


                                    // =============================
                                    // SEARCH TEXT
                                    // =============================

                                    String searchText =
                                            itemCode
                                            + " "
                                            + itemName
                                            + " "
                                            + brand
                                            + " "
                                            + category
                                            + " "
                                            + itemTypeDisplay
                                            + " "
                                            + size
                                            + " "
                                            + color
                                            + " "
                                            + location
                                            + " "
                                            + statusDisplay
                                            + " "
                                            + description;
                        %>


                            <!-- =================================
                                 INVENTORY ROW
                            ================================== -->

                            <tr
                                class="inventory-data-row"

                                data-category="<%= htmlEscape(category) %>"

                                data-status="<%= htmlEscape(status) %>"

                                data-location="<%= htmlEscape(location) %>"

                                data-brand="<%= htmlEscape(brand) %>"

                                data-size="<%= htmlEscape(size) %>"

                                data-color="<%= htmlEscape(color) %>"

                                data-search="<%= htmlEscape(
                                    searchText.toLowerCase()
                                ) %>"
                            >


                                <!-- =============================
                                     CODE
                                ============================== -->

                                <td>


                                    <span class="item-code">

                                        <%= htmlEscape(
                                            itemCode
                                        ) %>

                                    </span>


                                </td>


                                <!-- =============================
                                     ITEM INFORMATION
                                ============================== -->

                                <td>


                                    <div class="item-info">


                                        <strong>

                                            <%= htmlEscape(
                                                itemName
                                            ) %>

                                        </strong>


                                        <small class="item-brand">


                                            <%
                                                if (
                                                    !"-".equals(
                                                        brand
                                                    )
                                                ) {
                                            %>


                                                <%= htmlEscape(
                                                    brand
                                                ) %>


                                                <span>
                                                    &nbsp;•&nbsp;
                                                </span>


                                            <%
                                                }
                                            %>


                                            <%= htmlEscape(
                                                itemTypeDisplay
                                            ) %>


                                        </small>


                                    </div>


                                </td>


                                <!-- =============================
                                     CATEGORY
                                ============================== -->

                                <td>


                                    <span class="category-label">

                                        <%= htmlEscape(
                                            category
                                        ) %>

                                    </span>


                                </td>


                                <!-- =============================
                                     VARIATION
                                ============================== -->

                                <td>


                                    <div class="item-variation">


                                        <!-- COLOR -->

                                        <span class="variation-line">


                                            <span class="variation-label">
                                                Warna
                                            </span>


                                            <span class="variation-value">

                                                <%= htmlEscape(
                                                    color
                                                ) %>

                                            </span>


                                        </span>


                                        <!-- SIZE / VARIATION -->

                                        <span class="variation-line">


                                            <span class="variation-label">
                                                Saiz / Variasi
                                            </span>


                                            <span class="variation-value">

                                                <%= htmlEscape(
                                                    size
                                                ) %>

                                            </span>


                                        </span>


                                    </div>


                                </td>


                                <!-- =============================
                                     STOCK
                                ============================== -->

                                <td>


                                    <div class="stock-cell">


                                        <div class="stock-main">


                                            <strong>

                                                <%= htmlEscape(
                                                    availableQuantity
                                                ) %>

                                            </strong>


                                            <span>

                                                <%= htmlEscape(
                                                    unit
                                                ) %>

                                            </span>


                                        </div>


                                        <small class="stock-total">

                                            Jumlah:

                                            <%= htmlEscape(
                                                quantity
                                            ) %>

                                            <%= htmlEscape(
                                                unit
                                            ) %>

                                        </small>


                                    </div>


                                </td>


                                <!-- =============================
                                     LOCATION
                                ============================== -->

                                <td>


                                    <span class="location-text">

                                        <%= htmlEscape(
                                            location
                                        ) %>

                                    </span>


                                </td>


                                <!-- =============================
                                     STATUS
                                ============================== -->

                                <td>


                                    <span
                                        class="
                                            inventory-status
                                            <%= htmlEscape(
                                                statusClass
                                            ) %>
                                        "
                                    >

                                        <%= htmlEscape(
                                            statusDisplay
                                        ) %>

                                    </span>


                                </td>


                                <!-- =============================
                                     ACTION
                                ============================== -->

                                <td>


                                    <div class="inventory-actions">


                                        <!-- =====================
                                             VIEW BUTTON
                                        ====================== -->

                                        <button
                                            type="button"
                                            class="btn-view"

                                            onclick="openInventoryDetail(
                                                '<%= jsEscape(id) %>',
                                                '<%= jsEscape(itemCode) %>',
                                                '<%= jsEscape(itemName) %>',
                                                '<%= jsEscape(category) %>',
                                                '<%= jsEscape(itemTypeDisplay) %>',
                                                '<%= jsEscape(brand) %>',
                                                '<%= jsEscape(size) %>',
                                                '<%= jsEscape(color) %>',
                                                '<%= jsEscape(availableQuantity) %>',
                                                '<%= jsEscape(quantity) %>',
                                                '<%= jsEscape(unit) %>',
                                                '<%= jsEscape(conditionDisplay) %>',
                                                '<%= jsEscape(location) %>',
                                                '<%= jsEscape(status) %>',
                                                '<%= jsEscape(statusDisplay) %>',
                                                '<%= jsEscape(description) %>'
                                            )"
                                        >

                                            Lihat

                                        </button>


                                        <!-- =====================
                                             REQUEST BUTTON
                                        ====================== -->

                                        <%
                                            if (
                                                "AVAILABLE".equalsIgnoreCase(
                                                    status
                                                )
                                                ||
                                                "LOW_STOCK".equalsIgnoreCase(
                                                    status
                                                )
                                            ) {
                                        %>


                                            <a
                                                href="
                                                    <%= request.getContextPath() %>/inventory-request?id=<%= htmlEscape(id) %>
                                                "
                                                class="btn-request"
                                            >

                                                Mohon

                                            </a>


                                        <%
                                            }
                                            else {
                                        %>


                                            <span class="btn-disabled">

                                                Tidak Tersedia

                                            </span>


                                        <%
                                            }
                                        %>


                                    </div>


                                </td>


                            </tr>


                        <%
                                } // END FOR

                            } // END IF ITEMS

                            else {
                        %>


                            <!-- =================================
                                 EMPTY INVENTORY
                            ================================== -->

                            <tr>


                                <td
                                    colspan="8"
                                    class="inventory-empty"
                                >


                                    <div class="inventory-empty-icon">


                                        <svg
                                            viewBox="0 0 24 24"
                                            fill="none"
                                            stroke="currentColor"
                                            stroke-width="1.8"
                                        >

                                            <path
                                                d="
                                                    M4 7.5
                                                    12 3
                                                    l8 4.5
                                                    -8 4.5
                                                    -8-4.5Z
                                                "
                                            />

                                            <path
                                                d="
                                                    M4 7.5
                                                    V16
                                                    l8 5
                                                    8-5
                                                    V7.5
                                                "
                                            />

                                            <path
                                                d="M12 12v9"
                                            />

                                        </svg>


                                    </div>


                                    <strong>
                                        Tiada inventori tersedia
                                    </strong>


                                    <p>
                                        Tiada item inventori direkodkan
                                        dalam sistem pada masa ini.
                                    </p>


                                </td>


                            </tr>


                        <%
                            }
                        %>


                        </tbody>


                    </table>


                </div>


                <!-- =================================================
                     NO FILTER / SEARCH RESULT
                ================================================== -->

                <div
                    id="noSearchResult"
                    class="no-search-result"
                >


                    <strong>
                        Tiada item ditemui
                    </strong>


                    <span>
                        Cuba ubah kata carian atau pilihan penapis.
                    </span>


                </div>


            </div>
            <!-- END INVENTORY CARD -->


        </div>
        <!-- END INVENTORY PAGE -->


    </main>


</div>
<!-- END APP -->


<!-- =============================================================
     INVENTORY DETAIL MODAL
============================================================== -->

<div
    id="inventoryModal"
    class="inventory-modal-overlay"
    onclick="closeInventoryModalFromOverlay(event)"
>


    <div
        class="inventory-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modalItemName"
    >


        <!-- =====================================================
             MODAL HEADER
        ====================================================== -->

        <div class="modal-header">


            <div class="modal-title-area">


                <span
                    id="modalItemCode"
                    class="modal-code"
                >
                    -
                </span>


                <h3 id="modalItemName">
                    -
                </h3>


                <span
                    id="modalStatus"
                    class="inventory-status"
                >
                    -
                </span>


            </div>


            <button
                type="button"
                class="modal-close"
                onclick="closeInventoryModal()"
                aria-label="Tutup"
            >
                &times;
            </button>


        </div>


        <!-- =====================================================
             MODAL BODY
        ====================================================== -->

        <div class="modal-body">


            <!-- =================================================
                 ITEM INFORMATION
            ================================================== -->

            <div class="detail-section">


                <h4 class="detail-section-title">
                    Maklumat Barang
                </h4>


                <div class="detail-grid">


                    <!-- CODE -->

                    <div class="detail-box">

                        <label>
                            Kod Barang
                        </label>

                        <span id="modalCodeDetail">
                            -
                        </span>

                    </div>


                    <!-- NAME -->

                    <div class="detail-box">

                        <label>
                            Nama Barang
                        </label>

                        <span id="modalNameDetail">
                            -
                        </span>

                    </div>


                    <!-- CATEGORY -->

                    <div class="detail-box">

                        <label>
                            Kategori
                        </label>

                        <span id="modalCategory">
                            -
                        </span>

                    </div>


                    <!-- TYPE -->

                    <div class="detail-box">

                        <label>
                            Jenis Barang
                        </label>

                        <span id="modalType">
                            -
                        </span>

                    </div>


                    <!-- BRAND -->

                    <div class="detail-box">

                        <label>
                            Jenama
                        </label>

                        <span id="modalBrand">
                            -
                        </span>

                    </div>


                    <!-- SIZE -->

                    <div class="detail-box">

                        <label>
                            Saiz / Variasi
                        </label>

                        <span id="modalSize">
                            -
                        </span>

                    </div>


                    <!-- COLOR -->

                    <div class="detail-box">

                        <label>
                            Warna
                        </label>

                        <span id="modalColor">
                            -
                        </span>

                    </div>


                    <!-- UNIT -->

                    <div class="detail-box">

                        <label>
                            Unit
                        </label>

                        <span id="modalUnit">
                            -
                        </span>

                    </div>


                    <!-- CONDITION -->

                    <div class="detail-box">

                        <label>
                            Keadaan
                        </label>

                        <span id="modalCondition">
                            -
                        </span>

                    </div>


                    <!-- LOCATION -->

                    <div class="detail-box">

                        <label>
                            Lokasi
                        </label>

                        <span id="modalLocation">
                            -
                        </span>

                    </div>


                </div>


            </div>


            <!-- =================================================
                 STOCK INFORMATION
            ================================================== -->

            <div class="detail-section">


                <h4 class="detail-section-title">
                    Maklumat Stok
                </h4>


                <div class="stock-overview">


                    <!-- AVAILABLE STOCK -->

                    <div class="stock-overview-box">


                        <label>
                            Kuantiti Tersedia
                        </label>


                        <strong id="modalAvailable">
                            0
                        </strong>


                        <span id="modalAvailableUnit">
                            Unit
                        </span>


                    </div>


                    <!-- TOTAL STOCK -->

                    <div class="stock-overview-box">


                        <label>
                            Jumlah Kuantiti
                        </label>


                        <strong id="modalQuantity">
                            0
                        </strong>


                        <span id="modalQuantityUnit">
                            Unit
                        </span>


                    </div>


                </div>


            </div>


            <!-- =================================================
                 DESCRIPTION
            ================================================== -->

            <div
                id="modalDescriptionSection"
                class="detail-section"
                style="display:none;"
            >


                <h4 class="detail-section-title">
                    Keterangan
                </h4>


                <div
                    id="modalDescription"
                    class="description-box"
                >
                    -
                </div>


            </div>


        </div>


        <!-- =====================================================
             MODAL FOOTER
        ====================================================== -->

        <div class="modal-footer">


            <button
                type="button"
                class="btn-close-footer"
                onclick="closeInventoryModal()"
            >
                Tutup
            </button>


            <a
                id="modalRequestButton"
                href="#"
                class="btn-request"
            >
                Mohon Barang
            </a>


        </div>


    </div>


</div>


<!-- =============================================================
     PART 3 ENDS HERE

     PART 4 CONTINUES DIRECTLY BELOW THIS LINE.

     PART 4 WILL CONTAIN:
     - SEARCH
     - FILTER
     - RESET
     - MODAL JAVASCRIPT
     - BRAND / SIZE / COLOR MODAL DATA
     - ESC KEY
     - FINAL </body> AND </html>
============================================================== --><!-- =============================================================
     JAVASCRIPT
============================================================== -->

<script>

    /* =============================================================
       HELPER
    ============================================================== */

    function setText(id, value) {

        const element =
            document.getElementById(id);

        if (element) {

            element.textContent =
                value === null
                || value === undefined
                || String(value).trim() === ""
                    ? "-"
                    : value;
        }
    }


    /* =============================================================
       FILTER INVENTORY
    ============================================================== */

    function filterInventory() {

        // =========================================================
        // GET FILTER VALUES
        // =========================================================

        const searchInput =
            document.getElementById(
                "inventorySearch"
            );

        const categoryFilter =
            document.getElementById(
                "categoryFilter"
            );

        const statusFilter =
            document.getElementById(
                "statusFilter"
            );

        const locationFilter =
            document.getElementById(
                "locationFilter"
            );


        const searchValue =
            searchInput
                ? searchInput.value
                    .trim()
                    .toLowerCase()
                : "";


        const categoryValue =
            categoryFilter
                ? categoryFilter.value
                    .trim()
                    .toLowerCase()
                : "";


        const statusValue =
            statusFilter
                ? statusFilter.value
                    .trim()
                    .toUpperCase()
                : "";


        const locationValue =
            locationFilter
                ? locationFilter.value
                    .trim()
                    .toLowerCase()
                : "";


        // =========================================================
        // GET ROWS
        // =========================================================

        const rows =
            document.querySelectorAll(
                ".inventory-data-row"
            );


        let visibleCount = 0;


        // =========================================================
        // FILTER EACH ROW
        // =========================================================

        rows.forEach(function(row) {


            // =====================================================
            // SEARCH DATA
            // =====================================================

            const rowSearch =
                (
                    row.dataset.search
                    ||
                    row.textContent
                    ||
                    ""
                )
                .toLowerCase();


            const rowCategory =
                (
                    row.dataset.category
                    ||
                    ""
                )
                .trim()
                .toLowerCase();


            const rowStatus =
                (
                    row.dataset.status
                    ||
                    ""
                )
                .trim()
                .toUpperCase();


            const rowLocation =
                (
                    row.dataset.location
                    ||
                    ""
                )
                .trim()
                .toLowerCase();


            // =====================================================
            // MATCH SEARCH
            // =====================================================

            const matchesSearch =
                searchValue === ""
                ||
                rowSearch.includes(
                    searchValue
                );


            // =====================================================
            // MATCH CATEGORY
            // =====================================================

            const matchesCategory =
                categoryValue === ""
                ||
                rowCategory ===
                    categoryValue;


            // =====================================================
            // MATCH STATUS
            // =====================================================

            const matchesStatus =
                statusValue === ""
                ||
                rowStatus ===
                    statusValue;


            // =====================================================
            // MATCH LOCATION
            // =====================================================

            const matchesLocation =
                locationValue === ""
                ||
                rowLocation ===
                    locationValue;


            // =====================================================
            // SHOW / HIDE
            // =====================================================

            if (
                matchesSearch
                &&
                matchesCategory
                &&
                matchesStatus
                &&
                matchesLocation
            ) {

                row.style.display = "";

                visibleCount++;

            }
            else {

                row.style.display =
                    "none";
            }

        });


        // =========================================================
        // UPDATE RESULT COUNT
        // =========================================================

        const visibleItemCount =
            document.getElementById(
                "visibleItemCount"
            );


        if (visibleItemCount) {

            visibleItemCount.textContent =
                visibleCount;
        }


        // =========================================================
        // NO RESULT MESSAGE
        // =========================================================

        const noSearchResult =
            document.getElementById(
                "noSearchResult"
            );


        if (noSearchResult) {

            if (
                rows.length > 0
                &&
                visibleCount === 0
            ) {

                noSearchResult.style.display =
                    "block";

            }
            else {

                noSearchResult.style.display =
                    "none";
            }
        }
    }


    /* =============================================================
       RESET FILTER
    ============================================================== */

    function resetInventoryFilter() {

        const search =
            document.getElementById(
                "inventorySearch"
            );

        const category =
            document.getElementById(
                "categoryFilter"
            );

        const status =
            document.getElementById(
                "statusFilter"
            );

        const location =
            document.getElementById(
                "locationFilter"
            );


        if (search) {
            search.value = "";
        }


        if (category) {
            category.value = "";
        }


        if (status) {
            status.value = "";
        }


        if (location) {
            location.value = "";
        }


        filterInventory();


        if (search) {

            search.focus();
        }
    }


    /* =============================================================
       OPEN INVENTORY DETAIL
    ============================================================== */

    function openInventoryDetail(
        id,
        code,
        name,
        category,
        type,
        brand,
        size,
        color,
        available,
        quantity,
        unit,
        condition,
        location,
        status,
        statusDisplay,
        description
    ) {


        // =========================================================
        // HEADER
        // =========================================================

        setText(
            "modalItemCode",
            code || "-"
        );


        setText(
            "modalItemName",
            name || "-"
        );


        // =========================================================
        // ITEM INFORMATION
        // =========================================================

        setText(
            "modalCodeDetail",
            code || "-"
        );


        setText(
            "modalNameDetail",
            name || "-"
        );


        setText(
            "modalCategory",
            category || "-"
        );


        setText(
            "modalType",
            type || "-"
        );


        // =========================================================
        // BRAND
        // =========================================================

        setText(
            "modalBrand",
            brand || "-"
        );


        // =========================================================
        // SIZE / VARIATION
        // =========================================================

        setText(
            "modalSize",
            size || "-"
        );


        // =========================================================
        // COLOR
        // =========================================================

        setText(
            "modalColor",
            color || "-"
        );


        // =========================================================
        // UNIT
        // =========================================================

        setText(
            "modalUnit",
            unit || "Unit"
        );


        // =========================================================
        // CONDITION
        // =========================================================

        setText(
            "modalCondition",
            condition || "-"
        );


        // =========================================================
        // LOCATION
        // =========================================================

        setText(
            "modalLocation",
            location || "-"
        );


        // =========================================================
        // STOCK
        // =========================================================

        setText(
            "modalAvailable",
            available || "0"
        );


        setText(
            "modalQuantity",
            quantity || "0"
        );


        setText(
            "modalAvailableUnit",
            unit || "Unit"
        );


        setText(
            "modalQuantityUnit",
            unit || "Unit"
        );


        // =========================================================
        // DESCRIPTION
        // =========================================================

        const descriptionSection =
            document.getElementById(
                "modalDescriptionSection"
            );


        const descriptionElement =
            document.getElementById(
                "modalDescription"
            );


        if (
            descriptionSection
            &&
            descriptionElement
        ) {

            if (
                description
                &&
                description.trim() !== ""
                &&
                description.trim() !== "-"
            ) {

                descriptionSection.style.display =
                    "";


                descriptionElement.textContent =
                    description;

            }
            else {

                descriptionSection.style.display =
                    "none";


                descriptionElement.textContent =
                    "-";
            }
        }


        // =========================================================
        // STATUS
        // =========================================================

        const statusElement =
            document.getElementById(
                "modalStatus"
            );


        if (statusElement) {


            statusElement.textContent =
                statusDisplay || "-";


            // RESET CLASS

            statusElement.className =
                "inventory-status";


            // AVAILABLE

            if (
                status === "AVAILABLE"
            ) {

                statusElement.classList.add(
                    "available"
                );
            }


            // LOW STOCK

            else if (
                status === "LOW_STOCK"
            ) {

                statusElement.classList.add(
                    "low-stock"
                );
            }


            // OUT OF STOCK

            else if (
                status === "OUT_OF_STOCK"
            ) {

                statusElement.classList.add(
                    "out-of-stock"
                );
            }
        }


        // =========================================================
        // REQUEST BUTTON
        // =========================================================

        const requestButton =
            document.getElementById(
                "modalRequestButton"
            );


        if (requestButton) {


            if (
                status === "AVAILABLE"
                ||
                status === "LOW_STOCK"
            ) {

                requestButton.style.display =
                    "inline-flex";


                requestButton.href =
                    "<%= request.getContextPath() %>/inventory-request?id="
                    +
                    encodeURIComponent(id);

            }
            else {

                requestButton.style.display =
                    "none";


                requestButton.href =
                    "#";
            }
        }


        // =========================================================
        // SHOW MODAL
        // =========================================================

        const modal =
            document.getElementById(
                "inventoryModal"
            );


        if (modal) {

            modal.classList.add(
                "show"
            );


            // PREVENT PAGE FROM SCROLLING
            // WHILE MODAL IS OPEN

            document.body.style.overflowY =
                "hidden";
        }
    }


    /* =============================================================
       CLOSE INVENTORY MODAL
    ============================================================== */

    function closeInventoryModal() {

        const modal =
            document.getElementById(
                "inventoryModal"
            );


        if (modal) {

            modal.classList.remove(
                "show"
            );
        }


        // RESTORE VERTICAL SCROLL

        document.body.style.overflowY =
            "auto";
    }


    /* =============================================================
       CLOSE MODAL WHEN CLICKING OVERLAY
    ============================================================== */

    function closeInventoryModalFromOverlay(
        event
    ) {

        if (
            event.target ===
            event.currentTarget
        ) {

            closeInventoryModal();
        }
    }


    /* =============================================================
       ESC KEY
    ============================================================== */

    document.addEventListener(
        "keydown",
        function(event) {

            if (
                event.key === "Escape"
            ) {

                const modal =
                    document.getElementById(
                        "inventoryModal"
                    );


                if (
                    modal
                    &&
                    modal.classList.contains(
                        "show"
                    )
                ) {

                    closeInventoryModal();
                }
            }
        }
    );


    /* =============================================================
       PREVENT HORIZONTAL SCROLL
    ============================================================== */

    function preventHorizontalOverflow() {

        document.documentElement.style.overflowX =
            "hidden";


        document.body.style.overflowX =
            "hidden";
    }


    /* =============================================================
       INITIALIZE PAGE
    ============================================================== */

    document.addEventListener(
        "DOMContentLoaded",
        function() {


            // =====================================================
            // PREVENT HORIZONTAL SCROLL
            // =====================================================

            preventHorizontalOverflow();


            // =====================================================
            // INITIAL FILTER
            // =====================================================

            filterInventory();


            // =====================================================
            // SEARCH ENTER
            //
            // Prevent accidental form submission if this page
            // is later placed inside a form.
            // =====================================================

            const searchInput =
                document.getElementById(
                    "inventorySearch"
                );


            if (searchInput) {

                searchInput.addEventListener(
                    "keydown",
                    function(event) {

                        if (
                            event.key === "Enter"
                        ) {

                            event.preventDefault();

                            filterInventory();
                        }
                    }
                );
            }
        }
    );


    /* =============================================================
       WINDOW RESIZE
    ============================================================== */

    window.addEventListener(
        "resize",
        function() {

            preventHorizontalOverflow();
        }
    );

</script>


</body>

</html>