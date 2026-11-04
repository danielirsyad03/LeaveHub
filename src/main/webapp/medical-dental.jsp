<%@ page language="java" contentType="text/html; charset=UTF-8"

       pageEncoding="UTF-8"

       import="java.util.*,java.math.BigDecimal,java.math.RoundingMode,java.text.NumberFormat,java.util.Locale" %>



<%

       Boolean isAdminObj = (Boolean) request.getAttribute("isMedicalAdmin");

       boolean isMedicalAdmin = Boolean.TRUE.equals(isAdminObj);



       int benefitYear = request.getAttribute("benefitYear") == null

               ? java.time.LocalDate.now().getYear()

               : (Integer) request.getAttribute("benefitYear");



    // ===============================
    // MEDICAL & DENTAL CLAIMS
    // ===============================
    java.util.List<java.util.Map<String, Object>> claims =
            new java.util.ArrayList<>();

    Object claimsAttribute = request.getAttribute("claims");

    if (claimsAttribute instanceof java.util.List<?>) {
        for (Object item : (java.util.List<?>) claimsAttribute) {
            if (item instanceof java.util.Map<?, ?>) {

                java.util.Map<String, Object> claim =
                        new java.util.HashMap<>();

                for (java.util.Map.Entry<?, ?> entry :
                        ((java.util.Map<?, ?>) item).entrySet()) {

                    if (entry.getKey() instanceof String) {
                        claim.put(
                                (String) entry.getKey(),
                                entry.getValue()
                        );
                    }
                }

                claims.add(claim);
            }
        }
    }

    // ===============================
    // STAFF BENEFITS
    // ===============================
    java.util.List<java.util.Map<String, Object>> staffBenefits =
            new java.util.ArrayList<>();

    Object staffBenefitsAttribute = request.getAttribute("staffBenefits");

    if (staffBenefitsAttribute instanceof java.util.List<?>) {
        for (Object item : (java.util.List<?>) staffBenefitsAttribute) {
            if (item instanceof java.util.Map<?, ?>) {

                java.util.Map<String, Object> staffBenefit =
                        new java.util.HashMap<>();

                for (java.util.Map.Entry<?, ?> entry :
                        ((java.util.Map<?, ?>) item).entrySet()) {

                    if (entry.getKey() instanceof String) {
                        staffBenefit.put(
                                (String) entry.getKey(),
                                entry.getValue()
                        );
                    }
                }

                staffBenefits.add(staffBenefit);
            }
        }
    }

    // ===============================
    // ALLOCATION AUDITS
    // ===============================
    java.util.List<java.util.Map<String, Object>> allocationAudits =
            new java.util.ArrayList<>();

    Object allocationAuditsAttribute =
            request.getAttribute("allocationAudits");

    if (allocationAuditsAttribute instanceof java.util.List<?>) {
        for (Object item : (java.util.List<?>) allocationAuditsAttribute) {
            if (item instanceof java.util.Map<?, ?>) {

                java.util.Map<String, Object> allocationAudit =
                        new java.util.HashMap<>();

                for (java.util.Map.Entry<?, ?> entry :
                        ((java.util.Map<?, ?>) item).entrySet()) {

                    if (entry.getKey() instanceof String) {
                        allocationAudit.put(
                                (String) entry.getKey(),
                                entry.getValue()
                        );
                    }
                }

                allocationAudits.add(allocationAudit);
            }
        }
    }


       String printGeneratedBy = request.getAttribute("printGeneratedBy") == null

               ? "Pentadbir"

               : String.valueOf(request.getAttribute("printGeneratedBy"));



       String printRole = request.getAttribute("printRole") == null

               ? "HR"

               : String.valueOf(request.getAttribute("printRole"));



       boolean showAllClaims =

               Boolean.TRUE.equals(request.getAttribute("showAllClaims"));
    boolean autoPrintClaims = Boolean.TRUE.equals(request.getAttribute("autoPrintClaims"));



       Object claimStaffIdObj = request.getAttribute("claimStaffId");



       String selectedClaimStaffId = claimStaffIdObj == null

               ? ""

               : String.valueOf(claimStaffIdObj);



       NumberFormat rm = NumberFormat.getNumberInstance(new Locale("ms", "MY"));

       rm.setMinimumFractionDigits(2);

       rm.setMaximumFractionDigits(2);



       java.util.function.Function<Object,String> esc = value ->

               value == null ? "" :

               String.valueOf(value)

                   .replace("&","&amp;")

                   .replace("<","&lt;")

                   .replace(">","&gt;")

                   .replace("\"","&quot;")

                   .replace("'","&#39;");



       java.util.function.Function<Object,String> money = value ->

               "RM " + rm.format(

                   value == null ? BigDecimal.ZERO :

                   new BigDecimal(value.toString())

               );



       String flash = (String) session.getAttribute("medicalDentalFlash");

       String error = (String) session.getAttribute("medicalDentalError");



       session.removeAttribute("medicalDentalFlash");

       session.removeAttribute("medicalDentalError");

