<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.*" %>

<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/");
    return;
}
String role = String.valueOf(session.getAttribute("userRole"));
if (!"HR".equalsIgnoreCase(role)) {
    response.sendError(403);
    return;
}

@SuppressWarnings("unchecked")
List<Map<String,Object>> applications =
    (List<Map<String,Object>>) request.getAttribute("applications");
@SuppressWarnings("unchecked")
List<Map<String,Object>> changes =
    (List<Map<String,Object>>) request.getAttribute("changes");
@SuppressWarnings("unchecked")
Map<String,Integer> counts =
    (Map<String,Integer>) request.getAttribute("counts");

String selectedStatus = (String) request.getAttribute("selectedStatus");
if (selectedStatus == null) selectedStatus = "";
String selectedView = (String) request.getAttribute("selectedView");
if (selectedView == null) selectedView = "applications";

Integer pendingChangeCountObj =
    (Integer) request.getAttribute("pendingChangeCount");
int pendingChangeCount = pendingChangeCountObj == null ? 0 : pendingChangeCountObj;

String successMessage = request.getParameter("success");
String errorMessage = request.getParameter("error");

java.util.function.Function<Object,String> esc = value -> {
    if (value == null) return "";
    return String.valueOf(value)
        .replace("&","&amp;").replace("\"","&quot;")
        .replace("'","&#39;").replace("<","&lt;").replace(">","&gt;");
};

SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
SimpleDateFormat tf = new SimpleDateFormat("hh:mm a");
SimpleDateFormat dtf = new SimpleDateFormat("dd/MM/yyyy, hh:mm a");

int totalAll = counts == null ? 0 : counts.getOrDefault("ALL",0);
int totalPending = counts == null ? 0 : counts.getOrDefault("PENDING",0);
int totalApproved = counts == null ? 0 : counts.getOrDefault("APPROVED",0);
int totalRejected = counts == null ? 0 : counts.getOrDefault("REJECTED",0);
int totalCancelled = counts == null ? 0 : counts.getOrDefault("CANCELLED",0);
%>

