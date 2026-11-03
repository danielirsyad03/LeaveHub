<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
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


    private String formatHolidayDate(Object value) {

        if (value == null) {
            return "";
        }

        try {

            LocalDate date =
                LocalDate.parse(
                    value.toString()
                );

            return date.format(
                DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy"
                )
            );

        } catch (Exception e) {

            return value.toString();
        }
    }


    private long calculateHolidayDays(
            Object startValue,
            Object endValue) {

        if (
            startValue == null ||
            endValue == null
        ) {
            return 0;
        }

        try {

            LocalDate start =
                LocalDate.parse(
                    startValue.toString()
                );

            LocalDate end =
                LocalDate.parse(
                    endValue.toString()
                );

            if (end.isBefore(start)) {
                return 0;
            }

            return ChronoUnit.DAYS.between(
                start,
                end
            ) + 1;

        } catch (Exception e) {

            return 0;
        }
    }

%>


<%

    // =========================================================
    // LOGIN / ROLE
    // =========================================================

    if (
        session.getAttribute("userId") == null
    ) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    String role =
        session.getAttribute("userRole") == null
            ? ""
            : session
                .getAttribute("userRole")
                .toString()
                .trim()
                .toUpperCase();


    if (!"HR".equals(role)) {

        response.sendError(
            403
        );

        return;
    }


    String name =
        session.getAttribute("userName") == null
            ? "Pentadbir"
            : session
                .getAttribute("userName")
                .toString();


    @SuppressWarnings("unchecked")
    List<Map<String, Object>> holidays =
        (List<Map<String, Object>>)
        request.getAttribute(
            "holidays"
        );


    int totalHolidays =
        request.getAttribute("totalHolidays") == null
            ? 0
            : ((Number)
                request.getAttribute(
                    "totalHolidays"
                )
              ).intValue();


    int activeHolidays =
        request.getAttribute("activeHolidays") == null
            ? 0
            : ((Number)
                request.getAttribute(
                    "activeHolidays"
                )
              ).intValue();


    int inactiveHolidays =
        request.getAttribute("inactiveHolidays") == null
            ? 0
            : ((Number)
                request.getAttribute(
                    "inactiveHolidays"
                )
              ).intValue();


    int currentYearHolidays =
        request.getAttribute("currentYearHolidays") == null
            ? 0
            : ((Number)
                request.getAttribute(
                    "currentYearHolidays"
                )
              ).intValue();


    int currentYear =
        request.getAttribute("currentYear") == null
            ? LocalDate.now().getYear()
            : ((Number)
                request.getAttribute(
                    "currentYear"
                )
              ).intValue();


    String success =
        request.getParameter(
            "success"
        );


    String error =
        request.getParameter(
            "error"
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
        Pengurusan Cuti Umum - PKB
    </title>


    <link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260914-unified"
/>


    <style>

        /* =====================================================
           PAGE
           ===================================================== */

        .holiday-page {
            max-width: 1400px;
        }


        .holiday-page-header {

            display: flex;

            align-items: flex-start;

            justify-content: space-between;

            gap: 20px;

            margin-bottom: 22px;
        }


        .holiday-page-title h1 {

            margin: 0 0 5px;

            color: #172033;

            font-size: 28px;

            font-weight: 800;

            letter-spacing: -.5px;
        }


        .holiday-page-title p {

            margin: 0;

            color: #7d8799;

            font-size: 13px;
        }


        /* =====================================================
           ALERT
           ===================================================== */

        .holiday-alert {

            margin-bottom: 18px;

            padding: 13px 15px;

            border-radius: 11px;

            font-size: 12px;

            line-height: 1.5;
        }


        .holiday-alert.success {

            color: #24704d;

            background: #edf9f2;

            border: 1px solid #cbe8d8;
        }


        .holiday-alert.error {

            color: #a32c39;

            background: #fff0f2;

            border: 1px solid #efcdd2;
        }


        /* =====================================================
           SUMMARY
           ===================================================== */

        .holiday-summary {

            display: grid;

            grid-template-columns:
                repeat(4, minmax(0, 1fr));

            gap: 12px;

            margin-bottom: 18px;
        }


        .holiday-summary-card {

            position: relative;

            padding: 16px 18px;

            min-height: 94px;

            box-sizing: border-box;

            overflow: hidden;

            background: #ffffff;

            border: 1px solid #e7e9ef;

            border-radius: 13px;

            box-shadow:
                0 4px 14px
                rgba(27, 36, 53, .04);
        }


        .holiday-summary-card::before {

            content: "";

            position: absolute;

            top: 13px;

            bottom: 13px;

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


        .holiday-summary-card span {

            display: block;

            color: #8b94a4;

            font-size: 10px;

            font-weight: 750;

            text-transform: uppercase;

            letter-spacing: .4px;
        }


        .holiday-summary-card strong {

            display: block;

            margin-top: 7px;

            color: #172033;

            font-size: 27px;

            line-height: 1;

            font-weight: 850;
        }


        .holiday-summary-card small {

            display: block;

            margin-top: 6px;

            color: #8f98a7;

            font-size: 10px;
        }


        /* =====================================================
           LAYOUT
           ===================================================== */

        .holiday-layout {

            display: grid;

            grid-template-columns:
                minmax(320px, 410px)
                minmax(0, 1fr);

            align-items: start;

            gap: 18px;
        }


        /* =====================================================
           CARD
           ===================================================== */

        .holiday-card {

            background: #ffffff;

            border: 1px solid #e7e9ef;

            border-radius: 16px;

            box-shadow:
                0 6px 22px
                rgba(31, 41, 61, .045);

            overflow: hidden;
        }


        .holiday-card-header {

            padding: 18px 20px;

            border-bottom:
                1px solid #eceef2;

            background:
                linear-gradient(
                    180deg,
                    #ffffff,
                    #fcfcfd
                );
        }


        .holiday-card-header h2 {

            margin: 0 0 4px;

            color: #172033;

            font-size: 17px;

            font-weight: 800;
        }


        .holiday-card-header p {

            margin: 0;

            color: #8b94a4;

            font-size: 11px;

            line-height: 1.5;
        }


        .holiday-card-body {
            padding: 20px;
        }


        /* =====================================================
           FORM
           ===================================================== */

        .holiday-field {
            margin-bottom: 16px;
        }


        .holiday-field:last-child {
            margin-bottom: 0;
        }


        .holiday-field label {

            display: block;

            margin-bottom: 7px;

            color: #434d60;

            font-size: 12px;

            font-weight: 700;
        }


        .holiday-field input,
        .holiday-field textarea {

            width: 100%;

            box-sizing: border-box;

            border: 1px solid #dfe3ea;

            border-radius: 10px;

            background: #ffffff;

            color: #172033;

            font-family: inherit;

            font-size: 13px;

            outline: none;
        }


        .holiday-field input {

            height: 43px;

            padding: 0 13px;
        }


        .holiday-field textarea {

            min-height: 95px;

            padding: 11px 13px;

            resize: vertical;
        }


        .holiday-field input:focus,
        .holiday-field textarea:focus {

            border-color: #a74654;

            box-shadow:
                0 0 0 3px
                rgba(141, 31, 45, .08);
        }


        .holiday-field small {

            display: block;

            margin-top: 5px;

            color: #929aa8;

            font-size: 10px;
        }


        /* =====================================================
           DATE GRID
           ===================================================== */

        .holiday-date-grid {

            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 12px;
        }


        .holiday-duration-preview {

            display: none;

            margin-top: -4px;

            margin-bottom: 16px;

            padding: 11px 13px;

            border-radius: 9px;

            background: #f8f1f2;

            border: 1px solid #ead8dc;

            color: #6c4850;

            font-size: 11px;

            line-height: 1.5;
        }


        .holiday-duration-preview.show {
            display: block;
        }


        .holiday-duration-preview strong {
            color: #8d1f2d;
        }


        /* =====================================================
           FORM ACTIONS
           ===================================================== */

        .holiday-form-actions {

            display: flex;

            align-items: center;

            gap: 8px;

            margin-top: 20px;
        }


        .holiday-btn {

            min-height: 38px;

            display: inline-flex;

            align-items: center;

            justify-content: center;

            padding: 8px 13px;

            border-radius: 9px;

            border: 1px solid transparent;

            font-family: inherit;

            font-size: 11px;

            font-weight: 750;

            text-decoration: none;

            cursor: pointer;
        }


        .holiday-btn.primary {

            color: #ffffff;

            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a72a3b
                );

            border-color: #8d1f2d;
        }


        .holiday-btn.primary:hover {

            background:
                linear-gradient(
                    135deg,
                    #711722,
                    #8d1f2d
                );
        }


        .holiday-btn.secondary {

            color: #626d80;

            background: #ffffff;

            border-color: #dfe3e9;
        }


        .holiday-btn.secondary:hover {

            color: #8d1f2d;

            background: #fff8f8;

            border-color: #dab7bd;
        }


        .holiday-btn.warning {

            color: #855f0c;

            background: #fff7e5;

            border-color: #eedcae;
        }


        .holiday-btn.success {

            color: #24704d;

            background: #edf9f2;

            border-color: #cbe8d8;
        }


        .holiday-btn.danger {

            color: #aa2f3c;

            background: #fff1f2;

            border-color: #efced3;
        }


        /* =====================================================
           SEARCH
           ===================================================== */

        .holiday-list-toolbar {

            display: flex;

            align-items: center;

            justify-content: space-between;

            gap: 12px;

            margin-bottom: 14px;
        }


        .holiday-search {

            width: 100%;

            max-width: 320px;

            height: 39px;

            padding: 0 12px;

            box-sizing: border-box;

            border: 1px solid #dfe3e9;

            border-radius: 9px;

            color: #172033;

            font-family: inherit;

            font-size: 12px;

            outline: none;
        }


        .holiday-search:focus {

            border-color: #a74654;

            box-shadow:
                0 0 0 3px
                rgba(141, 31, 45, .07);
        }


        /* =====================================================
           TABLE
           ===================================================== */

        .holiday-table-wrap {
            overflow-x: auto;
        }


        .holiday-table {

            width: 100%;

            min-width: 820px;

            border-collapse: collapse;
        }


        .holiday-table th {

            padding: 11px 12px;

            background: #fafbfc;

            border-bottom:
                1px solid #e6e9ef;

            color: #747f91;

            font-size: 10px;

            font-weight: 800;

            text-align: left;

            text-transform: uppercase;

            letter-spacing: .35px;
        }


        .holiday-table td {

            padding: 13px 12px;

            border-bottom:
                1px solid #edf0f3;

            color: #465064;

            font-size: 12px;

            vertical-align: middle;
        }


        .holiday-table tr:last-child td {
            border-bottom: 0;
        }


        .holiday-name {

            display: block;

            color: #263044;

            font-size: 13px;

            font-weight: 750;
        }


        .holiday-desc {

            display: block;

            max-width: 280px;

            margin-top: 3px;

            color: #8a93a3;

            font-size: 10px;

            line-height: 1.4;
        }


        .holiday-date {

            display: block;

            white-space: nowrap;

            color: #5e687b;

            font-weight: 700;
        }


        .holiday-duration {

            display: inline-block;

            margin-top: 5px;

            padding: 4px 7px;

            border-radius: 999px;

            background: #f3f5f8;

            color: #758095;

            font-size: 9px;

            font-weight: 700;
        }


        .holiday-status {

            display: inline-flex;

            align-items: center;

            padding: 5px 8px;

            border-radius: 999px;

            font-size: 9px;

            font-weight: 800;

            text-transform: uppercase;

            letter-spacing: .3px;
        }


        .holiday-status.active {

            color: #24704d;

            background: #edf9f2;
        }


        .holiday-status.inactive {

            color: #767e8b;

            background: #f1f3f5;
        }


        .holiday-actions {

            display: flex;

            align-items: center;

            flex-wrap: wrap;

            gap: 6px;
        }


        .holiday-empty {

            padding: 45px 20px;

            color: #8b94a4;

            font-size: 12px;

            text-align: center;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 1050px) {

            .holiday-summary {

                grid-template-columns:
                    repeat(
                        2,
                        minmax(0, 1fr)
                    );
            }


            .holiday-layout {
                grid-template-columns: 1fr;
            }
        }


        @media (max-width: 650px) {

            .holiday-page-header {
                flex-direction: column;
            }


            .holiday-summary {
                grid-template-columns: 1fr;
            }


            .holiday-date-grid {
                grid-template-columns: 1fr;
            }


            .holiday-list-toolbar {

                align-items: stretch;

                flex-direction: column;
            }


            .holiday-search {
                max-width: none;
            }


            .holiday-form-actions {

                align-items: stretch;

                flex-direction: column;
            }


            .holiday-btn {
                width: 100%;
            }
        }
/* =========================================================
   FINAL STANDARD FONT & SIZE
   IKUT PENGURUSAN INVENTORI / PENGURUSAN STAF
   ========================================================= */

/* MAIN PAGE */
.holiday-page {
    max-width: 1400px;
}

/* =========================================================
   PAGE HEADER
   ========================================================= */

.holiday-page-title h1 {
    margin: 0 0 5px;
    color: #172033;

    /* sama seperti Pengurusan Inventori */
    font-size: 26px;
    font-weight: 800;
    line-height: 1.2;
    letter-spacing: -0.4px;
}

.holiday-page-title p {
    margin: 0;
    color: #7d8799;
    font-size: 13px;
    font-weight: 400;
    line-height: 1.5;
}


/* =========================================================
   SUMMARY CARDS
   ========================================================= */

.holiday-summary-card {
    padding: 15px 17px;
    min-height: 92px;
}

.holiday-summary-card span {
    display: block;
    color: #7f899a;

    font-size: 10px;
    font-weight: 700;

    text-transform: uppercase;
    letter-spacing: 0.25px;
}

.holiday-summary-card strong {
    display: block;

    margin-top: 6px;

    color: #172033;

    font-size: 24px;
    font-weight: 800;
    line-height: 1;
}

.holiday-summary-card small {
    display: block;

    margin-top: 6px;

    color: #8f98a7;

    font-size: 10px;
    font-weight: 400;
    line-height: 1.4;
}


/* =========================================================
   CARD HEADER
   TAMBAH CUTI UMUM / SENARAI CUTI UMUM
   ========================================================= */

.holiday-card-header {
    padding: 17px 20px;
}

.holiday-card-header h2 {
    margin: 0 0 4px;

    color: #172033;

    font-size: 16px;
    font-weight: 800;
    line-height: 1.3;
}

.holiday-card-header p {
    margin: 0;

    color: #8b94a4;

    font-size: 11px;
    font-weight: 400;
    line-height: 1.5;
}


/* =========================================================
   FORM
   ========================================================= */

.holiday-field {
    margin-bottom: 15px;
}

.holiday-field label {
    display: block;

    margin-bottom: 7px;

    color: #434d60;

    font-size: 11px;
    font-weight: 700;
}

.holiday-field input,
.holiday-field textarea {
    width: 100%;

    box-sizing: border-box;

    font-family: inherit;

    font-size: 12px;
    font-weight: 400;

    color: #172033;
}

.holiday-field input {
    height: 42px;
    padding: 0 13px;
}

.holiday-field textarea {
    min-height: 95px;

    padding: 11px 13px;

    line-height: 1.5;
}

.holiday-field input::placeholder,
.holiday-field textarea::placeholder {
    color: #9aa3b3;

    font-size: 12px;
    font-weight: 400;
}

.holiday-field small {
    margin-top: 5px;

    color: #929aa8;

    font-size: 10px;
    font-weight: 400;
}


/* =========================================================
   DURATION PREVIEW
   ========================================================= */

.holiday-duration-preview {
    font-size: 11px;
    line-height: 1.5;
}

.holiday-duration-preview strong {
    font-size: 11px;
    font-weight: 700;
}


/* =========================================================
   SEARCH
   ========================================================= */

.holiday-search {
    height: 39px;

    padding: 0 12px;

    font-family: inherit;

    font-size: 11px;
    font-weight: 400;

    color: #172033;
}

.holiday-search::placeholder {
    color: #9aa3b3;

    font-size: 11px;
}

#resultCount {
    font-size: 10px !important;
    color: #8992a2 !important;
}


