<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

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
%>

<%
    String role = (String) session.getAttribute("userRole");
    String name = (String) session.getAttribute("userName");

    if (session.getAttribute("userId") == null || name == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    if (name.isBlank()) {
        name = "Pengguna";
    }

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> requests =
        (List<Map<String, Object>>) request.getAttribute("requests");

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    int totalRequests = 0;
    int pendingRequests = 0;
    int approvedRequests = 0;
    int rejectedRequests = 0;
    int cancelledRequests = 0;

    if (requests != null) {
        totalRequests = requests.size();

        for (Map<String, Object> requestItem : requests) {

            String requestStatus =
                requestItem.get("status") == null
                    ? ""
                    : String.valueOf(requestItem.get("status"));

            if ("PENDING".equalsIgnoreCase(requestStatus)) {
                pendingRequests++;
            } else if ("APPROVED".equalsIgnoreCase(requestStatus)) {
                approvedRequests++;
            } else if ("REJECTED".equalsIgnoreCase(requestStatus)) {
                rejectedRequests++;
            } else if ("CANCELLED".equalsIgnoreCase(requestStatus)) {
                cancelledRequests++;
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

    <title>Permohonan Inventori Saya - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260927-inventory-request-v2"
    >

    <style>

        /* =========================================================
           PAGE
           ========================================================= */

        .inventory-requests-page {
            width: 100%;
            max-width: 1450px;
            margin: 0 auto;
            box-sizing: border-box;
        }


        /* =========================================================
           HEADER
           ========================================================= */

        .inventory-requests-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 24px;
            margin-bottom: 24px;
        }

        .inventory-requests-title {
            min-width: 0;
        }

        .inventory-requests-title h1 {
            margin: 0 0 6px;
            color: #172033;

            font-size: 28px;
            line-height: 1.2;
            font-weight: 700;

            letter-spacing: -0.4px;
        }

        .inventory-requests-title p {
            margin: 0;

            color: #7d8799;

            font-size: 14px;
            line-height: 1.5;
        }


        /* =========================================================
           TOP RIGHT
           ========================================================= */

        .inventory-header-actions {
            display: flex;
            align-items: center;
            gap: 10px;

            flex-shrink: 0;
        }

        .inventory-notification-button {
            position: relative;

            width: 46px;
            height: 46px;

            display: flex;
            align-items: center;
            justify-content: center;

            box-sizing: border-box;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 12px;

            color: #68758a;

            text-decoration: none;

            box-shadow:
                0 4px 14px rgba(31, 41, 61, 0.05);

            transition:
                background 0.18s ease,
                border-color 0.18s ease,
                transform 0.18s ease;
        }

        .inventory-notification-button:hover {
            background: #fff8f8;
            border-color: #e2c6ca;
            transform: translateY(-1px);
        }

        .inventory-notification-button svg {
            width: 20px;
            height: 20px;

            stroke: currentColor;
            fill: none;

            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .inventory-notification-dot {
            position: absolute;

            top: 8px;
            right: 8px;

            width: 7px;
            height: 7px;

            border-radius: 50%;

            background: #9d1f2e;

            border: 2px solid #ffffff;
        }


        /* USER CHIP */

        .inventory-user-chip {
            min-height: 46px;

            display: flex;
            align-items: center;

            gap: 10px;

            padding: 6px 13px 6px 7px;

            box-sizing: border-box;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 12px;

            box-shadow:
                0 4px 14px rgba(31, 41, 61, 0.05);
        }

        .inventory-user-avatar {
            width: 34px;
            height: 34px;

            display: grid;
            place-items: center;

            flex-shrink: 0;

            border-radius: 10px;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8e8
                );

            border: 1px solid #ecd7da;

            color: #8d1f2d;

            font-size: 13px;
            font-weight: 800;
        }

        .inventory-user-info {
            display: flex;
            flex-direction: column;

            min-width: 0;
        }

        .inventory-user-info strong {
            color: #172033;

            font-size: 13px;
            line-height: 1.3;
            font-weight: 700;

            white-space: nowrap;
        }

        .inventory-user-info span {
            margin-top: 2px;

            color: #929aa8;

            font-size: 10px;

            white-space: nowrap;
        }


        /* =========================================================
           MESSAGE
           ========================================================= */

        .modern-success,
        .modern-error {
            margin-bottom: 18px;

            padding: 13px 15px;

            border-radius: 10px;

            font-size: 13px;
            line-height: 1.5;
        }

        .modern-success {
            background: #eaf8f1;
            color: #20744b;

            border: 1px solid #ceeadd;
        }

        .modern-error {
            background: #fff0f2;
            color: #a72d39;

            border: 1px solid #efcdd2;
        }


        /* =========================================================
           SUMMARY
           ========================================================= */

        .request-summary {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 14px;

            margin-bottom: 22px;
        }

        .request-summary-card {
            position: relative;

            min-height: 100px;

            padding: 17px 19px;

            box-sizing: border-box;

            background: #ffffff;

            border: 1px solid #e7e9ef;
            border-radius: 14px;

            box-shadow:
                0 4px 15px rgba(27, 36, 53, 0.04);

            overflow: hidden;
        }

        .request-summary-card::before {
            content: "";

            position: absolute;

            left: 0;
            top: 14px;
            bottom: 14px;

            width: 3px;

            border-radius: 0 4px 4px 0;

            background:
                linear-gradient(
                    180deg,
                    #8d1f2d,
                    #d5a12b
                );
        }

        .request-summary-card span {
            display: block;

            color: #7f8999;

            font-size: 11px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        .request-summary-card strong {
            display: block;

            margin-top: 7px;

            color: #172033;

            font-size: 27px;
            line-height: 1;
            font-weight: 800;
        }

        .request-summary-card small {
            display: block;

            margin-top: 7px;

            color: #929aa8;

            font-size: 11px;
            line-height: 1.4;
        }


        /* =========================================================
           MAIN CARD
           ========================================================= */

        .requests-shell {
            width: 100%;

            background: #ffffff;

            border: 1px solid #e7e9ef;
            border-radius: 17px;

            box-shadow:
                0 7px 24px rgba(31, 41, 61, 0.05);

            overflow: hidden;
        }


        /* =========================================================
           CARD HEADER
           ========================================================= */

        .requests-shell-header {
            display: flex;
            justify-content: space-between;
            align-items: center;

            gap: 20px;

            padding: 21px 22px;

            border-bottom: 1px solid #eceef2;

            background:
                linear-gradient(
                    180deg,
                    #ffffff,
                    #fcfcfd
                );
        }

        .requests-shell-title {
            min-width: 0;
        }

        .requests-shell-title h2 {
            margin: 0 0 5px;

            color: #172033;

            font-size: 18px;
            line-height: 1.3;
            font-weight: 700;
        }

        .requests-shell-title p {
            margin: 0;

            color: #8992a2;

            font-size: 13px;
            line-height: 1.45;
        }


        /* =========================================================
           SEARCH
           ========================================================= */

        .requests-search {
            position: relative;

            width: 310px;

            flex-shrink: 0;
        }

        .requests-search-icon {
            position: absolute;

            left: 13px;
            top: 50%;

            width: 17px;
            height: 17px;

            transform: translateY(-50%);

            color: #929baa;

            pointer-events: none;
        }

        .requests-search-icon svg {
            width: 100%;
            height: 100%;

            stroke: currentColor;
            fill: none;

            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .requests-search input {
            width: 100%;
            height: 42px;

            box-sizing: border-box;

            padding: 0 14px 0 40px;

            background: #ffffff;

            border: 1px solid #dfe3e9;
            border-radius: 10px;

            color: #333d50;

            font-family: inherit;
            font-size: 12px;

            outline: none;

            transition:
                border-color 0.18s ease,
                box-shadow 0.18s ease;
        }

        .requests-search input::placeholder {
            color: #9ba4b3;
        }

        .requests-search input:focus {
            border-color: #a84754;

            box-shadow:
                0 0 0 3px rgba(141, 31, 45, 0.08);
        }


        /* =========================================================
           TOOLBAR
           ========================================================= */

        .requests-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 16px;

            padding: 12px 20px;

            background: #fafbfc;

            border-bottom: 1px solid #eceef2;
        }

        .requests-count {
            color: #7f8999;

            font-size: 12px;
            line-height: 1.4;
        }

        .requests-count strong {
            color: #8d1f2d;
            font-weight: 700;
        }


        /* =========================================================
           NEW REQUEST BUTTON
           ========================================================= */

        .new-inventory-request {
            display: inline-flex;
            align-items: center;
            justify-content: center;

            gap: 7px;

            min-height: 41px;

            padding: 9px 16px;

            box-sizing: border-box;

            border: 1px solid #8d1f2d;
            border-radius: 9px;

            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a72a3b
                );

            color: #ffffff !important;

            font-family: inherit;
            font-size: 11px;
            font-weight: 700;

            text-decoration: none;

            box-shadow:
                0 5px 14px rgba(141, 31, 45, 0.18);

            transition:
                transform 0.17s ease,
                box-shadow 0.17s ease,
                background 0.17s ease;
        }

        .new-inventory-request:hover {
            background:
                linear-gradient(
                    135deg,
                    #701722,
                    #8d1f2d
                );

            transform: translateY(-1px);

            box-shadow:
                0 7px 16px rgba(141, 31, 45, 0.22);
        }


        /* =========================================================
           TABLE
           ========================================================= */

        .requests-table-wrapper {
            width: 100%;

            overflow-x: auto;

            scrollbar-width: thin;
        }

        .requests-table {
            width: 100%;

            min-width: 0;

            border-collapse: collapse;

            table-layout: auto;
        }

        .requests-table thead th {
            padding: 14px 14px;

            background: #f9fafc;

            border-bottom: 1px solid #e9ebef;

            color: #737e91;

            font-size: 10px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: 0.35px;

            text-align: left;

            white-space: nowrap;
        }

        .requests-table tbody td {
            padding: 15px 14px;

            border-bottom: 1px solid #eef0f4;

            color: #535e70;

            font-size: 12px;
            line-height: 1.45;

            vertical-align: middle;
        }

        .requests-table tbody tr {
            transition: background 0.16s ease;
        }

        .requests-table tbody tr:hover {
            background: #fdfafa;
        }

        .requests-table tbody tr:last-child td {
            border-bottom: 0;
        }


        /* COLUMN WIDTH */

        .requests-table th:nth-child(1),
        .requests-table td:nth-child(1) {
            min-width: 190px;
        }

        .requests-table th:nth-child(2),
        .requests-table td:nth-child(2) {
            min-width: 130px;
        }

        .requests-table th:nth-child(3),
        .requests-table td:nth-child(3) {
            min-width: 95px;
        }

        .requests-table th:nth-child(4),
        .requests-table td:nth-child(4) {
            min-width: 160px;
        }

        .requests-table th:nth-child(5),
        .requests-table td:nth-child(5) {
            min-width: 140px;
        }

        .requests-table th:nth-child(6),
        .requests-table td:nth-child(6) {
            min-width: 135px;
        }

        .requests-table th:nth-child(7),
        .requests-table td:nth-child(7) {
            min-width: 160px;
        }


        .requests-table th:nth-child(8),
        .requests-table td:nth-child(8) {
            min-width: 235px;
        }


        /* =========================================================
           ITEM
           ========================================================= */

        .request-item-name {
            min-width: 175px;
        }

        .request-item-name strong {
            display: block;

            color: #293345;

            font-size: 13px;
            line-height: 1.35;
            font-weight: 700;
        }

        .request-item-name small {
            display: inline-flex;
            align-items: center;

            gap: 5px;

            margin-top: 5px;

            color: #929aa8;

            font-size: 10px;
            line-height: 1.3;
        }

        .request-item-name small::before {
            content: "";

            width: 5px;
            height: 5px;

            flex-shrink: 0;

            border-radius: 50%;

            background: #d5a12b;
        }


        /* =========================================================
           QUANTITY
           ========================================================= */

        .request-quantity {
            display: inline-flex;
            align-items: baseline;

            gap: 5px;

            padding: 6px 9px;

            background: #fff7f8;

            border: 1px solid #f0dde0;
            border-radius: 8px;
        }

        .request-quantity strong {
            color: #8d1f2d;

            font-size: 16px;
            line-height: 1;
            font-weight: 800;
        }

        .request-quantity span {
            color: #8e7e82;

            font-size: 10px;
            line-height: 1.2;
        }


        /* =========================================================
           PURPOSE
           ========================================================= */

        .request-purpose {
            max-width: 250px;

            color: #5e697b;

            font-size: 12px;
            line-height: 1.5;

            word-break: break-word;
        }


        /* =========================================================
           DATE
           ========================================================= */

        .request-date {
            color: #525e71;

            font-size: 12px;
            font-weight: 600;

            white-space: nowrap;
        }


        /* =========================================================
           STATUS
           ========================================================= */

        .request-status {
            display: inline-flex;
            align-items: center;

            gap: 6px;

            padding: 6px 10px;

            border-radius: 999px;

            font-size: 10px;
            line-height: 1.2;
            font-weight: 700;

            white-space: nowrap;
        }

        .request-status::before {
            content: "";

            width: 6px;
            height: 6px;

            flex-shrink: 0;

            border-radius: 50%;
        }

        .request-status.pending {
            background: #fff6e4;
            color: #916713;

            border: 1px solid #efdfba;
        }

        .request-status.pending::before {
            background: #c18a19;
        }

        .request-status.approved {
            background: #eaf8f1;
            color: #20744b;

            border: 1px solid #d0ebdd;
        }

        .request-status.approved::before {
            background: #24875a;
        }

        .request-status.rejected {
            background: #fff0f2;
            color: #a82e3a;

            border: 1px solid #efcfd4;
        }

        .request-status.rejected::before {
            background: #b53240;
        }

        .request-status.cancelled {
            background: #f2f3f5;
            color: #6d7582;

            border: 1px solid #e2e4e8;
        }

        .request-status.cancelled::before {
            background: #858d99;
        }


        /* =========================================================
           REMARKS
           ========================================================= */

        .request-remarks {
            max-width: 230px;

            color: #697385;

            font-size: 12px;
            line-height: 1.5;

            word-break: break-word;
        }

        .request-remarks.has-remark {
            padding: 7px 9px;

            border-radius: 8px;

            background: #faf7f3;

            border: 1px solid #eee5da;

            color: #675c4f;

            font-size: 11px;
        }



        /* =========================================================
           INVENTORY RETURN
           ========================================================= */

        .return-panel {
            min-width: 210px;
        }

        .return-progress {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .return-progress-main {
            color: #293345;
            font-size: 11px;
            font-weight: 700;
        }

        .return-progress-main strong {
            color: #20744b;
            font-size: 13px;
        }

        .return-progress-meta {
            color: #7f8999;
            font-size: 10px;
            line-height: 1.4;
        }

        .return-pending {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            width: fit-content;
            margin-top: 2px;
            padding: 5px 7px;
            border: 1px solid #efdfba;
            border-radius: 7px;
            background: #fff6e4;
            color: #916713;
            font-size: 9px;
            font-weight: 700;
        }

        .return-complete {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            width: fit-content;
            margin-top: 3px;
            padding: 5px 7px;
            border: 1px solid #d0ebdd;
            border-radius: 7px;
            background: #eaf8f1;
            color: #20744b;
            font-size: 9px;
            font-weight: 700;
        }

        .return-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 34px;
            margin-top: 8px;
            padding: 7px 11px;
            border: 1px solid #8d1f2d;
            border-radius: 8px;
            background: #ffffff;
            color: #8d1f2d;
            font-family: inherit;
            font-size: 10px;
            font-weight: 700;
            cursor: pointer;
            transition:
                background 0.17s ease,
                color 0.17s ease,
                transform 0.17s ease;
        }

        .return-button:hover {
            background: #8d1f2d;
            color: #ffffff;
            transform: translateY(-1px);
        }

        .return-not-applicable {
            color: #a0a7b2;
            font-size: 12px;
        }


        /* =========================================================
           RETURN MODAL
           ========================================================= */

        .return-modal {
            position: fixed;
            inset: 0;
            z-index: 99999;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 20px;
            box-sizing: border-box;
        }

        .return-modal.open {
            display: flex;
        }

        .return-modal-backdrop {
            position: absolute;
            inset: 0;
            background: rgba(20, 27, 40, 0.48);
            backdrop-filter: blur(2px);
        }

        .return-modal-card {
            position: relative;
            z-index: 1;
            width: min(520px, 100%);
            max-height: calc(100vh - 40px);
            overflow-y: auto;
            background: #ffffff;
            border: 1px solid #e3e6eb;
            border-radius: 16px;
            box-shadow: 0 24px 70px rgba(21, 29, 43, 0.22);
        }

        .return-modal-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 18px;
            padding: 20px 22px;
            border-bottom: 1px solid #eceef2;
        }

        .return-modal-header h3 {
            margin: 0;
            color: #172033;
            font-size: 18px;
            font-weight: 700;
        }

        .return-modal-header p {
            margin: 5px 0 0;
            color: #8992a2;
            font-size: 11px;
            line-height: 1.45;
        }

        .return-modal-close {
            width: 34px;
            height: 34px;
            flex-shrink: 0;
            border: 1px solid #e3e6eb;
            border-radius: 9px;
            background: #ffffff;
            color: #68758a;
            font-size: 19px;
            line-height: 1;
            cursor: pointer;
        }

        .return-modal-body {
            padding: 20px 22px 22px;
        }

        .return-item-card {
            margin-bottom: 17px;
            padding: 13px 14px;
            border: 1px solid #eee1e3;
            border-radius: 11px;
            background: #fffafb;
        }

        .return-item-card strong {
            display: block;
            color: #293345;
            font-size: 13px;
        }

        .return-item-card span {
            display: block;
            margin-top: 4px;
            color: #8c95a4;
            font-size: 10px;
        }

        .return-stats {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 9px;
            margin-bottom: 18px;
        }

        .return-stat {
            padding: 11px 12px;
            border: 1px solid #e7e9ef;
            border-radius: 10px;
            background: #fafbfc;
        }

        .return-stat span {
            display: block;
            color: #8992a2;
            font-size: 9px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.25px;
        }

        .return-stat strong {
            display: block;
            margin-top: 5px;
            color: #293345;
            font-size: 14px;
            font-weight: 800;
        }

        .return-field {
            margin-top: 14px;
        }

        .return-field label {
            display: block;
            margin-bottom: 6px;
            color: #4c5668;
            font-size: 11px;
            font-weight: 700;
        }

        .return-field input,
        .return-field textarea {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #dfe3e9;
            border-radius: 9px;
            background: #ffffff;
            color: #333d50;
            font-family: inherit;
            font-size: 12px;
            outline: none;
        }

        .return-field input {
            height: 42px;
            padding: 0 12px;
        }

        .return-field textarea {
            min-height: 90px;
            padding: 11px 12px;
            resize: vertical;
        }

        .return-field input:focus,
        .return-field textarea:focus {
            border-color: #a84754;
            box-shadow: 0 0 0 3px rgba(141, 31, 45, 0.08);
        }

        .return-help {
            margin-top: 6px;
            color: #929aa8;
            font-size: 10px;
            line-height: 1.4;
        }

        .return-modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 9px;
            margin-top: 20px;
        }

        .return-cancel-button,
        .return-submit-button {
            min-height: 39px;
            padding: 8px 14px;
            border-radius: 9px;
            font-family: inherit;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
        }

        .return-cancel-button {
            border: 1px solid #dfe3e9;
            background: #ffffff;
            color: #626d7f;
        }

        .return-submit-button {
            border: 1px solid #8d1f2d;
            background: #8d1f2d;
            color: #ffffff;
        }

        .return-submit-button:hover {
            background: #701722;
        }

        body.return-modal-open {
            overflow: hidden;
        }

        /* =========================================================
           EMPTY STATE
           ========================================================= */

        .request-empty {
            padding: 60px 20px !important;

            text-align: center;
        }

        .request-empty-icon {
            width: 52px;
            height: 52px;

            margin: 0 auto 13px;

            display: grid;
            place-items: center;

            border-radius: 15px;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8e8
                );

            border: 1px solid #f0dce0;

            color: #8d1f2d;

            font-size: 20px;
        }

        .request-empty strong {
            display: block;

            color: #374052;

            font-size: 14px;
            font-weight: 700;
        }

        .request-empty p {
            margin: 6px 0 16px;

            color: #929aa8;

            font-size: 12px;
        }


        /* =========================================================
           NO SEARCH RESULT
           ========================================================= */

        .no-request-search {
            display: none;

            padding: 40px 20px;

            border-top: 1px solid #eef0f4;

            text-align: center;

            color: #8992a1;

            font-size: 12px;
        }

        .no-request-search strong {
            display: block;

            margin-bottom: 5px;

            color: #4c5668;

            font-size: 13px;
            font-weight: 700;
        }



        /* =========================================================
           COMPACT TABLE - FIT WITHOUT HORIZONTAL SCROLL
           ========================================================= */

        .requests-table-wrapper {
            overflow-x: hidden;
            width: 100%;
        }

        .requests-table {
            width: 100%;
            min-width: 0 !important;
            table-layout: fixed;
        }

        .requests-table th,
        .requests-table td {
            min-width: 0 !important;
            white-space: normal;
            overflow-wrap: anywhere;
            word-break: normal;
            vertical-align: middle;
        }

        .requests-table th {
            padding: 11px 8px;
            font-size: 9px;
            line-height: 1.25;
        }

        .requests-table td {
            padding: 13px 8px;
            font-size: 10px;
            line-height: 1.35;
        }

        /* Barang */
        .requests-table th:nth-child(1),
        .requests-table td:nth-child(1) {
            width: 17%;
        }

        /* Kategori */
        .requests-table th:nth-child(2),
        .requests-table td:nth-child(2) {
            width: 10%;
        }

        /* Kuantiti */
        .requests-table th:nth-child(3),
        .requests-table td:nth-child(3) {
            width: 8%;
            text-align: center;
        }

        /* Tujuan */
        .requests-table th:nth-child(4),
        .requests-table td:nth-child(4) {
            width: 13%;
        }

        /* Tarikh */
        .requests-table th:nth-child(5),
        .requests-table td:nth-child(5) {
            width: 12%;
        }

        /* Status */
        .requests-table th:nth-child(6),
        .requests-table td:nth-child(6) {
            width: 11%;
        }

        /* Catatan */
        .requests-table th:nth-child(7),
        .requests-table td:nth-child(7) {
            width: 12%;
        }

        /* Pemulangan */
        .requests-table th:nth-child(8),
        .requests-table td:nth-child(8) {
            width: 17%;
        }

        .request-item-name {
            font-size: 11px;
        }

        .request-item-code,
        .request-purpose,
        .request-date,
        .request-remarks {
            font-size: 9px;
        }

        .quantity-badge,
        .status-badge {
            white-space: nowrap;
        }

        .return-panel {
            min-width: 0 !important;
            width: 100%;
        }

        .return-progress-main {
            font-size: 9px;
            line-height: 1.35;
        }

        .return-progress-main strong {
            font-size: 11px;
        }

        .return-progress-meta {
            font-size: 8px;
            line-height: 1.35;
        }

        .return-button {
            width: 100%;
            min-height: 31px;
            padding: 6px 5px;
            font-size: 9px;
            white-space: normal;
        }

        .return-pending,
        .return-complete {
            max-width: 100%;
            white-space: normal;
            font-size: 8px;
        }

        @media (max-width: 1100px) {
            .requests-table th {
                padding-left: 5px;
                padding-right: 5px;
                font-size: 8px;
            }

            .requests-table td {
                padding-left: 5px;
                padding-right: 5px;
                font-size: 9px;
            }

            .request-item-name {
                font-size: 10px;
            }

            .quantity-badge,
            .status-badge {
                padding-left: 6px;
                padding-right: 6px;
                font-size: 8px;
            }
        }

        /* =========================================================
           RESPONSIVE
           ========================================================= */

        @media (max-width: 1100px) {

            .request-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

        }


        @media (max-width: 900px) {

            .requests-shell-header {
                align-items: stretch;
                flex-direction: column;
            }

            .requests-search {
                width: 100%;
            }

        }


        @media (max-width: 700px) {

            .inventory-requests-header {
                align-items: stretch;
                flex-direction: column;
            }

            .inventory-header-actions {
                justify-content: flex-end;
            }

            .request-summary {
                grid-template-columns: 1fr;
            }

            .requests-toolbar {
                align-items: stretch;
                flex-direction: column;
            }

            .new-inventory-request {
                width: 100%;
            }

        }


        @media (max-width: 480px) {

            .return-stats {
                grid-template-columns: 1fr;
            }

            .return-modal {
                padding: 12px;
            }

            .return-modal-header,
            .return-modal-body {
                padding-left: 16px;
                padding-right: 16px;
            }

            .inventory-requests-title h1 {
                font-size: 24px;
            }

            .inventory-user-info span {
                display: none;
            }

            .inventory-user-chip {
                padding-right: 10px;
            }

            .request-summary-card {
                min-height: 92px;
            }

            .requests-shell-header {
                padding: 18px;
            }

            .requests-toolbar {
                padding: 12px 18px;
            }

        }

    
        /* =========================================================
   MOBILE LAYOUT MATCHING THE LEAVE APPLICATIONS PAGE
   ========================================================= */
