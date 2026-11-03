<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List,java.util.Map,java.text.SimpleDateFormat" %>

<%! private String esc(String s) { return s == null || "null".equals(s) ? "" : s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }

private String departmentLabel(String department) {

    if (department == null || "null".equals(department)) return "Tiada jabatan";

    switch (department.trim().toUpperCase(java.util.Locale.ROOT)) {

        case "PENTADBIRAN_KORPORAT": return "Pentadbiran Korporat";

        case "KEWANGAN": return "Kewangan";

        case "PEMBANGUNAN_PERNIAGAAN_OPERASI": return "Pembangunan Perniagaan & Operasi";

        default: return department.replace('_', ' ');

    }

} %>

<%

    List<Map<String,Object>> announcements = (List<Map<String,Object>>) request.getAttribute("announcements");

    List<Map<String,Object>> events = (List<Map<String,Object>>) request.getAttribute("events");

    List<Map<String,Object>> staff = (List<Map<String,Object>>) request.getAttribute("staff");

    if (announcements == null) announcements = new java.util.ArrayList<>();

    if (events == null) events = new java.util.ArrayList<>();

    if (staff == null) staff = new java.util.ArrayList<>();

    String success = (String) session.getAttribute("announcementSuccess");

    String error = (String) session.getAttribute("announcementError");

    session.removeAttribute("announcementSuccess");

    session.removeAttribute("announcementError");

    String cp = request.getContextPath();

    String currentUserName = (String) session.getAttribute("userName");

    if (currentUserName == null || currentUserName.isBlank()) currentUserName = "Pengguna";

    String currentUserInitial = currentUserName.substring(0, 1).toUpperCase();

    SimpleDateFormat dt = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");

    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");

    int allCount = announcements.size();

    int activeCount = 0, expiredCount = 0, scheduledCount = 0;

    java.util.Date statusNow = new java.util.Date();

    for (Map<String,Object> item : announcements) {

        String itemStatus = String.valueOf(item.get("status"));

        Object itemPublished = item.get("publishedAt");

        Object itemExpires = item.get("expiresAt");

        boolean itemFuture = itemPublished instanceof java.util.Date && ((java.util.Date)itemPublished).after(statusNow);

        boolean itemExpired = itemExpires instanceof java.util.Date && !((java.util.Date)itemExpires).after(statusNow);

        if (itemExpired) expiredCount++;

 
        else if ("SCHEDULED".equalsIgnoreCase(itemStatus) || ("PUBLISHED".equalsIgnoreCase(itemStatus) && itemFuture)) scheduledCount++;

        else if ("PUBLISHED".equalsIgnoreCase(itemStatus)) activeCount++;

    }

%>

<!DOCTYPE html>

<html lang="ms">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260927-unified">

<title>Pengurusan Pengumuman | LeaveHub</title>

<style>

\*{box-sizing:border-box}