/* =========================================================
   TABLE HEADER
   ========================================================= */

.holiday-table th {
    padding: 10px 12px;

    color: #747f91;

    font-size: 9px;
    font-weight: 700;

    text-transform: uppercase;

    letter-spacing: 0.25px;
}


/* =========================================================
   TABLE INFORMATION
   ========================================================= */

.holiday-table td {
    padding: 12px 12px;

    color: #465064;

    font-size: 11px;
    font-weight: 400;

    vertical-align: middle;
}


/* =========================================================
   HOLIDAY NAME
   ========================================================= */

.holiday-name {
    display: block;

    color: #263044;

    font-size: 12px;
    font-weight: 700;

    line-height: 1.35;
}


/* =========================================================
   HOLIDAY DESCRIPTION
   ========================================================= */

.holiday-desc {
    display: block;

    margin-top: 3px;

    color: #8a93a3;

    font-size: 10px;
    font-weight: 400;

    line-height: 1.4;
}


/* =========================================================
   DATE
   ========================================================= */

.holiday-date {
    display: block;

    white-space: nowrap;

    color: #4f5a6d;

    font-size: 11px;
    font-weight: 700;

    line-height: 1.35;
}


/* =========================================================
   DURATION BADGE
   ========================================================= */

.holiday-duration {
    display: inline-block;

    margin-top: 5px;

    padding: 3px 7px;

    border-radius: 999px;

    background: #f3f5f8;

    color: #758095;

    font-size: 9px;
    font-weight: 700;
}


