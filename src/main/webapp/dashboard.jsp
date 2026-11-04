<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%!
    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private int num(Object value) {
        if (value == null) return 0;
        try {
            return Integer.parseInt(value.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private String roleLabel(String role) {
        if (role == null) return "Staf";

        switch (role.trim().toUpperCase()) {
            case "HOD":
                return "Ketua Unit";
            case "HR":
                return "Pentadbir Sistem";
            case "MANAGEMENT":
                return "Pengurusan";
            default:
                return "Staf";
        }
    }

    private String departmentLabel(Object department) {
        if (department == null) return "—";

        String value = department.toString().trim();

        switch (value.toUpperCase()) {
            case "PENTADBIRAN_KORPORAT":
                return "Pentadbiran dan Korporat";

            case "KEWANGAN":
                return "Kewangan";

            case "PEMBANGUNAN_PERNIAGAAN_OPERASI":
                return "Pembangunan Perniagaan dan Operasi";

            default:
                return value.isBlank() ? "—" : value;
        }
    }

    private String statusLabel(Object statusObject) {
        if (statusObject == null) return "Menunggu";

        String status = statusObject.toString().trim().toUpperCase();

        switch (status) {
            case "APPROVED":
                return "Diluluskan";

            case "REJECTED":
                return "Tidak Diluluskan";

            case "CANCELLED":
                return "Dibatalkan";

            default:
                return "Menunggu";
        }
    }

    private String statusClass(Object statusObject) {
        if (statusObject == null) return "pending";

        String status = statusObject.toString().trim().toUpperCase();

        switch (status) {
            case "APPROVED":
                return "approved";

            case "REJECTED":
                return "rejected";

            case "CANCELLED":
                return "cancelled";

            default:
                return "pending";
        }
    }
%>

<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    String dashboardName =
            request.getAttribute("dashboardName") == null
                    ? (
                        session.getAttribute("userName") == null
                            ? "Pengguna"
                            : session.getAttribute("userName").toString()
                      )
                    : request.getAttribute("dashboardName").toString();

    String dashboardRole =
            request.getAttribute("dashboardRole") == null
                    ? (
                        session.getAttribute("userRole") == null
                            ? "STAFF"
                            : session.getAttribute("userRole").toString()
                      )
                    : request.getAttribute("dashboardRole").toString();

    dashboardRole = dashboardRole.trim().toUpperCase();


    @SuppressWarnings("unchecked")
    Map<String,Object> todayAttendance =
            (Map<String,Object>)
                    request.getAttribute("todayAttendance");

    if (todayAttendance == null) {
        todayAttendance =
                new java.util.HashMap<String,Object>();
    }

    String todayAttendanceStatus =
            todayAttendance.get("status") == null
                ? "BELUM_HADIR"
                : todayAttendance.get("status").toString().trim().toUpperCase();

    Object todayCheckInObj =
            todayAttendance.get("checkIn");

    Object todayCheckOutObj =
            todayAttendance.get("checkOut");

    Object todayCheckInDistanceObj =
            todayAttendance.get("checkInDistance");

    String todayCheckIn =
            todayCheckInObj == null
                ? "—"
                : new java.text.SimpleDateFormat("HH:mm:ss")
                    .format(todayCheckInObj);

    String todayCheckOut =
            todayCheckOutObj == null
                ? "—"
                : new java.text.SimpleDateFormat("HH:mm:ss")
                    .format(todayCheckOutObj);

    String todayCheckInDistance =
            todayCheckInDistanceObj == null
                ? "—"
                : String.valueOf(todayCheckInDistanceObj);

    String todayAttendanceTitle;
    String todayAttendanceLabel;
    String todayAttendanceClass;

    if ("SELESAI".equals(todayAttendanceStatus)) {
        todayAttendanceTitle = "Kehadiran Lengkap";
        todayAttendanceLabel = "Lengkap";
        todayAttendanceClass = "complete";
    } else if ("HADIR".equals(todayAttendanceStatus)) {
        todayAttendanceTitle = "Sudah Check In";
        todayAttendanceLabel = "Hadir";
        todayAttendanceClass = "present";
    } else {
        todayAttendanceTitle = "Belum Check In";
        todayAttendanceLabel = "Belum Hadir";
        todayAttendanceClass = "pending";
    }

    String position =
            request.getAttribute("position") == null
                    ? ""
                    : request.getAttribute("position").toString();

    String department =
            departmentLabel(request.getAttribute("department"));

    boolean isStaff = "STAFF".equals(dashboardRole);
    boolean isHOD = "HOD".equals(dashboardRole);
    boolean isHR = "HR".equals(dashboardRole);
    boolean isManagement = "MANAGEMENT".equals(dashboardRole);


    // =========================================================
    // CUTI SAYA
    // =========================================================

    int myTotal = num(request.getAttribute("myTotal"));
    int myPending = num(request.getAttribute("myPending"));
    int myApproved = num(request.getAttribute("myApproved"));
    int myRejected = num(request.getAttribute("myRejected"));


    // =========================================================
    // HOD
    // =========================================================

    int supervisedStaffCount =
            num(request.getAttribute("supervisedStaffCount"));

    int hodPendingReviewCount =
            num(request.getAttribute("hodPendingReviewCount"));

    int hodCompletedCount =
            num(request.getAttribute("hodCompletedCount"));


    // =========================================================
    // MANAGEMENT
    // =========================================================

    int managementPendingCount =
            num(request.getAttribute("managementPendingCount"));

    int managementApprovedCount =
            num(request.getAttribute("managementApprovedCount"));

    int managementRejectedCount =
            num(request.getAttribute("managementRejectedCount"));


    // =========================================================
    // HR
    // =========================================================

    int totalStaffCount =
            num(request.getAttribute("totalStaffCount"));

    int organizationLeaveCount =
            num(request.getAttribute("organizationLeaveCount"));

    int organizationPendingCount =
            num(request.getAttribute("organizationPendingCount"));

    int organizationApprovedCount =
            num(request.getAttribute("organizationApprovedCount"));

    int inventoryItemCount =
            num(request.getAttribute("inventoryItemCount"));

    int inventoryRequestCount =
            num(request.getAttribute("inventoryRequestCount"));

    int pendingInventoryRequestCount =
            num(request.getAttribute("pendingInventoryRequestCount"));

    int myPendingInventoryRequestCount =
            num(request.getAttribute("myPendingInventoryRequestCount"));


    // =========================================================
    // KENDERAAN
    // =========================================================

    int activeVehicleCount =
            num(request.getAttribute("activeVehicleCount"));

    int maintenanceVehicleCount =
            num(request.getAttribute("maintenanceVehicleCount"));

    int myVehicleApplicationCount =
            num(request.getAttribute("myVehicleApplicationCount"));

    int myPendingVehicleApplicationCount =
            num(request.getAttribute("myPendingVehicleApplicationCount"));

    int todayVehicleApplicationCount =
            num(request.getAttribute("todayVehicleApplicationCount"));

    int pendingVehicleApplicationCount =
            num(request.getAttribute("pendingVehicleApplicationCount"));


    // =========================================================
    // LIST
    // =========================================================

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> currentLeave =
            (List<Map<String,Object>>)
                    request.getAttribute("currentLeave");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> upcoming =
            (List<Map<String,Object>>)
                    request.getAttribute("upcoming");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> recentApplications =
            (List<Map<String,Object>>)
                    request.getAttribute("recentApplications");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> supervisedCurrentLeave =
            (List<Map<String,Object>>)
                    request.getAttribute("supervisedCurrentLeave");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> organizationCurrentLeave =
            (List<Map<String,Object>>)
                    request.getAttribute("organizationCurrentLeave");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> supervisedUpcomingLeave =
            (List<Map<String,Object>>)
                    request.getAttribute("supervisedUpcomingLeave");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> organizationUpcomingLeave =
            (List<Map<String,Object>>)
                    request.getAttribute("organizationUpcomingLeave");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> myRecentVehicleApplications =
            (List<Map<String,Object>>)
                    request.getAttribute("myRecentVehicleApplications");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> organizationRecentVehicleApplications =
            (List<Map<String,Object>>)
                    request.getAttribute("organizationRecentVehicleApplications");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> activeVehicles =
            (List<Map<String,Object>>)
                    request.getAttribute("activeVehicles");


    @SuppressWarnings("unchecked")
    List<Map<String,Object>> organizationAttendanceToday =
            (List<Map<String,Object>>)
                    request.getAttribute("organizationAttendanceToday");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> dashboardAnnouncements =
            (List<Map<String,Object>>)
                    request.getAttribute("dashboardAnnouncements");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> dashboardEvents =
            (List<Map<String,Object>>)
                    request.getAttribute("dashboardEvents");

    if (dashboardAnnouncements == null)
        dashboardAnnouncements = new java.util.ArrayList<Map<String,Object>>();

    if (dashboardEvents == null)
        dashboardEvents = new java.util.ArrayList<Map<String,Object>>();


    if (currentLeave == null)
        currentLeave = new java.util.ArrayList<Map<String,Object>>();

    if (upcoming == null)
        upcoming = new java.util.ArrayList<Map<String,Object>>();

    if (recentApplications == null)
        recentApplications = new java.util.ArrayList<Map<String,Object>>();

    if (supervisedCurrentLeave == null)
        supervisedCurrentLeave = new java.util.ArrayList<Map<String,Object>>();

    if (organizationCurrentLeave == null)
        organizationCurrentLeave = new java.util.ArrayList<Map<String,Object>>();

    if (supervisedUpcomingLeave == null)
        supervisedUpcomingLeave = new java.util.ArrayList<Map<String,Object>>();

    if (organizationUpcomingLeave == null)
        organizationUpcomingLeave = new java.util.ArrayList<Map<String,Object>>();

    if (myRecentVehicleApplications == null)
        myRecentVehicleApplications = new java.util.ArrayList<Map<String,Object>>();

    if (organizationRecentVehicleApplications == null)
        organizationRecentVehicleApplications =
                new java.util.ArrayList<Map<String,Object>>();

    if (activeVehicles == null)
        activeVehicles =
                new java.util.ArrayList<Map<String,Object>>();


    if (organizationAttendanceToday == null)
        organizationAttendanceToday =
                new java.util.ArrayList<Map<String,Object>>();


    List<Map<String,Object>> displayedCurrentLeave;

    if (isHOD) {
        displayedCurrentLeave = supervisedCurrentLeave;
    } else if (isHR || isManagement) {
        displayedCurrentLeave = organizationCurrentLeave;
    } else {
        displayedCurrentLeave = currentLeave;
    }


    List<Map<String,Object>> displayedUpcomingLeave;

    if (isHOD) {
        displayedUpcomingLeave = supervisedUpcomingLeave;
    } else if (isHR || isManagement) {
        displayedUpcomingLeave = organizationUpcomingLeave;
    } else {
        displayedUpcomingLeave = upcoming;
    }


    List<Map<String,Object>> vehicleRows =
            (isHR || isManagement)
                    ? organizationRecentVehicleApplications
                    : myRecentVehicleApplications;


    int attentionCount = 0;

    if (isHR) {
        attentionCount =
                organizationPendingCount
                + pendingInventoryRequestCount
                + pendingVehicleApplicationCount;

    } else if (isHOD) {
        attentionCount = hodPendingReviewCount;

    } else if (isManagement) {
        attentionCount =
                managementPendingCount
                + pendingVehicleApplicationCount;

    } else {
        attentionCount =
                myPending
                + myPendingInventoryRequestCount
                + myPendingVehicleApplicationCount;
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

    <title>Halaman Utama - PKB</title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260930-dashboard-modern"
    >

<style>

:root {
    --dash-maroon: #981525;
    --dash-maroon-dark: #74101c;
    --dash-gold: #d5a32b;
    --dash-dark: #172033;
    --dash-text: #536176;
    --dash-muted: #8b96a8;
    --dash-border: #e6eaf0;
    --dash-bg: #f5f7fa;
}


/* =========================================================
   PAGE
   ========================================================= */

html,
body {
    max-width: 100%;
    overflow-x: hidden;
}

body {
    background: var(--dash-bg);
}

.app-layout {
    width: 100%;
    min-height: 100vh;
}

main.main-content.dashboard-main {
    display: block !important;

    width: auto !important;
    max-width: none !important;

    margin-left: var(--sidebar-width) !important;

    padding:
        26px
        32px
        55px !important;

    box-sizing: border-box !important;
}

.dashboard-container {
    width: 100%;
    max-width: 1600px;
    margin: 0 auto;
}


/* =========================================================
   TOP ACTIONS
   ========================================================= */

.dashboard-topbar {
    display: flex;
    align-items: center;
    justify-content: flex-end;

    margin-bottom: 16px;
}


/* =========================================================
   HERO
   ========================================================= */

.dashboard-hero {
    position: relative;

    min-height: 285px;

    display: flex;
    align-items: flex-end;

    overflow: hidden;

    margin-bottom: 24px;

    border-radius: 24px;

    background:
        linear-gradient(
            90deg,
            rgba(22, 24, 31, .94) 0%,
            rgba(49, 24, 28, .86) 35%,
            rgba(61, 25, 30, .55) 62%,
            rgba(20, 20, 24, .20) 100%
        ),
        url('<%= request.getContextPath() %>/images/pkb-office.png');

    background-size: cover;
    background-position: center 57%;

    box-shadow:
        0 18px 45px rgba(31, 42, 68, .14);
}

.dashboard-hero::after {
    content: "";

    position: absolute;

    left: 0;
    right: 0;
    bottom: 0;

    height: 6px;

    background:
        linear-gradient(
            90deg,
            var(--dash-maroon) 0 72%,
            var(--dash-gold) 72% 82%,
            transparent 82%
        );
}

.hero-content {
    position: relative;
    z-index: 2;

    width: 100%;

    padding: 34px 38px 39px;

    color: #fff;
}

.hero-eyebrow {
    display: inline-flex;
    align-items: center;

    min-height: 28px;

    padding: 5px 12px;

    margin-bottom: 13px;

    border: 1px solid rgba(255,255,255,.22);
    border-radius: 999px;

    background: rgba(255,255,255,.12);

    backdrop-filter: blur(8px);

    font-size: 11px;
    font-weight: 700;

    letter-spacing: .04em;
    text-transform: uppercase;
}

.hero-content h1 {
    margin: 0;

    max-width: 720px;

    color: #fff;

    font-size: clamp(26px, 3vw, 40px);
    line-height: 1.15;

    font-weight: 800;
}

.hero-content > p {
    margin: 9px 0 0;

    color: rgba(255,255,255,.80);

    font-size: 13px;
}

.hero-meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;

    gap: 8px;

    margin-top: 14px;

    color: rgba(255,255,255,.78);

    font-size: 12px;
}

.hero-meta span {
    display: inline-flex;
    align-items: center;
}

.hero-meta .dot {
    opacity: .5;
}


/* =========================================================
   QUICK ACTION HERO
   ========================================================= */

.hero-actions {
    display: flex;
    flex-wrap: wrap;

    gap: 9px;

    margin-top: 21px;
}

.hero-action {
    display: inline-flex;
    align-items: center;
    justify-content: center;

    min-height: 40px;

    gap: 7px;

    padding: 8px 15px;

    border: 1px solid rgba(255,255,255,.20);
    border-radius: 10px;

    background: rgba(255,255,255,.12);

    color: #fff;

    font-size: 12px;
    font-weight: 700;

    text-decoration: none;

    backdrop-filter: blur(8px);

    transition:
        transform .18s ease,
        background .18s ease;
}

.hero-action:hover {
    transform: translateY(-2px);

    background: rgba(255,255,255,.22);

    color: #fff;
}

.hero-action.primary {
    border-color: var(--dash-maroon);

    background: var(--dash-maroon);
}


/* =========================================================
   SECTION
   ========================================================= */

.dashboard-section {
    margin-bottom: 25px;
}

.section-heading {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;

    gap: 18px;

    margin-bottom: 13px;
}

.section-heading h2 {
    margin: 0;

    color: var(--dash-dark);

    font-size: 18px;
    font-weight: 800;
}

.section-heading p {
    margin: 5px 0 0;

    color: var(--dash-muted);

    font-size: 12px;
}

.section-heading a {
    flex-shrink: 0;

    color: var(--dash-maroon);

    font-size: 12px;
    font-weight: 750;

    text-decoration: none;
}


/* =========================================================
   MAIN STATISTICS
   ========================================================= */

.stat-grid {
    display: grid;

    grid-template-columns:
        repeat(4, minmax(0, 1fr));

    gap: 14px;
}

.stat-card {
    position: relative;

    min-width: 0;

    display: flex;
    align-items: center;

    gap: 15px;

    min-height: 106px;

    padding: 18px;

    overflow: hidden;

    border: 1px solid var(--dash-border);
    border-radius: 17px;

    background: #fff;

    box-shadow:
        0 7px 24px rgba(31,42,68,.055);

    transition:
        transform .2s ease,
        box-shadow .2s ease,
        border-color .2s ease;
}

.stat-card:hover {
    transform: translateY(-3px);

    border-color: #d8dce4;

    box-shadow:
        0 13px 32px rgba(31,42,68,.10);
}

.stat-icon {
    flex: 0 0 50px;

    width: 50px;
    height: 50px;

    display: flex;
    align-items: center;
    justify-content: center;

    border-radius: 14px;

    font-size: 23px;
}

.stat-icon.maroon {
    background: #fff0f2;
}

.stat-icon.gold {
    background: #fff7e5;
}

.stat-icon.blue {
    background: #edf4ff;
}

.stat-icon.green {
    background: #eaf8f1;
}

.stat-icon.purple {
    background: #f3efff;
}

.stat-data {
    min-width: 0;
}

.stat-number {
    display: block;

    margin-bottom: 5px;

    color: var(--dash-dark);

    font-size: 25px;
    font-weight: 850;

    line-height: 1;
}

.stat-label {
    display: block;

    color: #677489;

    font-size: 12px;
    font-weight: 700;

    line-height: 1.35;
}

.stat-note {
    display: block;

    margin-top: 3px;

    color: #9aa3b1;

    font-size: 10px;
}


/* =========================================================
   TWO COLUMN
   ========================================================= */

.dashboard-two-column {
    display: grid;

    grid-template-columns:
        minmax(0, .9fr)
        minmax(0, 1.1fr);

    /* Elakkan kad yang lebih pendek diregangkan mengikut kad sebelahnya */
    align-items: start;

    gap: 16px;

    margin-bottom: 25px;
}

.panel-card {
    min-width: 0;

    border: 1px solid var(--dash-border);
    border-radius: 18px;

    background: #fff;

    box-shadow:
        0 7px 24px rgba(31,42,68,.05);

    overflow: hidden;
}

.panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 15px;

    padding: 18px 20px;

    border-bottom: 1px solid #edf0f4;
}

.panel-title {
    display: flex;
    align-items: center;

    gap: 11px;
}

.panel-title-icon {
    width: 38px;
    height: 38px;

    display: flex;
    align-items: center;
    justify-content: center;

    border-radius: 11px;

    background: #fff0f2;

    font-size: 18px;
}

.panel-title h3 {
    margin: 0;

    color: var(--dash-dark);

    font-size: 15px;
    font-weight: 800;
}

.panel-title p {
    margin: 3px 0 0;

    color: var(--dash-muted);

    font-size: 10px;
}

.panel-link {
    color: var(--dash-maroon);

    font-size: 11px;
    font-weight: 750;

    text-decoration: none;
}


/* =========================================================
   ACTION REQUIRED
   ========================================================= */

.attention-list {
    padding: 7px 20px 12px;
}

.attention-row {
    display: flex;
    align-items: center;
    justify-content: space-between;

    gap: 15px;

    padding: 13px 0;

    border-bottom: 1px solid #f0f2f5;
}

.attention-row:last-child {
    border-bottom: 0;
}

.attention-info {
    display: flex;
    align-items: center;

    gap: 11px;
}

.attention-dot {
    width: 9px;
    height: 9px;

    flex: 0 0 9px;

    border-radius: 50%;

    background: var(--dash-gold);
}

.attention-dot.red {
    background: var(--dash-maroon);
}

.attention-dot.blue {
    background: #4775c5;
}

.attention-label {
    color: #526075;

    font-size: 12px;
    font-weight: 650;
}

.attention-number {
    min-width: 30px;
    height: 28px;

    display: flex;
    align-items: center;
    justify-content: center;

    padding: 0 8px;

    border-radius: 9px;

    background: #f5f6f8;

    color: var(--dash-dark);

    font-size: 12px;
    font-weight: 800;
}

.attention-total {
    padding: 12px 20px;
    background: #fffaf1;
    border-top: 1px solid #f4e6c7;
    color: #795d20;
    font-size: 11px;
}

/* Paparan ringkas apabila tiada tindakan tertunggak */
.attention-total-empty {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 15px 20px;
    min-height: 0;
    background: #f4fbf6;
    border-top: 1px solid #e1f0e5;
    color: #34734a;
    font-size: 12px;
    font-weight: 650;
}

.attention-empty-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 25px;
    height: 25px;
    flex: 0 0 25px;
    border-radius: 50%;
    background: #e1f4e7;
    color: #287542;
    font-size: 14px;
    font-weight: 800;
}


/* =========================================================
   VEHICLE PANEL
   ========================================================= */

.vehicle-list {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
    padding: 18px 18px 8px;
}

.vehicle-card {
    min-width: 0;
    padding: 16px;
    border: 1px solid #eceff3;
    border-radius: 15px;
    background:
        linear-gradient(
            145deg,
            #fff7f8,
            #ffffff
        );
}

.vehicle-card-top {
    display: flex;
    align-items: center;
    gap: 12px;
}

.vehicle-card-image {
    width: 95px;
    height: 65px;
    flex: 0 0 95px;

    display: flex;
    align-items: center;
    justify-content: center;

    padding: 4px;

    border: 1px solid #f0f1f3;
    border-radius: 11px;

    background: #f8f8f9;

    overflow: hidden;
}

.vehicle-real-image {
    width: 100%;
    height: 100%;

    display: block;

    object-fit: contain;

    filter: drop-shadow(
        0 6px 7px rgba(15, 23, 42, .10)
    );
}

.vehicle-card-info {
    min-width: 0;
}

.vehicle-name {
    margin-bottom: 4px;
    color: var(--dash-dark);
    font-size: 13px;
    font-weight: 800;
    line-height: 1.35;
}

.vehicle-plate {
    color: var(--dash-maroon);
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .04em;
}

.vehicle-active-badge {
    display: inline-flex;
    align-items: center;
    margin-top: 10px;
    min-height: 23px;
    padding: 3px 8px;
    border-radius: 999px;
    background: #e8f7ef;
    color: #08794a;
    font-size: 9px;
    font-weight: 800;
}

.vehicle-empty {
    grid-column: 1 / -1;
    padding: 24px;
    border: 1px dashed #dfe4ea;
    border-radius: 14px;
    color: #929cab;
    font-size: 11px;
    text-align: center;
    background: #fafbfc;
}

.vehicle-details {
    display: grid;
    grid-template-columns:
        repeat(4, minmax(0,1fr));
    gap: 0;
    margin-top: 10px;
    padding: 8px 18px 14px;
    border-top: 1px solid #f0f2f5;
}

.vehicle-detail {
    padding: 12px;
    border-right: 1px solid #f0f2f5;
}

.vehicle-detail:last-child {
    border-right: 0;
}

.vehicle-detail strong {
    display: block;
    margin-bottom: 4px;
    color: var(--dash-dark);
    font-size: 20px;
    font-weight: 850;
}

.vehicle-detail span {
    color: var(--dash-muted);
    font-size: 10px;
    font-weight: 650;
}

@media (max-width: 650px) {
    .vehicle-list {
        grid-template-columns: 1fr;
    }

    .vehicle-details {
        grid-template-columns: repeat(2, minmax(0,1fr));
    }

    .vehicle-detail:nth-child(2) {
        border-right: 0;
    }

    .vehicle-detail:nth-child(-n+2) {
        border-bottom: 1px solid #f0f2f5;
    }
}


/* =========================================================
   TABLE
   ========================================================= */

.table-card {
    width: 100%;

    overflow-x: auto;

    border: 1px solid var(--dash-border);
    border-radius: 17px;

    background: #fff;

    box-shadow:
        0 7px 24px rgba(31,42,68,.05);
}

.dashboard-table {
    width: 100%;
    min-width: 760px;

    border-collapse: collapse;
}

.dashboard-table th {
    padding: 12px 14px;

    border-bottom: 1px solid #e7ebf0;

    background: #fafbfc;

    color: #8490a3;

    font-size: 10px;
    font-weight: 800;

    text-align: left;
    text-transform: uppercase;

    letter-spacing: .025em;

    white-space: nowrap;
}

.dashboard-table td {
    padding: 13px 14px;

    border-bottom: 1px solid #eef1f4;

    color: #526075;

    font-size: 12px;

    vertical-align: middle;
}

.dashboard-table tbody tr {
    transition: background .15s ease;
}

.dashboard-table tbody tr:hover {
    background: #fcfcfd;
}

.dashboard-table tbody tr:last-child td {
    border-bottom: 0;
}

.dashboard-table strong {
    color: #273248;
}

.empty-row {
    padding: 30px !important;

    color: #929cab !important;

    text-align: center;
}


/* =========================================================
   DASHBOARD ATTENDANCE
   ========================================================= */

.dashboard-attendance-card {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
    gap: 20px;
    align-items: center;
    padding: 18px 20px;
    border: 1px solid var(--dash-border);
    border-radius: 17px;
    background: #fff;
    box-shadow: 0 7px 24px rgba(31,42,68,.05);
}

.dashboard-attendance-main {
    display: flex;
    align-items: center;
    gap: 13px;
    min-width: 0;
}

.dashboard-attendance-icon {
    width: 44px;
    height: 44px;
    flex: 0 0 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: #fff1f3;
    color: #9e1628;
    font-size: 20px;
    font-weight: 800;
}

.dashboard-attendance-title {
    margin: 0 0 3px;
    color: var(--dash-dark);
    font-size: 13px;
    font-weight: 700;
}

.dashboard-attendance-note {
    margin: 0;
    color: var(--dash-muted);
    font-size: 10.5px;
    line-height: 1.5;
}

.dashboard-attendance-meta {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-top: 8px;
    flex-wrap: wrap;
}

.dashboard-attendance-meta-item {
    color: #64748b;
    font-size: 10px;
}

.dashboard-attendance-meta-item strong {
    color: var(--dash-dark);
    font-weight: 700;
}

.dashboard-attendance-right {
    display: flex;
    align-items: center;
    gap: 10px;
    justify-content: flex-end;
}

.dashboard-attendance-badge {
    display: inline-flex;
    align-items: center;
    min-height: 27px;
    padding: 5px 10px;
    border-radius: 999px;
    font-size: 10px;
    font-weight: 750;
    white-space: nowrap;
}

.dashboard-attendance-badge.pending {
    background: #fff5df;
    color: #946000;
}

.dashboard-attendance-badge.present {
    background: #e8f7ef;
    color: #08794a;
}

.dashboard-attendance-badge.complete {
    background: #edf4ff;
    color: #315ca8;
}

.dashboard-attendance-action {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 35px;
    padding: 7px 13px;
    border-radius: 9px;
    background: #9e1628;
    color: #fff;
    text-decoration: none;
    font-size: 10.5px;
    font-weight: 700;
    white-space: nowrap;
}

.dashboard-attendance-action:hover {
    background: #891222;
}

@media (max-width: 700px) {
    .dashboard-attendance-card {
        grid-template-columns: 1fr;
    }

    .dashboard-attendance-right {
        justify-content: flex-start;
    }
}

/* =========================================================
   ATTENDANCE
   ========================================================= */

.attendance-status {
    display: inline-flex;
    align-items: center;
    min-height: 25px;
    padding: 4px 9px;
    border-radius: 999px;
    font-size: 10px;
    font-weight: 750;
    white-space: nowrap;
}

.attendance-status.present {
    background: #e8f7ef;
    color: #08794a;
}

.attendance-status.complete {
    background: #edf4ff;
    color: #315ca8;
}

.attendance-status.absent {
    background: #fff5df;
    color: #946000;
}

.attendance-distance {
    color: #8b96a8;
    font-size: 10px;
}

/* =========================================================
   STATUS
   ========================================================= */

.status {
    display: inline-flex;
    align-items: center;

    min-height: 25px;

    padding: 4px 9px;

    border-radius: 999px;

    font-size: 10px;
    font-weight: 750;

    white-space: nowrap;
}

.status.approved,
.status.onleave {
    background: #e8f7ef;
    color: #08794a;
}

.status.pending {
    background: #fff5df;
    color: #946000;
}

.status.rejected {
    background: #ffecef;
    color: #b9243b;
}

.status.cancelled {
    background: #eef1f5;
    color: #667085;
}

.status.upcoming {
    background: #edf4ff;
    color: #315ca8;
}


/* =========================================================
   RECENT VEHICLE
   ========================================================= */

.vehicle-row-name {
    display: flex;
    align-items: center;

    gap: 9px;
}

.vehicle-mini-icon {
    width: 31px;
    height: 31px;

    display: flex;
    align-items: center;
    justify-content: center;

    flex: 0 0 31px;

    border-radius: 9px;

    background: #fff0f2;

    font-size: 16px;
}


/* =========================================================
   QUICK ACCESS
   ========================================================= */

.quick-grid {
    display: grid;

    grid-template-columns:
        repeat(4, minmax(0,1fr));

    gap: 12px;
}

.quick-card {
    display: flex;
    align-items: center;

    min-height: 70px;

    gap: 12px;

    padding: 14px;

    border: 1px solid var(--dash-border);
    border-radius: 14px;

    background: #fff;

    color: var(--dash-dark);

    text-decoration: none;

    transition:
        transform .18s ease,
        border-color .18s ease,
        box-shadow .18s ease;
}

.quick-card:hover {
    transform: translateY(-2px);

    border-color: #dfc5c9;

    box-shadow:
        0 9px 22px rgba(31,42,68,.07);
}

.quick-icon {
    width: 40px;
    height: 40px;

    display: flex;
    align-items: center;
    justify-content: center;

    flex: 0 0 40px;

    border-radius: 11px;

    background: #fff1f3;

    font-size: 18px;
}

.quick-card strong {
    display: block;

    margin-bottom: 3px;

    font-size: 12px;
}

.quick-card-content {
    display: block;
    min-width: 0;
}

.quick-card-content > span {
    display: block;
    color: var(--dash-muted);
    font-size: 10px;
}


/* =========================================================
   RESPONSIVE
   ========================================================= */

@media (max-width: 1200px) {

    main.main-content.dashboard-main {
        padding: 25px 22px 45px !important;
    }

    .stat-grid,
    .quick-grid {
        grid-template-columns:
            repeat(2,minmax(0,1fr));
    }

    .dashboard-two-column {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 900px) {

    main.main-content.dashboard-main {
        margin-left: 0 !important;

        padding:
            80px
            18px
            35px !important;
    }

    .dashboard-hero {
        min-height: 310px;
    }
}

@media (max-width: 650px) {

    main.main-content.dashboard-main {
        padding:
            76px
            12px
            30px !important;
    }

    .dashboard-hero {
        min-height: 350px;

        border-radius: 18px;

        background-position: center;
    }

    .hero-content {
        padding: 27px 23px 32px;
    }

    .stat-grid,
    .quick-grid {
        grid-template-columns: 1fr;
    }

    .section-heading {
        align-items: flex-start;
        flex-direction: column;
    }
}


/* =========================================================
   DASHBOARD COMPACT TYPOGRAPHY - 30/09/2026
   ========================================================= */
.dashboard-hero { min-height:225px; border-radius:20px; margin-bottom:20px; }
.hero-content { padding:25px 32px 30px; }
.hero-eyebrow { min-height:24px; padding:4px 10px; margin-bottom:10px; font-size:10px; font-weight:600; }
.hero-content h1 { max-width:780px; font-size:clamp(23px,2.25vw,31px); line-height:1.18; font-weight:650; }
.hero-content > p { margin-top:7px; font-size:12px; font-weight:400; }
.hero-meta { margin-top:10px; font-size:11px; }
.hero-actions { margin-top:16px; gap:8px; }
.hero-action { min-height:36px; padding:7px 13px; font-size:11px; font-weight:600; }
.section-heading h2 { font-size:17px; font-weight:650; }
.section-heading p { font-size:11.5px; }
.section-heading a { font-size:11px; font-weight:600; }
.stat-card { min-height:96px; padding:16px; }
.stat-icon { flex-basis:46px; width:46px; height:46px; font-size:20px; }
.stat-number { font-size:22px; font-weight:700; }
.stat-label { font-size:11.5px; font-weight:600; }
.stat-note { font-size:10px; }
.panel-header { padding:16px 18px; }
.panel-title h3 { font-size:14px; font-weight:650; }
.panel-title p { font-size:10px; }
.panel-link { font-weight:600; }
.attention-label { font-size:11.5px; font-weight:550; }
.attention-number { font-weight:650; }
.vehicle-name { font-size:12px; font-weight:650; }
.vehicle-plate { font-weight:650; }
.vehicle-detail strong { font-size:18px; font-weight:700; }
.dashboard-table th { font-weight:650; }
.dashboard-table td { font-size:11.5px; }
.dashboard-table strong { font-weight:600; }
.quick-card strong { font-weight:600; }
@media (max-width:900px) {
  .dashboard-hero { min-height:245px; }
  .hero-content h1 { font-size:26px; }
}
@media (max-width:650px) {
  .dashboard-hero { min-height:275px; border-radius:16px; }
  .hero-content { padding:22px 20px 26px; }
  .hero-content h1 { font-size:23px; line-height:1.2; }
  .hero-action { min-height:34px; padding:6px 10px; font-size:10.5px; }
}

/* PENGUMUMAN & EVENT */
.company-info-grid {
    display: grid;
    grid-template-columns: minmax(0, 1.15fr) minmax(0, .85fr);
    gap: 16px;
    align-items: start; /* Setiap kad ikut ketinggian kandungan sendiri */
    margin-top: 16px;
    margin-bottom: 25px;
}
.company-info-card {
    min-width: 0;
    height: fit-content; /* Elakkan kotak putih memanjang mengikut kad sebelah */
    align-self: start;
    overflow: hidden;
    border: 1px solid var(--dash-border);
    border-radius: 17px;
    background: #fff;
    box-shadow: 0 7px 24px rgba(31,42,68,.05);
}
.company-info-list { padding: 4px 18px 12px; }
.company-info-item {
    padding: 14px 2px;
    border-bottom: 1px solid #eef1f4;
}
.company-info-item:last-child { border-bottom: 0; }
.company-info-item-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 10px;
}
.company-info-item h4 {
    margin: 0;
    color: var(--dash-dark);
    font-size: 13.5px;
    line-height: 1.5;
    font-weight: 700;
}
.company-info-item p {
    margin: 6px 0 0;
    color: #647084;
    font-size: 12px;
    line-height: 1.65;
    white-space: pre-line;
    overflow-wrap: anywhere;
}
.company-info-meta {
    margin-top: 7px;
    color: var(--dash-muted);
    font-size: 11px;
    line-height: 1.5;
}
.company-info-tag {
    display: inline-flex;
    align-items: center;
    flex-shrink: 0;
    padding: 4px 8px;
    border-radius: 999px;
    background: #f2f4f7;
    color: #667085;
    font-size: 10px;
    font-weight: 750;
}
.company-info-tag.important {
    background: #fff0f2;
    color: var(--dash-maroon);
}
.company-event-date {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 56px;
    min-height: 48px;
    padding: 6px;
    border-radius: 11px;
    background: #fff3f4;
    color: var(--dash-maroon);
    font-size: 11px;
    font-weight: 750;
    text-align: center;
    line-height: 1.35;
    flex-shrink: 0;
}
.company-info-empty {
    padding: 25px 12px;
    color: #929cab;
    font-size: 12px;
    text-align: center;
}
@media (max-width: 900px) {
    .company-info-grid { grid-template-columns: 1fr; }
}

</style>

</head>


<body>

<div class="app-layout">

    <%@ include file="includes/sidebar.jspf" %>


    <main class="main-content dashboard-main">

        <div class="dashboard-container">


            <!-- =====================================================
                 HEADER ACTION
                 ===================================================== -->

            <div class="dashboard-topbar">

                <%@ include file="includes/header-actions.jspf" %>

            </div>


            <!-- =====================================================
                 HERO
                 ===================================================== -->

            <section class="dashboard-hero">

                <div class="hero-content">

                    <span class="hero-eyebrow">
                        <%= esc(roleLabel(dashboardRole)) %>
                    </span>

                    <h1>
                        Selamat Datang,
                        <%= esc(dashboardName) %>
                    </h1>

                    <p>
                        Sistem Pengurusan Staf Permodalan Kedah Berhad
                    </p>

                    <div class="hero-meta">

                        <% if (!position.isBlank()) { %>

                            <span>
                                <%= esc(position) %>
                            </span>

                            <span class="dot">•</span>

                        <% } %>

                        <span>
                            <%= esc(department) %>
                        </span>

                    </div>


                    <div class="hero-actions">

                        <a
                            class="hero-action primary"
                            href="<%= request.getContextPath() %>/apply"
                        >
                            ＋ Permohonan Cuti
                        </a>

                        <a
                            class="hero-action"
                            href="<%= request.getContextPath() %>/vehicle-apply"
                        >
                            🚘 Mohon Kenderaan
                        </a>

                        <a
                            class="hero-action"
                            href="<%= request.getContextPath() %>/inventory"
                        >
                            ▣ Inventori
                        </a>

                        <a
                            class="hero-action"
                            href="<%= request.getContextPath() %>/calendar"
                        >
                            ▦ Kalendar
                        </a>

                    </div>

                </div>

            </section>


            <!-- =====================================================
                 RINGKASAN UTAMA
                 ===================================================== -->

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Ringkasan Hari Ini
                        </h2>

                        <p>
                            Maklumat utama sistem berdasarkan peranan anda
                        </p>

                    </div>

                </div>


                <div class="stat-grid">


                    <% if (isHR) { %>

                    <div class="stat-card">

                        <div class="stat-icon maroon">
                            👥
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= totalStaffCount %>
                            </span>

                            <span class="stat-label">
                                Jumlah Pengguna
                            </span>

                            <span class="stat-note">
                                Pengguna berdaftar
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon gold">
                            📋
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= organizationLeaveCount %>
                            </span>

                            <span class="stat-label">
                                Permohonan Cuti
                            </span>

                            <span class="stat-note">
                                <%= organizationPendingCount %>
                                masih diproses
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon blue">
                            📦
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= inventoryItemCount %>
                            </span>

                            <span class="stat-label">
                                Item Inventori
                            </span>

                            <span class="stat-note">
                                <%= pendingInventoryRequestCount %>
                                permohonan menunggu
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon green">
                            🚘
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= activeVehicleCount %>
                            </span>

                            <span class="stat-label">
                                Kenderaan Aktif
                            </span>

                            <span class="stat-note">
                                <%= todayVehicleApplicationCount %>
                                penggunaan hari ini
                            </span>

                        </div>

                    </div>


                    <% } else if (isHOD) { %>


                    <div class="stat-card">

                        <div class="stat-icon maroon">
                            👥
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= supervisedStaffCount %>
                            </span>

                            <span class="stat-label">
                                Staf Seliaan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon gold">
                            ⏳
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= hodPendingReviewCount %>
                            </span>

                            <span class="stat-label">
                                Menunggu Sokongan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon green">
                            ✓
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= hodCompletedCount %>
                            </span>

                            <span class="stat-label">
                                Selesai Disemak
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon blue">
                            🚘
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= activeVehicleCount %>
                            </span>

                            <span class="stat-label">
                                Kenderaan Aktif
                            </span>

                        </div>

                    </div>


                    <% } else if (isManagement) { %>


                    <div class="stat-card">

                        <div class="stat-icon gold">
                            ⏳
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= managementPendingCount %>
                            </span>

                            <span class="stat-label">
                                Menunggu Keputusan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon green">
                            ✓
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= managementApprovedCount %>
                            </span>

                            <span class="stat-label">
                                Cuti Diluluskan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon maroon">
                            ×
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= managementRejectedCount %>
                            </span>

                            <span class="stat-label">
                                Tidak Diluluskan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon blue">
                            🚘
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= activeVehicleCount %>
                            </span>

                            <span class="stat-label">
                                Kenderaan Aktif
                            </span>

                        </div>

                    </div>


                    <% } else { %>


                    <div class="stat-card">

                        <div class="stat-icon maroon">
                            📋
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= myTotal %>
                            </span>

                            <span class="stat-label">
                                Permohonan Cuti Saya
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon gold">
                            ⏳
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= myPending %>
                            </span>

                            <span class="stat-label">
                                Sedang Diproses
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon green">
                            ✓
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= myApproved %>
                            </span>

                            <span class="stat-label">
                                Cuti Diluluskan
                            </span>

                        </div>

                    </div>


                    <div class="stat-card">

                        <div class="stat-icon blue">
                            🚘
                        </div>

                        <div class="stat-data">

                            <span class="stat-number">
                                <%= myVehicleApplicationCount %>
                            </span>

                            <span class="stat-label">
                                Permohonan Kenderaan
                            </span>

                            <span class="stat-note">
                                <%= myPendingVehicleApplicationCount %>
                                masih menunggu
                            </span>

                        </div>

                    </div>


                    <% } %>


                </div>

            <!-- =====================================================
                 PENGUMUMAN & EVENT SYARIKAT
                 ===================================================== -->

            <section class="company-info-grid">

                <div class="company-info-card">
                    <div class="panel-header">
                        <div class="panel-title">
                            <div class="panel-title-icon">📢</div>
                            <div>
                                <h3>Pengumuman Syarikat</h3>
                                <p>Makluman terkini untuk anda</p>
                            </div>
                        </div>
                        <% if (isHR) { %>
                            <a class="panel-link" href="<%= request.getContextPath() %>/announcements">Pengurusan →</a>
                        <% } %>
                    </div>

                    <div class="company-info-list">
                        <% if (dashboardAnnouncements.isEmpty()) { %>
                            <div class="company-info-empty">
                                Tiada pengumuman aktif buat masa ini.
                            </div>
                        <% } else {
                            for (Map<String,Object> announcement : dashboardAnnouncements) {
                                String announcementCategory =
                                    announcement.get("category") == null
                                        ? "UMUM" : announcement.get("category").toString();
                                String announcementCategoryLabel;
                                switch (announcementCategory) {
                                    case "PENTING": announcementCategoryLabel = "Penting"; break;
                                    case "HR": announcementCategoryLabel = "HR"; break;
                                    case "NOTIS": announcementCategoryLabel = "Notis"; break;
                                    default: announcementCategoryLabel = "Umum";
                                }
                                Object announcementPublishedAt = announcement.get("publishedAt");
                                String announcementDate = announcementPublishedAt == null
                                    ? "Tarikh tidak tersedia"
                                    : new java.text.SimpleDateFormat("dd/MM/yyyy, HH:mm")
                                        .format(announcementPublishedAt);
                        %>
                            <article class="company-info-item">
                                <div class="company-info-item-top">
                                    <h4><%= esc(announcement.get("title")) %></h4>
                                    <span class="company-info-tag <%= "PENTING".equals(announcementCategory) ? "important" : "" %>">
                                        <%= esc(announcementCategoryLabel) %>
                                    </span>
                                </div>
                                <p><%= esc(announcement.get("content")) %></p>
                                <div class="company-info-meta">
                                    Diterbitkan: <%= esc(announcementDate) %>
                                    <% if (announcement.get("creatorName") != null) { %>
                                        · Oleh <%= esc(announcement.get("creatorName")) %>
                                    <% } %>
                                </div>
                            </article>
                        <%  }
                           } %>
                    </div>
                </div>

                <div class="company-info-card">
                    <div class="panel-header">
                        <div class="panel-title">
                            <div class="panel-title-icon">🗓</div>
                            <div>
    <h3>Aktiviti &amp; Program Akan Datang</h3>
    <p>Maklumat aktiviti dan program syarikat</p>
</div>
                        </div>
                        <% if (isHR) { %>
                            <a class="panel-link" href="<%= request.getContextPath() %>/company-events">Pengurusan →</a>
                        <% } %>
                    </div>

                    <div class="company-info-list">
                        <% if (dashboardEvents.isEmpty()) { %>
                            <div class="company-info-empty">
                                Tiada aktiviti atau program akan datang direkodkan.
                            </div>
                        <% } else {
                            for (Map<String,Object> event : dashboardEvents) {
                                Object eventDateObject = event.get("eventDate");
                                String eventDateLabel = eventDateObject == null
                                    ? "—"
                                    : new java.text.SimpleDateFormat("dd/MM/yyyy")
                                        .format(eventDateObject);
                                String eventStart = event.get("startTime") == null
                                    ? "" : event.get("startTime").toString().substring(0, 5);
                                String eventEnd = event.get("endTime") == null
                                    ? "" : event.get("endTime").toString().substring(0, 5);
                        %>
                            <article class="company-info-item">
                                <div class="company-info-item-top">
                                    <div style="min-width:0;">
                                        <h4><%= esc(event.get("title")) %></h4>
                                        <% if (event.get("description") != null && !event.get("description").toString().isBlank()) { %>
                                            <p><%= esc(event.get("description")) %></p>
                                        <% } %>
                                    </div>
                                    <div class="company-event-date"><%= esc(eventDateLabel) %></div>
                                </div>
                                <div class="company-info-meta">
                                    <% if (!eventStart.isBlank()) { %>
                                        <span>⏰ <%= esc(eventStart) %><%= !eventEnd.isBlank() ? " – " + esc(eventEnd) : "" %></span>
                                    <% } %>
                                    <% if (event.get("location") != null && !event.get("location").toString().isBlank()) { %>
                                        <span> · 📍 <%= esc(event.get("location")) %></span>
                                    <% } %>
                                </div>
                            </article>
                        <%  }
                           } %>
                    </div>
                </div>

            </section>


            </section>


            <!-- =====================================================
                 ACTION + VEHICLE
                 ===================================================== -->

            <div class="dashboard-two-column">


                <!-- TINDAKAN -->

                <section class="panel-card">

                    <div class="panel-header">

                        <div class="panel-title">

                            <div class="panel-title-icon">
                                ⚠
                            </div>

                            <div>

                                <h3>
                                    Tindakan Diperlukan
                                </h3>

                                <p>
                                    Perkara yang memerlukan perhatian anda
                                </p>

                            </div>

                        </div>

                        <% if (attentionCount > 0) { %>

                        <span class="attention-number">
                            <%= attentionCount %>
                        </span>

                        <% } %>

                    </div>


                    <div class="attention-list">


                        <% if (isHR) { %>

                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot red"></span>

                                <span class="attention-label">
                                    Permohonan cuti masih diproses
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= organizationPendingCount %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot"></span>

                                <span class="attention-label">
                                    Permohonan inventori
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= pendingInventoryRequestCount %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot blue"></span>

                                <span class="attention-label">
                                    Permohonan kenderaan
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= pendingVehicleApplicationCount %>
                            </span>

                        </div>


                        <% } else if (isHOD) { %>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot red"></span>

                                <span class="attention-label">
                                    Permohonan menunggu sokongan
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= hodPendingReviewCount %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot blue"></span>

                                <span class="attention-label">
                                    Cuti staf akan datang
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= supervisedUpcomingLeave.size() %>
                            </span>

                        </div>


                        <% } else if (isManagement) { %>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot red"></span>

                                <span class="attention-label">
                                    Permohonan cuti menunggu keputusan
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= managementPendingCount %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot blue"></span>

                                <span class="attention-label">
                                    Permohonan kenderaan menunggu
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= pendingVehicleApplicationCount %>
                            </span>

                        </div>


                        <% } else { %>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot red"></span>

                                <span class="attention-label">
                                    Permohonan cuti sedang diproses
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= myPending %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot"></span>

                                <span class="attention-label">
                                    Permohonan inventori sedang diproses
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= myPendingInventoryRequestCount %>
                            </span>

                        </div>


                        <div class="attention-row">

                            <div class="attention-info">

                                <span class="attention-dot blue"></span>

                                <span class="attention-label">
                                    Permohonan kenderaan sedang diproses
                                </span>

                            </div>

                            <span class="attention-number">
                                <%= myPendingVehicleApplicationCount %>
                            </span>

                        </div>


                        <% } %>


                    </div>

                    <% if (attentionCount == 0) { %>
                    <div class="attention-total attention-total-empty">
                        <span class="attention-empty-icon">✓</span>
                        <span>Tiada tindakan segera diperlukan pada masa ini.</span>
                    </div>
                    <% } else { %>
                    <div class="attention-total">
                        Terdapat <strong><%= attentionCount %></strong> perkara yang masih memerlukan perhatian.
                    </div>
                    <% } %>

                </section>


                <!-- KENDERAAN -->

                <section class="panel-card">

                    <div class="panel-header">

                        <div class="panel-title">

                            <div class="panel-title-icon">
                                🚘
                            </div>

                            <div>

                                <h3>
                                    Kenderaan Syarikat
                                </h3>

                                <p>
                                    Status penggunaan kenderaan PKB
                                </p>

                            </div>

                        </div>

                        <a
                            class="panel-link"
                            href="<%= request.getContextPath() %>/vehicle-calendar"
                        >
                            Buka Kalendar →
                        </a>

                    </div>


                    <div class="vehicle-list">

    <%
        if (activeVehicles.isEmpty()) {
    %>

        <div class="vehicle-empty">
            Tiada kenderaan aktif direkodkan pada masa ini.
        </div>

    <%
        } else {

            for (
                Map<String,Object> vehicle :
                activeVehicles
            ) {

                // =========================================================
                // MAKLUMAT KENDERAAN
                // =========================================================

                String activeVehicleName =
                        vehicle.get("vehicleName") == null
                            ? "Kenderaan"
                            : vehicle.get("vehicleName").toString();

                String activeVehiclePlate =
                        vehicle.get("plateNumber") == null
                            ? "—"
                            : vehicle.get("plateNumber").toString();


                // =========================================================
                // TENTUKAN GAMBAR KENDERAAN
                // =========================================================

                String vehicleImage =
                        "nissan-xtrail-black.png";

                String vehicleNameLower =
                        activeVehicleName
                            .trim()
                            .toLowerCase();


                // Lamborghini Aventador
                if (
                    vehicleNameLower.contains("lamborghini")
                    ||
                    vehicleNameLower.contains("aventador")
                ) {

                    vehicleImage =
                            "lamborghini.png";
                }


                // Nissan X-Trail
                else if (
                    vehicleNameLower.contains("nissan")
                    ||
                    vehicleNameLower.contains("xtrail")
                    ||
                    vehicleNameLower.contains("x-trail")
                ) {

                    vehicleImage =
                            "nissan-xtrail-black.png";
                }
    %>


        <!-- =========================================================
             VEHICLE CARD
             ========================================================= -->

        <div class="vehicle-card">

            <div class="vehicle-card-top">


                <!-- GAMBAR KENDERAAN -->

                <div class="vehicle-card-image">

                    <img
                        src="<%= request.getContextPath() %>/images/<%= vehicleImage %>"
                        alt="<%= esc(activeVehicleName) %>"
                        class="vehicle-real-image"
                    >

                </div>


                <!-- MAKLUMAT KENDERAAN -->

                <div class="vehicle-card-info">

                    <div class="vehicle-name">
                        <%= esc(activeVehicleName) %>
                    </div>

                    <div class="vehicle-plate">
                        <%= esc(activeVehiclePlate) %>
                    </div>

                </div>

            </div>


            <!-- STATUS -->

            <span class="vehicle-active-badge">
                Aktif
            </span>

        </div>


    <%
            }
        }
    %>

</div>


                    <div class="vehicle-details">

                        <div class="vehicle-detail">

                            <strong>
                                <%= activeVehicleCount %>
                            </strong>

                            <span>
                                Kenderaan Aktif
                            </span>

                        </div>


                        <div class="vehicle-detail">

                            <strong>
                                <%= maintenanceVehicleCount %>
                            </strong>

                            <span>
                                Penyelenggaraan
                            </span>

                        </div>


                        <div class="vehicle-detail">

                            <strong>
                                <%= todayVehicleApplicationCount %>
                            </strong>

                            <span>
                                Digunakan Hari Ini
                            </span>

                        </div>


                        <div class="vehicle-detail">

                            <strong>
                                <%= (isHR || isManagement)
                                        ? pendingVehicleApplicationCount
                                        : myPendingVehicleApplicationCount %>
                            </strong>

                            <span>
                                Permohonan Menunggu
                            </span>

                        </div>

                    </div>

                </section>

            </div>


            <!-- =====================================================
                 STAFF CURRENT LEAVE
                 ===================================================== -->

            <% if (isHOD || isHR || isManagement) { %>

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Staf Sedang Bercuti Hari Ini
                        </h2>

                        <p>
                            Staf yang mempunyai cuti diluluskan dan sedang berlangsung
                        </p>

                    </div>

                    <a href="<%= request.getContextPath() %>/calendar">
                        Buka Kalendar →
                    </a>

                </div>


                <div class="table-card">

                    <table class="dashboard-table">

                        <thead>

                            <tr>
                                <th>Nama</th>
                                <th>Jawatan</th>
                                <th>Jabatan</th>
                                <th>Jenis Cuti</th>
                                <th>Tarikh</th>
                                <th>Jumlah</th>
                                <th>Status</th>
                            </tr>

                        </thead>


                        <tbody>

                        <%
                            if (displayedCurrentLeave.isEmpty()) {
                        %>

                            <tr>

                                <td
                                    colspan="7"
                                    class="empty-row"
                                >
                                    Tiada staf sedang bercuti hari ini.
                                </td>

                            </tr>

                        <%
                            } else {

                                for (
                                    Map<String,Object> leave :
                                    displayedCurrentLeave
                                ) {

                                    String staffName =
                                            leave.get("staffName") == null
                                                ? "—"
                                                : leave.get("staffName").toString();

                                    String staffPosition =
                                            leave.get("staffPosition") == null
                                                ? "—"
                                                : leave.get("staffPosition").toString();

                                    String staffDepartment =
                                            departmentLabel(
                                                leave.get("staffDepartment")
                                            );

                                    String leaveType =
                                            leave.get("type") == null
                                                ? "—"
                                                : leave.get("type").toString();

                                    String start =
                                            leave.get("start") == null
                                                ? "—"
                                                : leave.get("start").toString();

                                    String end =
                                            leave.get("end") == null
                                                ? "—"
                                                : leave.get("end").toString();

                                    int duration =
                                            num(leave.get("duration"));
                        %>

                            <tr>

                                <td>
                                    <strong>
                                        <%= esc(staffName) %>
                                    </strong>
                                </td>

                                <td>
                                    <%= esc(staffPosition) %>
                                </td>

                                <td>
                                    <%= esc(staffDepartment) %>
                                </td>

                                <td>
                                    <%= esc(leaveType) %>
                                </td>

                                <td>
                                    <%= esc(start) %>
                                    hingga
                                    <%= esc(end) %>
                                </td>

                                <td>
                                    <strong><%= duration %></strong>
                                    hari
                                </td>

                                <td>
                                    <span class="status onleave">
                                        Sedang Bercuti
                                    </span>
                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>

                    </table>

                </div>

            </section>

            <% } %>


            <!-- =====================================================
                 UPCOMING STAFF LEAVE
                 ===================================================== -->

            <% if (isHOD || isHR || isManagement) { %>

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Cuti Staf Akan Datang
                        </h2>

                        <p>
                            Cuti yang telah diluluskan dan belum bermula
                        </p>

                    </div>

                    <a href="<%= request.getContextPath() %>/calendar">
                        Lihat Semua →
                    </a>

                </div>


                <div class="table-card">

                    <table class="dashboard-table">

                        <thead>

                            <tr>
                                <th>Nama</th>
                                <th>Jawatan</th>
                                <th>Jabatan</th>
                                <th>Jenis Cuti</th>
                                <th>Tarikh</th>
                                <th>Jumlah</th>
                                <th>Status</th>
                            </tr>

                        </thead>


                        <tbody>

                        <%
                            if (displayedUpcomingLeave.isEmpty()) {
                        %>

                            <tr>

                                <td
                                    colspan="7"
                                    class="empty-row"
                                >
                                    Tiada cuti staf akan datang.
                                </td>

                            </tr>

                        <%
                            } else {

                                int displayedUpcomingCount = 0;
                                for (
                                    Map<String,Object> leave :
                                    displayedUpcomingLeave
                                ) {
                                    if (displayedUpcomingCount >= 5) break;
                                    displayedUpcomingCount++;

                                    String staffName =
                                            leave.get("staffName") == null
                                                ? "—"
                                                : leave.get("staffName").toString();

                                    String staffPosition =
                                            leave.get("staffPosition") == null
                                                ? "—"
                                                : leave.get("staffPosition").toString();

                                    String staffDepartment =
                                            departmentLabel(
                                                leave.get("staffDepartment")
                                            );

                                    String leaveType =
                                            leave.get("type") == null
                                                ? "—"
                                                : leave.get("type").toString();

                                    String start =
                                            leave.get("start") == null
                                                ? "—"
                                                : leave.get("start").toString();

                                    String end =
                                            leave.get("end") == null
                                                ? "—"
                                                : leave.get("end").toString();

                                    int duration =
                                            num(leave.get("duration"));
                        %>

                            <tr>

                                <td>
                                    <strong>
                                        <%= esc(staffName) %>
                                    </strong>
                                </td>

                                <td>
                                    <%= esc(staffPosition) %>
                                </td>

                                <td>
                                    <%= esc(staffDepartment) %>
                                </td>

                                <td>
                                    <%= esc(leaveType) %>
                                </td>

                                <td>
                                    <%= esc(start) %>
                                    hingga
                                    <%= esc(end) %>
                                </td>

                                <td>
                                    <strong><%= duration %></strong>
                                    hari
                                </td>

                                <td>
                                    <span class="status upcoming">
                                        Akan Bercuti
                                    </span>
                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>

                    </table>

                </div>

            </section>

            <% } %>


            <!-- =====================================================
                 RECENT VEHICLE APPLICATIONS
                 ===================================================== -->

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Permohonan Kenderaan Terkini
                        </h2>

                        <p>
                            Rekod penggunaan kenderaan syarikat yang terkini
                        </p>

                    </div>

                    <a href="<%= request.getContextPath() %>/my-vehicle-applications">
                        Lihat Semua →
                    </a>

                </div>


                <div class="table-card">

                    <table class="dashboard-table">

                        <thead>

                            <tr>

                                <% if (isHR || isManagement) { %>
                                    <th>Pemohon</th>
                                <% } %>

                                <th>Kenderaan</th>
                                <th>No. Permohonan</th>
                                <th>Tarikh</th>
                                <th>Masa</th>
                                <th>Pemandu</th>
                                <th>Destinasi</th>
                                <th>Status</th>

                            </tr>

                        </thead>


                        <tbody>

                        <%
                            if (vehicleRows.isEmpty()) {
                        %>

                            <tr>

                                <td
                                    colspan="<%= (isHR || isManagement) ? 8 : 7 %>"
                                    class="empty-row"
                                >
                                    Tiada permohonan kenderaan terkini.
                                </td>

                            </tr>

                        <%
                            } else {

                                int vehicleDisplayCount = 0;
                                for (
                                    Map<String,Object> vehicle :
                                    vehicleRows
                                ) {
                                    if (vehicleDisplayCount >= 5) break;
                                    vehicleDisplayCount++;

                                    Object vehicleStatus =
                                            vehicle.get("status");
                        %>

                            <tr>

                                <% if (isHR || isManagement) { %>

                                <td>
                                    <strong>
                                        <%= esc(vehicle.get("applicantName")) %>
                                    </strong>
                                </td>

                                <% } %>


                                <td>

                                    <div class="vehicle-row-name">

                                        <div class="vehicle-mini-icon">
                                            🚘
                                        </div>

                                        <div>

                                            <strong>
                                                <%= esc(vehicle.get("vehicleName")) %>
                                            </strong>

                                            <br>

                                            <span style="font-size:10px;color:#8d98a8;">
                                                <%= esc(vehicle.get("plateNumber")) %>
                                            </span>

                                        </div>

                                    </div>

                                </td>


                                <td>
                                    <strong>
                                        <%= esc(vehicle.get("applicationNo")) %>
                                    </strong>
                                </td>


                                <td>
                                    <%= esc(vehicle.get("useDate")) %>
                                </td>


                                <td>

                                    <%= esc(vehicle.get("startTime")) %>

                                    -

                                    <%= esc(vehicle.get("returnTime")) %>

                                </td>


                                <td>
                                    <%= esc(vehicle.get("driverName")) %>
                                </td>


                                <td>
                                    <%= esc(vehicle.get("destination")) %>
                                </td>


                                <td>

                                    <span class="status <%= statusClass(vehicleStatus) %>">

                                        <%= esc(
                                            statusLabel(vehicleStatus)
                                        ) %>

                                    </span>

                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- =====================================================
                 MY UPCOMING LEAVE
                 ===================================================== -->

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Cuti Saya Akan Datang
                        </h2>

                        <p>
                            Cuti anda yang telah diluluskan dan belum bermula
                        </p>

                    </div>

                    <a href="<%= request.getContextPath() %>/applications">
                        Permohonan Saya →
                    </a>

                </div>


                <div class="table-card">

                    <table class="dashboard-table">

                        <thead>

                            <tr>
                                <th>No. Permohonan</th>
                                <th>Jenis Cuti</th>
                                <th>Tarikh</th>
                                <th>Jumlah</th>
                                <th>Status</th>
                            </tr>

                        </thead>


                        <tbody>

                        <%
                            if (upcoming.isEmpty()) {
                        %>

                            <tr>

                                <td
                                    colspan="5"
                                    class="empty-row"
                                >
                                    Tiada cuti akan datang.
                                </td>

                            </tr>

                        <%
                            } else {

                                int upcomingDisplayCount = 0;
                                for (
                                    Map<String,Object> leave :
                                    upcoming
                                ) {
                                    if (upcomingDisplayCount >= 5) break;
                                    upcomingDisplayCount++;

                                    String applicationNo =
                                            leave.get("applicationNo") == null
                                                ? "—"
                                                : leave.get("applicationNo").toString();

                                    String leaveType =
                                            leave.get("type") == null
                                                ? "—"
                                                : leave.get("type").toString();

                                    String start =
                                            leave.get("start") == null
                                                ? "—"
                                                : leave.get("start").toString();

                                    String end =
                                            leave.get("end") == null
                                                ? "—"
                                                : leave.get("end").toString();

                                    int duration =
                                            num(leave.get("duration"));
                        %>

                            <tr>

                                <td>
                                    <strong>
                                        <%= esc(applicationNo) %>
                                    </strong>
                                </td>

                                <td>
                                    <%= esc(leaveType) %>
                                </td>

                                <td>
                                    <%= esc(start) %>
                                    hingga
                                    <%= esc(end) %>
                                </td>

                                <td>
                                    <strong><%= duration %></strong>
                                    hari
                                </td>

                                <td>
                                    <span class="status approved">
                                        Diluluskan
                                    </span>
                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- =====================================================
                 QUICK ACCESS
                 ===================================================== -->

            <section class="dashboard-section">

                <div class="section-heading">

                    <div>

                        <h2>
                            Akses Pantas
                        </h2>

                        <p>
                            Pintasan untuk urusan harian
                        </p>

                    </div>

                </div>


                <div class="quick-grid">


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/apply"
                    >

                        <span class="quick-icon">
                            📅
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Permohonan Cuti
                            </strong>

                            <span>
                                Mohon cuti baharu
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/vehicle-apply"
                    >

                        <span class="quick-icon">
                            🚘
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Permohonan Kenderaan
                            </strong>

                            <span>
                                Tempah kenderaan syarikat
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/inventory"
                    >

                        <span class="quick-icon">
                            📦
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Inventori
                            </strong>

                            <span>
                                Semak dan mohon inventori
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/attendance"
                    >

                        <span class="quick-icon">
                            ✓
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Kehadiran
                            </strong>

                            <span>
                                Check In dan Check Out
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/calendar"
                    >

                        <span class="quick-icon">
                            🗓
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Kalendar Cuti
                            </strong>

                            <span>
                                Lihat jadual cuti staf
                            </span>

                        </span>

                    </a>


                    <% if (isHR) { %>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/staff"
                    >

                        <span class="quick-icon">
                            👥
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Pengurusan Staf
                            </strong>

                            <span>
                                Urus akaun pengguna
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/inventory-admin"
                    >

                        <span class="quick-icon">
                            ⚙
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Pengurusan Inventori
                            </strong>

                            <span>
                                Urus stok syarikat
                            </span>

                        </span>

                    </a>


                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/vehicle-management"
                    >

                        <span class="quick-icon">
                            🚙
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Pengurusan Kenderaan
                            </strong>

                            <span>
                                Urus kenderaan syarikat
                            </span>

                        </span>

                    </a>


                    <% } %>


                    <% if (isHOD) { %>

                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/admin"
                    >

                        <span class="quick-icon">
                            ✓
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Sokongan Cuti
                            </strong>

                            <span>
                                Semak permohonan staf
                            </span>

                        </span>

                    </a>

                    <% } %>


                    <% if (isManagement) { %>

                    <a
                        class="quick-card"
                        href="<%= request.getContextPath() %>/admin"
                    >

                        <span class="quick-icon">
                            ✓
                        </span>

                        <span class="quick-card-content">

                            <strong>
                                Kelulusan Cuti
                            </strong>

                            <span>
                                Buat keputusan permohonan
                            </span>

                        </span>

                    </a>

                    <% } %>


                </div>

            </section>


        </div>

    </main>

</div>

</body>

</html>