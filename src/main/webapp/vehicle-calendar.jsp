<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // =========================================================
    // LOGIN CHECK
    // =========================================================
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    // =========================================================
    // USER SESSION
    // =========================================================
    String name = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("userRole");

    if (name == null || name.isBlank()) {
        name = "Pengguna";
    }

    String userInitial = name.substring(0, 1).toUpperCase();

    // =========================================================
    // CALENDAR DATA
    // =========================================================
    LocalDate today =
        (LocalDate) request.getAttribute("today");

    YearMonth selectedMonth =
        (YearMonth) request.getAttribute("selectedMonth");

    YearMonth previousMonth =
        (YearMonth) request.getAttribute("previousMonth");

    YearMonth nextMonth =
        (YearMonth) request.getAttribute("nextMonth");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> applications =
        (List<Map<String,Object>>)
        request.getAttribute("applications");

    @SuppressWarnings("unchecked")
    Map<LocalDate,List<Map<String,Object>>> applicationsByDate =
        (Map<LocalDate,List<Map<String,Object>>>)
        request.getAttribute("applicationsByDate");

    if (applications == null) {
        applications = new ArrayList<>();
    }

    if (applicationsByDate == null) {
        applicationsByDate = new HashMap<>();
    }

    if (today == null) {
        today = LocalDate.now();
    }

    if (selectedMonth == null) {
        selectedMonth = YearMonth.now();
    }

    if (previousMonth == null) {
        previousMonth = selectedMonth.minusMonths(1);
    }

    if (nextMonth == null) {
        nextMonth = selectedMonth.plusMonths(1);
    }

    // =========================================================
    // MALAY MONTH
    // =========================================================
    String[] monthNames = {
        "",
        "Januari",
        "Februari",
        "Mac",
        "April",
        "Mei",
        "Jun",
        "Julai",
        "Ogos",
        "September",
        "Oktober",
        "November",
        "Disember"
    };

    String monthTitle =
        monthNames[selectedMonth.getMonthValue()]
        + " "
        + selectedMonth.getYear();

    // =========================================================
    // CALENDAR POSITION
    // Sunday first
    // =========================================================
    LocalDate firstDate =
        selectedMonth.atDay(1);

    int firstDayOffset =
        firstDate.getDayOfWeek().getValue() % 7;

    int daysInMonth =
        selectedMonth.lengthOfMonth();

    int totalCells =
        firstDayOffset + daysInMonth;

    int totalRows =
        (int) Math.ceil(totalCells / 7.0);

    // =========================================================
    // TIME FORMAT
    // =========================================================
    SimpleDateFormat timeFormat =
        new SimpleDateFormat("hh:mm a");

    // =========================================================
    // ESCAPE HTML
    // =========================================================
    java.util.function.Function<Object,String> esc = value -> {

        if (value == null) {
            return "";
        }

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    };

 // =========================================================
 // SUMMARY
 // =========================================================

 Integer totalBookingsObj =
     (Integer) request.getAttribute("totalBookings");

 Integer totalVehiclesObj =
     (Integer) request.getAttribute("totalVehicles");

 Integer todayBookingsObj =
     (Integer) request.getAttribute("todayBookings");


 int totalBookings =
     totalBookingsObj != null
         ? totalBookingsObj
         : applications.size();


 int totalVehicles =
     totalVehiclesObj != null
         ? totalVehiclesObj
         : 0;


 int todayBookings =
     todayBookingsObj != null
         ? todayBookingsObj
         : 0;
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
        Kalendar Kenderaan - PKB
    </title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=vehicle-calendar-20261004-v3"
    >

    <style>

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

        .vehicle-calendar-page {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }


        /* =====================================================
           PAGE HEADER
           ===================================================== */

        .vehicle-page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 20px;
        }

        .vehicle-page-title {
            min-width: 0;
        }

        .vehicle-page-title h1 {
            margin: 0 0 6px;

            color: #172033;

            font-size: 27px;
            font-weight: 750;

            line-height: 1.2;

            letter-spacing: -0.4px;
        }

        .vehicle-page-title p {
            margin: 0;

            color: #7f899a;

            font-size: 14px;
            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           HEADER RIGHT
           ===================================================== */

        .vehicle-header-actions {
            display: flex;
            align-items: center;

            gap: 10px;

            flex-shrink: 0;
        }


        /* =====================================================
           USER CHIP
           ===================================================== */

        .vehicle-calendar-page .user-chip {
            display: flex;
            align-items: center;

            gap: 10px;

            min-height: 46px;

            padding: 6px 13px 6px 7px;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 12px;

            box-shadow:
                0 3px 12px
                rgba(31, 41, 61, .04);
        }

        .vehicle-calendar-page .user-chip .avatar {
            width: 34px;
            height: 34px;

            display: grid;
            place-items: center;

            border-radius: 9px;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8e9
                );

            border: 1px solid #efd8dc;

            color: #8d1f2d;

            font-size: 13px;
            font-weight: 700;
        }

        .vehicle-calendar-page .user-chip b {
            color: #2e3748;

            font-size: 13px;
            font-weight: 650;

            white-space: nowrap;
        }


        /* =====================================================
           SUMMARY
           ===================================================== */

        .vehicle-summary {
            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 14px;

            width: 100%;

            margin-bottom: 20px;
        }

        .vehicle-summary-card {
            position: relative;

            min-width: 0;
            min-height: 100px;

            padding: 16px 18px;

            overflow: hidden;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 13px;

            box-shadow:
                0 4px 14px
                rgba(27, 36, 53, .04);
        }

        .vehicle-summary-card::before {
            content: "";

            position: absolute;

            top: 14px;
            bottom: 14px;
            left: 0;

            width: 3px;

            border-radius:
                0 4px 4px 0;

            background:
                linear-gradient(
                    180deg,
                    #8d1f2d,
                    #d5a12b
                );
        }

        .vehicle-summary-card span {
            display: block;

            color: #7f899a;

            font-size: 11px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: .35px;
        }

        .vehicle-summary-card strong {
            display: block;

            margin-top: 7px;

            color: #172033;

            font-size: 25px;
            font-weight: 750;

            line-height: 1;
        }

        .vehicle-summary-card small {
            display: block;

            margin-top: 7px;

            color: #8b94a3;

            font-size: 11px;
            font-weight: 400;

            line-height: 1.4;
        }


        /* =====================================================
           INFORMATION BAR
           ===================================================== */

        .vehicle-role-info {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 16px;

            width: 100%;

            margin-bottom: 18px;

            padding: 13px 15px;

            background:
                linear-gradient(
                    135deg,
                    #fffafa,
                    #fffdf8
                );

            border: 1px solid #eadde0;
            border-radius: 11px;
        }

        .vehicle-role-left {
            display: flex;
            align-items: center;

            gap: 12px;

            min-width: 0;
        }

        .vehicle-role-icon {
            width: 38px;
            height: 38px;

            min-width: 38px;

            display: grid;
            place-items: center;

            background: #ffffff;

            border: 1px solid #ecdadd;
            border-radius: 9px;

            font-size: 17px;
        }

        .vehicle-role-info strong {
            display: block;

            margin-bottom: 3px;

            color: #293447;

            font-size: 13px;
            font-weight: 650;
        }

        .vehicle-role-info p {
            margin: 0;

            color: #7e8797;

            font-size: 11.5px;
            font-weight: 400;

            line-height: 1.4;
        }


        /* =====================================================
           APPLY BUTTON
           ===================================================== */

        .btn-apply {
            display: inline-flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            min-height: 39px;

            padding: 9px 15px;

            background: #971d2d;

            border: 1px solid #971d2d;
            border-radius: 8px;

            color: #ffffff;

            font-family: inherit;

            font-size: 12px;
            font-weight: 650;

            text-decoration: none;

            white-space: nowrap;

            transition: .15s ease;
        }

        .btn-apply:hover {
            background: #7e1724;

            border-color: #7e1724;

            color: #ffffff;

            transform: translateY(-1px);

            box-shadow:
                0 4px 10px
                rgba(141, 31, 45, .15);
        }


        /* =====================================================
           CALENDAR CARD
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
           CALENDAR MONTH HEADER
           ===================================================== */

        .modern-calendar-header {
            display: grid;

            grid-template-columns:
                45px 1fr 45px;

            align-items: center;

            gap: 12px;

            width: 100%;

            padding: 16px 18px;

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

            margin-bottom: 4px;

            color: #929baa;

            font-size: 10px;
            font-weight: 700;

            text-transform: uppercase;

            letter-spacing: .6px;
        }

        .calendar-month-area h2 {
            margin: 0;

            color: #172033;

            font-size: 20px;
            font-weight: 750;

            line-height: 1.2;
        }


        /* =====================================================
           MONTH NAVIGATION
           ===================================================== */

        .calendar-nav {
            width: 39px;
            height: 39px;

            display: grid;
            place-items: center;

            padding: 0;

            background: #ffffff;

            border: 1px solid #dfe3e9;
            border-radius: 9px;

            color: #697486;

            font-family: inherit;

            font-size: 22px;
            font-weight: 400;

            line-height: 1;

            text-decoration: none;

            cursor: pointer;

            transition: .15s ease;
        }

        .calendar-nav:hover {
            background: #fff5f6;

            color: #8d1f2d;

            border-color: #d8aeb5;
        }


        /* =====================================================
           TOOLBAR
           ===================================================== */

        .calendar-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 15px;

            width: 100%;

            padding: 11px 17px;

            background: #fafbfc;

            border-bottom:
                1px solid #eceef2;
        }

        .today-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;

            min-height: 34px;

            padding: 7px 11px;

            background: #ffffff;

            border: 1px solid #dfe3e9;
            border-radius: 7px;

            color: #8d1f2d;

            font-family: inherit;

            font-size: 12px;
            font-weight: 650;

            text-decoration: none;

            transition: .15s ease;
        }

        .today-button:hover {
            background: #8d1f2d;

            border-color: #8d1f2d;

            color: #ffffff;
        }


        /* =====================================================
           LEGEND
           ===================================================== */

        .calendar-legend {
            display: flex;
            align-items: center;
            justify-content: flex-end;

            flex-wrap: wrap;

            gap: 8px;
        }

        .legend-item {
            display: inline-flex;
            align-items: center;

            gap: 6px;

            min-height: 27px;

            padding: 5px 9px;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 999px;

            color: #687386;

            font-size: 10.5px;
            font-weight: 500;

            line-height: 1;
        }

        .legend-box {
            width: 8px;
            height: 8px;

            flex-shrink: 0;

            border-radius: 50%;
        }

        .legend-box.approved {
            background: #24875a;
        }

        .legend-box.today {
            background: #8d1f2d;
        }

        .legend-box.off-day {
            background: #d9dde4;

            border: 1px solid #c4c9d1;
        }


        /* =====================================================
           CALENDAR
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

            padding: 11px 5px;

            background: #f8f9fb;

            border-right:
                1px solid #e9ecf0;

            border-bottom:
                1px solid #e4e7eb;

            color: #687386;

            font-size: 11px;
            font-weight: 700;

            line-height: 1.2;

            text-align: center;
            text-transform: uppercase;

            letter-spacing: .3px;
        }

        .cal-head:nth-child(7n) {
            border-right: 0;
        }

        .cal-head.weekend {
            background: #f3f4f6;

            color: #858e9c;
        }


        /* =====================================================
           CALENDAR DAY
           ===================================================== */

        .cal-day {
            position: relative;

            min-width: 0;
            min-height: 120px;

            padding: 8px;

            overflow: visible;

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
           WEEKEND
           ===================================================== */

        .cal-day.off-day {
            background: #f7f8fa;
        }

        .cal-day.off-day:hover {
            background: #f4f5f7;
        }

        .off-day-label {
            position: absolute;

            top: 9px;
            right: 8px;

            padding: 3px 6px;

            background: #e9ebef;

            border-radius: 4px;

            color: #8f98a5;

            font-size: 8px;
            font-weight: 700;

            line-height: 1.2;

            text-transform: uppercase;

            letter-spacing: .3px;
        }


        /* =====================================================
           DATE NUMBER
           ===================================================== */

        .calendar-date {
            position: relative;

            z-index: 1;

            width: 28px;
            height: 28px;

            display: grid;
            place-items: center;

            border-radius: 6px;

            color: #536073;

            font-size: 12px;
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
           VEHICLE EVENT
           ===================================================== */

        .vehicle-event {
            position: relative;

            width: 100%;
            max-width: 100%;
            min-width: 0;

            margin-top: 6px;

            padding: 7px 8px 7px 10px;

            background: #eaf7f0;

            color: #176c43;

            border-left:
                3px solid #24875a;

            border-radius: 7px;

            cursor: pointer;

            transition:
                transform .12s ease,
                box-shadow .12s ease;
        }

        .vehicle-event:hover {
            transform: translateY(-1px);

            box-shadow:
                0 3px 8px
                rgba(27, 36, 53, .08);
        }

        .vehicle-plate {
            display: block;

            width: 100%;

            overflow: hidden;

            color: #176c43;

            font-size: 11px;
            font-weight: 700;

            line-height: 1.3;

            white-space: nowrap;

            text-overflow: ellipsis;
        }

        .vehicle-time {
            display: block;

            width: 100%;

            margin-top: 3px;

            overflow: hidden;

            color: #4f7c67;

            font-size: 9.5px;
            font-weight: 450;

            line-height: 1.3;

            white-space: nowrap;

            text-overflow: ellipsis;
        }

        .vehicle-person {
            display: block;

            width: 100%;

            margin-top: 2px;

            overflow: hidden;

            color: #648373;

            font-size: 9px;
            font-weight: 450;

            line-height: 1.3;

            white-space: nowrap;

            text-overflow: ellipsis;
        }


        /* =====================================================
           MODAL
           ===================================================== */

        .vehicle-modal {
            position: fixed;

            inset: 0;

            z-index: 2000;

            display: none;
            align-items: center;
            justify-content: center;

            padding: 20px;

            background:
                rgba(20, 29, 47, .46);

            backdrop-filter:
                blur(3px);
        }

        .vehicle-modal.show {
            display: flex;
        }

        .vehicle-modal-box {
            width: 100%;
            max-width: 520px;

            max-height: 88vh;

            overflow-y: auto;

            background: #ffffff;

            border-radius: 15px;

            box-shadow:
                0 24px 60px
                rgba(20, 29, 47, .22);
        }

        .vehicle-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;

            gap: 14px;

            padding: 18px 20px;

            border-bottom:
                1px solid #eceef2;
        }

        .vehicle-modal-heading h2 {
            margin: 0 0 4px;

            color: #172033;

            font-size: 19px;
            font-weight: 700;
        }

        .vehicle-modal-heading p {
            margin: 0;

            color: #929aa8;

            font-size: 11px;
        }

        .vehicle-modal-close {
            width: 34px;
            height: 34px;

            display: grid;
            place-items: center;

            flex-shrink: 0;

            padding: 0;

            background: #ffffff;

            border: 1px solid #e3e6eb;
            border-radius: 8px;

            color: #687284;

            font-size: 20px;

            cursor: pointer;
        }

        .vehicle-modal-close:hover {
            background: #fff3f4;

            color: #8d1f2d;

            border-color: #dab7bd;
        }

        .vehicle-modal-content {
            padding: 18px 20px;
        }

        .vehicle-detail-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 10px;
        }

        .vehicle-detail-row {
            min-width: 0;

            padding: 11px 12px;

            background: #fafbfc;

            border: 1px solid #eaecf0;
            border-radius: 8px;
        }

        .vehicle-detail-row.full {
            grid-column: 1 / -1;
        }

        .vehicle-detail-row span {
            display: block;

            margin-bottom: 5px;

            color: #8b94a4;

            font-size: 10px;
            font-weight: 650;

            text-transform: uppercase;

            letter-spacing: .3px;
        }

        .vehicle-detail-row strong {
            display: block;

            color: #404a5c;

            font-size: 12px;
            font-weight: 600;

            line-height: 1.45;

            overflow-wrap: anywhere;
        }

        .approved-badge {
            display: inline-flex !important;
            align-items: center;

            width: fit-content;

            padding: 5px 9px;

            background: #eaf8f1;

            border-radius: 999px;

            color: #20744b !important;

            font-size: 11px !important;
            font-weight: 650 !important;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1150px) {

            .vehicle-summary {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

            .cal-day {
                min-height: 105px;
            }

            .vehicle-plate {
                font-size: 10px;
            }

            .vehicle-time {
                font-size: 8.5px;
            }

            .vehicle-person {
                font-size: 8px;
            }
        }


        @media (max-width: 700px) {

            .vehicle-page-header {
                flex-direction: column;

                align-items: stretch;
            }

            .vehicle-header-actions {
                justify-content: flex-end;
            }

            .vehicle-summary {
                grid-template-columns: 1fr;
            }

            .vehicle-role-info {
                flex-direction: column;

                align-items: stretch;
            }

            .btn-apply {
                width: 100%;
            }

            .calendar-toolbar {
                flex-direction: column;

                align-items: flex-start;
            }

            .calendar-legend {
                justify-content: flex-start;
            }

            .cal-day {
                min-height: 85px;

                padding: 4px;
            }

            .cal-head {
                padding: 8px 2px;

                font-size: 8px;
            }

            .calendar-date {
                width: 22px;
                height: 22px;

                font-size: 9px;
            }

            .vehicle-event {
                padding: 5px 5px 5px 7px;
            }

            .vehicle-plate {
                font-size: 8px;
            }

            .vehicle-time,
            .vehicle-person {
                display: none;
            }

            .off-day-label {
                display: none;
            }

            .vehicle-detail-grid {
                grid-template-columns: 1fr;
            }

            .vehicle-detail-row.full {
                grid-column: auto;
            }
        }

    
        /* =====================================================
           MOBILE STYLE MATCHING KALENDAR CUTI
           ===================================================== */

        @media (max-width: 700px) {
            main {
                width: 100%; max-width: 100%; min-width: 0; margin-left: 0;
                padding: 74px 13px 28px; box-sizing: border-box; overflow-x: hidden;
            }
            .vehicle-calendar-page { width: 100%; max-width: 100%; min-width: 0; }
            .vehicle-page-header {
                position: relative; display: block; min-height: 44px; margin-bottom: 16px;
            }
            .vehicle-page-title { min-width: 0; padding-right: 100px; }
            .vehicle-page-title h1 { font-size: 21px; line-height: 1.25; }
            .vehicle-page-title p { font-size: 12px; line-height: 1.4; }
            .vehicle-header-actions {
                position: absolute; top: 0; right: 0; z-index: 3;
                width: max-content; display: flex; align-items: center;
                justify-content: flex-end; gap: 7px;
            }
            .vehicle-calendar-page .user-chip { min-height: 40px; padding: 5px; }
            .vehicle-calendar-page .user-chip .avatar { width: 30px; height: 30px; }
            .vehicle-calendar-page .user-chip b { display: none; }

            .vehicle-calendar-page .vehicle-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 9px; margin-bottom: 14px;
            }
            .vehicle-summary-card { min-width: 0; min-height: 66px; padding: 10px 12px; border-radius: 11px; }
            .vehicle-summary-card span { font-size: 8.5px; line-height: 1.3; }
            .vehicle-summary-card strong { margin-top: 4px; font-size: 19px; }
            .vehicle-summary-card small { margin-top: 4px; font-size: 8px; line-height: 1.3; }

            .vehicle-role-info {
                align-items: flex-start; flex-direction: column; gap: 10px;
                margin-bottom: 14px; padding: 11px 12px;
            }
            .vehicle-role-left { gap: 9px; }
            .vehicle-role-icon { width: 34px; height: 34px; min-width: 34px; font-size: 15px; }
            .vehicle-role-info strong { font-size: 12px; }
            .vehicle-role-info p { font-size: 10px; }
            .btn-apply { width: 100%; min-height: 38px; }

            .calendar-toolbar { gap: 8px; }
            .calendar-legend { flex-wrap: wrap; gap: 6px; }
            .cal-day { min-height: 80px; padding: 3px; }
            .cal-head { padding: 7px 1px; font-size: 6.5px; letter-spacing: 0; }
            .calendar-date { width: 19px; height: 19px; font-size: 7px; }
            .vehicle-event { padding: 3px 3px 3px 5px; border-radius: 4px; }
            .vehicle-plate { font-size: 6.5px; line-height: 1.2; overflow-wrap: anywhere; }
            .vehicle-time, .vehicle-person, .off-day-label { display: none; }
            .vehicle-detail-grid { grid-template-columns: 1fr; }
            .vehicle-detail-row.full { grid-column: auto; }
        }

        @media (max-width: 360px) {
            main { padding-right: 10px; padding-left: 10px; }
            .vehicle-page-title { padding-right: 94px; }
            .vehicle-header-actions { gap: 5px; }
            .vehicle-calendar-page .user-chip { min-height: 36px; }
            .vehicle-calendar-page .user-chip .avatar { width: 28px; height: 28px; }
            .vehicle-calendar-page .vehicle-summary { gap: 7px; }
            .vehicle-summary-card { padding: 9px 10px; }
            .cal-day { min-height: 72px; }
        }
        /* Header spacing fix for narrow mobile screens */
        @media (max-width: 700px) {
            .vehicle-page-header {
                display: grid !important;
                grid-template-columns: minmax(0, 1fr) auto !important;
                align-items: start !important;
                justify-content: initial !important;
                gap: 8px !important;
                min-height: 0 !important;
            }
            .vehicle-page-title {
                grid-column: 1;
                grid-row: 1;
                min-width: 0 !important;
                padding-right: 0 !important;
            }
            .vehicle-page-title h1 {
                max-width: 100%;
                font-size: 21px;
                line-height: 1.25;
                overflow-wrap: anywhere;
            }
            .vehicle-page-title p {
                max-width: 100%;
                font-size: 12px;
                line-height: 1.4;
                overflow-wrap: anywhere;
            }
            .vehicle-header-actions {
                position: static !important;
                grid-column: 2;
                grid-row: 1;
                align-self: start;
                width: auto !important;
                max-width: none !important;
                margin: 0 !important;
                gap: 6px !important;
            }
            .vehicle-calendar-page .user-chip {
                min-width: 0;
                min-height: 40px;
                padding: 5px;
            }
            .vehicle-calendar-page .user-chip b {
                display: none !important;
            }
        }
        @media (max-width: 360px) {
            .vehicle-page-header { gap: 6px !important; }
            .vehicle-page-title h1 { font-size: 19px; }
        }</style>

