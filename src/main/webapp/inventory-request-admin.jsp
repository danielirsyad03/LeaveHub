<%@ page contentType="text/html;charset=UTF-8" %>

<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>

<%
    String adminRole =
        (String) session.getAttribute("userRole");

    String adminName =
        (String) session.getAttribute("userName");

    // =========================================================
    // LOGIN CHECK
    // =========================================================
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(
            request.getContextPath() + "/"
        );
        return;
    }

    // =========================================================
    // HR ONLY
    // =========================================================
    if (
        adminRole == null ||
        !"HR".equalsIgnoreCase(adminRole.trim())
    ) {
        response.sendError(
            HttpServletResponse.SC_FORBIDDEN
        );
        return;
    }

    if (
        adminName == null ||
        adminName.isBlank()
    ) {
        adminName = "Pengguna";
    }

    // =========================================================
    // DATA
    // =========================================================
    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>>
        inventoryRequests =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("requests");

    int totalRequests =
        request.getAttribute("totalRequests") == null
            ? 0
            : ((Number)
                request.getAttribute("totalRequests"))
                .intValue();

    int pendingRequests =
        request.getAttribute("pendingRequests") == null
            ? 0
            : ((Number)
                request.getAttribute("pendingRequests"))
                .intValue();

    int approvedRequests =
        request.getAttribute("approvedRequests") == null
            ? 0
            : ((Number)
                request.getAttribute("approvedRequests"))
                .intValue();

    int rejectedRequests =
        request.getAttribute("rejectedRequests") == null
            ? 0
            : ((Number)
                request.getAttribute("rejectedRequests"))
                .intValue();

    int cancelledRequests =
        request.getAttribute("cancelledRequests") == null
            ? 0
            : ((Number)
                request.getAttribute("cancelledRequests"))
                .intValue();

    String success =
        request.getParameter("success");

    String error =
        request.getParameter("error");
%>

<!DOCTYPE html>

<html lang="ms">

<head>

<meta charset="UTF-8">

<meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
>

<title>
    Permohonan Inventori - PKB
</title>

<link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260927-inventory-request"
>

<style>

/* =========================================================
   PAGE
   SAME SCALE AS PENGURUSAN INVENTORI
   ========================================================= */

html,
body {
    max-width: 100%;
    overflow-x: hidden !important;
}

.inventory-request-admin-page {
    width: 100%;
    max-width: none;
    min-width: 0;

    box-sizing: border-box;

    font-size: 13px;
}

.inventory-request-admin-page *,
.inventory-request-admin-page *::before,
.inventory-request-admin-page *::after {
    box-sizing: border-box;
}


/* =========================================================
   HEADER
   ========================================================= */

.inventory-request-admin-header {

    display: flex;

    justify-content:
        space-between;

    align-items:
        center;

    gap: 18px;

    margin-bottom: 20px;
}

.inventory-request-admin-title h1 {
    margin: 0 0 4px;
    color: #172033;
    font-size: 24px;
    line-height: 1.2;
    font-weight: 700;
}

.inventory-request-admin-title p {

    margin: 0;

    color: #7d8799;

    font-size: 13px;

    line-height: 1.5;
}


/* =========================================================
   USER CHIP
   ========================================================= */

.inventory-request-admin-header .user-chip {

    font-size: 12px;
}


/* =========================================================
   MESSAGE
   ========================================================= */

.request-message {

    margin-bottom: 16px;

    padding: 11px 14px;

    border-radius: 10px;

    font-size: 12px;

    line-height: 1.5;
}

.request-message.success {

    background: #eaf8f1;

    color: #20744b;

    border:
        1px solid #ceeadd;
}

.request-message.error {

    background: #fff0f2;

    color: #a72d39;

    border:
        1px solid #efcdd2;
}


/* =========================================================
   STATISTIC CARDS
   ========================================================= */

.request-stats {

    display: grid;

    grid-template-columns:
        repeat(
            5,
            minmax(0, 1fr)
        );

    gap: 10px;

    margin-bottom: 18px;
}

.request-stat-card {

    position: relative;

    min-width: 0;

    min-height: 82px;

    padding: 12px 14px;

    overflow: hidden;

    background: #ffffff;

    border:
        1px solid #e7e9ef;

    border-radius: 12px;

    box-shadow:
        0 4px 14px
        rgba(27, 36, 53, .04);

    font-family: inherit;

    text-align: left;

    cursor: pointer;

    transition:
        border-color .15s ease,
        box-shadow .15s ease,
        transform .15s ease;
}

.request-stat-card::before {

    content: "";

    position: absolute;

    left: 0;

    top: 12px;

    bottom: 12px;

    width: 3px;

    border-radius:
        0 4px 4px 0;

    background: #e1e4e9;
}

.request-stat-card:hover {

    transform:
        translateY(-1px);

    border-color: #d7c2c6;

    box-shadow:
        0 6px 16px
        rgba(31, 41, 61, .06);
}

.request-stat-card.active {

    border-color: #d7b4ba;

    background:
        linear-gradient(
            135deg,
            #fffafa,
            #ffffff
        );

    box-shadow:
        0 5px 16px
        rgba(141, 31, 45, .07);
}

.request-stat-card.active::before {

    background:
        linear-gradient(
            180deg,
            #8d1f2d,
            #d5a12b
        );
}

.request-stat-card span {

    display: block;

    color: #8b94a4;

    font-size: 10px;

    font-weight: 700;

    line-height: 1.3;

    text-transform: uppercase;

    letter-spacing: .2px;
}

.request-stat-card strong {

    display: block;

    margin-top: 5px;

    color: #172033;

    font-size: 21px;

    line-height: 1.05;

    font-weight: 800;
}

.request-stat-card small {

    display: block;

    margin-top: 5px;

    color: #9ba3b1;

    font-size: 9.5px;

    line-height: 1.3;
}


/* =========================================================
   MAIN CARD
   ========================================================= */

.request-card {

    width: 100%;

    max-width: 100%;

    min-width: 0;

    overflow: hidden;

    background: #ffffff;

    border:
        1px solid #e7e9ef;

    border-radius: 14px;

    box-shadow:
        0 6px 20px
        rgba(31, 41, 61, .045);
}


