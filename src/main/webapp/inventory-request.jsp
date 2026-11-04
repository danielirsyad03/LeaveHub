<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>

<%!
    private String safeText(Object value) {
        if (value == null) {
            return "-";
        }

        String text = String.valueOf(value).trim();

        if (text.isEmpty() || "null".equalsIgnoreCase(text)) {
            return "-";
        }

        return text;
    }

    private String htmlEscape(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    // =========================================================
    // SESSION
    // =========================================================
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");

    if (userName == null || userName.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    // =========================================================
    // INVENTORY ITEM
    // =========================================================
    java.util.Map<String, Object> item = null;

Object itemAttribute = request.getAttribute("item");

if (itemAttribute instanceof java.util.Map<?, ?>) {

    java.util.Map<?, ?> originalMap =
            (java.util.Map<?, ?>) itemAttribute;

    item = new java.util.HashMap<>();

    for (java.util.Map.Entry<?, ?> entry :
            originalMap.entrySet()) {

        if (entry.getKey() instanceof String) {

            item.put(
                    (String) entry.getKey(),
                    entry.getValue()
            );
        }
    }
}

if (item == null) {
    response.sendRedirect(request.getContextPath() + "/inventory");
    return;
}

    String itemCode = safeText(item.get("item_code"));
    String itemName = safeText(item.get("item_name"));
    String brand = safeText(item.get("brand"));
    String size = safeText(item.get("size"));
    String color = safeText(item.get("color"));
    String category = safeText(item.get("category"));
    String itemType = safeText(item.get("item_type"));
    String unit = safeText(item.get("unit"));
    String condition = safeText(item.get("item_condition"));
    String location = safeText(item.get("location"));
    String description = safeText(item.get("description"));
    String status = safeText(item.get("status"));

    int itemId = 0;
    int quantity = 0;
    int availableQuantity = 0;

    if (item.get("id") instanceof Number) {
        itemId = ((Number) item.get("id")).intValue();
    }

    if (item.get("quantity") instanceof Number) {
        quantity = ((Number) item.get("quantity")).intValue();
    }

    if (item.get("available_quantity") instanceof Number) {
        availableQuantity =
                ((Number) item.get("available_quantity")).intValue();
    }

    boolean canRequest =
            Boolean.TRUE.equals(item.get("can_request"));

    // =========================================================
    // STATUS
    // =========================================================
    String statusText = status;
    String statusClass = "status-inactive";

    if ("AVAILABLE".equalsIgnoreCase(status)) {
        statusText = "Tersedia";
        statusClass = "status-available";

    } else if ("LOW_STOCK".equalsIgnoreCase(status)) {
        statusText = "Stok Rendah";
        statusClass = "status-low";

    } else if ("OUT_OF_STOCK".equalsIgnoreCase(status)) {
        statusText = "Kehabisan Stok";
        statusClass = "status-out";

    } else if ("INACTIVE".equalsIgnoreCase(status)) {
        statusText = "Tidak Aktif";
        statusClass = "status-inactive";
    }

    // =========================================================
    // ITEM TYPE
    // =========================================================
    String typeText = itemType;

    if ("CONSUMABLE".equalsIgnoreCase(itemType)) {
        typeText = "Barang Guna Habis";

    } else if ("ASSET".equalsIgnoreCase(itemType)) {
        typeText = "Aset";
    }

    // =========================================================
    // CONDITION
    // =========================================================
    String conditionText = condition;

    if ("GOOD".equalsIgnoreCase(condition)) {
        conditionText = "Baik";

    } else if ("NEW".equalsIgnoreCase(condition)) {
        conditionText = "Baharu";

    } else if ("DAMAGED".equalsIgnoreCase(condition)) {
        conditionText = "Rosak";

    } else if ("REPAIR".equalsIgnoreCase(condition)) {
        conditionText = "Dalam Pembaikan";
    }

    // =========================================================
    // USER
    // =========================================================
    String userInitial = "U";

    if (userName != null && !userName.trim().isEmpty()) {
        userInitial =
                userName.trim()
                        .substring(0, 1)
                        .toUpperCase();
    }

    String roleDisplay = "";

    if (userRole != null) {

        if ("HR".equalsIgnoreCase(userRole)) {
            roleDisplay = "Pentadbir Sistem";

        } else if ("HOD".equalsIgnoreCase(userRole)) {
            roleDisplay = "Ketua Unit";

        } else if ("STAFF".equalsIgnoreCase(userRole)) {
            roleDisplay = "Staf";

        } else {
            roleDisplay = userRole;
        }
    }

    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Permohonan Inventori - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css"
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
            margin: 0;
            padding: 0;
            width: 100%;
            max-width: 100%;
            overflow-x: hidden;
        }

        body {
            background: #f7f8fa;
        }

        .app {
            display: flex;
            width: 100%;
            min-height: 100vh;
        }

        main {
            flex: 1 1 auto;
            min-width: 0;
            overflow-x: hidden;
        }


        /* =====================================================
           PAGE
        ===================================================== */

        .inventory-request-page {
            width: 100%;
            padding: 30px 34px 50px;
        }


        /* =====================================================
           HEADER
        ===================================================== */

        .request-page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 24px;
        }

        .request-page-title {
            min-width: 0;
        }

        .request-page-title h1 {
            margin: 0 0 7px;

            color: #111827;

            font-size: 26px;
            line-height: 1.2;
            font-weight: 700;
        }

        .request-page-title p {
            margin: 0;

            color: #8a94a6;

            font-size: 13px;
            line-height: 1.5;
        }


        /* =====================================================
           HEADER ACTIONS
        ===================================================== */

        .request-header-actions {
            flex-shrink: 0;

            display: flex;
            align-items: center;

            gap: 10px;
        }


        /* =====================================================
           NOTIFICATION
        ===================================================== */

        .notification-button {
            position: relative;

            width: 42px;
            height: 42px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            background: #ffffff;

            border: 1px solid #e5e9ef;
            border-radius: 12px;

            color: #64748b;

            text-decoration: none;

            box-shadow:
                0 4px 16px rgba(15, 23, 42, 0.04);

            transition: 0.2s ease;
        }

        .notification-button:hover {
            background: #fafafa;
            color: #981b2b;
        }

        .notification-button svg {
            width: 19px;
            height: 19px;

            stroke: currentColor;
        }


        /* =====================================================
           USER
        ===================================================== */

        .request-user {
            flex-shrink: 0;

            display: flex;
            align-items: center;

            gap: 10px;

            padding: 8px 12px;

            background: #ffffff;

            border: 1px solid #e5e9ef;
            border-radius: 12px;

            box-shadow:
                0 4px 16px rgba(15, 23, 42, 0.04);
        }

        .request-user-avatar {
            width: 36px;
            height: 36px;

            flex-shrink: 0;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #fff4f2;

            border: 1px solid #f0d6d4;
            border-radius: 10px;

            color: #981b2b;

            font-size: 14px;
            font-weight: 700;
        }

        .request-user-details {
            min-width: 0;

            display: flex;
            flex-direction: column;

            gap: 2px;
        }

        .request-user-name {
            max-width: 180px;

            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;

            color: #273044;

            font-size: 12px;
            font-weight: 700;
        }

        .request-user-role {
            color: #929bad;

            font-size: 10px;
            font-weight: 500;
        }


        /* =====================================================
           MAIN CARD
        ===================================================== */

        .request-card {
            width: 100%;

            background: #ffffff;

            border: 1px solid #e4e8ee;
            border-radius: 16px;

            overflow: hidden;

            box-shadow:
                0 6px 24px rgba(15, 23, 42, 0.045);
        }

        .request-card-header {
            padding: 21px 23px;

            border-bottom: 1px solid #e9ecf1;
        }

        .request-card-header h2 {
            margin: 0 0 5px;

            color: #111827;

            font-size: 17px;
            font-weight: 700;
        }

        .request-card-header p {
            margin: 0;

            color: #8a94a6;

            font-size: 12px;
            line-height: 1.5;
        }


        /* =====================================================
           SECTION
        ===================================================== */

        .request-section {
            width: 100%;

            padding: 24px 23px;

            border-bottom: 1px solid #eceff3;
        }

        .section-title {
            display: flex;
            align-items: center;

            gap: 11px;

            margin-bottom: 17px;
        }

        .section-icon {
            width: 38px;
            height: 38px;

            flex-shrink: 0;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #fff5ef;

            border: 1px solid #f0dad2;
            border-radius: 10px;

            color: #981b2b;

            font-size: 14px;
            font-weight: 700;
        }

        .section-title h3 {
            margin: 0 0 3px;

            color: #111827;

            font-size: 14px;
            font-weight: 700;
        }

        .section-title p {
            margin: 0;

            color: #8c96a8;

            font-size: 11px;
            line-height: 1.4;
        }


        /* =====================================================
           SELECTED ITEM
        ===================================================== */

        .selected-item-card {
            position: relative;

            width: 100%;

            background: #ffffff;

            border: 1px solid #e0e5ec;
            border-radius: 14px;

            overflow: hidden;
        }

        .selected-item-card::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;
            right: 0;

            height: 3px;

            background:
                linear-gradient(
                    90deg,
                    #981b2b,
                    #b51f32,
                    #d4a126
                );
        }

        .selected-item-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;

            gap: 18px;

            padding: 19px 20px 15px;
        }

        .selected-item-name {
            min-width: 0;
        }

        .selected-item-name h3 {
            margin: 0 0 7px;

            color: #111827;

            font-size: 16px;
            line-height: 1.35;
            font-weight: 700;

            overflow-wrap: anywhere;
        }

        .selected-item-name p {
            margin: 0;

            color: #8b95a7;

            font-size: 11px;
        }

        .selected-item-name strong {
            color: #525e72;
        }


        /* =====================================================
           STATUS
        ===================================================== */

        .status-badge {
            flex-shrink: 0;

            display: inline-flex;
            align-items: center;

            gap: 6px;

            padding: 6px 11px;

            border-radius: 999px;

            white-space: nowrap;

            font-size: 10px;
            font-weight: 700;
        }

        .status-badge::before {
            content: "";

            width: 6px;
            height: 6px;

            border-radius: 50%;

            background: currentColor;
        }

        .status-available {
            background: #edf9f1;
            border: 1px solid #ccebd6;
            color: #18834d;
        }

        .status-low {
            background: #fff8e7;
            border: 1px solid #efdaa0;
            color: #a16b00;
        }

        .status-out {
            background: #fff0f1;
            border: 1px solid #efccd1;
            color: #b42335;
        }

        .status-inactive {
            background: #f3f4f6;
            border: 1px solid #dfe2e7;
            color: #6b7280;
        }


        /* =====================================================
           ITEM GRID
        ===================================================== */

        .item-information-grid {
            display: grid;

            grid-template-columns:
                repeat(5, minmax(0, 1fr));

            gap: 10px;

            padding: 0 20px 20px;
        }

        .item-info-box {
            min-width: 0;

            padding: 12px 13px;

            background: #fafbfc;

            border: 1px solid #e5e9ef;
            border-radius: 10px;
        }

        .item-info-box.stock {
            background: #fff9f6;
            border-color: #efdcd4;
        }

        .item-info-label {
            display: block;

            margin-bottom: 6px;

            color: #949daf;

            font-size: 9px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: 0.2px;
        }

        .item-info-value {
            display: block;

            color: #273044;

            font-size: 12px;
            line-height: 1.4;
            font-weight: 700;

            overflow-wrap: anywhere;
        }

        .item-info-box.stock .item-info-value {
            color: #981b2b;

            font-size: 14px;
        }

        .item-info-value small {
            color: #7f899b;

            font-size: 9px;
            font-weight: 500;
        }


        /* =====================================================
           DESCRIPTION
        ===================================================== */

        .item-description {
            margin: 0 20px 20px;

            padding: 12px 13px;

            background: #fafbfc;

            border: 1px solid #e5e9ef;
            border-radius: 10px;
        }

        .item-description p {
            margin: 0;

            color: #4f5b70;

            font-size: 11px;
            line-height: 1.55;

            overflow-wrap: anywhere;
        }


        /* =====================================================
           FORM
        ===================================================== */

        form {
            width: 100%;
        }

        .form-group {
            margin-bottom: 21px;
        }

        .form-group:last-child {
            margin-bottom: 0;
        }

        .form-label {
            display: block;

            margin-bottom: 8px;

            color: #253047;

            font-size: 12px;
            font-weight: 700;
        }

        .required {
            color: #a61e30;
        }

        .optional {
            margin-left: 4px;

            color: #929bad;

            font-size: 10px;
            font-weight: 500;
        }


        /* =====================================================
           QUANTITY
        ===================================================== */

        .quantity-control {
            display: inline-flex;
            align-items: stretch;

            background: #ffffff;

            border: 1px solid #dfe4eb;
            border-radius: 10px;

            overflow: hidden;
        }

        .quantity-button {
            width: 42px;
            height: 42px;

            border: none;

            background: #f9fafb;

            color: #5e6879;

            cursor: pointer;

            font-family: inherit;
            font-size: 17px;
            font-weight: 600;
        }

        .quantity-button:hover:not(:disabled) {
            background: #f1f3f6;
        }

        .quantity-button:disabled {
            cursor: not-allowed;
            opacity: 0.45;
        }

        .quantity-input {
            width: 90px;
            height: 42px;

            border: none;
            border-left: 1px solid #e3e7ed;
            border-right: 1px solid #e3e7ed;

            outline: none;

            text-align: center;

            color: #981b2b;

            font-family: inherit;
            font-size: 13px;
            font-weight: 700;

            appearance: textfield;
        }

        .quantity-input::-webkit-outer-spin-button,
        .quantity-input::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }

        .form-help {
            margin-top: 7px;

            color: #8c96a8;

            font-size: 10px;
            line-height: 1.5;
        }

        .form-help strong {
            color: #5b6576;
        }


        /* =====================================================
           TEXTAREA
        ===================================================== */

        .purpose-textarea {
            display: block;

            width: 100%;
            min-height: 105px;

            padding: 12px 13px;

            resize: vertical;

            background: #ffffff;

            border: 1px solid #dfe4eb;
            border-radius: 10px;

            outline: none;

            color: #253047;

            font-family: inherit;
            font-size: 11px;
            line-height: 1.6;

            transition:
                border-color 0.2s ease,
                box-shadow 0.2s ease;
        }

        .purpose-textarea:focus {
            border-color: #a62031;

            box-shadow:
                0 0 0 3px rgba(166, 32, 49, 0.07);
        }

        .purpose-textarea::placeholder {
            color: #a0a8b7;
        }


        /* =====================================================
           ALERT
        ===================================================== */

        .request-alert {
            margin-bottom: 18px;

            padding: 11px 13px;

            background: #fff1f2;

            border: 1px solid #f3cdd2;
            border-radius: 9px;

            color: #a61e30;

            font-size: 11px;
            line-height: 1.5;
        }

        .unavailable-message {
            margin-top: 13px;

            padding: 10px 12px;

            background: #fff8e7;

            border: 1px solid #efdaa0;
            border-radius: 9px;

            color: #8a6100;

            font-size: 10px;
            line-height: 1.5;
        }


        /* =====================================================
           FOOTER
        ===================================================== */

        .request-footer {
            display: flex;
            justify-content: flex-end;
            align-items: center;

            gap: 9px;

            padding: 17px 23px;
        }

        .btn-cancel,
        .btn-submit {
            min-width: 125px;
            height: 40px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            padding: 0 17px;

            border-radius: 9px;

            font-family: inherit;
            font-size: 11px;
            font-weight: 700;

            text-decoration: none;

            cursor: pointer;

            transition: 0.2s ease;
        }

        .btn-cancel {
            background: #ffffff;

            border: 1px solid #dce2e9;

            color: #536074;
        }

        .btn-cancel:hover {
            background: #f8f9fb;
        }

        .btn-submit {
            background: #a41f30;

            border: 1px solid #a41f30;

            color: #ffffff;

            box-shadow:
                0 4px 10px rgba(164, 31, 48, 0.14);
        }

        .btn-submit:hover:not(:disabled) {
            background: #8f1828;
        }

        .btn-submit:disabled {
            background: #c9cdd4;

            border-color: #c9cdd4;

            box-shadow: none;

            cursor: not-allowed;
        }


        /* =====================================================
           RESPONSIVE
        ===================================================== */

        @media (max-width: 1250px) {

            .inventory-request-page {
                padding: 28px 26px 45px;
            }

            .item-information-grid {
                grid-template-columns:
                    repeat(4, minmax(0, 1fr));
            }
        }

        @media (max-width: 1000px) {

            .item-information-grid {
                grid-template-columns:
                    repeat(3, minmax(0, 1fr));
            }
        }

        @media (max-width: 800px) {

            .inventory-request-page {
                padding: 22px 18px 38px;
            }

            .item-information-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 600px) {

            .inventory-request-page {
                padding: 17px 13px 28px;
            }

            .request-page-header {
                align-items: flex-start;
                margin-bottom: 18px;
            }

            .request-user {
                display: none;
            }

            .request-page-title h1 {
                font-size: 23px;
            }

            .request-card-header,
            .request-section,
            .request-footer {
                padding-left: 15px;
                padding-right: 15px;
            }

            .selected-item-top {
                flex-direction: column;

                padding-left: 14px;
                padding-right: 14px;
            }

            .item-information-grid {
                grid-template-columns: 1fr;

                padding-left: 14px;
                padding-right: 14px;
            }

            .item-description {
                margin-left: 14px;
                margin-right: 14px;
            }

            .request-footer {
                flex-direction: column-reverse;
            }

            .btn-cancel,
            .btn-submit {
                width: 100%;
            }
        }

    </style>