</head>

<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="vehicle-calendar-page">


            <!-- =================================================
                 PAGE HEADER
                 ================================================= -->

            <div class="vehicle-page-header">


                <div class="vehicle-page-title">

                    <h1>
                        Kalendar Kenderaan
                    </h1>

                    <p>
                        Semak jadual penggunaan kenderaan syarikat yang telah diluluskan.
                    </p>

                </div>


                <!--
                    IMPORTANT:
                    Notification bell tidak ditambah di sini.
                    Bell sedia ada daripada layout/style utama
                    akan digunakan supaya tidak duplicate.
                -->

                <div class="vehicle-header-actions">

                    <div class="user-chip">

                        <div class="avatar">
                            <%= esc.apply(userInitial) %>
                        </div>

                        <b>
                            <%= esc.apply(name) %>
                        </b>

                    </div>

                </div>


            </div>


            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="vehicle-summary">


                <div class="vehicle-summary-card">

                    <span>
                        Penggunaan Bulan Ini
                    </span>

                    <strong>
                        <%= totalBookings %>
                    </strong>

                    <small>
                        Permohonan kenderaan yang diluluskan
                    </small>

                </div>


                <div class="vehicle-summary-card">

                    <span>
                        Kenderaan Digunakan
                    </span>

                    <strong>
                        <%= totalVehicles %>
                    </strong>

                    <small>
                        Kenderaan terlibat pada bulan ini
                    </small>

                </div>


                <div class="vehicle-summary-card">

                    <span>
                        Penggunaan Hari Ini
                    </span>

                    <strong>
                        <%= todayBookings %>
                    </strong>

                    <small>
                        Tempahan kenderaan pada hari ini
                    </small>

                </div>


            </div>


            <!-- =================================================
                 INFORMATION BAR
                 ================================================= -->

            <div class="vehicle-role-info">


                <div class="vehicle-role-left">

                    <div class="vehicle-role-icon">
                        🚗
                    </div>


                    <div>

                        <strong>
                            Jadual Penggunaan Kenderaan
                        </strong>

                        <p>
                            Hanya permohonan yang telah diluluskan dipaparkan dalam kalendar.
                        </p>

                    </div>

                </div>


                <a
                    href="<%= request.getContextPath() %>/vehicle-apply"
                    class="btn-apply"
                >
                    + Permohonan Kenderaan
                </a>


            </div>


            <!-- =================================================
                 CALENDAR CARD
                 ================================================= -->

            <div class="modern-calendar-card">


                <!-- MONTH HEADER -->

                <div class="modern-calendar-header">


                    <a
                        class="calendar-nav"
                        href="<%= request.getContextPath() %>/vehicle-calendar?year=<%= previousMonth.getYear() %>&month=<%= previousMonth.getMonthValue() %>"
                        title="Bulan sebelumnya"
                        aria-label="Bulan sebelumnya"
                    >
                        &#8249;
                    </a>


                    <div class="calendar-month-area">

                        <span>
                            Kalendar Bulanan
                        </span>

                        <h2>
                            <%= monthTitle %>
                        </h2>

                    </div>


                    <a
                        class="calendar-nav"
                        href="<%= request.getContextPath() %>/vehicle-calendar?year=<%= nextMonth.getYear() %>&month=<%= nextMonth.getMonthValue() %>"
                        title="Bulan seterusnya"
                        aria-label="Bulan seterusnya"
                    >
                        &#8250;
                    </a>


                </div>


                <!-- =================================================
                     TOOLBAR
                     ================================================= -->

                <div class="calendar-toolbar">


                    <a
                        class="today-button"
                        href="<%= request.getContextPath() %>/vehicle-calendar?year=<%= today.getYear() %>&month=<%= today.getMonthValue() %>"
                    >
                        Hari Ini
                    </a>


                    <div class="calendar-legend">


                        <div class="legend-item">

                            <span
                                class="legend-box approved"
                            ></span>

                            Diluluskan

                        </div>


                        <div class="legend-item">

                            <span
                                class="legend-box today"
                            ></span>

                            Hari Ini

                        </div>


                        <div class="legend-item">

                            <span
                                class="legend-box off-day"
                            ></span>

                            Jumaat / Sabtu

                        </div>


                    </div>


                </div>


                <!-- =================================================
                     CALENDAR
                     ================================================= -->

                <div class="calendar-container">

                    <div class="calendar">


                        <!-- DAY HEADERS -->

                        <div class="cal-head">
                            Ahad
                        </div>

                        <div class="cal-head">
                            Isnin
                        </div>

                        <div class="cal-head">
                            Selasa
                        </div>

                        <div class="cal-head">
                            Rabu
                        </div>

                        <div class="cal-head">
                            Khamis
                        </div>

                        <div class="cal-head weekend">
                            Jumaat
                        </div>

                        <div class="cal-head weekend">
                            Sabtu
                        </div>


                        <%
                            int dayNumber = 1;

                            for (
                                int row = 0;
                                row < totalRows;
                                row++
                            ) {

                                for (
                                    int column = 0;
                                    column < 7;
                                    column++
                                ) {

                                    int cellIndex =
                                        (row * 7)
                                        + column;

                                    if (
                                        cellIndex < firstDayOffset
                                        ||
                                        dayNumber > daysInMonth
                                    ) {
                        %>


                                    <div
                                        class="cal-day empty"
                                    ></div>


                        <%
                                        continue;
                                    }


                                    LocalDate currentDate =
                                        selectedMonth.atDay(
                                            dayNumber
                                        );


                                    boolean isToday =
                                        currentDate.equals(
                                            today
                                        );


                                    boolean isOffDay =
                                        column == 5
                                        ||
                                        column == 6;


                                    List<Map<String,Object>>
                                        dayApplications =

                                            applicationsByDate
                                                .getOrDefault(
                                                    currentDate,
                                                    Collections.emptyList()
                                                );
                        %>


                                <div
                                    class="
                                        cal-day
                                        <%= isToday
                                            ? "today"
                                            : ""
                                        %>
                                        <%= isOffDay
                                            ? "off-day"
                                            : ""
                                        %>
                                    "
                                >


                                    <!-- DATE -->

                                    <div class="calendar-date">

                                        <%= dayNumber %>

                                    </div>


                                    <!-- WEEKEND LABEL -->

                                    <% if (isOffDay) { %>

                                        <span class="off-day-label">
                                            Cuti
                                        </span>

                                    <% } %>


                                    <!-- VEHICLE BOOKINGS -->

                                    <%

                                        for (
                                            Map<String,Object> app :
                                            dayApplications
                                        ) {


                                            String startTime = "";

                                            if (
                                                app.get(
                                                    "start_time"
                                                ) != null
                                            ) {

                                                startTime =
                                                    timeFormat.format(
                                                        app.get(
                                                            "start_time"
                                                        )
                                                    );
                                            }


                                            /*
                                             * Effective return:
                                             * - Jika Admin merekod pemulangan sebenar, guna actual return.
                                             * - Jika tiada actual return, guna expected return seperti biasa.
                                             */
                                            Object effectiveReturnTimeObj =
                                                app.get("actual_return_time") != null
                                                    ? app.get("actual_return_time")
                                                    : app.get("expected_return_time");

                                            String returnTime = "";

                                            if (effectiveReturnTimeObj != null) {
                                                returnTime =
                                                    timeFormat.format(
                                                        effectiveReturnTimeObj
                                                    );
                                            }

                                            java.sql.Date sqlUseDate =
                                                (java.sql.Date) app.get("use_date");

                                            java.sql.Date sqlExpectedReturnDate =
                                                (java.sql.Date) app.get("expected_return_date");

                                            java.sql.Date sqlActualReturnDate =
                                                (java.sql.Date) app.get("actual_return_date");

                                            java.sql.Date sqlReturnDate =
                                                sqlActualReturnDate != null
                                                    ? sqlActualReturnDate
                                                    : sqlExpectedReturnDate;


                                            LocalDate appStartDate =
                                                sqlUseDate != null
                                                    ? sqlUseDate.toLocalDate()
                                                    : currentDate;


                                            LocalDate appReturnDate =
                                                sqlReturnDate != null
                                                    ? sqlReturnDate.toLocalDate()
                                                    : appStartDate;


                                            	boolean isMultiDay =
                                            	    !appStartDate.equals(appReturnDate);


                                            	boolean isFirstBookingDay =
                                            	    currentDate.equals(appStartDate);


                                            	boolean isLastBookingDay =
                                            	    currentDate.equals(appReturnDate);

                                            	String useDateText =
                                            		    String.format(
                                            		        "%02d/%02d/%04d",
                                            		        appStartDate.getDayOfMonth(),
                                            		        appStartDate.getMonthValue(),
                                            		        appStartDate.getYear()
                                            		    );


                                            		String returnDateText =
                                            		    String.format(
                                            		        "%02d/%02d/%04d",
                                            		        appReturnDate.getDayOfMonth(),
                                            		        appReturnDate.getMonthValue(),
                                            		        appReturnDate.getYear()
                                            		    );

                                            	String calendarTimeText;


                                            	if (!isMultiDay) {

                                            	    // SAME DAY
                                            	    calendarTimeText =
                                            	        startTime
                                            	        + (
                                            	            !startTime.isBlank() &&
                                            	            !returnTime.isBlank()
                                            	                ? " - "
                                            	                : ""
                                            	        )
                                            	        + returnTime;

                                            	}
                                            	else if (isFirstBookingDay) {

                                            	    // FIRST DAY
                                            	    calendarTimeText =
                                            	        startTime
                                            	        + " → "
                                            	        + String.format(
                                            	            "%02d/%02d",
                                            	            appReturnDate.getDayOfMonth(),
                                            	            appReturnDate.getMonthValue()
                                            	        );

                                            	}
                                            	else if (isLastBookingDay) {

                                            	    // LAST DAY
                                            	    calendarTimeText =
                                            	        "→ " + returnTime;

                                            	}
                                            	else {

                                            	    // MIDDLE DAY
                                            	    calendarTimeText =
                                            	        "Sedang digunakan";
                                            	}

                                            String plateNumber =
                                                esc.apply(
                                                    app.get(
                                                        "plate_number"
                                                    )
                                                );


                                            String vehicleName =
                                                esc.apply(
                                                    app.get(
                                                        "vehicle_name"
                                                    )
                                                );


                                            String applicationNo =
                                                esc.apply(
                                                    app.get(
                                                        "application_no"
                                                    )
                                                );


                                            String applicantName =
                                                esc.apply(
                                                    app.get(
                                                        "applicant_name"
                                                    )
                                                );


                                            String driverName =
                                                esc.apply(
                                                    app.get(
                                                        "driver_name"
                                                    )
                                                );


                                            String destination =
                                                esc.apply(
                                                    app.get(
                                                        "destination"
                                                    )
                                                );


                                            String purpose =
                                                esc.apply(
                                                    app.get(
                                                        "purpose"
                                                    )
                                                );

                                    %>


                                        <div
    class="vehicle-event"

    data-plate="<%= plateNumber %>"
    data-vehicle="<%= vehicleName %>"
    data-application="<%= applicationNo %>"
    data-applicant="<%= applicantName %>"

    data-use-date="<%= esc.apply(useDateText) %>"
    data-return-date="<%= esc.apply(returnDateText) %>"

    data-start="<%= esc.apply(startTime) %>"
    data-return="<%= esc.apply(returnTime) %>"

    data-driver="<%= driverName %>"
    data-destination="<%= destination %>"
    data-purpose="<%= purpose %>"

    onclick="openVehicleModal(this)"
>


                                            <span class="vehicle-plate">

                                                <%= plateNumber %>

                                            </span>


                                            <span class="vehicle-time">
    <%= esc.apply(calendarTimeText) %>
</span>


                                            <span class="vehicle-person">

                                                <%= applicantName %>

                                            </span>


                                        </div>


                                    <%
                                        }
                                    %>


                                </div>


                        <%
                                    dayNumber++;
                                }
                            }
                        %>


                    </div>

                </div>


            </div>


        </div>

    </main>

