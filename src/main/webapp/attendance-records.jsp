<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    private String formatDisplayDate(Object value) {
        if (value == null) return "—";

        String raw = String.valueOf(value).trim();

        if (raw.matches("\\d{4}-\\d{2}-\\d{2}")) {
            String[] parts = raw.split("-");
            return parts[2] + "-" + parts[1] + "-" + parts[0];
        }

        return raw;
    }

    /* Paparkan nama jabatan dengan kemas tanpa mengubah nilai dalam database.
       Contoh: PENTADBIRAN_KORPORAT -> Pentadbiran Korporat */
    private String formatDepartment(Object value) {
        if (value == null) return "—";
        String raw = String.valueOf(value).trim().replace('_', ' ');
        if (raw.isEmpty()) return "—";

        String[] words = raw.toLowerCase(java.util.Locale.ROOT).split("\\s+");
        StringBuilder result = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) continue;
            if (result.length() > 0) result.append(' ');
            result.append(Character.toUpperCase(word.charAt(0)));
            if (word.length() > 1) result.append(word.substring(1));
        }
        return result.length() == 0 ? "—" : result.toString();
    }

    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private java.time.LocalDateTime asDateTime(Object value) {
        if (value == null) return null;
        if (value instanceof java.sql.Timestamp) return ((java.sql.Timestamp) value).toLocalDateTime();
        try { return java.sql.Timestamp.valueOf(String.valueOf(value)).toLocalDateTime(); }
        catch (Exception e) { return null; }
    }

    private java.time.LocalTime scheduledEnd(java.time.LocalDate date) {
        java.time.DayOfWeek day = date.getDayOfWeek();
        if (day == java.time.DayOfWeek.SUNDAY || day == java.time.DayOfWeek.MONDAY
                || day == java.time.DayOfWeek.TUESDAY || day == java.time.DayOfWeek.WEDNESDAY)
            return java.time.LocalTime.of(16, 45);
        if (day == java.time.DayOfWeek.THURSDAY) return java.time.LocalTime.of(16, 30);
        return null;
    }

    private String getAttendanceLabel(Object checkInValue, Object checkOutValue,
            Object lateReasonValue, Object earlyReasonValue, boolean hasLeave,
            java.time.LocalDate date) {
        java.time.LocalDateTime in = asDateTime(checkInValue);
        java.time.LocalDateTime out = asDateTime(checkOutValue);
        if (in == null) {
            if (hasLeave) return "Cuti Diluluskan";
            if (date.getDayOfWeek() == java.time.DayOfWeek.FRIDAY || date.getDayOfWeek() == java.time.DayOfWeek.SATURDAY)
                return "Hari Tidak Bekerja";
            return date.isBefore(java.time.LocalDate.now()) ? "Tidak Hadir" : "Belum Hadir";
        }
        java.time.LocalTime end = scheduledEnd(date);
        if (out != null && end != null && out.toLocalTime().isBefore(end)) return "Check Out Awal";
        boolean late = in.toLocalTime().isAfter(java.time.LocalTime.of(8, 0));
        if (late && lateReasonValue != null && !String.valueOf(lateReasonValue).isBlank()) return "Lewat Bersebab";
        if (late) return "Lewat";
        return out == null ? "Tepat Masa" : "Lengkap - Tepat Masa";
    }

    private String toDateTimeLocal(Object value) {
        java.time.LocalDateTime dt = asDateTime(value);
        return dt == null ? "" : dt.toString().substring(0, 16);
    }

    private String formatTableDateTime(Object value) {
        java.time.LocalDateTime dt = asDateTime(value);
        return dt == null ? "—"
                : dt.format(java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"));
    }
%>

<%
    String contextPath = request.getContextPath();
    String pageSuccess = session.getAttribute("attendanceRecordsSuccess") == null ? "" : String.valueOf(session.getAttribute("attendanceRecordsSuccess"));
    String pageError = session.getAttribute("attendanceRecordsError") == null ? "" : String.valueOf(session.getAttribute("attendanceRecordsError"));
    session.removeAttribute("attendanceRecordsSuccess");
    session.removeAttribute("attendanceRecordsError");

    String userName =
            session.getAttribute("userName") == null
                    ? "Pengguna"
                    : session.getAttribute("userName").toString();

    LocalDate selectedDate =
            (LocalDate) request.getAttribute("selectedDate");

    if (selectedDate == null) {
        selectedDate = LocalDate.now();
    }

    DateTimeFormatter displayFormatter =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");

    String selectedDateDisplay =
            selectedDate.format(displayFormatter);

    List<Map<String, Object>> records =
            (List<Map<String, Object>>) request.getAttribute("records");

    if (records == null) {
        records = new java.util.ArrayList<>();
    }

    Map<String, Integer> summary =
            (Map<String, Integer>) request.getAttribute("summary");

    int total =
            summary != null && summary.get("total") != null
                    ? summary.get("total")
                    : 0;

    int hadir =
            summary != null && summary.get("hadir") != null
                    ? summary.get("hadir")
                    : 0;

    int selesai =
            summary != null && summary.get("selesai") != null
                    ? summary.get("selesai")
                    : 0;

    int belumHadir =
            summary != null && summary.get("belumHadir") != null
                    ? summary.get("belumHadir")
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

    <title>Rekod Kehadiran | LeaveHub</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20261011-attendance-layout-fix2"
    >

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f5f7fb;
            color: #172033;
            font-family:
                "Segoe UI",
                Arial,
                sans-serif;
        }

        .attendance-records-page {
            min-height: 100vh;
            width: 100%;
            /* .main-content already supplies the page spacing.
               Avoid double padding so this page aligns with Inventori. */
            padding: 0 0 35px;
        }

        .attendance-records-container {
            width: 100%;
            max-width: none;
            margin: 0;
            min-width: 0;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 25px;
        }

        .page-title h1 {
            margin: 0;
            color: #172033;
            font-size: 28px;
            font-weight: 700;
        }

        .page-title p {
            margin: 6px 0 0;
            color: #7b8799;
            font-size: 14px;
        }

        .page-header {
            position: relative;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 25px;
            margin-bottom: 25px;
            padding-top: 0;
        }

        .pkb-attendance-header-actions {
            position: absolute;
            top: -2px;
            right: 0;
            z-index: 20;
        }

        .page-title {
            padding-top: 0;
        }

        .date-filter {
            margin-top: 58px;
        }

        .date-filter {
            display: flex;
            align-items: end;
            gap: 10px;
            padding: 10px;
            border: 1px solid #e3e7ee;
            border-radius: 12px;
            background: #ffffff;
        }

        .date-field {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .date-field label {
            color: #7b8799;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .date-field input {
            height: 38px;
            padding: 0 11px;
            border: 1px solid #dfe4ec;
            border-radius: 8px;
            background: #ffffff;
            color: #172033;
            font-size: 12px;
            outline: none;
        }

        .date-field input:focus {
            border-color: #8d1f2d;
        }

        .filter-button {
            height: 38px;
            padding: 0 15px;
            border: 0;
            border-radius: 8px;
            background: #8d1f2d;
            color: #ffffff;
            font-size: 12px;
            font-weight: 650;
            cursor: pointer;
        }

        .filter-button:hover {
            background: #741723;
        }

        .summary-grid {
            display: grid;
            grid-template-columns:
                repeat(4, minmax(0, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .summary-card {
            display: flex;
            align-items: center;
            gap: 13px;
            min-height: 92px;
            padding: 18px;
            border: 1px solid #e4e8ef;
            border-radius: 13px;
            background: #ffffff;
            box-shadow:
                0 4px 14px rgba(23, 32, 51, .03);
        }

        .summary-icon {
            width: 42px;
            height: 42px;
            min-width: 42px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 11px;
            background: #fff1f3;
            color: #8d1f2d;
            font-size: 19px;
            font-weight: 700;
        }

        .summary-card:nth-child(2) .summary-icon {
            background: #eef6ff;
            color: #2563eb;
        }

        .summary-card:nth-child(3) .summary-icon {
            background: #ecfaf4;
            color: #16805b;
        }

        .summary-card:nth-child(4) .summary-icon {
            background: #fff8e8;
            color: #a36a00;
        }

        .summary-value {
            margin: 0;
            color: #172033;
            font-size: 22px;
            font-weight: 700;
        }

        .summary-label {
            margin-top: 3px;
            color: #718096;
            font-size: 11px;
        }

        .record-card {
            overflow: hidden;
            border: 1px solid #e3e7ee;
            border-radius: 15px;
            background: #ffffff;
            box-shadow:
                0 5px 18px rgba(23, 32, 51, .035);
        }

        .record-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding: 21px 23px;
            border-bottom: 1px solid #edf0f4;
        }

        .record-card-header h2 {
            margin: 0;
            color: #172033;
            font-size: 17px;
            font-weight: 700;
        }

        .record-card-header p {
            margin: 5px 0 0;
            color: #8a96a8;
            font-size: 12px;
        }

        .selected-date-badge {
            padding: 8px 12px;
            border-radius: 999px;
            background: #fff1f3;
            color: #8d1f2d;
            font-size: 11px;
            font-weight: 700;
        }

        .table-wrapper {
            width: 100%;
            max-width: 100%;
            overflow-x: hidden;
        }

        table {
            width: 100%;
            min-width: 0;
            table-layout: fixed;
            border-collapse: collapse;
        }

        /* Column widths are balanced so the table fits the page without horizontal scrolling. */
        thead th:nth-child(1) { width: 14%; }
        thead th:nth-child(2) { width: 9%; }
        thead th:nth-child(3) { width: 12%; }
        thead th:nth-child(4) { width: 12%; }
        thead th:nth-child(5) { width: 12%; }
        thead th:nth-child(6) { width: 8%; }
        thead th:nth-child(7) { width: 8%; }
        thead th:nth-child(8) { width: 15%; }
        thead th:nth-child(9) { width: 10%; }

        th {
            padding: 13px 9px;
            border-bottom: 1px solid #e8ebf0;
            background: #fafbfc;
            color: #7b8799;
            font-size: 10px;
            font-weight: 700;
            text-align: left;
            text-transform: uppercase;
            letter-spacing: .025em;
            white-space: normal;
            overflow-wrap: anywhere;
        }

        td {
            padding: 13px 9px;
            border-bottom: 1px solid #edf0f4;
            color: #536176;
            font-size: 11px;
            vertical-align: middle;
            overflow-wrap: anywhere;
            word-break: normal;
        }

        .table-time {
            display: block;
            color: #344054;
            font-size: 10.5px;
            font-weight: 600;
            line-height: 1.45;
            white-space: normal;
            overflow-wrap: anywhere;
            font-variant-numeric: tabular-nums;
        }

        tbody tr:last-child td {
            border-bottom: 0;
        }

        tbody tr:hover {
            background: #fcfcfd;
        }

        .staff-name {
            color: #172033;
            font-size: 12px;
            font-weight: 650;
        }

        .staff-detail {
            margin-top: 3px;
            color: #8a96a8;
            font-size: 10px;
        }

        .time-value {
            color: #344054;
            font-weight: 600;
            white-space: nowrap;
        }

        .distance {
            color: #7b8799;
            white-space: nowrap;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 700;
            white-space: nowrap;
        }

        .status-hadir {
            background: #eef6ff;
            color: #2563eb;
        }

        .status-selesai {
            background: #ecfaf4;
            color: #16805b;
        }

        .status-late { background: #fff7df; color: #a36a00; }
        .status-early { background: #f3e8ff; color: #7e22ce; }

        .status-belum {
            background: #fff7df;
            color: #a36a00;
        }

        .view-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 31px;
            padding: 0 11px;
            border: 1px solid #ead5d8;
            border-radius: 7px;
            background: #fff8f9;
            color: #8d1f2d;
            font-size: 10.5px;
            font-weight: 650;
            text-decoration: none;
            white-space: nowrap;
        }

        .view-button:hover {
            background: #fff0f2;
        }

        .empty-state {
            padding: 45px 20px;
            color: #8a96a8;
            text-align: center;
            font-size: 12px;
        }

        .detail-card {
            margin-bottom: 20px;
        }

        .detail-grid {
            display: grid;
            grid-template-columns:
                repeat(2, minmax(0, 1fr));
            gap: 1px;
            background: #edf0f4;
        }

        .detail-item {
            min-height: 76px;
            padding: 16px 18px;
            background: #ffffff;
        }

        .detail-item span {
            display: block;
            margin-bottom: 5px;
            color: #8a96a8;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .035em;
        }

        .detail-item strong {
            display: block;
            color: #344054;
            font-size: 12px;
            font-weight: 650;
            line-height: 1.45;
            word-break: break-word;
        }


        /* =========================================================
           ATTENDANCE DETAIL MODAL
           ========================================================= */

        .attendance-flash { margin: 0 0 16px; padding: 12px 15px; border-radius: 9px; font-size: 12px; }
        .attendance-flash.success { background: #ecfaf4; color: #16805b; border: 1px solid #c7efdc; }
        .attendance-flash.error { background: #fff1f2; color: #b42332; border: 1px solid #f3c5cb; }
        .admin-edit-section { margin-top: 25px; padding: 18px; border: 1px solid #e5e9ef; border-radius: 12px; background: #fbfcfe; }
        .admin-edit-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 12px; }
        .admin-edit-field { display:flex; flex-direction:column; gap:6px; }
        .admin-edit-field label { color:#667085; font-size:11px; font-weight:700; }
        .admin-edit-field input, .admin-edit-field textarea { width:100%; border:1px solid #dfe4ec; border-radius:8px; padding:10px 11px; font:inherit; font-size:12px; background:#fff; color:#344054; }
        .admin-edit-field.full { grid-column:1 / -1; }
        .admin-edit-submit { margin-top:13px; padding:11px 16px; border:0; border-radius:8px; background:#8d1f2d; color:#fff; font-size:12px; font-weight:700; cursor:pointer; }
        .admin-edit-hint { margin:0 0 13px; color:#7b8799; font-size:11px; line-height:1.5; }
        @media(max-width:650px) { .admin-edit-grid { grid-template-columns:1fr; } }

        .attendance-modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 25px;
            background: rgba(23, 32, 51, .58);
            backdrop-filter: blur(5px);
        }

        .attendance-modal-overlay.show {
            display: flex;
        }

        .attendance-modal {
            width: 100%;
            max-width: 1050px;
            max-height: 88vh;
            overflow: hidden;
            border-radius: 16px;
            background: #ffffff;
            box-shadow: 0 25px 70px rgba(15, 23, 42, .24);
        }

        .attendance-modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            padding: 22px 26px;
            border-bottom: 1px solid #edf0f4;
        }

        .attendance-modal-title h2 {
            margin: 0;
            color: #172033;
            font-size: 19px;
            font-weight: 700;
        }

        .attendance-modal-title p {
            margin: 5px 0 0;
            color: #8a96a8;
            font-size: 12px;
        }

        .attendance-modal-close {
            width: 40px;
            height: 40px;
            border: 0;
            border-radius: 10px;
            background: #f5f7fa;
            color: #687386;
            font-size: 25px;
            line-height: 1;
            cursor: pointer;
        }

        .attendance-modal-close:hover {
            background: #edf0f4;
            color: #172033;
        }

        .attendance-modal-body {
            max-height: calc(88vh - 85px);
            overflow-y: auto;
            padding: 25px 26px 30px;
        }

        .modal-section-title {
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0 0 14px;
            color: #8d1f2d;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .045em;
        }

        .modal-section-title::before {
            content: "";
            width: 3px;
            height: 17px;
            border-radius: 3px;
            background: #d5a32b;
        }

        .modal-info-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 25px;
        }

        .modal-info-box {
            min-height: 78px;
            padding: 15px 16px;
            border: 1px solid #e5e9ef;
            border-radius: 11px;
            background: #fafbfc;
        }

        .modal-info-box.highlight {
            border-color: #ead5d8;
            background: #fffafb;
        }

        .modal-info-label {
            margin-bottom: 7px;
            color: #929dad;
            font-size: 9.5px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .035em;
        }

        .modal-info-value {
            color: #344054;
            font-size: 12px;
            font-weight: 600;
            line-height: 1.45;
            word-break: break-word;
        }

        .modal-status {
            display: inline-flex;
            align-items: center;
            padding: 5px 10px;
            border-radius: 999px;
            background: #ecfaf4;
            color: #16805b;
            font-size: 10px;
            font-weight: 700;
        }

        .modal-location-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
        }

        .modal-location-box {
            padding: 16px;
            border: 1px solid #e5e9ef;
            border-radius: 11px;
            background: #ffffff;
        }

        .modal-location-heading {
            margin-bottom: 12px;
            color: #172033;
            font-size: 12px;
            font-weight: 700;
        }

        .modal-location-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            padding: 8px 0;
            border-bottom: 1px solid #edf0f4;
            font-size: 11px;
        }

        .modal-location-row:last-child {
            border-bottom: 0;
        }

        .modal-location-row span:first-child {
            color: #8a96a8;
        }

        .modal-location-row span:last-child {
            color: #344054;
            font-weight: 600;
            text-align: right;
            word-break: break-word;
        }

        body.attendance-modal-open {
            overflow: hidden;
        }

        @media (max-width: 1200px) {
            .attendance-records-page {
                padding: 0 0 30px;
            }

            th {
                padding: 11px 7px;
                font-size: 9px;
            }

            td {
                padding: 12px 7px;
                font-size: 10.5px;
            }

            .staff-name {
                font-size: 11px;
            }

            .status-badge {
                white-space: normal;
                line-height: 1.35;
            }
        }

        @media (max-width: 1000px) {
            .attendance-records-page {
                padding: 0 0 30px;
            }

            .page-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .pkb-attendance-header-actions {
                position: static;
                align-self: flex-end;
                order: -1;
                margin-bottom: 8px;
            }

            .date-filter {
                width: 100%;
                margin-top: 0;
            }

            .date-field {
                flex: 1;
                min-width: 0;
            }

            .date-field input {
                width: 100%;
            }

            .summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            /* Hide secondary columns on narrower screens rather than adding a scrollbar. */
            thead th:nth-child(3),
            tbody td:nth-child(3),
            thead th:nth-child(6),
            tbody td:nth-child(6),
            thead th:nth-child(7),
            tbody td:nth-child(7) {
                display: none;
            }

            thead th:nth-child(1) { width: 20%; }
            thead th:nth-child(2) { width: 13%; }
            thead th:nth-child(4) { width: 16%; }
            thead th:nth-child(5) { width: 16%; }
            thead th:nth-child(8) { width: 20%; }
            thead th:nth-child(9) { width: 15%; }
        }

        @media (max-width: 600px) {
            .attendance-records-page {
                padding: 0 0 24px;
            }

            .summary-grid {
                grid-template-columns: 1fr;
            }

            .date-filter {
                align-items: stretch;
                flex-direction: column;
            }

            .filter-button {
                width: 100%;
            }

            thead th:nth-child(2),
            tbody td:nth-child(2) {
                display: none;
            }

            thead th:nth-child(1) { width: 27%; }
            thead th:nth-child(4) { width: 18%; }
            thead th:nth-child(5) { width: 18%; }
            thead th:nth-child(8) { width: 22%; }
            thead th:nth-child(9) { width: 15%; }

            th {
                padding: 9px 5px;
                font-size: 8px;
            }

            td {
                padding: 10px 5px;
                font-size: 9.5px;
            }

            .table-time {
                font-size: 9px;
            }

            .view-button {
                min-height: 28px;
                padding: 0 7px;
                font-size: 9px;
            }
        }

    </style>

</head>

<body>

<div class="app-layout">

    <%@ include file="includes/sidebar.jspf" %>

    <main class="main-content">

        <div class="attendance-records-page">

            <div class="attendance-records-container">

                <div class="page-header">

                    <div class="page-title">

                        <h1>
                            Rekod Kehadiran
                        </h1>

                        <p>
                            Semakan rekod kehadiran staf mengikut tarikh
                        </p>

                    </div>

                    <div class="pkb-attendance-header-actions">
                        <%@ include file="includes/header-actions.jspf" %>
                    </div>

                    <form
                        class="date-filter"
                        method="get"
                        action="<%= contextPath %>/attendance-records"
                    >

                        <div class="date-field">

                            <label for="date">
                                Tarikh
                            </label>

                            <input
                                type="date"
                                id="date"
                                name="date"
                                value="<%= selectedDate %>"
                            >

                        </div>

                        <button
                            type="submit"
                            class="filter-button"
                        >
                            Papar Rekod
                        </button>

                    </form>

                </div>

                <div class="summary-grid">

                    <div class="summary-card">

                        <div class="summary-icon">
                            👥
                        </div>

                        <div>
                            <p class="summary-value">
                                <%= total %>
                            </p>

                            <div class="summary-label">
                                Jumlah Staf
                            </div>
                        </div>

                    </div>

                    <div class="summary-card">

                        <div class="summary-icon">
                            ✓
                        </div>

                        <div>
                            <p class="summary-value">
                                <%= hadir %>
                            </p>

                            <div class="summary-label">
                                Sudah Check In
                            </div>
                        </div>

                    </div>

                    <div class="summary-card">

                        <div class="summary-icon">
                            ✓
                        </div>

                        <div>
                            <p class="summary-value">
                                <%= selesai %>
                            </p>

                            <div class="summary-label">
                                Lengkap
                            </div>
                        </div>

                    </div>

                    <div class="summary-card">

                        <div class="summary-icon">
                            ○
                        </div>

                        <div>
                            <p class="summary-value">
                                <%= belumHadir %>
                            </p>

                            <div class="summary-label">
                                Belum Hadir
                            </div>
                        </div>

                    </div>

                </div>

                <section class="record-card">

                    <div class="record-card-header">

                        <div>

                            <h2>
                                Kehadiran Staf
                            </h2>

                            <p>
                                Rekod untuk tarikh yang dipilih
                            </p>

                        </div>

                        <div class="selected-date-badge">
                            <%= formatDisplayDate(selectedDate) %>
                        </div>

                    </div>

                    <div class="table-wrapper">

                        <table>

                            <thead>

                                <tr>

                                    <th>
                                        Nama
                                    </th>

                                    <th>
                                        Jawatan
                                    </th>

                                    <th>
                                        Jabatan
                                    </th>

                                    <th>
                                        Check In
                                    </th>

                                    <th>
                                        Check Out
                                    </th>

                                    <th>
                                        Jarak Masuk
                                    </th>

                                    <th>
                                        Jarak Keluar
                                    </th>

                                    <th>
                                        Status
                                    </th>

                                    <th>
                                        Maklumat
                                    </th>

                                </tr>

                            </thead>

                            <tbody>

                            <%
                                if (records.isEmpty()) {
                            %>

                                <tr>

                                    <td
                                        colspan="9"
                                        class="empty-state"
                                    >
                                        Tiada rekod kehadiran
                                        untuk tarikh ini.
                                    </td>

                                </tr>

                            <%
                                } else {

                                    for (
                                        Map<String, Object> row
                                            : records
                                    ) {

                                        String status = String.valueOf(row.get("status"));
                                        boolean hasApprovedLeave = row.get("approvedLeaveType") != null;
                                        Object checkIn = row.get("checkIn");
                                        Object checkOut = row.get("checkOut");
                                        Object lateReasonValue = row.get("lateReason");
                                        Object earlyReasonValue = row.get("earlyCheckoutReason");
                                        String statusLabel = getAttendanceLabel(checkIn, checkOut, lateReasonValue, earlyReasonValue, hasApprovedLeave, selectedDate);
                                        String statusClass = "status-belum";
                                        if (statusLabel.equals("Tepat Masa") || statusLabel.equals("Lengkap - Tepat Masa") || statusLabel.equals("Cuti Diluluskan")) statusClass = "status-selesai";
                                        else if (statusLabel.equals("Lewat") || statusLabel.equals("Lewat Bersebab")) statusClass = "status-late";
                                        else if (statusLabel.equals("Check Out Awal")) statusClass = "status-early";
                                        else if (statusLabel.equals("Tidak Hadir")) statusClass = "status-late";

                                        Object checkInDistance =
                                                row.get(
                                                    "checkInDistance"
                                                );

                                        Object checkOutDistance =
                                                row.get(
                                                    "checkOutDistance"
                                                );

                                        String position =
                                                row.get("position") == null
                                                    ? "—"
                                                    : String.valueOf(
                                                        row.get("position")
                                                    );

                                        String department =
                                                formatDepartment(row.get("department"));
                            %>

                                <tr>

                                    <td>

                                        <div class="staff-name">
                                            <%= row.get("name") %>
                                        </div>

                                    </td>

                                    <td>
                                        <%= position %>
                                    </td>

                                    <td>
                                        <%= department %>
                                    </td>

                                    <td>

                                        <%
                                            if (checkIn != null) {
                                        %>

                                            <span class="time-value table-time">
                                                <%= formatTableDateTime(checkIn) %>
                                            </span>

                                        <%
                                            } else {
                                        %>

                                            —

                                        <%
                                            }
                                        %>

                                    </td>

                                    <td>

                                        <%
                                            if (checkOut != null) {
                                        %>

                                            <span class="time-value table-time">
                                                <%= formatTableDateTime(checkOut) %>
                                            </span>

                                        <%
                                            } else {
                                        %>

                                            —

                                        <%
                                            }
                                        %>

                                    </td>

                                    <td>

                                        <span class="distance">

                                            <%
                                                if (
                                                    checkInDistance != null
                                                ) {
                                            %>

                                                <%= checkInDistance %> m

                                            <%
                                                } else {
                                            %>

                                                —

                                            <%
                                                }
                                            %>

                                        </span>

                                    </td>

                                    <td>

                                        <span class="distance">

                                            <%
                                                if (
                                                    checkOutDistance != null
                                                ) {
                                            %>

                                                <%= checkOutDistance %> m

                                            <%
                                                } else {
                                            %>

                                                —

                                            <%
                                                }
                                            %>

                                        </span>

                                    </td>

                                    <td>

                                        <span
                                            class="status-badge <%= statusClass %>"
                                        >
                                            <%= statusLabel %>
                                        </span>

                                    </td>

                                    <td>

                                        <button
                                            type="button"
                                            class="view-button"
                                            onclick="openAttendanceModal(this)"
                                            data-name="<%= esc(row.get("name") == null ? "—" : row.get("name")) %>"
                                            data-position="<%= esc(position) %>"
                                            data-department="<%= esc(department) %>"
                                            data-date="<%= esc(formatDisplayDate(selectedDate)) %>"
                                            data-status="<%= esc(statusLabel) %>"
                                            data-checkin="<%= esc(checkIn == null ? "—" : checkIn) %>"
                                            data-checkout="<%= esc(checkOut == null ? "—" : checkOut) %>"
                                            data-checkindistance="<%= esc(checkInDistance == null ? "—" : checkInDistance + " m") %>"
                                            data-checkoutdistance="<%= esc(checkOutDistance == null ? "—" : checkOutDistance + " m") %>"
                                            data-checkinlatitude="<%= esc(row.get("checkInLatitude") == null ? "—" : row.get("checkInLatitude")) %>"
                                            data-checkinlongitude="<%= esc(row.get("checkInLongitude") == null ? "—" : row.get("checkInLongitude")) %>"
                                            data-checkoutlatitude="<%= esc(row.get("checkOutLatitude") == null ? "—" : row.get("checkOutLatitude")) %>"
                                            data-checkoutlongitude="<%= esc(row.get("checkOutLongitude") == null ? "—" : row.get("checkOutLongitude")) %>"
                                            data-latereason="<%= esc(row.get("lateReason") == null ? "—" : row.get("lateReason")) %>"
                                            data-earlyreason="<%= esc(row.get("earlyCheckoutReason") == null ? "—" : row.get("earlyCheckoutReason")) %>"
                                            data-adminnote="<%= esc(row.get("adminNote") == null ? "" : row.get("adminNote")) %>"
                                            data-userid="<%= esc(row.get("userId")) %>"
                                            data-editcheckin="<%= esc(toDateTimeLocal(checkIn)) %>"
                                            data-editcheckout="<%= esc(toDateTimeLocal(checkOut)) %>"
                                            data-attendancedate="<%= selectedDate.toString() %>"
                                            data-leavetype="<%= esc(row.get("approvedLeaveType") == null ? "—" : row.get("approvedLeaveType")) %>"
                                            data-leavestart="<%= esc(formatDisplayDate(row.get("approvedLeaveStart"))) %>"
                                            data-leaveend="<%= esc(formatDisplayDate(row.get("approvedLeaveEnd"))) %>"
                                        >
                                            Lihat
                                        </button>

                                    </td>

                                </tr>

                            <%
                                    }
                                }
                            %>

                            </tbody>

                        </table>

                    </div>

                </section>

            </div>

        </div>

    </main>

</div>


<!-- =========================================================
     ATTENDANCE DETAIL MODAL
     ========================================================= -->

<div
    class="attendance-modal-overlay"
    id="attendanceModalOverlay"
    onclick="closeAttendanceModal(event)"
>

    <div
        class="attendance-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="attendanceModalTitle"
        onclick="event.stopPropagation();"
    >

        <div class="attendance-modal-header">

            <div class="attendance-modal-title">

                <h2 id="attendanceModalTitle">
                    Butiran Kehadiran
                </h2>

                <p id="attendanceModalSubtitle">
                    Maklumat penuh rekod kehadiran staf
                </p>

            </div>

            <button
                type="button"
                class="attendance-modal-close"
                onclick="closeAttendanceModal()"
                aria-label="Tutup"
            >
                ×
            </button>

        </div>

        <div class="attendance-modal-body">

            <div class="modal-section-title">
                Maklumat Staf
            </div>

            <div class="modal-info-grid">

                <div class="modal-info-box highlight">
                    <div class="modal-info-label">Nama</div>
                    <div class="modal-info-value" id="modalName">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Jawatan</div>
                    <div class="modal-info-value" id="modalPosition">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Jabatan</div>
                    <div class="modal-info-value" id="modalDepartment">—</div>
                </div>

            </div>

            <div class="modal-section-title">
                Maklumat Kehadiran
            </div>

            <div class="modal-info-grid">

                <div class="modal-info-box">
                    <div class="modal-info-label">Tarikh</div>
                    <div class="modal-info-value" id="modalDate">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Status</div>
                    <div class="modal-info-value">
                        <span class="modal-status" id="modalStatus">—</span>
                    </div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Masa Check In</div>
                    <div class="modal-info-value" id="modalCheckIn">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Masa Check Out</div>
                    <div class="modal-info-value" id="modalCheckOut">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Jarak Check In</div>
                    <div class="modal-info-value" id="modalCheckInDistance">—</div>
                </div>

                <div class="modal-info-box">
                    <div class="modal-info-label">Jarak Check Out</div>
                    <div class="modal-info-value" id="modalCheckOutDistance">—</div>
                </div>

            </div>

            <div class="modal-section-title">
                Maklumat Sebab Lewat dan Cuti
            </div>
            <div class="modal-info-grid">
                <div class="modal-info-box">
                    <div class="modal-info-label">Penjelasan Sebab Lewat</div>
                    <div class="modal-info-value" id="modalLateReason">—</div>
                </div>
                <div class="modal-info-box">
                    <div class="modal-info-label">Sebab Check Out Awal</div>
                    <div class="modal-info-value" id="modalEarlyReason">—</div>
                </div>
                <div class="modal-info-box">
                    <div class="modal-info-label">Catatan Pembetulan HR</div>
                    <div class="modal-info-value" id="modalAdminNote">—</div>
                </div>
                <div class="modal-info-box">
                    <div class="modal-info-label">Status / Jenis Cuti</div>
                    <div class="modal-info-value" id="modalLeaveType">—</div>
                </div>
                <div class="modal-info-box">
                    <div class="modal-info-label">Tempoh Cuti</div>
                    <div class="modal-info-value" id="modalLeavePeriod">—</div>
                </div>
            </div>

            <div class="admin-edit-section">
                <div class="modal-section-title">Pembetulan Rekod oleh HR Admin</div>
                <p class="admin-edit-hint">Gunakan jika staf terlupa Check In atau Check Out. Masa boleh dibiarkan kosong jika tiada rekod. Catatan pembetulan wajib diisi untuk tujuan audit.</p>
                <form method="post" action="<%= contextPath %>/attendance-records" id="adminAttendanceEditForm" onsubmit="return confirmAdminAttendanceUpdate();">
                    <input type="hidden" name="staffId" id="editStaffId">
                    <input type="hidden" name="attendanceDate" id="editAttendanceDate">
                    <div class="admin-edit-grid">
                        <div class="admin-edit-field">
                            <label for="editCheckInTime">Masa Check In</label>
                            <input type="datetime-local" name="checkInTime" id="editCheckInTime" step="1">
                        </div>
                        <div class="admin-edit-field">
                            <label for="editCheckOutTime">Masa Check Out</label>
                            <input type="datetime-local" name="checkOutTime" id="editCheckOutTime" step="1">
                        </div>
                        <div class="admin-edit-field full">
                            <label for="editAdminNote">Sebab pembetulan (wajib)</label>
                            <textarea name="adminNote" id="editAdminNote" rows="2" maxlength="1000" required placeholder="Contoh: Staf terlupa menekan butang Check Out."></textarea>
                        </div>
                    </div>
                    <button type="submit" class="admin-edit-submit">Simpan Pembetulan</button>
                </form>
            </div>

            <div class="modal-section-title">
                Maklumat Lokasi
            </div>

            <div class="modal-location-grid">

                <div class="modal-location-box">

                    <div class="modal-location-heading">
                        Lokasi Check In
                    </div>

                    <div class="modal-location-row">
                        <span>Latitude</span>
                        <span id="modalCheckInLatitude">—</span>
                    </div>

                    <div class="modal-location-row">
                        <span>Longitude</span>
                        <span id="modalCheckInLongitude">—</span>
                    </div>

                </div>

                <div class="modal-location-box">

                    <div class="modal-location-heading">
                        Lokasi Check Out
                    </div>

                    <div class="modal-location-row">
                        <span>Latitude</span>
                        <span id="modalCheckOutLatitude">—</span>
                    </div>

                    <div class="modal-location-row">
                        <span>Longitude</span>
                        <span id="modalCheckOutLongitude">—</span>
                    </div>

                </div>

            </div>

        </div>

    </div>

</div>

<script>
    function setAttendanceModalValue(id, value) {
        var element = document.getElementById(id);

        if (element) {
            element.textContent =
                value === null ||
                value === undefined ||
                value === ""
                    ? "—"
                    : value;
        }
    }

    function openAttendanceModal(button) {
        setAttendanceModalValue(
            "modalName",
            button.getAttribute("data-name")
        );

        setAttendanceModalValue(
            "modalPosition",
            button.getAttribute("data-position")
        );

        setAttendanceModalValue(
            "modalDepartment",
            button.getAttribute("data-department")
        );

        setAttendanceModalValue(
            "modalDate",
            button.getAttribute("data-date")
        );

        setAttendanceModalValue(
            "modalCheckIn",
            button.getAttribute("data-checkin")
        );

        setAttendanceModalValue(
            "modalCheckOut",
            button.getAttribute("data-checkout")
        );

        setAttendanceModalValue(
            "modalCheckInDistance",
            button.getAttribute("data-checkindistance")
        );

        setAttendanceModalValue(
            "modalCheckOutDistance",
            button.getAttribute("data-checkoutdistance")
        );

        setAttendanceModalValue(
            "modalCheckInLatitude",
            button.getAttribute("data-checkinlatitude")
        );

        setAttendanceModalValue(
            "modalCheckInLongitude",
            button.getAttribute("data-checkinlongitude")
        );

        setAttendanceModalValue(
            "modalCheckOutLatitude",
            button.getAttribute("data-checkoutlatitude")
        );

        setAttendanceModalValue(
            "modalCheckOutLongitude",
            button.getAttribute("data-checkoutlongitude")
        );

        setAttendanceModalValue(
            "modalLateReason",
            button.getAttribute("data-latereason")
        );
        setAttendanceModalValue("modalEarlyReason", button.getAttribute("data-earlyreason"));
        setAttendanceModalValue("modalAdminNote", button.getAttribute("data-adminnote"));

        document.getElementById("editStaffId").value = button.getAttribute("data-userid") || "";
        document.getElementById("editAttendanceDate").value = button.getAttribute("data-attendancedate") || "";
        document.getElementById("editCheckInTime").value = button.getAttribute("data-editcheckin") || "";
        document.getElementById("editCheckOutTime").value = button.getAttribute("data-editcheckout") || "";
        document.getElementById("editAdminNote").value = "";

        setAttendanceModalValue(
            "modalLeaveType",
            button.getAttribute("data-leavetype")
        );

        var leaveStart = button.getAttribute("data-leavestart") || "—";
        var leaveEnd = button.getAttribute("data-leaveend") || "—";
        var leavePeriod = (leaveStart === "—" && leaveEnd === "—")
                ? "—" : leaveStart + " hingga " + leaveEnd;
        setAttendanceModalValue("modalLeavePeriod", leavePeriod);

        var statusElement =
            document.getElementById("modalStatus");

        if (statusElement) {
            statusElement.textContent =
                button.getAttribute("data-status") || "—";
        }

        var overlay =
            document.getElementById("attendanceModalOverlay");

        if (overlay) {
            overlay.classList.add("show");
            document.body.classList.add("attendance-modal-open");
        }
    }

    function confirmAdminAttendanceUpdate() {
        var inValue = document.getElementById("editCheckInTime").value;
        var outValue = document.getElementById("editCheckOutTime").value;
        var note = document.getElementById("editAdminNote").value.trim();
        if (!note) { alert("Sila masukkan sebab pembetulan."); return false; }
        if (outValue && !inValue) { alert("Masa Check In perlu diisi sebelum Check Out."); return false; }
        if (inValue && outValue && new Date(outValue) < new Date(inValue)) {
            alert("Masa Check Out tidak boleh lebih awal daripada Check In."); return false;
        }
        return confirm("Sahkan pembetulan masa kehadiran ini? Perubahan akan direkodkan sebagai pembetulan HR.");
    }

    function closeAttendanceModal(event) {
        if (
            event &&
            event.target &&
            event.target.id !== "attendanceModalOverlay"
        ) {
            return;
        }

        var overlay =
            document.getElementById("attendanceModalOverlay");

        if (overlay) {
            overlay.classList.remove("show");
            document.body.classList.remove("attendance-modal-open");
        }
    }

    document.addEventListener("keydown", function(event) {
        if (event.key === "Escape") {
            closeAttendanceModal();
        }
    });
</script>

</body>

</html>
