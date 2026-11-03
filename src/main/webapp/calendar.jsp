<%@ page contentType="text/html;charset=UTF-8" %>

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
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", "\\n")
                .replace("</", "<\\/");
    }

    private String departmentName(String department) {
        if (department == null || department.isBlank()) {
            return "—";
        }

        switch (department.trim().toUpperCase()) {
            case "PENTADBIRAN_KORPORAT":
                return "Pentadbiran dan Korporat";

            case "KEWANGAN":
                return "Kewangan";

            case "PEMBANGUNAN_PERNIAGAAN_OPERASI":
                return "Pembangunan Perniagaan dan Operasi";

            default:
                return department;
        }
    }
%>

<%
    // =========================================================
    // SESSION
    // =========================================================

    String role = (String) session.getAttribute("userRole");
    String name = (String) session.getAttribute("userName");

    if (
        session.getAttribute("userId") == null ||
        name == null ||
        name.isBlank()
    ) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    // =========================================================
    // ROLE ATTRIBUTES
    // =========================================================

    Boolean isHRObject =
        (Boolean) request.getAttribute("isHR");

    Boolean isHODObject =
        (Boolean) request.getAttribute("isHOD");

    Boolean isStaffObject =
        (Boolean) request.getAttribute("isStaff");

    Boolean isManagementObject =
        (Boolean) request.getAttribute("isManagement");

    boolean isHR =
        isHRObject != null &&
        isHRObject.booleanValue();

    boolean isHOD =
        isHODObject != null &&
        isHODObject.booleanValue();

    boolean isStaff =
        isStaffObject != null &&
        isStaffObject.booleanValue();

    boolean isManagement =
        isManagementObject != null &&
        isManagementObject.booleanValue();

    boolean showStaffDetails =
        isHR ||
        isHOD ||
        isManagement;

    // =========================================================
    // PAGE DESCRIPTION
    // =========================================================

    String pageDescription =
        (String) request.getAttribute("pageDescription");

    if (
        pageDescription == null ||
        pageDescription.isBlank()
    ) {

        if (isHR) {

            pageDescription =
                "Lihat dan pantau jadual cuti semua staf serta cuti umum.";

        } else if (isManagement) {

            pageDescription =
                "Lihat dan pantau jadual cuti semua staf serta cuti umum.";

        } else if (isHOD) {

            pageDescription =
                "Lihat jadual cuti staf di bawah seliaan anda serta cuti umum.";

        } else {

            pageDescription =
                "Lihat jadual cuti anda serta cuti umum.";
        }
    }

    // =========================================================
    // APPLICATIONS
    // =========================================================

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> applications =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("applications");

    // =========================================================
    // PUBLIC HOLIDAYS
    // =========================================================

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> publicHolidays =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("publicHolidays");

    // =========================================================
    // COUNTERS
    // =========================================================

    int totalApplications =
        applications == null
            ? 0
            : applications.size();

    int approvedApplications = 0;
    int pendingApplications = 0;

    if (applications != null) {

        for (
            java.util.Map<String, Object> item :
            applications
        ) {

            String itemStatus =
                item.get("status") == null
                    ? ""
                    : String.valueOf(
                        item.get("status")
                    );

            if (
                "APPROVED".equalsIgnoreCase(
                    itemStatus
                )
            ) {

                approvedApplications++;

            } else if (
                !"REJECTED".equalsIgnoreCase(
                    itemStatus
                )
                &&
                !"CANCELLED".equalsIgnoreCase(
                    itemStatus
                )
            ) {

                pendingApplications++;
            }
        }
    }

    int totalPublicHolidays =
        publicHolidays == null
            ? 0
            : publicHolidays.size();
%>

<!DOCTYPE html>