/* =========================================================
   CARD HEADER
   ========================================================= */

.request-card-header {

    display: flex;

    justify-content:
        space-between;

    align-items:
        center;

    gap: 14px;

    padding: 16px 18px;

    border-bottom:
        1px solid #eceef2;

    background:
        linear-gradient(
            180deg,
            #ffffff,
            #fcfcfd
        );

    flex-wrap: wrap;
}

.request-card-title {

    flex:
        1 1 280px;

    min-width: 0;
}

.request-card-title h2 {

    margin: 0 0 3px;

    color: #172033;

    font-size: 17px;

    line-height: 1.3;

    font-weight: 750;

    letter-spacing: -.1px;
}

.request-card-title p {

    margin: 0;

    color: #8992a2;

    font-size: 11.5px;

    line-height: 1.45;
}


/* =========================================================
   CARD TOOLS
   ========================================================= */

.request-card-tools {

    display: flex;

    align-items: center;

    justify-content:
        flex-end;

    gap: 9px;

    min-width: 0;
}


/* =========================================================
   PRINT BUTTON
   ========================================================= */

.request-print-button {

    min-height: 36px;

    display: inline-flex;

    align-items: center;

    justify-content: center;

    gap: 6px;

    padding:
        0 12px;

    background:
        linear-gradient(
            135deg,
            #8d1f2d,
            #a72a3b
        );

    border:
        1px solid #8d1f2d;

    border-radius: 9px;

    color: #ffffff;

    font-size: 11.5px;

    font-weight: 700;

    text-decoration: none;

    white-space: nowrap;

    box-shadow:
        0 3px 9px
        rgba(141, 31, 45, .12);

    transition: .15s ease;
}

.request-print-button svg {

    width: 14px;

    height: 14px;

    fill: none;

    stroke: currentColor;

    stroke-width: 1.8;

    stroke-linecap: round;

    stroke-linejoin: round;
}

.request-print-button:hover {

    background:
        linear-gradient(
            135deg,
            #701722,
            #8d1f2d
        );

    transform:
        translateY(-1px);
}


/* =========================================================
   SEARCH
   ========================================================= */

.request-search {

    position: relative;

    width: 225px;

    max-width: 100%;
}

.request-search span {

    position: absolute;

    left: 11px;

    top: 50%;

    transform:
        translateY(-50%);

    color: #9aa2b1;

    font-size: 13px;

    pointer-events: none;
}

.request-search input {

    width: 100%;

    min-width: 0;

    height: 36px;

    padding:
        0 12px 0 34px;

    background: #ffffff;

    border:
        1px solid #dfe3e9;

    border-radius: 9px;

    color: #333d50;

    font-family: inherit;

    font-size: 11.5px;

    outline: none;
}

.request-search input::placeholder {

    color: #a0a7b4;
}

.request-search input:focus {

    border-color: #a84754;

    box-shadow:
        0 0 0 3px
        rgba(141, 31, 45, .07);
}


/* =========================================================
   TOOLBAR
   ========================================================= */

.request-toolbar {

    display: flex;

    justify-content:
        space-between;

    align-items: center;

    gap: 12px;

    padding:
        9px 18px;

    background: #fafbfc;

    border-bottom:
        1px solid #eceef2;

    flex-wrap: wrap;
}

.request-count {

    color: #8790a0;

    font-size: 11.5px;
}

.request-count strong {

    color: #8d1f2d;

    font-weight: 750;
}

.request-filter-indicator {

    display: inline-flex;

    align-items: center;

    padding:
        5px 8px;

    background: #fff7f8;

    border:
        1px solid #efdde0;

    border-radius: 999px;

    color: #8d1f2d;

    font-size: 10px;

    font-weight: 700;
}


/* =========================================================
   TABLE WRAPPER
   NO HORIZONTAL SCROLL
   ========================================================= */

.request-table-wrap {

    width: 100%;

    max-width: 100%;

    min-width: 0;

    overflow-x: hidden !important;

    overflow-y: visible;
}


/* =========================================================
   TABLE
   ========================================================= */

.request-table {

    width: 100% !important;

    max-width: 100% !important;

    min-width: 0 !important;

    table-layout: fixed;

    border-collapse: collapse;

    border-spacing: 0;
}


/* =========================================================
   TABLE HEADER
   SAME AS PENGURUSAN INVENTORI
   ========================================================= */

.request-table th {

    padding:
        10px 7px;

    background: #f9fafc;

    border-bottom:
        1px solid #e9ebef;

    color: #687386;

    font-size: 10px;

    font-weight: 700;

    line-height: 1.35;

    text-align: left;

    text-transform: uppercase;

    letter-spacing: .15px;

    vertical-align: middle;

    white-space: normal;

    overflow-wrap: anywhere;
}


/* =========================================================
   TABLE BODY
   ========================================================= */

.request-table td {

    padding:
        11px 7px;

    border-bottom:
        1px solid #eef0f4;

    color: #535e70;

    font-size: 12px;

    line-height: 1.45;

    vertical-align: middle;

    white-space: normal;

    overflow-wrap: anywhere;

    word-break: normal;

    min-width: 0;
}

.request-table tbody tr {

    transition:
        background .15s ease;
}

.request-table tbody tr:hover {

    background: #fdfafa;
}

.request-table tbody tr:last-child td {

    border-bottom: 0;
}


/* =========================================================
   COLUMN WIDTH
   TOTAL = 100%
   ========================================================= */

.request-table th:nth-child(1),
.request-table td:nth-child(1) {
    width: 13%;
}

.request-table th:nth-child(2),
.request-table td:nth-child(2) {
    width: 13%;
}

.request-table th:nth-child(3),
.request-table td:nth-child(3) {
    width: 9%;
}

.request-table th:nth-child(4),
.request-table td:nth-child(4) {

    width: 7%;

    text-align: center;
}

.request-table th:nth-child(5),
.request-table td:nth-child(5) {

    width: 8%;

    text-align: center;
}

