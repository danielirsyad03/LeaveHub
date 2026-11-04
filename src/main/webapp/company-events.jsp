<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.util.List,java.util.Map,java.util.Date,java.util.Calendar,java.text.SimpleDateFormat" %>

<%! 


private String esc(String s) {
    return s == null || "null".equals(s)
        ? ""
        : s.replace("&", "&amp;")
           .replace("<", "&lt;")
           .replace(">", "&gt;")
           .replace("\"", "&quot;")
           .replace("'", "&#39;");
}


private String eventCategory(Map<String,Object> ev, Date now) {

    String status = String.valueOf(ev.get("status"));

    

    if (!"PUBLISHED".equalsIgnoreCase(status)) return "UPCOMING";



    Object eventDateObject = ev.get("eventDate");

    if (!(eventDateObject instanceof Date)) return "UPCOMING";



    Date eventDate = (Date) eventDateObject;

    Calendar eventDay = Calendar.getInstance();

    eventDay.setTime(eventDate);

    eventDay.set(Calendar.HOUR_OF_DAY, 0);

    eventDay.set(Calendar.MINUTE, 0);

    eventDay.set(Calendar.SECOND, 0);

    eventDay.set(Calendar.MILLISECOND, 0);



    Calendar today = Calendar.getInstance();

    today.setTime(now);

    today.set(Calendar.HOUR_OF_DAY, 0);

    today.set(Calendar.MINUTE, 0);

    today.set(Calendar.SECOND, 0);

    today.set(Calendar.MILLISECOND, 0);



    if (eventDay.after(today)) return "UPCOMING";

    if (eventDay.before(today)) return "COMPLETED";



    Calendar eventEnd = (Calendar) eventDay.clone();

    Object endTimeObject = ev.get("endTime");

    if (endTimeObject instanceof Date) {

        Calendar endTime = Calendar.getInstance();

        endTime.setTime((Date) endTimeObject);

        eventEnd.set(Calendar.HOUR_OF_DAY, endTime.get(Calendar.HOUR_OF_DAY));

        eventEnd.set(Calendar.MINUTE, endTime.get(Calendar.MINUTE));

        eventEnd.set(Calendar.SECOND, 0);

        eventEnd.set(Calendar.MILLISECOND, 0);

    } else {

        eventEnd.set(Calendar.HOUR_OF_DAY, 23);

        eventEnd.set(Calendar.MINUTE, 59);

        eventEnd.set(Calendar.SECOND, 59);

    }

    return eventEnd.getTime().before(now) ? "COMPLETED" : "TODAY";

}

private String eventCategoryLabel(String category) {

    if ("TODAY".equals(category)) return "Hari Ini";

    if ("COMPLETED".equals(category)) return "Selesai";

    if ("UPCOMING".equals(category)) return "Akan Datang";

    return "Akan Datang";

}

%>

<%

java.util.List<java.util.Map<String, Object>> events =
new java.util.ArrayList<>();

Object eventsAttribute = request.getAttribute("events");

if (eventsAttribute instanceof java.util.List<?>) {
for (Object item : (java.util.List<?>) eventsAttribute) {

if (item instanceof java.util.Map<?, ?>) {

    java.util.Map<String, Object> event =
            new java.util.HashMap<>();

    for (java.util.Map.Entry<?, ?> entry :
            ((java.util.Map<?, ?>) item).entrySet()) {

        if (entry.getKey() instanceof String) {
            event.put(
                    (String) entry.getKey(),
                    entry.getValue()
            );
        }
    }

    events.add(event);
}
}
}

 String success = (String) session.getAttribute("eventSuccess");

 String error = (String) session.getAttribute("eventError");

 session.removeAttribute("eventSuccess");

 session.removeAttribute("eventError");

 String cp = request.getContextPath();

 String currentUserName = (String) session.getAttribute("userName");

 if (currentUserName == null || currentUserName.isBlank()) currentUserName = "Pengguna";

 String currentUserInitial = currentUserName.substring(0,1).toUpperCase();

 SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");

 SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");

 Date now = new Date();

 int todayCount = 0, completedCount = 0, upcomingCount = 0;

 for (Map<String,Object> event : events) {

     String category = eventCategory(event, now);

     if ("TODAY".equals(category)) todayCount++;

     else if ("COMPLETED".equals(category)) completedCount++;

     else if ("UPCOMING".equals(category)) upcomingCount++;

     

 }