<html lang="ms">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Kalendar Cuti - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260915-calendar-professional"
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
            width: 100%;
            max-width: 100%;
            margin: 0;
            overflow-x: hidden;
        }

        .app {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }

        main {
            min-width: 0;
            max-width: 100%;
            overflow-x: hidden;
        }


        /* =====================================================
           PAGE
           ===================================================== */

        .calendar-page {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }


        /* =====================================================
           PAGE HEADER
           ===================================================== */

        .calendar-page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 18px;

            margin-bottom: 20px;
        }

        .calendar-page-title {
            min-width: 0;
        }

        .calendar-page-title h1 {
            margin: 0 0 5px;

            color: #172033;

            font-size: 25px;
            font-weight: 750;

            line-height: 1.2;

            letter-spacing: -0.4px;
        }

        .calendar-page-title p {
            margin: 0;

            color: #7f899a;

            font-size: 12px;
            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           USER CHIP
           ===================================================== */

        .calendar-page .user-chip {
            display: flex;
            align-items: center;

            gap: 9px;

            flex-shrink: 0;

            min-height: 42px;

            padding: 6px 10px 6px 6px;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 11px;

            box-shadow:
                0 3px 10px
                rgba(31, 41, 61, .04);
        }

        .calendar-page .user-chip .avatar {
            width: 31px;
            height: 31px;

            display: grid;
            place-items: center;

            border-radius: 8px;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8e9
                );

            border: 1px solid #efd8dc;

            color: #8d1f2d;

            font-size: 11px;
            font-weight: 700;
        }

        .calendar-page .user-chip b {
            color: #2e3748;

            font-size: 11px;
            font-weight: 650;
        }


        /* =====================================================
           SUMMARY
           ===================================================== */

        .calendar-summary {
            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 12px;

            width: 100%;

            margin-bottom: 18px;
        }

        .calendar-summary-card {
            position: relative;

            min-width: 0;
            min-height: 84px;

            padding: 13px 15px;

            overflow: hidden;

            background: #ffffff;

            border: 1px solid #e7e9ef;
            border-radius: 12px;

            box-shadow:
                0 4px 14px
                rgba(27, 36, 53, .04);
        }

        .calendar-summary-card::before {
            content: "";

            position: absolute;

            top: 12px;
            bottom: 12px;
            left: 0;

            width: 3px;

            border-radius: 0 4px 4px 0;

            background:
                linear-gradient(
                    180deg,
                    #8d1f2d,
                    #d5a12b
                );
        }

        .calendar-summary-card span {
            display: block;

            color: #8993a4;

            font-size: 9px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: .35px;
        }

        .calendar-summary-card strong {
            display: block;

            margin-top: 5px;

            color: #172033;

            font-size: 21px;
            font-weight: 750;

            line-height: 1;
        }

        .calendar-summary-card small {
            display: block;

            margin-top: 5px;

            color: #929aa8;

            font-size: 9px;
            font-weight: 400;

            line-height: 1.3;
        }


        /* =====================================================
           ROLE INFO
           ===================================================== */

        .calendar-role-info {
            display: flex;
            align-items: center;

            gap: 11px;

            width: 100%;

            margin-bottom: 16px;

            padding: 11px 13px;

            background:
                linear-gradient(
                    135deg,
                    #fffafa,
                    #fffdf8
                );

            border: 1px solid #eadde0;
            border-radius: 10px;
        }

        .calendar-role-icon {
            width: 34px;
            height: 34px;
            min-width: 34px;

            display: grid;
            place-items: center;

            border-radius: 8px;

            background: #ffffff;

            border: 1px solid #ecdadd;

            color: #8d1f2d;

            font-size: 14px;
        }

        .calendar-role-info strong {
            display: block;

            margin-bottom: 2px;

            color: #394355;

            font-size: 11px;
            font-weight: 650;
        }

        .calendar-role-info p {
            margin: 0;

            color: #7e8797;

            font-size: 10px;
            font-weight: 400;

            line-height: 1.4;
        }


        /* =====================================================
           MAIN CALENDAR CARD
           ===================================================== */

        .modern-calendar-card {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            overflow: hidden;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 15px;

            box-shadow:
                0 7px 24px
                rgba(31, 41, 61, .055);
        }


        /* =====================================================
           MONTH HEADER
           ===================================================== */

        .modern-calendar-header {
            display: grid;

            grid-template-columns:
                42px 1fr 42px;

            align-items: center;

            gap: 12px;

            width: 100%;

            padding: 14px 17px;

            background:
                linear-gradient(
                    180deg,
                    #ffffff,
                    #fdfdfe
                );

            border-bottom:
                1px solid #eceef2;
        }

        .calendar-month-area {
            text-align: center;
        }

        .calendar-month-area span {
            display: block;

            margin-bottom: 3px;

            color: #9aa2af;

            font-size: 8px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: .6px;
        }

        .calendar-month-area h2 {
            margin: 0;

            color: #172033;

            font-size: 18px;
            font-weight: 750;

            line-height: 1.2;
        }


        /* =====================================================
           NAVIGATION
           ===================================================== */

        .calendar-nav {
            width: 36px;
            height: 36px;

            display: grid;
            place-items: center;

            padding: 0;

            background: #ffffff;

            border: 1px solid #dfe3e9;
            border-radius: 9px;

            color: #697486;

            font-family: inherit;

            font-size: 20px;
            font-weight: 400;

            cursor: pointer;

            transition: .15s ease;
        }

        .calendar-nav:hover {
            background: #fff5f6;

            color: #8d1f2d;

            border-color: #d8aeb5;

            transform: translateY(-1px);

            box-shadow:
                0 3px 8px
                rgba(141, 31, 45, .08);
        }


        /* =====================================================
           TOOLBAR
           ===================================================== */

        .calendar-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 14px;

            width: 100%;

            padding: 10px 16px;

            background: #fafbfc;

            border-bottom:
                1px solid #eceef2;
        }

        .today-button {
            flex-shrink: 0;

            min-height: 31px;

            padding: 6px 10px;

            background: #ffffff;

            border: 1px solid #dfe3e9;
            border-radius: 7px;

            color: #8d1f2d;

            font-family: inherit;

            font-size: 9.5px;
            font-weight: 650;

            cursor: pointer;

            transition: .15s ease;
        }

        .today-button:hover {
            background: #8d1f2d;

            color: #ffffff;

            border-color: #8d1f2d;
        }


        /* =====================================================
           LEGEND
           ===================================================== */

        .calendar-legend {
            display: flex;
            align-items: center;
            justify-content: flex-end;

            flex-wrap: wrap;

            gap: 7px;
        }

        .legend-item {
            display: inline-flex;
            align-items: center;

            gap: 5px;

            min-height: 25px;

            padding: 4px 7px;

            background: #ffffff;

            border: 1px solid #e7e9ed;
            border-radius: 999px;

            color: #747e90;

            font-size: 8.5px;
            font-weight: 500;

            line-height: 1;
        }

        .legend-box {
            width: 7px;
            height: 7px;

            flex-shrink: 0;

            border-radius: 50%;
        }

        .legend-box.approved {
            background: #24875a;
        }

        .legend-box.pending {
            background: #c18a19;
        }

        .legend-box.public-holiday {
            background: #8d1f2d;
        }

        .legend-box.off-day {
            background: #d9dde4;

            border: 1px solid #c4c9d1;
        }


        /* =====================================================
           CALENDAR CONTAINER
           NO HORIZONTAL SCROLL
           ===================================================== */

        .calendar-container {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            overflow-x: hidden;
            overflow-y: visible;
        }

        .calendar {
            display: grid;

            grid-template-columns:
                repeat(7, minmax(0, 1fr));

            width: 100%;
            max-width: 100%;
            min-width: 0;
        }


        /* =====================================================
           DAY HEADER
           ===================================================== */

        .cal-head {
            min-width: 0;

            padding: 9px 4px;

            background: #f8f9fb;

            border-right:
                1px solid #e9ecf0;

            border-bottom:
                1px solid #e4e7eb;

            color: #687386;

            font-size: 8.5px;
            font-weight: 700;

            line-height: 1.2;

            text-align: center;
            text-transform: uppercase;

            letter-spacing: .35px;
        }

        .cal-head:nth-child(7n) {
            border-right: 0;
        }

        .cal-head:nth-child(6),
        .cal-head:nth-child(7) {
            background: #f3f4f6;

            color: #89919d;
        }


        /* =====================================================
           CALENDAR DAY
           ===================================================== */

        .cal-day {
            position: relative;

            min-width: 0;
            min-height: 112px;

            padding: 7px;

            overflow: hidden;

            background: #ffffff;

            border-right:
                1px solid #eceef2;

            border-bottom:
                1px solid #eceef2;

            transition:
                background .15s ease;
        }

        .cal-day:hover {
            background: #fdfbfb;
        }

        .cal-day:nth-child(7n) {
            border-right: 0;
        }

        .cal-day.empty {
            background: #fafbfc;
        }


        /* =====================================================
           OFF DAY
           ===================================================== */

        .cal-day.off-day {
            background: #f7f8fa;
        }

        .cal-day.off-day:hover {
            background: #f4f5f7;
        }

        .off-day-label {
            position: absolute;

            top: 8px;
            right: 7px;

            padding: 2px 5px;

            background: #e9ebef;

            border-radius: 4px;

            color: #979eaa;

            font-size: 6.5px;
            font-weight: 700;

            line-height: 1.2;

            text-transform: uppercase;

            letter-spacing: .3px;
        }


        /* =====================================================
           PUBLIC HOLIDAY DAY
           ===================================================== */

        .cal-day.public-holiday-day {
            background:
                linear-gradient(
                    180deg,
                    #fffafb 0,
                    #ffffff 45px
                );

            box-shadow:
                inset 0 2px 0
                rgba(141, 31, 45, .7);
        }

        .cal-day.public-holiday-day.off-day {
            background:
                linear-gradient(
                    180deg,
                    #fffafb 0,
                    #f7f8fa 48px
                );
        }


        /* =====================================================
           DATE
           ===================================================== */

        .calendar-date {
            position: relative;

            z-index: 1;

            width: 25px;
            height: 25px;

            display: grid;
            place-items: center;

            border-radius: 6px;

            color: #536073;

            font-size: 9.5px;
            font-weight: 650;

            line-height: 1;
        }


        /* =====================================================
           TODAY
           ===================================================== */

        .cal-day.today {
            background: #fffafb;
        }

        .cal-day.today::before {
            content: "";

            position: absolute;

            top: 0;
            left: 0;
            right: 0;

            height: 2px;

            background: #8d1f2d;
        }

        .cal-day.today .calendar-date {
            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a72a3b
                );

            color: #ffffff;

            box-shadow:
                0 2px 6px
                rgba(141, 31, 45, .18);
        }


        /* =====================================================
           EVENTS
           ===================================================== */

        .event {
            position: relative;

            width: 100%;
            max-width: 100%;
            min-width: 0;

            margin-top: 5px;

            padding: 5px 6px 5px 8px;

            overflow: hidden;

            border-radius: 6px;

            font-size: 8.5px;
            font-weight: 500;

            line-height: 1.25;

            cursor: pointer;

            transition:
                transform .12s ease,
                box-shadow .12s ease;
        }

        .event:hover {
            transform: translateY(-1px);

            box-shadow:
                0 3px 7px
                rgba(27, 36, 53, .08);
        }


        /* =====================================================
           APPROVED
           ===================================================== */

        .event.approved {
            background: #eaf7f0;

            color: #176c43;

            border-left:
                2px solid #24875a;
        }


        /* =====================================================
           PENDING
           ===================================================== */

        .event.pending {
            background: #fff7e7;

            color: #89610d;

            border-left:
                2px solid #c18a19;
        }


        /* =====================================================
           REJECTED
           ===================================================== */

        .event.rejected {
            background: #fff0f2;

            color: #a72c39;

            border-left:
                2px solid #b53240;
        }


        /* =====================================================
           CANCELLED
           ===================================================== */

        .event.cancelled {
            background: #f1f2f4;

            color: #6d7582;

            border-left:
                2px solid #858d99;
        }


        /* =====================================================
           PUBLIC HOLIDAY EVENT
           ===================================================== */

        .event.public-holiday {
            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8ee
                );

            color: #8d1f2d;

            border:
                1px solid #efd6da;

            border-left:
                2px solid #8d1f2d;
        }

        .holiday-event-title {
            display: block;

            width: 100%;

            overflow: hidden;

            color: #8d1f2d;

            font-size: 8.5px;
            font-weight: 650;

            line-height: 1.25;

            white-space: nowrap;

            text-overflow: ellipsis;
        }

        .holiday-event-label {
            display: block;

            margin-top: 2px;

            color: #aa6b73;

            font-size: 6.5px;
            font-weight: 650;

            line-height: 1.2;

            text-transform: uppercase;

            letter-spacing: .25px;
        }


        /* =====================================================
           STAFF EVENT
           ===================================================== */

        .event-staff-name {
            display: block;

            width: 100%;

            overflow: hidden;

            font-size: 8.5px;
            font-weight: 650;

            line-height: 1.25;

            white-space: nowrap;

            text-overflow: ellipsis;
        }

        .event-leave-type {
            display: block;

            width: 100%;

            margin-top: 2px;

            overflow: hidden;

            opacity: .85;

            font-size: 7.5px;
            font-weight: 450;

            line-height: 1.2;

            white-space: nowrap;

            text-overflow: ellipsis;
        }


        /* =====================================================
           MODAL
           ===================================================== */

        .leave-modal {
            position: fixed;

            inset: 0;

            z-index: 1000;

            display: none;

            align-items: center;
            justify-content: center;

            padding: 20px;

            background:
                rgba(20, 29, 47, .46);

            backdrop-filter:
                blur(3px);
        }

        .leave-modal.show {
            display: flex;
        }

        .leave-modal-box {
            width: 100%;
            max-width: 500px;

            max-height: 88vh;

            overflow-y: auto;
            overflow-x: hidden;

            background: #ffffff;

            border: 1px solid
                rgba(255, 255, 255, .5);

            border-radius: 15px;

            box-shadow:
                0 24px 60px
                rgba(20, 29, 47, .22);
        }


        /* =====================================================
           MODAL HEADER
           ===================================================== */

        .leave-modal-header {
            display: flex;

            justify-content: space-between;
            align-items: center;

            gap: 14px;

            padding: 16px 18px;

            border-bottom:
                1px solid #eceef2;
        }

        .leave-modal-heading h2 {
            margin: 0 0 3px;

            color: #172033;

            font-size: 17px;
            font-weight: 700;
        }

        .leave-modal-heading p {
            margin: 0;

            color: #929aa8;

            font-size: 9px;
        }

        .leave-modal-close {
            width: 32px;
            height: 32px;

            display: grid;
            place-items: center;

            flex-shrink: 0;

            padding: 0;

            background: #ffffff;

            border: 1px solid #e3e6eb;
            border-radius: 8px;

            color: #687284;

            font-family: inherit;

            font-size: 18px;

            cursor: pointer;
        }

        .leave-modal-close:hover {
            background: #fff3f4;

            color: #8d1f2d;

            border-color: #dab7bd;
        }


        /* =====================================================
           MODAL CONTENT
           ===================================================== */

        .leave-modal-content {
            padding: 17px 18px;
        }

        .leave-detail-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 9px;
        }

        .leave-detail-row {
            min-width: 0;

            padding: 10px 11px;

            background: #fafbfc;

            border: 1px solid #eaecf0;
            border-radius: 8px;
        }

        .leave-detail-row.full {
            grid-column: 1 / -1;
        }

        .leave-detail-row span {
            display: block;

            margin-bottom: 4px;

            color: #8b94a4;

            font-size: 8px;
            font-weight: 650;

            text-transform: uppercase;

            letter-spacing: .3px;
        }

        .leave-detail-row strong {
            display: block;

            color: #404a5c;

            font-size: 10.5px;
            font-weight: 600;

            line-height: 1.45;

            overflow-wrap: anywhere;
        }


        /* =====================================================
           STATUS MODAL
           ===================================================== */

        .leave-detail-status {
            display: inline-flex !important;

            align-items: center;

            width: fit-content;

            padding: 5px 8px;

            border-radius: 999px;

            font-size: 9px !important;
            font-weight: 650 !important;
        }

        .leave-detail-status.approved {
            background: #eaf8f1;

            color: #20744b;
        }

        .leave-detail-status.pending {
            background: #fff6e4;

            color: #916713;
        }

        .leave-detail-status.rejected {
            background: #fff0f2;

            color: #a82e3a;
        }

        .leave-detail-status.cancelled {
            background: #f2f3f5;

            color: #6d7582;
        }

        .holiday-modal-badge {
            display: inline-flex !important;

            align-items: center;

            width: fit-content;

            padding: 5px 8px;

            background: #fff0f2;

            border-radius: 999px;

            color: #8d1f2d !important;

            font-size: 8px !important;
            font-weight: 650 !important;

            text-transform: uppercase;

            letter-spacing: .3px;
        }


        /* =====================================================
           LAPTOP
           ===================================================== */

        @media (max-width: 1450px) {

            .calendar-page-title h1 {
                font-size: 23px;
            }

            .calendar-summary-card {
                min-height: 80px;

                padding: 12px 13px;
            }

            .calendar-summary-card strong {
                font-size: 20px;
            }

            .cal-day {
                min-height: 105px;

                padding: 6px;
            }

            .calendar-date {
                width: 23px;
                height: 23px;

                font-size: 9px;
            }

            .event {
                padding: 5px 5px 5px 7px;

                font-size: 8px;
            }

            .event-staff-name,
            .holiday-event-title {
                font-size: 8px;
            }

            .event-leave-type {
                font-size: 7px;
            }

            .holiday-event-label {
                font-size: 6px;
            }
        }


        /* =====================================================
           SMALL LAPTOP
           ===================================================== */

        @media (max-width: 1150px) {

            .calendar-summary {
                grid-template-columns:
                    repeat(
                        2,
                        minmax(0, 1fr)
                    );
            }

            .cal-day {
                min-height: 95px;

                padding: 5px;
            }

            .cal-head {
                padding: 8px 2px;

                font-size: 7.5px;
            }

            .calendar-date {
                width: 21px;
                height: 21px;

                font-size: 8px;
            }

            .event {
                padding: 4px 4px 4px 6px;
            }

            .event-staff-name,
            .holiday-event-title {
                font-size: 7.5px;
            }

            .event-leave-type {
                font-size: 6.5px;
            }

            .off-day-label {
                font-size: 6px;
            }
        }


        /* =====================================================
           MOBILE
           ===================================================== */

        @media (max-width: 700px) {

            .calendar-page-header {
                flex-direction: column;

                align-items: stretch;
            }

            .calendar-page .user-chip {
                align-self: flex-start;
            }

            .calendar-summary {
                grid-template-columns: 1fr;
            }

            .calendar-toolbar {
                flex-direction: column;

                align-items: flex-start;
            }

            .calendar-legend {
                justify-content: flex-start;
            }

            .cal-day {
                min-height: 80px;

                padding: 3px;
            }

            .cal-head {
                font-size: 6.5px;

                letter-spacing: 0;
            }

            .calendar-date {
                width: 19px;
                height: 19px;

                font-size: 7px;
            }

            .event {
                padding: 3px 3px 3px 5px;

                border-radius: 4px;
            }

            .event-staff-name,
            .holiday-event-title {
                font-size: 6.5px;
            }

            .event-leave-type,
            .holiday-event-label {
                display: none;
            }

            .off-day-label {
                display: none;
            }

            .leave-detail-grid {
                grid-template-columns: 1fr;
            }

            .leave-detail-row.full {
                grid-column: auto;
            }
        }

    </style>