.request-table th:nth-child(6),
.request-table td:nth-child(6) {
    width: 12%;
}

.request-table th:nth-child(7),
.request-table td:nth-child(7) {
    width: 11%;
}

.request-table th:nth-child(8),
.request-table td:nth-child(8) {

    width: 10%;

    text-align: center;
}

.request-table th:nth-child(9),
.request-table td:nth-child(9) {
    width: 17%;
}


/* =========================================================
   STAFF
   ========================================================= */

.request-staff {

    width: 100%;

    min-width: 0;
}

.request-staff strong {

    display: block;

    color: #293345;

    font-size: 13px;

    font-weight: 700;

    line-height: 1.4;

    white-space: normal;

    overflow-wrap: anywhere;
}

.request-staff small {

    display: block;

    margin-top: 3px;

    color: #919aa9;

    font-size: 10.5px;

    line-height: 1.35;

    white-space: normal;

    overflow-wrap: anywhere;
}


/* =========================================================
   ITEM
   ========================================================= */

.request-item {

    width: 100%;

    min-width: 0;
}

.request-item strong {

    display: block;

    color: #293345;

    font-size: 13px;

    font-weight: 700;

    line-height: 1.4;

    white-space: normal;

    overflow-wrap: anywhere;
}

.request-item small {

    display: block;

    margin-top: 3px;

    color: #919aa9;

    font-size: 10.5px;

    line-height: 1.35;

    white-space: normal;

    overflow-wrap: anywhere;
}


/* =========================================================
   QUANTITY
   ========================================================= */

.request-quantity {

    display: inline-flex;

    align-items: baseline;

    justify-content: center;

    gap: 3px;

    max-width: 100%;

    padding:
        4px 6px;

    background: #fff7f8;

    border:
        1px solid #f0dde0;

    border-radius: 7px;
}

.request-quantity strong {

    color: #8d1f2d;

    font-size: 13px;

    font-weight: 750;
}

.request-quantity span {

    color: #8e7e82;

    font-size: 9.5px;
}


/* =========================================================
   AVAILABLE STOCK
   ========================================================= */

.available-stock {

    display: inline-flex;

    align-items: baseline;

    justify-content: center;

    gap: 3px;

    max-width: 100%;
}

.available-stock strong {

    color: #3c4657;

    font-size: 13px;

    font-weight: 750;
}

.available-stock span {

    color: #939baa;

    font-size: 9.5px;
}


/* =========================================================
   PURPOSE
   ========================================================= */

.request-purpose {

    width: 100%;

    max-width: 100%;

    color: #626c7e;

    font-size: 12px;

    line-height: 1.45;

    white-space: normal;

    overflow-wrap: anywhere;
}


/* =========================================================
   DATE
   ========================================================= */

.request-date {

    display: block;

    color: #5b6577;

    font-size: 11px;

    font-weight: 600;

    line-height: 1.45;

    white-space: normal;
}


/* =========================================================
   STATUS
   ========================================================= */

.request-status {

    display: inline-flex;

    align-items: center;

    justify-content: center;

    gap: 5px;

    max-width: 100%;

    padding:
        4px 7px;

    border-radius: 999px;

    font-size: 10px;

    font-weight: 700;

    line-height: 1.25;

    text-align: center;

    white-space: normal;
}

.request-status::before {

    content: "";

    width: 5px;

    height: 5px;

    flex:
        0 0 5px;

    border-radius: 50%;
}

.request-status.pending {

    background: #fff6e4;

    color: #916713;

    border:
        1px solid #efdfba;
}

.request-status.pending::before {
    background: #c18a19;
}

.request-status.approved {

    background: #eaf8f1;

    color: #20744b;

    border:
        1px solid #d0ebdd;
}

.request-status.approved::before {
    background: #24875a;
}

.request-status.rejected {

    background: #fff0f2;

    color: #a82e3a;

    border:
        1px solid #efcfd4;
}

.request-status.rejected::before {
    background: #b53240;
}

.request-status.cancelled {

    background: #f2f3f5;

    color: #6d7582;

    border:
        1px solid #e2e4e8;
}

.request-status.cancelled::before {
    background: #858d99;
}


/* =========================================================
   ACTION
   ========================================================= */

.request-actions {

    display: flex;

    flex-direction: column;

    gap: 7px;

    width: 100%;

    min-width: 0;

    max-width: 100%;
}

.request-action-form {

    display: grid;

    grid-template-columns:
        minmax(0, 1fr)
        auto;

    align-items: center;

    gap: 6px;

    width: 100%;

    min-width: 0;

    max-width: 100%;

    margin: 0;
}


/* =========================================================
   ACTION INPUT
   ========================================================= */

.request-action-form input[type="text"] {

    width: 100%;

    min-width: 0;

    max-width: 100%;

    height: 32px;

    padding:
        0 7px;

    background: #ffffff;

    border:
        1px solid #dfe3e9;

    border-radius: 7px;

    color: #414b5e;

    font-family: inherit;

    font-size: 10.5px;

    outline: none;
}

.request-action-form input[type="text"]::placeholder {

    color: #a0a7b4;
}

.request-action-form input[type="text"]:focus {

    border-color: #a84754;

    box-shadow:
        0 0 0 2px
        rgba(141, 31, 45, .07);
}


/* =========================================================
   ACTION BUTTON
   ========================================================= */

.request-button {

    min-width: 52px;

    height: 32px;

    display: inline-flex;

    align-items: center;

    justify-content: center;

    padding:
        0 8px;

    border-radius: 7px;

    font-family: inherit;

    font-size: 10.5px;

    font-weight: 700;

    white-space: nowrap;

    cursor: pointer;

    transition: .15s ease;
}

.request-button.approve {

    background:
        linear-gradient(
            135deg,
            #8d1f2d,
            #a72a3b
        );

    color: #ffffff;

    border:
        1px solid #8d1f2d;
}

.request-button.approve:hover {

    background: #701722;
}

.request-button.reject {

    background: #ffffff;

    color: #a72d39;

    border:
        1px solid #e2bfc5;
}