</div>


<!-- =========================================================
     VEHICLE DETAIL MODAL
     ========================================================= -->

<div
    class="vehicle-modal"
    id="vehicleModal"
>

    <div class="vehicle-modal-box">


        <div class="vehicle-modal-header">


            <div class="vehicle-modal-heading">

                <h2>
                    Butiran Penggunaan Kenderaan
                </h2>

                <p>
                    Maklumat lengkap permohonan kenderaan
                </p>

            </div>


            <button
                type="button"
                class="vehicle-modal-close"
                onclick="closeVehicleModal()"
                aria-label="Tutup"
            >
                &times;
            </button>


        </div>


        <div class="vehicle-modal-content">


            <div class="vehicle-detail-grid">


                <div class="vehicle-detail-row">

                    <span>
                        No. Pendaftaran
                    </span>

                    <strong id="modalPlate">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row">

                    <span>
                        Kenderaan
                    </span>

                    <strong id="modalVehicle">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row">

                    <span>
                        No. Permohonan
                    </span>

                    <strong id="modalApplicationNo">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row">

                    <span>
                        Status
                    </span>

                    <strong class="approved-badge">
                        Diluluskan
                    </strong>

                </div>


                <div class="vehicle-detail-row full">

                    <span>
                        Pemohon
                    </span>

                    <strong id="modalApplicant">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row">

                    <span>
    Tarikh &amp; Masa Mula