</head>

<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="calendar-page">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="calendar-page-header">

                <div class="calendar-page-title">

                    <h1>
                        Kalendar Cuti
                    </h1>

                    <p>
                        <%= htmlEscape(pageDescription) %>
                    </p>

                </div>


                <div class="user-chip">

                    <div class="avatar">

                        <%= htmlEscape(
                            name.substring(
                                0,
                                1
                            ).toUpperCase()
                        ) %>

                    </div>

                    <b>
                        <%= htmlEscape(name) %>
                    </b>

                </div>

            </div>


            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="calendar-summary">


                <div class="calendar-summary-card">

                    <span>
                        Rekod Kalendar
                    </span>

                    <strong>
                        <%= totalApplications %>
                    </strong>

                    <small>
                        Jumlah permohonan dipaparkan
                    </small>

                </div>


                <div class="calendar-summary-card">

                    <span>
                        Diluluskan
                    </span>

                    <strong>
                        <%= approvedApplications %>
                    </strong>

                    <small>
                        Cuti yang telah diluluskan
                    </small>

                </div>


                <div class="calendar-summary-card">

                    <span>
                        Dalam Proses
                    </span>

                    <strong>
                        <%= pendingApplications %>
                    </strong>

                    <small>
                        Menunggu keputusan Pengurusan
                    </small>

                </div>


                <div class="calendar-summary-card">

                    <span>
                        Cuti Umum
                    </span>

                    <strong>
                        <%= totalPublicHolidays %>
                    </strong>

                    <small>
                        Hari cuti umum aktif
                    </small>

                </div>

            </div>


            <!-- =================================================
                 ROLE INFORMATION
                 ================================================= -->

            <% if (isHOD) { %>

                <div class="calendar-role-info">

                    <div class="calendar-role-icon">
                        ◉
                    </div>

                    <div>

                        <strong>
                            Kalendar Staf Di Bawah Seliaan
                        </strong>

                        <p>
                            Kalendar ini memaparkan permohonan cuti staf di bawah seliaan anda dan cuti umum.
                        </p>

                    </div>

                </div>

            <% } %>


            <% if (isHR) { %>

                <div class="calendar-role-info">

                    <div class="calendar-role-icon">
                        ▦
                    </div>

                    <div>

                        <strong>
                            Kalendar Cuti Organisasi
                        </strong>

                        <p>
                            Kalendar ini memaparkan jadual cuti semua staf dan cuti umum organisasi.
                        </p>

                    </div>

                </div>

            <% } %>


            <% if (isManagement) { %>

                <div class="calendar-role-info">

                    <div class="calendar-role-icon">
                        ▦
                    </div>

                    <div>

                        <strong>
                            Kalendar Cuti Organisasi
                        </strong>

                        <p>
                            Kalendar ini memaparkan jadual cuti semua staf serta cuti umum untuk rujukan pihak Pengurusan.
                        </p>

                    </div>

                </div>

            <% } %>


            <!-- =================================================
                 CALENDAR
                 ================================================= -->

            <div class="modern-calendar-card">


                <div class="modern-calendar-header">


                    <button
                        type="button"
                        class="calendar-nav"
                        onclick="previousMonth()"
                        aria-label="Bulan sebelumnya"
                        title="Bulan sebelumnya"
                    >
                        &#8249;
                    </button>


                    <div class="calendar-month-area">

                        <span>
                            Kalendar Bulanan
                        </span>

                        <h2 id="calendarMonth">
                            Kalendar Cuti
                        </h2>

                    </div>


                    <button
                        type="button"
                        class="calendar-nav"
                        onclick="nextMonth()"
                        aria-label="Bulan seterusnya"
                        title="Bulan seterusnya"
                    >
                        &#8250;
                    </button>


                </div>


                <!-- =================================================
                     TOOLBAR
                     ================================================= -->

                <div class="calendar-toolbar">


                    <button
                        type="button"
                        class="today-button"
                        onclick="goToToday()"
                    >
                        Hari Ini
                    </button>


                    <div class="calendar-legend">


                        <div class="legend-item">

                            <span class="legend-box approved"></span>

                            Diluluskan

                        </div>


                        <div class="legend-item">

                            <span class="legend-box pending"></span>

                            Dalam Proses

                        </div>


                        <div class="legend-item">

                            <span class="legend-box public-holiday"></span>

                            Cuti Umum

                        </div>


                        <div class="legend-item">

                            <span class="legend-box off-day"></span>

                            Jumaat / Sabtu

                        </div>


                    </div>


                </div>


                <!-- =================================================
                     CALENDAR GRID
                     ================================================= -->

                <div class="calendar-container">

                    <div
                        id="calendar"
                        class="calendar"
                    ></div>

                </div>


            </div>


        </div>

    </main>