%>

<!DOCTYPE html>

<html lang="ms">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=20260927-unified">

<title>Aktiviti Syarikat | LeaveHub</title>

<style>

*{box-sizing:border-box}body{margin:0;background:#f5f6fa;color:#252638;font-family:"Segoe UI",Arial,sans-serif}.app-layout{min-height:100vh;width:100%;display:flex;align-items:stretch}.main-content{margin-left:280px;min-width:0;flex:1;width:calc(100% - 280px);padding:0!important}.page{width:100%;max-width:none;margin:0;padding:32px 38px 48px 18px}.top{display:flex;justify-content:space-between;align-items:center;gap:16px;margin-bottom:22px}html body .main-content .page h1,html body .main-content .page h2{color:#172033!important}h1{font-size:27px;margin:0;font-weight:750;line-height:1.25;color:#172033}h2{font-size:18px;margin:0 0 18px;color:#172033}.sub{margin:7px 0 0;color:#788092;font-size:13px}.card{background:#fff;border:1px solid #e7eaf0;border-radius:16px;padding:22px 20px;box-shadow:0 8px 28px rgba(23,32,51,.035);margin-bottom:20px}.field{margin-bottom:13px}.field label{display:block;font-size:12px;font-weight:700;margin-bottom:6px;color:#555b6b}input,select,textarea{width:100%;border:1px solid #d9dce5;border-radius:8px;padding:10px 11px;font:inherit;font-size:13px;background:#fff;color:#252638}textarea{min-height:100px;resize:vertical}.two{display:grid;grid-template-columns:1fr 1fr;gap:10px}.btn{display:inline-flex;align-items:center;justify-content:center;border:0;border-radius:8px;padding:10px 14px;font-weight:700;font-size:12px;cursor:pointer;text-decoration:none}.primary{background:#801b31;color:#fff;box-shadow:0 4px 10px rgba(128,27,49,.12)}.secondary{background:#f1e5e8;color:#801b31}.danger{background:#fff0f0;color:#b42318}.notice{padding:12px 14px;border-radius:9px;margin-bottom:16px;font-size:13px}.ok{background:#eaf8ef;color:#176b37}.bad{background:#fff0f0;color:#a61b1b}.table-wrap{overflow:auto}table{border-collapse:collapse;width:100%;font-size:12px}th,td{padding:11px 9px;border-bottom:1px solid #edf0f4;text-align:left;vertical-align:top}th{background:#f8f9fc;color:#172033;font-size:11px;white-space:nowrap}.titlecell{font-weight:700;color:#2c3040;min-width:160px}.muted{color:#858b99;font-size:11px;margin-top:4px;line-height:1.5}.pill{display:inline-block;padding:4px 8px;border-radius:99px;font-size:10px;font-weight:800;background:#eef0f4;color:#535a6a}.published{background:#e7f7ed;color:#187443}.completed{background:#fde8e8;color:#a61b1b}.upcoming{background:#e8efff;color:#2856a6}.today{background:#e7f7ed;color:#187443*}

.top-right{display:flex;align-items:center;justify-content:flex-end;gap:12px;flex-wrap:wrap}.top-user{display:flex;align-items:center;gap:10px}.user-chip{min-height:46px;display:flex;align-items:center;gap:9px;padding:5px 13px 5px 7px;border:1px solid #e6e9ef;border-radius:14px;background:#fff;color:#303a4c}.user-chip b{font-size:12px;font-weight:700}.user-avatar{width:34px;height:34px;display:grid;place-items:center;border:1px solid #efdade;border-radius:10px;background:linear-gradient(135deg,#fff0f2,#fff7e6);color:#801b31;font-size:12px;font-weight:800}.top h1{color:#172033!important}

.summary-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin-bottom:22px}.summary-card{position:relative;display:block;width:100%;min-width:0;text-align:left;background:#fff;border:1px solid #e4e8ef;border-radius:16px;padding:17px 16px 15px 18px;box-shadow:0 5px 18px rgba(23,32,51,.035);cursor:pointer;color:#172033;transition:border-color .15s ease,box-shadow .15s ease,transform .15s ease;font:inherit}.summary-card:before{content:"";position:absolute;left:0;top:15px;bottom:15px;width:3px;border-radius:0 3px 3px 0;background:linear-gradient(180deg,#9b1c36,#e5a526)}.summary-card:hover{border-color:#d6a2ad;box-shadow:0 7px 22px rgba(23,32,51,.07);transform:translateY(-1px)}.summary-card.active{border:2px solid #9b1c36;padding:16px 15px 14px 17px;box-shadow:0 0 0 3px rgba(128,27,49,.07)}.summary-label{display:block;color:#788092;font-size:12px;font-weight:600;letter-spacing:.25px;text-transform:uppercase;line-height:1.4}.summary-number{display:block;margin-top:7px;font-size:27px;font-weight:750;line-height:1.1;color:#172033}.summary-help{display:block;margin-top:6px;color:#858b99;font-size:11px;line-height:1.35}.summary-card:focus-visible{outline:3px solid rgba(128,27,49,.22);outline-offset:2px}.empty-filter{text-align:center;padding:30px 16px;color:#788092;font-size:13px}

.table-wrap{border:1px solid #edf0f4;border-radius:10px}table{min-width:680px}td{color:#3d4657}

@media(max-width:1200px){.summary-grid{grid-template-columns:repeat(3,minmax(0,1fr))}}@media(max-width:900px){.main-content{margin-left:0;width:100%;padding:0!important}.page{width:100%;padding:72px 16px 28px}.top{align-items:flex-start;flex-direction:column}.top-right{align-items:flex-start;flex-direction:row;justify-content:flex-start}.top-user{order:0}.summary-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:600px){.two{grid-template-columns:1fr}.top-right{flex-wrap:wrap}.top-user{flex-wrap:wrap}.summary-grid{grid-template-columns:1fr 1fr;gap:9px}.summary-card{padding:14px 12px 13px 15px}.summary-card.active{padding:13px 11px 12px 14px}.summary-number{font-size:24px}.summary-label{font-size:10px}.summary-help{font-size:10px}}

input:focus,select:focus,textarea:focus{outline:none;border-color:#b65a6c;box-shadow:0 0 0 3px rgba(128,27,49,.08)}.field label{color:#303a4c}.card form{max-width:none}

</style>

</head>

<body>

<div class="app-layout">

<%@ include file="includes/sidebar.jspf" %>

<main class="main-content">

<div class="page">

  <div class="top">

    <div><h1>Pengurusan Aktiviti Syarikat</h1><p class="sub">Urus jadual program dan aktiviti syarikat akan datang.</p></div>

    <div class="top-right"><div class="top-user"><div class="user-chip"><span class="user-avatar"><%=esc(currentUserInitial)%></span><b><%=esc(currentUserName)%></b></div></div></div>

  </div>

  <% if(success!=null){ %><div class="notice ok"><%=esc(success)%></div><% } %>

  <% if(error!=null){ %><div class="notice bad"><%=esc(error)%></div><% } %>



  <div class="card">

    <h2>Tambah Aktiviti Syarikat</h2>

    <form method="post" action="<%=cp%>/company-events">

      <input type="hidden" name="action" value="saveEvent">

      <div class="field"><label>Nama aktiviti</label><input name="event_title" maxlength="200" required></div>

      <div class="field"><label>Penerangan</label><textarea name="event_description"></textarea></div>

      <div class="field"><label>Lokasi</label><input name="location" maxlength="200"></div>

      <div class="field"><label>Tarikh aktiviti</label><input type="date" name="event_date" required></div>

      <div class="two"><div class="field"><label>Waktu mula</label><input type="time" name="start_time"></div><div class="field"><label>Waktu tamat</label><input type="time" name="end_time"></div></div>

      <button class="btn primary" type="submit">Simpan Aktiviti</button>

    </form>

  </div>



  <div class="summary-grid" aria-label="Ringkasan status aktiviti">

    <button type="button" class="summary-card active" data-filter="ALL" aria-pressed="true"><span class="summary-label">Semua</span><span class="summary-number"><%=events.size()%></span><span class="summary-help">Semua aktiviti syarikat</span></button>

    <button type="button" class="summary-card" data-filter="UPCOMING" aria-pressed="false"><span class="summary-label">Akan Datang</span><span class="summary-number"><%=upcomingCount%></span><span class="summary-help">Aktiviti pada tarikh akan datang</span></button>

    <button type="button" class="summary-card" data-filter="TODAY" aria-pressed="false"><span class="summary-label">Hari Ini</span><span class="summary-number"><%=todayCount%></span><span class="summary-help">Aktiviti hari ini yang belum tamat</span></button>

    <button type="button" class="summary-card" data-filter="COMPLETED" aria-pressed="false"><span class="summary-label">Selesai</span><span class="summary-number"><%=completedCount%></span><span class="summary-help">Aktiviti yang telah berlalu</span></button>

  </div>



  <div class="card">

    <h2>Senarai Aktiviti Syarikat</h2>

    <p id="filter-caption" class="sub" style="margin:-9px 0 14px*">Memaparkan semua aktiviti syarikat.</p>

    <div class="table-wrap">

      <table>

        <thead><tr><th>Aktiviti</th><th>Tarikh &amp; Waktu</th><th>Lokasi</th><th>Status</th><th>Tindakan</th></tr></thead>

        <tbody id="event-table-body">

        <% if(events.isEmpty()){ %><tr class="empty-row"><td colspan="5">Tiada aktiviti direkodkan.</td></tr><% } %>

        <% for(Map<String,Object> ev:events){

 
             String category = eventCategory(ev, now);

             String statusLabel = eventCategoryLabel(category);

             String pillClass = "TODAY".equals(category) ? "today" : "COMPLETED".equals(category) ? "completed" : "UPCOMING".equals(category) ? "upcoming" : "upcoming";

        %>

          <tr class="event-row" data-status="<%=category%>">

            <td><div class="titlecell"><%=esc(String.valueOf(ev.get("title")))%></div><div class="muted"><%=esc(String.valueOf(ev.get("description")))%></div></td>

            <td><%=ev.get("eventDate")==null?"-":dateFmt.format(ev.get("eventDate"))%><div class="muted"><%=ev.get("startTime")==null?"":timeFmt.format(ev.get("startTime"))%><%=ev.get("endTime")==null?"":" – "+timeFmt.format(ev.get("endTime"))%></div></td>

            <td><%=esc(String.valueOf(ev.get("location")))%></td>

            <td><span class="pill <%=pillClass%>"><%=statusLabel%></span></td>

            <td><form method="post" action="<%=cp%>/company-events" onsubmit="return confirm('Padam aktiviti ini?')"><input type="hidden" name="action" value="deleteEvent"><input type="hidden" name="id" value="<%=ev.get("id")%>"><button class="btn danger" type="submit">Padam</button></form></td>

          </tr>

        <% } %>

        </tbody>

      </table>

    </div>

    <div id="event-empty-filter" class="empty-filter" hidden="hidden">
    Tiada aktiviti bagi status ini.
</div>

  </div>

</div>

</main>

</div>

<script>

(function(){

  const cards = document.querySelectorAll('.summary-card');

  const rows = Array.from(document.querySelectorAll('.event-row'));

  const caption = document.getElementById('filter-caption');

  const emptyMessage = document.getElementById('event-empty-filter');

  const tableBody = document.getElementById('event-table-body');

  const originalEmptyRow = tableBody ? tableBody.querySelector('.empty-row') : null;

  const labels = {ALL:'semua aktiviti syarikat',UPCOMING:'aktiviti akan datang',TODAY:'aktiviti hari ini',COMPLETED:'aktiviti selesai'};

  cards.forEach(function(card){

    card.addEventListener('click', function(){

      const filter = card.getAttribute('data-filter') || 'ALL';

      cards.forEach(function(item){

        const selected = item === card;

        item.classList.toggle('active', selected);

        item.setAttribute('aria-pressed', selected ? 'true' : 'false');

      });

      let visibleCount = 0;

      rows.forEach(function(row){

        const show = filter === 'ALL' || row.getAttribute('data-status') === filter;

        row.hidden = !show;

        if(show) visibleCount++;

      });

      if(originalEmptyRow) originalEmptyRow.hidden = rows.length > 0;

      emptyMessage.hidden = visibleCount > 0 || rows.length === 0;

      if(caption) caption.textContent = 'Memaparkan ' + labels[filter] + ' (' + (filter === 'ALL' ? rows.length : visibleCount) + ').';

    });

  });

  if(originalEmptyRow) originalEmptyRow.hidden = rows.length > 0;

  if(rows.length === 0 && emptyMessage) emptyMessage.hidden = true;

})();

</script>

</body>

</html>
