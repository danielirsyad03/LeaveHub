<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%!

    private String h(Object value) {

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
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("</", "<\\/");
    }


    private String formatDays(Object value) {

        if (value == null) {
            return "0";
        }

        try {

            return String.valueOf(
                Integer.parseInt(
                    value.toString()
                )
            );

        } catch (Exception e) {

            return "0";
        }
    }


    private String departmentName(String department) {

        if (
            department == null ||
            department.isBlank()
        ) {
            return "—";
        }

        switch (
            department.trim().toUpperCase()
        ) {

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

    if (
        session.getAttribute("userId") == null
    ) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    String name =
        request.getAttribute("staffName") == null
            ? (String) session.getAttribute("userName")
            : request.getAttribute("staffName").toString();


    if (
        name == null ||
        name.isBlank()
    ) {
        name = "Pengguna";
    }


    String position =
        request.getAttribute("position") == null
            ? ""
            : request.getAttribute("position").toString();


    String department =
        request.getAttribute("department") == null
            ? ""
            : request.getAttribute("department").toString();


    Integer selectedLeaveTypeId = null;


    try {

        Object selectedObject =
            request.getAttribute(
                "selectedLeaveTypeId"
            );

        if (selectedObject != null) {

            selectedLeaveTypeId =
                Integer.valueOf(
                    selectedObject.toString()
                );
        }

    } catch (Exception ignored) {
    }


    String otherLeaveType =
        request.getAttribute("otherLeaveType") == null
            ? ""
            : request.getAttribute("otherLeaveType").toString();


    String startDate =
        request.getAttribute("startDate") == null
            ? ""
            : request.getAttribute("startDate").toString();


    String endDate =
        request.getAttribute("endDate") == null
            ? ""
            : request.getAttribute("endDate").toString();


    String reason =
        request.getAttribute("reason") == null
            ? ""
            : request.getAttribute("reason").toString();


    String contactPhone =
        request.getAttribute("contactPhone") == null
            ? ""
            : request.getAttribute("contactPhone").toString();


    String contactAddress =
        request.getAttribute("contactAddress") == null
            ? ""
            : request.getAttribute("contactAddress").toString();


    String handoverStaffName =
        request.getAttribute("handoverStaffName") == null
            ? ""
            : request.getAttribute("handoverStaffName").toString();


    String balanceVerifiedBy =
        request.getAttribute("balanceVerifiedBy") == null
            ? ""
            : request.getAttribute("balanceVerifiedBy").toString();


    String balanceVerifiedDate =
        request.getAttribute("balanceVerifiedDate") == null
            ? ""
            : request.getAttribute("balanceVerifiedDate").toString();


    String existingAttachment =
        request.getAttribute("attachment") == null
            ? ""
            : request.getAttribute("attachment").toString();


    Integer originalLeaveYear = null;


    try {

        Object yearObject =
            request.getAttribute(
                "originalLeaveYear"
            );

        if (yearObject != null) {

            originalLeaveYear =
                Integer.valueOf(
                    yearObject.toString()
                );
        }

    } catch (Exception ignored) {
    }


    @SuppressWarnings("unchecked")
    List<Map<String, Object>> leaveTypes =
        (List<Map<String, Object>>)
        request.getAttribute("leaveTypes");


    @SuppressWarnings("unchecked")
    List<Map<String, Object>> publicHolidays =
        (List<Map<String, Object>>)
        request.getAttribute("publicHolidays");


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
        Kemas Kini Permohonan Cuti
    </title>

    <link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260914-unified"
/>


    <style>

        .edit-card {
            max-width: 950px;
        }


        .form-section {
            margin-top: 26px;
        }


        .form-section:first-child {
            margin-top: 0;
        }


        .form-section-title {
            margin-bottom: 15px;
        }


        .form-section-title h3 {
            margin: 0 0 5px;
        }


        .form-section-title p {
            margin: 0;
        }


        .form-grid {

            display: grid;

            grid-template-columns:
                repeat(2, minmax(0, 1fr));

            gap: 16px;
        }


        .full {
            grid-column: 1 / -1;
        }


        .field label {

            display: block;

            margin-bottom: 6px;

            font-weight: 600;
        }


        .field input,
        .field select,
        .field textarea {

            width: 100%;

            box-sizing: border-box;
        }


        /* =====================================================
           STAFF
           ===================================================== */

        .staff-info {

            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 12px;
        }


        .staff-box {

            padding: 14px 16px;

            border: 1px solid #e1e5ec;

            background: #fafbfc;

            border-radius: 9px;
        }


        .staff-box span {

            display: block;

            color: #7a8494;

            font-size: 11px;

            margin-bottom: 5px;
        }


        .staff-box strong {
            font-size: 13px;
        }


        /* =====================================================
           HOLIDAY
           ===================================================== */

        .holiday-info {

            display: none;

            margin-top: 10px;

            padding: 12px 14px;

            border: 1px solid #ead8a2;

            background: #fff9e8;

            color: #725411;

            border-radius: 9px;

            font-size: 12px;

            line-height: 1.6;
        }


        .holiday-info.show {
            display: block;
        }


        /* =====================================================
           BALANCE
           ===================================================== */

        .verification {

            padding: 18px;

            border: 1px solid #dfe3eb;

            border-radius: 12px;

            background: #fafbfc;
        }


        .selected-type {

            padding: 13px 16px;

            margin-bottom: 15px;

            background: #f8f1f2;

            border: 1px solid #ead8dc;

            border-radius: 9px;
        }


        .selected-type span {

            display: block;

            font-size: 12px;

            color: #707a8c;
        }


        .selected-type strong {

            display: block;

            margin-top: 4px;
        }


        .balance-summary {

            display: grid;

            grid-template-columns:
                repeat(3, minmax(0, 1fr));

            gap: 12px;

            margin-bottom: 18px;
        }


        .balance-box {

            padding: 16px;

            background: #ffffff;

            border: 1px solid #e1e5ec;

            border-radius: 10px;
        }


        .balance-box span {

            display: block;

            color: #7c8595;

            font-size: 12px;

            margin-bottom: 6px;
        }


        .balance-box strong {
            font-size: 24px;
        }


        .no-balance-box {

            display: none;

            margin-bottom: 18px;

            padding: 16px;

            border-radius: 10px;

            border: 1px solid #e4e7ed;

            background: #ffffff;
        }


        .no-balance-box.show {
            display: block;
        }


        .no-balance-box strong {

            display: block;

            color: #8d1f2d;

            font-size: 15px;

            margin-bottom: 5px;
        }


        .no-balance-box span {

            color: #687386;

            font-size: 12px;

            line-height: 1.6;
        }


        .balance-verification-fields.hide {
            display: none;
        }


        /* =====================================================
           WARNINGS
           ===================================================== */

        .warning-box {

            display: none;

            margin-bottom: 15px;

            padding: 11px 13px;

            border-radius: 8px;

            font-size: 12px;
        }


        .warning-box.show {
            display: block;
        }


        .warning-balance {

            background: #ffecec;

            color: #9d2e2e;
        }


        .warning-config,
        .warning-document {

            background: #fff6dc;

            color: #805d10;
        }


        /* =====================================================
           FILE
           ===================================================== */

        .existing-file {

            padding: 13px 15px;

            border-radius: 8px;

            background: #f5f7fa;

            border: 1px solid #e4e7ed;

            margin-bottom: 15px;
        }


        .existing-file span {

            display: block;

            font-size: 11px;

            color: #7c8595;

            margin-bottom: 4px;
        }


        .existing-file strong {

            font-size: 13px;

            word-break: break-word;
        }


        .upload-box {

            padding: 15px;

            border: 1px dashed #cbd2dd;

            border-radius: 10px;

            background: #fbfcfe;
        }


        .upload-box input[type="file"] {
            width: 100%;
        }


        .upload-note {

            margin-top: 7px;

            font-size: 11px;

            color: #7c8595;
        }


        .new-file-info {

            display: none;

            margin-top: 10px;

            padding: 10px 12px;

            background: #eef7ee;

            border-radius: 7px;

            font-size: 12px;
        }


        .new-file-info.show {
            display: block;
        }


        /* =====================================================
           ERROR
           ===================================================== */

        .error-box {

            margin-bottom: 20px;

            padding: 14px 17px;

            border-radius: 8px;

            background: #ffe8e8;

            color: #a52b2b;
        }


        @media(max-width: 750px) {

            .form-grid,
            .staff-info,
            .balance-summary {

                grid-template-columns: 1fr;
            }
        }

    </style>

</head>


<body>

<div class="app">


    <%@ include file="includes/sidebar.jspf" %>


    <main>


        <!-- =================================================
             TOPBAR
             ================================================= -->

        <div class="topbar">

            <div>

                <h1>
                    Kemas Kini Permohonan Cuti
                </h1>

                <p>
                    Kemas kini maklumat sebelum keputusan
                    akhir dibuat oleh Pengurusan
                </p>

            </div>


            <div class="user-chip">

                <div class="avatar">

                    <%= h(
                        name.substring(
                            0,
                            1
                        ).toUpperCase()
                    ) %>

                </div>

                <b>
                    <%= h(name) %>
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
                        "date".equals(error)
                    ) {

                        out.print(
                            "Tarikh permohonan tidak sah."
                        );

                    } else if (
                        "crossYear".equals(error)
                    ) {

                        out.print(
                            "Permohonan cuti tidak boleh merentasi dua tahun. Sila buat permohonan berasingan."
                        );

                    } else if (
                        "yearChange".equals(error)
                    ) {

                        out.print(
                            "Tahun permohonan tidak boleh diubah. Tarikh baharu mestilah kekal dalam tahun asal permohonan."
                        );

                    } else if (
                        "duration".equals(error)
                    ) {

                        out.print(
                            "Tempoh cuti tidak mempunyai hari bekerja yang sah. Jumaat, Sabtu dan cuti umum tidak dikira."
                        );

                    } else if (
                        "balanceVerification".equals(error)
                    ) {

                        out.print(
                            "Sila lengkapkan maklumat Disahkan Oleh dan Tarikh Pengesahan."
                        );

                    } else if (
                        "balanceNotConfigured".equals(error)
                    ) {

                        out.print(
                            "Baki jenis cuti yang dipilih belum ditetapkan oleh Pentadbir Sistem."
                        );

                    } else if (
                        "insufficientBalance".equals(error)
                    ) {

                        out.print(
                            "Baki cuti tidak mencukupi untuk jumlah hari yang dipohon."
                        );

                    } else if (
                        "invalidLeaveType".equals(error)
                    ) {

                        out.print(
                            "Jenis cuti yang dipilih tidak sah atau tidak aktif."
                        );

                    } else if (
                        "otherLeaveType".equals(error)
                    ) {

                        out.print(
                            "Sila nyatakan jenis cuti bagi pilihan Lain-lain."
                        );

                    } else if (
                        "overlap".equals(error)
                    ) {

                        out.print(
                            "Tarikh baharu bertindih dengan permohonan cuti lain."
                        );

                    } else if (
                        "documentRequired".equals(error)
                    ) {

                        out.print(
                            "Jenis cuti yang dipilih memerlukan dokumen sokongan."
                        );

                    } else if (
                        "fileSize".equals(error)
                    ) {

                        out.print(
                            "Saiz lampiran melebihi had maksimum 5 MB."
                        );

                    } else if (
                        "fileType".equals(error)
                    ) {

                        out.print(
                            "Format lampiran tidak dibenarkan. Gunakan PDF, JPG, JPEG, PNG, DOC atau DOCX."
                        );

                    } else {

                        out.print(
                            "Permohonan tidak dapat dikemas kini. Sila semak semula maklumat."
                        );
                    }

                %>

            </div>

        <% } %>


        <!-- =================================================
             FORM
             ================================================= -->

        <div class="card edit-card">

            <form
                method="post"
                enctype="multipart/form-data"
                action="<%= request.getContextPath() %>/edit-leave"
                id="editForm"
            >


                <input
                    type="hidden"
                    name="id"
                    value="<%= h(
                        request.getAttribute(
                            "applicationId"
                        )
                    ) %>"
                >


                <!-- =========================================
                     PEMOHON
                     ========================================= -->

                <div class="form-section">

                    <div class="form-section-title">

                        <h3>
                            Maklumat Pemohon
                        </h3>

                    </div>


                    <div class="staff-info">


                        <div class="staff-box">

                            <span>Nama</span>

                            <strong>
                                <%= h(name) %>
                            </strong>

                        </div>


                        <div class="staff-box">

                            <span>Jawatan</span>

                            <strong>

                                <%= position.isBlank()
                                    ? "—"
                                    : h(position)
                                %>

                            </strong>

                        </div>


                        <div class="staff-box">

                            <span>Bahagian</span>

                            <strong>

                                <%= h(
                                    departmentName(
                                        department
                                    )
                                ) %>

                            </strong>

                        </div>


                    </div>

                </div>


                <!-- =========================================
                     CUTI
                     ========================================= -->

                <div class="form-section">

                    <div class="form-section-title">

                        <h3>
                            Maklumat Cuti
                        </h3>

                    </div>


                    <div class="form-grid">


                        <div class="field full">

                            <label>
                                No. Permohonan
                            </label>

                            <input
                                value="<%= h(
                                    request.getAttribute(
                                        "applicationNo"
                                    )
                                ) %>"
                                readonly
                            >

                        </div>


                        <!-- =================================
                             LEAVE TYPE
                             ================================= -->

                        <div class="field full">

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
                                    data-shared-balance="false"
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


                                            Integer typeId =
                                                null;


                                            try {

                                                typeId =
                                                    Integer.valueOf(
                                                        type.get(
                                                            "leaveTypeId"
                                                        ).toString()
                                                    );

                                            } catch (
                                                Exception ignored
                                            ) {
                                            }


                                            String typeName =
                                                type.get(
                                                    "leaveTypeName"
                                                ) == null
                                                    ? ""
                                                    : type.get(
                                                        "leaveTypeName"
                                                    ).toString();


                                            String remaining =
                                                formatDays(
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


                                            boolean hideBalance =
                                                Boolean.TRUE.equals(
                                                    type.get(
                                                        "hideBalance"
                                                    )
                                                );


                                            boolean sharedBalance =
                                                Boolean.TRUE.equals(
                                                    type.get(
                                                        "sharedBalance"
                                                    )
                                                );


                                            boolean selected =
                                                typeId != null &&
                                                selectedLeaveTypeId != null &&
                                                typeId.intValue() ==
                                                selectedLeaveTypeId.intValue();

                                %>


                                    <option
                                        value="<%= h(typeId) %>"
                                        data-name="<%= h(typeName) %>"
                                        data-balance="<%= h(remaining) %>"
                                        data-configured="<%= configured %>"
                                        data-hide-balance="<%= hideBalance %>"
                                        data-shared-balance="<%= sharedBalance %>"
                                        data-requires-document="<%= requiresDocument %>"
                                        <%= selected
                                            ? "selected"
                                            : ""
                                        %>
                                    >

                                        <%= h(typeName) %>

                                        <% if (hideBalance) { %>

                                            — Boleh Dipohon

                                        <% } else if (sharedBalance) { %>

                                            — Baki Bersama:
                                            <%= h(remaining) %>
                                            hari

                                        <% } else if (configured) { %>

                                            — Baki:
                                            <%= h(remaining) %>
                                            hari

                                        <% } else { %>

                                            — Baki Belum Ditetapkan

                                        <% } %>

                                    </option>


                                <%

                                        }
                                    }

                                %>


                            </select>

                        </div>


                        <!-- =================================
                             OTHER
                             ================================= -->

                        <div
                            class="field full"
                            id="otherField"
                            style="display:none;"
                        >

                            <label for="otherLeaveType">
                                Nyatakan Jenis Cuti *
                            </label>

                            <input
                                name="otherLeaveType"
                                id="otherLeaveType"
                                value="<%= h(otherLeaveType) %>"
                                maxlength="100"
                            >

                        </div>


                        <!-- =================================
                             START
                             ================================= -->

                        <div class="field">

                            <label for="startDate">
                                Tarikh Mula *
                            </label>

                            <input
                                type="date"
                                name="startDate"
                                id="startDate"
                                value="<%= h(startDate) %>"

                                <% if (originalLeaveYear != null) { %>

                                    min="<%= originalLeaveYear %>-01-01"
                                    max="<%= originalLeaveYear %>-12-31"

                                <% } %>

                                required
                            >

                        </div>


                        <!-- =================================
                             END
                             ================================= -->

                        <div class="field">

                            <label for="endDate">
                                Tarikh Akhir *
                            </label>

                            <input
                                type="date"
                                name="endDate"
                                id="endDate"
                                value="<%= h(endDate) %>"

                                <% if (originalLeaveYear != null) { %>

                                    min="<%= originalLeaveYear %>-01-01"
                                    max="<%= originalLeaveYear %>-12-31"

                                <% } %>

                                required
                            >

                        </div>


                        <!-- =================================
                             DURATION
                             ================================= -->

                        <div class="field full">

                            <label>
                                Jumlah Hari Bekerja
                            </label>

                            <input
                                id="durationDisplay"
                                value="0 hari"
                                readonly
                            >


                            <div
                                class="muted"
                                style="
                                    margin-top:6px;
                                    font-size:12px;
                                "
                            >

                                Jumaat, Sabtu dan cuti umum
                                tidak dikira sebagai hari bekerja.

                            </div>


                            <div
                                id="holidayInfo"
                                class="holiday-info"
                            ></div>

                        </div>


                        <!-- =================================
                             REASON
                             ================================= -->

                        <div class="field full">

                            <label for="reason">
                                Alasan *
                            </label>

                            <textarea
                                name="reason"
                                id="reason"
                                rows="4"
                                required
                            ><%= h(reason) %></textarea>

                        </div>


                    </div>

                </div>


                <!-- =========================================
                     BALANCE
                     ========================================= -->

                <div class="form-section">

                    <div class="form-section-title">

                        <h3>
                            Pengesahan Baki Cuti
                        </h3>

                        <p
                            class="muted"
                            id="balanceSectionDescription"
                        >
                            Baki dikira berdasarkan jenis cuti
                            dan tempoh yang dipilih.
                        </p>

                    </div>


                    <div class="verification">


                        <div class="selected-type">

                            <span>
                                Jenis Cuti Dipilih
                            </span>

                            <strong
                                id="selectedTypeDisplay"
                            >
                                Belum dipilih
                            </strong>

                        </div>


                        <!-- CONFIG WARNING -->

                        <div
                            id="configWarning"
                            class="warning-box warning-config"
                        >

                            Baki jenis cuti ini belum ditetapkan
                            oleh Pentadbir Sistem.

                        </div>


                        <!-- BALANCE WARNING -->

                        <div
                            id="balanceWarning"
                            class="warning-box warning-balance"
                        >

                            Baki cuti tidak mencukupi untuk
                            tempoh yang dipilih.

                        </div>


                        <!-- NORMAL BALANCE -->

                        <div
                            class="balance-summary"
                            id="balanceSummary"
                        >


                            <div class="balance-box">

                                <span>
                                    Baki Semasa
                                </span>

                                <strong
                                    id="balanceBeforeDisplay"
                                >
                                    0
                                </strong>

                                hari

                            </div>


                            <div class="balance-box">

                                <span>
                                    Jumlah Cuti Dipohon
                                </span>

                                <strong
                                    id="requestedDisplay"
                                >
                                    0
                                </strong>

                                hari

                            </div>


                            <div class="balance-box">

                                <span>
                                    Baki Selepas Cuti
                                </span>

                                <strong
                                    id="balanceAfterDisplay"
                                >
                                    0
                                </strong>

                                hari

                            </div>


                        </div>


                        <!-- NO BALANCE TYPES -->

                        <div
                            id="noBalanceBox"
                            class="no-balance-box"
                        >

                            <strong>
                                Boleh Dipohon
                            </strong>

                            <span>

                                Jenis cuti ini tidak menggunakan
                                semakan baki pada permohonan staf.

                                Jumlah hari bekerja tetap akan
                                direkodkan berdasarkan tarikh
                                yang dipilih.

                            </span>

                        </div>


                        <!-- VERIFICATION -->

                        <div
                            class="form-grid balance-verification-fields"
                            id="balanceVerificationFields"
                        >


                            <div class="field">

                                <label for="balanceVerifiedBy">
                                    Disahkan Oleh *
                                </label>

                                <input
                                    name="balanceVerifiedBy"
                                    id="balanceVerifiedBy"
                                    maxlength="150"
                                    value="<%= h(balanceVerifiedBy) %>"
                                    required
                                >

                            </div>


                            <div class="field">

                                <label for="balanceVerifiedDate">
                                    Tarikh Pengesahan *
                                </label>

                                <input
                                    type="date"
                                    name="balanceVerifiedDate"
                                    id="balanceVerifiedDate"
                                    value="<%= h(balanceVerifiedDate) %>"
                                    required
                                >

                            </div>


                        </div>


                    </div>

                </div>


                <!-- =========================================
                     CONTACT
                     ========================================= -->

                <div class="form-section">

                    <div class="form-section-title">

                        <h3>
                            Maklumat Semasa Cuti
                        </h3>

                    </div>


                    <div class="form-grid">


                        <div class="field">

                            <label for="contactPhone">
                                No. Telefon
                            </label>

                            <input
                                name="contactPhone"
                                id="contactPhone"
                                maxlength="50"
                                value="<%= h(contactPhone) %>"
                            >

                        </div>


                        <div class="field">

                            <label for="handoverStaffName">
                                Tugas Ditanggung Oleh
                            </label>

                            <input
                                name="handoverStaffName"
                                id="handoverStaffName"
                                maxlength="150"
                                value="<%= h(handoverStaffName) %>"
                            >

                        </div>


                        <div class="field full">

                            <label for="contactAddress">
                                Alamat Ketika Cuti
                            </label>

                            <textarea
                                name="contactAddress"
                                id="contactAddress"
                                rows="3"
                            ><%= h(contactAddress) %></textarea>

                        </div>


                    </div>

                </div>


                <!-- =========================================
                     ATTACHMENT
                     ========================================= -->

                <div class="form-section">

                    <div class="form-section-title">

                        <h3>
                            Lampiran
                        </h3>

                        <p class="muted">

                            Jika fail baharu dipilih, lampiran lama
                            akan digantikan selepas kemas kini berjaya.

                        </p>

                    </div>


                    <% if (!existingAttachment.isBlank()) { %>

                        <div class="existing-file">

                            <span>
                                Lampiran Sedia Ada
                            </span>

                            <strong>
                                <%= h(existingAttachment) %>
                            </strong>

                        </div>

                    <% } else { %>

                        <div class="existing-file">

                            <span>
                                Lampiran Sedia Ada
                            </span>

                            <strong>
                                Tiada lampiran
                            </strong>

                        </div>

                    <% } %>


                    <div class="upload-box">

                        <div class="field">

                            <label for="attachment">
                                Pilih Lampiran Baharu
                            </label>

                            <input
                                type="file"
                                name="attachment"
                                id="attachment"
                                accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                            >

                        </div>


                        <div class="upload-note">

                            Format dibenarkan:
                            PDF, JPG, JPEG, PNG, DOC dan DOCX.
                            Saiz maksimum 5 MB.

                        </div>


                        <div
                            id="newFileInfo"
                            class="new-file-info"
                        ></div>

                    </div>


                    <div
                        id="documentWarning"
                        class="warning-box warning-document"
                        style="margin-top:12px;"
                    >

                        Jenis cuti ini memerlukan dokumen sokongan.
                        Sila kekalkan lampiran sedia ada atau pilih
                        lampiran baharu.

                    </div>

                </div>


                <!-- =========================================
                     ACTION
                     ========================================= -->

                <div
                    class="actions"
                    style="margin-top:25px;"
                >

                    <a
                        href="<%= request.getContextPath() %>/applications"
                        class="btn secondary"
                    >
                        Batal
                    </a>


                    <button
                        type="submit"
                        class="btn primary"
                        id="submitButton"
                    >
                        Simpan Perubahan
                    </button>

                </div>


            </form>

        </div>


    </main>