</div>


<!-- =========================================================
     LEAVE MODAL
     ========================================================= -->

<div
    class="leave-modal"
    id="leaveModal"
>

    <div class="leave-modal-box">


        <div class="leave-modal-header">


            <div class="leave-modal-heading">

                <h2>
                    Butiran Cuti
                </h2>

                <p>
                    Maklumat lengkap permohonan cuti
                </p>

            </div>


            <button
                type="button"
                class="leave-modal-close"
                onclick="closeLeaveModal()"
                aria-label="Tutup"
            >
                &times;
            </button>


        </div>


        <div class="leave-modal-content">


            <div class="leave-detail-grid">


                <% if (showStaffDetails) { %>


                    <div class="leave-detail-row">

                        <span>
                            Nama Staf
                        </span>

                        <strong id="modalStaff">
                            —
                        </strong>

                    </div>


                    <div class="leave-detail-row">

                        <span>
                            E-mel
                        </span>

                        <strong id="modalEmail">
                            —
                        </strong>

                    </div>


                    <div class="leave-detail-row full">

                        <span>
                            Bahagian
                        </span>

                        <strong id="modalDepartment">
                            —
                        </strong>

                    </div>


                <% } %>


                <div class="leave-detail-row">

                    <span>
                        Jenis Cuti
                    </span>

                    <strong id="modalType">
                        —
                    </strong>

                </div>


                <div class="leave-detail-row">

                    <span>
                        Jumlah Cuti
                    </span>

                    <strong id="modalDuration">
                        —
                    </strong>

                </div>


                <div class="leave-detail-row full">

                    <span>
                        Tarikh
                    </span>

                    <strong id="modalDate">
                        —
                    </strong>

                </div>


                <div class="leave-detail-row full">

                    <span>
                        Status
                    </span>

                    <strong
                        id="modalStatus"
                        class="leave-detail-status"
                    >
                        —
                    </strong>

                </div>


                <div class="leave-detail-row full">

                    <span>
                        Alasan
                    </span>

                    <strong id="modalReason">
                        —
                    </strong>

                </div>


            </div>


        </div>


    </div>

