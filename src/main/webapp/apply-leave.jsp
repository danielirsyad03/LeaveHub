<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

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


    private int wholeDays(Object value) {

        if (value == null) {
            return 0;
        }

        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        try {

            return Integer.parseInt(
                value.toString().trim()
            );

        } catch (Exception e) {

            return 0;
        }
    }


    private String departmentName(
            String department) {

        if (
            department == null ||
            department.isBlank()
        ) {
            return "—";
        }

        switch (department) {

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


    /*
     * Jenis cuti yang tidak mempunyai kuota.
     *
     * Cuti Tanpa Rekod
     * Cuti Tanpa Gaji
     * Lain-lain
     */
    private boolean hideBalance(
            String leaveTypeName) {

        if (leaveTypeName == null) {
            return false;
        }

        String name =
            leaveTypeName.trim();

        return
            "Cuti Tanpa Rekod".equalsIgnoreCase(name)
            ||
            "Cuti Tanpa Gaji".equalsIgnoreCase(name)
            ||
            "Lain-lain".equalsIgnoreCase(name);
    }
%>


<%
    // =========================================================
    // LOGIN CHECK
    // =========================================================

    if (
        session.getAttribute("userId") == null
    ) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    // =========================================================
    // USER
    // =========================================================

    String name =

        request.getAttribute("staffName") == null

            ? (String) session.getAttribute(
                "userName"
            )

            : request.getAttribute(
                "staffName"
            ).toString();


    if (
        name == null ||
        name.isBlank()
    ) {
        name = "Pengguna";
    }


    String position =

        request.getAttribute("position") == null

            ? ""

            : request.getAttribute(
                "position"
            ).toString();


    String department =

        request.getAttribute("department") == null

            ? ""

            : request.getAttribute(
                "department"
            ).toString();


    // =========================================================
    // LEAVE TYPES
    // =========================================================

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> leaveTypes =

        (List<Map<String, Object>>)
        request.getAttribute(
            "leaveTypes"
        );


    // =========================================================
    // PUBLIC HOLIDAYS
    // =========================================================

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> publicHolidays =

        (List<Map<String, Object>>)
        request.getAttribute(
            "publicHolidays"
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
        Permohonan Cuti - PKB
    </title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260927-unified"
    >


    <style>

        /* =====================================================
           PAGE
           ===================================================== */

        .leave-page-wrap {
            width: 100%;
            max-width: 1180px;
            min-width: 0;
            box-sizing: border-box;
        }


        /* =====================================================
           PAGE INTRO
           ===================================================== */

        .leave-page-intro {
            margin-bottom: 20px;
            min-width: 0;
        }

        .leave-page-intro h1 {
            margin: 0 0 5px;
            font-size: 26px;
            line-height: 1.25;
            font-weight: 700;
            color: #172033;
            letter-spacing: -0.35px;
        }

        .leave-page-intro p {
            margin: 0;
            color: #7c8597;
            font-size: 14px;
            line-height: 1.5;
            font-weight: 400;
        }


        /* =====================================================
           FORM CARD
           ===================================================== */

        .leave-form-shell {

            width: 100%;
            min-width: 0;

            background: #ffffff;

            border:
                1px solid #e7e9ef;

            border-radius: 16px;

            box-shadow:
                0 8px 28px
                rgba(31, 41, 61, 0.055);

            overflow: hidden;

            box-sizing: border-box;
        }


        /* =====================================================
           SECTION
           ===================================================== */

        .form-section {

            padding: 24px 26px;

            border-bottom:
                1px solid #eef0f4;

            box-sizing: border-box;

            min-width: 0;
        }

        .form-section:last-of-type {
            border-bottom: 0;
        }


        .form-section-header {

            display: flex;

            align-items: flex-start;

            gap: 12px;

            margin-bottom: 20px;
        }


        .section-icon {

            width: 38px;
            height: 38px;
            min-width: 38px;

            border-radius: 11px;

            display: grid;

            place-items: center;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff7e8
                );

            color: #8d1f2d;

            border:
                1px solid #f0dce0;

            font-size: 17px;

            font-weight: 700;
        }


        .form-section-title {
            min-width: 0;
        }

        .form-section-title h3 {

            margin: 0 0 4px;

            font-size: 16px;

            line-height: 1.4;

            font-weight: 600;

            color: #172033;
        }


        .form-section-title p {

            margin: 0;

            color: #8790a0;

            font-size: 13px;

            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           STAFF INFO
           ===================================================== */

        .staff-info {

            display: grid;

            grid-template-columns:
                repeat(
                    3,
                    minmax(0, 1fr)
                );

            gap: 14px;

            min-width: 0;
        }


        .staff-info-item {

            position: relative;

            min-width: 0;

            padding: 15px 16px;

            border:
                1px solid #e8eaf0;

            border-radius: 12px;

            background:
                linear-gradient(
                    145deg,
                    #ffffff,
                    #fbfbfc
                );

            box-sizing: border-box;
        }


        .staff-info-item::before {

            content: "";

            position: absolute;

            left: 0;

            top: 13px;

            bottom: 13px;

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


        .staff-info-item span {

            display: block;

            margin-bottom: 5px;

            color: #8b94a4;

            font-size: 11px;

            font-weight: 600;

            text-transform: uppercase;

            letter-spacing: .35px;
        }


        .staff-info-item strong {

            display: block;

            color: #273044;

            font-size: 14px;

            line-height: 1.45;

            font-weight: 600;

            overflow-wrap: anywhere;
        }


        /* =====================================================
           GRID
           ===================================================== */

        .form-grid {

            display: grid;

            grid-template-columns:
                repeat(
                    2,
                    minmax(0, 1fr)
                );

            gap: 18px;

            min-width: 0;
        }


        .field-full {
            grid-column: 1 / -1;
        }


        /* =====================================================
           FIELD
           ===================================================== */

        .field {
            min-width: 0;
        }


        .field label {

            display: block;

            margin-bottom: 7px;

            color: #434d60;

            font-size: 13px;

            line-height: 1.4;

            font-weight: 600;
        }


        .field input,
        .field select,
        .field textarea {

            width: 100%;

            max-width: 100%;

            box-sizing: border-box;

            border:
                1px solid #dfe3ea;

            border-radius: 10px;

            background: #ffffff;

            color: #172033;

            font-family: inherit;

            font-size: 14px;

            font-weight: 400;

            outline: none;

            transition:
                border-color .18s ease,
                box-shadow .18s ease,
                background .18s ease;
        }


        .field input,
        .field select {

            height: 44px;

            padding: 0 13px;
        }


        .field textarea {

            min-height: 105px;

            padding: 12px 13px;

            resize: vertical;

            line-height: 1.5;
        }


        .field input:hover,
        .field select:hover,
        .field textarea:hover {

            border-color: #cfd4dc;
        }


        .field input:focus,
        .field select:focus,
        .field textarea:focus {

            border-color: #a74654;

            box-shadow:
                0 0 0 3px
                rgba(141, 31, 45, .08);
        }


        .field input[readonly] {

            background: #f7f8fa;

            color: #535d70;

            font-weight: 500;
        }


        .field-help {

            margin-top: 6px;

            color: #8a93a4;

            font-size: 12px;

            line-height: 1.5;
        }


        /* =====================================================
           DURATION
           ===================================================== */

        .duration-field {
            position: relative;
        }


        /* =====================================================
           HOLIDAY
           ===================================================== */

        .holiday-info {

            display: none;

            margin-top: 9px;

            padding: 11px 13px;

            border:
                1px solid #ead9ad;

            border-radius: 9px;

            background: #fff9eb;

            color: #75570f;

            font-size: 12px;

            line-height: 1.5;
        }

        .holiday-info.show {
            display: block;
        }


        /* =====================================================
           SELECTED TYPE
           ===================================================== */

        .selected-type-box {

            display: flex;

            align-items: center;

            justify-content:
                space-between;

            gap: 15px;

            margin-bottom: 16px;

            padding: 14px 16px;

            border:
                1px solid #eadde0;

            border-radius: 12px;

            background:
                linear-gradient(
                    135deg,
                    #fff7f8,
                    #fffaf1
                );
        }


        .selected-type-box span {

            color: #7a8394;

            font-size: 12px;
        }


        .selected-type-box strong {

            display: block;

            margin-top: 3px;

            color: #8d1f2d;

            font-size: 16px;

            line-height: 1.4;

            font-weight: 600;
        }


        .selected-type-badge {

            flex-shrink: 0;

            padding: 6px 10px;

            border-radius: 999px;

            background: #8d1f2d;

            color: #ffffff !important;

            font-size: 10px !important;

            font-weight: 600;

            letter-spacing: .35px;
        }


        /* =====================================================
           BALANCE
           ===================================================== */

        .balance-summary {

            display: grid;

            grid-template-columns:
                repeat(
                    3,
                    minmax(0, 1fr)
                );

            gap: 13px;

            margin-bottom: 17px;
        }


        .balance-box {

            position: relative;

            min-height: 108px;

            padding: 16px;

            border:
                1px solid #e6e9ef;

            border-radius: 13px;

            background: #ffffff;

            overflow: hidden;

            box-sizing: border-box;
        }


        .balance-box::before {

            content: "";

            position: absolute;

            left: 0;

            top: 0;

            right: 0;

            height: 3px;

            background:
                linear-gradient(
                    90deg,
                    #8d1f2d,
                    #d5a12b
                );
        }


        .balance-box span {

            display: block;

            margin-bottom: 12px;

            color: #858e9f;

            font-size: 11px;

            font-weight: 600;

            text-transform: uppercase;

            letter-spacing: .35px;
        }


        .balance-value {

            display: flex;

            align-items: baseline;

            gap: 5px;
        }


        .balance-box strong {

            color: #172033;

            font-size: 27px;

            line-height: 1;

            font-weight: 700;
        }


        .balance-box small {

            color: #8b94a4;

            font-size: 11px;
        }


        /* =====================================================
           ALERTS
           ===================================================== */

        .balance-warning,
        .balance-not-configured,
        .no-balance-info,
        .document-required {

            display: none;

            margin-bottom: 15px;

            padding: 12px 14px;

            border-radius: 10px;

            font-size: 12px;

            line-height: 1.5;
        }


        .balance-warning.show,
        .balance-not-configured.show,
        .no-balance-info.show,
        .document-required.show {

            display: block;
        }


        .balance-warning {

            background: #fff0f2;

            color: #a52b38;

            border:
                1px solid #f0cfd4;
        }


        .balance-not-configured {

            background: #fff6e4;

            color: #8e650f;

            border:
                1px solid #f2e0b5;
        }


        .no-balance-info {

            background:
                linear-gradient(
                    135deg,
                    #fff7f8,
                    #fffaf3
                );

            color: #6f5960;

            border:
                1px solid #eadcdf;
        }


        .document-required {

            margin-top: 10px;

            margin-bottom: 0;

            background: #fff6e4;

            color: #85600d;

            border:
                1px solid #f0deb0;
        }


        /* =====================================================
           UPLOAD
           ===================================================== */

        .upload-wrap {

            position: relative;

            padding: 18px;

            border:
                1.5px dashed #d9dde5;

            border-radius: 12px;

            background: #fafbfc;

            transition:
                border-color .18s ease,
                background .18s ease;
        }


        .upload-wrap:hover {

            border-color: #b55c68;

            background: #fffafa;
        }


        .upload-heading {

            margin-bottom: 9px;

            color: #4e586a;

            font-size: 13px;

            font-weight: 600;
        }


        .upload-wrap input[type="file"] {

            width: 100%;

            height: auto;

            padding: 7px;

            border: 0;

            background: transparent;

            box-shadow: none;
        }


        .upload-note {

            margin-top: 7px;

            color: #8b94a3;

            font-size: 12px;

            line-height: 1.5;
        }


        /* =====================================================
           ACTION BAR
           ===================================================== */

        .form-actions {

            display: flex;

            align-items: center;

            justify-content: flex-end;

            gap: 10px;

            padding: 19px 26px;

            background:
                linear-gradient(
                    180deg,
                    #ffffff,
                    #fbfbfc
                );
        }


        .form-actions .btn {

            min-width: 120px;

            min-height: 42px;

            padding: 10px 18px;

            display: inline-flex;

            align-items: center;

            justify-content: center;

            box-sizing: border-box;

            border-radius: 9px;

            font-family: inherit;

            font-size: 13px;

            font-weight: 600;

            text-decoration: none;

            cursor: pointer;

            transition:
                background .18s ease,
                border-color .18s ease,
                color .18s ease,
                transform .18s ease;
        }


        .submit-btn {

            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a72a3b
                ) !important;

            border:
                1px solid #8d1f2d !important;

            color:
                #ffffff !important;

            box-shadow:
                0 6px 16px
                rgba(141, 31, 45, .18)
                !important;
        }


        .submit-btn:hover {

            background:
                linear-gradient(
                    135deg,
                    #711722,
                    #8d1f2d
                ) !important;

            transform:
                translateY(-1px);
        }


        .submit-btn:disabled {

            cursor: not-allowed;

            opacity: .55;

            transform: none !important;

            box-shadow: none !important;
        }


        .cancel-btn {

            background:
                #ffffff !important;

            color:
                #667085 !important;

            border:
                1px solid #dce0e7
                !important;
        }


        .cancel-btn:hover {

            color:
                #8d1f2d !important;

            border-color:
                #dab7bd !important;

            background:
                #fff8f8 !important;
        }


        /* =====================================================
           ERROR
           ===================================================== */

        .error-box {

            margin-bottom: 18px;

            padding: 13px 15px;

            border-radius: 11px;

            background: #fff0f2;

            color: #aa2c39;

            border:
                1px solid #efcdd2;

            font-size: 13px;

            line-height: 1.5;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 900px) {

            .staff-info,
            .balance-summary {

                grid-template-columns:
                    1fr;
            }

            .form-grid {

                grid-template-columns:
                    1fr;
            }

            .field-full {
                grid-column: auto;
            }
        }


        @media (max-width: 700px) {

            .leave-page-intro h1 {
                font-size: 23px;
            }

            .form-section {

                padding: 20px 18px;
            }

            .form-actions {

                padding: 16px 18px;

                flex-direction:
                    column-reverse;
            }

            .form-actions .btn {

                width: 100%;
            }

            .selected-type-box {

                align-items:
                    flex-start;

                flex-direction:
                    column;
            }
        }

    </style>

</head>


<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="leave-page-wrap">


            <!-- =================================================
                 TOPBAR
                 ================================================= -->

            <div class="topbar">

                <div class="leave-page-intro">

                    <h1>
                        Permohonan Cuti
                    </h1>

                    <p>
                        Lengkapkan maklumat permohonan cuti anda
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
                 ERROR
                 ================================================= -->

            <% if (error != null) { %>

                <div class="error-box">

                    <%

                        if (
                            "balanceNotConfigured".equals(error)
                        ) {

                            out.print(
                                "Baki bagi jenis cuti yang dipilih belum ditetapkan oleh Pentadbir Sistem."
                            );

                        } else if (
                            "insufficientBalance".equals(error)
                        ) {

                            out.print(
                                "Baki cuti anda tidak mencukupi untuk tempoh yang dipohon."
                            );

                        } else if (
                            "invalidLeaveType".equals(error)
                        ) {

                            out.print(
                                "Jenis cuti yang dipilih tidak sah atau tidak lagi aktif."
                            );

                        } else if (
                            "otherLeaveType".equals(error)
                        ) {

                            out.print(
                                "Sila nyatakan jenis cuti bagi pilihan Lain-lain."
                            );

                        } else if (
                            "documentRequired".equals(error)
                        ) {

                            out.print(
                                "Lampiran dokumen sokongan wajib disertakan bagi jenis cuti yang dipilih."
                            );

                        } else if (
                            "crossYear".equals(error)
                        ) {

                            out.print(
                                "Permohonan cuti tidak boleh merentasi dua tahun. Sila buat permohonan berasingan bagi setiap tahun."
                            );

                        } else if (
                            "overlap".equals(error)
                        ) {

                            out.print(
                                "Tarikh permohonan bertindih dengan permohonan cuti lain."
                            );

                        } else if (
                            "date".equals(error)
                        ) {

                            out.print(
                                "Tarikh permohonan tidak sah."
                            );

                        } else if (
                            "duration".equals(error)
                        ) {

                            out.print(
                                "Tempoh cuti tidak mempunyai hari bekerja yang sah kerana semua tarikh yang dipilih ialah Jumaat, Sabtu atau cuti umum."
                            );

                        } else if (
                            "file".equals(error)
                        ) {

                            out.print(
                                "Lampiran tidak sah. Gunakan PDF, JPG, JPEG, PNG, DOC atau DOCX dengan saiz maksimum 5MB."
                            );

                        } else {

                            out.print(
                                "Sila lengkapkan maklumat permohonan dengan betul."
                            );
                        }

                    %>

                </div>

            <% } %>


            <div class="leave-form-shell">

                <form
                    method="post"
                    action="<%= request.getContextPath() %>/apply"
                    enctype="multipart/form-data"
                    id="leaveForm"
                >


                    <!-- =========================================
                         MAKLUMAT PEMOHON
                         ========================================= -->

                    <section class="form-section">

                        <div class="form-section-header">

                            <div class="section-icon">
                                ◉
                            </div>

                            <div class="form-section-title">

                                <h3>
                                    Maklumat Pemohon
                                </h3>

                                <p>
                                    Maklumat ini diambil daripada profil pengguna anda.
                                </p>

                            </div>

                        </div>


                        <div class="staff-info">

                            <div class="staff-info-item">

                                <span>
                                    Nama
                                </span>

                                <strong>
                                    <%= htmlEscape(name) %>
                                </strong>

                            </div>


                            <div class="staff-info-item">

                                <span>
                                    Jawatan
                                </span>

                                <strong>

                                    <%=
                                        position == null ||
                                        position.isBlank()

                                            ? "—"

                                            : htmlEscape(
                                                position
                                            )
                                    %>

                                </strong>

                            </div>


                            <div class="staff-info-item">

                                <span>
                                    Bahagian
                                </span>

                                <strong>

                                    <%= htmlEscape(
                                        departmentName(
                                            department
                                        )
                                    ) %>

                                </strong>

                            </div>

                        </div>

                    </section>


                    <!-- =========================================
                         MAKLUMAT CUTI
                         ========================================= -->

                    <section class="form-section">

                        <div class="form-section-header">

                            <div class="section-icon">
                                ◷
                            </div>

                            <div class="form-section-title">

                                <h3>
                                    Maklumat Cuti
                                </h3>

                                <p>
                                    Pilih jenis cuti dan tetapkan tarikh permohonan.
                                </p>

                            </div>

                        </div>


                        <div class="form-grid">


                            <div class="field field-full">

                                <label for="leaveTypeId">
                                    Jenis Cuti *
                                </label>

                                <select
                                    name="leaveTypeId"
                                    id="leaveTypeId"
                                    required
                                >

                                    <option
                                        value=""
                                        data-name=""
                                        data-balance="0"
                                        data-configured="false"
                                        data-hide-balance="false"
                                        data-requires-document="false"
                                    >
                                        Pilih Jenis Cuti
                                    </option>

                                    <%

                                        if (leaveTypes != null) {

                                            for (
                                                Map<String, Object> type :
                                                leaveTypes
                                            ) {

                                                Object idObject =
                                                    type.get(
                                                        "leaveTypeId"
                                                    );

                                                String typeName =

                                                    type.get(
                                                        "leaveTypeName"
                                                    ) == null

                                                        ? ""

                                                        : type.get(
                                                            "leaveTypeName"
                                                        ).toString();


                                                int remaining =

                                                    wholeDays(
                                                        type.get(
                                                            "remainingDays"
                                                        )
                                                    );


                                                boolean configured =

                                                    Boolean.TRUE.equals(
                                                        type.get(
                                                            "balanceConfigured"
                                                        )
                                                    );


                                                boolean requiresDocument =

                                                    Boolean.TRUE.equals(
                                                        type.get(
                                                            "requiresDocument"
                                                        )
                                                    );


                                                boolean balanceHidden =

                                                    hideBalance(
                                                        typeName
                                                    );

                                    %>

                                    <option
                                        value="<%= htmlEscape(idObject) %>"
                                        data-name="<%= htmlEscape(typeName) %>"
                                        data-balance="<%= remaining %>"
                                        data-configured="<%= configured %>"
                                        data-hide-balance="<%= balanceHidden %>"
                                        data-requires-document="<%= requiresDocument %>"
                                    >

                                        <%= htmlEscape(typeName) %>

                                        <% if (!balanceHidden) { %>

                                            — Baki:
                                            <%= remaining %>
                                            hari

                                        <% } %>

                                    </option>

                                    <%
                                            }
                                        }
                                    %>

                                </select>

                            </div>


                            <div
                                class="field field-full"
                                id="otherLeaveField"
                                style="display:none;"
                            >

                                <label for="otherLeaveType">
                                    Nyatakan Jenis Cuti *
                                </label>

                                <input
                                    type="text"
                                    name="otherLeaveType"
                                    id="otherLeaveType"
                                    maxlength="100"
                                    placeholder="Contoh: Cuti khas"
                                >

                            </div>


                            <div class="field">

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


                            <div class="field">

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


                            <div
                                class="field field-full duration-field"
                            >

                                <label>
                                    Jumlah Hari Bekerja
                                </label>

                                <input
                                    type="text"
                                    id="durationDisplay"
                                    value="0 hari"
                                    readonly
                                >

                                <input
                                    type="hidden"
                                    name="workingDays"
                                    id="workingDays"
                                    value="0"
                                >

                                <div class="field-help">
                                    Jumaat, Sabtu dan cuti umum
                                    tidak dikira sebagai hari bekerja.
                                </div>

                                <div
                                    id="holidayInfo"
                                    class="holiday-info"
                                ></div>

                            </div>


                            <div class="field field-full">

                                <label for="reason">
                                    Alasan Untuk Bercuti *
                                </label>

                                <textarea
                                    name="reason"
                                    id="reason"
                                    rows="4"
                                    placeholder="Nyatakan alasan permohonan cuti"
                                    required
                                ></textarea>

                            </div>

                        </div>

                    </section>


                    <!-- =========================================
                         MAKLUMAT SEMASA CUTI
                         ========================================= -->

                    <section class="form-section">

                        <div class="form-section-header">

                            <div class="section-icon">
                                ☎
                            </div>

                            <div class="form-section-title">

                                <h3>
                                    Maklumat Semasa Cuti
                                </h3>

                                <p>
                                    Maklumat untuk dihubungi dan serahan tugas sepanjang tempoh cuti.
                                </p>

                            </div>

                        </div>


                        <div class="form-grid">

                            <div class="field">

                                <label for="contactPhone">
                                    No. Telefon
                                </label>

                                <input
                                    type="text"
                                    name="contactPhone"
                                    id="contactPhone"
                                    maxlength="50"
                                    placeholder="Contoh: 012-3456789"
                                >

                            </div>


                            <div class="field">

                                <label for="handoverStaffName">
                                    Tugas Ditanggung Oleh
                                </label>

                                <input
                                    type="text"
                                    name="handoverStaffName"
                                    id="handoverStaffName"
                                    maxlength="150"
                                    placeholder="Nama staf yang mengambil alih tugas"
                                >

                            </div>


                            <div class="field field-full">

                                <label for="contactAddress">
                                    Alamat Ketika Cuti
                                </label>

                                <textarea
                                    name="contactAddress"
                                    id="contactAddress"
                                    rows="3"
                                    placeholder="Masukkan alamat semasa cuti"
                                ></textarea>

                            </div>


                            <div class="field field-full">

                                <label for="attachment">

                                    Lampiran

                                    <span
                                        id="attachmentStar"
                                        style="display:none;color:#b32636;"
                                    >
                                        *
                                    </span>

                                </label>


                                <div class="upload-wrap">

                                    <div class="upload-heading">
                                        Dokumen Sokongan
                                    </div>

                                    <input
                                        type="file"
                                        name="attachment"
                                        id="attachment"
                                        accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                                    >

                                    <div class="upload-note">
                                        Format: PDF, JPG, JPEG,
                                        PNG, DOC atau DOCX •
                                        Maksimum 5MB
                                    </div>

                                </div>


                                <div
                                    id="documentRequiredMessage"
                                    class="document-required"
                                >
                                    Dokumen sokongan wajib
                                    disertakan bagi jenis cuti ini.
                                </div>

                            </div>

                        </div>

                    </section>


                    <!-- =========================================
                         ACTION
                         ========================================= -->

                    <div class="form-actions">

                        <a
                            href="<%= request.getContextPath() %>/applications"
                            class="btn cancel-btn"
                        >
                            Batal
                        </a>

                        <button
                            type="submit"
                            class="btn submit-btn"
                            id="submitButton"
                        >
                            Hantar Permohonan
                        </button>

                    </div>

                </form>

            </div>

        </div>

    </main>

</div><!-- =========================================================
     JAVASCRIPT DATA
     ========================================================= -->

<script>

    // =========================================================
    // PUBLIC HOLIDAYS FROM SERVER
    // =========================================================

    const publicHolidays = [

        <%
            if (
                publicHolidays != null
                &&
                !publicHolidays.isEmpty()
            ) {

                boolean firstHoliday = true;

                for (
                    Map<String, Object> holiday :
                    publicHolidays
                ) {

                    String holidayDate =
                        holiday.get("holidayDate") == null
                            ? ""
                            : holiday.get(
                                "holidayDate"
                            ).toString();

                    String holidayName =
                        holiday.get("holidayName") == null
                            ? "Cuti Umum"
                            : holiday.get(
                                "holidayName"
                            ).toString();

                    if (!firstHoliday) {
                        out.print(",");
                    }

                    firstHoliday = false;
        %>

        {
            date:
                "<%= htmlEscape(holidayDate) %>",

            name:
                "<%= htmlEscape(holidayName) %>"
        }

        <%
                }
            }
        %>

    ];


    // =========================================================
    // DOM READY
    // =========================================================

    document.addEventListener(
        "DOMContentLoaded",
        function () {

            // =================================================
            // ELEMENTS
            // =================================================

            const leaveForm =
                document.getElementById(
                    "leaveForm"
                );

            const leaveTypeSelect =
                document.getElementById(
                    "leaveTypeId"
                );

            const otherLeaveField =
                document.getElementById(
                    "otherLeaveField"
                );

            const otherLeaveType =
                document.getElementById(
                    "otherLeaveType"
                );

            const startDate =
                document.getElementById(
                    "startDate"
                );

            const endDate =
                document.getElementById(
                    "endDate"
                );

            const durationDisplay =
                document.getElementById(
                    "durationDisplay"
                );

            const holidayInfo =
                document.getElementById(
                    "holidayInfo"
                );

            const selectedLeaveType =
                document.getElementById(
                    "selectedLeaveType"
                );

            const balanceSummary =
                document.getElementById(
                    "balanceSummary"
                );

            const balanceBeforeDisplay =
                document.getElementById(
                    "balanceBeforeDisplay"
                );

            const requestedDaysDisplay =
                document.getElementById(
                    "requestedDaysDisplay"
                );

            const balanceAfterDisplay =
                document.getElementById(
                    "balanceAfterDisplay"
                );

            const balanceWarning =
                document.getElementById(
                    "balanceWarning"
                );

            const balanceNotConfigured =
                document.getElementById(
                    "balanceNotConfigured"
                );

            const noBalanceInfo =
                document.getElementById(
                    "noBalanceInfo"
                );

            const attachment =
                document.getElementById(
                    "attachment"
                );

            const attachmentStar =
                document.getElementById(
                    "attachmentStar"
                );

            const documentRequiredMessage =
                document.getElementById(
                    "documentRequiredMessage"
                );

            const submitButton =
                document.getElementById(
                    "submitButton"
                );


            // =================================================
            // STATE
            // =================================================

            let calculatedWorkingDays = 0;

            let selectedBalance = 0;

            let selectedBalanceConfigured = false;

            let selectedHideBalance = false;

            let selectedRequiresDocument = false;


            // =================================================
            // DATE FORMAT
            // =================================================

            function formatDateForInput(date) {

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
                    + "-"
                    + month
                    + "-"
                    + day
                );
            }


            // =================================================
            // TODAY
            // =================================================

            const today =
                new Date();


            today.setHours(
                0,
                0,
                0,
                0
            );


            const todayString =
                formatDateForInput(
                    today
                );


            // =================================================
            // PARSE YYYY-MM-DD SAFELY
            // =================================================

            function parseDate(value) {

                if (!value) {
                    return null;
                }


                const parts =
                    value.split("-");


                if (parts.length !== 3) {
                    return null;
                }


                const year =
                    Number(parts[0]);

                const month =
                    Number(parts[1]);

                const day =
                    Number(parts[2]);


                if (
                    !Number.isInteger(year)
                    ||
                    !Number.isInteger(month)
                    ||
                    !Number.isInteger(day)
                ) {

                    return null;
                }


                const date =
                    new Date(
                        year,
                        month - 1,
                        day
                    );


                date.setHours(
                    0,
                    0,
                    0,
                    0
                );


                return date;
            }


            // =================================================
            // DATE TO KEY
            // =================================================

            function dateKey(date) {

                return formatDateForInput(
                    date
                );
            }


            // =================================================
            // HOLIDAY MAP
            // =================================================

            const holidayMap =
                new Map();


            publicHolidays.forEach(
                function (holiday) {

                    if (
                        holiday
                        &&
                        holiday.date
                    ) {

                        const normalizedHolidayDate =
                            normalizeHolidayDate(
                                holiday.date
                            );

                        if (normalizedHolidayDate) {
                            holidayMap.set(
                                normalizedHolidayDate,
                                holiday.name
                                    ? holiday.name
                                    : "Cuti Umum"
                            );
                        }
                    }
                }
            );


            // =================================================
            // NORMALIZE PUBLIC HOLIDAY DATE
            // Supports yyyy-MM-dd and dd/MM/yyyy
            // =================================================

            function normalizeHolidayDate(value) {

                if (!value) {
                    return "";
                }

                const raw = String(value).trim();

                // Already in HTML date format: yyyy-MM-dd
                if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
                    return raw;
                }

                // Display/database alternative: dd/MM/yyyy
                if (/^\d{2}\/\d{2}\/\d{4}$/.test(raw)) {

                    const parts = raw.split("/");

                    return (
                        parts[2]
                        + "-"
                        + parts[1]
                        + "-"
                        + parts[0]
                    );
                }

                // Fallback for date-time strings beginning yyyy-MM-dd
                const match = raw.match(/^(\d{4}-\d{2}-\d{2})/);

                return match ? match[1] : "";
            }


            // =================================================
            // IS WEEKEND
            //
            // PKB:
            // Friday = off
            // Saturday = off
            // =================================================

            function isWeekend(date) {

                const day =
                    date.getDay();


                return (
                    day === 5
                    ||
                    day === 6
                );
            }


            // =================================================
            // IS PUBLIC HOLIDAY
            // =================================================

            function isPublicHoliday(date) {

                return holidayMap.has(
                    dateKey(date)
                );
            }


            // =================================================
            // CALCULATE WORKING DAYS
            // =================================================

            function calculateWorkingDays() {

                calculatedWorkingDays = 0;


                if (
                    !startDate
                    ||
                    !endDate
                    ||
                    !startDate.value
                    ||
                    !endDate.value
                ) {

                    if (durationDisplay) {

                        durationDisplay.value =
                            "0 hari";
                    }

                    const workingDaysInput =
                        document.getElementById(
                            "workingDays"
                        );

                    if (workingDaysInput) {
                        workingDaysInput.value = "0";
                    }


                    if (holidayInfo) {

                        holidayInfo.classList.remove(
                            "show"
                        );

                        holidayInfo.innerHTML =
                            "";
                    }


                    updateBalanceDisplay();

                    return;
                }


                const start =
                    parseDate(
                        startDate.value
                    );

                const end =
                    parseDate(
                        endDate.value
                    );


                if (
                    !start
                    ||
                    !end
                    ||
                    end < start
                ) {

                    if (durationDisplay) {

                        durationDisplay.value =
                            "0 hari";
                    }


                    calculatedWorkingDays = 0;

                    const workingDaysInput =
                        document.getElementById(
                            "workingDays"
                        );

                    if (workingDaysInput) {
                        workingDaysInput.value = "0";
                    }

                    if (holidayInfo) {
                        holidayInfo.innerHTML = "";
                        holidayInfo.classList.remove(
                            "show"
                        );
                    }

                    updateBalanceDisplay();

                    return;
                }


                let current =
                    new Date(
                        start.getTime()
                    );


                const excludedDates = [];


                while (current <= end) {

                    const key =
                        dateKey(
                            current
                        );


                    const weekend =
                        isWeekend(
                            current
                        );

                    const holiday =
                        isPublicHoliday(
                            current
                        );


                    if (
                        !weekend
                        &&
                        !holiday
                    ) {

                        calculatedWorkingDays++;

                    } else {

                        if (holiday) {

                            excludedDates.push({
                                date: key,
                                name:
                                    holidayMap.get(
                                        key
                                    )
                            });
                        }
                    }


                    current.setDate(
                        current.getDate() + 1
                    );
                }


                if (durationDisplay) {

                    durationDisplay.value =
                        calculatedWorkingDays
                        + " hari";
                }

                const workingDaysInput =
                    document.getElementById(
                        "workingDays"
                    );

                if (workingDaysInput) {

                    workingDaysInput.value =
                        calculatedWorkingDays;
                }


                // =============================================
                // HOLIDAY INFO
                // =============================================

                if (holidayInfo) {

                    if (
                        excludedDates.length > 0
                    ) {

                        let html =
                            "<strong>Cuti umum dalam tempoh dipilih:</strong><br>";


                        excludedDates.forEach(
                            function (
                                holiday,
                                index
                            ) {

                                html +=
                                    escapeHtml(
                                        holiday.name
                                    )
                                    + " ("
                                    + escapeHtml(
                                        formatDisplayDate(
                                            holiday.date
                                        )
                                    )
                                    + ")";


                                if (
                                    index <
                                    excludedDates.length - 1
                                ) {

                                    html += "<br>";
                                }
                            }
                        );


                        holidayInfo.innerHTML =
                            html;


                        holidayInfo.classList.add(
                            "show"
                        );

                    } else {

                        holidayInfo.innerHTML =
                            "";


                        holidayInfo.classList.remove(
                            "show"
                        );
                    }
                }


                updateBalanceDisplay();
            }


            // =================================================
            // FORMAT DISPLAY DATE
            // =================================================

            function formatDisplayDate(
                value
            ) {

                const date =
                    parseDate(
                        value
                    );


                if (!date) {
                    return value;
                }


                return date.toLocaleDateString(
                    "ms-MY",
                    {
                        day: "2-digit",
                        month: "2-digit",
                        year: "numeric"
                    }
                );
            }


            // =================================================
            // LEAVE TYPE CHANGE
            // =================================================

            function updateLeaveType() {

                if (!leaveTypeSelect) {
                    return;
                }


                const selectedOption =
                    leaveTypeSelect.options[
                        leaveTypeSelect.selectedIndex
                    ];


                if (!selectedOption) {
                    return;
                }


                const leaveName =
                    (
                        selectedOption.dataset.name
                        ||
                        ""
                    ).trim();


                selectedBalance =
                    parseInt(
                        selectedOption.dataset.balance
                        ||
                        "0",
                        10
                    );


                if (
                    Number.isNaN(
                        selectedBalance
                    )
                ) {

                    selectedBalance = 0;
                }


                selectedBalanceConfigured =
                    selectedOption.dataset.configured
                    === "true";


                selectedHideBalance =
                    selectedOption.dataset.hideBalance
                    === "true";


                selectedRequiresDocument =
                    selectedOption.dataset.requiresDocument
                    === "true";


                // =============================================
                // SELECTED TYPE TEXT
                // =============================================

                if (selectedLeaveType) {

                    selectedLeaveType.textContent =
                        leaveName !== ""
                            ? leaveName
                            : "Belum dipilih";
                }


                // =============================================
                // OTHER LEAVE
                // =============================================

                const isOther =
                    leaveName.toLowerCase()
                    === "lain-lain";


                if (otherLeaveField) {

                    otherLeaveField.style.display =
                        isOther
                            ? ""
                            : "none";
                }


                if (otherLeaveType) {

                    otherLeaveType.required =
                        isOther;


                    if (!isOther) {

                        otherLeaveType.value =
                            "";
                    }
                }


                // =============================================
                // DOCUMENT
                // =============================================

                updateDocumentRequirement();


                // =============================================
                // BALANCE
                // =============================================

                updateBalanceDisplay();
            }


            // =================================================
            // DOCUMENT REQUIREMENT
            // =================================================

            function updateDocumentRequirement() {

                if (attachment) {

                    attachment.required =
                        selectedRequiresDocument;
                }


                if (attachmentStar) {

                    attachmentStar.style.display =
                        selectedRequiresDocument
                            ? "inline"
                            : "none";
                }


                if (documentRequiredMessage) {

                    if (selectedRequiresDocument) {

                        documentRequiredMessage
                            .classList.add(
                                "show"
                            );

                    } else {

                        documentRequiredMessage
                            .classList.remove(
                                "show"
                            );
                    }
                }
            }


            // =================================================
            // BALANCE DISPLAY
            // =================================================

            function updateBalanceDisplay() {

                const hasSelectedLeaveType =
                    leaveTypeSelect
                    &&
                    leaveTypeSelect.value !== "";


                // =============================================
                // NO QUOTA LEAVE
                // =============================================

                if (
                    hasSelectedLeaveType
                    &&
                    selectedHideBalance
                ) {

                    if (noBalanceInfo) {

                        noBalanceInfo.classList.add(
                            "show"
                        );
                    }


                    if (balanceSummary) {

                        balanceSummary.style.display =
                            "none";
                    }



                    if (balanceWarning) {

                        balanceWarning.classList.remove(
                            "show"
                        );
                    }


                    if (balanceNotConfigured) {

                        balanceNotConfigured.classList.remove(
                            "show"
                        );
                    }



                    updateSubmitButton();

                    return;
                }


                // =============================================
                // NORMAL QUOTA LEAVE
                // =============================================

                if (noBalanceInfo) {

                    noBalanceInfo.classList.remove(
                        "show"
                    );
                }


                if (balanceSummary) {

                    balanceSummary.style.display =
                        "";
                }



                // =============================================
                // VALUES
                // =============================================

                if (balanceBeforeDisplay) {

                    balanceBeforeDisplay.textContent =
                        selectedBalance;
                }


                if (requestedDaysDisplay) {

                    requestedDaysDisplay.textContent =
                        calculatedWorkingDays;
                }


                const after =
                    selectedBalance
                    -
                    calculatedWorkingDays;


                if (balanceAfterDisplay) {

                    balanceAfterDisplay.textContent =
                        after;
                }


                // =============================================
                // NOT CONFIGURED
                // =============================================

                if (
                    hasSelectedLeaveType
                    &&
                    !selectedBalanceConfigured
                ) {

                    if (balanceNotConfigured) {

                        balanceNotConfigured
                            .classList.add(
                                "show"
                            );
                    }

                } else {

                    if (balanceNotConfigured) {

                        balanceNotConfigured
                            .classList.remove(
                                "show"
                            );
                    }
                }


                // =============================================
                // INSUFFICIENT BALANCE
                // =============================================

                if (
                    hasSelectedLeaveType
                    &&
                    selectedBalanceConfigured
                    &&
                    calculatedWorkingDays > 0
                    &&
                    calculatedWorkingDays
                        > selectedBalance
                ) {

                    if (balanceWarning) {

                        balanceWarning.classList.add(
                            "show"
                        );
                    }

                } else {

                    if (balanceWarning) {

                        balanceWarning.classList.remove(
                            "show"
                        );
                    }
                }


                updateSubmitButton();
            }


            // =================================================
            // SUBMIT BUTTON STATE
            // =================================================

            function updateSubmitButton() {

                if (!submitButton) {
                    return;
                }


                let disabled = false;


                const hasSelectedLeaveType =
                    leaveTypeSelect
                    &&
                    leaveTypeSelect.value !== "";


                // =============================================
                // NORMAL QUOTA LEAVE
                // =============================================

                if (
                    hasSelectedLeaveType
                    &&
                    !selectedHideBalance
                ) {

                    if (
                        !selectedBalanceConfigured
                    ) {

                        disabled = true;
                    }


                    if (
                        calculatedWorkingDays > 0
                        &&
                        calculatedWorkingDays
                            > selectedBalance
                    ) {

                        disabled = true;
                    }
                }


                submitButton.disabled =
                    disabled;
            }


            // =================================================
            // DATE EVENTS
            // =================================================

            function handleStartDateChange() {

                if (
                    endDate
                    &&
                    startDate
                    &&
                    startDate.value
                ) {

                    endDate.min =
                        startDate.value;

                    // If end date is empty, use the selected start date
                    // so a one-day application immediately shows 1 day.
                    if (!endDate.value) {

                        endDate.value =
                            startDate.value;

                    } else if (
                        endDate.value
                        < startDate.value
                    ) {

                        endDate.value =
                            startDate.value;
                    }
                }

                calculateWorkingDays();
            }


            if (startDate) {

                startDate.addEventListener(
                    "change",
                    handleStartDateChange
                );

                startDate.addEventListener(
                    "input",
                    handleStartDateChange
                );
            }


            if (endDate) {

                endDate.addEventListener(
                    "change",
                    calculateWorkingDays
                );

                endDate.addEventListener(
                    "input",
                    calculateWorkingDays
                );
            }


            // =================================================
            // LEAVE TYPE EVENT
            // =================================================

            if (leaveTypeSelect) {

                leaveTypeSelect.addEventListener(
                    "change",
                    updateLeaveType
                );
            }


            // =================================================
            // FILE VALIDATION
            // =================================================

            if (attachment) {

                attachment.addEventListener(
                    "change",
                    function () {

                        attachment.setCustomValidity(
                            ""
                        );


                        if (
                            !attachment.files
                            ||
                            attachment.files.length === 0
                        ) {

                            return;
                        }


                        const file =
                            attachment.files[0];


                        const maxSize =
                            5
                            *
                            1024
                            *
                            1024;


                        if (
                            file.size > maxSize
                        ) {

                            attachment.setCustomValidity(
                                "Saiz fail mestilah tidak melebihi 5MB."
                            );


                            attachment.reportValidity();

                            return;
                        }


                        const fileName =
                            file.name.toLowerCase();


                        const allowedExtensions = [
                            ".pdf",
                            ".jpg",
                            ".jpeg",
                            ".png",
                            ".doc",
                            ".docx"
                        ];


                        const validExtension =
                            allowedExtensions.some(
                                function (extension) {

                                    return fileName.endsWith(
                                        extension
                                    );
                                }
                            );


                        if (!validExtension) {

                            attachment.setCustomValidity(
                                "Format fail tidak dibenarkan. Gunakan PDF, JPG, JPEG, PNG, DOC atau DOCX."
                            );


                            attachment.reportValidity();

                            return;
                        }
                    }
                );
            }


            // =================================================
            // FORM VALIDATION
            // =================================================

            if (leaveForm) {

                leaveForm.addEventListener(
                    "submit",
                    function (event) {

                        // =====================================
                        // LEAVE TYPE
                        // =====================================

                        if (
                            !leaveTypeSelect
                            ||
                            leaveTypeSelect.value === ""
                        ) {

                            event.preventDefault();


                            if (leaveTypeSelect) {

                                leaveTypeSelect.focus();
                            }


                            alert(
                                "Sila pilih jenis cuti."
                            );

                            return;
                        }


                        const selectedOption =
                            leaveTypeSelect.options[
                                leaveTypeSelect.selectedIndex
                            ];


                        const selectedName =
                            selectedOption
                                ? (
                                    selectedOption.dataset.name
                                    ||
                                    ""
                                ).trim()
                                : "";


                        // =====================================
                        // OTHER LEAVE TYPE
                        // =====================================

                        if (
                            selectedName.toLowerCase()
                            === "lain-lain"
                        ) {

                            if (
                                !otherLeaveType
                                ||
                                otherLeaveType.value
                                    .trim() === ""
                            ) {

                                event.preventDefault();


                                if (otherLeaveType) {

                                    otherLeaveType.focus();
                                }


                                alert(
                                    "Sila nyatakan jenis cuti."
                                );

                                return;
                            }
                        }


                        // =====================================
                        // DATE
                        // =====================================

                        if (
                            !startDate.value
                            ||
                            !endDate.value
                        ) {

                            event.preventDefault();


                            alert(
                                "Sila lengkapkan tarikh mula dan tarikh akhir."
                            );

                            return;
                        }


                        const start =
                            parseDate(
                                startDate.value
                            );

                        const end =
                            parseDate(
                                endDate.value
                            );


                        if (
                            !start
                            ||
                            !end
                            ||
                            end < start
                        ) {

                            event.preventDefault();


                            alert(
                                "Tarikh akhir tidak boleh lebih awal daripada tarikh mula."
                            );

                            return;
                        }


                        // =====================================
                        // CROSS YEAR
                        // =====================================

                        if (
                            start.getFullYear()
                            !==
                            end.getFullYear()
                        ) {

                            event.preventDefault();


                            alert(
                                "Permohonan cuti tidak boleh merentasi dua tahun. Sila buat permohonan berasingan bagi setiap tahun."
                            );

                            return;
                        }


                        // =====================================
                        // WORKING DAYS
                        // =====================================

                        calculateWorkingDays();


                        if (
                            calculatedWorkingDays <= 0
                        ) {

                            event.preventDefault();


                            alert(
                                "Tempoh yang dipilih tidak mempunyai hari bekerja yang sah."
                            );

                            return;
                        }


                        // =====================================
                        // BALANCE
                        // =====================================

                        if (!selectedHideBalance) {

                            if (
                                !selectedBalanceConfigured
                            ) {

                                event.preventDefault();


                                alert(
                                    "Baki jenis cuti ini belum ditetapkan oleh Pentadbir Sistem."
                                );

                                return;
                            }


                            if (
                                calculatedWorkingDays
                                > selectedBalance
                            ) {

                                event.preventDefault();


                                alert(
                                    "Baki cuti anda tidak mencukupi."
                                );

                                return;
                            }


                        // =====================================
                        // REQUIRED DOCUMENT
                        // =====================================

                        if (
                            selectedRequiresDocument
                        ) {

                            if (
                                !attachment
                                ||
                                !attachment.files
                                ||
                                attachment.files.length === 0
                            ) {

                                event.preventDefault();


                                if (attachment) {

                                    attachment.focus();
                                }


                                alert(
                                    "Dokumen sokongan wajib disertakan bagi jenis cuti ini."
                                );

                                return;
                            }
                        }


                        // =====================================
                        // FILE VALIDITY
                        // =====================================

                        if (
                            attachment
                            &&
                            !attachment.checkValidity()
                        ) {

                            event.preventDefault();


                            attachment.reportValidity();

                            return;
                        }


                        // =====================================
                        // PREVENT DOUBLE SUBMIT
                        // =====================================

                        if (submitButton) {

                            submitButton.disabled =
                                true;


                            submitButton.textContent =
                                "Menghantar...";
                        }
                    }
                );
            }


            // =================================================
            // INITIAL
            // =================================================

            updateLeaveType();

            calculateWorkingDays();

        }
    );


    // =========================================================
    // HTML ESCAPE FOR JAVASCRIPT GENERATED CONTENT
    // =========================================================

    function escapeHtml(value) {

        if (
            value === null
            ||
            value === undefined
        ) {

            return "";
        }


        return String(value)
            .replace(
                /&/g,
                "&amp;"
            )
            .replace(
                /</g,
                "&lt;"
            )
            .replace(
                />/g,
                "&gt;"
            )
            .replace(
                /"/g,
                "&quot;"
            )
            .replace(
                /'/g,
                "&#039;"
            );
    }

</script>




<!-- =========================================================
     FINAL WORKING-DAY CALCULATOR FIX
     Independent calculator for Tarikh Mula / Tarikh Akhir.
     PKB weekend: Friday + Saturday.
     Public holidays are excluded when available.
     ========================================================= -->
<script>
(function () {
    "use strict";

    function initWorkingDayCalculator() {
        const start = document.getElementById("startDate");
        const end = document.getElementById("endDate");
        const display = document.getElementById("durationDisplay");
        const hidden = document.getElementById("workingDays");
        const info = document.getElementById("holidayInfo");

        if (!start || !end || !display || !hidden) {
            return;
        }

        function pad(n) {
            return String(n).padStart(2, "0");
        }

        function key(d) {
            return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
        }

        function parseInputDate(value) {
            if (!/^\d{4}-\d{2}-\d{2}$/.test(value || "")) {
                return null;
            }

            const p = value.split("-").map(Number);
            const d = new Date(p[0], p[1] - 1, p[2], 12, 0, 0, 0);

            if (
                d.getFullYear() !== p[0] ||
                d.getMonth() !== p[1] - 1 ||
                d.getDate() !== p[2]
            ) {
                return null;
            }

            return d;
        }

        function normalizeHolidayDate(value) {
            const raw = String(value || "").trim();

            if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
                return raw;
            }

            if (/^\d{2}\/\d{2}\/\d{4}$/.test(raw)) {
                const p = raw.split("/");
                return p[2] + "-" + p[1] + "-" + p[0];
            }

            const m = raw.match(/^(\d{4}-\d{2}-\d{2})/);
            return m ? m[1] : "";
        }

        const holidays = new Map();

        try {
            if (typeof publicHolidays !== "undefined" && Array.isArray(publicHolidays)) {
                publicHolidays.forEach(function (h) {
                    if (!h) return;
                    const k = normalizeHolidayDate(h.date);
                    if (k) holidays.set(k, h.name || "Cuti Umum");
                });
            }
        } catch (e) {
            console.warn("Public holiday data could not be loaded:", e);
        }

        function calculate() {
            if (!start.value || !end.value) {
                display.value = "0 hari";
                hidden.value = "0";
                if (info) {
                    info.innerHTML = "";
                    info.classList.remove("show");
                }
                return 0;
            }

            const startDate = parseInputDate(start.value);
            const endDate = parseInputDate(end.value);

            if (!startDate || !endDate || endDate.getTime() < startDate.getTime()) {
                display.value = "0 hari";
                hidden.value = "0";
                return 0;
            }

            let count = 0;
            const excludedHolidays = [];
            const current = new Date(startDate.getTime());

            while (current.getTime() <= endDate.getTime()) {
                const day = current.getDay();
                const dateKey = key(current);
                const weekend = day === 5 || day === 6; // Friday / Saturday
                const holiday = holidays.has(dateKey);

                if (!weekend && !holiday) {
                    count++;
                } else if (holiday) {
                    excludedHolidays.push({
                        date: dateKey,
                        name: holidays.get(dateKey)
                    });
                }

                current.setDate(current.getDate() + 1);
            }

            display.value = count + (count === 1 ? " hari" : " hari");
            hidden.value = String(count);

            if (info) {
                if (excludedHolidays.length > 0) {
                    info.innerHTML = "<strong>Cuti umum yang tidak dikira:</strong><br>" +
                        excludedHolidays.map(function (h) {
                            return h.date + " - " + h.name;
                        }).join("<br>");
                    info.classList.add("show");
                } else {
                    info.innerHTML = "";
                    info.classList.remove("show");
                }
            }

            return count;
        }

        function startChanged() {
            if (start.value) {
                end.min = start.value;

                if (!end.value || end.value < start.value) {
                    end.value = start.value;
                }
            }

            calculate();
        }

        // Capture phase makes this calculator run reliably even when
        // another listener on the page also handles the same date fields.
        start.addEventListener("input", startChanged, true);
        start.addEventListener("change", startChanged, true);
        end.addEventListener("input", calculate, true);
        end.addEventListener("change", calculate, true);

        // Recalculate once after the page has fully loaded.
        calculate();

        // Expose only for debugging/manual test in browser console.
        window.recalculateLeaveWorkingDays = calculate;
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initWorkingDayCalculator);
    } else {
        initWorkingDayCalculator();
    }
})();
</script>

</body>

</html>