</span>

<strong id="modalStart">
    —
</strong>

                </div>


                <div class="vehicle-detail-row">

                    <span>
    Tarikh &amp; Masa Pulang
</span>

<strong id="modalReturn">
    —
</strong>

                </div>


                <div class="vehicle-detail-row full">

                    <span>
                        Pemandu
                    </span>

                    <strong id="modalDriver">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row full">

                    <span>
                        Destinasi
                    </span>

                    <strong id="modalDestination">
                        —
                    </strong>

                </div>


                <div class="vehicle-detail-row full">

                    <span>
                        Tujuan
                    </span>

                    <strong id="modalPurpose">
                        —
                    </strong>

                </div>


            </div>


        </div>


    </div>

</div>


<script>

    const vehicleModal =
        document.getElementById(
            "vehicleModal"
        );


    function setModalText(
        id,
        value
    ) {

        const element =
            document.getElementById(id);

        if (!element) {
            return;
        }

        if (
            value == null
            ||
            value.trim() === ""
        ) {

            element.textContent = "—";

        } else {

            element.textContent = value;
        }
    }


    function openVehicleModal(element) {

        setModalText(
            "modalPlate",
            element.dataset.plate
        );

        setModalText(
            "modalVehicle",
            element.dataset.vehicle
        );

        setModalText(
            "modalApplicationNo",
            element.dataset.application
        );

        setModalText(
            "modalApplicant",
            element.dataset.applicant
        );

        setModalText(
        	    "modalStart",
        	    (
        	        element.dataset.useDate || ""
        	    )
        	    +
        	    (
        	        element.dataset.start
        	            ? " • " + element.dataset.start
        	            : ""
        	    )
        	);


        	setModalText(
        	    "modalReturn",
        	    (
        	        element.dataset.returnDate || ""
        	    )
        	    +
        	    (
        	        element.dataset.return
        	            ? " • " + element.dataset.return
        	            : ""
        	    )
        	);

        setModalText(
            "modalDriver",
            element.dataset.driver
        );

        setModalText(
            "modalDestination",
            element.dataset.destination
        );

        setModalText(
            "modalPurpose",
            element.dataset.purpose
        );


        vehicleModal.classList.add(
            "show"
        );

        document.body.style.overflow =
            "hidden";
    }


    function closeVehicleModal() {

        vehicleModal.classList.remove(
            "show"
        );

        document.body.style.overflow =
            "";
    }


    vehicleModal.addEventListener(
        "click",
        function(event) {

            if (
                event.target ===
                vehicleModal
            ) {

                closeVehicleModal();
            }
        }
    );


    document.addEventListener(
        "keydown",
        function(event) {

            if (
                event.key === "Escape"
                &&
                vehicleModal.classList.contains(
                    "show"
                )
            ) {

                closeVehicleModal();
            }
        }
    );

</script>

</body>

</html>