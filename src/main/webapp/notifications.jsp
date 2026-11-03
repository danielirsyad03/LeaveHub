<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!

    private String notificationEscape(
            Object value) {

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


    private String notificationTypeClass(
            String type) {

        if (type == null) {
            return "info";
        }

        String value =
            type.trim().toUpperCase();


        if (value.contains("APPROVED")) {
            return "approved";
        }


        if (value.contains("REJECTED")) {
            return "rejected";
        }


        if (
            value.contains("HOD")
            ||
            value.contains("MANAGEMENT")
            ||
            value.contains("REVIEW")
            ||
            value.contains("PENDING")
        ) {
            return "pending";
        }


        return "info";
    }


    private String notificationDate(
            Object value) {

        if (!(value instanceof Timestamp)) {
            return "";
        }


        Timestamp timestamp =
            (Timestamp)value;


        DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern(
                "dd/MM/yyyy, hh:mm a"
            );


        return timestamp
            .toLocalDateTime()
            .format(formatter);
    }

%>


<%

    if (
        session.getAttribute("userId") == null
    ) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    @SuppressWarnings("unchecked")
    List<Map<String,Object>> notifications =
        (List<Map<String,Object>>)
            request.getAttribute(
                "notifications"
            );


    int unreadCount = 0;
    int totalCount = 0;


    Object unreadObject =
        request.getAttribute(
            "unreadCount"
        );


    if (unreadObject instanceof Number) {

        unreadCount =
            ((Number)unreadObject)
                .intValue();
    }


    Object totalObject =
        request.getAttribute(
            "totalCount"
        );


    if (totalObject instanceof Number) {

        totalCount =
            ((Number)totalObject)
                .intValue();
    }


    String currentFilter =
        request.getAttribute("filter") == null
            ? "all"
            : request.getAttribute("filter")
                .toString();


    String flashMessage =
        session.getAttribute(
            "notificationMessage"
        ) == null
            ? null
            : session.getAttribute(
                "notificationMessage"
            ).toString();


    session.removeAttribute(
        "notificationMessage"
    );

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
    Notifikasi - PKB
</title>


<link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260930-notification"
/>


<style>

    /* =========================================================
       PAGE
       ========================================================= */

    .notification-page {

        width: 100%;
        max-width: 1120px;

        margin: 0 auto;
    }


    /* =========================================================
       HEADER
       ========================================================= */

    .notification-page-header {

        display: flex;

        align-items: flex-start;
        justify-content: space-between;

        gap: 20px;

        margin-bottom: 22px;
    }


    .notification-page-title h1 {

        margin: 0 0 5px;

        color: #172033;

        font-size: 27px;
        font-weight: 650;
    }


    .notification-page-title p {

        margin: 0;

        color: #8490a3;

        font-size: 13px;
        font-weight: 400;
    }


    /* =========================================================
       TOOLBAR
       ========================================================= */

    .notification-toolbar {

        display: flex;

        align-items: center;
        justify-content: space-between;

        gap: 14px;

        margin-bottom: 16px;
    }


    .notification-filters {

        display: flex;

        align-items: center;

        gap: 8px;
    }


    .notification-filter {

        display: inline-flex;

        align-items: center;

        gap: 7px;

        padding: 8px 13px;

        background: #ffffff;

        border: 1px solid #dfe4eb;

        border-radius: 999px;

        color: #68758a;

        font-size: 11px;
        font-weight: 500;

        text-decoration: none;

        transition: .18s ease;
    }


    .notification-filter:hover {

        border-color: #d7b8bd;

        color: #8d1f2d;
    }


    .notification-filter.active {

        background: #fff7f8;

        border-color: #e6bcc3;

        color: #981c2c;
    }


    .filter-count {

        display: inline-flex;

        align-items: center;
        justify-content: center;

        min-width: 20px;
        height: 20px;

        padding: 0 6px;

        background: #f0f2f5;

        border-radius: 999px;

        color: #6c7788;

        font-size: 9px;
        font-weight: 600;
    }


    .notification-filter.active
    .filter-count {

        background: #f5dfe3;

        color: #8d1f2d;
    }


    /* =========================================================
       ACTION BUTTONS
       ========================================================= */

    .notification-actions {

        display: flex;

        align-items: center;

        gap: 8px;
    }


    .notification-action-form {

        margin: 0;
    }


    .notification-action-button {

        display: inline-flex;

        align-items: center;
        justify-content: center;

        gap: 7px;

        min-height: 36px;

        padding: 8px 13px;

        background: #ffffff;

        border: 1px solid #dfe4eb;

        border-radius: 9px;

        color: #566276;

        font-family: inherit;

        font-size: 11px;
        font-weight: 500;

        cursor: pointer;

        transition: .18s ease;
    }


    .notification-action-button:hover {

        border-color: #cdd3dc;

        background: #f8f9fb;

        color: #172033;
    }


    .notification-action-button.primary {

        background: #981c2c;

        border-color: #981c2c;

        color: #ffffff;
    }


    .notification-action-button.primary:hover {

        background: #801724;

        border-color: #801724;

        color: #ffffff;
    }


    .notification-action-button.danger {

        color: #a82b39;
    }


    .notification-action-button.danger:hover {

        background: #fff5f6;

        border-color: #edcdd1;

        color: #8d1f2d;
    }


    .notification-action-button svg {

        width: 15px;
        height: 15px;

        fill: none;

        stroke: currentColor;

        stroke-width: 1.8;

        stroke-linecap: round;
        stroke-linejoin: round;
    }


    /* =========================================================
       FLASH
       ========================================================= */

    .notification-flash {

        margin-bottom: 14px;

        padding: 11px 14px;

        background: #edf8f2;

        border: 1px solid #d1eadc;

        border-radius: 10px;

        color: #26724e;

        font-size: 11px;
        font-weight: 500;
    }


    /* =========================================================
       LIST
       ========================================================= */

    .notification-list {

        display: flex;

        flex-direction: column;

        gap: 10px;
    }


    .notification-item {

        position: relative;

        display: flex;

        align-items: flex-start;

        gap: 14px;

        padding: 16px;

        background: #ffffff;

        border: 1px solid #e5e9ef;

        border-radius: 13px;

        box-shadow:
            0 4px 14px
            rgba(20,28,45,.035);

        transition: .18s ease;
    }


    .notification-item:hover {

        border-color: #ddc8cc;

        box-shadow:
            0 7px 20px
            rgba(20,28,45,.055);
    }


    .notification-item.unread {

        border-left:
            3px solid #9c2433;

        background:
            linear-gradient(
                90deg,
                #fffafb,
                #ffffff 32%
            );
    }


    /* =========================================================
       ICON
       ========================================================= */

    .notification-icon {

        width: 40px;
        height: 40px;

        flex: 0 0 40px;

        display: grid;

        place-items: center;

        border-radius: 11px;

        background: #f4f5f7;

        color: #697386;
    }


    .notification-icon svg {

        width: 19px;
        height: 19px;

        fill: none;

        stroke: currentColor;

        stroke-width: 1.8;

        stroke-linecap: round;
        stroke-linejoin: round;
    }


    .notification-icon.approved {

        background: #e9f8f0;
        color: #18794e;
    }


    .notification-icon.rejected {

        background: #fff0f2;
        color: #b32636;
    }


    .notification-icon.pending {

        background: #fff5df;
        color: #9c6507;
    }


    .notification-icon.info {

        background: #f2f4f7;
        color: #697386;
    }


    /* =========================================================
       CONTENT
       ========================================================= */

    .notification-content {

        flex: 1;

        min-width: 0;
    }


    .notification-title-row {

        display: flex;

        align-items: center;

        gap: 8px;
    }


    .notification-title {

        color: #273247;

        font-size: 13px;

        /*
         * Tidak terlalu bold.
         * Selaras dengan page lain.
         */
        font-weight: 600;

        line-height: 1.4;
    }


    .notification-unread-dot {

        width: 7px;
        height: 7px;

        flex: 0 0 7px;

        background: #9c2433;

        border-radius: 50%;
    }


    .notification-message {

        margin:
            5px
            0
            0;

        color: #697386;

        font-size: 11px;

        font-weight: 400;

        line-height: 1.55;
    }


    .notification-time {

        display: block;

        margin-top: 7px;

        color: #9aa2b0;

        font-size: 9px;

        font-weight: 400;
    }


    /* =========================================================
       BOTTOM ACTIONS
       ========================================================= */

    .notification-item-actions {

        display: flex;

        align-items: center;

        gap: 13px;

        margin-top: 9px;
    }


    .notification-open {

        display: inline-flex;

        align-items: center;

        gap: 4px;

        color: #8d1f2d;

        font-size: 10px;
        font-weight: 600;

        text-decoration: none;
    }


    .notification-open:hover {

        text-decoration: underline;
    }


    .notification-delete-form {

        display: inline-flex;

        margin: 0;
    }


    .notification-delete {

        padding: 0;

        background: transparent;

        border: 0;

        color: #8c96a5;

        font-family: inherit;

        font-size: 10px;
        font-weight: 500;

        cursor: pointer;
    }


    .notification-delete:hover {

        color: #b32636;

        text-decoration: underline;
    }


    /* =========================================================
       EMPTY
       ========================================================= */

    .notification-empty {

        padding:
            55px
            25px;

        background: #ffffff;

        border:
            1px dashed #dfe3e9;

        border-radius: 14px;

        text-align: center;
    }


    .notification-empty-icon {

        width: 52px;
        height: 52px;

        display: grid;

        place-items: center;

        margin:
            0 auto
            14px;

        background: #fff7f8;

        border-radius: 14px;

        color: #8d1f2d;
    }


    .notification-empty-icon svg {

        width: 24px;
        height: 24px;

        fill: none;

        stroke: currentColor;

        stroke-width: 1.7;

        stroke-linecap: round;
        stroke-linejoin: round;
    }


    .notification-empty strong {

        display: block;

        color: #3c4658;

        font-size: 14px;

        font-weight: 600;
    }


    .notification-empty p {

        margin:
            5px
            0
            0;

        color: #8b94a3;

        font-size: 11px;
    }


    /* =========================================================
       MOBILE
       ========================================================= */

    @media (max-width: 760px) {

        .notification-page-header {

            flex-direction: column;
        }


        .notification-toolbar {

            flex-direction: column;

            align-items: stretch;
        }


        .notification-filters {

            flex-wrap: wrap;
        }


        .notification-actions {

            flex-wrap: wrap;
        }


        .notification-item {

            padding: 13px;
        }
    }

</style>


</head>


<body>


<div class="app">


    <%@ include file="includes/sidebar.jspf" %>


    <main>


        <div class="notification-page">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="notification-page-header">


                <div class="notification-page-title">


                    <h1>
                        Notifikasi
                    </h1>


                    <p>
                        Pemberitahuan terkini berkaitan sistem PKB
                    </p>


                </div>


                <%@ include file="includes/header-actions.jspf" %>


            </div>


            <!-- =================================================
                 TOOLBAR
                 ================================================= -->

            <div class="notification-toolbar">


                <div class="notification-filters">


                    <a
                        class="notification-filter <%= "all".equals(currentFilter) ? "active" : "" %>"
                        href="<%= request.getContextPath() %>/notifications"
                    >

                        Semua

                        <span class="filter-count">
                            <%= totalCount %>
                        </span>

                    </a>


                    <a
                        class="notification-filter <%= "unread".equals(currentFilter) ? "active" : "" %>"
                        href="<%= request.getContextPath() %>/notifications?filter=unread"
                    >

                        Belum Dibaca

                        <span class="filter-count">
                            <%= unreadCount %>
                        </span>

                    </a>


                </div>


                <div class="notification-actions">


                    <% if (unreadCount > 0) { %>


                        <form
                            class="notification-action-form"
                            method="post"
                            action="<%= request.getContextPath() %>/notifications"
                        >

                            <input
                                type="hidden"
                                name="action"
                                value="read-all"
                            >

                            <input
                                type="hidden"
                                name="filter"
                                value="<%= notificationEscape(currentFilter) %>"
                            >


                            <button
                                type="submit"
                                class="notification-action-button primary"
                            >

                                <svg viewBox="0 0 24 24">

                                    <path
                                        d="M20 6L9 17l-5-5"
                                    />

                                </svg>

                                Baca Semua

                            </button>


                        </form>


                    <% } %>


                    <% if (totalCount > unreadCount) { %>


                        <form
                            class="notification-action-form"
                            method="post"
                            action="<%= request.getContextPath() %>/notifications"
                            onsubmit="return confirm('Padam semua notifikasi yang telah dibaca?');"
                        >

                            <input
                                type="hidden"
                                name="action"
                                value="delete-read"
                            >

                            <input
                                type="hidden"
                                name="filter"
                                value="<%= notificationEscape(currentFilter) %>"
                            >


                            <button
                                type="submit"
                                class="notification-action-button danger"
                            >

                                <svg viewBox="0 0 24 24">

                                    <path
                                        d="M3 6h18"
                                    />

                                    <path
                                        d="M8 6V4h8v2"
                                    />

                                    <path
                                        d="M19 6l-1 14H6L5 6"
                                    />

                                    <path
                                        d="M10 11v5"
                                    />

                                    <path
                                        d="M14 11v5"
                                    />

                                </svg>

                                Padam Yang Dibaca

                            </button>


                        </form>


                    <% } %>


                </div>


            </div>


            <!-- =================================================
                 FLASH MESSAGE
                 ================================================= -->

            <% if (flashMessage != null && !flashMessage.isBlank()) { %>


                <div class="notification-flash">

                    <%= notificationEscape(
                        flashMessage
                    ) %>

                </div>


            <% } %>


            <!-- =================================================
                 LIST
                 ================================================= -->

            <%

                if (
                    notifications != null
                    &&
                    !notifications.isEmpty()
                ) {

            %>


                <div class="notification-list">


                <%

                    for (
                        Map<String,Object> item :
                        notifications
                    ) {


                        int notificationId =
                            item.get("id") instanceof Number
                                ? ((Number)item.get("id"))
                                    .intValue()
                                : 0;


                        String notificationType =
                            item.get("notificationType") == null
                                ? ""
                                : item
                                    .get("notificationType")
                                    .toString();


                        String title =
                            item.get("title") == null
                                ? "Notifikasi"
                                : item
                                    .get("title")
                                    .toString();


                        String message =
                            item.get("message") == null
                                ? ""
                                : item
                                    .get("message")
                                    .toString();


                        boolean isRead =
                            Boolean.TRUE.equals(
                                item.get("isRead")
                            );


                        String typeClass =
                            notificationTypeClass(
                                notificationType
                            );

                %>


                    <div
                        class="notification-item <%= isRead ? "" : "unread" %>"
                    >


                        <!-- ICON -->

                        <div
                            class="notification-icon <%= typeClass %>"
                        >


                            <% if ("approved".equals(typeClass)) { %>


                                <svg viewBox="0 0 24 24">

                                    <circle
                                        cx="12"
                                        cy="12"
                                        r="9"
                                    />

                                    <path
                                        d="M8 12l3 3 5-6"
                                    />

                                </svg>


                            <% } else if ("rejected".equals(typeClass)) { %>


                                <svg viewBox="0 0 24 24">

                                    <circle
                                        cx="12"
                                        cy="12"
                                        r="9"
                                    />

                                    <path
                                        d="M9 9l6 6"
                                    />

                                    <path
                                        d="M15 9l-6 6"
                                    />

                                </svg>


                            <% } else if ("pending".equals(typeClass)) { %>


                                <svg viewBox="0 0 24 24">

                                    <circle
                                        cx="12"
                                        cy="12"
                                        r="9"
                                    />

                                    <path
                                        d="M12 7v5l3 2"
                                    />

                                </svg>


                            <% } else { %>


                                <svg viewBox="0 0 24 24">

                                    <path
                                        d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                                    />

                                    <path
                                        d="M10 21h4"
                                    />

                                </svg>


                            <% } %>


                        </div>


                        <!-- CONTENT -->

                        <div class="notification-content">


                            <div class="notification-title-row">


                                <span class="notification-title">

                                    <%= notificationEscape(
                                        title
                                    ) %>

                                </span>


                                <% if (!isRead) { %>


                                    <span
                                        class="notification-unread-dot"
                                        title="Belum dibaca"
                                    ></span>


                                <% } %>


                            </div>


                            <p class="notification-message">

                                <%= notificationEscape(
                                    message
                                ) %>

                            </p>


                            <span class="notification-time">

                                <%= notificationEscape(
                                    notificationDate(
                                        item.get("createdAt")
                                    )
                                ) %>

                            </span>


                            <!-- =====================================
                                 ITEM ACTIONS
                                 ===================================== -->

                            <div class="notification-item-actions">


                                <a
                                    class="notification-open"
                                    href="<%= request.getContextPath() %>/notification-read?id=<%= notificationId %>"
                                >

                                    Buka

                                </a>


                                <form
                                    class="notification-delete-form"
                                    method="post"
                                    action="<%= request.getContextPath() %>/notifications"
                                    onsubmit="return confirm('Padam notifikasi ini?');"
                                >


                                    <input
                                        type="hidden"
                                        name="action"
                                        value="delete"
                                    >


                                    <input
                                        type="hidden"
                                        name="id"
                                        value="<%= notificationId %>"
                                    >


                                    <input
                                        type="hidden"
                                        name="filter"
                                        value="<%= notificationEscape(currentFilter) %>"
                                    >


                                    <button
                                        type="submit"
                                        class="notification-delete"
                                    >

                                        Padam

                                    </button>


                                </form>


                            </div>


                        </div>


                    </div>


                <% } %>


                </div>


            <% } else { %>


                <!-- =================================================
                     EMPTY
                     ================================================= -->

                <div class="notification-empty">


                    <div class="notification-empty-icon">


                        <svg viewBox="0 0 24 24">

                            <path
                                d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                            />

                            <path
                                d="M10 21h4"
                            />

                        </svg>


                    </div>


                    <strong>

                        <%

                            if ("unread".equals(currentFilter)) {

                        %>

                            Tiada Notifikasi Belum Dibaca

                        <%

                            } else {

                        %>

                            Tiada Notifikasi

                        <%

                            }

                        %>

                    </strong>


                    <p>

                        <%

                            if ("unread".equals(currentFilter)) {

                        %>

                            Semua notifikasi anda telah dibaca.

                        <%

                            } else {

                        %>

                            Anda belum mempunyai sebarang notifikasi.

                        <%

                            }

                        %>

                    </p>


                </div>


            <% } %>


        </div>


    </main>


</div>


</body>

</html>