/* =========================================================
   STATUS BADGE
   ========================================================= */

.holiday-status {
    display: inline-flex;

    align-items: center;
    justify-content: center;

    padding: 5px 8px;

    border-radius: 999px;

    font-size: 9px;
    font-weight: 800;

    line-height: 1;

    text-transform: uppercase;

    letter-spacing: 0.2px;
}

.holiday-status.active {
    color: #24704d;
    background: #edf9f2;
}

.holiday-status.inactive {
    color: #767e8b;
    background: #f1f3f5;
}


/* =========================================================
   BUTTONS
   Edit / Nyahaktif / Padam
   ========================================================= */

.holiday-btn {
    min-height: 34px;

    display: inline-flex;

    align-items: center;
    justify-content: center;

    padding: 7px 11px;

    border-radius: 8px;

    font-family: inherit;

    font-size: 10px;
    font-weight: 600;

    line-height: 1;

    white-space: nowrap;

    text-decoration: none;

    cursor: pointer;
}


/* =========================================================
   PRIMARY BUTTON
   TAMBAH CUTI UMUM
   ========================================================= */

.holiday-btn.primary {
    min-height: 36px;

    padding: 8px 13px;

    color: #ffffff;

    background: linear-gradient(
        135deg,
        #8d1f2d,
        #a72a3b
    );

    border: 1px solid #8d1f2d;

    font-size: 11px;
    font-weight: 700;
}

