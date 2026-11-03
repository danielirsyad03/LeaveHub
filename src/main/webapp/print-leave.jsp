<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

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

    private String departmentName(String department) {
        if (
            department == null
            ||
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

    private boolean typeIs(
            String current,
            String value) {

        return
            current != null
            &&
            value.equalsIgnoreCase(
                current.trim()
            );
    }

    private String formatWholeDays(Object value) {
        if (value == null) {
            return "—";
        }

        if (value instanceof Number) {
            return String.valueOf(
                ((Number) value).intValue()
            );
        }

        try {
            return String.valueOf(
                Integer.parseInt(
                    value.toString().trim()
                )
            );
        } catch (Exception e) {
            return "—";
        }
    }

    private String formatDate(Object value) {
        if (value == null) {
            return "";
        }

        try {
            SimpleDateFormat output =
                new SimpleDateFormat(
                    "dd/MM/yyyy"
                );

            if (value instanceof Date) {
                return output.format(
                    (Date) value
                );
            }

            if (value instanceof Timestamp) {
                return output.format(
                    (Timestamp) value
                );
            }

        } catch (Exception ignored) {
        }

        return value.toString();
    }
%>

<%
    @SuppressWarnings("unchecked")

    Map<String, Object> leave =
        (Map<String, Object>)
        request.getAttribute(
            "leave"
        );

    if (leave == null) {
        response.sendRedirect(
            request.getContextPath()
            + "/applications"
        );

        return;
    }


    // =========================================================
    // LOGIN ROLE / BACK URL
    // =========================================================

    String printUserRole =
        session.getAttribute("userRole") == null
            ? ""
            : session
                .getAttribute("userRole")
                .toString()
                .trim()
                .toUpperCase();

    String backUrl;

    if (
        "HR".equals(printUserRole)
        ||
        "HOD".equals(printUserRole)
        ||
        "MANAGEMENT".equals(printUserRole)
    ) {
        backUrl =
            request.getContextPath()
            + "/admin";

    } else {
        backUrl =
            request.getContextPath()
            + "/applications";
    }


    // =========================================================
    // APPLICATION
    // =========================================================

    String applicationNo =
        h(
            leave.get(
                "applicationNo"
            )
        );

    String staffName =
        leave.get("staffName") == null
            ? ""
            : leave.get("staffName")
                 .toString();

    String staffPosition =
        leave.get("staffPosition") == null
            ? ""
            : leave.get("staffPosition")
                 .toString();

    String department =
        leave.get("staffDepartment") == null
            ? ""
            : leave.get("staffDepartment")
                 .toString();


    // =========================================================
    // APPLICANT ROLE
    // =========================================================

    String applicantRole =
        leave.get("applicantRole") == null
            ? ""
            : leave.get("applicantRole")
                 .toString()
                 .trim()
                 .toUpperCase();

    boolean applicantIsHod =
        "HOD".equals(
            applicantRole
        );

    boolean hodNotApplicable =
        Boolean.TRUE.equals(
            leave.get(
                "hodNotApplicable"
            )
        );


    // =========================================================
    // LEAVE TYPE
    // =========================================================

    String leaveType =
        leave.get("leaveType") == null
            ? ""
            : leave.get("leaveType")
                 .toString();

    String otherLeaveType =
        leave.get("otherLeaveType") == null
            ? ""
            : leave.get("otherLeaveType")
                 .toString();


    // =========================================================
    // STATUS
    // =========================================================

    String status =
        leave.get("status") == null
            ? ""
            : leave.get("status")
                 .toString()
                 .trim()
                 .toUpperCase();

    boolean approved =
        "APPROVED".equals(
            status
        );

    boolean rejected =
        "REJECTED".equals(
            status
        );

    boolean cancelled =
        "CANCELLED".equals(
            status
        );

    boolean managementFinal =
        approved
        ||
        rejected;


    // =========================================================
    // BALANCE
    // =========================================================

    String balanceBefore =
        formatWholeDays(
            leave.get(
                "balanceBefore"
            )
        );

    String duration =
        formatWholeDays(
            leave.get(
                "duration"
            )
        );

    String balanceAfter =
        formatWholeDays(
            leave.get(
                "balanceAfter"
            )
        );

    boolean hideBalance =
        "Cuti Tanpa Rekod".equalsIgnoreCase(
            leaveType
        )
        ||
        "Cuti Tanpa Gaji".equalsIgnoreCase(
            leaveType
        )
        ||
        "Lain-lain".equalsIgnoreCase(
            leaveType
        );


    // =========================================================
    // HANDOVER
    // =========================================================

    String handoverName =
        leave.get("handoverStaffName") == null
            ? ""
            : leave.get("handoverStaffName")
                 .toString();


    // =========================================================
    // HOD
    // =========================================================

    String hodDecision =
        leave.get("hodDecision") == null
            ? ""
            : leave.get("hodDecision")
                 .toString()
                 .trim()
                 .toUpperCase();

    String hodName =
        leave.get("hodApproverName") == null
            ? ""
            : leave.get("hodApproverName")
                 .toString();

    if (
        !hodNotApplicable
        &&
        hodName.isBlank()
        &&
        leave.get("assignedHodName") != null
    ) {
        hodName =
            leave.get("assignedHodName")
                 .toString();
    }

    String hodRemarks =
        leave.get("hodRemarks") == null
            ? ""
            : leave.get("hodRemarks")
                 .toString();

    String hodDecisionDate =
        formatDate(
            leave.get(
                "hodDecisionDate"
            )
        );

    boolean hodReviewed =
        !hodNotApplicable
        &&
        (
            "SUPPORTED".equals(
                hodDecision
            )
            ||
            "NOT_SUPPORTED".equals(
                hodDecision
            )
        );


    // =========================================================
    // MANAGEMENT
    // =========================================================

    String managementDecision =
        leave.get("managementDecision") == null
            ? ""
            : leave.get("managementDecision")
                 .toString()
                 .trim()
                 .toUpperCase();

    String managementName =
        leave.get("managementApproverName") == null
            ? ""
            : leave.get("managementApproverName")
                 .toString();

    String managementDecisionDate =
        formatDate(
            leave.get(
                "managementDecisionDate"
            )
        );

    String rejectionReason =
        leave.get("rejectionReason") == null
            ? ""
            : leave.get("rejectionReason")
                 .toString();


    // =========================================================
    // DATES
    // =========================================================

    String startDate =
        formatDate(
            leave.get(
                "startDate"
            )
        );

    String endDate =
        formatDate(
            leave.get(
                "endDate"
            )
        );

    String submittedDate =
        formatDate(
            leave.get(
                "submittedAt"
            )
        );
%>

<!DOCTYPE html>

<html lang="ms">

<head>

<meta charset="UTF-8">

<title>
    <%= applicationNo %>
</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 20px;
    background: #eeeeee;
    font-family:
        "Times New Roman",
        Times,
        serif;
    color: #111111;
}


/* =========================================================
   TOOLBAR
   ========================================================= */

.toolbar {
    width: 210mm;
    max-width: 100%;
    margin: 0 auto 10px;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

.toolbar button {
    border: 0;
    padding: 8px 14px;
    border-radius: 5px;
    font-family: Arial, sans-serif;
    font-size: 12px;
    cursor: pointer;
}

.toolbar .back-button {
    background: #dddddd;
    color: #222222;
}

.toolbar .print-button {
    background: #8d1f2d;
    color: white;
}


/* =========================================================
   A4
   ========================================================= */

.page {
    width: 210mm;
    min-height: 297mm;
    margin: auto;
    background: white;
    padding: 7mm 11mm 6mm;
}


/* =========================================================
   HEADER
   ========================================================= */

.header {
    text-align: center;
}

.header img {
    width: 72px;
    display: block;
    margin: 0 auto 2px;
}

.company {
    font-size: 16px;
    font-weight: bold;
}

.form-title {
    font-size: 14px;
    font-weight: bold;
    margin-top: 1px;
}

.number {
    margin-top: 2px;
    text-align: right;
    font-size: 11px;
}


/* =========================================================
   NOTICE
   ========================================================= */

.notice {
    border: 1px solid #555555;
    padding: 5px 7px;
    font-size: 11px;
    line-height: 1.25;
    margin: 5px 0;
}


/* =========================================================
   PERSONAL
   ========================================================= */

.personal {
    border: 3px double #555555;
    padding: 5px 8px;
}

.line {
    display: flex;
    margin: 4px 0;
    font-size: 11px;
}

.label {
    width: 82px;
    flex-shrink: 0;
    font-weight: bold;
}

.value {
    flex: 1;
    border-bottom: 1px dotted #555555;
    padding-left: 5px;
    min-height: 14px;
}


/* =========================================================
   LEAVE AREA
   ========================================================= */

.leave-area {
    display: grid;
    grid-template-columns: 2.4fr 1.45fr;
    gap: 8px;
    margin-top: 6px;
    align-items: start;
}


/* =========================================================
   LEAVE TYPE + DATE
   ========================================================= */

.leave-date-grid {
    display: grid;
    grid-template-columns: 1fr 1.15fr;
    column-gap: 8px;
    row-gap: 0;
}

.heading {
    font-size: 11px;
    font-weight: bold;
    margin-bottom: 4px;
}

.leave-row {
    display: flex;
    min-height: 18px;
    align-items: center;
    gap: 5px;
    font-size: 11px;
}

.box {
    width: 14px;
    height: 14px;
    border: 1px solid #555555;
    display: inline-flex;
    justify-content: center;
    align-items: center;
    font-family: Arial, sans-serif;
    font-size: 10px;
    font-weight: bold;
    flex-shrink: 0;
}

.leave-date-row {
    min-height: 18px;
    display: flex;
    align-items: center;
    padding: 0 3px;
    border-bottom: 1px solid #777777;
    font-size: 11px;
    line-height: 1.2;
    white-space: nowrap;
}


/* =========================================================
   BALANCE
   ========================================================= */

.balance {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}

.balance th,
.balance td {
    border: 1px solid #555555;
    text-align: center;
    padding: 4px;
}

.balance th {
    font-size: 11px;
    line-height: 1.15;
}

.balance td {
    font-size: 11px;
}

.balance-type {
    font-size: 10px;
    font-weight: normal;
    margin-top: 1px;
}

.no-balance-box {
    border: 1px solid #555555;
    padding: 10px;
    min-height: 105px;
    font-size: 11px;
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
}


/* =========================================================
   DATE TOTAL
   ========================================================= */

.date-total {
    display: flex;
    justify-content: space-between;
    margin: 6px 0;
    font-size: 11px;
}


/* =========================================================
   REASON
   ========================================================= */

.reason {
    border: 1px solid #555555;
    padding: 6px;
    font-size: 11px;
}

.answer {
    min-height: 24px;
    border-bottom: 1px dotted #777777;
    padding: 3px;
    font-size: 11px;
    line-height: 1.2;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
}


/* =========================================================
   SIGNATURES
   ========================================================= */

.signatures {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 14px;
    margin-top: 10px;
}

.signature {
    text-align: center;
    font-size: 11px;
}

.signature-writing {
    min-height: 30px;
    display: flex;
    justify-content: center;
    align-items: flex-end;
    padding: 0 4px 2px;
    border-bottom: 1px dotted #555555;
    font-family:
        "Segoe Script",
        "Lucida Handwriting",
        "Brush Script MT",
        cursive;
    font-size: 14px;
    font-weight: 500;
    line-height: 1;
}

.signature-writing.empty {
    font-family:
        "Times New Roman",
        serif;
}

.signature-title {
    padding-top: 2px;
    font-size: 11px;
    font-weight: bold;
}

.signature-name {
    margin-top: 1px;
    min-height: 13px;
    font-size: 10px;
}

.hod-result {
    margin-top: 3px;
    min-height: 12px;
    font-size: 10px;
    font-weight: bold;
}

.hod-date {
    margin-top: 1px;
    font-size: 10px;
}

.hod-remarks {
    margin-top: 2px;
    font-size: 9px;
    line-height: 1.15;
}


/* =========================================================
   HOD NOT APPLICABLE
   ========================================================= */

.hod-na-writing {
    min-height: 30px;
    display: flex;
    justify-content: center;
    align-items: flex-end;
    padding-bottom: 3px;
    border-bottom: 1px dotted #555555;
    font-family:
        "Times New Roman",
        serif;
    font-size: 10px;
    font-weight: bold;
}

.hod-na-label {
    margin-top: 3px;
    font-size: 10px;
    font-weight: bold;
}

.hod-na-reason {
    margin-top: 2px;
    font-size: 9px;
    line-height: 1.2;
}


/* =========================================================
   COMPUTER NOTE
   ========================================================= */

.computer-note {
    margin-top: 6px;
    padding-top: 3px;
    border-top: 1px solid #bbbbbb;
    text-align: center;
    font-family: Arial, sans-serif;
    font-size: 8px;
    font-style: italic;
    color: #555555;
}


/* =========================================================
   MANAGEMENT
   ========================================================= */

.management-title {
    font-weight: bold;
    font-size: 11px;
    margin: 6px 0 3px 6px;
}

.management {
    border: 1px solid #555555;
    padding: 6px;
    min-height: 105px;
    font-size: 11px;
}

.management-result {
    font-weight: bold;
    min-height: 12px;
}

.m-line {
    display: flex;
    align-items: flex-end;
    margin: 4px 0;
}

.m-label {
    min-width: 88px;
    font-weight: bold;
    font-size: 11px;
}

.m-value {
    flex: 1;
    border-bottom: 1px dotted #555555;
    margin-left: 5px;
    min-height: 14px;
    padding: 0 4px 1px;
    font-size: 11px;
}

.management-signature {
    flex: 1;
    min-height: 28px;
    margin-left: 5px;
    border-bottom: 1px dotted #555555;
    padding: 0 6px 2px;
    display: flex;
    align-items: flex-end;
    font-family:
        "Segoe Script",
        "Lucida Handwriting",
        "Brush Script MT",
        cursive;
    font-size: 14px;
    font-weight: 500;
    line-height: 1;
}

.management-note {
    margin-top: 5px;
    padding-top: 3px;
    border-top: 1px solid #cccccc;
    text-align: center;
    font-family: Arial, sans-serif;
    font-size: 8px;
    font-style: italic;
    color: #555555;
}


/* =========================================================
   CANCELLED
   ========================================================= */

.cancelled-notice {
    margin-top: 5px;
    border: 1px solid #555555;
    padding: 5px;
    text-align: center;
    font-size: 11px;
    font-weight: bold;
}


/* =========================================================
   PRINT
   ========================================================= */

@page {
    size: A4 portrait;
    margin: 0;
}

@media print {

    html,
    body {
        width: 210mm;
        height: 297mm;
        margin: 0;
        padding: 0;
        background: white;
    }

    .toolbar {
        display: none;
    }

    .page {
        margin: 0;
        box-shadow: none;
        width: 210mm;
        min-height: 0;
        padding: 7mm 11mm 6mm;
    }
}

</style>

</head>

<body>


<!-- =========================================================
     TOOLBAR
     ========================================================= -->

<div class="toolbar">

    <button
        type="button"
        class="back-button"
        onclick="window.location.href='<%= backUrl %>'"
    >
        Kembali
    </button>

    <button
        type="button"
        class="print-button"
        onclick="window.print()"
    >
        Cetak
    </button>

</div>


<div class="page">


    <!-- =====================================================
         HEADER
         ===================================================== -->

    <div class="header">

        <img
            src="<%= request.getContextPath() %>/images/logo-pkb.png"
            alt="Logo PKB"
        >

        <div class="company">
            PERMODALAN KEDAH BERHAD
        </div>

        <div class="form-title">
            BORANG PERMOHONAN CUTI
        </div>

    </div>

    <div class="number">

        NO. PERMOHONAN:

        <b>
            <%= applicationNo %>
        </b>

    </div>


    <!-- =====================================================
         NOTICE
         ===================================================== -->

    <div class="notice">

        ** PERMOHONAN BERCUTI HENDAKLAH DIBUAT
        SEKURANG-KURANGNYA SEMINGGU SEBELUM TARIKH PERCUTIAN

        <br>

        ** CUTI CARRY FORWARD HENDAKLAH DIHABISKAN DALAM TAHUN SEMASA DAN AKAN LUPUT JIKA TIDAK DIGUNAKAN.

    </div>


    <!-- =====================================================
         PERSONAL
         ===================================================== -->

    <div class="personal">

        <div class="line">
            <span class="label">
                NAMA :
            </span>

            <span class="value">
                <%= h(staffName) %>
            </span>
        </div>

        <div class="line">
            <span class="label">
                JAWATAN :
            </span>

            <span class="value">
                <%= staffPosition.isBlank()
                    ? "—"
                    : h(staffPosition)
                %>
            </span>
        </div>

        <div class="line">
            <span class="label">
                BAHAGIAN :
            </span>

            <span class="value">
                <%= h(
                    departmentName(
                        department
                    )
                ) %>
            </span>
        </div>

    </div>


    <!-- =====================================================
         LEAVE INFORMATION
         ===================================================== -->

    <div class="leave-area">

        <!-- =================================================
             LEAVE TYPE + DATE
             ================================================= -->

        <div class="leave-date-grid">

            <div class="heading">
                JENIS CUTI DIPOHON
            </div>

            <div class="heading">
                TARIKH DIPOHON
            </div>


            <!-- CUTI TAHUNAN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Tahunan"
                    ) ? "✓" : "" %>
                </span>
                CUTI TAHUNAN
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Tahunan"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI KECEMASAN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Kecemasan"
                    ) ? "✓" : "" %>
                </span>
                CUTI KECEMASAN
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Kecemasan"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI SAKIT -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Sakit"
                    ) ? "✓" : "" %>
                </span>
                CUTI SAKIT
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Sakit"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI BERSALIN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Bersalin"
                    ) ? "✓" : "" %>
                </span>
                CUTI BERSALIN
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Bersalin"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI KAHWIN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Kahwin"
                    ) ? "✓" : "" %>
                </span>
                CUTI KAHWIN
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Kahwin"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI IHSAN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Ihsan"
                    ) ? "✓" : "" %>
                </span>
                CUTI IHSAN
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Ihsan"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI TANPA REKOD -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Tanpa Rekod"
                    ) ? "✓" : "" %>
                </span>
                CUTI TANPA REKOD
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Tanpa Rekod"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- CUTI TANPA GAJI -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Cuti Tanpa Gaji"
                    ) ? "✓" : "" %>
                </span>
                CUTI TANPA GAJI
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Cuti Tanpa Gaji"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>


            <!-- LAIN-LAIN -->

            <div class="leave-row">
                <span class="box">
                    <%= typeIs(
                        leaveType,
                        "Lain-lain"
                    ) ? "✓" : "" %>
                </span>

                LAIN-LAIN:
                <%= h(otherLeaveType) %>
            </div>

            <div class="leave-date-row">
                <%
                    if (
                        typeIs(
                            leaveType,
                            "Lain-lain"
                        )
                    ) {
                %>
                    <%= h(startDate) %>
                    hingga
                    <%= h(endDate) %>
                <%
                    }
                %>
            </div>

        </div>


        <!-- =================================================
             MAKLUMAT BAKI CUTI
             ================================================= -->

        <div>

            <%
                if (
                    hideBalance
                ) {
            %>

                <div class="no-balance-box">

                    <b>
                        MAKLUMAT BAKI CUTI
                    </b>

                    <div style="margin-top:5px;">
                        <%= h(
                            leaveType
                        ) %>
                    </div>

                    <div style="margin-top:12px;">
                        Jenis cuti ini tidak
                        menggunakan kuota cuti.
                    </div>

                </div>

            <%
                } else {
            %>

                <table class="balance">

                    <tr>
                        <th colspan="3">

                            MAKLUMAT BAKI CUTI

                            <div class="balance-type">
                                <%= h(
                                    leaveType
                                ) %>
                            </div>

                        </th>
                    </tr>

                    <tr>

                        <th>
                            BAKI<br>TERAKHIR
                        </th>

                        <th>
                            CUTI<br>DIPOHON
                        </th>

                        <th>
                            BAKI<br>CUTI
                        </th>

                    </tr>

                    <tr>

                        <td style="height:42px;">
                            <b>
                                <%= h(
                                    balanceBefore
                                ) %>
                            </b>
                        </td>

                        <td>
                            <b>
                                <%= h(
                                    duration
                                ) %>
                            </b>
                        </td>

                        <td>
                            <b>
                                <%= h(
                                    balanceAfter
                                ) %>
                            </b>
                        </td>

                    </tr>

                </table>

            <%
                }
            %>

        </div>

    </div>


    <!-- =====================================================
         DATE / TOTAL
         ===================================================== -->

    <div class="date-total">

        <div>
            TARIKH :

            <b>
                <%= h(
                    submittedDate
                ) %>
            </b>
        </div>

        <div>
            JUMLAH CUTI :

            <b>
                <%= h(
                    duration
                ) %>
                HARI
            </b>
        </div>

    </div>


    <!-- =====================================================
         REASON
         ===================================================== -->

    <div class="reason">

        ALASAN UNTUK BERCUTI :

        <div class="answer">
            <%= h(
                leave.get(
                    "reason"
                )
            ) %>
        </div>

        <br>

        ALAMAT &amp; NO. TELEFON UNTUK DIHUBUNGI KETIKA CUTI :

        <div class="answer">

            <%= h(
                leave.get(
                    "contactAddress"
                )
            ) %>

            <br>

            <%= h(
                leave.get(
                    "contactPhone"
                )
            ) %>

        </div>


        <!-- =================================================
             SIGNATURES
             ================================================= -->

        <div class="signatures">


            <!-- APPLICANT -->

            <div class="signature">

                <div class="signature-writing">
                    <%= h(
                        staffName
                    ) %>
                </div>

                <div class="signature-title">
                    PEMOHON
                </div>

                <div class="signature-name">
                    NAMA:
                    <%= h(
                        staffName
                    ) %>
                </div>

            </div>


            <!-- HANDOVER -->

            <div class="signature">

                <div class="signature-writing">
                    <%= h(
                        handoverName
                    ) %>
                </div>

                <div class="signature-title">
                    TUGAS DITANGGUNG OLEH
                </div>

                <div class="signature-name">
                    NAMA:
                    <%= h(
                        handoverName
                    ) %>
                </div>

            </div>


            <!-- =================================================
                 HOD
                 ================================================= -->

            <div class="signature">

                <%
                    if (
                        hodNotApplicable
                    ) {
                %>

                    <div class="hod-na-writing">
                        TIDAK BERKENAAN
                    </div>

                    <div class="signature-title">
                        SOKONGAN KETUA UNIT
                    </div>

                    <div class="hod-na-label">
                        TIDAK BERKENAAN
                    </div>

                    <div class="hod-na-reason">

                        <%
                            if (
                                applicantIsHod
                            ) {
                        %>

                            Pemohon merupakan Ketua Unit

                        <%
                            } else if (
                                "MANAGEMENT".equals(
                                    applicantRole
                                )
                            ) {
                        %>

                            Pemohon merupakan pihak Pengurusan

                        <%
                            } else if (
                                "HR".equals(
                                    applicantRole
                                )
                            ) {
                        %>

                            Tidak memerlukan sokongan Ketua Unit

                        <%
                            } else {
                        %>

                            Tidak memerlukan sokongan Ketua Unit

                        <%
                            }
                        %>

                    </div>

                <%
                    } else {
                %>

                    <div
                        class="signature-writing <%= hodReviewed ? "" : "empty" %>"
                    >

                        <%
                            if (
                                hodReviewed
                            ) {
                        %>

                            <%= h(
                                hodName
                            ) %>

                        <%
                            }
                        %>

                    </div>

                    <div class="signature-title">
                        SOKONGAN KETUA UNIT
                    </div>

                    <div class="signature-name">
                        NAMA:
                        <%= h(
                            hodName
                        ) %>
                    </div>

                    <div class="hod-result">

                        <%
                            if (
                                "SUPPORTED".equals(
                                    hodDecision
                                )
                            ) {

                                out.print(
                                    "DISOKONG"
                                );

                            } else if (
                                "NOT_SUPPORTED".equals(
                                    hodDecision
                                )
                            ) {

                                out.print(
                                    "TIDAK DISOKONG"
                                );
                            }
                        %>

                    </div>

                    <%
                        if (
                            hodReviewed
                            &&
                            !hodDecisionDate.isBlank()
                        ) {
                    %>

                        <div class="hod-date">
                            TARIKH:
                            <%= h(
                                hodDecisionDate
                            ) %>
                        </div>

                    <%
                        }
                    %>

                    <%
                        if (
                            !hodRemarks.isBlank()
                        ) {
                    %>

                        <div class="hod-remarks">
                            CATATAN:
                            <%= h(
                                hodRemarks
                            ) %>
                        </div>

                    <%
                        }
                    %>

                <%
                    }
                %>

            </div>

        </div>


        <div class="computer-note">
            Dokumen ini dijana melalui sistem komputer.
            Cetakan komputer tidak memerlukan tandatangan.
        </div>

    </div>


    <!-- =====================================================
         MANAGEMENT
         ===================================================== -->

    <div class="management-title">
        KELULUSAN PENGURUSAN
    </div>

    <div class="management">

        <div>

            PERMOHONAN DILULUSKAN / TIDAK DILULUSKAN :

            <span class="management-result">

                <%
                    if (
                        approved
                    ) {

                        out.print(
                            "DILULUSKAN"
                        );

                    } else if (
                        rejected
                    ) {

                        out.print(
                            "TIDAK DILULUSKAN"
                        );
                    }
                %>

            </span>

        </div>


        <div class="m-line">

            <span class="m-label">
                NAMA :
            </span>

            <span class="m-value">

                <%
                    if (
                        managementFinal
                    ) {
                %>

                    <%= h(
                        managementName
                    ) %>

                <%
                    }
                %>

            </span>

        </div>


        <div class="m-line">

            <span class="m-label">
                PENGESAHAN :
            </span>

            <span class="management-signature">

                <%
                    if (
                        managementFinal
                    ) {
                %>

                    <%= h(
                        managementName
                    ) %>

                <%
                    }
                %>

            </span>

        </div>


        <div class="m-line">

            <span class="m-label">
                TARIKH :
            </span>

            <span class="m-value">

                <%
                    if (
                        managementFinal
                    ) {
                %>

                    <%= h(
                        managementDecisionDate
                    ) %>

                <%
                    }
                %>

            </span>

        </div>


        <div>

            ALASAN PERMOHONAN TIDAK DILULUSKAN :

            <div class="answer">

                <%
                    if (
                        rejected
                        &&
                        !rejectionReason.isBlank()
                    ) {
                %>

                    <%= h(
                        rejectionReason
                    ) %>

                <%
                    }
                %>

            </div>

        </div>


        <div class="management-note">
            Kelulusan dan pengesahan direkodkan melalui sistem.
            Cetakan komputer tidak memerlukan tandatangan.
        </div>

    </div>


    <!-- =====================================================
         CANCELLED
         ===================================================== -->

    <%
        if (
            cancelled
        ) {
    %>

        <div class="cancelled-notice">
            STATUS PERMOHONAN:
            DIBATALKAN
        </div>

    <%
        }
    %>

</div>

</body>

</html>