body{margin:0;background:#f5f6fa;color:#252638;font-family:"Segoe UI",Arial,sans-serif}

.app-layout{min-height:100vh;width:100%;display:flex;align-items:stretch}

.main-content{margin-left:280px;min-width:0;flex:1;width:calc(100% - 280px);padding:0!important}

.page{width:100%;max-width:none;margin:0;padding:32px 38px 48px 18px}

.top{display:flex;justify-content:space-between;align-items:center;gap:16px;margin-bottom:22px}

html body .main-content .page h1,html body .main-content .page h2{color:#172033!important}

h1{font-size:27px;margin:0;font-weight:750;line-height:1.25;color:#172033}

h2{font-size:18px;margin:0 0 18px;color:#172033}

.sub{margin:7px 0 0;color:#788092;font-size:13px}

.card{background:#fff;border:1px solid #e7eaf0;border-radius:16px;padding:22px 20px;box-shadow:0 8px 28px rgba(23,32,51,.035);margin-bottom:20px}

.status-summary{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin:0 0 20px}

.status-card{position:relative;display:block;width:100%;text-align:left;min-width:0;background:#fff;border:1px solid #e7eaf0;border-radius:16px;padding:18px 16px 16px 20px;box-shadow:0 8px 28px rgba(23,32,51,.035);overflow:hidden;cursor:pointer;font:inherit;transition:border-color .15s ease,box-shadow .15s ease,transform .15s ease}

.status-card:before{content:"";position:absolute;left:0;top:14px;bottom:14px;width:3px;border-radius:0 4px 4px 0;background:#801b31}

.status-card.expired-card:before{background:#b42318}.status-card.scheduled-card:before{background:#3268b2}

.status-label{display:block;color:#788092;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.25px;margin-bottom:8px}

.status-number{font-size:28px;line-height:1;font-weight:750;color:#172033}.status-card:hover{transform:translateY(-1px);box-shadow:0 10px 30px rgba(23,32,51,.08)}.status-card:focus-visible{outline:3px solid rgba(128,27,49,.22);outline-offset:2px}.status-card.is-selected{border-color:#801b31;box-shadow:0 0 0 2px rgba(128,27,49,.10),0 8px 28px rgba(23,32,51,.05)}.status-card.all-card:before{background:#52647d}.status-card.is-selected:before{width:4px}.filter-summary{font-size:12px;color:#788092;margin:-7px 0 14px}.filter-summary strong{color:#303a4c}

@media(max-width:1100px){.status-summary{grid-template-columns:repeat(3,minmax(0,1fr))}}

@media(max-width:900px){.status-summary{grid-template-columns:repeat(2,minmax(0,1fr))}}

@media(max-width:480px){.status-summary{grid-template-columns:1fr 1fr;gap:9px}.status-card{padding:15px 10px 14px 15px}.status-label{font-size:10px}.status-number{font-size:24px}}

.field{margin-bottom:13px}

.field label{display:block;font-size:12px;font-weight:700;margin-bottom:6px;color:#303a4c}

input,select,textarea{width:100%;border:1px solid #d9dce5;border-radius:8px;padding:10px 11px;font:inherit;font-size:13px;background:#fff;color:#252638}

textarea{min-height:100px;resize:vertical}

.two{display:grid;grid-template-columns:1fr 1fr;gap:10px}

.btn{display:inline-flex;align-items:center;justify-content:center;border:0;border-radius:8px;padding:10px 14px;font-weight:700;font-size:12px;cursor:pointer;text-decoration:none}

.primary{background:#801b31;color:#fff;box-shadow:0 4px 10px rgba(128,27,49,.12)}

.secondary{background:#f1e5e8;color:#801b31}

.danger{background:#fff0f0;color:#b42318}

.notice{padding:12px 14px;border-radius:9px;margin-bottom:16px;font-size:13px}

.ok{background:#eaf8ef;color:#176b37}

.bad{background:#fff0f0;color:#a61b1b}

.table-wrap{overflow:auto;border:1px solid #edf0f4;border-radius:10px}

table{border-collapse:collapse;width:100%;min-width:680px;font-size:12px}

th,td{padding:11px 9px;border-bottom:1px solid #edf0f4;text-align:left;vertical-align:top}

th{background:#f8f9fc;color:#172033;font-size:11px;white-space:nowrap}

td{color:#3d4657}

.titlecell{font-weight:700;color:#2c3040;min-width:160px}

.muted{color:#858b99;font-size:11px;margin-top:4px;line-height:1.5}

.pill{display:inline-block;padding:4px 8px;border-radius:99px;font-size:10px;font-weight:800;background:#eef0f4;color:#535a6a}

.published{background:#e7f7ed;color:#187443}



.scheduled{background:#e8f1ff;color:#2459a9}

.expired{background:#fff0f0;color:#b42318}

.checklist{border:1px solid #e0e2e9;border-radius:8px;padding:8px;max-height:145px;overflow:auto}

.checkitem{display:flex;gap:8px;align-items:center;padding:5px;font-size:12px}

.checkitem input{width:auto}

.section-note{font-size:11px;color:#7c8493;line-height:1.5;margin:-8px 0 15px}

.top-right{display:flex;align-items:center;justify-content:flex-end;gap:12px;flex-wrap:wrap}

.top-user{display:flex;align-items:center;gap:10px}

.notification-button{width:46px;height:46px;display:inline-flex;align-items:center;justify-content:center;border:1px solid #e6e9ef;border-radius:14px;background:#fff;color:#64748b;text-decoration:none;font-size:20px;box-shadow:0 4px 14px rgba(25,35,55,.04)}

.user-chip{min-height:46px;display:flex;align-items:center;gap:9px;padding:5px 13px 5px 7px;border:1px solid #e6e9ef;border-radius:14px;background:#fff;color:#303a4c}

.user-chip b{font-size:12px;font-weight:700}

.user-avatar{width:34px;height:34px;display:grid;place-items:center;border:1px solid #efdade;border-radius:10px;background:linear-gradient(135deg,#fff0f2,#fff7e6);color:#801b31;font-size:12px;font-weight:800}

input:focus,select:focus,textarea:focus{outline:none;border-color:#b65a6c;box-shadow:0 0 0 3px rgba(128,27,49,.08)}

.card form{max-width:none}

@media(max-width:900px){.main-content{margin-left:0;width:100%;padding:0!important}.page{width:100%;padding:72px 16px 28px}.top{align-items:flex-start;flex-direction:column}.top-right{align-items:flex-start;flex-direction:row}.top-user{order:0}}

@media(max-width:600px){.two{grid-template-columns:1fr}.top-right{flex-wrap:wrap}.card{padding:20px 16px}}

</style>

</head>

<body>

<div class="app-layout">

<%@ include file="includes/sidebar.jspf" %>

<main class="main-content">

<div class="page">

<div class="top"><div><h1>Pengurusan Pengumuman</h1><p class="sub">Urus pengumuman dan makluman rasmi kepada staf.</p></div><div class="top-right"><div class="top-user"><div class="user-chip"><span class="user-avatar"><%=esc(currentUserInitial)%></span><b><%=esc(currentUserName)%></b></div></div></div></div>

<% if(success!=null){ %><div class="notice ok"><%=esc(success)%></div><% } %>

<% if(error!=null){ %><div class="notice bad"><%=esc(error)%></div><% } %>

<div class="card">

<h2>Tambah Pengumuman</h2>

<p class="section-note">Tarikh terbitan boleh dijadualkan. Biarkan tarikh tamat kosong jika pengumuman tiada tarikh tamat.</p>

<form method="post" action="<%=cp%>/announcements">

<input type="hidden" name="action" value="saveAnnouncement">

<div class="field"><label>Tajuk</label><input name="title" maxlength="200" required></div>

<div class="field"><label>Kandungan</label><textarea name="content" required></textarea></div>

<div class="two">

<div class="field"><label>Kategori</label><select name="category"><option value="UMUM">Umum</option><option value="PENTING">Penting</option><option value="HR">HR</option><option value="NOTIS">Notis</option></select></div>



</div>

<div class="field"><label>Sasaran penerima</label><select name="audience_type" id="audience" onchange="toggleAudience()"><option value="ALL">Semua staf</option><option value="DEPARTMENT">Jabatan tertentu</option><option value="SELECTED_STAFF">Staf tertentu</option></select></div>

<div class="field" id="departmentField" hidden><label>Jabatan</label><select name="target_department"><option value="">-- Pilih jabatan --</option>

<% java.util.Set<String> departments = new java.util.TreeSet<>(); for(Map<String,Object> s:staff){ if(s.get("department")!=null && !s.get("department").toString().isBlank()) departments.add(s.get("department").toString()); } for(String dep:departments){ %><option value="<%=esc(dep)%>"><%=esc(departmentLabel(dep))%></option><% } %>

</select></div>

<div class="field" id="staffField" hidden><label>Pilih staf (boleh pilih lebih daripada seorang)</label><div class="checklist">

<% for(Map<String,Object> s:staff){ %><label class="checkitem"><input type="checkbox" name="staff_ids" value="<%=s.get("id")%>"><span><%=esc(String.valueOf(s.get("name")))%> <span class="muted">— <%=esc(departmentLabel(s.get("department")==null?null:String.valueOf(s.get("department"))))%></span></span></label><% } %>

</div></div>

<div class="two">

<div class="field"><label>Tarikh/waktu terbitan</label><input type="datetime-local" name="published_at"></div>

<div class="field"><label>Tarikh/waktu tamat (pilihan)</label><input type="datetime-local" name="expires_at"></div>

</div>

<button class="btn primary" type="submit">Simpan Pengumuman</button>

</form>

</div>

<div class="status-summary" aria-label="Ringkasan status pengumuman">

  <button type="button" class="status-card all-card is-selected" data-filter="ALL" aria-pressed="true"><span class="status-label">Semua</span><div class="status-number"><%=allCount%></div></button>

  <button type="button" class="status-card active-card" data-filter="ACTIVE" aria-pressed="false"><span class="status-label">Aktif</span><div class="status-number"><%=activeCount%></div></button>

  <button type="button" class="status-card expired-card" data-filter="EXPIRED" aria-pressed="false"><span class="status-label">Tamat Tempoh</span><div class="status-number"><%=expiredCount%></div></button>

  <button type="button" class="status-card scheduled-card" data-filter="SCHEDULED" aria-pressed="false"><span class="status-label">Dijadualkan</span><div class="status-number"><%=scheduledCount%></div></button>

</div>

<div class="card">

<h2>Senarai Pengumuman</h2>

<p class="filter-summary" id="announcementFilterSummary">Memaparkan <strong>Semua</strong> pengumuman.</p>

<div class="table-wrap"><table><thead><tr><th>Pengumuman</th><th>Penerima</th><th>Status</th><th>Jadual</th><th>Tindakan</th></tr></thead><tbody id="announcementTableBody">

<% if(announcements.isEmpty()){ %><tr id="noAnnouncementsRow"><td colspan="5">Tiada pengumuman direkodkan.</td></tr><% } for(Map<String,Object> a:announcements){ String st=String.valueOf(a.get("status")); String aud=String.valueOf(a.get("audienceType")); String audienceLabel="Semua staf"; if("DEPARTMENT".equals(aud)) audienceLabel="Jabatan: "+departmentLabel(String.valueOf(a.get("targetDepartment"))); else if("SELECTED_STAFF".equals(aud)) audienceLabel="Staf terpilih"; String statusLabel="Diterbitkan"; String statusClass="published"; String statusKey="ACTIVE"; java.util.Date now=new java.util.Date(); Object publishedValue=a.get("publishedAt"); Object expiresValue=a.get("expiresAt"); boolean isFuturePublish=publishedValue instanceof java.util.Date && ((java.util.Date)publishedValue).after(now); boolean isExpired=expiresValue instanceof java.util.Date && !((java.util.Date)expiresValue).after(now); if(isExpired){statusLabel="Tamat Tempoh";statusClass="expired";statusKey="EXPIRED";} else if("PUBLISHED".equalsIgnoreCase(st)){ if(isFuturePublish){statusLabel="Dijadualkan";statusClass="scheduled";statusKey="SCHEDULED";}else{statusLabel="Diterbitkan";statusClass="published";statusKey="ACTIVE";} } else if("SCHEDULED".equalsIgnoreCase(st)){statusLabel="Dijadualkan";statusClass="scheduled";statusKey="SCHEDULED";} else if(!"DRAFT".equalsIgnoreCase(st)){statusLabel=st;} %>

<tr data-status="<%=statusKey%>"><td><div class="titlecell"><%=esc(String.valueOf(a.get("title")))%></div><div class="muted"><%=esc(String.valueOf(a.get("category")))%> · Oleh <%=esc(String.valueOf(a.get("creatorName")))%></div><div class="muted"><%=esc(String.valueOf(a.get("content")))%></div></td><td><%=esc(audienceLabel)%></td><td><span class="pill <%=statusClass%>"><%=esc(statusLabel)%></span></td><td><div><b>Terbit:</b> <%=a.get("publishedAt")==null?"Serta-merta / belum ditetapkan":dt.format(a.get("publishedAt"))%></div><div class="muted"><b>Tamat:</b> <%=a.get("expiresAt")==null?"Tiada tamat":dt.format(a.get("expiresAt"))%></div></td><td><form method="post" action="<%=cp%>/announcements" onsubmit="return confirm('Padam pengumuman ini?')"><input type="hidden" name="action" value="deleteAnnouncement"><input type="hidden" name="id" value="<%=a.get("id")%>"><button class="btn danger" type="submit">Padam</button></form></td></tr>

<% } %>

<tr id="noFilteredAnnouncementsRow" hidden><td colspan="5">Tiada pengumuman bagi status ini.</td></tr>

</tbody></table></div>

</div>

</div>

</main>

</div>

<script>

function toggleAudience(){

 const value=document.getElementById('audience').value;

 document.getElementById('departmentField').hidden=value!=='DEPARTMENT';

 document.getElementById('staffField').hidden=value!=='SELECTED_STAFF';

}

toggleAudience();

(function(){

 const cards = Array.from(document.querySelectorAll('.status-card[data-filter]'));

 const rows = Array.from(document.querySelectorAll('#announcementTableBody tr[data-status]'));

 const summary = document.getElementById('announcementFilterSummary');

 const emptyFiltered = document.getElementById('noFilteredAnnouncementsRow');

 const labels = {ALL:'Semua', ACTIVE:'Aktif', EXPIRED:'Tamat Tempoh', SCHEDULED:'Dijadualkan'};

 function applyAnnouncementFilter(filter) {

   let visibleCount = 0;

   rows.forEach(function(row) {

     const show = filter === 'ALL' || row.dataset.status === filter;

     row.hidden = !show;

     if (show) visibleCount++;

   });

   if (emptyFiltered) emptyFiltered.hidden = visibleCount !== 0;

   cards.forEach(function(card) {

     const selected = card.dataset.filter === filter;

     card.classList.toggle('is-selected', selected);

     card.setAttribute('aria-pressed', selected ? 'true' : 'false');

   });

   if (summary) summary.innerHTML = 'Memaparkan <strong>' + labels[filter] + '</strong> pengumuman (' + visibleCount + ').';

 }

 cards.forEach(function(card) { card.addEventListener('click', function() { applyAnnouncementFilter(card.dataset.filter); }); });

 applyAnnouncementFilter('ALL');

})();

(function(){

 const openBtn=document.getElementById('mobileMenuButton');

 const closeBtn=document.getElementById('sidebarCloseButton');

 const overlay=document.getElementById('sidebarOverlay');

 function openSidebar(){document.body.classList.add('sidebar-mobile-open');}

 function closeSidebar(){document.body.classList.remove('sidebar-mobile-open');}

 if(openBtn) openBtn.addEventListener('click',openSidebar);

 if(closeBtn) closeBtn.addEventListener('click',closeSidebar);

 if(overlay) overlay.addEventListener('click',closeSidebar);

})();

</script>

</body>

</html>