.holiday-btn.primary:hover {
    background: linear-gradient(
        135deg,
        #711722,
        #8d1f2d
    );
}


/* =========================================================
   EDIT
   ========================================================= */

.holiday-btn.secondary {
    color: #626d80;

    background: #ffffff;

    border: 1px solid #dfe3e9;
}

.holiday-btn.secondary:hover {
    color: #8d1f2d;

    background: #fff8f8;

    border-color: #dab7bd;
}


/* =========================================================
   NYAHAKTIF
   ========================================================= */

.holiday-btn.warning {
    color: #855f0c;

    background: #fff7e5;

    border: 1px solid #eedcae;
}


/* =========================================================
   AKTIFKAN
   ========================================================= */

.holiday-btn.success {
    color: #24704d;

    background: #edf9f2;

    border: 1px solid #cbe8d8;
}


/* =========================================================
   PADAM
   ========================================================= */

.holiday-btn.danger {
    color: #aa2f3c;

    background: #fff1f2;

    border: 1px solid #efced3;
}


/* =========================================================
   ACTION COLUMN
   ========================================================= */

.holiday-actions {
    display: flex;

    align-items: center;

    flex-wrap: nowrap;

    gap: 6px;
}


/* Jangan biarkan form dalam action mengubah alignment */
.holiday-actions form {
    margin: 0;
    padding: 0;

    display: inline-flex !important;

    align-items: center;
}


/* =========================================================
   USER CHIP
   ========================================================= */

.holiday-page-header .user-chip {
    font-size: 12px;
}