</head>

<body>

<div class="app">

    <%-- =====================================================
         SIDEBAR STANDARD SISTEM PKB
    ====================================================== --%>

    <%@ include file="includes/sidebar.jspf" %>


    <main>

        <div class="inventory-request-page">

            <!-- =================================================
                 HEADER
            ================================================== -->

            <div class="request-page-header">

                <div class="request-page-title">

                    <h1>Permohonan Inventori</h1>

                    <p>
                        Lengkapkan maklumat untuk memohon inventori syarikat.
                    </p>

                </div>


                <div class="request-header-actions">

                    <a
                        href="<%= request.getContextPath() %>/notifications"
                        class="notification-button"
                        title="Notifikasi"
                        aria-label="Notifikasi"
                    >

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            aria-hidden="true"
                        >
                            <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"></path>
                            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                        </svg>

                    </a>


                    <div class="request-user">

                        <div class="request-user-avatar">
                            <%= htmlEscape(userInitial) %>
                        </div>

                        <div class="request-user-details">

                            <span class="request-user-name">
                                <%= htmlEscape(userName) %>
                            </span>

                            <% if (
                                roleDisplay != null &&
                                !roleDisplay.trim().isEmpty()
                            ) { %>

                                <span class="request-user-role">
                                    <%= htmlEscape(roleDisplay) %>
                                </span>

                            <% } %>

                        </div>

                    </div>

                </div>

            </div>


            <!-- =================================================
                 MAIN CARD
            ================================================== -->

            <div class="request-card">

                <div class="request-card-header">

                    <h2>Butiran Permohonan</h2>

                    <p>
                        Semak barang yang dipilih sebelum menghantar permohonan.
                    </p>

                </div>


                <!-- =================================================
                     ITEM
                ================================================== -->

                <div class="request-section">

                    <div class="section-title">

                        <div class="section-icon">
                            ▣
                        </div>

                        <div>

                            <h3>Inventori Dipilih</h3>

                            <p>
                                Maklumat inventori yang ingin dipohon
                            </p>

                        </div>

                    </div>


                    <div class="selected-item-card">

                        <div class="selected-item-top">

                            <div class="selected-item-name">

                                <h3>
                                    <%= htmlEscape(itemName) %>
                                </h3>

                                <p>
                                    Kod Barang:
                                    <strong>
                                        <%= htmlEscape(itemCode) %>
                                    </strong>
                                </p>

                            </div>


                            <span class="status-badge <%= statusClass %>">
                                <%= htmlEscape(statusText) %>
                            </span>

                        </div>


                        <div class="item-information-grid">

                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Jenama
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(brand) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Saiz / Variasi
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(size) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Warna
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(color) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Kategori
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(category) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Jenis
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(typeText) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Keadaan
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(conditionText) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Lokasi
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(location) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Unit
                                </span>

                                <span class="item-info-value">
                                    <%= htmlEscape(unit) %>
                                </span>

                            </div>


                            <div class="item-info-box">

                                <span class="item-info-label">
                                    Jumlah Kuantiti
                                </span>

                                <span class="item-info-value">

                                    <%= quantity %>

                                    <small>
                                        <%= htmlEscape(unit) %>
                                    </small>

                                </span>

                            </div>


                            <div class="item-info-box stock">

                                <span class="item-info-label">
                                    Kuantiti Tersedia
                                </span>

                                <span class="item-info-value">

                                    <%= availableQuantity %>

                                    <small>
                                        <%= htmlEscape(unit) %>
                                    </small>

                                </span>

                            </div>

                        </div>


                        <% if (
                            description != null &&
                            !description.trim().isEmpty() &&
                            !"-".equals(description)
                        ) { %>

                            <div class="item-description">

                                <span class="item-info-label">
                                    Keterangan
                                </span>

                                <p>
                                    <%= htmlEscape(description) %>
                                </p>

                            </div>

                        <% } %>

                    </div>

                </div>


                <!-- =================================================
                     FORM
                ================================================== -->

                <form
                    method="post"
                    action="<%= request.getContextPath() %>/inventory-request"
                    id="inventoryRequestForm"
                >

                    <input
                        type="hidden"
                        name="itemId"
                        value="<%= itemId %>"
                    >


                    <div class="request-section">

                        <div class="section-title">

                            <div class="section-icon">
                                ✎
                            </div>

                            <div>

                                <h3>Maklumat Permohonan</h3>

                                <p>
                                    Masukkan kuantiti yang ingin dimohon
                                </p>

                            </div>

                        </div>


                        <!-- ERROR -->

                        <% if (
                            error != null &&
                            !error.trim().isEmpty()
                        ) { %>

                            <div class="request-alert">

                                <% if ("stock".equals(error)) { %>

                                    Kuantiti yang dimohon melebihi stok yang tersedia.

                                <% } else if ("quantity".equals(error)) { %>

                                    Sila masukkan kuantiti yang sah.

                                <% } else if ("unavailable".equals(error)) { %>

                                    Inventori ini tidak tersedia untuk permohonan.

                                <% } else { %>

                                    Permohonan tidak dapat diproses.
                                    Sila cuba semula.

                                <% } %>

                            </div>

                        <% } %>


                        <!-- QUANTITY -->

                        <div class="form-group">

                            <label
                                for="quantity"
                                class="form-label"
                            >
                                Kuantiti
                                <span class="required">*</span>
                            </label>


                            <div class="quantity-control">

                                <button
                                    type="button"
                                    class="quantity-button"
                                    onclick="decreaseQuantity()"
                                    aria-label="Kurangkan kuantiti"
                                    <%= !canRequest ? "disabled" : "" %>
                                >
                                    −
                                </button>


                                <input
                                    id="quantity"
                                    class="quantity-input"
                                    type="number"
                                    name="quantity"
                                    value="1"
                                    min="1"
                                    max="<%= availableQuantity %>"
                                    required
                                    <%= !canRequest ? "disabled" : "" %>
                                >


                                <button
                                    type="button"
                                    class="quantity-button"
                                    onclick="increaseQuantity()"
                                    aria-label="Tambah kuantiti"
                                    <%= !canRequest ? "disabled" : "" %>
                                >
                                    +
                                </button>

                            </div>


                            <div class="form-help">

                                Maksimum yang boleh dimohon:

                                <strong>
                                    <%= availableQuantity %>
                                    <%= htmlEscape(unit) %>
                                </strong>

                            </div>


                            <% if (!canRequest) { %>

                                <div class="unavailable-message">

                                    Barang ini tidak boleh dimohon pada masa ini
                                    kerana stok tidak tersedia atau status barang
                                    tidak aktif.

                                </div>

                            <% } %>

                        </div>


                        <!-- PURPOSE -->

                        <div class="form-group">

                            <label
                                for="purpose"
                                class="form-label"
                            >
                                Tujuan Permohonan

                                <span class="optional">
                                    (Pilihan)
                                </span>

                            </label>


                            <textarea
                                id="purpose"
                                name="purpose"
                                class="purpose-textarea"
                                maxlength="500"
                                placeholder="Contoh: Digunakan untuk mesyuarat, program syarikat atau tugasan rasmi..."
                            ></textarea>


                            <div class="form-help">

                                Ruangan ini tidak wajib diisi.
                                Jika perlu, terangkan tujuan penggunaan
                                inventori secara ringkas.

                            </div>

                        </div>

                    </div>


                    <!-- =================================================
                         BUTTONS
                    ================================================== -->

                    <div class="request-footer">

                        <a
                            href="<%= request.getContextPath() %>/inventory"
                            class="btn-cancel"
                        >
                            Batal
                        </a>


                        <button
                            type="submit"
                            class="btn-submit"
                            <%= !canRequest ? "disabled" : "" %>
                        >
                            Hantar Permohonan
                        </button>

                    </div>

                </form>

            </div>

        </div>

    </main>

