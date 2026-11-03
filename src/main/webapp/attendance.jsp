<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%

    /*

     * ============================================================

     * ATTENDANCE PAGE - LEAVEHUB

     * ============================================================

     */

    java.util.Map<String, Object> attendance =

            (java.util.Map<String, Object>) request.getAttribute("attendance");

    if (attendance == null) {

        attendance = new java.util.HashMap<>();

    }

    Object statusObj =

            attendance.get("status");

    Object checkInObj =

            attendance.get("checkIn");

    Object checkOutObj =

            attendance.get("checkOut");

    Object checkInDistanceObj =

            attendance.get("checkInDistance");

    Object checkOutDistanceObj =

            attendance.get("checkOutDistance");

    String attendanceStatus =
            statusObj != null ? String.valueOf(statusObj) : "BELUM_HADIR";

    java.util.Map<String, Object> approvedLeave =
            (java.util.Map<String, Object>) request.getAttribute("approvedLeave");
    boolean hasApprovedLeave = approvedLeave != null;
    String approvedLeaveType = hasApprovedLeave && approvedLeave.get("leaveType") != null
            ? String.valueOf(approvedLeave.get("leaveType")) : "Cuti diluluskan";
    String lateReason = attendance.get("lateReason") == null
            ? "" : String.valueOf(attendance.get("lateReason"));
    String earlyCheckoutReason = attendance.get("earlyCheckoutReason") == null
            ? "" : String.valueOf(attendance.get("earlyCheckoutReason"));
    java.time.LocalDate todayForStatus = java.time.LocalDate.now();
    java.time.LocalTime checkInTimeForStatus = null;
    java.time.LocalTime checkOutTimeForStatus = null;
    try {
        if (checkInObj instanceof java.sql.Timestamp) {
            checkInTimeForStatus = ((java.sql.Timestamp) checkInObj).toLocalDateTime().toLocalTime();
        }
        if (checkOutObj instanceof java.sql.Timestamp) {
            checkOutTimeForStatus = ((java.sql.Timestamp) checkOutObj).toLocalDateTime().toLocalTime();
        }
    } catch (Exception ignored) { }
    java.time.LocalTime endTimeForStatus = null;
    java.time.DayOfWeek dayForStatus = todayForStatus.getDayOfWeek();
    if (dayForStatus == java.time.DayOfWeek.SUNDAY || dayForStatus == java.time.DayOfWeek.MONDAY
            || dayForStatus == java.time.DayOfWeek.TUESDAY || dayForStatus == java.time.DayOfWeek.WEDNESDAY) {
        endTimeForStatus = java.time.LocalTime.of(16, 45);
    } else if (dayForStatus == java.time.DayOfWeek.THURSDAY) {
        endTimeForStatus = java.time.LocalTime.of(16, 30);
    }
    boolean lateCheckInForStatus = checkInTimeForStatus != null
            && checkInTimeForStatus.isAfter(java.time.LocalTime.of(8, 0));
    boolean earlyCheckOutForStatus = checkOutTimeForStatus != null && endTimeForStatus != null
            && checkOutTimeForStatus.isBefore(endTimeForStatus);

    String checkIn =

            checkInObj != null

                ? String.valueOf(checkInObj)

                : "-";

    String checkOut =

            checkOutObj != null

                ? String.valueOf(checkOutObj)

                : "-";

    String checkInDistance =

            checkInDistanceObj != null

                ? String.valueOf(checkInDistanceObj)

                : "-";

    String checkOutDistance =

            checkOutDistanceObj != null

                ? String.valueOf(checkOutDistanceObj)

                : "-";

    String userName =

            session.getAttribute("userName") != null

                ? String.valueOf(session.getAttribute("userName"))

                : "Pengguna";

    String contextPath =

            request.getContextPath();

%>