.holiday-page-header .user-chip b {
    font-size: 12px;
    font-weight: 700;
}


/* =========================================================
   EMPTY STATE
   ========================================================= */

.holiday-empty {
    padding: 45px 20px;

    color: #8b94a4;

    font-size: 11px;

    text-align: center;
}


/* =========================================================
   ALERT
   ========================================================= */

.holiday-alert {
    font-size: 11px;
    line-height: 1.5;
}


/* =========================================================
   RESPONSIVE
   ========================================================= */

@media (max-width: 1050px) {

    .holiday-summary {
        grid-template-columns:
            repeat(2, minmax(0, 1fr));
    }

    .holiday-layout {
        grid-template-columns: 1fr;
    }
}


@media (max-width: 650px) {

    .holiday-page-title h1 {
        font-size: 23px;
    }

    .holiday-page-title p {
        font-size: 12px;
    }

    .holiday-summary {
        grid-template-columns: 1fr;
    }

    .holiday-date-grid {
        grid-template-columns: 1fr;
    }

    .holiday-list-toolbar {
        align-items: stretch;
        flex-direction: column;
    }

    .holiday-search {
        max-width: none;
    }

    .holiday-form-actions {
        align-items: stretch;
        flex-direction: column;
    }

    .holiday-form-actions .holiday-btn {
        width: 100%;
    }
}/* FINAL PAGE TITLE STANDARD */
.holiday-page-title h1 {
    font-size: 26px !important;
    font-weight: 700 !important;
    line-height: 1.2 !important;
    letter-spacing: -0.3px !important;
}
    </style>

</head>


<body>