@media (max-width: 480px) {
    .inventory-requests-header {
        position: relative;
        display: block;
        min-height: 44px;
        margin-bottom: 14px;
    }
    .inventory-requests-title {
        min-width: 0;
        padding-right: 104px;
    }
    .inventory-header-actions {
        position: absolute;
        top: 0;
        right: 0;
        z-index: 2;
        width: max-content;
        gap: 7px;
    }
    .inventory-notification-button { width: 40px; height: 40px; }
    .inventory-user-chip { min-width: 0; flex: 0 0 auto; padding: 5px; }
    .inventory-user-avatar { width: 30px; height: 30px; flex: 0 0 30px; }
    .inventory-user-info { display: none; }
    .inventory-requests-title h1 { font-size: 21px; line-height: 1.25; }
    .inventory-requests-title p { font-size: 12px; line-height: 1.4; }

    .request-summary {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 9px;
        margin-bottom: 14px;
    }
    .request-summary-card {
        min-width: 0;
        min-height: 68px;
        padding: 11px 12px;
        border-radius: 11px;
    }
    .request-summary-card span { font-size: 9px; line-height: 1.35; }
    .request-summary-card strong { margin-top: 5px; font-size: 20px; line-height: 1.1; }
    .request-summary-card small { display: none; }

    .requests-shell { overflow: hidden; border-radius: 12px; }
    .requests-shell-header { padding: 13px 14px; }
    .requests-shell-title h2 { font-size: 16px; }
    .requests-shell-title p { font-size: 11px; line-height: 1.4; }
    .requests-search { width: 100%; }
    .requests-search input { min-height: 38px; font-size: 12px; }
    .requests-toolbar {
        align-items: stretch;
        flex-direction: column;
        gap: 8px;
        padding: 10px 14px;
    }
    .new-inventory-request { width: 100%; min-height: 38px; font-size: 11px; }
    .requests-count { font-size: 11px; }

    .requests-table-wrapper {
        display: block;
        width: 100%;
        max-width: 100%;
        overflow-x: hidden;
        overflow-y: visible;
        scrollbar-width: none;
        -ms-overflow-style: none;
    }
    .requests-table-wrapper::-webkit-scrollbar { display: none; }
    .requests-table {
        display: block;
        width: 100%;
        min-width: 0;
        max-width: 100%;
        table-layout: auto;
        border-collapse: separate;
        border-spacing: 0;
    }
    .requests-table thead { display: none; }
    .requests-table tbody { display: block; width: 100%; }
    .requests-table tbody tr.request-data-row {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 7px 8px;
        width: auto;
        min-width: 0;
        height: auto;
        min-height: 0;
        margin: 0 10px 8px;
        padding: 11px 12px;
        border: 1px solid #e7eaf0;
        border-radius: 11px;
        background: #fff;
        box-shadow: 0 3px 10px rgba(27, 36, 53, .035);
        box-sizing: border-box;
    }
    .requests-table tbody tr.request-data-row td {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 3px;
        width: auto;
        min-width: 0;
        height: auto;
        padding: 7px 8px;
        border: 1px solid #eef0f4;
        border-radius: 8px;
        background: #fcfcfd;
        font-size: 11px;
        line-height: 1.4;
        text-align: left;
        white-space: normal;
        overflow-wrap: anywhere;
        box-sizing: border-box;
    }
    .requests-table tbody tr.request-data-row td::before {
        color: #8790a0;
        font-size: 9px;
        font-weight: 700;
        line-height: 1.3;
        text-transform: uppercase;
    }
    .requests-table tbody tr.request-data-row td:nth-child(1) { order: 1; grid-column: 1 / -1; }
    .requests-table tbody tr.request-data-row td:nth-child(2) { order: 2; }
    .requests-table tbody tr.request-data-row td:nth-child(3) { order: 3; }
    .requests-table tbody tr.request-data-row td:nth-child(4) { order: 4; }
    .requests-table tbody tr.request-data-row td:nth-child(5) { order: 5; }
    .requests-table tbody tr.request-data-row td:nth-child(6) { order: 6; }
    .requests-table tbody tr.request-data-row td:nth-child(7) { order: 7; }
    .requests-table tbody tr.request-data-row td:nth-child(8) { order: 8; grid-column: 1 / -1; }
    .requests-table tbody tr.request-data-row td:nth-child(1)::before { content: "Barang"; }
    .requests-table tbody tr.request-data-row td:nth-child(2)::before { content: "Kategori"; }
    .requests-table tbody tr.request-data-row td:nth-child(3)::before { content: "Kuantiti"; }
    .requests-table tbody tr.request-data-row td:nth-child(4)::before { content: "Tujuan"; }
    .requests-table tbody tr.request-data-row td:nth-child(5)::before { content: "Tarikh Permohonan"; }
    .requests-table tbody tr.request-data-row td:nth-child(6)::before { content: "Status"; }
    .requests-table tbody tr.request-data-row td:nth-child(7)::before { content: "Catatan"; }
    .requests-table tbody tr.request-data-row td:nth-child(8)::before { content: "Pemulangan"; }
    .request-item-name { min-width: 0; }
    .request-item-name strong { font-size: 12px; line-height: 1.35; overflow-wrap: anywhere; }
    .request-item-name small,
    .request-date,
    .request-purpose,
    .request-remarks { font-size: 10px; line-height: 1.35; }
    .request-status { max-width: 100%; padding: 4px 7px; font-size: 9px; white-space: normal; }
    .return-panel { width: 100%; min-width: 0; }
    .requests-table tbody tr:not(.request-data-row) td[colspan] {
        display: block;
        width: 100%;
        box-sizing: border-box;
    }
}