<%!

    /*

     * ============================================================

     * ESCAPE HTML

     * ============================================================

     */

    public String esc(String value) {

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

    /*

     * ============================================================

     * STATUS DISPLAY

     * ============================================================

     */

    String statusTitle =

            "Belum Check In";

    String statusDescription =

            "Anda belum merekodkan kehadiran untuk hari ini.";

    String statusClass =

            "status-pending";

    String statusIcon =

            "○";

    if (earlyCheckOutForStatus) {
        statusTitle = "Check Out Awal";
        statusDescription = "Check Out direkodkan sebelum waktu tamat kerja. "
                + (earlyCheckoutReason.isBlank() ? "Sebab belum direkodkan." : "Sebab: " + earlyCheckoutReason);
        statusClass = "status-pending";
        statusIcon = "!";
    } else if (lateCheckInForStatus && !lateReason.isBlank()) {
        statusTitle = "Lewat Bersebab";
        statusDescription = "Check In selepas 8:00 pagi. Sebab: " + lateReason;
        statusClass = "status-pending";
        statusIcon = "!";
    } else if (lateCheckInForStatus) {
        statusTitle = "Lewat";
        statusDescription = "Check In direkodkan selepas 8:00 pagi.";
        statusClass = "status-pending";
        statusIcon = "!";
    } else if (hasApprovedLeave
            && !"HADIR".equalsIgnoreCase(attendanceStatus)
            && !"SELESAI".equalsIgnoreCase(attendanceStatus)) {

        statusTitle = "Cuti Diluluskan";
        statusDescription = "Cuti " + approvedLeaveType + " telah diluluskan untuk hari ini.";
        statusClass = "status-complete";
        statusIcon = "✓";

    } else if ("HADIR".equalsIgnoreCase(attendanceStatus)) {

        statusTitle =

                "Sudah Check In";

        statusDescription =

                "Kehadiran masuk telah direkodkan. Sila lakukan Check Out apabila selesai bekerja.";

        statusClass =

                "status-present";

        statusIcon =

                "✓";

    } else if ("SELESAI".equalsIgnoreCase(attendanceStatus)) {

        statusTitle =

                "Kehadiran Lengkap";

        statusDescription =

                "Check In dan Check Out untuk hari ini telah direkodkan.";

        statusClass =

                "status-complete";

        statusIcon =

                "✓";

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

    <title>Kehadiran | LeaveHub</title>

    <link

        rel="stylesheet"

        href="<%= request.getContextPath() %>/css/style.css?v=20261008-attendance"

    >

    <style>

        * {

            box-sizing: border-box;

        }

        body {

            margin: 0;

            font-family:

                "Segoe UI",

                Arial,

                sans-serif;

            background:

                #f5f7fb;

            color:

                #1f2937;

        }

        .attendance-page {

            min-height: 100vh;

            padding:

                35px 25px 50px;

        }

        .attendance-container {

            width: 100%;

            max-width: 1050px;

            margin: 0 auto;

        }

        /* =========================================================

           TOP BAR

           ========================================================= */

        .top-bar {

            display: flex;

            justify-content: space-between;

            align-items: center;

            margin-bottom: 25px;

        }

        .page-title-area h1 {

            margin: 0;

            font-size: 28px;

            font-weight: 700;

            color:

                #172033;

        }

        .page-title-area p {

            margin:

                6px 0 0;

            font-size: 14px;

            color:

                #6b7280;

        }

        .back-button {

            display: inline-flex;

            align-items: center;

            gap: 8px;

            padding:

                10px 16px;

            border:

                1px solid #d9dee8;

            border-radius: 9px;

            background:

                #ffffff;

            color:

                #374151;

            text-decoration: none;

            font-size: 14px;

            font-weight: 600;

            transition:

                0.2s ease;

        }

        .back-button:hover {

            background:

                #f8fafc;

            border-color:

                #c5ccd8;

        }

        /* =========================================================

           MAIN CARD

           ========================================================= */

        .attendance-card {

            background:

                #ffffff;

            border:

                1px solid #e5e7eb;

            border-radius:

                16px;

            box-shadow:

                0 5px 20px rgba(15, 23, 42, 0.06);

            overflow:

                hidden;

        }

        .attendance-card-header {

            padding:

                25px 30px;

            border-bottom:

                1px solid #edf0f4;

            display:

                flex;

            justify-content:

                space-between;

            align-items:

                center;

            gap:

                20px;

        }

        .header-left {

            display:

                flex;

            align-items:

                center;

            gap:

                15px;

        }

        .attendance-icon {

            width:

                52px;

            height:

                52px;

            border-radius:

                13px;

            display:

                flex;

            align-items:

                center;

            justify-content:

                center;

            background:

                #eef4ff;

            color:

                #2563eb;

            font-size:

                24px;

            font-weight:

                700;

        }

        .header-text h2 {

            margin:

                0;

            font-size:

                20px;

            color:

                #172033;

        }

        .header-text p {

            margin:

                4px 0 0;

            font-size:

                13px;

            color:

                #6b7280;

        }

        /* =========================================================

           STATUS BADGE

           ========================================================= */

        .status-badge {

            display:

                inline-flex;

            align-items:

                center;

            gap:

                8px;

            padding:

                9px 13px;

            border-radius:

                999px;

            font-size:

                13px;

            font-weight:

                700;

            white-space:

                nowrap;

        }

        .status-pending {

            background:

                #fff7ed;

            color:

                #c2410c;

        }

        .status-present {

            background:

                #ecfdf5;

            color:

                #047857;

        }

        .status-complete {

            background:

                #eff6ff;

            color:

                #1d4ed8;

        }

        /* =========================================================

           BODY

           ========================================================= */

        .attendance-body {

            padding:

                30px;

        }

        .welcome-text {

            margin-bottom:

                25px;

            font-size:

                15px;

            color:

                #4b5563;

        }

        .welcome-text strong {

            color:

                #172033;

        }

        /* =========================================================

           STATUS PANEL

           ========================================================= */

        .status-panel {

            padding:

                22px;

            border:

                1px solid #e5e7eb;

            border-radius:

                13px;

            background:

                #fafbfc;

            margin-bottom:

                25px;

        }

        .status-panel-top {

            display:

                flex;

            align-items:

                center;

            gap:

                15px;

        }

        .status-circle {

            width:

                45px;

            height:

                45px;

            min-width:

                45px;

            border-radius:

                50%;

            display:

                flex;

            align-items:

                center;

            justify-content:

                center;

            font-size:

                19px;

            font-weight:

                700;

        }

        .status-pending .status-circle {

            background:

                #ffedd5;

            color:

                #c2410c;

        }

        .status-present .status-circle {

            background:

                #d1fae5;

            color:

                #047857;

        }

        .status-complete .status-circle {

            background:

                #dbeafe;

            color:

                #1d4ed8;

        }

        .status-content {

            flex:

                1;

        }

        .status-content h3 {

            margin:

                0;

            font-size:

                17px;

            color:

                #172033;

        }

        .status-content p {

            margin:

                5px 0 0;

            font-size:

                13px;

            line-height:

                1.5;

            color:

                #6b7280;

        }

        /* =========================================================

           TIME INFORMATION

           ========================================================= */

        .time-grid {

            display:

                grid;

            grid-template-columns:

                repeat(2, minmax(0, 1fr));

            gap:

                18px;

            margin-bottom:

                25px;

        }

        .time-box {

            border:

                1px solid #e5e7eb;

            border-radius:

                12px;

            padding:

                20px;

            background:

                #ffffff;

        }

        .time-label {

            font-size:

                12px;

            font-weight:

                700;

            text-transform:

                uppercase;

            letter-spacing:

                0.4px;

            color:

                #6b7280;

            margin-bottom:

                8px;

        }

        .time-value {

            font-size:

                22px;

            font-weight:

                700;

            color:

                #172033;

        }

        .time-distance {

            margin-top:

                5px;

            font-size:

                12px;

            color:

                #6b7280;

        }

        /* =========================================================

           LOCATION NOTICE

           ========================================================= */

        .location-notice {

            display:

                flex;

            align-items:

                flex-start;

            gap:

                12px;

            padding:

                16px 18px;

            border-radius:

                11px;

            background:

                #f0f7ff;

            border:

                1px solid #dbeafe;

            margin-bottom:

                25px;

        }

        .location-symbol {

            font-size:

                20px;

            line-height:

                1;

        }

        .location-content strong {

            display:

                block;

            margin-bottom:

                4px;

            font-size:

                14px;

            color:

                #1e3a8a;

        }

        .location-content span {

            font-size:

                12px;

            line-height:

                1.5;

            color:

                #475569;

        }

        /* =========================================================

           ACTIONS

           ========================================================= */

        .attendance-actions {

            display:

                flex;

            gap:

                12px;

            flex-wrap:

                wrap;

        }

        .attendance-form {

            margin:

                0;

        }

        .attendance-button {

            min-width:

                145px;

            min-height:

                46px;

            padding:

                11px 20px;

            border:

                none;

            border-radius:

                9px;

            font-family:

                inherit;

            font-size:

                14px;

            font-weight:

                700;

            cursor:

                pointer;

            transition:

                all 0.2s ease;

        }

        .check-in-button {

            background:

                #2563eb;

            color:

                #ffffff;

        }

        .check-in-button:hover {

            background:

                #1d4ed8;

        }

        .check-out-button {

            background:

                #dc2626;

            color:

                #ffffff;

        }

        .check-out-button:hover {

            background:

                #b91c1c;

        }

        .attendance-button:disabled {

            opacity:

                0.65;

            cursor:

                not-allowed;

        }

        .disabled-button {

            background:

                #e5e7eb;

            color:

                #9ca3af;

            cursor:

                not-allowed;

        }

        /* =========================================================

           INFORMATION

           ========================================================= */

        .info-section {

            margin-top:

                30px;

            padding-top:

                25px;

            border-top:

                1px solid #edf0f4;

        }

        .info-title {

            margin:

                0 0 14px;

            font-size:

                15px;

            font-weight:

                700;

            color:

                #172033;

        }

        .info-list {

            margin:

                0;

            padding-left:

                20px;

            color:

                #6b7280;

            font-size:

                13px;

            line-height:

                1.8;

        }

        /* =========================================================

           LOCATION MESSAGE

           ========================================================= */

        #locationMessage {

            display:

                none;

            margin-top:

                15px;

            padding:

                12px 15px;

            border-radius:

                9px;

            font-size:

                13px;

            line-height:

                1.5;

        }

        #locationMessage.error {

            display:

                block;

            background:

                #fef2f2;

            border:

                1px solid #fecaca;

            color:

                #b91c1c;

        }

        #locationMessage.loading {

            display:

                block;

            background:

                #eff6ff;

            border:

                1px solid #dbeafe;

            color:

                #1d4ed8;

        }

        /* =========================================================

           RESPONSIVE

           ========================================================= */

        .late-reason-field {
            width: 100%;
            margin-bottom: 15px;
        }

        .late-reason-field label {
            display: block;
            margin-bottom: 7px;
            color: #344054;
            font-size: 13px;
            font-weight: 600;
        }

        .late-reason-field label span,
        .late-reason-field small {
            color: #8a96a8;
            font-weight: 400;
        }

        .late-reason-field textarea {
            display: block;
            width: 100%;
            min-height: 78px;
            padding: 12px;
            border: 1px solid #dfe4ec;
            border-radius: 8px;
            background: #fff;
            color: #344054;
            font: inherit;
            font-size: 13px;
            resize: vertical;
        }

        .late-reason-field small {
            display: block;
            margin-top: 5px;
            font-size: 11px;
        }

        @media (max-width: 700px) {

            .attendance-page {

                padding:

                    20px 15px 35px;

            }

            .top-bar {

                align-items:

                    flex-start;

                flex-direction:

                    column;

                gap:

                    15px;

            }

            .attendance-card-header {

                align-items:

                    flex-start;

                flex-direction:

                    column;

            }

            .time-grid {

                grid-template-columns:

                    1fr;

            }

            .attendance-body {

                padding:

                    20px;

            }

            .attendance-card-header {

                padding:

                    20px;

            }

            .attendance-button {

                width:

                    100%;

            }

            .attendance-form {

                width:

                    100%;

            }

        }

        /* =========================================================

           PKB SHARED PAGE LAYOUT

           Match the same layout used by Permohonan Cuti.

           ========================================================= */

        html,

        body {

            max-width: 100%;

            overflow-x: hidden;

        }

        body {

            background: #f5f7fa;

            color: #172033;

        }

        .attendance-main {

            display: block !important;

            width: auto !important;

            max-width: none !important;

            margin-left: var(--sidebar-width) !important;

            padding: 32px 40px 55px !important;

            box-sizing: border-box !important;

        }

        .attendance-main .attendance-page {

            min-height: auto;

            width: 100%;

            padding: 0;

        }

        .attendance-main .attendance-container {

            width: 100%;

            max-width: none;

            margin: 0;

        }

        .attendance-main .top-bar {

            display: flex;

            align-items: flex-start;

            justify-content: space-between;

            gap: 20px;

            width: 100%;

            margin: 0 0 24px;

        }

        .attendance-main .page-title-area h1 {

            margin: 0;

            color: #172033;

            font-size: 28px;

            line-height: 1.2;

            font-weight: 700;

        }

        .attendance-main .page-title-area p {

            margin: 7px 0 0;

            color: #8b96a8;

            font-size: 13px;

            line-height: 1.5;

            font-weight: 400;

        }

        /* Do not show the old Dashboard back button.

           The shared PKB header-actions.jspf provides the

           notification icon and logged-in user chip. */

        .attendance-main .back-button {

            display: none !important;

        }

        .attendance-main .attendance-card {

            width: 100%;

            max-width: none;

            margin: 0;

            border: 1px solid #e6eaf0;

            border-radius: 18px;

            background: #ffffff;

            box-shadow: 0 10px 30px rgba(31, 42, 68, 0.07);

        }

        .attendance-main .attendance-card-header {

            padding: 24px 28px;

            border-bottom: 1px solid #edf0f4;

        }

        .attendance-main .attendance-icon {

            background: #fff4f5;

            border: 1px solid #f0d7da;

            color: #981525;

        }

        .attendance-main .header-text h2 {

            color: #172033;

            font-size: 18px;

            font-weight: 600;

        }

        .attendance-main .header-text p {

            color: #8b96a8;

            font-size: 13px;

        }

        .attendance-main .status-pending {

            background: #fff8e8;

            color: #9a6b00;

        }

        .attendance-main .status-present {

            background: #f2f8f3;

            color: #39734a;

        }

        .attendance-main .status-complete {

            background: #f8f0f2;

            color: #981525;

        }

        .attendance-main .status-panel {

            background: #fbfcfd;

            border-color: #e6eaf0;

        }

        .attendance-main .time-box {

            border-color: #e6eaf0;

        }

        .attendance-main .location-notice {

            background: #faf6f0;

            border-color: #eadfc9;

        }

        .attendance-main .location-content strong {

            color: #7a5a13;

        }

        .attendance-main .location-content span {

            color: #697386;

        }

        .attendance-main .check-in-button {

            background: #981525;

            color: #ffffff;

        }

        .attendance-main .check-in-button:hover {

            background: #7d101f;

        }

        .attendance-main .check-out-button {

            background: #d5a32b;

            color: #3b2b00;

        }

        .attendance-main .check-out-button:hover {

            background: #bd8e1d;

        }

        .attendance-main .disabled-button {

            background: #eef0f3;

            color: #9aa3b2;

        }

        @media (max-width: 900px) {

            .attendance-main {

                padding: 26px 24px 45px !important;

            }

        }

        @media (max-width: 650px) {

            .attendance-main {

                margin-left: 0 !important;

                padding: 22px 16px 35px !important;

            }

            .attendance-main .top-bar {

                align-items: flex-start;

                flex-direction: column;

                gap: 14px;

            }

            .attendance-main .page-title-area h1 {

                font-size: 24px;

            }

        }

        /* TYPOGRAPHY: samakan dengan saiz teks page Permohonan Cuti */
        .attendance-main .page-title-area h1 {
            font-size: 28px !important;
        }

        .attendance-main .page-title-area p {
            font-size: 13px !important;
        }

        .attendance-main .header-text h2 {
            font-size: 16px !important;
            line-height: 1.4 !important;
            font-weight: 600 !important;
        }

        .attendance-main .header-text p {
            font-size: 12px !important;
            line-height: 1.5 !important;
        }

        .attendance-main .status-badge {
            font-size: 12px !important;
        }

        .attendance-main .welcome-text {
            font-size: 13px !important;
            line-height: 1.6 !important;
        }

        .attendance-main .status-content h3 {
            font-size: 15px !important;
            line-height: 1.4 !important;
            font-weight: 600 !important;
        }

        .attendance-main .status-content p {
            font-size: 12px !important;
            line-height: 1.5 !important;
        }

        .attendance-main .time-label {
            font-size: 11px !important;
        }

        .attendance-main .time-value {
            font-size: 18px !important;
            line-height: 1.4 !important;
            overflow-wrap: anywhere;
        }

        .attendance-main .time-distance {
            font-size: 11px !important;
            line-height: 1.5 !important;
        }

        .attendance-main .location-content strong {
            font-size: 12px !important;
            line-height: 1.5 !important;
        }

        .attendance-main .location-content span {
            font-size: 11px !important;
            line-height: 1.5 !important;
        }

        .attendance-main .attendance-button {
            font-size: 13px !important;
        }

        .attendance-main .info-title {
            font-size: 14px !important;
        }

        .attendance-main .info-list {
            font-size: 12px !important;
        }

        .attendance-main .late-reason-field label,
        .attendance-main .late-reason-field textarea {
            font-size: 12px !important;
        }

        .attendance-main .late-reason-field small {
            font-size: 11px !important;
        }

    </style>