<div class="app">


    <%@ include file="includes/sidebar.jspf" %>


    <main>


        <div class="holiday-page">


            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="holiday-page-header">


                <div class="holiday-page-title">

                    <h1>
                        Pengurusan Cuti Umum
                    </h1>

                    <p>
                        Urus cuti umum satu hari atau beberapa hari
                        yang digunakan dalam pengiraan permohonan
                        dan kalendar cuti.
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
                 SUCCESS
                 ================================================= -->

            <% if (success != null) { %>

                <div class="holiday-alert success">

                    <%

                        if ("added".equals(success)) {

                            out.print(
                                "Cuti umum berjaya ditambah."
                            );

                        } else if ("updated".equals(success)) {

                            out.print(
                                "Maklumat cuti umum berjaya dikemas kini."
                            );

                        } else if ("status".equals(success)) {

                            out.print(
                                "Status cuti umum berjaya dikemas kini."
                            );

                        } else if ("deleted".equals(success)) {

                            out.print(
                                "Rekod cuti umum berjaya dipadam."
                            );

                        } else {

                            out.print(
                                "Operasi berjaya diselesaikan."
                            );
                        }

                    %>

                </div>

            <% } %>


            <!-- =================================================
                 ERROR
                 ================================================= -->

            <% if (error != null) { %>

                <div class="holiday-alert error">

                    <%

                        if ("duplicate".equals(error)) {

                            out.print(
                                "Rekod cuti umum dengan nama dan tempoh yang sama telah wujud."
                            );

                        } else if ("required".equals(error)) {

                            out.print(
                                "Nama cuti, tarikh mula dan tarikh akhir wajib diisi."
                            );

                        } else if ("date".equals(error)) {

                            out.print(
                                "Tarikh cuti umum tidak sah."
                            );

                        } else if ("dateRange".equals(error)) {

                            out.print(
                                "Tarikh akhir tidak boleh lebih awal daripada tarikh mula."
                            );

                        } else if ("nameLength".equals(error)) {

                            out.print(
                                "Nama cuti terlalu panjang. Maksimum 150 aksara."
                            );

                        } else if ("descriptionLength".equals(error)) {

                            out.print(
                                "Keterangan terlalu panjang. Maksimum 255 aksara."
                            );

                        } else if ("notFound".equals(error)) {

                            out.print(
                                "Rekod cuti umum tidak ditemui."
                            );

                        } else {

                            out.print(
                                "Maklumat tidak sah. Sila cuba semula."
                            );
                        }

                    %>

                </div>

            <% } %>


            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="holiday-summary">


                <div class="holiday-summary-card">

                    <span>
                        Jumlah Rekod
                    </span>

                    <strong>
                        <%= totalHolidays %>
                    </strong>

                    <small>
                        Semua rekod cuti umum
                    </small>

                </div>


                <div class="holiday-summary-card">

                    <span>
                        Aktif
                    </span>

                    <strong>
                        <%= activeHolidays %>
                    </strong>

                    <small>
                        Digunakan dalam kiraan cuti
                    </small>

                </div>


                <div class="holiday-summary-card">

                    <span>
                        Tidak Aktif
                    </span>

                    <strong>
                        <%= inactiveHolidays %>
                    </strong>

                    <small>
                        Tidak digunakan dalam kiraan
                    </small>

                </div>


                <div class="holiday-summary-card">

                    <span>
                        Tahun <%= currentYear %>
                    </span>

                    <strong>
                        <%= currentYearHolidays %>
                    </strong>

                    <small>
                        Rekod melibatkan tahun semasa
                    </small>

                </div>


            </div>


            <!-- =================================================
                 MAIN LAYOUT
                 ================================================= -->

            <div class="holiday-layout">


                <!-- =============================================
                     FORM CARD
                     ============================================= -->

                <div class="holiday-card">


                    <div class="holiday-card-header">

                        <h2 id="formTitle">
                            Tambah Cuti Umum
                        </h2>

                        <p id="formDescription">
                            Untuk cuti sehari, gunakan tarikh mula
                            dan tarikh akhir yang sama.
                        </p>

                    </div>


                    <div class="holiday-card-body">


                        <form
                            method="post"
                            action="<%= request.getContextPath() %>/public-holidays"
                            id="holidayForm"
                        >


                            <input
                                type="hidden"
                                name="action"
                                id="formAction"
                                value="add"
                            >


                            <input
                                type="hidden"
                                name="id"
                                id="holidayId"
                                value=""
                            >


                            <!-- NAME -->

                            <div class="holiday-field">

                                <label for="holidayName">
                                    Nama Cuti *
                                </label>

                                <input
                                    type="text"
                                    name="holidayName"
                                    id="holidayName"
                                    maxlength="150"
                                    placeholder="Contoh: Hari Raya Aidilfitri"
                                    required
                                >

                            </div>


                            <!-- DATE RANGE -->

                            <div class="holiday-date-grid">


                                <div class="holiday-field">

                                    <label for="startDate">
                                        Tarikh Mula *
                                    </label>

                                    <input
                                        type="date"
                                        name="startDate"
                                        id="startDate"
                                        required
                                    >

                                </div>


                                <div class="holiday-field">

                                    <label for="endDate">
                                        Tarikh Akhir *
                                    </label>

                                    <input
                                        type="date"
                                        name="endDate"
                                        id="endDate"
                                        required
                                    >

                                </div>


                            </div>


                            <!-- DURATION PREVIEW -->

                            <div
                                id="durationPreview"
                                class="holiday-duration-preview"
                            ></div>


                            <!-- DESCRIPTION -->

                            <div class="holiday-field">

                                <label for="description">
                                    Keterangan
                                </label>

                                <textarea
                                    name="description"
                                    id="description"
                                    maxlength="255"
                                    placeholder="Contoh: Cuti umum persekutuan"
                                ></textarea>

                                <small>
                                    Maksimum 255 aksara.
                                </small>

                            </div>


                            <!-- ACTIONS -->

                            <div class="holiday-form-actions">


                                <button
                                    type="submit"
                                    class="holiday-btn primary"
                                    id="submitFormButton"
                                >
                                    Tambah Cuti Umum
                                </button>


                                <button
                                    type="button"
                                    class="holiday-btn secondary"
                                    id="cancelEditButton"
                                    onclick="resetHolidayForm()"
                                    style="display:none;"
                                >
                                    Batal Kemas Kini
                                </button>


                            </div>


                        </form>


                    </div>


                </div>


                <!-- =============================================
                     LIST CARD
                     ============================================= -->

                <div class="holiday-card">


                    <div class="holiday-card-header">

                        <h2>
                            Senarai Cuti Umum
                        </h2>

                        <p>
                            Hanya rekod aktif digunakan dalam
                            pengiraan hari cuti dan dipaparkan
                            dalam Kalendar Cuti.
                        </p>

                    </div>


                    <div class="holiday-card-body">


                        <!-- SEARCH -->

                        <div class="holiday-list-toolbar">


                            <input
                                type="search"
                                id="holidaySearch"
                                class="holiday-search"
                                placeholder="Cari nama, tarikh atau keterangan..."
                            >


                            <span
                                id="resultCount"
                                style="font-size:11px;color:#8992a2;"
                            >
                                <%= totalHolidays %> rekod
                            </span>


                        </div>


                        <div class="holiday-table-wrap">


                            <% if (
                                holidays == null ||
                                holidays.isEmpty()
                            ) { %>


                                <div class="holiday-empty">
                                    Belum ada rekod cuti umum.
                                </div>


                            <% } else { %>


                                <table
                                    class="holiday-table"
                                    id="holidayTable"
                                >


                                    <thead>

                                        <tr>

                                            <th>
                                                Cuti Umum
                                            </th>

                                            <th>
                                                Tempoh
                                            </th>

                                            <th>
                                                Status
                                            </th>

                                            <th>
                                                Tindakan
                                            </th>

                                        </tr>

                                    </thead>


                                    <tbody>


                                    <%

                                        for (
                                            Map<String, Object> holiday :
                                            holidays
                                        ) {


                                            int id =
                                                ((Number)
                                                    holiday.get("id")
                                                ).intValue();


                                            String holidayName =
                                                holiday.get("holidayName") == null
                                                    ? ""
                                                    : holiday.get("holidayName")
                                                        .toString();


                                            String startDate =
                                                holiday.get("startDate") == null
                                                    ? ""
                                                    : holiday.get("startDate")
                                                        .toString();


                                            String endDate =
                                                holiday.get("endDate") == null
                                                    ? ""
                                                    : holiday.get("endDate")
                                                        .toString();


                                            String description =
                                                holiday.get("description") == null
                                                    ? ""
                                                    : holiday.get("description")
                                                        .toString();


                                            boolean active =
                                                Boolean.TRUE.equals(
                                                    holiday.get("active")
                                                );


                                            long holidayDays =
                                                calculateHolidayDays(
                                                    startDate,
                                                    endDate
                                                );

                                    %>


                                    <tr
                                        class="holiday-row"
                                        data-search="<%= htmlEscape(
                                            (
                                                holidayName
                                                + " "
                                                + startDate
                                                + " "
                                                + endDate
                                                + " "
                                                + description
                                            ).toLowerCase()
                                        ) %>"
                                    >


                                        <!-- HOLIDAY -->

                                        <td>

                                            <span class="holiday-name">
                                                <%= htmlEscape(holidayName) %>
                                            </span>

                                            <span class="holiday-desc">

                                                <%= description.isBlank()
                                                    ? "Tiada keterangan."
                                                    : htmlEscape(description)
                                                %>

                                            </span>

                                        </td>


                                        <!-- DATE RANGE -->

                                        <td>


                                            <span class="holiday-date">

                                                <% if (
                                                    startDate.equals(
                                                        endDate
                                                    )
                                                ) { %>

                                                    <%= htmlEscape(
                                                        formatHolidayDate(
                                                            startDate
                                                        )
                                                    ) %>

                                                <% } else { %>

                                                    <%= htmlEscape(
                                                        formatHolidayDate(
                                                            startDate
                                                        )
                                                    ) %>

                                                    &nbsp;–&nbsp;

                                                    <%= htmlEscape(
                                                        formatHolidayDate(
                                                            endDate
                                                        )
                                                    ) %>

                                                <% } %>

                                            </span>


                                            <span class="holiday-duration">

                                                <%= holidayDays %>

                                                <%= holidayDays == 1
                                                    ? "hari"
                                                    : "hari"
                                                %>

                                            </span>


                                        </td>


                                        <!-- STATUS -->

                                        <td>

                                            <span
                                                class="holiday-status <%= active ? "active" : "inactive" %>"
                                            >

                                                <%= active
                                                    ? "Aktif"
                                                    : "Tidak Aktif"
                                                %>

                                            </span>

                                        </td>


                                        <!-- ACTION -->

                                        <td>


                                            <div class="holiday-actions">


                                                <!-- EDIT -->

                                                <button
                                                    type="button"
                                                    class="holiday-btn secondary"
                                                    onclick="editHoliday(
                                                        <%= id %>,
                                                        '<%= jsEscape(holidayName) %>',
                                                        '<%= jsEscape(startDate) %>',
                                                        '<%= jsEscape(endDate) %>',
                                                        '<%= jsEscape(description) %>'
                                                    )"
                                                >
                                                    Edit
                                                </button>


                                                <!-- TOGGLE -->

                                                <form
                                                    method="post"
                                                    action="<%= request.getContextPath() %>/public-holidays"
                                                    style="display:inline;"
                                                >

                                                    <input
                                                        type="hidden"
                                                        name="action"
                                                        value="toggle"
                                                    >

                                                    <input
                                                        type="hidden"
                                                        name="id"
                                                        value="<%= id %>"
                                                    >

                                                    <button
                                                        type="submit"
                                                        class="holiday-btn <%= active ? "warning" : "success" %>"
                                                    >

                                                        <%= active
                                                            ? "Nyahaktif"
                                                            : "Aktifkan"
                                                        %>

                                                    </button>

                                                </form>


                                                <!-- DELETE -->

                                                <form
                                                    method="post"
                                                    action="<%= request.getContextPath() %>/public-holidays"
                                                    style="display:inline;"
                                                    onsubmit="return confirmDeleteHoliday(
                                                        '<%= jsEscape(holidayName) %>'
                                                    );"
                                                >

                                                    <input
                                                        type="hidden"
                                                        name="action"
                                                        value="delete"
                                                    >

                                                    <input
                                                        type="hidden"
                                                        name="id"
                                                        value="<%= id %>"
                                                    >

                                                    <button
                                                        type="submit"
                                                        class="holiday-btn danger"
                                                    >
                                                        Padam
                                                    </button>

                                                </form>


                                            </div>


                                        </td>


                                    </tr>


                                    <%

                                        }

                                    %>


                                    </tbody>


                                </table>


                            <% } %>


                        </div>


                    </div>


                </div>


            </div>


        </div>


    </main>