@media (max-width: 360px) {
    .inventory-requests-title { padding-right: 96px; }
    .inventory-header-actions { gap: 5px; }
    .inventory-notification-button { width: 36px; height: 36px; }
    .inventory-user-avatar { width: 28px; height: 28px; flex-basis: 28px; }
    .request-summary { gap: 7px; }
    .request-summary-card { padding: 9px 10px; }
    .requests-table tbody tr.request-data-row { margin-right: 7px; margin-left: 7px; padding: 9px; }
}
</style>
</head>


<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="inventory-requests-page">


            <!-- =====================================================
                 HEADER
                 ===================================================== -->

            <div class="inventory-requests-header">

                <div class="inventory-requests-title">

                    <h1>
                        Permohonan Inventori Saya
                    </h1>

                    <p>
                        Lihat dan semak status permohonan inventori anda
                    </p>

                </div>


                <div class="inventory-header-actions">

                    <!-- NOTIFICATION -->

                    <a
                        href="<%= request.getContextPath() %>/notifications"
                        class="inventory-notification-button"
                        title="Notifikasi"
                        aria-label="Notifikasi"
                    >

                        <svg viewBox="0 0 24 24">
                            <path
                                d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                            ></path>

                            <path
                                d="M10 21h4"
                            ></path>
                        </svg>

                    </a>


                    <!-- USER -->

                    <div class="inventory-user-chip">

                        <div class="inventory-user-avatar">

                            <%= htmlEscape(
                                name.substring(0, 1).toUpperCase()
                            ) %>

                        </div>

                        <div class="inventory-user-info">

                            <strong>
                                <%= htmlEscape(name) %>
                            </strong>

                            <span>
                                <%
                                    if ("HR".equalsIgnoreCase(role)) {
                                        out.print("HR Admin");
                                    } else if ("HOD".equalsIgnoreCase(role)) {
                                        out.print("Ketua Unit");
                                    } else {
                                        out.print("Staf");
                                    }
                                %>
                            </span>

                        </div>

                    </div>

                </div>

            </div>


                        <!-- =====================================================
                 MESSAGE
                 ===================================================== -->

            <%
                /*
                 * =====================================================
                 * MESSAGE FROM SERVLET
                 * =====================================================
                 */

                Object servletErrorObj = request.getAttribute("error");

                if (servletErrorObj != null) {

                    String servletError =
                        String.valueOf(servletErrorObj).trim();

                    if (!servletError.isBlank()) {
            %>

                <div class="modern-error">
                    <%= htmlEscape(servletError) %>
                </div>

            <%
                    }
                }
            %>


            <%
                /*
                 * =====================================================
                 * ERROR MESSAGE FROM URL
                 * =====================================================
                 */

                String errorMessage = null;

                if (
                    error != null &&
                    !error.isBlank()
                ) {

                    if ("stock".equalsIgnoreCase(error)) {

                        errorMessage =
                            "Kuantiti yang dimohon melebihi stok yang tersedia.";

                    } else if (
                        "quantity".equalsIgnoreCase(error)
                    ) {

                        errorMessage =
                            "Kuantiti yang dimasukkan tidak sah.";

                    } else if (
                        "return_quantity".equalsIgnoreCase(error)
                    ) {

                        errorMessage =
                            "Kuantiti pemulangan tidak sah.";

                    } else if (
                        "return_pending".equalsIgnoreCase(error)
                    ) {

                        errorMessage =
                            "Permohonan pemulangan bagi barang ini sedang menunggu tindakan HR.";

                    } else if (
                        "return_not_allowed".equalsIgnoreCase(error)
                    ) {

                        errorMessage =
                            "Barang ini tidak boleh dipulangkan.";

                    } else if (
                        "request_not_found".equalsIgnoreCase(error)
                    ) {

                        errorMessage =
                            "Maklumat permohonan inventori tidak dijumpai.";

                    } else {

                        errorMessage =
                            "Tindakan tidak dapat diproses. Sila cuba semula.";
                    }
                }


                if (errorMessage != null) {
            %>

                <div class="modern-error">
                    <%= htmlEscape(errorMessage) %>
                </div>

            <%
                }
            %>


            <%
                /*
                 * =====================================================
                 * SUCCESS MESSAGE
                 * =====================================================
                 */

                String successMessage = null;

                if (
                    success != null &&
                    !success.isBlank()
                ) {

                    /*
                     * Permohonan inventori baharu.
                     *
                     * Support kedua-dua parameter:
                     * ?success=requested
                     * ?success=submitted
                     */

                    if (
                        "requested".equalsIgnoreCase(success) ||
                        "submitted".equalsIgnoreCase(success)
                    ) {

                        successMessage =
                            "Permohonan inventori berjaya dihantar.";

                    } else if (
                        "cancelled".equalsIgnoreCase(success)
                    ) {

                        successMessage =
                            "Permohonan inventori berjaya dibatalkan.";

                    } else if (
                        "return_requested".equalsIgnoreCase(success) ||
                        "return-requested".equalsIgnoreCase(success)
                    ) {

                        successMessage =
                            "Permohonan pemulangan inventori berjaya dihantar untuk pengesahan HR.";

                    } else if (
                        "returned".equalsIgnoreCase(success)
                    ) {

                        successMessage =
                            "Pemulangan inventori berjaya direkodkan.";

                    } else {

                        /*
                         * Jangan paparkan raw parameter seperti:
                         * requested
                         * submitted
                         * return_requested
                         *
                         * Gunakan mesej umum jika parameter tidak dikenali.
                         */

                        successMessage =
                            "Permohonan inventori berjaya dihantar.";
                    }
                }


                if (successMessage != null) {
            %>

                <div class="modern-success">
                    <%= htmlEscape(successMessage) %>
                </div>

            <%
                }
            %>


            <!-- =====================================================
                 SUMMARY
                 ===================================================== -->

            <!-- =====================================================
                 SUMMARY
                 ===================================================== -->

            <div class="request-summary">

                <div class="request-summary-card">

                    <span>
                        Jumlah Permohonan
                    </span>

                    <strong>
                        <%= totalRequests %>
                    </strong>

                    <small>
                        Semua permohonan inventori
                    </small>

                </div>


                <div class="request-summary-card">

                    <span>
                        Menunggu Tindakan
                    </span>

                    <strong>
                        <%= pendingRequests %>
                    </strong>

                    <small>
                        Sedang diproses
                    </small>

                </div>


                <div class="request-summary-card">

                    <span>
                        Diluluskan
                    </span>

                    <strong>
                        <%= approvedRequests %>
                    </strong>

                    <small>
                        Permohonan diluluskan
                    </small>

                </div>


                <div class="request-summary-card">

                    <span>
                        Ditolak
                    </span>

                    <strong>
                        <%= rejectedRequests %>
                    </strong>

                    <small>
                        Permohonan tidak diluluskan
                    </small>

                </div>

            </div>


            <!-- =====================================================
                 REQUEST LIST
                 ===================================================== -->

            <div class="requests-shell">


                <!-- HEADER -->

                <div class="requests-shell-header">

                    <div class="requests-shell-title">

                        <h2>
                            Senarai Permohonan Inventori
                        </h2>

                        <p>
                            Jejaki status barang inventori yang telah anda mohon.
                        </p>

                    </div>


                    <div class="requests-search">

                        <span class="requests-search-icon">

                            <svg viewBox="0 0 24 24">
                                <circle
                                    cx="11"
                                    cy="11"
                                    r="7"
                                ></circle>

                                <path
                                    d="m20 20-3.5-3.5"
                                ></path>
                            </svg>

                        </span>

                        <input
                            type="text"
                            id="requestSearch"
                            placeholder="Cari barang, kod, kategori..."
                            onkeyup="searchRequests()"
                        >

                    </div>

                </div>


                <!-- =================================================
                     TOOLBAR
                     ================================================= -->

                <div class="requests-toolbar">

                    <div class="requests-count">

                        Memaparkan

                        <strong id="visibleRequestCount">
                            <%= totalRequests %>
                        </strong>

                        permohonan

                    </div>


                    <a
                        href="<%= request.getContextPath() %>/inventory"
                        class="new-inventory-request"
                    >
                        + Permohonan Baharu
                    </a>

                </div>


                <!-- =================================================
                     TABLE
                     ================================================= -->

                <div class="requests-table-wrapper">

                    <table class="requests-table">

                        <thead>

                            <tr>

                                <th>Barang</th>

                                <th>Kategori</th>

                                <th>Kuantiti</th>

                                <th>Tujuan</th>

                                <th>Tarikh Permohonan</th>

                                <th>Status</th>

                                <th>Catatan</th>

                                <th>Pemulangan</th>

                            </tr>

                        </thead>


                        <tbody id="requestTableBody">

                        <%
                            if (
                                requests != null &&
                                !requests.isEmpty()
                            ) {

                                for (
                                    Map<String, Object> item :
                                    requests
                                ) {

                                    String status =
                                        item.get("status") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get("status")
                                            );

                                    String statusClass =
                                        status
                                            .toLowerCase()
                                            .replace("_", "-");

                                    String statusDisplay =
                                        status;


                                    if (
                                        "PENDING".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                            "Menunggu Tindakan";

                                    } else if (
                                        "APPROVED".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                            "Diluluskan";

                                    } else if (
                                        "REJECTED".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                            "Ditolak";

                                    } else if (
                                        "CANCELLED".equalsIgnoreCase(
                                            status
                                        )
                                    ) {

                                        statusDisplay =
                                            "Dibatalkan";
                                    }


                                    String itemName =
                                        item.get("item_name") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get("item_name")
                                            );


                                    String itemCode =
                                        item.get("item_code") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get("item_code")
                                            );


                                    String category =
                                        item.get("category") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get("category")
                                            );


                                    String purpose =
                                        item.get("purpose") == null
                                            ? "-"
                                            : String.valueOf(
                                                item.get("purpose")
                                            );

                                    if (purpose.isBlank()) {
                                        purpose = "-";
                                    }


                                    String remarks =
                                        item.get("remarks") == null
                                            ? ""
                                            : String.valueOf(
                                                item.get("remarks")
                                            ).trim();


                                    /*
                                     * UNIT
                                     *
                                     * Cuba beberapa key yang lazim.
                                     * Jika servlet belum menghantar unit,
                                     * gunakan "unit" sebagai fallback.
                                     */

                                    String itemUnit = "unit";

                                    if (
                                        item.get("unit") != null &&
                                        !String.valueOf(
                                            item.get("unit")
                                        ).isBlank()
                                    ) {

                                        itemUnit =
                                            String.valueOf(
                                                item.get("unit")
                                            );

                                    } else if (
                                        item.get("item_unit") != null &&
                                        !String.valueOf(
                                            item.get("item_unit")
                                        ).isBlank()
                                    ) {

                                        itemUnit =
                                            String.valueOf(
                                                item.get("item_unit")
                                            );

                                    } else if (
                                        item.get("unit_name") != null &&
                                        !String.valueOf(
                                            item.get("unit_name")
                                        ).isBlank()
                                    ) {

                                        itemUnit =
                                            String.valueOf(
                                                item.get("unit_name")
                                            );
                                    }


                                    int requestId =
                                        item.get("id") instanceof Number
                                            ? ((Number) item.get("id")).intValue()
                                            : 0;

                                    int approvedQuantity =
                                        item.get("quantity") instanceof Number
                                            ? ((Number) item.get("quantity")).intValue()
                                            : 0;

                                    int returnedQuantity =
                                        item.get("returned_quantity") instanceof Number
                                            ? ((Number) item.get("returned_quantity")).intValue()
                                            : 0;

                                    int pendingReturnQuantity =
                                        item.get("pending_return_quantity") instanceof Number
                                            ? ((Number) item.get("pending_return_quantity")).intValue()
                                            : 0;

                                    int remainingQuantity =
                                        item.get("remaining_quantity") instanceof Number
                                            ? ((Number) item.get("remaining_quantity")).intValue()
                                            : 0;

                                    boolean canReturn =
                                        Boolean.TRUE.equals(
                                            item.get("can_return")
                                        );

                                    boolean hasPendingReturn =
                                        Boolean.TRUE.equals(
                                            item.get("has_pending_return")
                                        );

                                    boolean fullyReturned =
                                        Boolean.TRUE.equals(
                                            item.get("fully_returned")
                                        );

                                    boolean partiallyReturned =
                                        Boolean.TRUE.equals(
                                            item.get("partially_returned")
                                        );
                        %>


                            <tr class="request-data-row">


                                <!-- ITEM -->

                                <td>

                                    <div class="request-item-name">

                                        <strong>
                                            <%= htmlEscape(itemName) %>
                                        </strong>

                                        <small>
                                            Kod:
                                            <%= htmlEscape(itemCode) %>
                                        </small>

                                    </div>

                                </td>


                                <!-- CATEGORY -->

                                <td>
                                    <%= htmlEscape(category) %>
                                </td>


                                <!-- QUANTITY -->

                                <td>

                                    <span class="request-quantity">

                                        <strong>

                                            <%= item.get("quantity") != null
                                                ? htmlEscape(
                                                    item.get("quantity")
                                                )
                                                : "0"
                                            %>

                                        </strong>

                                        <span>
                                            <%= htmlEscape(itemUnit) %>
                                        </span>

                                    </span>

                                </td>


                                <!-- PURPOSE -->

                                <td>

                                    <div class="request-purpose">
                                        <%= htmlEscape(purpose) %>
                                    </div>

                                </td>


                                <!-- DATE -->

                                <td>

                                    <span class="request-date">

                                    <%
                                        Object requestedAtObj =
                                            item.get("requested_at");

                                        if (
                                            requestedAtObj instanceof
                                            Timestamp
                                        ) {

                                            Timestamp requestedAt =
                                                (Timestamp)
                                                requestedAtObj;

                                            LocalDate requestedDate =
                                                requestedAt
                                                    .toLocalDateTime()
                                                    .toLocalDate();

                                            DateTimeFormatter formatter =
                                                DateTimeFormatter
                                                    .ofPattern(
                                                        "dd/MM/yyyy"
                                                    );
                                    %>

                                        <%= requestedDate.format(
                                            formatter
                                        ) %>

                                    <%
                                        } else if (
                                            requestedAtObj != null
                                        ) {
                                    %>

                                        <%= htmlEscape(
                                            requestedAtObj
                                        ) %>

                                    <%
                                        } else {
                                    %>

                                        —

                                    <%
                                        }
                                    %>

                                    </span>

                                </td>


                                <!-- STATUS -->

                                <td>

                                    <span
                                        class="request-status <%= statusClass %>"
                                    >

                                        <%= statusDisplay.isBlank()
                                            ? "-"
                                            : htmlEscape(
                                                statusDisplay
                                            )
                                        %>

                                    </span>

                                </td>


                                <!-- REMARKS -->

                                <td>

                                    <div
                                        class="request-remarks <%= !remarks.isBlank()
                                            ? "has-remark"
                                            : ""
                                        %>"
                                    >

                                        <%= remarks.isBlank()
                                            ? "—"
                                            : htmlEscape(remarks)
                                        %>

                                    </div>

                                </td>


                                <!-- RETURN -->

                                <td>

                                    <%
                                        if (
                                            "APPROVED".equalsIgnoreCase(
                                                status
                                            )
                                        ) {
                                    %>

                                        <div class="return-panel">

                                            <div class="return-progress">

                                                <div class="return-progress-main">

                                                    <strong>
                                                        <%= returnedQuantity %>
                                                    </strong>

                                                    /
                                                    <%= approvedQuantity %>
                                                    <%= htmlEscape(itemUnit) %>

                                                    dipulangkan

                                                </div>


                                                <div class="return-progress-meta">

                                                    Baki boleh dipulangkan:
                                                    <strong>
                                                        <%= remainingQuantity %>
                                                        <%= htmlEscape(itemUnit) %>
                                                    </strong>

                                                </div>


                                                <%
                                                    if (
                                                        hasPendingReturn
                                                    ) {
                                                %>

                                                    <span class="return-pending">

                                                        Menunggu HR:
                                                        <%= pendingReturnQuantity %>
                                                        <%= htmlEscape(itemUnit) %>

                                                    </span>

                                                <%
                                                    }
                                                %>


                                                <%
                                                    if (
                                                        fullyReturned
                                                    ) {
                                                %>

                                                    <span class="return-complete">
                                                        ✓ Dipulangkan Sepenuhnya
                                                    </span>

                                                <%
                                                    }
                                                %>

                                            </div>


                                            <%
                                                if (canReturn) {
                                            %>

                                                <button
                                                    type="button"
                                                    class="return-button"
                                                    onclick="openReturnModal(this)"
                                                    data-request-id="<%= requestId %>"
                                                    data-item-name="<%= htmlEscape(itemName) %>"
                                                    data-item-code="<%= htmlEscape(itemCode) %>"
                                                    data-unit="<%= htmlEscape(itemUnit) %>"
                                                    data-approved="<%= approvedQuantity %>"
                                                    data-returned="<%= returnedQuantity %>"
                                                    data-pending="<%= pendingReturnQuantity %>"
                                                    data-remaining="<%= remainingQuantity %>"
                                                >

                                                    <%= partiallyReturned || hasPendingReturn
                                                        ? "Pulangkan Baki"
                                                        : "Pulangkan Barang"
                                                    %>

                                                </button>

                                            <%
                                                }
                                            %>

                                        </div>

                                    <%
                                        } else {
                                    %>

                                        <span class="return-not-applicable">
                                            —
                                        </span>

                                    <%
                                        }
                                    %>

                                </td>

                            </tr>


                        <%
                                }

                            } else {
                        %>


                            <!-- EMPTY -->

                            <tr>

                                <td
                                    colspan="8"
                                    class="request-empty"
                                >

                                    <div class="request-empty-icon">
                                        ▣
                                    </div>

                                    <strong>
                                        Tiada Permohonan Inventori
                                    </strong>

                                    <p>
                                        Anda belum membuat sebarang permohonan inventori.
                                    </p>

                                    <a
                                        href="<%= request.getContextPath() %>/inventory"
                                        class="new-inventory-request"
                                    >
                                        Lihat Inventori
                                    </a>

                                </td>

                            </tr>


                        <%
                            }
                        %>

                        </tbody>

                    </table>

                </div>


                <!-- =================================================
                     SEARCH EMPTY
                     ================================================= -->

                <div
                    class="no-request-search"
                    id="noRequestSearch"
                >

                    <strong>
                        Tiada permohonan dijumpai
                    </strong>

                    Cuba gunakan kata carian yang lain.

                </div>


            </div>

        </div>

    </main>