%>



<!DOCTYPE html>

<html lang="ms">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">



<title>Pengurusan Perubatan &amp; Pergigian | LeaveHub PKB</title>



<link rel="stylesheet"

         href="<%= request.getContextPath() %>/css/style.css">



<style>

.md-page{padding:0 0 36px;color:#172033}

.md-header{display:flex;justify-content:space-between;align-items:flex-start;gap:18px;margin-bottom:24px}

.md-header h1{font-size:28px;margin:0;font-weight:750}

.md-header p{margin:7px 0 0;color:#7b8799;font-size:14px}

.md-header-actions{display:flex;justify-content:flex-end;margin-bottom:8px}

.md-year{background:#fff;border:1px solid #e4e8ef;border-radius:12px;padding:10px 14px;color:#596579;font-size:13px;font-weight:700}



.md-flash{padding:13px 16px;border-radius:10px;margin-bottom:18px;font-size:14px}

.md-success{background:#e9f8ef;color:#17653b;border:1px solid #c8ecd5}

.md-error{background:#fff0ef;color:#a62d27;border:1px solid #f6d0cc}



.md-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;margin-bottom:24px}

.md-card,.md-panel{background:#fff;border:1px solid #e5e9f0;border-radius:16px;padding:22px;box-shadow:0 4px 16px rgba(24,39,75,.035);min-width:0}

.md-panel{margin-bottom:22px}

.md-panel-head{display:flex;justify-content:space-between;align-items:flex-start;gap:16px;margin-bottom:18px}

.md-panel h2{font-size:19px;margin:0}

.md-panel-head p{margin:5px 0 0;color:#7b8799;font-size:13px}



.md-card-top{display:flex;align-items:center;gap:13px}

.md-icon{width:46px;height:46px;border-radius:13px;display:grid;place-items:center;font-size:23px;background:#e9f2ff}

.md-icon.dental{background:#fff0dc}

.md-icon svg{width:23px;height:23px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}

.md-card h2{font-size:17px;margin:0}

.md-muted{color:#788397;font-size:13px}

.md-balance{font-size:28px;font-weight:800;margin:18px 0 5px;letter-spacing:-.6px}

.md-green{color:#217448}

.md-gold{color:#a86b1f}

.md-track{height:8px;border-radius:99px;background:#edf0f5;overflow:hidden;margin:14px 0 15px}

.md-track span{height:100%;display:block;border-radius:99px;background:#258052}

.md-track .dental-fill{background:#c28a3c}

.md-stats{display:flex;justify-content:space-between;gap:12px;font-size:13px;color:#707b8e}



.md-form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}

.md-field{display:flex;flex-direction:column;gap:7px}

.md-field.full{grid-column:1/-1}

.md-field label{font-size:12px;font-weight:750;color:#586477}

.md-field input,.md-field select,.md-field textarea{

       width:100%;box-sizing:border-box;border:1px solid #dce2eb;

       border-radius:9px;background:#fff;padding:11px 12px;

       font:inherit;font-size:14px;color:#172033

}

.md-field textarea{min-height:84px;resize:vertical}

.md-hint{font-size:12px;color:#8490a1}

.md-note{font-size:12px;color:#7b8799;line-height:1.5;margin-top:10px}



.md-btn{border:0;border-radius:9px;padding:11px 16px;font-weight:700;font-size:13px;cursor:pointer;background:#982638;color:white}

.md-btn:hover{background:#7f1d2d}

.md-btn.secondary{background:#eef3f8;color:#31445c;border:1px solid #dce4ed}



.md-table-wrap{width:100%;overflow-x:auto}

.md-table{width:100%;border-collapse:collapse;min-width:760px;font-size:13px}

.md-table th{text-align:left;color:#758196;font-size:11px;letter-spacing:.04em;text-transform:uppercase;background:#f8fafc;padding:12px;border-bottom:1px solid #e9edf3;white-space:nowrap}

.md-table td{padding:13px 12px;border-bottom:1px solid #edf0f4;vertical-align:top}

.md-table tr:last-child td{border-bottom:0}

.md-pill{display:inline-block;padding:5px 8px;border-radius:7px;background:#edf4ff;color:#245b93;font-size:11px;font-weight:800;white-space:nowrap}

.md-pill.dental{background:#fff2df;color:#99621d}

.md-empty{text-align:center;padding:32px;color:#8490a1;font-size:14px}

.md-link{color:#245b93;text-decoration:none;font-weight:700}



.md-history-tools{display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:16px}

.md-history-tools select{min-width:220px;max-width:100%;border:1px solid #dce2eb;border-radius:9px;padding:10px 12px;background:#fff;color:#172033;font:inherit;font-size:13px}

.md-tool-btn{display:inline-flex;align-items:center;justify-content:center;padding:10px 13px;border-radius:9px;background:#982638;color:#fff;border:1px solid #982638;text-decoration:none;font-size:12px;font-weight:700;cursor:pointer}

.md-tool-btn:hover{background:#7f1d2d;color:#fff;border-color:#7f1d2d}



.md-print-header{display:none}

.md-print-brand{display:flex;align-items:center;gap:12px;border-bottom:3px solid #982638;padding-bottom:12px;margin-bottom:16px}

.md-print-logo img{display:block;max-width:78px;max-height:42px;object-fit:contain}

.md-print-brand-name{font-size:16px;font-weight:800;color:#982638}

.md-print-subbrand{font-size:10px;color:#64748b;margin-top:3px}

.md-print-title{text-align:center;margin:16px 0 14px}

.md-print-title h2{font-size:19px;margin:0;color:#172033}

.md-print-title p{font-size:10px;color:#64748b;margin:4px 0 0}

.md-print-meta{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;margin-bottom:14px}

.md-print-meta div{border:1px solid #e2e8f0;background:#f8fafc;padding:8px;border-radius:5px;font-size:10px}

.md-print-meta b{display:block;font-size:9px;color:#64748b;text-transform:uppercase;margin-bottom:4px}

.md-print-meta span{font-weight:700;color:#334155}



@media(max-width:760px){

       .md-grid{grid-template-columns:1fr}

       .md-header{flex-direction:column}

       .md-form-grid{grid-template-columns:1fr}

       .md-field.full{grid-column:auto}

       .md-card,.md-panel{padding:17px}

       .md-header h1{font-size:24px}

}



@media print {
    @page {
        size: A4 landscape;
        margin: 10mm;
    }

    html,
    body {
        width: 100% !important;
        height: auto !important;
        min-height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        background: #fff !important;
        overflow: visible !important;
    }

    /*
     * Jangan gunakan visibility:hidden kerana ia masih mengekalkan
     * ruang elemen tersembunyi dan menghasilkan halaman kosong.
     * Kekalkan hanya kandungan utama.
     */
    body > * {
        display: none !important;
    }

    body > main.main-content {
        display: block !important;
        position: static !important;
        width: 100% !important;
        max-width: none !important;
        height: auto !important;
        min-height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: visible !important;
        transform: none !important;
    }

    main.main-content > .md-page {
        display: block !important;
        width: 100% !important;
        max-width: none !important;
        height: auto !important;
        min-height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: visible !important;
    }

    /* Dalam halaman utama, cetak bahagian sejarah tuntutan sahaja. */
    .md-page > *:not(#claims-history) {
        display: none !important;
    }

    #claims-history {
        display: block !important;
        position: static !important;
        float: none !important;
        width: 100% !important;
        max-width: none !important;
        height: auto !important;
        min-height: 0 !important;
        max-height: none !important;
        margin: 0 !important;
        padding: 0 !important;
        border: 0 !important;
        border-radius: 0 !important;
        box-shadow: none !important;
        background: #fff !important;
        overflow: visible !important;
        break-inside: auto !important;
        page-break-inside: auto !important;
    }

    #claims-history .md-print-header {
        display: block !important;
    }

    #claims-history .md-history-tools,
    #claims-history .md-panel-head .md-history-actions {
        display: none !important;
    }

    .md-print-brand {
        display: flex !important;
        align-items: center !important;
        border-bottom: 3px solid #982638 !important;
        padding-bottom: 10px !important;
        margin-bottom: 12px !important;
    }

    .md-print-logo img {
        display: block !important;
        width: 135px !important;
        max-width: 135px !important;
        max-height: 75px !important;
        object-fit: contain !important;
    }

    .md-print-brand-name {
        font-size: 16pt !important;
        color: #982638 !important;
    }

    .md-print-subbrand {
        font-size: 8pt !important;
    }

    .md-print-title {
        display: block !important;
        text-align: center !important;
        margin: 12px 0 !important;
    }

    .md-print-title h2 {
        font-size: 15pt !important;
    }

    .md-print-title p {
        font-size: 8pt !important;
    }

    .md-print-meta {
        display: grid !important;
        grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
        gap: 8px !important;
    }

    .md-table-wrap {
        display: block !important;
        width: 100% !important;
        height: auto !important;
        max-height: none !important;
        overflow: visible !important;
    }

    .md-table {
        display: table !important;
        width: 100% !important;
        min-width: 0 !important;
        max-width: none !important;
        table-layout: auto !important;
        border-collapse: collapse !important;
        font-size: 8pt !important;
    }

    .md-table thead {
        display: table-header-group !important;
    }

    .md-table tbody {
        display: table-row-group !important;
    }

    .md-table tr {
        break-inside: avoid !important;
        page-break-inside: avoid !important;
    }

    .md-table th,
    .md-table td {
        padding: 5px !important;
        border: 1px solid #d8dee8 !important;
        overflow-wrap: anywhere !important;
        white-space: normal !important;
    }

    .md-table th {
        background: #982638 !important;
        color: #fff !important;
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }

    .md-pill {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
    }

    a {
        color: inherit !important;
        text-decoration: none !important;
    }
}

</style>

</head>



<body>



<%@ include file="includes/sidebar.jspf" %>



<main class="main-content">

<div class="md-page">



       <div class="md-header">

           <div>

               <h1>Pengurusan Perubatan &amp; Pergigian</h1>

               <p>

                   <%= isMedicalAdmin

                       ? "Urus peruntukan tahunan, baki manfaat dan rekod tuntutan semua staf."

                       : "Semak baki manfaat perubatan dan pergigian anda." %>

               </p>

           </div>



           <div>

               <div class="md-header-actions">

                   <%@ include file="includes/header-actions.jspf" %>

               </div>

               <div class="md-year">TAHUN MANFAAT <%= benefitYear %></div>

           </div>

       </div>



       <% if (flash != null) { %>

           <div class="md-flash md-success"><%= esc.apply(flash) %></div>

       <% } %>



       <% if (error != null) { %>

           <div class="md-flash md-error"><%= esc.apply(error) %></div>

       <% } %>



       <% if (!isMedicalAdmin) { %>



       <div class="md-grid">



           <div class="md-card">

               <div class="md-card-top">

                   <div class="md-icon" aria-hidden="true">

                       <svg viewBox="0 0 24 24">

                           <path d="M12 21s-7-4.2-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 11c0 5.8-7 10-7 10z"/>

                           <path d="M12 8v7M8.5 11.5h7"/>

                       </svg>

                   </div>

                   <div>

                       <h2>Perubatan</h2>

                       <div class="md-muted">Peruntukan tahunan</div>

                   </div>

               </div>



               <div class="md-balance md-green">

                   <%= money.apply(request.getAttribute("medicalBalance")) %>

               </div>



               <div class="md-muted">Baki tersedia</div>



               <div class="md-track">

                   <span style="width:<%=

                       request.getAttribute("medicalAllocation") == null

                       || new BigDecimal(request.getAttribute("medicalAllocation").toString()).signum()==0

                       ? 0

                       : Math.max(0,Math.min(100,

                           new BigDecimal(request.getAttribute("medicalBalance").toString())

                           .multiply(new BigDecimal("100"))

                           .divide(new BigDecimal(request.getAttribute("medicalAllocation").toString()),0,RoundingMode.HALF_UP)

                           .doubleValue()))

                   %>%"></span>

               </div>



               <div class="md-stats">

                   <span>Peruntukan: <b><%= money.apply(request.getAttribute("medicalAllocation")) %></b></span>

                   <span>Digunakan: <b><%= money.apply(request.getAttribute("medicalUsed")) %></b></span>

               </div>

           </div>



           <div class="md-card">

               <div class="md-card-top">

                   <div class="md-icon dental" aria-hidden="true">

                       <svg viewBox="0 0 24 24">

                           <path d="M7 3c-2.4 0-4 2-3 5l2.4 9.2c.4 1.5 1.1 2.8 2.1 2.8 1.5 0 1.5-5 3.5-5s2 5 3.5 5c1 0 1.7-1.3 2.1-2.8L20 8c1-3-0.6-5-3-5-1.9 0-2.8 1-5 1S8.9 3 7 3z"/>

                       </svg>

                   </div>

                   <div>

                       <h2>Pergigian</h2>

                       <div class="md-muted">Peruntukan tahunan</div>

                   </div>

               </div>



               <div class="md-balance md-gold">

                   <%= money.apply(request.getAttribute("dentalBalance")) %>

               </div>



               <div class="md-muted">Baki tersedia</div>



               <div class="md-track">

                   <span class="dental-fill" style="width:<%=

                       request.getAttribute("dentalAllocation") == null

                       || new BigDecimal(request.getAttribute("dentalAllocation").toString()).signum()==0

                       ? 0

                       : Math.max(0,Math.min(100,

                           new BigDecimal(request.getAttribute("dentalBalance").toString())

                           .multiply(new BigDecimal("100"))

                           .divide(new BigDecimal(request.getAttribute("dentalAllocation").toString()),0,RoundingMode.HALF_UP)

                           .doubleValue()))

                   %>%"></span>

               </div>



               <div class="md-stats">

                   <span>Peruntukan: <b><%= money.apply(request.getAttribute("dentalAllocation")) %></b></span>

                   <span>Digunakan: <b><%= money.apply(request.getAttribute("dentalUsed")) %></b></span>

               </div>

           </div>



       </div>



       <% } %>



       <% if (isMedicalAdmin) { %>



       <!-- REKOD TUNTUTAN -->



       <div class="md-panel">

           <div class="md-panel-head">

               <div>

                   <h2>Rekod Tuntutan Baharu</h2>

                   <p>Masukkan bil penuh. Sistem mengira sumbangan PKB dan lebihan bayaran staf secara automatik.</p>

               </div>

           </div>



           <form method="post"

                 action="<%= request.getContextPath() %>/medical-dental-management"

                 enctype="multipart/form-data">



               <input type="hidden" name="action" value="recordClaim">



               <div class="md-form-grid">



                   <div class="md-field">

                       <label for="userId">Nama staf *</label>

                       <select id="userId" name="userId" required>

                           <option value="">Pilih nama staf</option>

                           <% for(Map<String,Object> s : staffBenefits) { %>

                               <option value="<%= s.get("id") %>">

                                   <%= esc.apply(s.get("name")) %>

                               </option>

                           <% } %>

                       </select>

                   </div>



                   <div class="md-field">

                       <label for="claimType">Jenis tuntutan *</label>

                       <select id="claimType" name="claimType" required>

                           <option value="MEDICAL">Perubatan</option>

                           <option value="DENTAL">Pergigian</option>

                       </select>

                   </div>



                   <div class="md-field">

                       <label for="treatmentDate">Tarikh rawatan *</label>

                       <input type="date" id="treatmentDate" name="treatmentDate" required>

                   </div>



                   <div class="md-field">

                       <label for="billAmount">Jumlah bil (RM) *</label>

                       <input type="number" id="billAmount" name="billAmount"

                              min="0.01" step="0.01" placeholder="0.00" required>

                   </div>



                   <div class="md-field full">

                       <label for="description">Keterangan rawatan *</label>

                       <textarea id="description" name="description"

                                 maxlength="1000"

                                 placeholder="Contoh: konsultasi doktor, ubat atau rawatan pergigian"

                                 required></textarea>

                   </div>



                   <div class="md-field full">

                       <label for="supportingDocument">Dokumen sokongan (pilihan)</label>

                       <input type="file" id="supportingDocument"

                              name="supportingDocument"

                              accept=".pdf,.jpg,.jpeg,.png">

                       <div class="md-hint">Format PDF, JPG, JPEG atau PNG. Maksimum 5 MB.</div>

                   </div>



                   <div class="md-field full">

                       <button class="md-btn" type="submit">

                           Rekod Tuntutan &amp; Kemas Kini Baki

                       </button>

                       <div class="md-note">

                           Tiada proses kelulusan berasingan. Selepas direkod,

                           jumlah yang layak ditanggung PKB akan ditolak daripada

                           baki manfaat. Lebihan bil menjadi tanggungan staf.

                       </div>

                   </div>



               </div>

           </form>

       </div>



       <!-- SENARAI PERUNTUKAN SEMUA STAF -->



       <div class="md-panel">

           <div class="md-panel-head">

               <div>

                   <h2>Peruntukan Staf</h2>

                   <p>Baki dan penggunaan manfaat bagi tahun <%= benefitYear %>.</p>

               </div>

           </div>



           <div class="md-table-wrap">

               <table class="md-table">

                   <thead>

                       <tr>

                           <th>Staf</th>

                           <th>Peruntukan Perubatan</th>

                           <th>Digunakan</th>

                           <th>Baki</th>

                           <th>Peruntukan Pergigian</th>

                           <th>Digunakan</th>

                           <th>Baki</th>

                       </tr>

                   </thead>

                   <tbody>

                       <% if (staffBenefits.isEmpty()) { %>

                           <tr><td colspan="7" class="md-empty">Tiada rekod staf.</td></tr>

                       <% } else {

                           for(Map<String,Object> s : staffBenefits) { %>

                           <tr>

                               <td><b><%= esc.apply(s.get("name")) %></b></td>

                               <td><%= money.apply(s.get("medicalAllocation")) %></td>

                               <td><%= money.apply(s.get("medicalUsed")) %></td>

                               <td><b><%= money.apply(s.get("medicalBalance")) %></b></td>

                               <td><%= money.apply(s.get("dentalAllocation")) %></td>

                               <td><%= money.apply(s.get("dentalUsed")) %></td>

                               <td><b><%= money.apply(s.get("dentalBalance")) %></b></td>

                           </tr>

                       <% } } %>

                   </tbody>

               </table>

           </div>

       </div>



       <!-- PENGURUSAN PERUNTUKAN STAF -->



       <div class="md-panel" id="allocation-settings">



           <div class="md-panel-head">

               <div>

                   <h2>Pengurusan Peruntukan Manfaat Staf</h2>

                   <p>

                       Semua staf menerima kadar standard. Admin boleh

                       menetapkan kadar khas bagi staf tertentu mengikut

                       kelayakan jawatan.

                   </p>

               </div>

           </div>



           <form method="post"

                 action="<%= request.getContextPath() %>/medical-dental-management">



               <input type="hidden" name="action" value="updateAllocation">



               <div class="md-form-grid">



                   <div class="md-field">

                       <label for="allocationUserId">Nama staf *</label>



                       <select id="allocationUserId" name="userId" required>

                           <option value="">Pilih nama staf</option>



                           <% for (Map<String, Object> s : staffBenefits) { %>

    <option value="<%= s.get("id") %>"
            data-medical="<%= esc.apply(s.get("medicalAllocation")) %>"
            data-dental="<%= esc.apply(s.get("dentalAllocation")) %>">

        <%= esc.apply(s.get("name")) %>

    </option>

<% } %>

                       </select>

                   </div>



                   <div class="md-field">

                       <label for="medicalAllocation">

                           Peruntukan perubatan tahunan (RM) *

                       </label>

                       <input type="number" id="medicalAllocation"

                              name="medicalAllocation"

                              min="0" step="0.01"

                              value="1500.00" required>

                   </div>



                   <div class="md-field">

                       <label for="dentalAllocation">

                           Peruntukan pergigian tahunan (RM) *

                       </label>

                       <input type="number" id="dentalAllocation"

                              name="dentalAllocation"

                              min="0" step="0.01"

                              value="200.00" required>

                   </div>



                   <div class="md-field full">

                       <label for="allocationReason">Sebab perubahan peruntukan *</label>

                       <textarea id="allocationReason"

                                 name="allocationReason"

                                 maxlength="1000"

                                 placeholder="Contoh: Kelayakan khas mengikut jawatan pengurusan"

                                 required></textarea>

                   </div>



                   <div class="md-field full">

                       <div class="md-note">

                           <b>Kadar standard:</b><br>

                           Perubatan: RM1,500.00<br>

                           Pergigian: RM200.00<br><br>

                           Peruntukan khas akan digunakan bagi tahun manfaat

                           semasa dan tahun seterusnya. Perubahan kadar tidak

                           memadam sejarah tuntutan atau mengubah jumlah yang

                           telah digunakan.

                       </div>

                   </div>



                   <div class="md-field full">

                       <button class="md-btn secondary" type="submit">

                           Simpan Peruntukan Staf

                       </button>

                   </div>



               </div>

           </form>

       </div>



       <!-- SEJARAH PERUBAHAN KADAR -->



       <div class="md-panel" id="allocation-audit">

           <div class="md-panel-head">

               <div>

                   <h2>Sejarah Perubahan Peruntukan</h2>

                   <p>Rekod pentadbiran bagi setiap perubahan kadar manfaat staf.</p>

               </div>

           </div>



           <div class="md-table-wrap">

               <table class="md-table">

                   <thead>

                       <tr>

                           <th>Staf</th>

                           <th>Perubatan Sebelum</th>

                           <th>Perubatan Selepas</th>

                           <th>Pergigian Sebelum</th>

                           <th>Pergigian Selepas</th>

                           <th>Sebab</th>

                           <th>Diubah Oleh</th>

                           <th>Tarikh</th>

                       </tr>

                   </thead>



                   <tbody>

                       <% if (allocationAudits.isEmpty()) { %>

                           <tr>

                               <td colspan="8" class="md-empty">

                                   Belum ada rekod perubahan peruntukan.

                               </td>

                           </tr>

                       <% } else {

                           for(Map<String,Object> a : allocationAudits) { %>

                           <tr>

                               <td><b><%= esc.apply(a.get("staffName")) %></b></td>

                               <td><%= money.apply(a.get("oldMedical")) %></td>

                               <td><b><%= money.apply(a.get("newMedical")) %></b></td>

                               <td><%= money.apply(a.get("oldDental")) %></td>

                               <td><b><%= money.apply(a.get("newDental")) %></b></td>

                               <td><%= esc.apply(a.get("reason")) %></td>

                               <td><%= esc.apply(a.get("adminName")) %></td>

                               <td><%= esc.apply(a.get("createdAt")) %></td>

                           </tr>

                       <% } } %>

                   </tbody>

               </table>

           </div>

       </div>



       <% } %>



       <!-- SEJARAH TUNTUTAN -->



       <div class="md-panel" id="claims-history">



           <div class="md-print-header">



               <div class="md-print-brand">

                   <div class="md-print-logo">

                       <img src="<%= request.getContextPath() %>/images/logo-pkb.png"

                            alt="Logo PKB">

                   </div>



                   <div>

                       <div class="md-print-brand-name">Permodalan Kedah Berhad</div>

                       <div class="md-print-subbrand">PKB Staff Management System</div>

                   </div>

               </div>



               <div class="md-print-title">

                   <h2>Sejarah Tuntutan Perubatan &amp; Pergigian</h2>

                   <p>Rekod audit manfaat perubatan dan pergigian</p>

               </div>



               <div class="md-print-meta">

                   <div><b>Dicetak oleh</b><span><%= esc.apply(printGeneratedBy) %></span></div>

                   <div><b>Peranan</b><span><%= esc.apply(printRole) %></span></div>

                   <div>

                       <b>Tarikh cetakan</b>

                       <span><%= java.time.LocalDateTime.now().format(

                           java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")

                       ) %></span>

                   </div>

               </div>

           </div>



           <div class="md-panel-head">

               <div>

                   <h2>

                       <%= isMedicalAdmin

                           ? "Sejarah Tuntutan Semua Staf"

                           : "Sejarah Tuntutan Saya" %>

                   </h2>

                   <p>

                       Rekod bil, sumbangan PKB dan lebihan yang ditanggung staf.

                   </p>

               </div>



               <% if (isMedicalAdmin) { %>

                   <div class="md-history-actions">
                       <a class="md-tool-btn"
                          href="<%= request.getContextPath() %>/medical-dental-management?claims=all&amp;autoPrint=1#claims-history">
                           Cetak Semua Staf
                       </a>
                   </div>

               <% } %>

           </div>



           <% if (isMedicalAdmin) { %>



               <form class="md-history-tools"
                     method="get"
                     action="<%= request.getContextPath() %>/medical-dental-management#claims-history">
                   <input type="hidden" name="claims" value="all">
                   <input type="hidden" name="autoPrint" value="1">



                   <label for="claimStaffId" class="md-muted">

                       Pilih staf untuk cetakan individu:

                   </label>



                   <select id="claimStaffId" name="claimStaffId" required>

                       <option value="" disabled <%= selectedClaimStaffId.isEmpty() ? "selected" : "" %>>Pilih nama staf</option>



                       <% for(Map<String,Object> s : staffBenefits) { %>

                           <option value="<%= s.get("id") %>"

                               <%= String.valueOf(s.get("id")).equals(selectedClaimStaffId)

                                   ? "selected" : "" %>>

                               <%= esc.apply(s.get("name")) %>

                           </option>

                       <% } %>

                   </select>



                   <button class="md-tool-btn" type="submit">
                       Cetak Staf Dipilih
                   </button>



               </form>



               <% if (!selectedClaimStaffId.isEmpty()) { %>

                   <p class="md-note">

                       Paparan individu: rekod tuntutan untuk staf yang dipilih sahaja.

                   </p>

               <% } %>



           <% } %>



           <div class="md-table-wrap">

               <table class="md-table">

                   <thead>

                       <tr>

                           <% if(isMedicalAdmin) { %><th>Staf</th><% } %>

                           <th>Tarikh</th>

                           <th>Jenis</th>

                           <th>Keterangan</th>

                           <th>Jumlah bil</th>

                           <th>PKB bayar</th>

                           <th>Staf bayar</th>

                           <th>Dokumen</th>

                           <% if(isMedicalAdmin) { %><th>Direkod oleh</th><% } %>

                       </tr>

                   </thead>



                   <tbody>

                       <% if(claims.isEmpty()) { %>

                           <tr>

                               <td colspan="<%= isMedicalAdmin ? 9 : 7 %>"

                                   class="md-empty">

                                   Belum ada tuntutan direkodkan.

                               </td>

                           </tr>

                       <% } else {

                           for(Map<String,Object> c : claims) { %>



                           <tr>

                               <% if(isMedicalAdmin) { %>

                                   <td><b><%= esc.apply(c.get("staffName")) %></b></td>

                               <% } %>



                               <td><%= esc.apply(c.get("treatmentDate")) %></td>



                               <td>

                                   <span class="md-pill    <%= "DENTAL".equals(c.get("claimType")) ? "dental" : "" %>">

                                       <%= "DENTAL".equals(c.get("claimType"))

                                           ? "Pergigian" : "Perubatan" %>

                                   </span>

                               </td>



                               <td><%= esc.apply(c.get("description")) %></td>



                               <td><b><%= money.apply(c.get("billAmount")) %></b></td>

                               <td><%= money.apply(c.get("pkbAmount")) %></td>

                               <td><%= money.apply(c.get("staffAmount")) %></td>



                               <td>

                                   <% if(c.get("documentPath") != null

                                       && !String.valueOf(c.get("documentPath")).isBlank()) { %>



                                       <a class="md-link"

                                          href="<%= request.getContextPath() %>/medical-dental-document?id=<%= c.get("id") %>"

                                          target="_blank"

                                          rel="noopener">

                                           Lihat dokumen

                                       </a>



                                   <% } else { %>

                                       <span class="md-muted">Tiada</span>

                                   <% } %>

                               </td>



                               <% if(isMedicalAdmin) { %>

                                   <td><%= esc.apply(c.get("recorderName")) %></td>

                               <% } %>

                           </tr>



                       <% } } %>

                   </tbody>

               </table>

           </div>



       </div>



</div>

</main>



<script>

(function () {



       const staffSelect = document.getElementById('allocationUserId');

       const medicalInput = document.getElementById('medicalAllocation');

       const dentalInput = document.getElementById('dentalAllocation');



       if (staffSelect && medicalInput && dentalInput) {



           staffSelect.addEventListener('change', function () {



               const option =

                   staffSelect.options[staffSelect.selectedIndex];



               if (!option || !option.value) {

                   medicalInput.value = '1500.00';

                   dentalInput.value = '200.00';

                   return;

               }



               medicalInput.value =

                   option.dataset.medical || '1500.00';



               dentalInput.value =

                   option.dataset.dental || '200.00';

           });

       }



})();

</script>



<script>

(function () {



       let previousPrintSection = null;



       function restoreAfterPrint() {



           if (previousPrintSection === null) {

               document.body.removeAttribute('data-print-section');

           } else {

               document.body.setAttribute(

                   'data-print-section',

                   previousPrintSection

               );

           }



           previousPrintSection = null;

           window.removeEventListener('afterprint', restoreAfterPrint);

       }



       window.printSection = function (id) {



           const section = document.getElementById(id);



           if (!section) {

               alert('Bahagian yang hendak dicetak tidak dijumpai.');

               return;

           }



           // Cetak dalam tab semasa.

           previousPrintSection =

               document.body.getAttribute('data-print-section');



           document.body.setAttribute('data-print-section', id);



           window.addEventListener(

               'afterprint',

               restoreAfterPrint,

               { once: true }

           );



           requestAnimationFrame(function () {

               requestAnimationFrame(function () {

                   window.print();

               });

           });

       };



       window.addEventListener('afterprint', restoreAfterPrint);



})();

</script>



<% if (isMedicalAdmin && autoPrintClaims) { %>
<script>
window.addEventListener('load', function () {
    window.printSection('claims-history');
});
</script>
<% } %>
</body>

</html>