.request-button.reject:hover {

    background: #fff0f2;
}


/* =========================================================
   PROCESSED REMARK
   ========================================================= */

.processed-remark {

    width: 100%;

    max-width: 100%;

    color: #697385;

    font-size: 11px;

    line-height: 1.45;

    white-space: normal;

    overflow-wrap: anywhere;
}

.processed-remark.has-remark {

    padding:
        6px 8px;

    background: #faf7f3;

    border:
        1px solid #eee5da;

    border-radius: 7px;

    color: #675c4f;
}


/* =========================================================
   EMPTY
   ========================================================= */

.request-empty {

    padding:
        48px 20px !important;

    text-align: center;
}

.request-empty-icon {

    width: 46px;

    height: 46px;

    display: grid;

    place-items: center;

    margin:
        0 auto 10px;

    border-radius: 13px;

    background:
        linear-gradient(
            135deg,
            #fff0f2,
            #fff8e8
        );

    border:
        1px solid #f0dce0;

    color: #8d1f2d;

    font-size: 18px;
}

.request-empty strong {

    display: block;

    color: #374052;

    font-size: 13px;
}

.request-empty p {

    margin:
        4px 0 0;

    color: #929aa8;

    font-size: 10.5px;
}

.empty-filter-message {

    display: none;

    padding:
        35px 20px;

    border-top:
        1px solid #eef0f4;

    text-align: center;

    color: #8993a6;

    font-size: 11px;
}

.empty-filter-message strong {

    display: block;

    margin-bottom: 4px;

    color: #4c5668;

    font-size: 13px;
}


/* =========================================================
   PREVENT HORIZONTAL OVERFLOW
   ========================================================= */

.request-table,
.request-table thead,
.request-table tbody,
.request-table tr,
.request-table th,
.request-table td,
.request-staff,
.request-item,
.request-purpose,
.request-actions,
.request-action-form {

    min-width:
        0 !important;
}

.request-table td *,
.request-table th * {

    max-width:
        100%;
}


/* =========================================================
   RESPONSIVE
   ========================================================= */

@media (max-width: 1200px) {

    .request-table th {

        padding:
            9px 5px;

        font-size:
            9.5px;
    }

    .request-table td {

        padding:
            10px 5px;

        font-size:
            11px;
    }

    .request-action-form {

        grid-template-columns:
            1fr;
    }

    .request-button {

        width: 100%;

        min-width: 0;
    }
}


@media (max-width: 1100px) {

    .request-stats {

        grid-template-columns:
            repeat(
                3,
                minmax(0, 1fr)
            );
    }
}


@media (max-width: 900px) {

    .request-stats {

        grid-template-columns:
            repeat(
                2,
                minmax(0, 1fr)
            );
    }

    .inventory-request-admin-header {

        flex-direction: column;

        align-items: stretch;
    }

    .request-card-header {

        align-items: stretch;

        flex-direction: column;
    }

    .request-card-tools {

        width: 100%;
    }

    .request-search {

        flex:
            1 1 auto;

        width: auto;
    }
}


@media (max-width: 650px) {

    .inventory-request-admin-title h1 {

        font-size: 22px;
    }

    .request-stats {

        grid-template-columns:
            1fr;
    }

    .request-toolbar {

        align-items: flex-start;

        flex-direction: column;
    }

    .request-card-tools {

        flex-direction: column;

        align-items: stretch;
    }

    .request-search,
    .request-print-button {

        width: 100%;
    }

    .request-table th {

        padding:
            8px 3px;

        font-size:
            8px;

        letter-spacing: 0;
    }

    .request-table td {

        padding:
            9px 3px;

        font-size:
            9px;
    }

    .request-staff strong,
    .request-item strong,
    .request-purpose {

        font-size: 9px;
    }

    .request-staff small,
    .request-item small,
    .request-date {

        font-size: 8px;
    }

    .request-status {

        padding: 4px;

        font-size: 7.5px;
    }
}