</div>


<script>

const leaveType =
    document.getElementById(
        "leaveTypeId"
    );


const otherField =
    document.getElementById(
        "otherField"
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


const selectedTypeDisplay =
    document.getElementById(
        "selectedTypeDisplay"
    );


const balanceBeforeDisplay =
    document.getElementById(
        "balanceBeforeDisplay"
    );


const requestedDisplay =
    document.getElementById(
        "requestedDisplay"
    );


const balanceAfterDisplay =
    document.getElementById(
        "balanceAfterDisplay"
    );


const balanceSummary =
    document.getElementById(
        "balanceSummary"
    );


const noBalanceBox =
    document.getElementById(
        "noBalanceBox"
    );


const balanceVerificationFields =
    document.getElementById(
        "balanceVerificationFields"
    );


const balanceVerifiedBy =
    document.getElementById(
        "balanceVerifiedBy"
    );


const balanceVerifiedDate =
    document.getElementById(
        "balanceVerifiedDate"
    );


const balanceSectionDescription =
    document.getElementById(
        "balanceSectionDescription"
    );


const configWarning =
    document.getElementById(
        "configWarning"
    );


const balanceWarning =
    document.getElementById(
        "balanceWarning"
    );


const documentWarning =
    document.getElementById(
        "documentWarning"
    );


const attachment =
    document.getElementById(
        "attachment"
    );


const newFileInfo =
    document.getElementById(
        "newFileInfo"
    );


const submitButton =
    document.getElementById(
        "submitButton"
    );


const existingAttachment =
    "<%= existingAttachment.isBlank()
        ? "false"
        : "true"
    %>" === "true";


let workingDays = 0;


/* ===========================================================
   PUBLIC HOLIDAYS FROM DATABASE
   =========================================================== */

const publicHolidays = new Map([

<%

    if (publicHolidays != null) {

        boolean firstHoliday = true;

        for (
            Map<String, Object> holiday :
            publicHolidays
        ) {

            Object holidayDateObject =
                holiday.get(
                    "holiday_date"
                );


            Object holidayNameObject =
                holiday.get(
                    "holiday_name"
                );


            if (
                holidayDateObject == null ||
                holidayNameObject == null
            ) {
                continue;
            }


            if (!firstHoliday) {
                out.print(",");
            }


            firstHoliday = false;

%>

    [
        "<%= jsEscape(holidayDateObject) %>",
        "<%= jsEscape(holidayNameObject) %>"
    ]

<%

        }
    }

%>

]);


/* ===========================================================
   SELECTED OPTION
   =========================================================== */

function getSelectedOption() {

    if (
        leaveType.selectedIndex < 0
    ) {
        return null;
    }


    return leaveType.options[
        leaveType.selectedIndex
    ];
}


/* ===========================================================
   WHOLE NUMBER
   =========================================================== */

function getWholeNumber(value) {

    const number =
        Number.parseInt(
            value,
            10
        );


    if (
        !Number.isInteger(number) ||
        number < 0
    ) {
        return 0;
    }


    return number;
}


/* ===========================================================
   LOCAL DATE KEY
   =========================================================== */

function formatLocalDate(date) {

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


/* ===========================================================
   DISPLAY DATE
   =========================================================== */

function formatDisplayDate(dateKey) {

    const parts =
        dateKey.split("-");


    if (
        parts.length !== 3
    ) {
        return dateKey;
    }


    return (
        parts[2]
        + "/"
        + parts[1]
        + "/"
        + parts[0]
    );
}


/* ===========================================================
   WORKING DAYS

   Friday    = 5
   Saturday  = 6

   Public holidays are also excluded.
   =========================================================== */

function calculateWorkingDays() {

    workingDays = 0;


    holidayInfo.classList.remove(
        "show"
    );


    holidayInfo.textContent = "";


    if (
        !startDate.value ||
        !endDate.value
    ) {

        durationDisplay.value =
            "0 hari";


        updateBalance();

        return;
    }


    let current =
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
        end < current
    ) {

        durationDisplay.value =
            "Tarikh tidak sah";


        updateBalance();

        return;
    }


    const holidaysInRange = [];


    while (
        current <= end
    ) {


        const day =
            current.getDay();


        const dateKey =
            formatLocalDate(
                current
            );


        const isWeekend =
            day === 5 ||
            day === 6;


        const isPublicHoliday =
            publicHolidays.has(
                dateKey
            );


        /*
         * Friday/Saturday are already excluded.
         *
         * If a public holiday falls on Friday/Saturday,
         * it is still excluded only once.
         */
        if (
            !isWeekend &&
            !isPublicHoliday
        ) {

            workingDays++;
        }


        if (isPublicHoliday) {

            holidaysInRange.push({
                date: dateKey,
                name: publicHolidays.get(
                    dateKey
                )
            });
        }


        current.setDate(
            current.getDate() + 1
        );
    }


    durationDisplay.value =
        workingDays
        + " hari";


    if (
        holidaysInRange.length > 0
    ) {


        const holidayText =
            holidaysInRange
                .map(
                    function(holiday) {

                        return (
                            holiday.name
                            + " ("
                            + formatDisplayDate(
                                holiday.date
                            )
                            + ")"
                        );
                    }
                )
                .join(", ");


        holidayInfo.textContent =
            "Cuti umum dalam tempoh ini tidak dikira: "
            + holidayText
            + ".";


        holidayInfo.classList.add(
            "show"
        );
    }


    updateBalance();
}


/* ===========================================================
   TYPE
   =========================================================== */

function updateType() {

    const option =
        getSelectedOption();


    if (!option) {
        return;
    }


    const typeName =
        option.dataset.name || "";


    const isOther =
        typeName.toLowerCase() ===
        "lain-lain";


    otherField.style.display =
        isOther
            ? ""
            : "none";


    otherLeaveType.required =
        isOther;


    if (!isOther) {
        otherLeaveType.value = "";
    }


    updateBalance();
}


/* ===========================================================
   NEW ATTACHMENT EXISTS
   =========================================================== */

function hasNewAttachment() {

    return (
        attachment.files &&
        attachment.files.length > 0
    );
}


/* ===========================================================
   ATTACHMENT
   =========================================================== */

function updateAttachment() {

    if (!hasNewAttachment()) {


        newFileInfo.classList.remove(
            "show"
        );


        newFileInfo.textContent =
            "";


        updateBalance();

        return;
    }


    const file =
        attachment.files[0];


    const maxSize =
        5 * 1024 * 1024;


    const fileName =
        file.name.toLowerCase();


    const allowed =
        fileName.endsWith(".pdf") ||
        fileName.endsWith(".jpg") ||
        fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png") ||
        fileName.endsWith(".doc") ||
        fileName.endsWith(".docx");


    if (!allowed) {


        alert(
            "Format fail tidak dibenarkan. Gunakan PDF, JPG, JPEG, PNG, DOC atau DOCX."
        );


        attachment.value =
            "";


        newFileInfo.classList.remove(
            "show"
        );


        updateBalance();

        return;
    }


    if (
        file.size > maxSize
    ) {


        alert(
            "Saiz fail melebihi had maksimum 5 MB."
        );


        attachment.value =
            "";


        newFileInfo.classList.remove(
            "show"
        );


        updateBalance();

        return;
    }


    newFileInfo.textContent =
        "Fail baharu dipilih: "
        + file.name;


    newFileInfo.classList.add(
        "show"
    );


    updateBalance();
}


/* ===========================================================
   BALANCE + VALIDATION
   =========================================================== */

function updateBalance() {

    const option =
        getSelectedOption();


    /* =======================================================
       NOTHING SELECTED
       ======================================================= */

    if (
        !option ||
        !leaveType.value
    ) {


        selectedTypeDisplay.textContent =
            "Belum dipilih";


        balanceBeforeDisplay.textContent =
            "0";


        requestedDisplay.textContent =
            workingDays.toString();


        balanceAfterDisplay.textContent =
            "0";


        balanceSummary.style.display =
            "";


        noBalanceBox.classList.remove(
            "show"
        );


        balanceVerificationFields.classList.remove(
            "hide"
        );


        balanceVerifiedBy.required =
            true;


        balanceVerifiedDate.required =
            true;


        configWarning.classList.remove(
            "show"
        );


        balanceWarning.classList.remove(
            "show"
        );


        documentWarning.classList.remove(
            "show"
        );


        balanceSectionDescription.textContent =
            "Baki dikira berdasarkan jenis cuti dan tempoh yang dipilih.";


        submitButton.disabled =
            false;


        return;
    }


    /* =======================================================
       OPTION DATA
       ======================================================= */

    const typeName =
        option.dataset.name || "";


    const configured =
        option.dataset.configured ===
        "true";


    const hideBalance =
        option.dataset.hideBalance ===
        "true";


    const sharedBalance =
        option.dataset.sharedBalance ===
        "true";


    const requiresDocument =
        option.dataset.requiresDocument ===
        "true";


    const balance =
        getWholeNumber(
            option.dataset.balance || "0"
        );


    const balanceAfter =
        balance - workingDays;


    selectedTypeDisplay.textContent =
        typeName;


    requestedDisplay.textContent =
        workingDays.toString();


    /* =======================================================
       CUTI TANPA REKOD / CUTI TANPA GAJI
       ======================================================= */

    if (hideBalance) {


        balanceSummary.style.display =
            "none";


        noBalanceBox.classList.add(
            "show"
        );


        balanceVerificationFields.classList.add(
            "hide"
        );


        balanceVerifiedBy.required =
            false;


        balanceVerifiedDate.required =
            false;


        configWarning.classList.remove(
            "show"
        );


        balanceWarning.classList.remove(
            "show"
        );


        balanceSectionDescription.textContent =
            "Jenis cuti ini boleh dipohon tanpa semakan baki staf.";


    } else {


        /* ===================================================
           NORMAL / SHARED BALANCE
           =================================================== */

        balanceSummary.style.display =
            "";


        noBalanceBox.classList.remove(
            "show"
        );


        balanceVerificationFields.classList.remove(
            "hide"
        );


        balanceVerifiedBy.required =
            true;


        balanceVerifiedDate.required =
            true;


        balanceBeforeDisplay.textContent =
            balance.toString();


        balanceAfterDisplay.textContent =
            Math.max(
                balanceAfter,
                0
            ).toString();


        if (sharedBalance) {

            balanceSectionDescription.textContent =
                "Cuti Tahunan dan Cuti Kecemasan menggunakan baki bersama sebanyak 50 hari.";

        } else {

            balanceSectionDescription.textContent =
                "Baki dikira berdasarkan jenis cuti dan tempoh yang dipilih.";
        }


        /* CONFIG */

        configWarning.classList.toggle(
            "show",
            !configured
        );


        /* BALANCE */

        const insufficient =
            configured &&
            workingDays > 0 &&
            balanceAfter < 0;


        balanceWarning.classList.toggle(
            "show",
            insufficient
        );
    }


    /* =======================================================
       DOCUMENT
       ======================================================= */

    const documentAvailable =
        existingAttachment ||
        hasNewAttachment();


    const missingDocument =
        requiresDocument &&
        !documentAvailable;


    documentWarning.classList.toggle(
        "show",
        missingDocument
    );


    /* =======================================================
       BUTTON
       ======================================================= */

    let disableSubmit =
        false;


    if (!hideBalance) {


        if (!configured) {
            disableSubmit = true;
        }


        if (
            configured &&
            workingDays > 0 &&
            balanceAfter < 0
        ) {
            disableSubmit = true;
        }
    }


    if (missingDocument) {
        disableSubmit = true;
    }


    submitButton.disabled =
        disableSubmit;
}


/* ===========================================================
   EVENTS
   =========================================================== */

leaveType.addEventListener(
    "change",
    updateType
);


startDate.addEventListener(
    "change",
    calculateWorkingDays
);


endDate.addEventListener(
    "change",
    calculateWorkingDays
);


attachment.addEventListener(
    "change",
    updateAttachment
);


/* ===========================================================
   SUBMIT CHECK
   =========================================================== */

document
    .getElementById(
        "editForm"
    )
    .addEventListener(
        "submit",
        function(event) {


            const option =
                getSelectedOption();


            /* TYPE */

            if (
                !option ||
                !leaveType.value
            ) {


                event.preventDefault();


                alert(
                    "Sila pilih jenis cuti."
                );


                return;
            }


            const hideBalance =
                option.dataset.hideBalance ===
                "true";


            const configured =
                option.dataset.configured ===
                "true";


            /* DURATION */

            if (
                workingDays <= 0
            ) {


                event.preventDefault();


                alert(
                    "Tempoh cuti tidak mempunyai hari bekerja yang sah. Jumaat, Sabtu dan cuti umum tidak dikira."
                );


                return;
            }


            /* =================================================
               BALANCE CHECK

               Not applied to:
               - Cuti Tanpa Rekod
               - Cuti Tanpa Gaji
               ================================================= */

            if (!hideBalance) {


                if (!configured) {


                    event.preventDefault();


                    alert(
                        "Baki jenis cuti ini belum ditetapkan."
                    );


                    return;
                }


                const balance =
                    getWholeNumber(
                        option.dataset.balance || "0"
                    );


                if (
                    balance < workingDays
                ) {


                    event.preventDefault();


                    alert(
                        "Baki cuti tidak mencukupi."
                    );


                    return;
                }


                if (
                    !balanceVerifiedBy.value.trim() ||
                    !balanceVerifiedDate.value
                ) {


                    event.preventDefault();


                    alert(
                        "Sila lengkapkan maklumat pengesahan baki cuti."
                    );


                    return;
                }
            }


            /* DOCUMENT */

            const requiresDocument =
                option.dataset.requiresDocument ===
                "true";


            const documentAvailable =
                existingAttachment ||
                hasNewAttachment();


            if (
                requiresDocument &&
                !documentAvailable
            ) {


                event.preventDefault();


                alert(
                    "Jenis cuti ini memerlukan dokumen sokongan."
                );


                return;
            }


            /* FILE SIZE */

            if (
                hasNewAttachment()
            ) {


                const file =
                    attachment.files[0];


                const maxSize =
                    5 * 1024 * 1024;


                if (
                    file.size > maxSize
                ) {


                    event.preventDefault();


                    alert(
                        "Saiz fail melebihi had maksimum 5 MB."
                    );


                    return;
                }
            }
        }
    );


/* ===========================================================
   INITIAL
   =========================================================== */

updateType();

calculateWorkingDays();

updateAttachment();

</script>


</body>

</html>