</div>


<!-- =========================================================
     PUBLIC HOLIDAY MODAL
     ========================================================= -->

<div
    class="leave-modal"
    id="holidayModal"
>

    <div class="leave-modal-box">


        <div class="leave-modal-header">


            <div class="leave-modal-heading">

                <h2>
                    Butiran Cuti Umum
                </h2>

                <p>
                    Maklumat lengkap cuti umum
                </p>

            </div>


            <button
                type="button"
                class="leave-modal-close"
                onclick="closeHolidayModal()"
                aria-label="Tutup"
            >
                &times;
            </button>


        </div>


        <div class="leave-modal-content">


            <div class="leave-detail-grid">


                <div class="leave-detail-row full">

                    <span>
                        Nama Cuti
                    </span>

                    <strong id="holidayModalName">
                        —
                    </strong>

                </div>


                <div class="leave-detail-row">

                    <span>
                        Tempoh
                    </span>

                    <strong id="holidayModalDate">
                        —
                    </strong>

                </div>


                <div class="leave-detail-row">

                    <span>
                        Kategori
                    </span>

                    <strong class="holiday-modal-badge">
                        Cuti Umum
                    </strong>

                </div>


                <div class="leave-detail-row full">

                    <span>
                        Keterangan
                    </span>

                    <strong id="holidayModalDescription">
                        —
                    </strong>

                </div>


            </div>


        </div>


    </div>