/* Shared compact mobile layout. */
@media (max-width: 650px) {
    main {
        width: 100% !important;
        max-width: 100vw !important;
        min-width: 0 !important;
        margin-left: 0 !important;
        padding: 74px 13px 28px !important;
        overflow-x: hidden !important;
    }

    .inventory-request-admin-page {
        width: 100% !important;
        max-width: 100% !important;
        min-width: 0 !important;
        margin: 0 !important;
        overflow-x: hidden !important;
    }

    .inventory-request-admin-header {
        position: relative !important;
        display: block !important;
        min-height: 42px !important;
        margin: 0 0 14px !important;
    }

    .inventory-request-admin-title {
        width: 100% !important;
        min-width: 0 !important;
        padding-right: 100px !important;
    }

    .inventory-request-admin-title h1 {
        margin: 0 0 5px !important;
        font-size: 23px !important;
        line-height: 1.2 !important;
    }

    .inventory-request-admin-title p {
        margin: 0 !important;
        font-size: 12px !important;
        line-height: 1.4 !important;
    }

    .inventory-request-header-actions {
        position: absolute !important;
        top: 0 !important;
        right: 0 !important;
        z-index: 10 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: flex-end !important;
        margin: 0 !important;
    }

    .inventory-request-header-actions .pkb-header-actions {
        display: flex !important;
        align-items: center !important;
        justify-content: flex-end !important;
        gap: 6px !important;
    }

    .inventory-request-header-actions .pkb-user-name {
        display: none !important;
    }

    .inventory-request-header-actions .pkb-notification-bell,
    .inventory-request-header-actions .pkb-user-chip {
        width: 42px !important;
        min-width: 42px !important;
        height: 42px !important;
        min-height: 42px !important;
        padding: 5px !important;
        justify-content: center !important;
    }

    .request-stats {
        grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
        gap: 9px !important;
        margin: 0 0 14px !important;
    }

    .request-stat-card {
        min-width: 0 !important;
        min-height: 76px !important;
        padding: 11px 12px !important;
        border-radius: 14px !important;
    }

    .request-stat-card span {
        font-size: 9px !important;
        line-height: 1.25 !important;
    }

    .request-stat-card strong {
        margin-top: 5px !important;
        font-size: 21px !important;
    }

    .request-stat-card small {
        margin-top: 4px !important;
        font-size: 9px !important;
        line-height: 1.25 !important;
    }

    .request-card {
        width: 100% !important;
        min-width: 0 !important;
        border-radius: 14px !important;
    }

    .request-card-header {
        align-items: stretch !important;
        gap: 10px !important;
        padding: 14px !important;
    }

    .request-card-title h2 {
        font-size: 15px !important;
    }

    .request-card-title p {
        font-size: 10px !important;
    }

    .request-card-tools {
        display: flex !important;
        flex-direction: column !important;
        align-items: stretch !important;
        gap: 7px !important;
        width: 100% !important;
    }

    .request-print-button,
    .request-search {
        width: 100% !important;
        min-width: 0 !important;
        min-height: 40px !important;
    }

    .request-toolbar {
        flex-direction: row !important;
        align-items: center !important;
        justify-content: space-between !important;
        gap: 8px !important;
        padding: 10px 13px !important;
    }

    .request-table-wrap {
        width: 100% !important;
        max-width: 100% !important;
        padding: 8px !important;
        overflow-x: hidden !important;
        background: #f5f7fa !important;
    }

    .request-table {
        display: block !important;
        width: 100% !important;
        min-width: 0 !important;
    }

    .request-table thead { display: none !important; }

    .request-table tbody {
        display: grid !important;
        grid-template-columns: minmax(0, 1fr) !important;
        gap: 8px !important;
        width: 100% !important;
    }

    .request-table tbody .inventory-request-row {
        display: grid !important;
        grid-template-columns: minmax(0, 1fr) auto !important;
        align-items: center !important;
        gap: 6px 9px !important;
        width: 100% !important;
        min-width: 0 !important;
        padding: 11px !important;
        border: 1px solid #dce2ea !important;
        border-left: 4px solid #a11f31 !important;
        border-radius: 12px !important;
        background: #fff !important;
        box-shadow: 0 2px 7px rgba(23, 32, 51, .06) !important;
    }

    .request-table tbody .inventory-request-row td {
        display: block !important;
        width: auto !important;
        min-width: 0 !important;
        padding: 0 !important;
        border: 0 !important;
        font-size: 10px !important;
        line-height: 1.3 !important;
        overflow-wrap: anywhere !important;
    }

    .request-table tbody .inventory-request-row td:nth-child(1) { grid-column: 1 / -1 !important; grid-row: 1 !important; }
    .request-table tbody .inventory-request-row td:nth-child(2) { grid-column: 1 !important; grid-row: 2 !important; }
    .request-table tbody .inventory-request-row td:nth-child(8) { grid-column: 2 !important; grid-row: 2 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(3) { grid-column: 1 !important; grid-row: 3 !important; }
    .request-table tbody .inventory-request-row td:nth-child(4) { grid-column: 2 !important; grid-row: 3 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(5) { grid-column: 1 !important; grid-row: 4 !important; }
    .request-table tbody .inventory-request-row td:nth-child(7) { grid-column: 2 !important; grid-row: 4 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(6) { grid-column: 1 / -1 !important; grid-row: 5 !important; }
    .request-table tbody .inventory-request-row td:nth-child(9) { grid-column: 1 / -1 !important; grid-row: 6 !important; padding-top: 8px !important; border-top: 1px solid #edf0f4 !important; }

    .request-staff strong,
    .request-item strong { font-size: 11px !important; line-height: 1.25 !important; }
    .request-staff small,
    .request-item small,
    .request-date { font-size: 9px !important; line-height: 1.25 !important; }
    .request-purpose { font-size: 9px !important; line-height: 1.3 !important; }
    .request-quantity strong,
    .available-stock strong { font-size: 13px !important; }
    .request-status { max-width: 85px !important; padding: 5px 7px !important; font-size: 8px !important; white-space: normal !important; text-align: center !important; }
    .request-actions,
    .request-action-form { display: grid !important; grid-template-columns: minmax(0,1fr) auto !important; gap: 5px !important; width: 100% !important; }
    .request-action-form input { grid-column: 1 / -1 !important; width: 100% !important; min-width: 0 !important; min-height: 34px !important; font-size: 10px !important; }
    .request-button { width: auto !important; min-width: 62px !important; min-height: 30px !important; padding: 5px 8px !important; font-size: 9px !important; }
}

/* Tighten the list header and reduce each request to a compact scan card. */
@media (max-width: 650px) {
    .request-card-header {
        display: flex !important;
        flex: 0 0 auto !important;
        flex-direction: column !important;
        justify-content: flex-start !important;
        align-items: stretch !important;
        gap: 8px !important;
        min-height: 0 !important;
        padding: 12px !important;
    }

    .request-card-title {
        flex: 0 0 auto !important;
        width: 100% !important;
        min-height: 0 !important;
    }

    .request-card-title h2 { margin-bottom: 2px !important; }
    .request-card-title p { line-height: 1.3 !important; }

    .request-card-tools {
        display: grid !important;
        grid-template-columns: minmax(0, 1fr) !important;
        gap: 6px !important;
        width: 100% !important;
    }

    .request-print-button,
    .request-search,
    .request-search input {
        min-height: 36px !important;
        height: 36px !important;
    }

    .request-toolbar { min-height: 0 !important; padding: 8px 12px !important; }
    .request-table-wrap { padding: 6px !important; }
    .request-table tbody { gap: 6px !important; }

    .request-table tbody .inventory-request-row {
        grid-template-columns: minmax(0, 1fr) minmax(0, 1fr) auto !important;
        gap: 4px 7px !important;
        padding: 8px !important;
        border-radius: 10px !important;
    }

    .request-table tbody .inventory-request-row td { line-height: 1.2 !important; }
    .request-table tbody .inventory-request-row td:nth-child(1) { grid-column: 1 / 3 !important; grid-row: 1 !important; }
    .request-table tbody .inventory-request-row td:nth-child(2) { grid-column: 1 / 3 !important; grid-row: 2 !important; }
    .request-table tbody .inventory-request-row td:nth-child(8) { grid-column: 3 !important; grid-row: 1 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(3) { grid-column: 1 !important; grid-row: 3 !important; }
    .request-table tbody .inventory-request-row td:nth-child(4) { grid-column: 3 !important; grid-row: 2 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(5) { grid-column: 2 !important; grid-row: 3 !important; }
    .request-table tbody .inventory-request-row td:nth-child(7) { grid-column: 3 !important; grid-row: 3 !important; justify-self: end !important; }
    .request-table tbody .inventory-request-row td:nth-child(6) { grid-column: 1 / -1 !important; grid-row: 4 !important; }
    .request-table tbody .inventory-request-row td:nth-child(9) { grid-column: 1 / -1 !important; grid-row: 5 !important; padding-top: 6px !important; }
    .request-staff strong,
    .request-item strong { font-size: 10px !important; }
    .request-staff small,
    .request-item small,
    .request-date,
    .request-purpose { font-size: 8px !important; }
    .request-purpose { display: -webkit-box !important; overflow: hidden !important; -webkit-box-orient: vertical; -webkit-line-clamp: 1; }
    .request-status { padding: 4px 6px !important; font-size: 7px !important; }
    .request-actions { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 6px !important; }
    .request-action-form { display: flex !important; flex-direction: column !important; align-items: stretch !important; gap: 4px !important; }
    .request-action-form input { min-height: 30px !important; height: 30px !important; padding: 0 7px !important; font-size: 9px !important; }
    .request-button { width: 100% !important; min-height: 28px !important; }
    .processed-remark { padding: 5px 7px !important; font-size: 8px !important; line-height: 1.2 !important; }
}

</style>

</head>


<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>


    <main>

        <div class="inventory-request-admin-page">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="inventory-request-admin-header">


                <div class="inventory-request-admin-title">

                    <h1>
                        Permohonan Inventori
                    </h1>

                    <p>
                        Semak dan urus permohonan inventori staf
                    </p>

                </div>


                <div class="inventory-request-header-actions">
                    <%@ include file="includes/header-actions.jspf" %>
                </div>


            </div>


            <!-- =================================================
                 SUCCESS MESSAGE
                 ================================================= -->

            <%
                if (
                    success != null &&
                    !success.isBlank()
                ) {
            %>

                <div class="request-message success">

                    <%
                        if (
                            "approved".equals(success)
                        ) {

                            out.print(
                                "Permohonan inventori berjaya diluluskan."
                            );

                        } else if (
                            "rejected".equals(success)
                        ) {

                            out.print(
                                "Permohonan inventori berjaya ditolak."
                            );

                        } else {

                            out.print(
                                "Tindakan berjaya dilaksanakan."
                            );
                        }
                    %>

                </div>

            <% } %>


            <!-- =================================================
                 ERROR MESSAGE
                 ================================================= -->

            <%
                if (
                    error != null &&
                    !error.isBlank()
                ) {
            %>

                <div class="request-message error">

                    <%
                        if (
                            "stock".equals(error)
                        ) {

                            out.print(
                                "Permohonan tidak dapat diluluskan kerana stok tidak mencukupi."
                            );

                        } else if (
                            "request".equals(error)
                        ) {

                            out.print(
                                "Permohonan inventori tidak ditemui."
                            );

                        } else if (
                            "processed".equals(error)
                        ) {

                            out.print(
                                "Permohonan ini telah diproses sebelum ini."
                            );

                        } else {

                            out.print(
                                "Tindakan tidak berjaya. Sila cuba semula."
                            );
                        }
                    %>

                </div>

            <% } %>


            <!-- =================================================
                 STATUS FILTER
                 ================================================= -->

            <div class="request-stats">


                <button
                    type="button"
                    class="request-stat-card active"
                    data-filter="ALL"
                >

                    <span>
                        Semua Permohonan
                    </span>

                    <strong>
                        <%= totalRequests %>
                    </strong>

                    <small>
                        Keseluruhan rekod
                    </small>

                </button>


                <button
                    type="button"
                    class="request-stat-card"
                    data-filter="PENDING"
                >

                    <span>
                        Menunggu Tindakan
                    </span>

                    <strong>
                        <%= pendingRequests %>
                    </strong>

                    <small>
                        Perlu diproses
                    </small>

                </button>


                <button
                    type="button"
                    class="request-stat-card"
                    data-filter="APPROVED"
                >

                    <span>
                        Diluluskan
                    </span>

                    <strong>
                        <%= approvedRequests %>
                    </strong>

                    <small>
                        Permohonan diluluskan
                    </small>

                </button>


                <button
                    type="button"
                    class="request-stat-card"
                    data-filter="REJECTED"
                >

                    <span>
                        Ditolak
                    </span>

                    <strong>
                        <%= rejectedRequests %>
                    </strong>

                    <small>
                        Permohonan ditolak
                    </small>

                </button>


                <button
                    type="button"
                    class="request-stat-card"
                    data-filter="CANCELLED"
                >

                    <span>
                        Dibatalkan
                    </span>

                    <strong>
                        <%= cancelledRequests %>
                    </strong>

                    <small>
                        Dibatalkan oleh staf
                    </small>

                </button>


            </div>


            <!-- =================================================
                 MAIN CARD
                 ================================================= -->

            <div class="request-card">


                <div class="request-card-header">


                    <div class="request-card-title">

                        <h2 id="requestTableTitle">
                            Semua Permohonan Inventori
                        </h2>

                        <p>
                            Permohonan yang masih menunggu tindakan dipaparkan terlebih dahulu.
                        </p>

                    </div>


                    <div class="request-card-tools">


                        <a
                            href="<%= request.getContextPath() %>/print-inventory-request-list"
                            class="request-print-button"
                        >

                            <svg
                                viewBox="0 0 24 24"
                                aria-hidden="true"
                            >
                                <path
                                    d="M6 9V3h12v6"
                                ></path>

                                <path
                                    d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"
                                ></path>

                                <rect
                                    x="6"
                                    y="14"
                                    width="12"
                                    height="7"
                                ></rect>
                            </svg>

                            Cetak Senarai Permohonan

                        </a>


                        <div class="request-search">

                            <span>
                                ⌕
                            </span>

                            <input
                                type="text"
                                id="requestSearch"
                                placeholder="Cari staf, barang, kategori..."
                                autocomplete="off"
                            >

                        </div>


                    </div>


                </div>


                <!-- =================================================
                     TOOLBAR
                     ================================================= -->

                <div class="request-toolbar">


                    <div class="request-count">

                        Memaparkan

                        <strong id="visibleRequestCount">
                            <%= totalRequests %>
                        </strong>

                        permohonan

                    </div>


                    <div
                        class="request-filter-indicator"
                        id="currentFilterIndicator"
                    >

                        Semua Permohonan

                    </div>


                </div>


                <!-- =================================================
                     TABLE
                     ================================================= -->

                <div class="request-table-wrap">


                    <table class="request-table">


                        <thead>

                            <tr>

                                <th>Staf</th>

                                <th>Barang</th>

                                <th>Kategori</th>

                                <th>Kuantiti</th>

                                <th>Stok Tersedia</th>

                                <th>Tujuan</th>

                                <th>Tarikh Permohonan</th>

                                <th>Status</th>

                                <th>Tindakan / Catatan</th>

                            </tr>

                        </thead>


                        <tbody id="requestTableBody">


<%

    if (
        inventoryRequests != null &&
        !inventoryRequests.isEmpty()
    ) {


        for (
            java.util.Map<String, Object> row :
            inventoryRequests
        ) {


            String rowStatus =
                row.get("status") == null
                    ? ""
                    : String.valueOf(
                        row.get("status")
                    );


            String rowRemarks =
                row.get("remarks") == null
                    ? ""
                    : String.valueOf(
                        row.get("remarks")
                    ).trim();


            String statusDisplay =
                rowStatus;


            String statusClass =
                rowStatus
                    .toLowerCase()
                    .replace("_", "-");


            if (
                "PENDING".equalsIgnoreCase(
                    rowStatus
                )
            ) {

                statusDisplay =
                    "Menunggu Tindakan";

            } else if (
                "APPROVED".equalsIgnoreCase(
                    rowStatus
                )
            ) {

                statusDisplay =
                    "Diluluskan";

            } else if (
                "REJECTED".equalsIgnoreCase(
                    rowStatus
                )
            ) {

                statusDisplay =
                    "Ditolak";

            } else if (
                "CANCELLED".equalsIgnoreCase(
                    rowStatus
                )
            ) {

                statusDisplay =
                    "Dibatalkan";
            }


            String staffName =
                row.get("staff_name") == null
                    ? "-"
                    : String.valueOf(
                        row.get("staff_name")
                    );


            String staffEmail =
                row.get("staff_email") == null
                    ? "-"
                    : String.valueOf(
                        row.get("staff_email")
                    );


            String itemName =
                row.get("item_name") == null
                    ? "-"
                    : String.valueOf(
                        row.get("item_name")
                    );


            String itemCode =
                row.get("item_code") == null
                    ? "-"
                    : String.valueOf(
                        row.get("item_code")
                    );


            String category =
                row.get("category") == null
                    ? "-"
                    : String.valueOf(
                        row.get("category")
                    );


            String purpose =
                row.get("purpose") == null
                    ? "-"
                    : String.valueOf(
                        row.get("purpose")
                    );


            if (purpose.isBlank()) {
                purpose = "-";
            }

%>


                            <tr
                                class="inventory-request-row"
                                data-status="<%= escapeHtml(rowStatus) %>"
                            >


                                <!-- STAFF -->

                                <td>

                                    <div class="request-staff">

                                        <strong>
                                            <%= escapeHtml(
                                                staffName
                                            ) %>
                                        </strong>

                                        <small>
                                            <%= escapeHtml(
                                                staffEmail
                                            ) %>
                                        </small>

                                    </div>

                                </td>


                                <!-- ITEM -->

                                <td>

                                    <div class="request-item">

                                        <strong>
                                            <%= escapeHtml(
                                                itemName
                                            ) %>
                                        </strong>

                                        <small>

                                            Kod:
                                            <%= escapeHtml(
                                                itemCode
                                            ) %>

                                        </small>

                                    </div>

                                </td>


                                <!-- CATEGORY -->

                                <td>

                                    <%= escapeHtml(
                                        category
                                    ) %>

                                </td>


                                <!-- QUANTITY -->

                                <td>

                                    <span class="request-quantity">

                                        <strong>
                                            <%= escapeHtml(
                                                row.get(
                                                    "quantity"
                                                )
                                            ) %>
                                        </strong>

                                        <span>
                                            unit
                                        </span>

                                    </span>

                                </td>


                                <!-- AVAILABLE STOCK -->

                                <td>

                                    <span class="available-stock">

                                        <strong>
                                            <%= escapeHtml(
                                                row.get(
                                                    "available_quantity"
                                                )
                                            ) %>
                                        </strong>

                                        <span>
                                            unit
                                        </span>

                                    </span>

                                </td>


                                <!-- PURPOSE -->

                                <td>

                                    <div class="request-purpose">

                                        <%= escapeHtml(
                                            purpose
                                        ) %>

                                    </div>

                                </td>


                                <!-- DATE -->

                                <td>

                                    <span class="request-date">

                                        <%= row.get(
                                                "requested_at"
                                            ) == null

                                                ? "—"

                                                : escapeHtml(
                                                    row.get(
                                                        "requested_at"
                                                    )
                                                )
                                        %>

                                    </span>

                                </td>


                                <!-- STATUS -->

                                <td>

                                    <span
                                        class="request-status <%= statusClass %>"
                                    >

                                        <%= escapeHtml(
                                            statusDisplay
                                        ) %>

                                    </span>

                                </td>


                                <!-- ACTION -->

                                <td>


<%

    if (
        "PENDING".equalsIgnoreCase(
            rowStatus
        )
    ) {

%>


                                    <div class="request-actions">


                                        <!-- APPROVE -->

                                        <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/inventory-request-admin"
                                            class="request-action-form"
                                            onsubmit="return confirm('Adakah anda pasti mahu meluluskan permohonan ini?');"
                                        >

                                            <input
                                                type="hidden"
                                                name="action"
                                                value="approve"
                                            >

                                            <input
                                                type="hidden"
                                                name="request_id"
                                                value="<%= escapeHtml(
                                                    row.get("id")
                                                ) %>"
                                            >

                                            <input
                                                type="text"
                                                name="remarks"
                                                maxlength="255"
                                                placeholder="Catatan (pilihan)"
                                            >

                                            <button
                                                type="submit"
                                                class="request-button approve"
                                            >
                                                Lulus
                                            </button>

                                        </form>


                                        <!-- REJECT -->

                                        <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/inventory-request-admin"
                                            class="request-action-form reject-form"
                                            onsubmit="return confirm('Adakah anda pasti mahu menolak permohonan ini?');"
                                        >

                                            <input
                                                type="hidden"
                                                name="action"
                                                value="reject"
                                            >

                                            <input
                                                type="hidden"
                                                name="request_id"
                                                value="<%= escapeHtml(
                                                    row.get("id")
                                                ) %>"
                                            >

                                            <input
                                                type="text"
                                                name="remarks"
                                                maxlength="255"
                                                placeholder="Sebab penolakan"
                                                required
                                            >

                                            <button
                                                type="submit"
                                                class="request-button reject"
                                            >
                                                Tolak
                                            </button>

                                        </form>


                                    </div>


<%

    } else {

%>


                                    <div
                                        class="processed-remark <%= !rowRemarks.isBlank()
                                            ? "has-remark"
                                            : ""
                                        %>"
                                    >

                                        <%= rowRemarks.isBlank()
                                            ? "—"
                                            : escapeHtml(
                                                rowRemarks
                                            )
                                        %>

                                    </div>


<%

    }

%>


                                </td>


                            </tr>


<%

        }

    } else {

%>


                            <tr>

                                <td
                                    colspan="9"
                                    class="request-empty"
                                >

                                    <div class="request-empty-icon">
                                        ▣
                                    </div>

                                    <strong>
                                        Tiada Permohonan Inventori
                                    </strong>

                                    <p>
                                        Belum ada permohonan inventori daripada staf.
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
                     EMPTY FILTER RESULT
                     ================================================= -->

                <div
                    class="empty-filter-message"
                    id="emptyFilterMessage"
                >

                    <strong>
                        Tiada permohonan dijumpai
                    </strong>

                    Tiada rekod yang sepadan dengan status atau carian semasa.

                </div>


            </div>


        </div>


    </main>


</div>


<script>

document.addEventListener(
    "DOMContentLoaded",
    function() {


        const tabs =
            document.querySelectorAll(
                ".request-stat-card"
            );


        const rows =
            document.querySelectorAll(
                ".inventory-request-row"
            );


        const title =
            document.getElementById(
                "requestTableTitle"
            );


        const emptyFilterMessage =
            document.getElementById(
                "emptyFilterMessage"
            );


        const searchInput =
            document.getElementById(
                "requestSearch"
            );


        const visibleCounter =
            document.getElementById(
                "visibleRequestCount"
            );


        const filterIndicator =
            document.getElementById(
                "currentFilterIndicator"
            );


        const titles = {

            ALL:
                "Semua Permohonan Inventori",

            PENDING:
                "Permohonan Menunggu Tindakan",

            APPROVED:
                "Permohonan Diluluskan",

            REJECTED:
                "Permohonan Ditolak",

            CANCELLED:
                "Permohonan Dibatalkan"

        };


        const indicators = {

            ALL:
                "Semua Permohonan",

            PENDING:
                "Menunggu Tindakan",

            APPROVED:
                "Diluluskan",

            REJECTED:
                "Ditolak",

            CANCELLED:
                "Dibatalkan"

        };


        let activeFilter =
            "ALL";


        // =====================================================
        // APPLY FILTER + SEARCH
        // =====================================================

        function applyFilters() {


            const searchText =
                searchInput
                    ? searchInput.value
                        .toLowerCase()
                        .trim()
                    : "";


            let visibleCount = 0;


            rows.forEach(
                function(row) {


                    const statusMatches =
                        activeFilter === "ALL"
                        ||
                        row.dataset.status ===
                            activeFilter;


                    const searchMatches =
                        row.textContent
                            .toLowerCase()
                            .includes(
                                searchText
                            );


                    const visible =
                        statusMatches &&
                        searchMatches;


                    row.style.display =
                        visible
                            ? ""
                            : "none";


                    if (visible) {
                        visibleCount++;
                    }

                }
            );


            if (visibleCounter) {

                visibleCounter.textContent =
                    visibleCount;
            }


            if (emptyFilterMessage) {

                emptyFilterMessage.style.display =
                    rows.length > 0 &&
                    visibleCount === 0

                        ? "block"
                        : "none";
            }

        }


        // =====================================================
        // FILTER CARD
        // =====================================================

        tabs.forEach(
            function(tab) {


                tab.addEventListener(
                    "click",
                    function() {


                        activeFilter =
                            this.dataset.filter;


                        tabs.forEach(
                            function(item) {

                                item.classList.remove(
                                    "active"
                                );

                            }
                        );


                        this.classList.add(
                            "active"
                        );


                        if (title) {

                            title.textContent =
                                titles[
                                    activeFilter
                                ]
                                ||
                                "Permohonan Inventori";
                        }


                        if (filterIndicator) {

                            filterIndicator.textContent =
                                indicators[
                                    activeFilter
                                ]
                                ||
                                "Semua Permohonan";
                        }


                        applyFilters();

                    }
                );

            }
        );


        // =====================================================
        // SEARCH
        // =====================================================

        if (searchInput) {

            searchInput.addEventListener(
                "input",
                applyFilters
            );

        }


        // =====================================================
        // INITIAL
        // =====================================================

        applyFilters();


    }
);

</script>


</body>

</html>