</div>


<script>

    // =========================================================
    // ELEMENTS
    // =========================================================

    const holidayForm =
        document.getElementById(
            "holidayForm"
        );


    const formAction =
        document.getElementById(
            "formAction"
        );


    const holidayId =
        document.getElementById(
            "holidayId"
        );


    const holidayName =
        document.getElementById(
            "holidayName"
        );


    const startDate =
        document.getElementById(
            "startDate"
        );


    const endDate =
        document.getElementById(
            "endDate"
        );


    const description =
        document.getElementById(
            "description"
        );


    const durationPreview =
        document.getElementById(
            "durationPreview"
        );


    const formTitle =
        document.getElementById(
            "formTitle"
        );


    const formDescription =
        document.getElementById(
            "formDescription"
        );


    const submitFormButton =
        document.getElementById(
            "submitFormButton"
        );


    const cancelEditButton =
        document.getElementById(
            "cancelEditButton"
        );


    // =========================================================
    // CALCULATE RANGE DAYS
    // =========================================================

    function updateDurationPreview() {


        durationPreview.classList.remove(
            "show"
        );


        durationPreview.textContent =
            "";


        if (
            !startDate.value ||
            !endDate.value
        ) {

            return;
        }


        const start =
            new Date(
                startDate.value
                + "T00:00:00"
            );


        const end =
            new Date(
                endDate.value
                + "T00:00:00"
            );


        if (
            end < start
        ) {


            durationPreview.innerHTML =
                "<strong>Tarikh tidak sah.</strong> "
                + "Tarikh akhir tidak boleh lebih awal daripada tarikh mula.";


            durationPreview.classList.add(
                "show"
            );


            return;
        }


        const millisecondsPerDay =
            24 * 60 * 60 * 1000;


        const totalDays =
            Math.round(
                (
                    end.getTime()
                    -
                    start.getTime()
                )
                /
                millisecondsPerDay
            ) + 1;


        if (
            totalDays === 1
        ) {


            durationPreview.innerHTML =
                "<strong>Cuti sehari.</strong> "
                + "Tarikh mula dan tarikh akhir adalah sama.";


        } else {


            durationPreview.innerHTML =
                "<strong>"
                + totalDays
                + " hari.</strong> "
                + "Semua tarikh dalam tempoh ini akan dianggap sebagai cuti umum.";
        }


        durationPreview.classList.add(
            "show"
        );
    }


    // =========================================================
    // AUTO END DATE
    //
    // When adding new holiday:
    // first selection of start date automatically sets
    // end date to same day.
    // =========================================================

    startDate.addEventListener(
        "change",
        function() {


            if (
                formAction.value === "add"
                &&
                startDate.value
                &&
                !endDate.value
            ) {

                endDate.value =
                    startDate.value;
            }


            if (
                startDate.value
            ) {

                endDate.min =
                    startDate.value;
            }


            updateDurationPreview();
        }
    );


    endDate.addEventListener(
        "change",
        updateDurationPreview
    );


    // =========================================================
    // EDIT
    // =========================================================

    function editHoliday(
        id,
        name,
        start,
        end,
        desc
    ) {


        formAction.value =
            "update";


        holidayId.value =
            id;


        holidayName.value =
            name;


        startDate.value =
            start;


        endDate.value =
            end;


        endDate.min =
            start;


        description.value =
            desc;


        formTitle.textContent =
            "Kemas Kini Cuti Umum";


        formDescription.textContent =
            "Kemas kini nama dan tempoh cuti umum yang dipilih.";


        submitFormButton.textContent =
            "Simpan Perubahan";


        cancelEditButton.style.display =
            "";


        updateDurationPreview();


        holidayName.focus();


        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
    }


    // =========================================================
    // RESET
    // =========================================================

    function resetHolidayForm() {


        holidayForm.reset();


        formAction.value =
            "add";


        holidayId.value =
            "";


        endDate.min =
            "";


        durationPreview.classList.remove(
            "show"
        );


        durationPreview.textContent =
            "";


        formTitle.textContent =
            "Tambah Cuti Umum";


        formDescription.textContent =
            "Untuk cuti sehari, gunakan tarikh mula dan tarikh akhir yang sama.";


        submitFormButton.textContent =
            "Tambah Cuti Umum";


        cancelEditButton.style.display =
            "none";
    }


    // =========================================================
    // FORM VALIDATION
    // =========================================================

    holidayForm.addEventListener(
        "submit",
        function(event) {


            if (
                !startDate.value ||
                !endDate.value
            ) {

                event.preventDefault();


                alert(
                    "Sila pilih tarikh mula dan tarikh akhir."
                );


                return;
            }


            const start =
                new Date(
                    startDate.value
                    + "T00:00:00"
                );


            const end =
                new Date(
                    endDate.value
                    + "T00:00:00"
                );


            if (
                end < start
            ) {


                event.preventDefault();


                alert(
                    "Tarikh akhir tidak boleh lebih awal daripada tarikh mula."
                );


                return;
            }
        }
    );


    // =========================================================
    // DELETE CONFIRMATION
    // =========================================================

    function confirmDeleteHoliday(
        name
    ) {


        return confirm(
            "Padam rekod cuti umum \""
            + name
            + "\"?\n\n"
            + "Rekod yang dipadam tidak lagi digunakan dalam pengiraan cuti."
        );
    }


    // =========================================================
    // SEARCH
    // =========================================================

    const holidaySearch =
        document.getElementById(
            "holidaySearch"
        );


    const resultCount =
        document.getElementById(
            "resultCount"
        );


    if (holidaySearch) {


        holidaySearch.addEventListener(
            "input",
            function() {


                const keyword =
                    holidaySearch
                        .value
                        .trim()
                        .toLowerCase();


                const rows =
                    document.querySelectorAll(
                        ".holiday-row"
                    );


                let visible =
                    0;


                rows.forEach(
                    function(row) {


                        const searchText =
                            row.dataset.search || "";


                        const show =
                            !keyword ||
                            searchText.includes(
                                keyword
                            );


                        row.style.display =
                            show
                                ? ""
                                : "none";


                        if (show) {
                            visible++;
                        }
                    }
                );


                if (resultCount) {

                    resultCount.textContent =
                        visible
                        + " rekod";
                }
            }
        );
    }

</script>


</body>

</html>