</div>


<script>

    // =========================================================
    // ROLE
    // =========================================================

    const isHR =
        <%= isHR ? "true" : "false" %>;

    const isHOD =
        <%= isHOD ? "true" : "false" %>;

    const isStaff =
        <%= isStaff ? "true" : "false" %>;

    const isManagement =
        <%= isManagement ? "true" : "false" %>;

    const showStaffDetails =
        <%= showStaffDetails ? "true" : "false" %>;


    // =========================================================
    // LEAVE DATA
    // =========================================================

    const leaveApplications = [

<%
    boolean firstLeave = true;

    if (
        applications != null &&
        !applications.isEmpty()
    ) {

        for (
            java.util.Map<String, Object> row :
            applications
        ) {

            if (!firstLeave) {
                out.print(",");
            }

            firstLeave = false;

            int id =
                row.get("id") == null
                    ? 0
                    : ((Number)
                        row.get("id")
                      ).intValue();

            String staffName =
                row.get("staff_name") == null
                    ? ""
                    : String.valueOf(
                        row.get("staff_name")
                    );

            String staffEmail =
                row.get("staff_email") == null
                    ? ""
                    : String.valueOf(
                        row.get("staff_email")
                    );

            String department =
                row.get("department") == null
                    ? ""
                    : String.valueOf(
                        row.get("department")
                    );

            String departmentDisplay =
                departmentName(
                    department
                );

            String type =
                row.get("leave_type") == null
                    ? ""
                    : String.valueOf(
                        row.get("leave_type")
                    );

            String otherType =
                row.get("other_leave_type") == null
                    ? ""
                    : String.valueOf(
                        row.get("other_leave_type")
                    );

            if (
                "Lain-lain".equalsIgnoreCase(
                    type
                )
                &&
                !otherType.isBlank()
            ) {

                type =
                    "Lain-lain - "
                    +
                    otherType;
            }

            String start =
                row.get("start_date") == null
                    ? ""
                    : row.get(
                        "start_date"
                    ).toString();

            String end =
                row.get("end_date") == null
                    ? ""
                    : row.get(
                        "end_date"
                    ).toString();

            String status =
                row.get("status") == null
                    ? ""
                    : String.valueOf(
                        row.get("status")
                    );

            String reason =
                row.get("reason") == null
                    ? ""
                    : String.valueOf(
                        row.get("reason")
                    );

            int duration =
                row.get("duration") == null
                    ? 0
                    : ((Number)
                        row.get("duration")
                      ).intValue();
%>

        {
            id:
                <%= id %>,

            staffName:
                "<%= jsEscape(staffName) %>",

            staffEmail:
                "<%= jsEscape(staffEmail) %>",

            department:
                "<%= jsEscape(departmentDisplay) %>",

            type:
                "<%= jsEscape(type) %>",

            start:
                "<%= jsEscape(start) %>",

            end:
                "<%= jsEscape(end) %>",

            duration:
                <%= duration %>,

            reason:
                "<%= jsEscape(reason) %>",

            status:
                "<%= jsEscape(status) %>"
        }

<%
        }
    }
%>

    ];


    // =========================================================
    // PUBLIC HOLIDAY DATA
    // =========================================================

    const publicHolidayData = [

<%
    boolean firstHoliday = true;

    if (
        publicHolidays != null &&
        !publicHolidays.isEmpty()
    ) {

        for (
            java.util.Map<String, Object> holiday :
            publicHolidays
        ) {

            if (!firstHoliday) {
                out.print(",");
            }

            firstHoliday = false;

            int holidayId =
                holiday.get("id") == null
                    ? 0
                    : ((Number)
                        holiday.get("id")
                      ).intValue();

            String holidayName =
                holiday.get("holiday_name") == null
                    ? "Cuti Umum"
                    : String.valueOf(
                        holiday.get("holiday_name")
                    );

            String holidayDate =
                holiday.get("holiday_date") == null
                    ? ""
                    : String.valueOf(
                        holiday.get("holiday_date")
                    );

            String holidayStartDate =
                holiday.get("start_date") == null
                    ? holidayDate
                    : String.valueOf(
                        holiday.get("start_date")
                    );

            String holidayEndDate =
                holiday.get("end_date") == null
                    ? holidayDate
                    : String.valueOf(
                        holiday.get("end_date")
                    );

            String holidayDescription =
                holiday.get("description") == null
                    ? ""
                    : String.valueOf(
                        holiday.get("description")
                    );
%>

        {
            id:
                <%= holidayId %>,

            name:
                "<%= jsEscape(holidayName) %>",

            date:
                "<%= jsEscape(holidayDate) %>",

            start:
                "<%= jsEscape(holidayStartDate) %>",

            end:
                "<%= jsEscape(holidayEndDate) %>",

            description:
                "<%= jsEscape(holidayDescription) %>"
        }

<%
        }
    }
%>

    ];


    // =========================================================
    // CURRENT MONTH
    // =========================================================

    let currentDate =
        new Date();


    // =========================================================
    // STATUS
    // =========================================================

    function getStatusInfo(status) {

        if (
            status === "APPROVED"
        ) {

            return {
                text:
                    "Diluluskan",

                cssClass:
                    "approved"
            };
        }

        if (
            status === "PENDING_MANAGEMENT"
            ||
            status === "PENDING"
            ||
            status === "PENDING_HEAD"
            ||
            status === "PENDING_ADMIN"
        ) {

            return {
                text:
                    "Menunggu Pengurusan",

                cssClass:
                    "pending"
            };
        }

        if (
            status === "REJECTED"
        ) {

            return {
                text:
                    "Tidak Diluluskan",

                cssClass:
                    "rejected"
            };
        }

        if (
            status === "CANCELLED"
        ) {

            return {
                text:
                    "Dibatalkan",

                cssClass:
                    "cancelled"
            };
        }

        return {
            text:
                status || "—",

            cssClass:
                "pending"
        };
    }


    // =========================================================
    // FORMAT DATE
    // =========================================================

    function formatDate(
        dateString
    ) {

        if (!dateString) {
            return "—";
        }

        const date =
            new Date(
                dateString
                +
                "T00:00:00"
            );

        return date.toLocaleDateString(
            "ms-MY",
            {
                day:
                    "2-digit",

                month:
                    "2-digit",

                year:
                    "numeric"
            }
        );
    }


    // =========================================================
    // DATE KEY
    // =========================================================

    function formatDateKey(date) {

        const year =
            date.getFullYear();

        const month =
            String(
                date.getMonth() + 1
            ).padStart(
                2,
                "0"
            );

        const day =
            String(
                date.getDate()
            ).padStart(
                2,
                "0"
            );

        return (
            year
            +
            "-"
            +
            month
            +
            "-"
            +
            day
        );
    }


    // =========================================================
    // SAME DATE
    // =========================================================

    function isSameDate(
        firstDate,
        secondDate
    ) {

        return (
            firstDate.getFullYear() ===
                secondDate.getFullYear()
            &&
            firstDate.getMonth() ===
                secondDate.getMonth()
            &&
            firstDate.getDate() ===
                secondDate.getDate()
        );
    }


    // =========================================================
    // HOLIDAY
    // =========================================================

    function getHolidayForDate(
        dateKey
    ) {

        return publicHolidayData.find(
            function(holiday) {

                return (
                    holiday.date ===
                    dateKey
                );
            }
        );
    }


    // =========================================================
    // RENDER CALENDAR
    // =========================================================

    function renderCalendar() {

        const calendar =
            document.getElementById(
                "calendar"
            );

        const monthTitle =
            document.getElementById(
                "calendarMonth"
            );

        calendar.innerHTML =
            "";

        const year =
            currentDate.getFullYear();

        const month =
            currentDate.getMonth();

        const monthName =
            currentDate.toLocaleString(
                "ms-MY",
                {
                    month:
                        "long"
                }
            );

        monthTitle.textContent =
            monthName.charAt(0).toUpperCase()
            +
            monthName.slice(1)
            +
            " "
            +
            year;


        // =====================================================
        // HEADERS
        // =====================================================

        const days = [
            "Ahad",
            "Isnin",
            "Selasa",
            "Rabu",
            "Khamis",
            "Jumaat",
            "Sabtu"
        ];

        days.forEach(
            function(day) {

                const header =
                    document.createElement(
                        "div"
                    );

                header.className =
                    "cal-head";

                header.textContent =
                    day;

                calendar.appendChild(
                    header
                );
            }
        );


        const firstDay =
            new Date(
                year,
                month,
                1
            ).getDay();


        const daysInMonth =
            new Date(
                year,
                month + 1,
                0
            ).getDate();


        // =====================================================
        // EMPTY CELLS
        // =====================================================

        for (
            let i = 0;
            i < firstDay;
            i++
        ) {

            const empty =
                document.createElement(
                    "div"
                );

            empty.className =
                "cal-day empty";

            calendar.appendChild(
                empty
            );
        }


        // =====================================================
        // DAYS
        // =====================================================

        for (
            let day = 1;
            day <= daysInMonth;
            day++
        ) {

            const cellDate =
                new Date(
                    year,
                    month,
                    day
                );

            const dateKey =
                formatDateKey(
                    cellDate
                );

            const dayOfWeek =
                cellDate.getDay();

            const isOffDay =
                dayOfWeek === 5 ||
                dayOfWeek === 6;

            const holiday =
                getHolidayForDate(
                    dateKey
                );

            const cell =
                document.createElement(
                    "div"
                );

            cell.className =
                "cal-day";


            // =================================================
            // OFF DAY
            // =================================================

            if (isOffDay) {

                cell.classList.add(
                    "off-day"
                );
            }


            // =================================================
            // PUBLIC HOLIDAY
            // =================================================

            if (holiday) {

                cell.classList.add(
                    "public-holiday-day"
                );
            }


            // =================================================
            // TODAY
            // =================================================

            const today =
                new Date();

            if (
                isSameDate(
                    cellDate,
                    today
                )
            ) {

                cell.classList.add(
                    "today"
                );
            }


            // =================================================
            // DATE NUMBER
            // =================================================

            const number =
                document.createElement(
                    "div"
                );

            number.className =
                "calendar-date";

            number.textContent =
                day;

            cell.appendChild(
                number
            );


            // =================================================
            // OFF DAY LABEL
            // =================================================

            if (
                isOffDay &&
                !holiday
            ) {

                const offLabel =
                    document.createElement(
                        "span"
                    );

                offLabel.className =
                    "off-day-label";

                offLabel.textContent =
                    "Cuti";

                cell.appendChild(
                    offLabel
                );
            }


            // =================================================
            // PUBLIC HOLIDAY EVENT
            // =================================================

            if (holiday) {

                const holidayEvent =
                    document.createElement(
                        "div"
                    );

                holidayEvent.className =
                    "event public-holiday";


                const holidayTitle =
                    document.createElement(
                        "span"
                    );

                holidayTitle.className =
                    "holiday-event-title";

                holidayTitle.textContent =
                    holiday.name;

                holidayEvent.appendChild(
                    holidayTitle
                );


                const holidayLabel =
                    document.createElement(
                        "span"
                    );

                holidayLabel.className =
                    "holiday-event-label";

                holidayLabel.textContent =
                    "Cuti Umum";

                holidayEvent.appendChild(
                    holidayLabel
                );


                holidayEvent.title =
                    holiday.name
                    +
                    " - Cuti Umum";


                holidayEvent.addEventListener(
                    "click",
                    function() {

                        openHolidayModal(
                            holiday
                        );
                    }
                );


                cell.appendChild(
                    holidayEvent
                );
            }


            // =================================================
            // LEAVE EVENTS
            // =================================================

            leaveApplications.forEach(
                function(leave) {


                    if (
                        leave.status ===
                        "CANCELLED"
                    ) {

                        return;
                    }


                    if (
                        !leave.start ||
                        !leave.end
                    ) {

                        return;
                    }


                    const leaveStart =
                        new Date(
                            leave.start
                            +
                            "T00:00:00"
                        );


                    const leaveEnd =
                        new Date(
                            leave.end
                            +
                            "T23:59:59"
                        );


                    if (
                        cellDate >= leaveStart &&
                        cellDate <= leaveEnd
                    ) {

                        const statusInfo =
                            getStatusInfo(
                                leave.status
                            );


                        const event =
                            document.createElement(
                                "div"
                            );


                        event.className =
                            "event "
                            +
                            statusInfo.cssClass;


                        // =====================================
                        // HR / HOD / MANAGEMENT
                        // =====================================

                        if (
                            showStaffDetails
                        ) {

                            const staff =
                                document.createElement(
                                    "span"
                                );

                            staff.className =
                                "event-staff-name";

                            staff.textContent =
                                leave.staffName ||
                                "Staf";

                            event.appendChild(
                                staff
                            );


                            const leaveTypeElement =
                                document.createElement(
                                    "span"
                                );

                            leaveTypeElement.className =
                                "event-leave-type";

                            leaveTypeElement.textContent =
                                leave.type;

                            event.appendChild(
                                leaveTypeElement
                            );

                        } else {


                            // =================================
                            // STAFF
                            // =================================

                            const leaveTypeElement =
                                document.createElement(
                                    "span"
                                );

                            leaveTypeElement.className =
                                "event-staff-name";

                            leaveTypeElement.textContent =
                                leave.type;

                            event.appendChild(
                                leaveTypeElement
                            );
                        }


                        if (
                            showStaffDetails
                        ) {

                            event.title =
                                leave.staffName
                                +
                                " - "
                                +
                                leave.type
                                +
                                " - "
                                +
                                statusInfo.text;

                        } else {

                            event.title =
                                leave.type
                                +
                                " - "
                                +
                                statusInfo.text;
                        }


                        event.addEventListener(
                            "click",
                            function() {

                                openLeaveModal(
                                    leave
                                );
                            }
                        );


                        cell.appendChild(
                            event
                        );
                    }
                }
            );


            calendar.appendChild(
                cell
            );
        }


        // =====================================================
        // COMPLETE LAST WEEK
        // Keeps calendar bottom edge neat
        // =====================================================

        const usedCells =
            firstDay +
            daysInMonth;

        const remainingCells =
            (7 - (usedCells % 7)) % 7;


        for (
            let i = 0;
            i < remainingCells;
            i++
        ) {

            const empty =
                document.createElement(
                    "div"
                );

            empty.className =
                "cal-day empty";

            calendar.appendChild(
                empty
            );
        }
    }


    // =========================================================
    // LEAVE MODAL
    // =========================================================

    const leaveModal =
        document.getElementById(
            "leaveModal"
        );


    function openLeaveModal(
        leave
    ) {


        if (
            showStaffDetails
        ) {

            document.getElementById(
                "modalStaff"
            ).textContent =
                leave.staffName ||
                "—";


            document.getElementById(
                "modalEmail"
            ).textContent =
                leave.staffEmail ||
                "—";


            document.getElementById(
                "modalDepartment"
            ).textContent =
                leave.department ||
                "—";
        }


        document.getElementById(
            "modalType"
        ).textContent =
            leave.type ||
            "—";


        document.getElementById(
            "modalDate"
        ).textContent =
            formatDate(
                leave.start
            )
            +
            " hingga "
            +
            formatDate(
                leave.end
            );


        document.getElementById(
            "modalDuration"
        ).textContent =
            leave.duration
            +
            " hari";


        const statusInfo =
            getStatusInfo(
                leave.status
            );


        const statusElement =
            document.getElementById(
                "modalStatus"
            );


        statusElement.textContent =
            statusInfo.text;


        statusElement.className =
            "leave-detail-status "
            +
            statusInfo.cssClass;


        document.getElementById(
            "modalReason"
        ).textContent =
            leave.reason ||
            "—";


        leaveModal.classList.add(
            "show"
        );


        document.body.style.overflow =
            "hidden";
    }


    function closeLeaveModal() {

        leaveModal.classList.remove(
            "show"
        );

        document.body.style.overflow =
            "";
    }


    // =========================================================
    // HOLIDAY MODAL
    // =========================================================

    const holidayModal =
        document.getElementById(
            "holidayModal"
        );


    function openHolidayModal(
        holiday
    ) {


        document.getElementById(
            "holidayModalName"
        ).textContent =
            holiday.name ||
            "Cuti Umum";


        if (
            holiday.start &&
            holiday.end &&
            holiday.start !==
            holiday.end
        ) {

            document.getElementById(
                "holidayModalDate"
            ).textContent =
                formatDate(
                    holiday.start
                )
                +
                " hingga "
                +
                formatDate(
                    holiday.end
                );

        } else {

            document.getElementById(
                "holidayModalDate"
            ).textContent =
                formatDate(
                    holiday.start ||
                    holiday.date
                );
        }


        document.getElementById(
            "holidayModalDescription"
        ).textContent =
            holiday.description ||
            "Tiada keterangan tambahan.";


        holidayModal.classList.add(
            "show"
        );


        document.body.style.overflow =
            "hidden";
    }


    function closeHolidayModal() {

        holidayModal.classList.remove(
            "show"
        );

        document.body.style.overflow =
            "";
    }


    // =========================================================
    // CLICK OUTSIDE MODAL
    // =========================================================

    leaveModal.addEventListener(
        "click",
        function(event) {

            if (
                event.target ===
                leaveModal
            ) {

                closeLeaveModal();
            }
        }
    );


    holidayModal.addEventListener(
        "click",
        function(event) {

            if (
                event.target ===
                holidayModal
            ) {

                closeHolidayModal();
            }
        }
    );


    // =========================================================
    // ESCAPE KEY
    // =========================================================

    document.addEventListener(
        "keydown",
        function(event) {


            if (
                event.key ===
                "Escape"
            ) {


                if (
                    leaveModal
                        .classList
                        .contains(
                            "show"
                        )
                ) {

                    closeLeaveModal();
                }


                if (
                    holidayModal
                        .classList
                        .contains(
                            "show"
                        )
                ) {

                    closeHolidayModal();
                }
            }
        }
    );


    // =========================================================
    // NAVIGATION
    // =========================================================

    function previousMonth() {

        currentDate.setMonth(
            currentDate.getMonth() - 1
        );

        renderCalendar();
    }


    function nextMonth() {

        currentDate.setMonth(
            currentDate.getMonth() + 1
        );

        renderCalendar();
    }


    function goToToday() {

        currentDate =
            new Date();

        renderCalendar();
    }


    // =========================================================
    // INITIAL RENDER
    // =========================================================

    renderCalendar();

</script>

</body>

</html>