</div>


<script>

    // =========================================================
    // QUANTITY
    // =========================================================

    const quantityInput =
        document.getElementById("quantity");

    const maxQuantity =
        <%= availableQuantity %>;


    function decreaseQuantity() {

        if (!quantityInput || quantityInput.disabled) {
            return;
        }

        let current =
            parseInt(quantityInput.value, 10);

        if (isNaN(current)) {
            current = 1;
        }

        if (current > 1) {
            quantityInput.value = current - 1;
        }
    }


    function increaseQuantity() {

        if (!quantityInput || quantityInput.disabled) {
            return;
        }

        let current =
            parseInt(quantityInput.value, 10);

        if (isNaN(current)) {
            current = 1;
        }

        if (current < maxQuantity) {
            quantityInput.value = current + 1;
        }
    }


    // =========================================================
    // MANUAL INPUT
    // =========================================================

    if (quantityInput) {

        quantityInput.addEventListener(
            "input",
            function () {

                if (this.disabled) {
                    return;
                }

                let value =
                    parseInt(this.value, 10);

                if (isNaN(value) || value < 1) {
                    this.value = 1;
                    return;
                }

                if (value > maxQuantity) {
                    this.value = maxQuantity;
                }
            }
        );


        quantityInput.addEventListener(
            "blur",
            function () {

                if (this.disabled) {
                    return;
                }

                let value =
                    parseInt(this.value, 10);

                if (isNaN(value) || value < 1) {
                    this.value = 1;
                    return;
                }

                if (value > maxQuantity) {
                    this.value = maxQuantity;
                }
            }
        );
    }


    // =========================================================
    // FORM VALIDATION
    // =========================================================

    const inventoryRequestForm =
        document.getElementById(
            "inventoryRequestForm"
        );


    if (inventoryRequestForm) {

        inventoryRequestForm.addEventListener(
            "submit",
            function (event) {

                if (!quantityInput) {
                    return;
                }

                const requestedQuantity =
                    parseInt(
                        quantityInput.value,
                        10
                    );


                if (
                    isNaN(requestedQuantity) ||
                    requestedQuantity < 1
                ) {

                    event.preventDefault();

                    alert(
                        "Sila masukkan kuantiti yang sah."
                    );

                    quantityInput.focus();

                    return;
                }


                if (
                    requestedQuantity >
                    maxQuantity
                ) {

                    event.preventDefault();

                    alert(
                        "Kuantiti yang dimohon melebihi stok yang tersedia."
                    );

                    quantityInput.value =
                        maxQuantity;

                    quantityInput.focus();
                }
            }
        );
    }

</script>

</body>
</html>