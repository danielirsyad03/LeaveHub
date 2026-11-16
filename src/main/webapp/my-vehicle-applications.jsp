<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.*" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> applications =
        (List<Map<String,Object>>) request.getAttribute("applications");

    @SuppressWarnings("unchecked")
    Map<String,Integer> counts =
        (Map<String,Integer>) request.getAttribute("counts");

    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null) selectedStatus = "";

    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");

    Object sessionNameObj = session.getAttribute("userName");
    String userName = sessionNameObj == null ? "Pengguna" : String.valueOf(sessionNameObj);
    if (userName.isBlank()) userName = "Pengguna";
    String userInitial = userName.substring(0,1).toUpperCase();

    java.util.function.Function<Object,String> esc = value -> {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    };

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy, hh:mm a");

    int totalAll = counts == null ? 0 : counts.getOrDefault("ALL", 0);
    int totalPending = counts == null ? 0 : counts.getOrDefault("PENDING", 0);
    int totalApproved = counts == null ? 0 : counts.getOrDefault("APPROVED", 0);
    int totalRejected = counts == null ? 0 : counts.getOrDefault("REJECTED", 0);
    int totalCancelled = counts == null ? 0 : counts.getOrDefault("CANCELLED", 0);
%>

<!DOCTYPE html>
<html lang="ms">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Permohonan Kenderaan Saya - PKB</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=my-vehicle-20261006-v1">

