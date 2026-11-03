<%@ page contentType="text/html;charset=UTF-8" %>

<%!
    private String htmlEscape(Object value) {
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

    private String departmentName(String department) {
        if (department == null || department.isBlank()) {
            return "";
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

    private String roleName(String role) {
        if (role == null) {
            return "";
        }

        switch (role.toUpperCase()) {
            case "HOD":
                return "Ketua Unit";

            case "MANAGEMENT":
                return "Pengurusan";

            case "HR":
                return "Pentadbir Sistem";

            default:
                return "Staf";
        }
    }

    private java.util.Map<String, Object> findBalance(
            java.util.List<java.util.Map<String, Object>> balances,
            int leaveTypeId) {

        if (balances == null) {
            return null;
        }

        for (java.util.Map<String, Object> b : balances) {

            Object id = b.get("leaveTypeId");

            if (id instanceof Number &&
                ((Number) id).intValue() == leaveTypeId) {
                return b;
            }
        }

        return null;
    }
%>

<%
    // =========================================================
    // SESSION
    // =========================================================

    String role = (String) session.getAttribute("userRole");
    String name = (String) session.getAttribute("userName");

    if (session.getAttribute("userId") == null ||
        name == null ||
        name.isBlank()) {

        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    if (role == null || !"HR".equalsIgnoreCase(role.trim())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    // =========================================================
    // DATA
    // =========================================================

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> staff =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("staff");

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> hods =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("hods");

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> leaveTypes =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("leaveTypes");

    Object currentYearObj = request.getAttribute("currentYear");

    int currentYear =
        currentYearObj instanceof Number
            ? ((Number) currentYearObj).intValue()
            : java.time.Year.now().getValue();

    String temporaryPassword =
        (String) session.getAttribute("temporaryPassword");

    String temporaryEmail =
        (String) session.getAttribute("temporaryEmail");

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    // =========================================================
    // COUNTS
    // =========================================================

    int totalUsers = staff == null ? 0 : staff.size();

    int staffCount = 0;
    int hodCount = 0;
    int managementCount = 0;

    if (staff != null) {

        for (java.util.Map<String, Object> user : staff) {

            String userRole =
                user.get("role") == null
                    ? ""
                    : String.valueOf(user.get("role"));

            if ("STAFF".equalsIgnoreCase(userRole)) {
                staffCount++;

            } else if ("HOD".equalsIgnoreCase(userRole)) {
                hodCount++;

            } else if ("MANAGEMENT".equalsIgnoreCase(userRole)) {
                managementCount++;
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

<title>Pengurusan Staf - PKB</title>

<link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260915-staff-fit"
>

<style>
*{box-sizing:border-box}
html,body{max-width:100%;overflow-x:hidden}

.staff-management-page{width:100%;max-width:100%;min-width:0;font-size:13px;color:#536075}
.staff-page-header{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;margin-bottom:20px}
.staff-page-title h1{margin:0 0 7px;color:#172033;font-size:28px;font-weight:700;line-height:1.2;letter-spacing:-.3px}
.staff-page-title p{margin:0;color:#8590a3;font-size:14px;line-height:1.5}

/* Alert */
.staff-alert{margin-bottom:16px;padding:12px 14px;border-radius:10px;font-size:13px;line-height:1.5}
.staff-alert.error{background:#fff0f2;color:#a72d39;border:1px solid #efcdd2}
.staff-alert.success{background:#eaf8f1;color:#20744b;border:1px solid #ceeadd}

/* Temporary password */
.temporary-password-card{margin-bottom:18px;padding:17px;background:linear-gradient(135deg,#fffaf2,#fff);border:1px solid #eadcb9;border-radius:14px}
.temporary-password-card h3{margin:0 0 6px;color:#5f4916;font-size:17px;font-weight:600}
.temporary-password-card>p{margin:0 0 12px;color:#857754;font-size:13px}
.temporary-credentials{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin-bottom:12px}
.temporary-credential{padding:11px 13px;background:#fff;border:1px solid #eee3c9;border-radius:9px}
.temporary-credential span{display:block;margin-bottom:4px;color:#9b8a61;font-size:11px;font-weight:500;text-transform:uppercase}
.temporary-credential strong{color:#453d2a;font-size:14px;font-weight:600}
.temp-password{font-family:Consolas,monospace;letter-spacing:.5px}

/* Summary */
.staff-summary{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;width:100%;margin-bottom:18px}
.staff-summary-card{position:relative;min-width:0;min-height:94px;padding:15px 16px;background:#fff;border:1px solid #e4e7ed;border-radius:13px;box-shadow:0 4px 14px rgba(27,36,53,.04);overflow:hidden}
.staff-summary-card:before{content:"";position:absolute;left:0;top:12px;bottom:12px;width:3px;border-radius:0 4px 4px 0;background:linear-gradient(180deg,#8d1f2d,#d5a12b)}
.staff-summary-card span{display:block;color:#758095;font-size:11.5px;font-weight:500;text-transform:uppercase}
.staff-summary-card strong{display:block;margin-top:7px;color:#172033;font-size:25px;font-weight:600;line-height:1}
.staff-summary-card small{display:block;margin-top:8px;color:#929bad;font-size:11.5px}

/* Main card */
.staff-shell{width:100%;max-width:100%;min-width:0;background:#fff;border:1px solid #e5e8ed;border-radius:16px;box-shadow:0 6px 22px rgba(31,41,61,.04);overflow:hidden}
.staff-shell-header{display:flex;align-items:center;justify-content:space-between;gap:16px;padding:17px 19px;border-bottom:1px solid #e9ecf1}
.staff-shell-title h2{margin:0 0 5px;color:#172033;font-size:19px;font-weight:600;line-height:1.3}
.staff-shell-title p{margin:0;color:#8993a5;font-size:13px;line-height:1.4}
.staff-header-actions{display:flex;align-items:center;gap:9px;flex-wrap:wrap}

/* Buttons */
.staff-btn{display:inline-flex;align-items:center;justify-content:center;gap:5px;min-height:38px;padding:9px 14px;border-radius:8px;font:500 12.5px/1.2 inherit;text-decoration:none;white-space:nowrap;cursor:pointer;transition:.15s ease}
.staff-btn.primary{background:#9c1f30;color:#fff;border:1px solid #9c1f30;box-shadow:0 4px 11px rgba(141,31,45,.14)}
.staff-btn.primary:hover{background:#7d1927;border-color:#7d1927}
.staff-btn.secondary{background:#fff;color:#687284;border:1px solid #dfe3e9}
.staff-btn.secondary:hover{background:#fff7f8;color:#8d1f2d;border-color:#dab7bd}
.staff-btn.print,.staff-btn.gold{background:#fff8e8;color:#85600f;border:1px solid #ead8a5}
.staff-btn.print:hover,.staff-btn.gold:hover{background:#fff2cf;border-color:#d5a12b}
.staff-btn.danger{background:#fff0f2;color:#a72d39;border:1px solid #efcbd0}
.staff-btn.danger:hover{background:#fde3e6}
.staff-header-actions .staff-btn{min-height:40px;padding:10px 15px;font-size:13px}

/* Toolbar/search */
.staff-toolbar{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:11px 18px;background:#fafbfc;border-bottom:1px solid #e9ecf1}
.staff-count{color:#8993a5;font-size:12.5px}
.staff-count strong{color:#8d1f2d;font-weight:600}
.staff-search{position:relative;width:min(360px,48%)}
.staff-search span{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#98a2b3;font-size:13px;pointer-events:none}
.staff-search input{width:100%;height:40px;padding:0 12px 0 35px;background:#fff;border:1px solid #dfe3e9;border-radius:8px;color:#333d50;font:400 13px inherit;outline:none}
.staff-search input::placeholder{color:#99a3b5}
.staff-search input:focus,.staff-form-group input:focus,.staff-form-group select:focus{border-color:#a84754;box-shadow:0 0 0 3px rgba(141,31,45,.08)}

/* Table */
.staff-table-wrap{width:100%;max-width:100%;overflow-x:auto}
.staff-table{width:100%;min-width:1050px;table-layout:fixed;border-collapse:collapse}
.staff-table th:nth-child(1),.staff-table td:nth-child(1){width:18%}
.staff-table th:nth-child(2),.staff-table td:nth-child(2){width:14%}
.staff-table th:nth-child(3),.staff-table td:nth-child(3){width:13%}
.staff-table th:nth-child(4),.staff-table td:nth-child(4){width:17%}
.staff-table th:nth-child(5),.staff-table td:nth-child(5){width:10%}
.staff-table th:nth-child(6),.staff-table td:nth-child(6){width:12%}
.staff-table th:nth-child(7),.staff-table td:nth-child(7){width:16%}
.staff-table thead th{padding:12px 8px;background:#f8f9fb;border-bottom:1px solid #e8ebef;color:#68758a;font-size:11.5px;font-weight:600;line-height:1.3;text-align:left;text-transform:uppercase}
.staff-table tbody td{padding:13px 8px;border-bottom:1px solid #edf0f3;color:#536075;font-size:13px;font-weight:400;line-height:1.45;vertical-align:middle;overflow-wrap:anywhere}
.staff-table tbody tr:hover{background:#fdfafa}
.staff-table tbody tr:last-child td{border-bottom:0}
.staff-name strong{display:block;color:#172033;font-size:13.5px;font-weight:600;line-height:1.35}
.staff-email{display:block;margin-top:3px;color:#8490a3;font-size:11.5px;line-height:1.4}
.position-text{display:block;font-size:13px;line-height:1.4}
.staff-role-badge{display:inline-flex;align-items:center;justify-content:center;gap:4px;min-height:27px;padding:5px 9px;border-radius:999px;font-size:11px;font-weight:500;line-height:1.1;text-align:center}
.staff-role-badge:before{content:"";width:5px;height:5px;min-width:5px;border-radius:50%}
.staff-role-badge.STAFF{background:#f2f3f6;color:#5f6877;border:1px solid #e1e4e9}.staff-role-badge.STAFF:before{background:#7d8797}
.staff-role-badge.HOD{background:#fff6e4;color:#916713;border:1px solid #efdfba}.staff-role-badge.HOD:before{background:#c18a19}
.staff-role-badge.MANAGEMENT{background:#fff0f2;color:#8d1f2d;border:1px solid #efcfd4}.staff-role-badge.MANAGEMENT:before{background:#8d1f2d}
.staff-role-badge.HR{background:#eaf8f1;color:#20744b;border:1px solid #d0ebdd}.staff-role-badge.HR:before{background:#24875a}
.department-badge{display:inline-block;max-width:100%;padding:5px 8px;background:#f7f4f2;border:1px solid #ebe3de;border-radius:7px;color:#655b54;font-size:11px;line-height:1.3}
.staff-actions{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.staff-actions form{margin:0}
.staff-table .staff-btn{min-height:34px;padding:7px 10px;font-size:11.5px}
.staff-table .staff-btn.gold{max-width:none}

/* Empty */
.staff-empty{padding:45px 20px!important;text-align:center}
.staff-empty-icon{width:48px;height:48px;display:grid;place-items:center;margin:0 auto 11px;border-radius:14px;background:linear-gradient(135deg,#fff0f2,#fff8e8);border:1px solid #f0dce0;color:#8d1f2d;font-size:19px}
.staff-empty strong{display:block;color:#374052;font-size:14px;font-weight:600}
.staff-empty p{margin:5px 0 0;color:#929aa8;font-size:12px}
.staff-no-search{display:none;padding:30px 20px;border-top:1px solid #eef0f4;color:#8992a1;font-size:12px;text-align:center}

/* Modal */
.staff-modal{position:fixed;inset:0;z-index:1000;display:none;align-items:center;justify-content:center;padding:20px;background:rgba(20,29,47,.48);backdrop-filter:blur(2px)}
.staff-modal.show{display:flex}
.staff-modal-box{width:100%;max-width:620px;max-height:90vh;overflow-y:auto;background:#fff;border-radius:17px;box-shadow:0 24px 60px rgba(20,29,47,.22)}
.staff-modal-box.balance-modal-box{max-width:920px}
.staff-modal-header{display:flex;align-items:center;justify-content:space-between;gap:20px;padding:19px 21px;border-bottom:1px solid #eceef2}
.staff-modal-heading h2{margin:0 0 4px;color:#172033;font-size:20px;font-weight:600}
.staff-modal-heading p{margin:0;color:#929aa8;font-size:13px}
.staff-modal-close{width:38px;height:38px;display:grid;place-items:center;padding:0;background:#fff;border:1px solid #e3e6eb;border-radius:9px;color:#687284;font-size:21px;cursor:pointer}
.staff-modal-close:hover{background:#fff3f4;color:#8d1f2d;border-color:#dab7bd}
.staff-modal-body{padding:20px 21px}
.staff-form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}
.staff-form-group{display:flex;flex-direction:column;gap:6px}
.staff-form-group.full{grid-column:1/-1}
.staff-form-group label{color:#424c5e;font-size:13px;font-weight:600}
.staff-form-group input,.staff-form-group select{width:100%;min-height:44px;padding:10px 11px;background:#fff;border:1px solid #dfe3e9;border-radius:9px;color:#333d50;font:400 13px inherit;outline:none}
.form-note{margin-top:2px;color:#929aa8;font-size:11.5px;line-height:1.4}
.field-hidden{display:none!important}
.staff-modal-footer{display:flex;justify-content:flex-end;gap:8px;margin-top:19px;padding-top:17px;border-top:1px solid #eceef2}
.staff-modal-footer .staff-btn{min-height:38px;font-size:12.5px}

/* Balance */
.balance-staff-info{display:flex;justify-content:space-between;align-items:center;gap:15px;margin-bottom:16px;padding:13px 14px;background:linear-gradient(135deg,#fffafa,#fffdf7);border:1px solid #eadde0;border-radius:11px}
.balance-staff-info strong{display:block;margin-bottom:3px;color:#364052;font-size:14px;font-weight:600}
.balance-staff-info div{color:#748093;font-size:12px}
.balance-year{padding:6px 9px;background:#fff;border:1px solid #e3d9dc;border-radius:8px;color:#8d1f2d!important;font-size:12px!important;font-weight:600}
.shared-quota-card{margin-bottom:16px;padding:15px;background:linear-gradient(135deg,#fffaf3,#fffdf9);border:1px solid #eadbb5;border-radius:11px}
.shared-quota-header{display:flex;justify-content:space-between;align-items:flex-start;gap:15px;flex-wrap:wrap}
.shared-quota-title{display:block;margin-bottom:4px;color:#5f4916;font-size:14px;font-weight:600}
.shared-quota-subtitle{color:#8a7953;font-size:12px}
.shared-quota-badge{display:inline-flex;padding:6px 10px;background:#fff;border:1px solid #eadbb5;border-radius:999px;color:#85600f;font-size:11px;font-weight:500}
.shared-quota-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin-top:14px}
.shared-quota-item{min-height:82px;padding:11px;background:rgba(255,255,255,.7);border:1px solid #eee3ca;border-radius:9px}
.shared-quota-label{margin-bottom:7px;color:#8b7d5e;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.2px}
.shared-quota-item input{width:100%;min-height:40px;padding:8px 9px;border:1px solid #dfd4ba;border-radius:8px;font:400 13px inherit;outline:none}
.shared-used-value,.shared-remaining-value{font-size:18px;font-weight:600}
.shared-used-value{color:#8d1f2d}.shared-remaining-value{color:#20744b}
.balance-table-wrap{overflow-x:auto;border:1px solid #e7e9ef;border-radius:11px}
.balance-table{width:100%;min-width:650px;border-collapse:collapse}
.balance-table th{padding:12px;background:#f9fafc;border-bottom:1px solid #e7e9ef;color:#7b8698;font-size:11px;font-weight:600;text-align:left;text-transform:uppercase}
.balance-table td{padding:12px;border-bottom:1px solid #eef0f4;color:#566173;font-size:12.5px;vertical-align:middle}
.balance-table tbody tr:last-child td{border-bottom:0}
.balance-table input{width:95px;min-height:40px;padding:8px 9px;border:1px solid #dfe3e9;border-radius:8px;font:400 13px inherit;outline:none}
.balance-value{color:#8d1f2d;font-weight:600}.remaining-value{color:#20744b;font-weight:600}
.no-quota-badge{display:inline-flex;padding:6px 9px;background:#f2f3f6;border:1px solid #e1e4e9;border-radius:999px;color:#687284;font-size:11px;font-weight:500}
.balance-note{margin-top:13px;padding:11px 12px;background:#fafbfc;border:1px solid #e8ebef;border-radius:9px;color:#7b8494;font-size:12px;line-height:1.6}

@media(max-width:1000px){
  .staff-summary{grid-template-columns:repeat(2,minmax(0,1fr))}
  .staff-toolbar{align-items:stretch;flex-direction:column}
  .staff-search{width:100%;max-width:none}
  .shared-quota-grid{grid-template-columns:repeat(2,minmax(0,1fr))}
}
@media(max-width:650px){
  .staff-page-header,.staff-shell-header,.balance-staff-info{flex-direction:column;align-items:flex-start}
  .staff-page-title h1{font-size:24px}
  .staff-summary,.staff-form-grid,.temporary-credentials,.shared-quota-grid{grid-template-columns:1fr}
  .staff-form-group.full{grid-column:auto}
  .staff-header-actions{width:100%}
  .staff-header-actions .staff-btn{flex:1}
  .staff-modal-footer{flex-direction:column-reverse}
  .staff-modal-footer .staff-btn{width:100%}
}
</style>
</head>

<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="staff-management-page">

            <!-- =================================================
                 HEADER
                 ================================================= -->

            <div class="staff-page-header">

                <div class="staff-page-title">

                    <h1>Pengurusan Staf</h1>

                    <p>
                        Urus akaun pengguna, jawatan, jabatan, peranan dan kuota cuti staf.
                    </p>

                </div>

                <div class="user-chip">

                    <div class="avatar">
                        <%= htmlEscape(
                            name.substring(0, 1).toUpperCase()
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

                <div class="staff-alert error">

                    <%
                        if ("invalid".equals(error)) {

                            out.print(
                                "Sila lengkapkan semua maklumat yang diperlukan."
                            );

                        } else if ("invalidAction".equals(error)) {

                            out.print(
                                "Tindakan yang dipilih tidak sah."
                            );

                        } else if ("invalidRole".equals(error)) {

                            out.print(
                                "Jenis pengguna yang dipilih tidak sah."
                            );

                        } else if ("departmentRequired".equals(error)) {

                            out.print(
                                "Jabatan diperlukan untuk Staf dan Ketua Unit."
                            );

                        } else if ("invalidHod".equals(error)) {

                            out.print(
                                "Ketua Unit yang dipilih bukan daripada jabatan yang sama."
                            );

                        } else if ("emailExists".equals(error)) {

                            out.print(
                                "Alamat e-mel ini telah didaftarkan."
                            );

                        } else if ("selfRole".equals(error)) {

                            out.print(
                                "Anda tidak boleh menukar peranan Pentadbir Sistem bagi akaun anda sendiri."
                            );

                        } else if ("selfDelete".equals(error)) {

                            out.print(
                                "Anda tidak boleh memadam akaun anda sendiri."
                            );

                        } else if ("selfHod".equals(error)) {

                            out.print(
                                "Pengguna tidak boleh ditetapkan sebagai Ketua Unit kepada dirinya sendiri."
                            );

                        } else if ("notFound".equals(error)) {

                            out.print(
                                "Rekod pengguna tidak ditemui."
                            );

                        } else if ("cannotDeleteHR".equals(error)) {

                            out.print(
                                "Akaun Pentadbir Sistem tidak boleh dipadam."
                            );

                        } else if ("deleteReferenced".equals(error)) {

                            out.print(
                                "Akaun ini tidak boleh dipadam kerana mempunyai rekod sistem yang berkaitan."
                            );

                        } else if ("invalidEmail".equals(error)) {

                            out.print(
                                "Alamat e-mel yang dimasukkan tidak sah."
                            );

                        } else if ("nameLength".equals(error)) {

                            out.print(
                                "Nama yang dimasukkan terlalu panjang."
                            );

                        } else if ("positionLength".equals(error)) {

                            out.print(
                                "Jawatan yang dimasukkan terlalu panjang."
                            );

                        } else if ("invalidBalance".equals(error)) {

                            out.print(
                                "Maklumat kuota cuti tidak sah. Pastikan semua nilai menggunakan nombor bulat."
                            );

                        } else if ("quotaBelowUsed".equals(error)) {

                            out.print(
                                "Kuota baharu tidak boleh lebih rendah daripada jumlah cuti yang telah digunakan."
                            );

                        } else if ("sharedBalanceMissing".equals(error)) {

                            out.print(
                                "Rekod Cuti Tahunan atau Cuti Kecemasan tidak lengkap."
                            );

                        } else if ("balanceNotFound".equals(error)) {

                            out.print(
                                "Maklumat staf atau jenis cuti tidak ditemui."
                            );

                        } else {

                            out.print(
                                "Tindakan pengurusan staf tidak berjaya."
                            );
                        }
                    %>

                </div>

            <% } %>

            <!-- =================================================
                 SUCCESS
                 ================================================= -->

            <%
                if (
                    success != null &&
                    temporaryPassword == null
                ) {
            %>

                <div class="staff-alert success">

                    <%
                        if ("added".equals(success)) {

                            out.print(
                                "Akaun pengguna berjaya dicipta."
                            );

                        } else if ("edited".equals(success)) {

                            out.print(
                                "Maklumat pengguna berjaya dikemas kini."
                            );

                        } else if ("deleted".equals(success)) {

                            out.print(
                                "Akaun pengguna berjaya dipadam."
                            );

                        } else if ("balanceUpdated".equals(success)) {

                            out.print(
                                "Kuota cuti staf berjaya dikemas kini."
                            );

                        } else {

                            out.print(
                                "Maklumat berjaya dikemas kini."
                            );
                        }
                    %>

                </div>

            <% } %>

            <!-- =================================================
                 TEMP PASSWORD
                 ================================================= -->

            <% if (temporaryPassword != null) { %>

                <div class="temporary-password-card">

                    <h3>
                        Akaun Pengguna Berjaya Dicipta
                    </h3>

                    <p>
                        Berikan maklumat log masuk sementara berikut kepada pengguna baharu.
                    </p>

                    <div class="temporary-credentials">

                        <div class="temporary-credential">

                            <span>E-mel</span>

                            <strong>
                                <%= htmlEscape(temporaryEmail) %>
                            </strong>

                        </div>

                        <div class="temporary-credential">

                            <span>
                                Kata Laluan Sementara
                            </span>

                            <strong class="temp-password">
                                <%= htmlEscape(temporaryPassword) %>
                            </strong>

                        </div>

                    </div>

                    <p>
                        Pengguna perlu menukar kata laluan semasa log masuk kali pertama.
                    </p>

                    <form
                        method="post"
                        action="<%= request.getContextPath() %>/staff"
                    >

                        <input
                            type="hidden"
                            name="action"
                            value="clearTemp"
                        >

                        <button
                            type="submit"
                            class="staff-btn secondary"
                        >
                            Sembunyikan Maklumat
                        </button>

                    </form>

                </div>

            <% } %>

            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="staff-summary">

                <div class="staff-summary-card">

                    <span>
                        Jumlah Pengguna
                    </span>

                    <strong>
                        <%= totalUsers %>
                    </strong>

                    <small>
                        Akaun dalam sistem
                    </small>

                </div>

                <div class="staff-summary-card">

                    <span>
                        Staf
                    </span>

                    <strong>
                        <%= staffCount %>
                    </strong>

                    <small>
                        Pengguna biasa
                    </small>

                </div>

                <div class="staff-summary-card">

                    <span>
                        Ketua Unit
                    </span>

                    <strong>
                        <%= hodCount %>
                    </strong>

                    <small>
                        Ketua bahagian / unit
                    </small>

                </div>

                <div class="staff-summary-card">

                    <span>
                        Pengurusan
                    </span>

                    <strong>
                        <%= managementCount %>
                    </strong>

                    <small>
                        Pegawai kelulusan
                    </small>

                </div>

            </div>

            <!-- =================================================
                 STAFF CARD
                 ================================================= -->

            <div class="staff-shell">

                <div class="staff-shell-header">

                    <div class="staff-shell-title">

                        <h2>
                            Senarai Pengguna
                        </h2>

                        <p>
                            Maklumat pengguna dan tindakan pentadbiran staf.
                        </p>

                    </div>

                    <div class="staff-header-actions">

                        <a
                            href="<%= request.getContextPath() %>/print-staff-list"
                            class="staff-btn print"
                            target="_self"
                        >
                            Cetak Senarai Staf
                        </a>

                        <button
                            type="button"
                            class="staff-btn primary"
                            onclick="openAddModal()"
                        >
                            ＋ Tambah Pengguna
                        </button>

                    </div>

                </div>

                <div class="staff-toolbar">

                    <div class="staff-count">

                        Memaparkan

                        <strong id="visibleStaffCount">
                            <%= totalUsers %>
                        </strong>

                        pengguna

                    </div>

                    <div class="staff-search">

                        <span>⌕</span>

                        <input
                            type="text"
                            id="staffSearch"
                            placeholder="Cari nama, jawatan, e-mel, peranan atau jabatan..."
                        >

                    </div>

                </div>

                <!-- =================================================
                     MAIN TABLE
                     ================================================= -->

                <div class="staff-table-wrap">

                    <table
                        class="staff-table"
                        id="staffTable"
                    >

                        <thead>

                            <tr>
                                <th>Nama / E-mel</th>
                                <th>Jawatan</th>
                                <th>Jenis Pengguna</th>
                                <th>Jabatan</th>
                                <th>Ketua Unit</th>
                                <th>Kuota Cuti</th>
                                <th>Tindakan</th>
                            </tr>

                        </thead>

                        <tbody>

                        <%
                            if (
                                staff != null &&
                                !staff.isEmpty()
                            ) {

                                for (
                                    java.util.Map<String, Object> r :
                                    staff
                                ) {

                                    String staffRole =
                                        r.get("role") == null
                                            ? ""
                                            : String.valueOf(
                                                r.get("role")
                                            );

                                    String department =
                                        r.get("department") == null
                                            ? ""
                                            : String.valueOf(
                                                r.get("department")
                                            );

                                    String hodName =
                                        r.get("hodName") == null
                                            ? ""
                                            : String.valueOf(
                                                r.get("hodName")
                                            );

                                    String position =
                                        r.get("position") == null
                                            ? ""
                                            : String.valueOf(
                                                r.get("position")
                                            );

                                    Object hodId =
                                        r.get("hodId");
                        %>

                            <tr class="staff-row">

                                <td>

                                    <div class="staff-name">

                                        <strong>
                                            <%= htmlEscape(
                                                r.get("name")
                                            ) %>
                                        </strong>

                                        <span class="staff-email">
                                            <%= htmlEscape(r.get("email")) %>
                                        </span>

                                    </div>

                                </td>

                                <td>

                                    <% if (!position.isBlank()) { %>

                                        <span class="position-text">
                                            <%= htmlEscape(position) %>
                                        </span>

                                    <% } else { %>

                                        —

                                    <% } %>

                                </td>

                                <td>

                                    <span
                                        class="staff-role-badge <%= htmlEscape(staffRole) %>"
                                    >
                                        <%= htmlEscape(
                                            roleName(staffRole)
                                        ) %>
                                    </span>

                                </td>

                                <td>

                                    <% if (!department.isBlank()) { %>

                                        <span class="department-badge">
                                            <%= htmlEscape(
                                                departmentName(
                                                    department
                                                )
                                            ) %>
                                        </span>

                                    <% } else { %>

                                        —

                                    <% } %>

                                </td>

                                <td>

                                    <%= hodName.isBlank()
                                        ? "—"
                                        : htmlEscape(hodName)
                                    %>

                                </td>

                                <td>

                                    <button
                                        type="button"
                                        class="staff-btn gold"
                                        onclick="openBalanceModal('<%= r.get("id") %>')"
                                    >
                                        Urus Kuota Cuti
                                    </button>

                                </td>

                                <td>

                                    <div class="staff-actions">

                                        <button
                                            type="button"
                                            class="staff-btn secondary edit-staff-button"

                                            data-id="<%= htmlEscape(r.get("id")) %>"

                                            data-name="<%= htmlEscape(r.get("name")) %>"

                                            data-position="<%= htmlEscape(position) %>"

                                            data-email="<%= htmlEscape(r.get("email")) %>"

                                            data-role="<%= htmlEscape(staffRole) %>"

                                            data-department="<%= htmlEscape(department) %>"

                                            data-hod-id="<%= hodId == null
                                                ? ""
                                                : htmlEscape(hodId)
                                            %>"

                                            onclick="openEditModal(this)"
                                        >
                                            Kemaskini
                                        </button>

                                        <%
                                            if (
                                                "STAFF".equals(staffRole)
                                                ||
                                                "HOD".equals(staffRole)
                                                ||
                                                "MANAGEMENT".equals(staffRole)
                                            ) {
                                        %>

                                            <form
                                                method="post"
                                                action="<%= request.getContextPath() %>/staff"
                                                onsubmit="return confirm('Adakah anda pasti mahu memadam akaun pengguna ini?');"
                                            >

                                                <input
                                                    type="hidden"
                                                    name="action"
                                                    value="delete"
                                                >

                                                <input
                                                    type="hidden"
                                                    name="id"
                                                    value="<%= htmlEscape(
                                                        r.get("id")
                                                    ) %>"
                                                >

                                                <button
                                                    type="submit"
                                                    class="staff-btn danger"
                                                >
                                                    Padam
                                                </button>

                                            </form>

                                        <% } %>

                                    </div>

                                </td>

                            </tr>

                        <%
                                }

                            } else {
                        %>

                            <tr>

                                <td
                                    colspan="7"
                                    class="staff-empty"
                                >

                                    <div class="staff-empty-icon">
                                        ◉
                                    </div>

                                    <strong>
                                        Tiada Rekod Pengguna
                                    </strong>

                                    <p>
                                        Belum ada pengguna direkodkan dalam sistem.
                                    </p>

                                </td>

                            </tr>

                        <% } %>

                        </tbody>

                    </table>

                </div>

                <div
                    class="staff-no-search"
                    id="staffNoSearch"
                >
                    Tiada pengguna sepadan dengan carian anda.
                </div>

            </div>            <!-- =================================================
                 QUOTA MODALS
                 ================================================= -->

            <%
                if (
                    staff != null &&
                    !staff.isEmpty()
                ) {

                    for (
                        java.util.Map<String, Object> r :
                        staff
                    ) {

                        String balanceDepartment =
                            r.get("department") == null
                                ? ""
                                : String.valueOf(
                                    r.get("department")
                                );

                        String balancePosition =
                            r.get("position") == null
                                ? ""
                                : String.valueOf(
                                    r.get("position")
                                );

                        @SuppressWarnings("unchecked")
                        java.util.List<java.util.Map<String, Object>> balances =
                            (java.util.List<java.util.Map<String, Object>>)
                            r.get("balances");

                        // =========================================
                        // FIND ANNUAL + EMERGENCY
                        // =========================================

                        Integer annualTypeId = null;
                        Integer emergencyTypeId = null;

                        java.util.Map<String, Object> annualBalance =
                            null;

                        java.util.Map<String, Object> emergencyBalance =
                            null;

                        if (leaveTypes != null) {

                            for (
                                java.util.Map<String, Object> lt :
                                leaveTypes
                            ) {

                                Object typeIdObject =
                                    lt.get("id");

                                if (
                                    !(typeIdObject instanceof Number)
                                ) {
                                    continue;
                                }

                                int typeId =
                                    ((Number) typeIdObject)
                                        .intValue();

                                String leaveName =
                                    lt.get("name") == null
                                        ? ""
                                        : String.valueOf(
                                            lt.get("name")
                                        ).trim();

                                if (
                                    "Cuti Tahunan".equalsIgnoreCase(
                                        leaveName
                                    )
                                ) {

                                    annualTypeId =
                                        typeId;

                                    annualBalance =
                                        findBalance(
                                            balances,
                                            typeId
                                        );

                                } else if (
                                    "Cuti Kecemasan".equalsIgnoreCase(
                                        leaveName
                                    )
                                ) {

                                    emergencyTypeId =
                                        typeId;

                                    emergencyBalance =
                                        findBalance(
                                            balances,
                                            typeId
                                        );
                                }
                            }
                        }

                        // =========================================
                        // SHARED ENTITLEMENT
                        // =========================================

                        int annualEntitlement =
                            annualBalance == null ||
                            annualBalance.get("entitlement") == null
                                ? 0
                                : ((Number)
                                    annualBalance.get("entitlement")
                                  ).intValue();

                        int emergencyEntitlement =
                            emergencyBalance == null ||
                            emergencyBalance.get("entitlement") == null
                                ? 0
                                : ((Number)
                                    emergencyBalance.get("entitlement")
                                  ).intValue();

                        int sharedEntitlement =
                            Math.max(
                                annualEntitlement,
                                emergencyEntitlement
                            );

                        // =========================================
                        // CARRY FORWARD + CURRENT YEAR USAGE
                        // =========================================

                        int carryForwardDays =
                            annualBalance == null ||
                            annualBalance.get("carryForwardDays") == null
                                ? 0
                                : ((Number) annualBalance.get("carryForwardDays")).intValue();

                        int carryForwardUsed =
                            annualBalance == null ||
                            annualBalance.get("carryForwardUsed") == null
                                ? 0
                                : ((Number) annualBalance.get("carryForwardUsed")).intValue();

                        int carryForwardRemaining =
                            Math.max(0, carryForwardDays - carryForwardUsed);

                        int annualUsed =
                            annualBalance == null ||
                            annualBalance.get("usedDays") == null
                                ? 0
                                : ((Number) annualBalance.get("usedDays")).intValue();

                        int emergencyUsed =
                            emergencyBalance == null ||
                            emergencyBalance.get("usedDays") == null
                                ? 0
                                : ((Number) emergencyBalance.get("usedDays")).intValue();

                        int totalUsed = annualUsed + emergencyUsed;

                        // usedDays merangkumi penggunaan carry forward.
                        // Tolak carryForwardUsed supaya hanya penggunaan
                        // peruntukan tahun semasa diambil kira di sini.
                        int currentYearUsed =
                            Math.max(0, totalUsed - carryForwardUsed);

                        int currentYearRemaining =
                            Math.max(0, sharedEntitlement - currentYearUsed);

                        int sharedRemaining =
                            currentYearRemaining + carryForwardRemaining;
            %>

                <!-- =================================================
                     BALANCE MODAL
                     ================================================= -->

                <div
                    id="balanceBox-<%= r.get("id") %>"
                    class="staff-modal"
                >

                    <div class="staff-modal-box balance-modal-box">

                        <!-- =========================================
                             HEADER
                             ========================================= -->

                        <div class="staff-modal-header">

                            <div class="staff-modal-heading">

                                <h2>
                                    Urus Kuota Cuti
                                </h2>

                                <p>
                                    Laraskan kelayakan cuti staf tanpa mengubah penggunaan cuti.
                                </p>

                            </div>

                            <button
                                type="button"
                                class="staff-modal-close"
                                onclick="closeBalanceModal('<%= r.get("id") %>')"
                            >
                                &times;
                            </button>

                        </div>

                        <!-- =========================================
                             BODY
                             ========================================= -->

                        <div class="staff-modal-body">

                            <!-- =====================================
                                 STAFF INFORMATION
                                 ===================================== -->

                            <div class="balance-staff-info">

                                <div>

                                    <strong>
                                        <%= htmlEscape(
                                            r.get("name")
                                        ) %>
                                    </strong>

                                    <div>
                                        <%= balancePosition.isBlank()
                                            ? "Jawatan tidak dinyatakan"
                                            : htmlEscape(
                                                balancePosition
                                            )
                                        %>
                                    </div>

                                    <div>
                                        <%= balanceDepartment.isBlank()
                                            ? "Tiada jabatan"
                                            : htmlEscape(
                                                departmentName(
                                                    balanceDepartment
                                                )
                                            )
                                        %>
                                    </div>

                                </div>

                                <div class="balance-year">

                                    Tahun Cuti:

                                    <strong>
                                        <%= currentYear %>
                                    </strong>

                                </div>

                            </div>

                            <!-- =====================================
                                 QUOTA FORM
                                 ===================================== -->

                            <form
                                method="post"
                                action="<%= request.getContextPath() %>/leave-balance"
                                class="quota-form"
                            >

                                <input
                                    type="hidden"
                                    name="userId"
                                    value="<%= r.get("id") %>"
                                >

                                <input
                                    type="hidden"
                                    name="leaveYear"
                                    value="<%= currentYear %>"
                                >

                                <!-- =================================
                                     SHARED ANNUAL + EMERGENCY
                                     ================================= -->

                                <div class="shared-quota-card">

                                    <div class="shared-quota-header">

                                        <div>

                                            <strong class="shared-quota-title">
                                                Cuti Tahunan + Cuti Kecemasan
                                            </strong>

                                            <span class="shared-quota-subtitle">
                                                Kedua-dua jenis cuti berkongsi satu kuota yang sama.
                                            </span>

                                        </div>

                                        <span class="shared-quota-badge">
                                            KUOTA BERSAMA
                                        </span>

                                    </div>

                                    <div class="shared-quota-grid">

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Peruntukan <%= currentYear %></div>
                                            <input
                                                type="number"
                                                name="sharedEntitlement"
                                                min="<%= currentYearUsed %>"
                                                step="1"
                                                value="<%= sharedEntitlement %>"
                                                required
                                            >
                                            <div class="form-note">hari</div>
                                        </div>

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Dibawa Dari <%= currentYear - 1 %></div>
                                            <span class="carry-forward-total shared-used-value"><%= carryForwardDays %></span> hari
                                            <div class="form-note">Baki dibawa ke hadapan</div>
                                        </div>

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Baki Terdahulu Digunakan</div>
                                            <span class="carry-forward-used shared-used-value"><%= carryForwardUsed %></span> hari
                                            <div class="form-note">Digunakan daripada baki lama</div>
                                        </div>

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Baki Terdahulu</div>
                                            <span class="carry-forward-remaining shared-remaining-value"><%= carryForwardRemaining %></span> hari
                                            <div class="form-note">Baki carry forward yang masih ada</div>
                                        </div>

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Digunakan Peruntukan <%= currentYear %></div>
                                            <span class="current-year-used shared-used-value"><%= currentYearUsed %></span> hari
                                            <div class="form-note">Cuti Tahunan + Cuti Kecemasan</div>
                                        </div>

                                        <div class="shared-quota-item">
                                            <div class="shared-quota-label">Jumlah Baki Semasa</div>
                                            <span class="shared-remaining-value total-shared-remaining"><%= sharedRemaining %></span> hari
                                            <div class="form-note">Termasuk baki dibawa ke hadapan</div>
                                        </div>

                                    </div>

                                    <div class="form-note" style="margin-top:10px;">
                                        Jumlah baki semasa = baki peruntukan <%= currentYear %>
                                        + baki yang dibawa dari <%= currentYear - 1 %>.
                                    </div>

                                </div>

                                <!-- =================================
                                     OTHER LEAVE TYPES
                                     ================================= -->

                                <div class="balance-table-wrap">

                                    <table class="balance-table">

                                        <thead>

                                            <tr>

                                                <th>
                                                    Jenis Cuti
                                                </th>

                                                <th>
                                                    Kuota
                                                </th>

                                                <th>
                                                    Digunakan
                                                </th>

                                                <th>
                                                    Baki
                                                </th>

                                            </tr>

                                        </thead>

                                        <tbody>

                                        <%
                                            if (leaveTypes != null) {

                                                for (
                                                    java.util.Map<String, Object> lt :
                                                    leaveTypes
                                                ) {

                                                    Object typeIdObj =
                                                        lt.get("id");

                                                    if (
                                                        !(typeIdObj instanceof Number)
                                                    ) {
                                                        continue;
                                                    }

                                                    int leaveTypeId =
                                                        ((Number)
                                                            typeIdObj
                                                        ).intValue();

                                                    String leaveTypeName =
                                                        lt.get("name") == null
                                                            ? ""
                                                            : String.valueOf(
                                                                lt.get("name")
                                                            ).trim();

                                                    // =================================
                                                    // SHARED TYPES ALREADY ABOVE
                                                    // =================================

                                                    if (
                                                        "Cuti Tahunan".equalsIgnoreCase(
                                                            leaveTypeName
                                                        )
                                                        ||
                                                        "Cuti Kecemasan".equalsIgnoreCase(
                                                            leaveTypeName
                                                        )
                                                    ) {
                                                        continue;
                                                    }

                                                    java.util.Map<String, Object> balance =
                                                        findBalance(
                                                            balances,
                                                            leaveTypeId
                                                        );

                                                    int entitlement =
                                                        balance == null ||
                                                        balance.get("entitlement") == null
                                                            ? 0
                                                            : ((Number)
                                                                balance.get("entitlement")
                                                              ).intValue();

                                                    int usedDays =
                                                        balance == null ||
                                                        balance.get("usedDays") == null
                                                            ? 0
                                                            : ((Number)
                                                                balance.get("usedDays")
                                                              ).intValue();

                                                    int remainingDays =
                                                        Math.max(
                                                            0,
                                                            entitlement
                                                            -
                                                            usedDays
                                                        );

                                                    // =================================
                                                    // NO QUOTA
                                                    // =================================

                                                    boolean noQuota =
                                                        "Cuti Tanpa Rekod".equalsIgnoreCase(
                                                            leaveTypeName
                                                        )
                                                        ||
                                                        "Cuti Tanpa Gaji".equalsIgnoreCase(
                                                            leaveTypeName
                                                        )
                                                        ||
                                                        "Lain-lain".equalsIgnoreCase(
                                                            leaveTypeName
                                                        );
                                        %>

                                            <tr>

                                                <!-- LEAVE TYPE -->

                                                <td>

                                                    <strong>
                                                        <%= htmlEscape(
                                                            leaveTypeName
                                                        ) %>
                                                    </strong>

                                                </td>

                                                <% if (noQuota) { %>

                                                    <!-- =============================
                                                         NO QUOTA
                                                         ============================= -->

                                                    <td colspan="3">

                                                        <span class="no-quota-badge">
                                                            TIADA KUOTA
                                                        </span>

                                                        <div
                                                            class="form-note"
                                                            style="margin-top:5px;"
                                                        >
                                                            Staf boleh membuat permohonan tanpa had kuota.
                                                        </div>

                                                    </td>

                                                <% } else { %>

                                                    <!-- =============================
                                                         ENTITLEMENT
                                                         ============================= -->

                                                    <td>

                                                        <input
                                                            type="number"
                                                            name="entitlement_<%= leaveTypeId %>"
                                                            min="<%= usedDays %>"
                                                            step="1"
                                                            value="<%= entitlement %>"
                                                            required
                                                        >

                                                        <div class="form-note">
                                                            hari
                                                        </div>

                                                    </td>

                                                    <!-- =============================
                                                         USED
                                                         ============================= -->

                                                    <td>

                                                        <span class="balance-value">
                                                            <%= usedDays %>
                                                        </span>

                                                        hari

                                                    </td>

                                                    <!-- =============================
                                                         REMAINING
                                                         ============================= -->

                                                    <td>

                                                        <span class="remaining-value">
                                                            <%= remainingDays %>
                                                        </span>

                                                        hari

                                                        <div class="form-note">
                                                            Dikira automatik
                                                        </div>

                                                    </td>

                                                <% } %>

                                            </tr>

                                        <%
                                                }
                                            }
                                        %>

                                        </tbody>

                                    </table>

                                </div>

                                <!-- =================================
                                     NOTE
                                     ================================= -->

                                <div class="balance-note">

                                    Pentadbir hanya perlu mengubah

                                    <strong>
                                        kuota / kelayakan
                                    </strong>.

                                    Hari yang telah digunakan tidak boleh
                                    diubah melalui halaman ini dan baki
                                    akan dikira secara automatik oleh sistem.

                                    <br><br>

                                    <strong>
                                        Cuti Tahunan + Cuti Kecemasan
                                    </strong>

                                    menggunakan satu kuota bersama.

                                    <br>

                                    Contoh: kuota 50 hari,
                                    Tahunan digunakan 8 hari dan
                                    Kecemasan digunakan 2 hari,
                                    maka baki bersama ialah 40 hari.

                                    <br><br>

                                    <strong>
                                        Cuti Tanpa Rekod,
                                        Cuti Tanpa Gaji dan Lain-lain
                                    </strong>

                                    tidak mempunyai kuota.

                                </div>

                                <!-- =================================
                                     FOOTER
                                     ================================= -->

                                <div class="staff-modal-footer">

                                    <button
                                        type="button"
                                        class="staff-btn secondary"
                                        onclick="closeBalanceModal('<%= r.get("id") %>')"
                                    >
                                        Batal
                                    </button>

                                    <button
                                        type="submit"
                                        class="staff-btn primary"
                                    >
                                        Simpan Kuota
                                    </button>

                                </div>

                            </form>

                        </div>

                    </div>

                </div>

            <%
                    }
                }
            %>

            <!-- =================================================
                 ADD MODAL
                 ================================================= -->

            <div
                id="addBox"
                class="staff-modal"
            >

                <div class="staff-modal-box">

                    <!-- =========================================
                         HEADER
                         ========================================= -->

                    <div class="staff-modal-header">

                        <div class="staff-modal-heading">

                            <h2>
                                Tambah Pengguna
                            </h2>

                            <p>
                                Daftarkan akaun baharu ke dalam sistem PKB.
                            </p>

                        </div>

                        <button
                            type="button"
                            class="staff-modal-close"
                            onclick="closeAddModal()"
                        >
                            &times;
                        </button>

                    </div>

                    <!-- =========================================
                         BODY
                         ========================================= -->

                    <div class="staff-modal-body">

                        <form
                            method="post"
                            action="<%= request.getContextPath() %>/staff"
                            id="addStaffForm"
                        >

                            <input
                                type="hidden"
                                name="action"
                                value="add"
                            >

                            <div class="staff-form-grid">

                                <!-- NAME -->

                                <div class="staff-form-group">

                                    <label>
                                        Nama *
                                    </label>

                                    <input
                                        name="name"
                                        maxlength="120"
                                        autocomplete="name"
                                        placeholder="Nama penuh pengguna"
                                        required
                                    >

                                </div>

                                <!-- POSITION -->

                                <div class="staff-form-group">

                                    <label>
                                        Jawatan *
                                    </label>

                                    <input
                                        name="position"
                                        maxlength="150"
                                        placeholder="Contoh: Eksekutif"
                                        required
                                    >

                                </div>

                                <!-- EMAIL -->

                                <div class="staff-form-group full">

                                    <label>
                                        E-mel *
                                    </label>

                                    <input
                                        name="email"
                                        type="email"
                                        maxlength="160"
                                        autocomplete="email"
                                        placeholder="Contoh: nama@pkb.my"
                                        required
                                    >

                                </div>

                                <!-- ROLE -->

                                <div class="staff-form-group">

                                    <label>
                                        Jenis Pengguna *
                                    </label>

                                    <select
                                        id="addRole"
                                        name="role"
                                        onchange="updateAddFields()"
                                        required
                                    >

                                        <option value="STAFF">
                                            Staf
                                        </option>

                                        <option value="HOD">
                                            Ketua Unit
                                        </option>

                                        <option value="MANAGEMENT">
                                            Pengurusan
                                        </option>

                                        <option value="HR">
                                            Pentadbir Sistem
                                        </option>

                                    </select>

                                </div>

                                <!-- DEPARTMENT -->

                                <div
                                    class="staff-form-group"
                                    id="addDepartmentField"
                                >

                                    <label>
                                        Jabatan *
                                    </label>

                                    <select
                                        id="addDepartment"
                                        name="department"
                                        onchange="filterAddHods()"
                                    >

                                        <option value="">
                                            Pilih Jabatan
                                        </option>

                                        <option value="PENTADBIRAN_KORPORAT">
                                            Pentadbiran dan Korporat
                                        </option>

                                        <option value="KEWANGAN">
                                            Kewangan
                                        </option>

                                        <option value="PEMBANGUNAN_PERNIAGAAN_OPERASI">
                                            Pembangunan Perniagaan dan Operasi
                                        </option>

                                    </select>

                                </div>

                                <!-- HOD -->

                                <div
                                    class="staff-form-group full"
                                    id="addHodField"
                                >

                                    <label>
                                        Ketua Unit
                                    </label>

                                    <select
                                        id="addHod"
                                        name="hodId"
                                    >

                                        <option value="">
                                            Tiada Ketua Unit
                                        </option>

                                        <%
                                            if (hods != null) {

                                                for (
                                                    java.util.Map<String, Object> hod :
                                                    hods
                                                ) {

                                                    String hodDepartment =
                                                        hod.get("department") == null
                                                            ? ""
                                                            : String.valueOf(
                                                                hod.get("department")
                                                            );
                                        %>

                                            <option
                                                value="<%= hod.get("id") %>"
                                                data-department="<%= htmlEscape(hodDepartment) %>"
                                            >
                                                <%= htmlEscape(
                                                    hod.get("name")
                                                ) %>
                                                -
                                                <%= htmlEscape(
                                                    departmentName(
                                                        hodDepartment
                                                    )
                                                ) %>
                                            </option>

                                        <%
                                                }
                                            }
                                        %>

                                    </select>

                                    <div class="form-note">
                                        Ketua Unit tidak wajib untuk staf.
                                    </div>

                                </div>

                            </div>

                            <!-- =================================
                                 FOOTER
                                 ================================= -->

                            <div class="staff-modal-footer">

                                <button
                                    type="button"
                                    class="staff-btn secondary"
                                    onclick="closeAddModal()"
                                >
                                    Batal
                                </button>

                                <button
                                    type="submit"
                                    class="staff-btn primary"
                                >
                                    Tambah Pengguna
                                </button>

                            </div>

                        </form>

                    </div>

                </div>

            </div>

            <!-- =================================================
                 EDIT MODAL
                 ================================================= -->

            <div
                id="editBox"
                class="staff-modal"
            >

                <div class="staff-modal-box">

                    <!-- =========================================
                         HEADER
                         ========================================= -->

                    <div class="staff-modal-header">

                        <div class="staff-modal-heading">

                            <h2>
                                Kemaskini Pengguna
                            </h2>

                            <p>
                                Kemaskini maklumat dan peranan pengguna.
                            </p>

                        </div>

                        <button
                            type="button"
                            class="staff-modal-close"
                            onclick="closeEditModal()"
                        >
                            &times;
                        </button>

                    </div>

                    <!-- =========================================
                         BODY
                         ========================================= -->

                    <div class="staff-modal-body">

                        <form
                            method="post"
                            action="<%= request.getContextPath() %>/staff"
                            id="editStaffForm"
                        >

                            <input
                                type="hidden"
                                name="action"
                                value="edit"
                            >

                            <input
                                type="hidden"
                                id="editId"
                                name="id"
                            >

                            <div class="staff-form-grid">

                                <!-- NAME -->

                                <div class="staff-form-group">

                                    <label>
                                        Nama *
                                    </label>

                                    <input
                                        id="editName"
                                        name="name"
                                        maxlength="120"
                                        required
                                    >

                                </div>

                                <!-- POSITION -->

                                <div class="staff-form-group">

                                    <label>
                                        Jawatan *
                                    </label>

                                    <input
                                        id="editPosition"
                                        name="position"
                                        maxlength="150"
                                        required
                                    >

                                </div>

                                <!-- EMAIL -->

                                <div class="staff-form-group full">

                                    <label>
                                        E-mel *
                                    </label>

                                    <input
                                        id="editEmail"
                                        name="email"
                                        type="email"
                                        maxlength="160"
                                        required
                                    >

                                </div>

                                <!-- ROLE -->

                                <div class="staff-form-group">

                                    <label>
                                        Jenis Pengguna *
                                    </label>

                                    <select
                                        id="editRole"
                                        name="role"
                                        onchange="updateEditFields()"
                                        required
                                    >

                                        <option value="STAFF">
                                            Staf
                                        </option>

                                        <option value="HOD">
                                            Ketua Unit
                                        </option>

                                        <option value="MANAGEMENT">
                                            Pengurusan
                                        </option>

                                        <option value="HR">
                                            Pentadbir Sistem
                                        </option>

                                    </select>

                                </div>

                                <!-- DEPARTMENT -->

                                <div
                                    class="staff-form-group"
                                    id="editDepartmentField"
                                >

                                    <label>
                                        Jabatan *
                                    </label>

                                    <select
                                        id="editDepartment"
                                        name="department"
                                        onchange="filterEditHods()"
                                    >

                                        <option value="">
                                            Pilih Jabatan
                                        </option>

                                        <option value="PENTADBIRAN_KORPORAT">
                                            Pentadbiran dan Korporat
                                        </option>

                                        <option value="KEWANGAN">
                                            Kewangan
                                        </option>

                                        <option value="PEMBANGUNAN_PERNIAGAAN_OPERASI">
                                            Pembangunan Perniagaan dan Operasi
                                        </option>

                                    </select>

                                </div>

                                <!-- HOD -->

                                <div
                                    class="staff-form-group full"
                                    id="editHodField"
                                >

                                    <label>
                                        Ketua Unit
                                    </label>

                                    <select
                                        id="editHod"
                                        name="hodId"
                                    >

                                        <option value="">
                                            Tiada Ketua Unit
                                        </option>

                                        <%
                                            if (hods != null) {

                                                for (
                                                    java.util.Map<String, Object> hod :
                                                    hods
                                                ) {

                                                    String hodDepartment =
                                                        hod.get("department") == null
                                                            ? ""
                                                            : String.valueOf(
                                                                hod.get("department")
                                                            );
                                        %>

                                            <option
                                                value="<%= hod.get("id") %>"
                                                data-department="<%= htmlEscape(hodDepartment) %>"
                                            >
                                                <%= htmlEscape(
                                                    hod.get("name")
                                                ) %>
                                                -
                                                <%= htmlEscape(
                                                    departmentName(
                                                        hodDepartment
                                                    )
                                                ) %>
                                            </option>

                                        <%
                                                }
                                            }
                                        %>

                                    </select>

                                    <div class="form-note">
                                        Ketua Unit tidak wajib untuk staf.
                                    </div>

                                </div>

                            </div>

                            <!-- =================================
                                 FOOTER
                                 ================================= -->

                            <div class="staff-modal-footer">

                                <button
                                    type="button"
                                    class="staff-btn secondary"
                                    onclick="closeEditModal()"
                                >
                                    Batal
                                </button>

                                <button
                                    type="submit"
                                    class="staff-btn primary"
                                >
                                    Simpan Perubahan
                                </button>

                            </div>

                        </form>

                    </div>

                </div>

            </div>

        </div>

    </main>

</div><script>

// =============================================================
// BODY
// =============================================================

function lockBody() {
    document.body.style.overflow = "hidden";
}

function unlockBody() {

    const opened =
        document.querySelector(
            ".staff-modal.show"
        );

    if (!opened) {
        document.body.style.overflow = "";
    }
}

// =============================================================
// ADD MODAL
// =============================================================

function openAddModal() {

    document
        .getElementById(
            "addStaffForm"
        )
        .reset();

    document
        .getElementById(
            "addRole"
        )
        .value =
            "STAFF";

    updateAddFields();

    document
        .getElementById(
            "addBox"
        )
        .classList
        .add(
            "show"
        );

    lockBody();
}

function closeAddModal() {

    document
        .getElementById(
            "addBox"
        )
        .classList
        .remove(
            "show"
        );

    unlockBody();
}

// =============================================================
// ADD ROLE
// =============================================================

function updateAddFields() {

    const role =
        document
            .getElementById(
                "addRole"
            )
            .value;

    const departmentField =
        document
            .getElementById(
                "addDepartmentField"
            );

    const department =
        document
            .getElementById(
                "addDepartment"
            );

    const hodField =
        document
            .getElementById(
                "addHodField"
            );

    const hod =
        document
            .getElementById(
                "addHod"
            );

    // =========================================================
    // STAFF
    // =========================================================

    if (role === "STAFF") {

        departmentField
            .classList
            .remove(
                "field-hidden"
            );

        hodField
            .classList
            .remove(
                "field-hidden"
            );

        department.required =
            true;

        hod.required =
            false;

        filterAddHods();

    // =========================================================
    // HOD
    // =========================================================

    } else if (
        role === "HOD"
    ) {

        departmentField
            .classList
            .remove(
                "field-hidden"
            );

        hodField
            .classList
            .add(
                "field-hidden"
            );

        department.required =
            true;

        hod.required =
            false;

        hod.value =
            "";

    // =========================================================
    // MANAGEMENT / HR
    // =========================================================

    } else {

        departmentField
            .classList
            .add(
                "field-hidden"
            );

        hodField
            .classList
            .add(
                "field-hidden"
            );

        department.required =
            false;

        hod.required =
            false;

        department.value =
            "";

        hod.value =
            "";
    }
}

// =============================================================
// FILTER ADD HOD
// =============================================================

function filterAddHods() {

    const department =
        document
            .getElementById(
                "addDepartment"
            )
            .value;

    const hodSelect =
        document
            .getElementById(
                "addHod"
            );

    const options =
        hodSelect.querySelectorAll(
            "option"
        );

    // Reset HOD whenever department changes
    hodSelect.value =
        "";

    options.forEach(
        function(option) {

            // Always show "Tiada Ketua Unit"
            if (
                option.value === ""
            ) {

                option.hidden =
                    false;

                return;
            }

            option.hidden =
                option.dataset.department !==
                department;
        }
    );
}

// =============================================================
// EDIT MODAL
// =============================================================

function openEditModal(button) {

    const id =
        button.dataset.id;

    const staffName =
        button.dataset.name;

    const position =
        button.dataset.position;

    const email =
        button.dataset.email;

    const role =
        button.dataset.role;

    const department =
        button.dataset.department;

    const hodId =
        button.dataset.hodId;

    // =========================================================
    // SET VALUES
    // =========================================================

    document
        .getElementById(
            "editId"
        )
        .value =
            id;

    document
        .getElementById(
            "editName"
        )
        .value =
            staffName;

    document
        .getElementById(
            "editPosition"
        )
        .value =
            position;

    document
        .getElementById(
            "editEmail"
        )
        .value =
            email;

    document
        .getElementById(
            "editRole"
        )
        .value =
            role;

    document
        .getElementById(
            "editDepartment"
        )
        .value =
            department;

    // Update visible fields based on role
    updateEditFields();

    // =========================================================
    // STAFF HOD
    // =========================================================

    if (
        role === "STAFF"
    ) {

        filterEditHods();

        document
            .getElementById(
                "editHod"
            )
            .value =
                hodId;
    }

    // =========================================================
    // SHOW MODAL
    // =========================================================

    document
        .getElementById(
            "editBox"
        )
        .classList
        .add(
            "show"
        );

    lockBody();
}

function closeEditModal() {

    document
        .getElementById(
            "editBox"
        )
        .classList
        .remove(
            "show"
        );

    unlockBody();
}

// =============================================================
// EDIT ROLE
// =============================================================

function updateEditFields() {

    const role =
        document
            .getElementById(
                "editRole"
            )
            .value;

    const departmentField =
        document
            .getElementById(
                "editDepartmentField"
            );

    const department =
        document
            .getElementById(
                "editDepartment"
            );

    const hodField =
        document
            .getElementById(
                "editHodField"
            );

    const hod =
        document
            .getElementById(
                "editHod"
            );

    // =========================================================
    // STAFF
    // =========================================================

    if (
        role === "STAFF"
    ) {

        departmentField
            .classList
            .remove(
                "field-hidden"
            );

        hodField
            .classList
            .remove(
                "field-hidden"
            );

        department.required =
            true;

        hod.required =
            false;

        filterEditHods();

    // =========================================================
    // HOD
    // =========================================================

    } else if (
        role === "HOD"
    ) {

        departmentField
            .classList
            .remove(
                "field-hidden"
            );

        hodField
            .classList
            .add(
                "field-hidden"
            );

        department.required =
            true;

        hod.required =
            false;

        hod.value =
            "";

    // =========================================================
    // MANAGEMENT / HR
    // =========================================================

    } else {

        departmentField
            .classList
            .add(
                "field-hidden"
            );

        hodField
            .classList
            .add(
                "field-hidden"
            );

        department.required =
            false;

        hod.required =
            false;

        department.value =
            "";

        hod.value =
            "";
    }
}

// =============================================================
// FILTER EDIT HOD
// =============================================================

function filterEditHods() {

    const department =
        document
            .getElementById(
                "editDepartment"
            )
            .value;

    const hodSelect =
        document
            .getElementById(
                "editHod"
            );

    const currentValue =
        hodSelect.value;

    const options =
        hodSelect.querySelectorAll(
            "option"
        );

    options.forEach(
        function(option) {

            // Always show "Tiada Ketua Unit"
            if (
                option.value === ""
            ) {

                option.hidden =
                    false;

                return;
            }

            option.hidden =
                option.dataset.department !==
                department;
        }
    );

    // =========================================================
    // KEEP CURRENT HOD IF STILL VALID
    // =========================================================

    const selectedOption =
        hodSelect.querySelector(
            'option[value="' +
            currentValue +
            '"]'
        );

    if (
        selectedOption &&
        !selectedOption.hidden
    ) {

        hodSelect.value =
            currentValue;

    } else {

        hodSelect.value =
            "";
    }
}

// =============================================================
// QUOTA MODAL
// =============================================================

function openBalanceModal(userId) {

    const box =
        document.getElementById(
            "balanceBox-" +
            userId
        );

    if (box) {

        box.classList.add(
            "show"
        );

        lockBody();
    }
}

function closeBalanceModal(userId) {

    const box =
        document.getElementById(
            "balanceBox-" +
            userId
        );

    if (box) {

        box.classList.remove(
            "show"
        );

        unlockBody();
    }
}

// =============================================================
// SEARCH STAFF
// =============================================================

const staffSearch =
    document.getElementById(
        "staffSearch"
    );

if (staffSearch) {

    staffSearch.addEventListener(
        "input",
        function() {

            const keyword =
                this.value
                    .toLowerCase()
                    .trim();

            const rows =
                document.querySelectorAll(
                    ".staff-row"
                );

            let visible =
                0;

            rows.forEach(
                function(row) {

                    const text =
                        row.textContent
                            .toLowerCase();

                    const matches =
                        text.includes(
                            keyword
                        );

                    row.style.display =
                        matches
                            ? ""
                            : "none";

                    if (matches) {
                        visible++;
                    }
                }
            );

            // =================================================
            // UPDATE COUNTER
            // =================================================

            const counter =
                document.getElementById(
                    "visibleStaffCount"
                );

            if (counter) {

                counter.textContent =
                    visible;
            }

            // =================================================
            // NO RESULT
            // =================================================

            const noSearch =
                document.getElementById(
                    "staffNoSearch"
                );

            if (noSearch) {

                noSearch.style.display =
                    rows.length > 0 &&
                    visible === 0
                        ? "block"
                        : "none";
            }
        }
    );
}

// =============================================================
// WHOLE NUMBER QUOTA ONLY
// =============================================================

document
    .querySelectorAll(
        '.quota-form input[type="number"]'
    )
    .forEach(
        function(input) {

            input.addEventListener(
                "input",
                function() {

                    if (
                        this.value.includes(
                            "."
                        )
                    ) {

                        this.value =
                            this.value
                                .split(
                                    "."
                                )[0];
                    }
                }
            );
        }
    );

// =============================================================
// LIVE SHARED QUOTA CALCULATION
// =============================================================

document
    .querySelectorAll(".quota-form")
    .forEach(function(form) {

        const sharedInput =
            form.querySelector('input[name="sharedEntitlement"]');

        const currentYearUsedDisplay =
            form.querySelector(".current-year-used");

        const carryForwardRemainingDisplay =
            form.querySelector(".carry-forward-remaining");

        const remainingDisplay =
            form.querySelector(".total-shared-remaining");

        if (
            sharedInput &&
            currentYearUsedDisplay &&
            carryForwardRemainingDisplay &&
            remainingDisplay
        ) {

            const currentYearUsed =
                parseInt(currentYearUsedDisplay.textContent.trim(), 10) || 0;

            const carryForwardRemaining =
                parseInt(carryForwardRemainingDisplay.textContent.trim(), 10) || 0;

            function updateSharedRemaining() {

                const entitlement =
                    parseInt(sharedInput.value, 10) || 0;

                const currentYearRemaining =
                    Math.max(0, entitlement - currentYearUsed);

                const totalRemaining =
                    currentYearRemaining + carryForwardRemaining;

                remainingDisplay.textContent = totalRemaining;
            }

            sharedInput.addEventListener("input", updateSharedRemaining);
            updateSharedRemaining();
        }
    });

// =============================================================
// LIVE OTHER LEAVE BALANCE CALCULATION
// =============================================================

document
    .querySelectorAll(
        ".balance-table tbody tr"
    )
    .forEach(
        function(row) {

            const entitlementInput =
                row.querySelector(
                    'input[type="number"]'
                );

            const usedElement =
                row.querySelector(
                    ".balance-value"
                );

            const remainingElement =
                row.querySelector(
                    ".remaining-value"
                );

            if (
                entitlementInput &&
                usedElement &&
                remainingElement
            ) {

                const used =
                    parseInt(
                        usedElement
                            .textContent
                            .trim(),
                        10
                    ) || 0;

                function updateRemaining() {

                    const entitlement =
                        parseInt(
                            entitlementInput.value,
                            10
                        ) || 0;

                    const remaining =
                        Math.max(
                            0,
                            entitlement -
                            used
                        );

                    remainingElement.textContent =
                        remaining;
                }

                entitlementInput.addEventListener(
                    "input",
                    updateRemaining
                );
            }
        }
    );

// =============================================================
// CLICK OUTSIDE MODAL
// =============================================================

window.addEventListener(
    "click",
    function(event) {

        document
            .querySelectorAll(
                ".staff-modal.show"
            )
            .forEach(
                function(box) {

                    if (
                        event.target ===
                        box
                    ) {

                        box.classList.remove(
                            "show"
                        );

                        unlockBody();
                    }
                }
            );
    }
);

// =============================================================
// ESC KEY
// =============================================================

document.addEventListener(
    "keydown",
    function(event) {

        if (
            event.key ===
            "Escape"
        ) {

            document
                .querySelectorAll(
                    ".staff-modal.show"
                )
                .forEach(
                    function(box) {

                        box.classList.remove(
                            "show"
                        );
                    }
                );

            unlockBody();
        }
    }
);

// =============================================================
// INITIAL
// =============================================================

updateAddFields();

</script>

</body>
</html>