<!DOCTYPE html>
<html lang="ms">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Kelulusan Kenderaan - PKB</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css?v=vehicle-approval-change-v1">
<style>
*{box-sizing:border-box}
.vehicle-approval-page{width:100%;max-width:1280px;margin:0 auto;color:#424c5d;font-size:13px}
.page-top{display:flex;align-items:flex-start;justify-content:space-between;gap:20px;margin-bottom:20px}
.page-header h1{margin:0 0 5px;color:#182238;font-size:24px;font-weight:650}
.page-header p{margin:0;color:#8792a5}
.header-actions{display:flex;align-items:center;gap:10px}
.user-box{min-height:44px;display:flex;align-items:center;gap:9px;padding:6px 12px 6px 7px;background:#fff;border:1px solid #e1e5eb;border-radius:12px}
.user-avatar{width:34px;height:34px;display:grid;place-items:center;background:#fff6ee;border:1px solid #efdcd3;border-radius:9px;color:#8f1828;font-weight:650}
.user-name{color:#273143;font-size:12px;font-weight:600}
.message{margin-bottom:16px;padding:12px 14px;border-radius:9px;font-size:12px}
.message.success{background:#eef8f2;border:1px solid #cfe7d8;color:#256847}
.message.error{background:#fff1f2;border:1px solid #efced3;color:#9f2f3a}

.main-tabs{display:flex;gap:8px;margin-bottom:18px;padding:6px;background:#f2f4f7;border-radius:11px;width:max-content;max-width:100%;overflow:auto}
.main-tab{display:flex;align-items:center;gap:8px;padding:10px 15px;border-radius:8px;text-decoration:none;color:#687386;font-size:11.5px;font-weight:650;white-space:nowrap}
.main-tab.active{background:#fff;color:#941b2b;box-shadow:0 1px 4px rgba(0,0,0,.08)}
.main-tab .count{min-width:20px;height:20px;padding:0 6px;display:grid;place-items:center;border-radius:10px;background:#eee;color:#707988;font-size:9px}
.main-tab.active .count{background:#f6e7e9;color:#941b2b}

.summary-grid{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:12px;margin-bottom:20px}
.summary-card{padding:15px;background:#fff;border:1px solid #e1e5eb;border-radius:12px;text-decoration:none}
.summary-card.active{background:#fffafa;border-color:#e2b7bd;box-shadow:inset 3px 0 0 #a6192d}
.summary-label{margin-bottom:8px;color:#818b9d;font-size:10px;font-weight:600;text-transform:uppercase}
.summary-value{color:#1d293d;font-size:21px;font-weight:650}
.summary-description{margin-top:5px;color:#8c96a6;font-size:10.5px}

.list-card{background:#fff;border:1px solid #e1e5eb;border-radius:13px;overflow:hidden}
.list-header{display:flex;align-items:center;justify-content:space-between;gap:20px;padding:18px 20px}
.list-title h2{margin:0 0 4px;color:#273143;font-size:16px}
.list-title p{margin:0;color:#8c95a2;font-size:11.5px}
.search-box{width:310px;max-width:100%}
.search-input{width:100%;height:40px;padding:0 13px;border:1px solid #dfe4eb;border-radius:9px;outline:none}

.filter-row{display:flex;gap:8px;padding:11px 20px;background:#fafbfc;border-top:1px solid #edf0f3;border-bottom:1px solid #edf0f3;overflow:auto}
.filter-pill{display:inline-flex;align-items:center;gap:6px;padding:7px 12px;background:#fff;border:1px solid #dfe4ea;border-radius:18px;color:#697589;font-size:10.5px;text-decoration:none;white-space:nowrap}
.filter-pill.active{background:#fff7f8;border-color:#e5b7be;color:#9b1729}
.filter-count{padding:2px 6px;background:#f0f2f5;border-radius:10px;font-size:9px}

.application-item,.change-item{border-bottom:1px solid #edf0f3}
.application-item:last-child,.change-item:last-child{border-bottom:0}
.application-summary,.change-summary{display:grid;grid-template-columns:1.35fr 1fr 1fr .8fr 30px;align-items:center;gap:16px;padding:15px 20px;cursor:pointer}
.application-summary:hover,.change-summary:hover{background:#fafbfc}
.summary-field-label,.info-label{margin-bottom:4px;color:#959daa;font-size:8.5px;font-weight:650;text-transform:uppercase}
.summary-field-value,.info-value{color:#465064;font-size:11.5px;line-height:1.5;word-break:break-word}
.summary-field-value.primary,.info-value.strong{color:#303a4c;font-weight:650}
.application-number{margin-top:3px;color:#9099a7;font-size:9.5px}
.expand-arrow{font-size:18px;color:#8994a5;transition:.2s}
.application-item.open .expand-arrow,.change-item.open .expand-arrow{transform:rotate(90deg)}

.status-badge{display:inline-flex;align-items:center;gap:5px;padding:5px 9px;border-radius:20px;font-size:9.5px;font-weight:600}
.status-dot{width:5px;height:5px;border-radius:50%;background:currentColor}
.status-pending{background:#fff7e6;color:#a86f0e}
.status-approved{background:#eaf7ef;color:#27845b}
.status-rejected{background:#fff0f1;color:#b83a46}
.status-cancelled{background:#f0f2f4;color:#737c89}

.application-details,.change-details{display:none;padding:0 20px 18px;background:#fbfcfd}
.application-item.open .application-details,.change-item.open .change-details{display:block}
.details-inner{padding:16px;background:#fff;border:1px solid #e5e8ed;border-radius:10px}
.info-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:15px}
.detail-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin-top:14px;padding-top:14px;border-top:1px solid #eef0f2}
.detail-box{padding:11px 12px;background:#f8f9fa;border-radius:7px}

.period-compare{display:grid;grid-template-columns:1fr 1fr;gap:13px;margin-top:14px}
.period-box{padding:14px;border:1px solid #e2e6eb;border-radius:9px;background:#fafbfc}
.period-box.new{background:#f4f8ff;border-color:#d6e0ef}
.period-title{margin-bottom:9px;color:#7c8797;font-size:9px;font-weight:700;text-transform:uppercase}
.period-date{color:#273143;font-size:12px;font-weight:650;line-height:1.6}
.reason-box{margin-top:13px;padding:12px;background:#fff9ec;border:1px solid #eee1c0;border-radius:8px;color:#6f5b2a;font-size:11.5px;line-height:1.55}

.approval-area{margin-top:15px;padding-top:15px;border-top:1px solid #eceef1}
.remark-textarea{width:100%;min-height:70px;padding:10px 12px;border:1px solid #dce0e5;border-radius:7px;resize:vertical;font:inherit}
.approval-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:10px}
.btn-action{min-height:34px;padding:7px 14px;border-radius:7px;font:600 10px inherit;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;justify-content:center}
.btn-reject{background:#fff;border:1px solid #e2bfc4;color:#a52f3b}
.btn-approve{background:#9f192c;border:1px solid #9f192c;color:#fff}
.btn-print{background:#fff;border:1px solid #d9dde4;color:#586477}
.btn-return{background:#fff8ea;border:1px solid #e7d4a5;color:#8a671a}
.decision-box{margin-top:14px;padding:11px 12px;border:1px solid #eceef1;border-radius:7px;background:#f8f9fa;font-size:11px}
.empty-state{padding:55px 20px;text-align:center;color:#929baa}

.modal-overlay{position:fixed;inset:0;z-index:9999;display:none;align-items:center;justify-content:center;padding:20px;background:rgba(17,24,39,.45)}
.modal-overlay.show{display:flex}
.modal-card{width:min(520px,100%);background:#fff;border-radius:13px;overflow:hidden}
.modal-header{display:flex;justify-content:space-between;align-items:center;padding:17px 19px;border-bottom:1px solid #eceef1}
.modal-header h3{margin:0;font-size:16px;color:#273143}
.modal-close{border:0;background:none;font-size:23px;color:#7c8593;cursor:pointer}
.modal-body{padding:19px}
.form-grid{display:grid;grid-template-columns:1fr 1fr;gap:13px}
.form-group label{display:block;margin-bottom:6px;color:#596477;font-size:10.5px;font-weight:650}
.form-group input{width:100%;padding:10px;border:1px solid #dce0e5;border-radius:8px}
.modal-footer{display:flex;justify-content:flex-end;gap:8px;padding:14px 19px;border-top:1px solid #eceef1}
.btn-secondary{padding:8px 14px;background:#fff;border:1px solid #dce0e5;border-radius:7px;cursor:pointer}

@media(max-width:900px){
.summary-grid{grid-template-columns:repeat(2,1fr)}
.application-summary,.change-summary{grid-template-columns:1fr 1fr}
.info-grid{grid-template-columns:repeat(2,1fr)}
}
@media(max-width:650px){
.page-top,.list-header{flex-direction:column}
.summary-grid,.info-grid,.detail-grid,.period-compare,.form-grid{grid-template-columns:1fr}
.application-summary,.change-summary{grid-template-columns:1fr}
.search-box{width:100%}
.approval-actions{flex-direction:column}
.btn-action{width:100%}
}
</style>
</head>
<body>
<div class="app-layout">
<%@ include file="includes/sidebar.jspf" %>
<main class="main-content">
<div class="vehicle-approval-page">

<div class="page-top">
    <div class="page-header">
        <h1>Kelulusan Kenderaan</h1>
        <p>Semak dan proses permohonan penggunaan serta perubahan tempahan kenderaan.</p>
    </div>
    <div class="header-actions">
        <jsp:include page="/includes/notification-bell.jspf" />
        <div class="user-box">
            <div class="user-avatar">H</div>
            <div class="user-name">HR Admin</div>
        </div>
    </div>
</div>

<% if(successMessage!=null&&!successMessage.isBlank()){ %>
<div class="message success"><%=esc.apply(successMessage)%></div>
<% } %>
<% if(errorMessage!=null&&!errorMessage.isBlank()){ %>
<div class="message error"><%=esc.apply(errorMessage)%></div>
<% } %>

<div class="main-tabs">
    <a class="main-tab <%= "applications".equals(selectedView)?"active":"" %>"
       href="<%=request.getContextPath()%>/vehicle-approval">
       Permohonan Kenderaan <span class="count"><%=totalPending%></span>
    </a>
    <a class="main-tab <%= "changes".equals(selectedView)?"active":"" %>"
       href="<%=request.getContextPath()%>/vehicle-approval?view=changes">
       Permohonan Perubahan <span class="count"><%=pendingChangeCount%></span>
    </a>
</div>

<% if("applications".equals(selectedView)){ %>

<div class="summary-grid">
<%
String[][] cards={
 {"","Semua",String.valueOf(totalAll),"Keseluruhan permohonan"},
 {"PENDING","Menunggu Keputusan",String.valueOf(totalPending),"Perlu tindakan"},
 {"APPROVED","Diluluskan",String.valueOf(totalApproved),"Permohonan diluluskan"},
 {"REJECTED","Tidak Diluluskan",String.valueOf(totalRejected),"Permohonan ditolak"},
 {"CANCELLED","Dibatalkan",String.valueOf(totalCancelled),"Permohonan dibatalkan"}
};
for(String[] c:cards){
 String href=request.getContextPath()+"/vehicle-approval"+(c[0].isEmpty()?"":"?status="+c[0]);
 boolean active=c[0].equals(selectedStatus);
%>
<a href="<%=href%>" class="summary-card <%=active?"active":""%>">
 <div class="summary-label"><%=c[1]%></div>
 <div class="summary-value"><%=c[2]%></div>
 <div class="summary-description"><%=c[3]%></div>
</a>
<% } %>
</div>

<div class="list-card">
<div class="list-header">
 <div class="list-title"><h2>Permohonan Kenderaan Staf</h2><p>Klik permohonan untuk melihat maklumat lengkap.</p></div>
 <div class="search-box"><input id="vehicleSearch" class="search-input" placeholder="Cari nama, kenderaan, no. plat..." oninput="filterItems('application-item','vehicleSearch')"></div>
</div>

<div class="filter-row">
<%
String[][] filters={{"","Semua",String.valueOf(totalAll)},{"PENDING","Menunggu Tindakan",String.valueOf(totalPending)},{"APPROVED","Diluluskan",String.valueOf(totalApproved)},{"REJECTED","Tidak Diluluskan",String.valueOf(totalRejected)},{"CANCELLED","Dibatalkan",String.valueOf(totalCancelled)}};
for(String[] f:filters){
 String href=request.getContextPath()+"/vehicle-approval"+(f[0].isEmpty()?"":"?status="+f[0]);
%>
<a href="<%=href%>" class="filter-pill <%=f[0].equals(selectedStatus)?"active":""%>">
 <%=f[1]%> <span class="filter-count"><%=f[2]%></span>
</a>
<% } %>
</div>

<div>
<% if(applications==null||applications.isEmpty()){ %>
<div class="empty-state"><h3>Tiada permohonan</h3><p>Tiada permohonan kenderaan ditemui.</p></div>
<% } else { for(Map<String,Object> a:applications){
 int id=((Number)a.get("id")).intValue();
 String s=String.valueOf(a.get("status"));
 String label="Menunggu Keputusan", cls="status-pending";
 if("APPROVED".equals(s)){label="Diluluskan";cls="status-approved";}
 else if("REJECTED".equals(s)){label="Tidak Diluluskan";cls="status-rejected";}
 else if("CANCELLED".equals(s)){label="Dibatalkan";cls="status-cancelled";}

 String use=a.get("use_date")==null?"":df.format(a.get("use_date"));
 String ret=a.get("expected_return_date")==null?use:df.format(a.get("expected_return_date"));
 String st=a.get("start_time")==null?"":tf.format(a.get("start_time"));
 String rt=a.get("expected_return_time")==null?"":tf.format(a.get("expected_return_time"));
 String created=a.get("created_at")==null?"":dtf.format(a.get("created_at"));

 boolean canRecordReturn=false;
 if("APPROVED".equals(s)&&a.get("use_date")!=null&&a.get("start_time")!=null&&a.get("actual_return_date")==null){
   LocalDateTime start=LocalDateTime.of(((java.sql.Date)a.get("use_date")).toLocalDate(),((java.sql.Time)a.get("start_time")).toLocalTime());
   canRecordReturn=!LocalDateTime.now().isBefore(start);
 }
%>
<div class="application-item searchable-item" onclick="toggleItem(this)">
 <div class="application-summary">
  <div><div class="summary-field-label">Pemohon</div><div class="summary-field-value primary"><%=esc.apply(a.get("applicant_name"))%></div><div class="application-number"><%=esc.apply(a.get("application_no"))%></div></div>
  <div><div class="summary-field-label">Kenderaan</div><div class="summary-field-value"><%=esc.apply(a.get("plate_number"))%> - <%=esc.apply(a.get("vehicle_name"))%></div></div>
  <div><div class="summary-field-label">Tempoh</div><div class="summary-field-value"><%=use%> · <%=st%><br>hingga <%=ret%> · <%=rt%></div></div>
  <div><span class="status-badge <%=cls%>"><span class="status-dot"></span><%=label%></span></div>
  <div class="expand-arrow">›</div>
 </div>

 <div class="application-details" onclick="event.stopPropagation()">
  <div class="details-inner">
   <div class="info-grid">
    <div><div class="info-label">Pemohon</div><div class="info-value strong"><%=esc.apply(a.get("applicant_name"))%></div></div>
    <div><div class="info-label">Pemandu</div><div class="info-value"><%=esc.apply(a.get("driver_name"))%></div></div>
    <div><div class="info-label">Tarikh & Masa Mula</div><div class="info-value"><%=use%>, <%=st%></div></div>
    <div><div class="info-label">Jangkaan Pulang</div><div class="info-value"><%=ret%>, <%=rt%></div></div>
   </div>
   <div class="detail-grid">
    <div class="detail-box"><div class="info-label">Destinasi</div><div class="info-value"><%=esc.apply(a.get("destination"))%></div></div>
    <div class="detail-box"><div class="info-label">Tujuan</div><div class="info-value"><%=esc.apply(a.get("purpose"))%></div></div>
   </div>

   <% if("PENDING".equals(s)){ %>
   <form method="post" action="<%=request.getContextPath()%>/vehicle-approval" class="approval-area">
    <input type="hidden" name="id" value="<%=id%>">
    <div class="info-label">Catatan Kelulusan</div>
    <textarea class="remark-textarea" name="approval_remark" placeholder="Catatan (pilihan)..."></textarea>
    <div class="approval-actions">
     <button class="btn-action btn-reject" name="action" value="reject" onclick="return confirm('Tolak permohonan ini?')">Tolak</button>
     <button class="btn-action btn-approve" name="action" value="approve" onclick="return confirm('Luluskan permohonan ini?')">Luluskan</button>
    </div>
   </form>
   <% } else { %>
   <div class="decision-box">
    <strong>Status:</strong> <%=label%>
    <% if(a.get("approval_remark")!=null&&!String.valueOf(a.get("approval_remark")).isBlank()){ %>
    <br><strong>Catatan:</strong> <%=esc.apply(a.get("approval_remark"))%>
    <% } %>
    <% if(a.get("actual_return_date")!=null){ %>
    <br><strong>Pulang sebenar:</strong> <%=df.format(a.get("actual_return_date"))%>,
    <%=a.get("actual_return_time")==null?"":tf.format(a.get("actual_return_time"))%>
    <% } %>
   </div>
   <div class="approval-actions">
    <% if("APPROVED".equals(s)){ %>
    <a class="btn-action btn-print" href="<%=request.getContextPath()%>/vehicle-print?id=<%=id%>">Cetak Borang</a>
    <% } %>
    <% if(canRecordReturn){ %>
    <button type="button" class="btn-action btn-return" onclick="openReturnModal(<%=id%>)">Rekod Pemulangan</button>
    <% } %>
   </div>
   <% } %>
  </div>
 </div>
</div>
<% }} %>
</div>
</div>

<% } else { %>

<div class="list-card">
<div class="list-header">
 <div class="list-title"><h2>Permohonan Perubahan Tempahan</h2><p>Semak tempoh asal dan tempoh baharu sebelum membuat keputusan.</p></div>
 <div class="search-box"><input id="changeSearch" class="search-input" placeholder="Cari pemohon, no. permohonan, kenderaan..." oninput="filterItems('change-item','changeSearch')"></div>
</div>

<div>
<% if(changes==null||changes.isEmpty()){ %>
<div class="empty-state"><h3>Tiada permohonan perubahan</h3><p>Belum ada perubahan tempahan untuk disemak.</p></div>
<% } else { for(Map<String,Object> c:changes){
 int cid=((Number)c.get("change_id")).intValue();
 String cs=String.valueOf(c.get("change_status"));
 String clabel="Menunggu Semakan", ccls="status-pending";
 if("APPROVED".equals(cs)){clabel="Diluluskan";ccls="status-approved";}
 else if("REJECTED".equals(cs)){clabel="Ditolak";ccls="status-rejected";}
 else if("CANCELLED".equals(cs)){clabel="Dibatalkan";ccls="status-cancelled";}

 String oldUse=df.format(c.get("old_use_date"));
 String oldRet=df.format(c.get("old_return_date"));
 String oldSt=tf.format(c.get("old_start_time"));
 String oldRt=tf.format(c.get("old_return_time"));
 String newUse=df.format(c.get("new_use_date"));
 String newRet=df.format(c.get("new_return_date"));
 String newSt=tf.format(c.get("new_start_time"));
 String newRt=tf.format(c.get("new_return_time"));
%>
<div class="change-item searchable-item" onclick="toggleItem(this)">
 <div class="change-summary">
  <div><div class="summary-field-label">Pemohon</div><div class="summary-field-value primary"><%=esc.apply(c.get("applicant_name"))%></div><div class="application-number"><%=esc.apply(c.get("application_no"))%></div></div>
  <div><div class="summary-field-label">Kenderaan</div><div class="summary-field-value"><%=esc.apply(c.get("plate_number"))%> - <%=esc.apply(c.get("vehicle_name"))%></div></div>
  <div><div class="summary-field-label">Tempoh Baharu</div><div class="summary-field-value"><%=newUse%> · <%=newSt%><br>hingga <%=newRet%> · <%=newRt%></div></div>
  <div><span class="status-badge <%=ccls%>"><span class="status-dot"></span><%=clabel%></span></div>
  <div class="expand-arrow">›</div>
 </div>

 <div class="change-details" onclick="event.stopPropagation()">
  <div class="details-inner">
   <div class="info-grid">
    <div><div class="info-label">No. Permohonan</div><div class="info-value strong"><%=esc.apply(c.get("application_no"))%></div></div>
    <div><div class="info-label">Pemohon</div><div class="info-value"><%=esc.apply(c.get("applicant_name"))%></div></div>
    <div><div class="info-label">Kenderaan</div><div class="info-value"><%=esc.apply(c.get("plate_number"))%> - <%=esc.apply(c.get("vehicle_name"))%></div></div>
    <div><div class="info-label">Status Tempahan Asal</div><div class="info-value"><%=esc.apply(c.get("application_status"))%></div></div>
   </div>

   <div class="period-compare">
    <div class="period-box">
     <div class="period-title">Tempahan Semasa</div>
     <div class="period-date"><%=oldUse%>, <%=oldSt%><br>hingga<br><%=oldRet%>, <%=oldRt%></div>
    </div>
    <div class="period-box new">
     <div class="period-title">Perubahan Dimohon</div>
     <div class="period-date"><%=newUse%>, <%=newSt%><br>hingga<br><%=newRet%>, <%=newRt%></div>
    </div>
   </div>

   <div class="reason-box"><strong>Sebab Perubahan</strong><br><%=esc.apply(c.get("reason"))%></div>

   <% if("PENDING".equals(cs)){ %>
   <form method="post" action="<%=request.getContextPath()%>/vehicle-approval" class="approval-area">
    <input type="hidden" name="change_id" value="<%=cid%>">
    <div class="info-label">Catatan Semakan</div>
    <textarea class="remark-textarea" name="review_remark" placeholder="Catatan kepada pemohon (pilihan)..."></textarea>
    <div class="approval-actions">
     <button class="btn-action btn-reject" name="action" value="rejectChange" onclick="return confirm('Tolak permohonan perubahan ini?')">Tolak Perubahan</button>
     <button class="btn-action btn-approve" name="action" value="approveChange" onclick="return confirm('Luluskan perubahan tempahan ini?')">Luluskan Perubahan</button>
    </div>
   </form>
   <% } else { %>
   <div class="decision-box">
    <strong>Keputusan:</strong> <%=clabel%>
    <% if(c.get("review_remark")!=null&&!String.valueOf(c.get("review_remark")).isBlank()){ %>
    <br><strong>Catatan:</strong> <%=esc.apply(c.get("review_remark"))%>
    <% } %>
    <% if(c.get("reviewed_at")!=null){ %>
    <br><strong>Diproses:</strong> <%=dtf.format(c.get("reviewed_at"))%>
    <% } %>
   </div>
   <% } %>
  </div>
 </div>
</div>
<% }} %>
</div>
</div>
<% } %>

</div>
</main>
</div>

<div class="modal-overlay" id="returnModal">
 <div class="modal-card">
  <form method="post" action="<%=request.getContextPath()%>/vehicle-approval">
   <input type="hidden" name="action" value="return">
   <input type="hidden" name="id" id="returnId">
   <div class="modal-header"><h3>Rekod Pemulangan Kenderaan</h3><button type="button" class="modal-close" onclick="closeReturnModal()">&times;</button></div>
   <div class="modal-body">
    <div class="form-grid">
     <div class="form-group"><label>Tarikh Pulang Sebenar</label><input type="date" name="actual_return_date" id="actualReturnDate" required></div>
     <div class="form-group"><label>Masa Pulang Sebenar</label><input type="time" name="actual_return_time" id="actualReturnTime" required></div>
    </div>
   </div>
   <div class="modal-footer"><button type="button" class="btn-secondary" onclick="closeReturnModal()">Tutup</button><button class="btn-action btn-approve" type="submit">Simpan Pemulangan</button></div>
  </form>
 </div>
</div>

<script>
function toggleItem(el){ el.classList.toggle("open"); }

function filterItems(className,inputId){
 const q=(document.getElementById(inputId).value||"").toLowerCase();
 document.querySelectorAll("."+className).forEach(el=>{
   el.style.display=el.innerText.toLowerCase().includes(q)?"":"none";
 });
}

function openReturnModal(id){
 document.getElementById("returnId").value=id;
 const now=new Date();
 const local=new Date(now.getTime()-now.getTimezoneOffset()*60000);
 document.getElementById("actualReturnDate").value=local.toISOString().slice(0,10);
 document.getElementById("actualReturnTime").value=local.toISOString().slice(11,16);
 document.getElementById("returnModal").classList.add("show");
}
function closeReturnModal(){document.getElementById("returnModal").classList.remove("show");}
document.getElementById("returnModal").addEventListener("click",function(e){if(e.target===this)closeReturnModal();});
</script>
</body>
</html>