</div>


<!-- =========================================================
     RETURN INVENTORY MODAL
     ========================================================= -->

<div
    class="return-modal"
    id="returnInventoryModal"
    aria-hidden="true"
>

    <div
        class="return-modal-backdrop"
        onclick="closeReturnModal()"
    ></div>


    <div
        class="return-modal-card"
        role="dialog"
        aria-modal="true"
        aria-labelledby="returnModalTitle"
    >

        <div class="return-modal-header">

            <div>

                <h3 id="returnModalTitle">
                    Pulangkan Inventori
                </h3>

                <p>
                    Hantar maklumat pemulangan untuk pengesahan HR.
                </p>

            </div>


            <button
                type="button"
                class="return-modal-close"
                onclick="closeReturnModal()"
                aria-label="Tutup"
            >
                ×
            </button>

        </div>


        <form
            method="post"
            action="<%= request.getContextPath() %>/inventory-return"
            id="returnInventoryForm"
        >

            <div class="return-modal-body">

                <input
                    type="hidden"
                    name="requestId"
                    id="returnRequestId"
                >


                <div class="return-item-card">

                    <strong id="returnItemName">
                        -
                    </strong>

                    <span id="returnItemCode">
                        Kod: -
                    </span>

                </div>


                <div class="return-stats">

                    <div class="return-stat">

                        <span>
                            Kuantiti Diluluskan
                        </span>

                        <strong id="returnApproved">
                            -
                        </strong>

                    </div>


                    <div class="return-stat">

                        <span>
                            Telah Dipulangkan
                        </span>

                        <strong id="returnReturned">
                            -
                        </strong>

                    </div>


                    <div class="return-stat">

                        <span>
                            Menunggu HR
                        </span>

                        <strong id="returnPending">
                            -
                        </strong>

                    </div>


                    <div class="return-stat">

                        <span>
                            Baki Boleh Dipulangkan
                        </span>

                        <strong id="returnRemaining">
                            -
                        </strong>

                    </div>

                </div>


                <div class="return-field">

                    <label for="returnQuantity">
                        Kuantiti Dipulangkan
                    </label>

                    <input
                        type="number"
                        name="quantity"
                        id="returnQuantity"
                        min="1"
                        step="1"
                        required
                    >

                    <div
                        class="return-help"
                        id="returnQuantityHelp"
                    >
                        Masukkan kuantiti barang yang hendak dipulangkan.
                    </div>

                </div>


                <div class="return-field">

                    <label for="returnRemarks">
                        Catatan
                        <span style="font-weight:400;color:#929aa8;">
                            (Pilihan)
                        </span>
                    </label>

                    <textarea
                        name="remarks"
                        id="returnRemarks"
                        maxlength="500"
                        placeholder="Contoh: Baki barang tidak digunakan."
                    ></textarea>

                </div>


                <div class="return-modal-actions">

                    <button
                        type="button"
                        class="return-cancel-button"
                        onclick="closeReturnModal()"
                    >
                        Batal
                    </button>


                    <button
                        type="submit"
                        class="return-submit-button"
                    >
                        Hantar Pemulangan
                    </button>

                </div>

            </div>

        </form>

    </div>