<style>
* { box-sizing: border-box; }
html, body { width:100%; max-width:100%; margin:0; overflow-x:hidden; }
.app-layout { width:100%; max-width:100%; min-width:0; }
.main-content { flex:1 1 0; width:auto; max-width:none; min-width:0; overflow-x:hidden; }
.vehicle-page { width:100%; max-width:100%; min-width:0; color:#424c5d; font-size:14px; }

.vehicle-page-header {
    display:flex; align-items:center; justify-content:space-between;
    gap:20px; margin-bottom:20px;
}
.vehicle-page-title h1 {
    margin:0 0 6px; color:#172033; font-size:27px;
    font-weight:750; line-height:1.2;
}
.vehicle-page-title p { margin:0; color:#7f899a; font-size:14px; }
.vehicle-header-actions { display:flex; align-items:center; gap:10px; }
.vehicle-user-chip {
    display:flex; align-items:center; gap:10px; min-height:46px;
    padding:6px 14px 6px 7px; background:#fff;
    border:1px solid #e5e8ed; border-radius:12px;
}
.vehicle-user-avatar {
    width:34px; height:34px; display:grid; place-items:center;
    border-radius:9px; background:#fff0f2; color:#8d1f2d;
    border:1px solid #efd8dc; font-weight:700;
}
.vehicle-user-name { color:#2e3748; font-size:13px; font-weight:650; }

.top-action-row { display:flex; justify-content:flex-end; margin-bottom:18px; }
.btn-new {
    display:inline-flex; align-items:center; justify-content:center;
    min-height:42px; padding:10px 17px; background:#971d2d;
    border:1px solid #971d2d; border-radius:8px; color:#fff;
    font-size:12.5px; font-weight:650; text-decoration:none;
}
.btn-new:hover { background:#7e1724; }

.message {
    margin-bottom:16px; padding:13px 15px;
    border-radius:9px; font-size:13px; line-height:1.5;
}
.message.success { background:#eef8f2; border:1px solid #cfe7d8; color:#256847; }
.message.error { background:#fff1f2; border:1px solid #efced3; color:#9f2f3a; }

.summary-grid {
    display:grid; grid-template-columns:repeat(4,minmax(0,1fr));
    gap:13px; margin-bottom:18px;
}
.summary-card {
    display:flex; align-items:center; gap:13px; min-height:100px;
    padding:16px; background:#fff; border:1px solid #e3e6eb;
    border-radius:13px;
}
.summary-icon {
    width:43px; height:43px; display:flex; align-items:center;
    justify-content:center; border-radius:10px; font-size:17px;
}
.pending .summary-icon { background:#fff7e7; color:#b87b13; }
.approved .summary-icon { background:#eef8f2; color:#27845b; }
.rejected .summary-icon { background:#fff0f1; color:#b83a46; }
.cancelled .summary-icon { background:#f1f3f5; color:#707988; }
.summary-label {
    margin-bottom:5px; color:#7e8999; font-size:11px;
    font-weight:700; text-transform:uppercase;
}
.summary-value { color:#172033; font-size:23px; font-weight:700; }

.list-card {
    background:#fff; border:1px solid #e3e6eb;
    border-radius:14px; overflow:hidden;
}
.list-card-header { padding:20px 20px 0; }
.list-card-header h2 { margin:0 0 5px; color:#273143; font-size:17px; }
.list-card-header p { margin:0; color:#8c95a2; font-size:12.5px; }

.tabs {
    display:flex; gap:6px; margin-top:18px;
    border-bottom:1px solid #e8eaee; overflow-x:auto;
}
.tab {
    display:inline-flex; align-items:center; gap:7px;
    padding:11px 13px; border-bottom:2px solid transparent;
    color:#748094; font-size:12px; font-weight:600;
    text-decoration:none; white-space:nowrap;
}
.tab.active { border-bottom-color:#8d1f2d; color:#8d1f2d; }
.tab-count {
    min-width:21px; padding:2px 6px; background:#f1f3f5;
    border-radius:10px; font-size:10px; text-align:center;
}

.application-list { padding:16px; }
.application-item {
    margin-bottom:13px; border:1px solid #e4e7ec;
    border-radius:11px; overflow:hidden;
}
.application-top {
    display:flex; align-items:center; justify-content:space-between;
    gap:15px; padding:14px 16px; background:#fafbfc;
    border-bottom:1px solid #eceef1;
}
.application-no-label, .info-label {
    margin-bottom:5px; color:#8e98a7; font-size:10px;
    font-weight:650; text-transform:uppercase;
}
.application-no { color:#253046; font-size:13px; font-weight:700; }

.status-badge {
    display:inline-flex; align-items:center; gap:6px;
    padding:6px 10px; border-radius:20px;
    font-size:10.5px; font-weight:650;
}
.status-dot { width:6px; height:6px; border-radius:50%; background:currentColor; }
.status-pending { background:#fff7e6; color:#a86f0e; }
.status-approved { background:#eaf7ef; color:#27845b; }
.status-rejected { background:#fff0f1; color:#b83a46; }
.status-cancelled { background:#f0f2f4; color:#737c89; }

.application-body { padding:16px; }
.info-grid {
    display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:16px;
}
.info-value { color:#465064; font-size:12.5px; line-height:1.55; word-break:break-word; }
.info-value.strong { color:#303a4c; font-weight:650; }

.detail-grid {
    display:grid; grid-template-columns:repeat(2,minmax(0,1fr));
    gap:12px; margin-top:15px; padding-top:15px;
    border-top:1px solid #eef0f2;
}
.detail-box { padding:12px 13px; background:#f8f9fa; border-radius:8px; }

.remark-box, .change-box {
    margin-top:13px; padding:11px 13px; border-radius:8px;
    font-size:12px; line-height:1.5;
}
.remark-box { background:#fff8e9; border:1px solid #eee0ba; color:#745d24; }
.change-box { background:#f4f7ff; border:1px solid #d9e2f6; color:#45546d; }
.change-box strong, .remark-box strong { display:block; margin-bottom:5px; }

.application-footer {
    display:flex; align-items:center; justify-content:space-between;
    gap:15px; padding:12px 16px; border-top:1px solid #eef0f2;
}
.created-at { color:#8e98a7; font-size:11px; }
.action-group { display:flex; gap:8px; flex-wrap:wrap; }

.action-btn {
    min-height:34px; display:inline-flex; align-items:center;
    justify-content:center; padding:7px 12px; background:#fff;
    border:1px solid #dce0e5; border-radius:7px;
    color:#687284; font:600 10.5px inherit; text-decoration:none;
    cursor:pointer;
}
.action-btn.edit { border-color:#cbd8ea; color:#42658f; background:#f8fbff; }
.action-btn.cancel { border-color:#ebccd0; color:#a9323e; background:#fffafa; }
.action-btn.print { background:#971d2d; border-color:#971d2d; color:#fff; }
.action-btn:disabled { opacity:.55; cursor:not-allowed; }

.empty-state { padding:60px 20px; text-align:center; color:#969eaa; }

.modal-overlay {
    position:fixed; inset:0; z-index:9999; display:none;
    align-items:center; justify-content:center; padding:20px;
    background:rgba(17,24,39,.45);
}
.modal-overlay.show { display:flex; }
.modal-card {
    width:min(560px,100%); max-height:90vh; overflow:auto;
    background:#fff; border-radius:14px; box-shadow:0 20px 50px rgba(0,0,0,.18);
}
.modal-header {
    display:flex; align-items:center; justify-content:space-between;
    padding:18px 20px; border-bottom:1px solid #eceef1;
}
.modal-header h3 { margin:0; color:#253046; font-size:17px; }
.modal-close {
    border:0; background:transparent; font-size:24px; cursor:pointer; color:#7b8492;
}
.modal-body { padding:20px; }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
.form-group.full { grid-column:1/-1; }
.form-group label {
    display:block; margin-bottom:6px; color:#596477;
    font-size:11px; font-weight:700;
}
.form-group input, .form-group textarea {
    width:100%; padding:10px 11px; border:1px solid #dce0e5;
    border-radius:8px; font:inherit; color:#364052;
}
.form-group textarea { min-height:90px; resize:vertical; }
.modal-footer {
    display:flex; justify-content:flex-end; gap:9px;
    padding:15px 20px; border-top:1px solid #eceef1;
}
.btn-secondary, .btn-primary, .btn-danger {
    min-height:38px; padding:8px 15px; border-radius:8px;
    font:600 12px inherit; cursor:pointer;
}
.btn-secondary { background:#fff; border:1px solid #dce0e5; color:#687284; }
.btn-primary { background:#971d2d; border:1px solid #971d2d; color:#fff; }
.btn-danger { background:#a9323e; border:1px solid #a9323e; color:#fff; }

@media (max-width:1200px) {
    .summary-grid { grid-template-columns:repeat(2,minmax(0,1fr)); }
    .info-grid { grid-template-columns:repeat(2,minmax(0,1fr)); }
}
@media (min-width:1201px) {
    .summary-grid { grid-template-columns:repeat(4,minmax(0,1fr)); }
}
@media (max-width:760px) {
    .vehicle-page-header, .application-top, .application-footer {
        align-items:flex-start; flex-direction:column;
    }
    .vehicle-header-actions { width:100%; justify-content:flex-end; }
    .summary-grid, .info-grid, .detail-grid, .form-grid { grid-template-columns:1fr; }
    .form-group.full { grid-column:auto; }
    .top-action-row .btn-new { width:100%; }
}

.notification-btn {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    padding: 0;
    border: 1px solid #e4e7ec;
    border-radius: 11px;
    background: #fff;
    color: #667085;
    text-decoration: none;
    box-shadow: 0 4px 14px rgba(27, 36, 53, .05);
    transition: .15s ease;
}
.notification-btn:hover {
    background: #fff8f8;
    border-color: #e4c7cb;
    color: #8d1f2d;
}
.notification-btn svg {
    width: 19px;
    height: 19px;
    fill: none;
    stroke: currentColor;
    stroke-width: 1.8;
    stroke-linecap: round;
    stroke-linejoin: round;
}
/* =========================================================
   MOBILE STYLE MATCHING THE OTHER APPLICATION PAGES
   ========================================================= */
@media (max-width: 650px) {
    html, body { width:100%; max-width:100%; margin:0; overflow-x:hidden; }
    .app-layout { display:block; width:100%; max-width:100%; min-width:0; overflow-x:hidden; }
    main.main-content {
        display:block; width:100%; max-width:100%; min-width:0;
        margin-left:0; padding:74px 13px 28px; overflow-x:hidden;
        box-sizing:border-box;
    }
    .vehicle-page, .list-card, .application-item {
        width:100%; max-width:100%; min-width:0; box-sizing:border-box;
    }
    .vehicle-page-header {
        position:relative; display:block; min-height:44px; margin-bottom:14px;
    }
    .vehicle-page-title { min-width:0; padding-right:104px; }
    .vehicle-page-title h1 {
        max-width:100%; font-size:21px; line-height:1.25;
        white-space:normal; overflow-wrap:anywhere;
    }
    .vehicle-page-title p { font-size:12px; line-height:1.4; }
    .vehicle-header-actions {
        position:absolute; top:0; right:0; z-index:3;
        display:flex; align-items:center; justify-content:flex-end;
        width:max-content; gap:7px;
    }
    .notification-btn { width:40px; height:40px; }
    .vehicle-user-chip { min-width:0; min-height:40px; padding:5px; }
    .vehicle-user-avatar { width:30px; height:30px; }
    .vehicle-user-name { display:none; }

    .top-action-row { margin-bottom:12px; }
    .top-action-row .btn-new { width:100%; min-height:40px; }
    .message { margin-bottom:12px; padding:10px 12px; font-size:11px; }
    .summary-grid {
        grid-template-columns:repeat(2,minmax(0,1fr));
        gap:9px; margin-bottom:14px;
    }
    .summary-card {
        min-width:0; min-height:68px; gap:8px;
        padding:10px 11px; border-radius:11px;
    }
    .summary-icon { width:32px; height:32px; flex:0 0 32px; font-size:14px; }
    .summary-label { margin-bottom:3px; font-size:9px; line-height:1.3; }
    .summary-value { font-size:20px; line-height:1.1; }

    .list-card { border-radius:12px; overflow:hidden; }
    .list-card-header { padding:13px 14px 0; }
    .list-card-header h2 { font-size:16px; }
    .list-card-header p { font-size:11px; line-height:1.4; }
    .tabs {
        display:flex; flex-wrap:wrap; gap:3px 6px;
        margin-top:12px; overflow:visible;
    }
    .tab { min-height:34px; padding:8px 7px; gap:5px; font-size:10px; }
    .tab-count { min-width:18px; padding:2px 5px; font-size:9px; }

    .application-list { padding:10px; }
    .application-item { margin-bottom:9px; border-radius:11px; }
    .application-top {
        flex-direction:row; align-items:center; justify-content:space-between;
        gap:8px; padding:10px 11px;
    }
    .application-no-label, .info-label { margin-bottom:3px; font-size:8px; line-height:1.3; }
    .application-no { font-size:11px; line-height:1.35; overflow-wrap:anywhere; }
    .status-badge { max-width:48%; padding:5px 7px; font-size:9px; white-space:normal; }
    .application-body { padding:10px; }
    .info-grid { grid-template-columns:repeat(2,minmax(0,1fr)); gap:7px; }
    .info-grid > div {
        min-width:0; padding:7px 8px;
        border:1px solid #eef0f4; border-radius:8px; background:#fcfcfd;
    }
    .info-value { font-size:10px; line-height:1.35; overflow-wrap:anywhere; }
    .info-value.strong { font-size:10px; }
    .detail-grid { grid-template-columns:repeat(2,minmax(0,1fr)); gap:7px; margin-top:10px; padding-top:10px; }
    .detail-box { min-width:0; padding:8px; border-radius:8px; overflow-wrap:anywhere; }
    .remark-box, .change-box { margin-top:8px; padding:8px 9px; font-size:10px; line-height:1.4; }
    .application-footer {
        align-items:stretch; flex-direction:column; gap:7px; padding:9px 10px;
    }
    .created-at { font-size:9px; }
    .action-group { display:flex; flex-wrap:wrap; gap:6px; }
    .action-btn { flex:1 1 100px; min-width:0; min-height:32px; padding:6px 8px; font-size:9px; }

    .modal-overlay { align-items:flex-end; padding:10px; }
    .modal-card { width:100%; max-height:90vh; border-radius:13px; }
    .modal-header, .modal-body, .modal-footer { padding:13px 14px; }
    .form-grid { grid-template-columns:minmax(0,1fr); gap:11px; }
    .form-group.full { grid-column:1 / -1; }
    .modal-footer { flex-wrap:wrap; }
}
@media (max-width: 360px) {
    main.main-content { padding-right:10px; padding-left:10px; }
    .vehicle-page-title { padding-right:96px; }
    .vehicle-header-actions { gap:5px; }
    .summary-grid { gap:7px; }
    .summary-card { gap:6px; padding:9px; }
    .summary-icon { width:29px; height:29px; flex-basis:29px; }
    .application-list { padding:8px; }
    .info-grid, .detail-grid { gap:6px; }
}</style>
</head>

<body>
<div class="app-layout">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main-content">
        <div class="vehicle-page">

            <div class="vehicle-page-header">
                <div class="vehicle-page-title">
                    <h1>Permohonan Kenderaan Saya</h1>
                    <p>Semak dan urus permohonan penggunaan kenderaan syarikat anda.</p>
                </div>

                <div class="vehicle-header-actions">
                    <a href="<%= request.getContextPath() %>/notifications"
                       class="notification-btn"
                       title="Notifikasi"
                       aria-label="Notifikasi">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"></path>
                            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                        </svg>
                    </a>
                    <div class="vehicle-user-chip">
                        <div class="vehicle-user-avatar"><%= esc.apply(userInitial) %></div>
                        <div class="vehicle-user-name"><%= esc.apply(userName) %></div>
                    </div>
                </div>
            </div>

            <div class="top-action-row">
                <a href="<%= request.getContextPath() %>/vehicle-apply" class="btn-new">
                    + Permohonan Baru
                </a>
            </div>

            <% if (successMessage != null && !successMessage.isBlank()) { %>
                <div class="message success"><%= esc.apply(successMessage) %></div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="message error"><%= esc.apply(errorMessage) %></div>
            <% } %>

            <div class="summary-grid">
                <div class="summary-card pending">
                    <div class="summary-icon">◷</div>
                    <div><div class="summary-label">Menunggu</div><div class="summary-value"><%= totalPending %></div></div>
                </div>
                <div class="summary-card approved">
                    <div class="summary-icon">✓</div>
                    <div><div class="summary-label">Diluluskan</div><div class="summary-value"><%= totalApproved %></div></div>
                </div>
                <div class="summary-card rejected">
                    <div class="summary-icon">×</div>
                    <div><div class="summary-label">Ditolak</div><div class="summary-value"><%= totalRejected %></div></div>
                </div>
                <div class="summary-card cancelled">
                    <div class="summary-icon">—</div>
                    <div><div class="summary-label">Dibatalkan</div><div class="summary-value"><%= totalCancelled %></div></div>
                </div>
            </div>

            <div class="list-card">
                <div class="list-card-header">
                    <h2>Senarai Permohonan</h2>
                    <p>Jumlah keseluruhan: <strong><%= totalAll %></strong> permohonan</p>

                    <div class="tabs">
                        <a href="<%= request.getContextPath() %>/my-vehicle-applications"
                           class="tab <%= selectedStatus.isEmpty() ? "active" : "" %>">
                            Semua <span class="tab-count"><%= totalAll %></span>
                        </a>
                        <a href="<%= request.getContextPath() %>/my-vehicle-applications?status=PENDING"
                           class="tab <%= "PENDING".equals(selectedStatus) ? "active" : "" %>">
                            Menunggu <span class="tab-count"><%= totalPending %></span>
                        </a>
                        <a href="<%= request.getContextPath() %>/my-vehicle-applications?status=APPROVED"
                           class="tab <%= "APPROVED".equals(selectedStatus) ? "active" : "" %>">
                            Diluluskan <span class="tab-count"><%= totalApproved %></span>
                        </a>
                        <a href="<%= request.getContextPath() %>/my-vehicle-applications?status=REJECTED"
                           class="tab <%= "REJECTED".equals(selectedStatus) ? "active" : "" %>">
                            Ditolak <span class="tab-count"><%= totalRejected %></span>
                        </a>
                        <a href="<%= request.getContextPath() %>/my-vehicle-applications?status=CANCELLED"
                           class="tab <%= "CANCELLED".equals(selectedStatus) ? "active" : "" %>">
                            Dibatalkan <span class="tab-count"><%= totalCancelled %></span>
                        </a>
                    </div>
                </div>

                <div class="application-list">
                <% if (applications == null || applications.isEmpty()) { %>
                    <div class="empty-state">
                        <h3>Tiada permohonan kenderaan</h3>
                        <p>Tiada permohonan ditemui untuk kategori ini.</p>
                    </div>
                <% } else {
                    for (Map<String,Object> app : applications) {
                        int id = ((Number) app.get("id")).intValue();
                        String status = String.valueOf(app.get("status"));
                        String statusLabel = "Menunggu Kelulusan";
                        String statusClass = "status-pending";

                        if ("APPROVED".equals(status)) {
                            statusLabel = "Diluluskan";
                            statusClass = "status-approved";
                        } else if ("REJECTED".equals(status)) {
                            statusLabel = "Ditolak";
                            statusClass = "status-rejected";
                        } else if ("CANCELLED".equals(status)) {
                            statusLabel = "Dibatalkan";
                            statusClass = "status-cancelled";
                        }

                        String useDate = app.get("use_date") == null ? "" : dateFormat.format(app.get("use_date"));
                        String returnDate = app.get("expected_return_date") == null ? useDate : dateFormat.format(app.get("expected_return_date"));
                        String startTime = app.get("start_time") == null ? "" : timeFormat.format(app.get("start_time"));
                        String returnTime = app.get("expected_return_time") == null ? "" : timeFormat.format(app.get("expected_return_time"));
                        String createdAt = app.get("created_at") == null ? "" : dateTimeFormat.format(app.get("created_at"));
                        boolean multiDay = !useDate.equals(returnDate);
                        boolean pendingChange = app.get("pending_change_id") != null;

                        boolean canManageApproved = false;
                        if ("APPROVED".equals(status) && app.get("use_date") != null && app.get("start_time") != null) {
                            java.sql.Date d = (java.sql.Date) app.get("use_date");
                            java.sql.Time t = (java.sql.Time) app.get("start_time");
                            LocalDateTime bookingStart = LocalDateTime.of(d.toLocalDate(), t.toLocalTime());
                            canManageApproved = LocalDateTime.now().isBefore(bookingStart);
                        }

                        String approvalRemark = app.get("approval_remark") == null ? "" : String.valueOf(app.get("approval_remark"));
                %>

                    <div class="application-item">
                        <div class="application-top">
                            <div>
                                <div class="application-no-label">No. Permohonan</div>
                                <div class="application-no"><%= esc.apply(app.get("application_no")) %></div>
                            </div>
                            <span class="status-badge <%= statusClass %>">
                                <span class="status-dot"></span><%= statusLabel %>
                            </span>
                        </div>

                        <div class="application-body">
                            <div class="info-grid">
                                <div>
                                    <div class="info-label">Kenderaan</div>
                                    <div class="info-value strong">
                                        <%= esc.apply(app.get("plate_number")) %> -
                                        <%= esc.apply(app.get("vehicle_name")) %>
                                    </div>
                                </div>
                                <div>
                                    <div class="info-label">Tempoh Penggunaan</div>
                                    <div class="info-value">
                                        <%= multiDay ? useDate + " - " + returnDate : useDate %>
                                    </div>
                                </div>
                                <div>
                                    <div class="info-label">Masa</div>
                                    <div class="info-value"><%= startTime %> - <%= returnTime %></div>
                                </div>
                                <div>
                                    <div class="info-label">Pemandu</div>
                                    <div class="info-value"><%= esc.apply(app.get("driver_name")) %></div>
                                </div>
                            </div>

                            <div class="detail-grid">
                                <div class="detail-box">
                                    <div class="info-label">Tempat Tuju / Destinasi</div>
                                    <div class="info-value"><%= esc.apply(app.get("destination")) %></div>
                                </div>
                                <div class="detail-box">
                                    <div class="info-label">Tujuan / Tugas</div>
                                    <div class="info-value"><%= esc.apply(app.get("purpose")) %></div>
                                </div>
                            </div>

                            <% if (!approvalRemark.isBlank()) { %>
                                <div class="remark-box">
                                    <strong>Catatan Admin</strong>
                                    <%= esc.apply(approvalRemark) %>
                                </div>
                            <% } %>

                            <% if (pendingChange) {
                                String nUse = app.get("pending_new_use_date") == null ? "" : dateFormat.format(app.get("pending_new_use_date"));
                                String nStart = app.get("pending_new_start_time") == null ? "" : timeFormat.format(app.get("pending_new_start_time"));
                                String nReturn = app.get("pending_new_return_date") == null ? "" : dateFormat.format(app.get("pending_new_return_date"));
                                String nReturnTime = app.get("pending_new_return_time") == null ? "" : timeFormat.format(app.get("pending_new_return_time"));
                            %>
                                <div class="change-box">
                                    <strong>Perubahan sedang menunggu semakan Admin/HR</strong>
                                    Tempoh baharu: <%= nUse %>, <%= nStart %> hingga
                                    <%= nReturn %>, <%= nReturnTime %><br>
                                    Sebab: <%= esc.apply(app.get("pending_change_reason")) %>
                                </div>
                            <% } %>

                            <% if ("CANCELLED".equals(status) && app.get("cancellation_reason") != null) { %>
                                <div class="remark-box">
                                    <strong>Sebab Pembatalan</strong>
                                    <%= esc.apply(app.get("cancellation_reason")) %>
                                </div>
                            <% } %>
                        </div>

                        <div class="application-footer">
                            <div class="created-at">Dihantar: <%= createdAt %></div>

                            <div class="action-group">
                                <% if ("PENDING".equals(status)) { %>
                                    <form action="<%= request.getContextPath() %>/my-vehicle-applications"
                                          method="post" style="margin:0"
                                          onsubmit="return confirm('Adakah anda pasti mahu membatalkan permohonan ini?');">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="id" value="<%= id %>">
                                        <button type="submit" class="action-btn cancel">Batal Permohonan</button>
                                    </form>
                                <% } %>

                                <% if ("APPROVED".equals(status) && canManageApproved) { %>
                                    <button type="button"
                                            class="action-btn edit"
                                            <%= pendingChange ? "disabled" : "" %>
                                            onclick="openChangeModal(
                                                '<%= id %>',
                                                '<%= app.get("use_date") %>',
                                                '<%= app.get("start_time") %>',
                                                '<%= app.get("expected_return_date") %>',
                                                '<%= app.get("expected_return_time") %>'
                                            )">
                                        <%= pendingChange ? "Perubahan Menunggu" : "Ubah Tempahan" %>
                                    </button>

                                    <button type="button"
                                            class="action-btn cancel"
                                            onclick="openCancelModal('<%= id %>')">
                                        Batalkan Tempahan
                                    </button>
                                <% } %>

                                <% if ("APPROVED".equals(status)) { %>
                                    <a href="<%= request.getContextPath() %>/vehicle-print?id=<%= id %>"
                                       class="action-btn print">
                                        Cetak Borang
                                    </a>
                                <% } %>
                            </div>
                        </div>
                    </div>

                <%  }
                   } %>
                </div>
            </div>
        </div>
    </main>
</div>

<div class="modal-overlay" id="changeModal">
    <div class="modal-card">
        <form action="<%= request.getContextPath() %>/my-vehicle-applications" method="post">
            <input type="hidden" name="action" value="requestChange">
            <input type="hidden" name="id" id="changeId">

            <div class="modal-header">
                <h3>Mohon Ubah Tempahan</h3>
                <button type="button" class="modal-close" onclick="closeModal('changeModal')">&times;</button>
            </div>

            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Tarikh Mula Baharu</label>
                        <input type="date" name="new_use_date" id="newUseDate" required>
                    </div>
                    <div class="form-group">
                        <label>Masa Mula Baharu</label>
                        <input type="time" name="new_start_time" id="newStartTime" required>
                    </div>
                    <div class="form-group">
                        <label>Tarikh Pulang Baharu</label>
                        <input type="date" name="new_return_date" id="newReturnDate" required>
                    </div>
                    <div class="form-group">
                        <label>Masa Pulang Baharu</label>
                        <input type="time" name="new_return_time" id="newReturnTime" required>
                    </div>
                    <div class="form-group full">
                        <label>Sebab Perubahan</label>
                        <textarea name="change_reason" maxlength="1000" required
                                  placeholder="Nyatakan sebab perubahan tempahan..."></textarea>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('changeModal')">Tutup</button>
                <button type="submit" class="btn-primary">Hantar Permohonan Perubahan</button>
            </div>
        </form>
    </div>
</div>

<div class="modal-overlay" id="cancelModal">
    <div class="modal-card">
        <form action="<%= request.getContextPath() %>/my-vehicle-applications" method="post">
            <input type="hidden" name="action" value="cancel">
            <input type="hidden" name="id" id="cancelId">

            <div class="modal-header">
                <h3>Batalkan Tempahan</h3>
                <button type="button" class="modal-close" onclick="closeModal('cancelModal')">&times;</button>
            </div>

            <div class="modal-body">
                <div class="form-group">
                    <label>Sebab Pembatalan</label>
                    <textarea name="cancellation_reason" maxlength="1000" required
                              placeholder="Nyatakan sebab tempahan dibatalkan..."></textarea>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-secondary" onclick="closeModal('cancelModal')">Tutup</button>
                <button type="submit" class="btn-danger">Sahkan Pembatalan</button>
            </div>
        </form>
    </div>
</div>

<script>
function dateValue(value) {
    if (!value || value === "null") return "";
    return String(value).substring(0, 10);
}

function timeValue(value) {
    if (!value || value === "null") return "";
    return String(value).substring(0, 5);
}

function openChangeModal(id, useDate, startTime, returnDate, returnTime) {
    document.getElementById("changeId").value = id;
    document.getElementById("newUseDate").value = dateValue(useDate);
    document.getElementById("newStartTime").value = timeValue(startTime);
    document.getElementById("newReturnDate").value = dateValue(returnDate);
    document.getElementById("newReturnTime").value = timeValue(returnTime);
    document.getElementById("changeModal").classList.add("show");
}

function openCancelModal(id) {
    document.getElementById("cancelId").value = id;
    document.getElementById("cancelModal").classList.add("show");
}

function closeModal(id) {
    document.getElementById(id).classList.remove("show");
}

document.querySelectorAll(".modal-overlay").forEach(function(modal) {
    modal.addEventListener("click", function(e) {
        if (e.target === modal) {
            modal.classList.remove("show");
        }
    });
});

document.addEventListener("keydown", function(e) {
    if (e.key === "Escape") {
        document.querySelectorAll(".modal-overlay.show").forEach(function(modal) {
            modal.classList.remove("show");
        });
    }
});
</script>
</body>
</html>