</head>

<body>

<div class="app-layout">

    <%@ include file="includes/sidebar.jspf" %>

    <main class="main-content attendance-main">

        <div class="attendance-page">

            <div class="attendance-container">

                <!-- =====================================================

                     PAGE HEADER

                     ===================================================== -->

                <div class="top-bar">

                    <div class="page-title-area">

                        <h1>

                            Kehadiran

                        </h1>

                        <p>

                            Rekod kehadiran harian staf

                        </p>

                    </div>

                    <div class="pkb-attendance-header-actions">

                        <%@ include file="includes/header-actions.jspf" %>

                    </div>

                </div>

        <!-- =====================================================

             ATTENDANCE CARD

             ===================================================== -->

        <div class="attendance-card">

            <!-- HEADER -->

            <div class="attendance-card-header">

                <div class="header-left">

                    <div class="attendance-icon">

                        ✓

                    </div>

                    <div class="header-text">

                        <h2>

                            Kehadiran Hari Ini

                        </h2>

                        <p>

                            Sistem merekodkan masa dan lokasi kehadiran anda

                        </p>

                    </div>

                </div>

                <div

                    class="status-badge <%= statusClass %>"

                >

                    <span>

                        <%= statusIcon %>

                    </span>

                    <span>

                        <%= esc(statusTitle) %>

                    </span>

                </div>

            </div>

            <!-- BODY -->

            <div class="attendance-body">

                <div class="welcome-text">

                    Selamat datang,

                    <strong>

                        <%= esc(userName) %>

                    </strong>.

                    Sila pastikan lokasi peranti dibenarkan sebelum melakukan

                    Check In atau Check Out.

                </div>

                <!-- =================================================

                     STATUS PANEL

                     ================================================= -->

                <div class="status-panel">

                    <div class="status-panel-top">

                        <div

                            class="status-circle"

                        >

                            <%= statusIcon %>

                        </div>

                        <div class="status-content">

                            <h3>

                                <%= esc(statusTitle) %>

                            </h3>

                            <p>

                                <%= esc(statusDescription) %>

                            </p>

                        </div>

                    </div>

                </div>

                <!-- =================================================

                     TIME INFORMATION

                     ================================================= -->

                <div class="time-grid">

                    <div class="time-box">

                        <div class="time-label">

                            Masa Masuk

                        </div>

                        <div class="time-value">

                            <%= esc(checkIn) %>

                        </div>

                        <%

                            if (!"-".equals(checkInDistance)) {

                        %>

                            <div class="time-distance">

                                Jarak dari pejabat:

                                <strong>

                                    <%= esc(checkInDistance) %> m

                                </strong>

                            </div>

                        <%

                            } else {

                        %>

                            <div class="time-distance">

                                Belum direkodkan

                            </div>

                        <%

                            }

                        %>

                    </div>

                    <div class="time-box">

                        <div class="time-label">

                            Masa Keluar

                        </div>

                        <div class="time-value">

                            <%= esc(checkOut) %>

                        </div>

                        <%

                            if (!"-".equals(checkOutDistance)) {

                        %>

                            <div class="time-distance">

                                Jarak dari pejabat:

                                <strong>

                                    <%= esc(checkOutDistance) %> m

                                </strong>

                            </div>

                        <%

                            } else {

                        %>

                            <div class="time-distance">

                                Belum direkodkan

                            </div>

                        <%

                            }

                        %>

                    </div>

                </div>

                <% if (!lateReason.isBlank()) { %>
                    <div class="location-notice" style="margin-top:-5px;">
                        <div class="location-symbol">📝</div>
                        <div class="location-content">
                            <strong>Penjelasan Sebab Lewat</strong>
                            <span><%= esc(lateReason) %></span>
                        </div>
                    </div>
                <% } %>

                <!-- =================================================

                     LOCATION NOTICE

                     ================================================= -->

                <div class="location-notice">

                    <div class="location-symbol">

                        📍

                    </div>

                    <div class="location-content">

                        <strong>

                            Pengesahan Lokasi Diperlukan

                        </strong>

                        <span>

                            Sistem akan menggunakan lokasi semasa peranti

                            untuk memastikan anda berada dalam kawasan pejabat

                            sebelum kehadiran direkodkan.

                        </span>

                    </div>

                </div>

                <!-- =================================================

                     ACTIONS

                     ================================================= -->

                <div class="attendance-actions">

                    <%

                        if ("BELUM_HADIR".equalsIgnoreCase(attendanceStatus)
                                && !hasApprovedLeave) {

                    %>

                        <form

                            id="checkInForm"

                            class="attendance-form"

                            method="post"

                            action="<%= contextPath %>/attendance"

                        >

                            <input

                                type="hidden"

                                name="action"

                                value="check_in"

                            >

                            <input

                                type="hidden"

                                name="latitude"

                                id="checkInLatitude"

                            >

                            <input

                                type="hidden"

                                name="longitude"

                                id="checkInLongitude"

                            >

                            <div class="late-reason-field">
                                <label for="lateReason">
                                    Penjelasan Sebab Lewat <span>(Pilihan)</span>
                                </label>
                                <textarea
                                    id="lateReason"
                                    name="lateReason"
                                    rows="3"
                                    maxlength="1000"
                                    placeholder="Nyatakan sebab lewat jika berkaitan..."
                                ></textarea>
                                <small>Ruangan ini tidak wajib diisi.</small>
                            </div>

                            <button

                                type="button"

                                id="checkInButton"

                                class="attendance-button check-in-button"

                                onclick="getLocationAndSubmit('checkIn')"

                            >

                                Check In

                            </button>

                        </form>

                    <%

                        } else {

                    %>

                        <button

                            type="button"

                            class="attendance-button disabled-button"

                            disabled

                        >

                            <%= hasApprovedLeave ? "Cuti Diluluskan" : "Check In Selesai" %>

                        </button>

                    <%

                        }

                    %>

                    <%

                        if ("HADIR".equalsIgnoreCase(attendanceStatus)) {

                    %>

                        <form

                            id="checkOutForm"

                            class="attendance-form"

                            method="post"

                            action="<%= contextPath %>/attendance"

                        >

                            <input

                                type="hidden"

                                name="action"

                                value="check_out"

                            >

                            <input

                                type="hidden"

                                name="latitude"

                                id="checkOutLatitude"

                            >

                            <input

                                type="hidden"

                                name="longitude"

                                id="checkOutLongitude"

                            >

                            <input type="hidden" name="earlyCheckoutReason" id="earlyCheckoutReason">

                            <button

                                type="button"

                                id="checkOutButton"

                                class="attendance-button check-out-button"

                                onclick="confirmCheckOutFlow()"

                            >

                                Check Out

                            </button>

                        </form>

                    <%

                        } else if ("SELESAI".equalsIgnoreCase(attendanceStatus)) {

                    %>

                        <button

                            type="button"

                            class="attendance-button disabled-button"

                            disabled

                        >

                            Kehadiran Lengkap

                        </button>

                    <%

                        }

                    %>

                </div>

                <!-- =================================================

                     LOCATION MESSAGE

                     ================================================= -->

                <div

                    id="locationMessage"

                ></div>

                <!-- =================================================

                     INFORMATION

                     ================================================= -->

                <div class="info-section">

                    <h3 class="info-title">

                        Maklumat Kehadiran

                    </h3>

                    <ul class="info-list">

                        <li>

                            Pastikan fungsi lokasi pada peranti anda

                            diaktifkan.

                        </li>

                        <li>

                            Pelayar akan meminta kebenaran untuk mengakses

                            lokasi semasa.

                        </li>

                        <li>

                            Check In hanya boleh dilakukan apabila anda

                            berada dalam kawasan pejabat yang ditetapkan.

                        </li>

                        <li>

                            Check Out hanya boleh dilakukan selepas

                            Check In direkodkan.

                        </li>

                        <li>

                            Setiap staf hanya mempunyai satu rekod

                            kehadiran bagi setiap hari.

                        </li>

                    </ul>

                </div>

            </div>

        </div>

    </main>