</div>


<script>

    function openReturnModal(button) {

        const modal =
            document.getElementById(
                "returnInventoryModal"
            );

        if (!modal || !button) {
            return;
        }


        const requestId =
            button.dataset.requestId || "";

        const itemName =
            button.dataset.itemName || "-";

        const itemCode =
            button.dataset.itemCode || "-";

        const unit =
            button.dataset.unit || "Unit";

        const approved =
            parseInt(
                button.dataset.approved || "0",
                10
            );

        const returned =
            parseInt(
                button.dataset.returned || "0",
                10
            );

        const pending =
            parseInt(
                button.dataset.pending || "0",
                10
            );

        const remaining =
            parseInt(
                button.dataset.remaining || "0",
                10
            );


        document.getElementById(
            "returnRequestId"
        ).value = requestId;


        document.getElementById(
            "returnItemName"
        ).textContent = itemName;


        document.getElementById(
            "returnItemCode"
        ).textContent =
            "Kod: " + itemCode;


        document.getElementById(
            "returnApproved"
        ).textContent =
            approved + " " + unit;


        document.getElementById(
            "returnReturned"
        ).textContent =
            returned + " " + unit;


        document.getElementById(
            "returnPending"
        ).textContent =
            pending + " " + unit;


        document.getElementById(
            "returnRemaining"
        ).textContent =
            remaining + " " + unit;


        const quantityInput =
            document.getElementById(
                "returnQuantity"
            );


        quantityInput.value =
            remaining > 0
                ? 1
                : 0;


        quantityInput.max =
            remaining;


        document.getElementById(
            "returnQuantityHelp"
        ).textContent =
            "Maksimum "
            +
            remaining
            +
            " "
            +
            unit
            +
            " boleh dihantar untuk pemulangan.";


        document.getElementById(
            "returnRemarks"
        ).value = "";


        modal.classList.add(
            "open"
        );


        modal.setAttribute(
            "aria-hidden",
            "false"
        );


        document.body.classList.add(
            "return-modal-open"
        );


        setTimeout(function() {

            quantityInput.focus();

        }, 50);
    }


    function closeReturnModal() {

        const modal =
            document.getElementById(
                "returnInventoryModal"
            );


        if (!modal) {
            return;
        }


        modal.classList.remove(
            "open"
        );


        modal.setAttribute(
            "aria-hidden",
            "true"
        );


        document.body.classList.remove(
            "return-modal-open"
        );
    }


    document.addEventListener(
        "keydown",
        function(event) {

            if (event.key === "Escape") {
                closeReturnModal();
            }
        }
    );


    const returnInventoryForm =
        document.getElementById(
            "returnInventoryForm"
        );


    if (returnInventoryForm) {

        returnInventoryForm.addEventListener(
            "submit",
            function(event) {

                const quantityInput =
                    document.getElementById(
                        "returnQuantity"
                    );


                const quantity =
                    parseInt(
                        quantityInput.value || "0",
                        10
                    );


                const maximum =
                    parseInt(
                        quantityInput.max || "0",
                        10
                    );


                if (
                    quantity < 1
                    ||
                    quantity > maximum
                ) {

                    event.preventDefault();

                    alert(
                        "Kuantiti pemulangan mestilah antara 1 hingga "
                        +
                        maximum
                        +
                        "."
                    );

                    quantityInput.focus();
                }
            }
        );
    }


    function searchRequests() {

        const input =
            document.getElementById(
                "requestSearch"
            );

        if (!input) {
            return;
        }

        const filter =
            input.value
                .toLowerCase()
                .trim();


        const rows =
            document.querySelectorAll(
                ".request-data-row"
            );


        let visibleCount = 0;


        rows.forEach(function(row) {

            const text =
                row.textContent
                    .toLowerCase();


            const visible =
                text.includes(filter);


            row.style.display =
                visible
                    ? ""
                    : "none";


            if (visible) {
                visibleCount++;
            }

        });


        const counter =
            document.getElementById(
                "visibleRequestCount"
            );


        if (counter) {

            counter.textContent =
                visibleCount;

        }


        const empty =
            document.getElementById(
                "noRequestSearch"
            );


        if (empty) {

            empty.style.display =
                rows.length > 0 &&
                visibleCount === 0
                    ? "block"
                    : "none";

        }

    }

</script>

</body>
</html>