</div>

<script>

    /*

     * ============================================================

     * GPS / LOCATION

     * ============================================================

     */

    function confirmCheckOutFlow() {
        var now = new Date();
        var day = now.getDay(); // 0 Ahad, 4 Khamis
        var endHour = (day === 4) ? 16 : 16;
        var endMinute = (day === 4) ? 30 : 45;
        var isWorkday = day >= 0 && day <= 4;
        var early = isWorkday && (now.getHours() < endHour ||
            (now.getHours() === endHour && now.getMinutes() < endMinute));
        var reasonField = document.getElementById("earlyCheckoutReason");
        if (early) {
            if (!confirm("Anda akan Check Out sebelum waktu tamat bekerja (" +
                    (day === 4 ? "4:30 petang" : "4:45 petang") + "). Adakah anda pasti mahu meneruskan?")) {
                return;
            }
            var reason = prompt("Sila masukkan sebab Check Out awal. Sebab ini wajib diisi:");
            if (reason === null) return;
            reason = reason.trim();
            if (!reason) {
                alert("Sebab Check Out awal wajib diisi.");
                return;
            }
            if (!confirm("Pengesahan kedua: Check Out awal dengan sebab berikut?\n\n" + reason + "\n\nTekan OK untuk meneruskan.")) {
                return;
            }
            reasonField.value = reason.substring(0, 1000);
        } else if (reasonField) {
            reasonField.value = "";
        }
        getLocationAndSubmit("checkOut");
    }

    function getLocationAndSubmit(type) {

        var button = null;

        var form = null;

        if (type === "checkIn") {

            button =

                document.getElementById(

                    "checkInButton"

                );

            form =

                document.getElementById(

                    "checkInForm"

                );

        } else if (type === "checkOut") {

            button =

                document.getElementById(

                    "checkOutButton"

                );

            form =

                document.getElementById(

                    "checkOutForm"

                );

        }

        if (!button || !form) {

            return;

        }

        var message =

            document.getElementById(

                "locationMessage"

            );

        /*

         * Browser tidak support GPS

         */

        if (!navigator.geolocation) {

            showLocationMessage(

                "error",

                "Pelayar anda tidak menyokong fungsi lokasi. Sila gunakan pelayar moden seperti Google Chrome atau Microsoft Edge."

            );

            return;

        }

        /*

         * Disable button

         */

        button.disabled = true;

        button.innerText =

            "Mengesan lokasi...";

        showLocationMessage(

            "loading",

            "Sedang mendapatkan lokasi semasa anda. Sila tunggu..."

        );

        /*

         * Get current position

         */

        navigator.geolocation.getCurrentPosition(

            function(position) {

                var latitude =

                    position.coords.latitude;

                var longitude =

                    position.coords.longitude;

                /*

                 * Pastikan koordinat valid

                 */

                if (

                    !isFinite(latitude) ||

                    !isFinite(longitude)

                ) {

                    showLocationMessage(

                        "error",

                        "Lokasi yang diterima tidak sah. Sila cuba sekali lagi."

                    );

                    button.disabled = false;

                    button.innerText =

                        type === "checkIn"

                            ? "Check In"

                            : "Check Out";

                    return;

                }

                /*

                 * Set hidden fields

                 */

                if (type === "checkIn") {

                    document.getElementById(

                        "checkInLatitude"

                    ).value =

                        latitude;

                    document.getElementById(

                        "checkInLongitude"

                    ).value =

                        longitude;

                } else {

                    document.getElementById(

                        "checkOutLatitude"

                    ).value =

                        latitude;

                    document.getElementById(

                        "checkOutLongitude"

                    ).value =

                        longitude;

                }

                /*

                 * Submit form

                 */

                showLocationMessage(

                    "loading",

                    "Lokasi berjaya dikesan. Kehadiran sedang direkodkan..."

                );

                form.submit();

            },

            function(error) {

                var errorMessage =

                    "Tidak dapat mendapatkan lokasi anda.";

                switch (error.code) {

                    case error.PERMISSION_DENIED:

                        errorMessage =

                            "Kebenaran lokasi telah ditolak. Sila benarkan Location untuk laman localhost ini melalui tetapan pelayar dan cuba sekali lagi.";

                        break;

                    case error.POSITION_UNAVAILABLE:

                        errorMessage =

                            "Lokasi semasa tidak dapat dikesan. Pastikan GPS atau Location pada peranti anda diaktifkan.";

                        break;

                    case error.TIMEOUT:

                        errorMessage =

                            "Masa untuk mendapatkan lokasi telah tamat. Sila cuba sekali lagi.";

                        break;

                    default:

                        errorMessage =

                            "Berlaku masalah ketika mendapatkan lokasi. Sila cuba sekali lagi.";

                        break;

                }

                showLocationMessage(

                    "error",

                    errorMessage

                );

                button.disabled = false;

                button.innerText =

                    type === "checkIn"

                        ? "Check In"

                        : "Check Out";

            },

            {

                enableHighAccuracy: true,

                timeout: 15000,

                maximumAge: 0

            }

        );

    }

    /*

     * ============================================================

     * LOCATION MESSAGE

     * ============================================================

     */

    function showLocationMessage(

        type,

        message

    ) {

        var element =

            document.getElementById(

                "locationMessage"

            );

        if (!element) {

            return;

        }

        element.className =

            type;

        element.innerText =

            message;

    }

</script>

</body>

</html>
