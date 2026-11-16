<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%!
    private String balanceEscape(Object value) {
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

    private int balanceNumber(Object value) {
        if (value == null) {
            return 0;
        }

        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        try {
            return Integer.parseInt(value.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

 
    private String leaveIcon(String leaveName) {
        if (leaveName == null) {
            return "📅";
        }

        String name = leaveName.toLowerCase();

        if (name.contains("tahunan")) {
            return "📅";
        }

        if (name.contains("kecemasan")) {
            return "⚡";
        }

        if (name.contains("sakit")) {
            return "✚";
        }

        if (name.contains("bersalin")) {
            return "♡";
        }

        if (name.contains("kahwin")) {
            return "♢";
        }

        if (name.contains("ihsan")) {
            return "♡";
        }

        if (name.contains("tanpa rekod")) {
            return "✓";
        }

        if (name.contains("tanpa gaji")) {
            return "−";
        }

        return "📄";
    }
%>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    String balanceStaffName =
        request.getAttribute("staffName") == null
            ? (
                session.getAttribute("userName") == null
                    ? "Pengguna"
                    : session.getAttribute("userName").toString()
            )
            : request.getAttribute("staffName").toString();

    if (balanceStaffName == null || balanceStaffName.isBlank()) {
        balanceStaffName = "Pengguna";
    }

    String balancePosition =
        request.getAttribute("position") == null
            ? ""
            : request.getAttribute("position").toString();

    String balanceDepartmentCode =
        request.getAttribute("department") == null
            ? ""
            : request.getAttribute("department").toString();

    int balanceYear =
        request.getAttribute("currentYear") instanceof Number
            ? ((Number) request.getAttribute("currentYear")).intValue()
            : java.time.Year.now().getValue();

    int sharedCarryForwardDays =
        balanceNumber(
            request.getAttribute("sharedCarryForwardDays")
        );

    int sharedCarryForwardUsed =
        balanceNumber(
            request.getAttribute("sharedCarryForwardUsed")
        );

    int sharedCarryForwardRemaining =
        balanceNumber(
            request.getAttribute("sharedCarryForwardRemaining")
        );

    int sharedCurrentYearUsed =
        balanceNumber(
            request.getAttribute("sharedCurrentYearUsed")
        );

    int sharedCurrentYearRemaining =
        balanceNumber(
            request.getAttribute("sharedCurrentYearRemaining")
        );

    int sharedEntitlement =
        balanceNumber(
            request.getAttribute("sharedEntitlement")
        );

    int sharedUsed =
        balanceNumber(
            request.getAttribute("sharedUsed")
        );

    int sharedRemaining =
        balanceNumber(
            request.getAttribute("sharedRemaining")
        );

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> balances =
        (List<Map<String, Object>>)
            request.getAttribute("balances");

    int sharedTotalAvailable =
        sharedEntitlement + sharedCarryForwardDays;

    int sharedRemainingPercentage = 0;

    if (sharedTotalAvailable > 0) {
        sharedRemainingPercentage =
            (int) Math.round(
                (sharedRemaining * 100.0)
                / sharedTotalAvailable
            );

        sharedRemainingPercentage =
            Math.max(
                0,
                Math.min(
                    100,
                    sharedRemainingPercentage
                )
            );
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

    <title>
        Baki Cuti Saya - PKB
    </title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260930-balance-new"
    >

    <style>

        /* =========================================================
           PAGE
           ========================================================= */

        .leave-balance-page {
            width: 100%;
            max-width: 1500px;
            margin: 0 auto;
            /* Selaraskan tajuk dan kandungan dengan halaman lain */
            padding: 0 0 60px;
            box-sizing: border-box;
        }

        .leave-balance-page * {
            box-sizing: border-box;
        }


        /* =========================================================
           HEADER
           ========================================================= */

        .leave-balance-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 24px;
        }

        .leave-balance-title h1 {
            margin: 0;
            color: #101828;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .leave-balance-title p {
            margin: 7px 0 0;
            color: #8190a8;
            font-size: 14px;
        }


        /* =========================================================
           HERO / PROFILE
           ========================================================= */

        .balance-hero {
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 25px;

            padding: 25px 28px;

            background:
                linear-gradient(
                    135deg,
                    #8f1426 0%,
                    #a5192d 55%,
                    #b32338 100%
                );

            border-radius: 20px;
            box-shadow:
                0 12px 35px rgba(142, 20, 38, 0.18);

            margin-bottom: 24px;
        }

        .balance-hero::after {
            content: "";
            position: absolute;
            width: 240px;
            height: 240px;
            right: -80px;
            top: -110px;
            border-radius: 50%;
            background: rgba(255,255,255,0.06);
        }

        .balance-hero::before {
            content: "";
            position: absolute;
            width: 150px;
            height: 150px;
            right: 120px;
            bottom: -100px;
            border-radius: 50%;
            background: rgba(255,255,255,0.05);
        }

        .balance-profile {
            position: relative;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .balance-profile-avatar {
            width: 58px;
            height: 58px;

            display: flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            border-radius: 16px;

            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.22);

            color: #fff;
            font-size: 22px;
            font-weight: 800;
        }

        .balance-profile-name {
            color: #fff;
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 5px;
        }

        .balance-profile-meta {
            color: rgba(255,255,255,0.78);
            font-size: 13px;
            line-height: 1.5;
        }

        .balance-year {
            position: relative;
            z-index: 2;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            padding: 10px 16px;

            border: 1px solid rgba(255,255,255,0.22);
            border-radius: 999px;

            background: rgba(255,255,255,0.12);

            color: #fff;
            font-size: 13px;
            font-weight: 700;

            white-space: nowrap;
        }


        /* =========================================================
           SECTION HEADER
           ========================================================= */

        .balance-section-heading {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 16px;
        }

        .balance-section-heading h2 {
            margin: 0;
            color: #101828;
            font-size: 19px;
            font-weight: 800;
        }

        .balance-section-heading p {
            margin: 5px 0 0;
            color: #8a98ae;
            font-size: 13px;
        }


        /* =========================================================
           SHARED LEAVE MAIN CARD
           ========================================================= */

        .shared-leave-card {
            display: grid;
            grid-template-columns: 1.15fr 1fr;
            gap: 0;

            overflow: hidden;

            background: #fff;

            border: 1px solid #e5e9f0;
            border-radius: 20px;

            box-shadow:
                0 8px 30px rgba(15,23,42,0.055);

            margin-bottom: 30px;
        }

        .shared-main {
            padding: 26px 28px;
            border-right: 1px solid #edf0f4;
        }

        .shared-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 22px;
        }

        .shared-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .shared-icon {
            width: 46px;
            height: 46px;

            display: flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            border-radius: 13px;

            background: #fff0f2;

            color: #9f1729;
            font-size: 20px;
        }

        .shared-title h3 {
            margin: 0 0 3px;
            color: #111827;
            font-size: 16px;
            font-weight: 800;
        }

        .shared-title p {
            margin: 0;
            color: #8a98ae;
            font-size: 12px;
        }

        .shared-badge {
            display: inline-flex;
            align-items: center;

            padding: 7px 11px;

            border-radius: 999px;

            background: #fff5df;
            border: 1px solid #f3d59a;

            color: #946200;

            font-size: 10px;
            font-weight: 800;
            letter-spacing: .3px;
        }

        .shared-number {
            display: flex;
            align-items: baseline;
            gap: 8px;
            margin-bottom: 5px;
        }

        .shared-number strong {
            color: #9e1729;
            font-size: 44px;
            line-height: 1;
            font-weight: 800;
            letter-spacing: -1.5px;
        }

        .shared-number span {
            color: #8492a8;
            font-size: 13px;
        }

        .shared-caption {
            color: #66758c;
            font-size: 12px;
            margin-bottom: 16px;
        }

        .main-progress {
            width: 100%;
            height: 8px;

            overflow: hidden;

            border-radius: 999px;

            background: #edf0f4;

            margin-bottom: 20px;
        }

        .main-progress div {
            height: 100%;
            border-radius: inherit;

            background:
                linear-gradient(
                    90deg,
                    #9e1729,
                    #d79b1d
                );
        }

        .shared-stat-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 10px;
        }

        .shared-stat {
            padding: 12px 13px;

            border-radius: 12px;
            background: #f8fafc;
            border: 1px solid #eef1f5;
        }

        .shared-stat span {
            display: block;
            margin-bottom: 4px;

            color: #8a98ae;
            font-size: 11px;
        }

        .shared-stat strong {
            color: #172033;
            font-size: 14px;
            font-weight: 800;
        }


        /* =========================================================
           CARRY FORWARD
           ========================================================= */

        .carry-panel {
            padding: 26px 28px;
            background: #fbfcfe;
        }

        .carry-header {
            display: flex;
            align-items: center;
            gap: 11px;
            margin-bottom: 20px;
        }

        .carry-header-icon {
            width: 38px;
            height: 38px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 11px;

            background: #eef4ff;
            color: #3f6fb6;

            font-size: 16px;
        }

        .carry-header h3 {
            margin: 0;
            color: #172033;
            font-size: 15px;
            font-weight: 800;
        }

        .carry-header p {
            margin: 3px 0 0;
            color: #8a98ae;
            font-size: 11px;
        }

        .carry-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }

        .carry-item {
            padding: 13px 14px;

            background: #fff;
            border: 1px solid #e6eaf0;
            border-radius: 12px;
        }

        .carry-item span {
            display: block;
            color: #8190a8;
            font-size: 11px;
            margin-bottom: 5px;
            line-height: 1.35;
        }

        .carry-item strong {
            color: #152033;
            font-size: 14px;
            font-weight: 800;
        }

        .carry-message {
            margin-top: 12px;
            padding: 11px 13px;

            border-radius: 11px;

            font-size: 11px;
            line-height: 1.5;
        }

        .carry-message.warning {
            background: #fff8e8;
            border: 1px solid #f3dda7;
            color: #805c12;
        }

        .carry-message.success {
            background: #eefbf3;
            border: 1px solid #cdeed9;
            color: #267245;
        }

        .carry-message.normal {
            background: #f4f7fa;
            border: 1px solid #e1e6ec;
            color: #718096;
        }


        /* =========================================================
           OTHER LEAVE
           ========================================================= */

        .leave-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 16px;
        }

        .leave-card {
            position: relative;
            overflow: hidden;

            min-height: 210px;

            padding: 20px;

            background: #fff;

            border: 1px solid #e5e9ef;
            border-radius: 17px;

            box-shadow:
                0 6px 22px rgba(15,23,42,0.045);

            transition:
                transform .2s ease,
                box-shadow .2s ease,
                border-color .2s ease;
        }

        .leave-card:hover {
            transform: translateY(-2px);
            border-color: #d8dde6;

            box-shadow:
                0 10px 30px rgba(15,23,42,0.075);
        }

        .leave-card-top {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 20px;
        }

        .leave-name-wrap {
            display: flex;
            align-items: center;
            gap: 11px;
        }

        .leave-icon {
            width: 40px;
            height: 40px;

            display: flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            border-radius: 11px;

            background: #f8edf0;
            color: #a3182c;

            font-size: 16px;
            font-weight: 800;
        }

        .leave-name {
            color: #172033;
            font-size: 14px;
            font-weight: 800;
            line-height: 1.3;
        }

        .document-badge {
            display: inline-flex;
            align-items: center;

            padding: 5px 8px;

            border-radius: 999px;

            background: #fff7e5;
            border: 1px solid #eed8a6;

            color: #8a6205;

            font-size: 9px;
            font-weight: 800;

            white-space: nowrap;
        }

        .leave-balance-number {
            display: flex;
            align-items: baseline;
            gap: 6px;
            margin-bottom: 13px;
        }

        .leave-balance-number strong {
            color: #a0182b;
            font-size: 30px;
            font-weight: 800;
            line-height: 1;
        }

        .leave-balance-number span {
            color: #8a98ae;
            font-size: 11px;
        }

        .leave-progress {
            width: 100%;
            height: 6px;

            overflow: hidden;

            background: #eef1f4;
            border-radius: 999px;

            margin-bottom: 17px;
        }

        .leave-progress div {
            height: 100%;
            border-radius: inherit;

            background:
                linear-gradient(
                    90deg,
                    #a0182b,
                    #d8a122
                );
        }

        .leave-stats {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 8px;
        }

        .leave-stat {
            padding: 10px 11px;

            background: #f8fafc;

            border-radius: 10px;
        }

        .leave-stat span {
            display: block;

            color: #8a98ae;
            font-size: 10px;

            margin-bottom: 3px;
        }

        .leave-stat strong {
            color: #172033;
            font-size: 12px;
            font-weight: 800;
        }


        /* =========================================================
           NO QUOTA
           ========================================================= */

        .no-quota-card {
            min-height: 175px;
        }

        .no-quota-body {
            padding-top: 5px;
        }

        .available-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;

            padding: 7px 10px;

            background: #ecf9f1;
            border-radius: 999px;

            color: #25764a;

            font-size: 11px;
            font-weight: 800;

            margin-bottom: 12px;
        }

        .available-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #31a267;
        }

        .no-quota-body p {
            margin: 0;
            color: #758399;
            font-size: 11px;
            line-height: 1.55;
        }


        /* =========================================================
           NOT CONFIGURED
           ========================================================= */

        .not-configured {
            padding: 13px 14px;

            border-radius: 11px;

            background: #fff8e8;
            border: 1px solid #f3dda7;

            color: #846018;

            font-size: 11px;
            line-height: 1.5;
        }


        /* =========================================================
           INFO PANEL
           ========================================================= */

        .balance-info-panel {
            display: flex;
            align-items: flex-start;
            gap: 13px;

            margin-top: 24px;

            padding: 16px 18px;

            background: #f8fafc;
            border: 1px solid #e6eaf0;
            border-radius: 14px;
        }

        .balance-info-icon {
            width: 34px;
            height: 34px;

            display: flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            border-radius: 10px;

            background: #edf3ff;

            color: #4773b7;
            font-size: 15px;
            font-weight: 800;
        }

        .balance-info-content strong {
            display: block;

            margin-bottom: 4px;

            color: #172033;
            font-size: 12px;
        }

        .balance-info-content p {
            margin: 0;

            color: #748198;
            font-size: 11px;
            line-height: 1.55;
        }


        /* =========================================================
           ACTION
           ========================================================= */

        .balance-actions {
            display: flex;
            justify-content: flex-end;

            margin-top: 22px;
        }

        .balance-action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;

            min-height: 42px;

            padding: 0 18px;

            border-radius: 11px;

            background: #9e1729;

            color: #fff !important;

            text-decoration: none;

            font-size: 12px;
            font-weight: 700;

            box-shadow:
                0 6px 16px rgba(158,23,41,0.18);

            transition:
                background .2s ease,
                transform .2s ease;
        }

        .balance-action-btn:hover {
            background: #861224;
            transform: translateY(-1px);
        }


        /* =========================================================
           EMPTY
           ========================================================= */

        .empty-state {
            padding: 45px 25px;

            background: #fff;

            border: 1px solid #e5e9ef;
            border-radius: 17px;

            color: #7c899d;
            font-size: 13px;
            text-align: center;
        }


        /* =========================================================
           RESPONSIVE
           ========================================================= */

        @media (max-width: 1200px) {

            .shared-leave-card {
                grid-template-columns: 1fr;
            }

            .shared-main {
                border-right: none;
                border-bottom: 1px solid #edf0f4;
            }

            .leave-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 850px) {

            .leave-balance-page {
                padding:
                    24px 20px 50px;
            }

            .balance-hero {
                align-items: flex-start;
                flex-direction: column;
            }

            .shared-stat-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 650px) {

            .leave-balance-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .leave-grid {
                grid-template-columns: 1fr;
            }

            .carry-grid {
                grid-template-columns: 1fr;
            }

            .shared-top {
                align-items: flex-start;
                flex-direction: column;
            }

            .balance-profile {
                align-items: flex-start;
            }

            .shared-number strong {
                font-size: 36px;
            }
        }

    
/* =========================================================
   PAPARAN BAKI CUTI - COMPACT / CLEAN
   ========================================================= */

/* Banner profil merah lama tidak digunakan */
.balance-hero {
    display: none !important;
}

/* Tajuk halaman */
.page-title,
.balance-page-title,
.main-title {
    font-size: 25px !important;
    line-height: 1.25 !important;
    font-weight: 600 !important;
    letter-spacing: -0.02em !important;
}

.page-subtitle,
.balance-page-subtitle,
.main-subtitle {
    font-size: 12px !important;
    font-weight: 400 !important;
}

/* Tajuk seksyen */
.section-title,
.section-heading h2,
.balance-section-title {
    font-size: 18px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
}

.section-subtitle,
.section-heading p,
.balance-section-subtitle {
    font-size: 12px !important;
    font-weight: 400 !important;
}

/* Kad utama */
.main-balance-card,
.balance-main-card,
.shared-balance-card {
    border-radius: 18px !important;
}

.balance-content,
.balance-card-content,
.shared-balance-content {
    padding: 24px 28px !important;
}

.balance-card h2,
.balance-card h3,
.shared-balance-card h2,
.shared-balance-card h3 {
    font-weight: 600 !important;
}

.balance-card p,
.shared-balance-card p {
    font-weight: 400 !important;
}

/* Nama cuti */
.leave-title,
.balance-name,
.balance-card-title {
    font-size: 16px !important;
    font-weight: 600 !important;
}

.leave-description,
.balance-description {
    font-size: 11.5px !important;
    font-weight: 400 !important;
}

/* Nilai baki utama */
.balance-number,
.balance-value,
.remaining-number,
.remaining-days {
    font-size: 36px !important;
    line-height: 1 !important;
    font-weight: 650 !important;
}

.balance-unit,
.remaining-label {
    font-size: 11px !important;
    font-weight: 400 !important;
}

/* Badge */
.balance-badge,
.shared-badge,
.document-badge {
    font-size: 10px !important;
    font-weight: 600 !important;
    padding: 5px 10px !important;
}

/* Kotak statistik */
.balance-stat,
.summary-item,
.balance-summary-item {
    padding: 13px 14px !important;
    border-radius: 12px !important;
}

.balance-stat span,
.summary-item span,
.balance-summary-item span {
    font-size: 10.5px !important;
    font-weight: 400 !important;
}

.balance-stat strong,
.summary-item strong,
.balance-summary-item strong {
    font-size: 13px !important;
    font-weight: 600 !important;
}

/* Pecahan baki */
.carry-panel {
    padding: 22px !important;
    border-radius: 16px !important;
}

.carry-header {
    margin-bottom: 17px !important;
}

.carry-header-icon {
    width: 42px !important;
    height: 42px !important;
    min-width: 42px !important;
    font-size: 17px !important;
}

.carry-header h3 {
    font-size: 16px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
}

.carry-header p {
    margin-top: 4px !important;
    font-size: 11.5px !important;
    line-height: 1.4 !important;
    font-weight: 400 !important;
}

.carry-grid {
    gap: 11px !important;
}

.carry-item {
    min-height: 74px !important;
    padding: 13px 15px !important;
    border-radius: 12px !important;
}

.carry-item span {
    font-size: 10.5px !important;
    line-height: 1.35 !important;
    font-weight: 400 !important;
}

.carry-item strong {
    margin-top: 5px !important;
    font-size: 13px !important;
    line-height: 1.25 !important;
    font-weight: 600 !important;
}

.carry-note,
.carry-message,
.carry-info {
    padding: 11px 14px !important;
    font-size: 10.5px !important;
    line-height: 1.45 !important;
    font-weight: 400 !important;
    border-radius: 11px !important;
}

/* Kad jenis cuti lain */
.leave-card,
.leave-type-card {
    border-radius: 16px !important;
}

.leave-card h3,
.leave-type-card h3 {
    font-size: 15px !important;
    font-weight: 600 !important;
}

.leave-card strong,
.leave-type-card strong {
    font-weight: 600 !important;
}

/* Elakkan teks keseluruhan kelihatan terlalu tebal */
.balance-page strong,
.leave-balance-page strong,
main strong {
    font-weight: 600;
}

/* Responsive */
@media (max-width: 900px) {
    .balance-content,
    .balance-card-content,
    .shared-balance-content {
        padding: 20px !important;
    }

    .carry-panel {
        padding: 18px !important;
    }
}

@media (max-width: 650px) {
    .page-title,
    .balance-page-title,
    .main-title {
        font-size: 22px !important;
    }

    .section-title,
    .section-heading h2,
    .balance-section-title {
        font-size: 17px !important;
    }

    .balance-number,
    .balance-value,
    .remaining-number,
    .remaining-days {
        font-size: 31px !important;
    }

    .carry-grid {
        grid-template-columns: 1fr !important;
    }

    .carry-item {
        min-height: 68px !important;
    }
}

</style>


<style>
/* =========================================================
   FINAL TYPOGRAPHY OVERRIDE
   Rujukan: gaya Permohonan Inventori Saya
   ========================================================= */

main,
main * {
    font-weight: 400;
}

/* Tajuk halaman: jelas tetapi tidak terlalu tebal */
main h1,
.page-title,
.balance-page-title,
.main-title {
    font-size: 25px !important;
    line-height: 1.25 !important;
    font-weight: 600 !important;
    letter-spacing: -0.015em !important;
}

/* Tajuk seksyen */
main h2,
.section-title,
.section-heading h2,
.balance-section-title {
    font-size: 17px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
}

/* Tajuk dalam kad */
main h3,
.balance-card h3,
.shared-balance-card h3,
.carry-header h3,
.leave-card h3,
.leave-type-card h3 {
    font-size: 15px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
}

/* Semua penerangan dan label */
main p,
main span,
main label,
.page-subtitle,
.section-subtitle,
.section-heading p,
.balance-description,
.leave-description,
.carry-header p,
.carry-item span,
.balance-stat span,
.summary-item span,
.balance-summary-item span {
    font-weight: 400 !important;
}

/* Nama cuti */
.leave-title,
.balance-name,
.balance-card-title {
    font-size: 15px !important;
    font-weight: 600 !important;
}

/* Nilai utama - sederhana seperti card inventori */
.balance-number,
.balance-value,
.remaining-number,
.remaining-days {
    font-size: 34px !important;
    line-height: 1 !important;
    font-weight: 600 !important;
}

/* Nilai dalam kotak kecil */
.carry-item strong,
.balance-stat strong,
.summary-item strong,
.balance-summary-item strong {
    font-size: 13px !important;
    font-weight: 600 !important;
}

/* Override tag strong/b yang menyebabkan terlalu bold */
main strong,
main b {
    font-weight: 600 !important;
}

/* Badge */
.balance-badge,
.shared-badge,
.document-badge {
    font-size: 10px !important;
    font-weight: 500 !important;
}

/* Pecahan baki */
.carry-header h3 {
    font-size: 15px !important;
    font-weight: 600 !important;
}

.carry-header p {
    font-size: 11px !important;
    font-weight: 400 !important;
}

.carry-item span {
    font-size: 10.5px !important;
    font-weight: 400 !important;
}

.carry-item strong {
    font-size: 12.5px !important;
    font-weight: 600 !important;
}

.carry-note,
.carry-message,
.carry-info {
    font-size: 10.5px !important;
    font-weight: 400 !important;
}

/* Tajuk Baki Cuti Utama dan Jenis Cuti Lain */
.balance-section-title,
.section-heading h2 {
    font-weight: 600 !important;
}

/* Jangan guna berat 700/800/850 dalam kandungan utama */
main .font-bold,
main .font-extrabold {
    font-weight: 600 !important;
}

@media (max-width: 650px) {
    main h1,
    .page-title,
    .balance-page-title,
    .main-title {
        font-size: 22px !important;
    }

    main h2,
    .section-title,
    .section-heading h2,
    .balance-section-title {
        font-size: 16px !important;
    }

    .balance-number,
    .balance-value,
    .remaining-number,
    .remaining-days {
        font-size: 30px !important;
    }
}
</style>


<style>
/* =========================================================
   BALANCED TYPOGRAPHY - PKB BAKI CUTI
   ========================================================= */

/* Teks biasa kekal ringan tetapi bukan terlalu nipis */
main,
main p,
main span,
main label {
    font-weight: 450 !important;
}

/* Tajuk halaman */
main h1,
.page-title,
.balance-page-title,
.main-title {
    font-size: 25px !important;
    font-weight: 650 !important;
    line-height: 1.25 !important;
}

/* Tajuk seksyen */
main h2,
.section-title,
.section-heading h2,
.balance-section-title {
    font-size: 17px !important;
    font-weight: 650 !important;
}

/* Tajuk kad */
main h3,
.balance-card h3,
.shared-balance-card h3,
.carry-header h3,
.leave-card h3,
.leave-type-card h3,
.leave-title,
.balance-name,
.balance-card-title {
    font-size: 15px !important;
    font-weight: 650 !important;
}

/* Penerangan */
.page-subtitle,
.section-subtitle,
.section-heading p,
.balance-description,
.leave-description,
.carry-header p {
    font-weight: 450 !important;
}

/* Nilai utama */
.balance-number,
.balance-value,
.remaining-number,
.remaining-days {
    font-size: 34px !important;
    font-weight: 650 !important;
}

/* Nilai dalam kotak */
main strong,
main b,
.carry-item strong,
.balance-stat strong,
.summary-item strong,
.balance-summary-item strong {
    font-weight: 650 !important;
}

/* Label kotak */
.carry-item span,
.balance-stat span,
.summary-item span,
.balance-summary-item span {
    font-weight: 450 !important;
}

/* Badge */
.balance-badge,
.shared-badge,
.document-badge {
    font-weight: 600 !important;
}

/* Sidebar/header tidak disentuh oleh aturan main di atas */
</style>


<style>
/* =========================================================
   PKB - PAGE ALIGNMENT
   Selaraskan Baki Cuti dengan Kalendar Cuti / Permohonan Cuti
   Layout sahaja - fungsi dan data tidak diubah
   ========================================================= */

/* Kawasan kandungan utama */
main,
.main-content,
.content,
.page-content {
    box-sizing: border-box;
}

/* Header halaman */
main .page-header,
main .content-header,
main .balance-page-header {
    margin-bottom: 22px !important;
}

main .page-title,
main .balance-page-title,
main .main-title,
main h1 {
    margin: 0 0 5px 0 !important;
    font-size: 24px !important;
    line-height: 1.25 !important;
    font-weight: 650 !important;
    letter-spacing: -0.25px !important;
}

main .page-subtitle,
main .balance-page-subtitle {
    margin: 0 !important;
    font-size: 13px !important;
    line-height: 1.5 !important;
    font-weight: 450 !important;
}

/* Section */
main .section-heading,
main .balance-section-heading {
    margin: 0 0 16px 0 !important;
}

main .section-heading h2,
main .balance-section-heading h2,
main .section-title,
main .balance-section-title {
    margin: 0 0 5px 0 !important;
    font-size: 17px !important;
    line-height: 1.3 !important;
    font-weight: 650 !important;
}

main .section-heading p,
main .balance-section-heading p,
main .section-subtitle {
    margin: 0 !important;
    font-size: 13px !important;
    line-height: 1.45 !important;
    font-weight: 450 !important;
}

/* Jarak antara seksyen */
main section + section,
main .balance-section + .balance-section {
    margin-top: 32px !important;
}

/* Kad baki utama */
main .balance-card,
main .shared-balance-card,
main .main-balance-card {
    border-radius: 16px !important;
}

/* Padding kandungan kiri/kanan kad supaya konsisten */
main .balance-card-content,
main .shared-balance-content,
main .balance-main,
main .balance-left,
main .carry-section,
main .carry-panel,
main .balance-right {
    box-sizing: border-box;
}

/* Tajuk di dalam kad */
main .balance-card h3,
main .shared-balance-card h3,
main .carry-header h3,
main .leave-card h3,
main .leave-type-card h3 {
    font-size: 15px !important;
    line-height: 1.35 !important;
    font-weight: 650 !important;
}

/* Teks penerangan kad */
main .balance-card p,
main .shared-balance-card p,
main .carry-header p,
main .leave-card p {
    font-size: 12px !important;
    line-height: 1.5 !important;
}

/* Nilai utama - kekal jelas tetapi tidak terlalu besar */
main .balance-number,
main .balance-value,
main .remaining-number,
main .remaining-days {
    font-size: 34px !important;
    line-height: 1 !important;
    font-weight: 650 !important;
}

/* Kotak pecahan baki */
main .carry-item,
main .balance-stat,
main .summary-item,
main .balance-summary-item {
    min-height: 70px !important;
}

/* Section Jenis Cuti Lain */
main .other-leave-section,
main .other-leaves-section,
main .leave-types-section {
    margin-top: 32px !important;
}

/* Responsive */
@media (max-width: 1100px) {
    main .page-title,
    main .balance-page-title,
    main .main-title,
    main h1 {
        font-size: 22px !important;
    }

    main .balance-number,
    main .balance-value,
    main .remaining-number,
    main .remaining-days {
        font-size: 31px !important;
    }
}

@media (max-width: 768px) {
    main .page-header,
    main .content-header,
    main .balance-page-header {
        margin-bottom: 18px !important;
    }

    main section + section,
    main .balance-section + .balance-section,
    main .other-leave-section,
    main .other-leaves-section,
    main .leave-types-section {
        margin-top: 24px !important;
    }
}
</style>

<style>
@media (max-width: 650px) {
    .leave-balance-header {
        position: relative;
        display: block;
        min-height: 44px;
        margin-bottom: 18px;
    }

    .leave-balance-title {
        min-width: 0;
        padding-right: 100px;
    }

    .leave-balance-header > .pkb-header-actions {
        position: absolute;
        top: 0;
        right: 0;
        z-index: 2;
    }

    .leave-grid { grid-template-columns: 1fr; gap: 12px; }

    .leave-card,
    .leave-card.no-quota-card {
        min-height: 0;
        padding: 14px;
        border-radius: 14px;
    }

    .leave-card-top {
        align-items: center;
        gap: 8px;
        margin-bottom: 11px;
    }

    .leave-name-wrap { min-width: 0; gap: 9px; }

    .leave-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        font-size: 14px;
    }

    .leave-name {
        font-size: 13px !important;
        line-height: 1.3 !important;
    }

    .document-badge { padding: 4px 7px; font-size: 8px !important; }
    .leave-balance-number { gap: 5px; margin-bottom: 8px; }
    .leave-balance-number strong { font-size: 26px !important; }
    .leave-balance-number span { font-size: 10px; }
    .leave-progress { margin-bottom: 10px; }

    .leave-stats { gap: 7px; }
    .leave-stat { padding: 8px 9px; border-radius: 9px; }
    .leave-stat span { margin-bottom: 2px; font-size: 9px; }
    .leave-stat strong { font-size: 11px; }

    .no-quota-body { padding-top: 0; }
    .available-pill { margin-bottom: 8px; padding: 6px 9px; font-size: 10px; }
    .no-quota-body p { font-size: 10px; line-height: 1.45; }
    .not-configured { padding: 10px 11px; font-size: 10px; }
}
</style>
<style>
@media (max-width: 650px) {
    .carry-panel { padding: 15px 13px; }
    .carry-header { gap: 9px; margin-bottom: 11px; }
    .carry-header-icon { width: 32px; height: 32px; border-radius: 9px; font-size: 14px; }
    .carry-header h3 { font-size: 14px !important; }
    .carry-header p { font-size: 10px; line-height: 1.35; }
    .carry-panel .carry-grid { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; gap: 8px; }
    .carry-item { min-width: 0; padding: 9px 10px; border-radius: 9px; }
    .carry-item span { margin-bottom: 3px; font-size: 9px; line-height: 1.3; }
    .carry-item strong { font-size: 12px; }
    .carry-message { margin-top: 9px; padding: 9px 10px; font-size: 10px; }
}

@media (max-width: 360px) {
    .carry-panel .carry-grid { grid-template-columns: 1fr !important; }
}
</style>
<style>
@media (max-width: 650px) {
    .shared-leave-card {
        grid-template-columns: 1fr;
        margin-bottom: 20px;
        border-radius: 15px;
    }

    .shared-main { padding: 17px 15px; }

    .shared-top {
        align-items: flex-start;
        flex-direction: row;
        gap: 8px;
        margin-bottom: 15px;
    }

    .shared-title { min-width: 0; gap: 9px; }
    .shared-title h3 { font-size: 14px !important; line-height: 1.3; }
    .shared-title p { font-size: 10px; line-height: 1.35; }
    .shared-icon { width: 36px; height: 36px; border-radius: 10px; font-size: 16px; }
    .shared-badge { flex-shrink: 0; padding: 5px 8px; font-size: 8px !important; }
    .shared-number { gap: 6px; margin-bottom: 4px; }
    .shared-number strong { font-size: 36px !important; }
    .shared-number span { font-size: 11px; }
    .shared-caption { margin-bottom: 11px; font-size: 10px; line-height: 1.4; }
    .main-progress { height: 6px; margin-bottom: 13px; }

    .shared-main .shared-stat-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
        gap: 8px;
    }

    .shared-stat { min-width: 0; padding: 9px 10px; border-radius: 9px; }
    .shared-stat:last-child { grid-column: 1 / -1; }
    .shared-stat span { font-size: 9px; line-height: 1.3; }
    .shared-stat strong { font-size: 12px; }
}

@media (max-width: 360px) {
    .shared-main { padding: 15px 12px; }
    .shared-top { flex-wrap: wrap; }
    .shared-main .shared-stat-grid { grid-template-columns: 1fr !important; }
    .shared-stat:last-child { grid-column: auto; }
}
</style>
</head>

<body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="leave-balance-page">


            <!-- =====================================================
                 HEADER
                 ===================================================== -->

            <div class="leave-balance-header">

                <div class="leave-balance-title">

                    <h1>Baki Cuti Saya</h1>

                    <p>
                        Ringkasan kelayakan, penggunaan dan baki cuti anda
                    </p>

                </div>

                <%@ include file="includes/header-actions.jspf" %>

            </div>


            <!-- =====================================================
                 PROFILE HERO
                 ===================================================== -->


            <!-- =====================================================
                 SHARED LEAVE
                 ===================================================== -->

            <div class="balance-section-heading">

                <div>

                    <h2>Baki Cuti Utama</h2>

                    <p>
                        Ringkasan baki cuti yang digunakan bersama
                    </p>

                </div>

            </div>


            <section class="shared-leave-card">

                <div class="shared-main">

                    <div class="shared-top">

                        <div class="shared-title">

                            <div class="shared-icon">
                                📅
                            </div>

                            <div>

                                <h3>
                                    Cuti Tahunan &amp; Cuti Kecemasan
                                </h3>

                                <p>
                                    Menggunakan satu baki bersama
                                </p>

                            </div>

                        </div>

                        <span class="shared-badge">
                            BAKI BERSAMA
                        </span>

                    </div>


                    <div class="shared-number">

                        <strong>
                            <%= sharedRemaining %>
                        </strong>

                        <span>
                            hari berbaki
                        </span>

                    </div>


                    <div class="shared-caption">

                        daripada
                        <strong>
                            <%= sharedTotalAvailable %> hari
                        </strong>
                        yang tersedia bagi tahun
                        <%= balanceYear %>

                    </div>


                    <div
                        class="main-progress"
                        title="<%= sharedRemaining %> daripada <%= sharedTotalAvailable %> hari tersedia"
                    >

                        <div
                            style="width: <%= sharedRemainingPercentage %>%;"
                        ></div>

                    </div>


                    <div class="shared-stat-grid">

                        <div class="shared-stat">

                            <span>
                                Peruntukan <%= balanceYear %>
                            </span>

                            <strong>
                                <%= sharedEntitlement %> hari
                            </strong>

                        </div>


                        <div class="shared-stat">

                            <span>
                                Jumlah Digunakan
                            </span>

                            <strong>
                                <%= sharedUsed %> hari
                            </strong>

                        </div>


                        <div class="shared-stat">

                            <span>
                                Baki Dibawa Ke Hadapan
                            </span>

                            <strong>
                                <%= sharedCarryForwardDays %> hari
                            </strong>

                        </div>

                    </div>

                </div>


                <!-- =================================================
                     CARRY FORWARD
                     ================================================= -->

                <div class="carry-panel">

                    <div class="carry-header">

                        <div class="carry-header-icon">
                            ↻
                        </div>

                        <div>

                            <h3>
                                Pecahan Baki <%= balanceYear %>
                            </h3>

                            <p>
                                Peruntukan semasa dan baki dibawa ke hadapan
                            </p>

                        </div>

                    </div>


                    <div class="carry-grid">

                        <div class="carry-item">

                            <span>
                                Baki Dibawa Dari
                                <%= balanceYear - 1 %>
                            </span>

                            <strong>
                                <%= sharedCarryForwardDays %> hari
                            </strong>

                        </div>


                        <div class="carry-item">

                            <span>
                                Baki Terdahulu Digunakan
                            </span>

                            <strong>
                                <%= sharedCarryForwardUsed %> hari
                            </strong>

                        </div>


                        <div class="carry-item">

                            <span>
                                Baki Terdahulu
                            </span>

                            <strong>
                                <%= sharedCarryForwardRemaining %> hari
                            </strong>

                        </div>


                        <div class="carry-item">

                            <span>
                                Digunakan Peruntukan
                                <%= balanceYear %>
                            </span>

                            <strong>
                                <%= sharedCurrentYearUsed %> hari
                            </strong>

                        </div>


                        <div class="carry-item">

                            <span>
                                Baki Peruntukan
                                <%= balanceYear %>
                            </span>

                            <strong>
                                <%= sharedCurrentYearRemaining %> hari
                            </strong>

                        </div>


                        <div class="carry-item">

                            <span>
                                Jumlah Baki Semasa
                            </span>

                            <strong>
                                <%= sharedRemaining %> hari
                            </strong>

                        </div>

                    </div>


                    <% if (sharedCarryForwardRemaining > 0) { %>

                        <div class="carry-message warning">

                            <strong>
                                <%= sharedCarryForwardRemaining %>
                                hari Baki Dibawa Ke Hadapan
                            </strong>

                            perlu digunakan sebelum
                            <strong>
                                31 Disember <%= balanceYear %>
                            </strong>.

                        </div>

                    <% } else if (sharedCarryForwardDays > 0) { %>

                        <div class="carry-message success">

                            ✓ Baki Dibawa Ke Hadapan bagi tahun
                            <%= balanceYear %>
                            telah digunakan sepenuhnya.

                        </div>

                    <% } else { %>

                        <div class="carry-message normal">

                            Tiada baki cuti dibawa ke hadapan daripada tahun
                            <%= balanceYear - 1 %>.

                        </div>

                    <% } %>

                </div>

            </section>


            <!-- =====================================================
                 OTHER LEAVE
                 ===================================================== -->

            <div class="balance-section-heading">

                <div>

                    <h2>Jenis Cuti Lain</h2>

                    <p>
                        Kelayakan dan baki mengikut jenis cuti
                    </p>

                </div>

            </div>


            <%
                if (
                    balances != null
                    &&
                    !balances.isEmpty()
                ) {
            %>


            <div class="leave-grid">


            <%
                for (
                    Map<String, Object> balance :
                    balances
                ) {

                    String leaveTypeName =
                        balance.get("leaveTypeName") == null
                            ? "Jenis Cuti"
                            : balance
                                .get("leaveTypeName")
                                .toString();

                    boolean requiresDocument =
                        Boolean.TRUE.equals(
                            balance.get(
                                "requiresDocument"
                            )
                        );

                    boolean sharedBalance =
                        Boolean.TRUE.equals(
                            balance.get(
                                "sharedBalance"
                            )
                        );

                    boolean noQuota =
                        Boolean.TRUE.equals(
                            balance.get(
                                "noQuota"
                            )
                        );

                    boolean balanceConfigured =
                        Boolean.TRUE.equals(
                            balance.get(
                                "balanceConfigured"
                            )
                        );

                    int entitlement =
                        balanceNumber(
                            balance.get(
                                "entitlement"
                            )
                        );

                    int usedDays =
                        balanceNumber(
                            balance.get(
                                "usedDays"
                            )
                        );

                    int remainingDays =
                        balanceNumber(
                            balance.get(
                                "remainingDays"
                            )
                        );


                    /*
                     * Cuti Tahunan dan Cuti Kecemasan
                     * sudah dipaparkan pada kad utama.
                     */
                    if (sharedBalance) {
                        continue;
                    }


                    int remainingPercentage = 0;

                    if (entitlement > 0) {

                        remainingPercentage =
                            (int) Math.round(
                                (
                                    remainingDays
                                    *
                                    100.0
                                )
                                /
                                entitlement
                            );

                        remainingPercentage =
                            Math.max(
                                0,
                                Math.min(
                                    100,
                                    remainingPercentage
                                )
                            );
                    }
            %>


                <!-- =================================================
                     NO QUOTA
                     ================================================= -->

                <% if (noQuota) { %>

                    <div class="leave-card no-quota-card">

                        <div class="leave-card-top">

                            <div class="leave-name-wrap">

                                <div class="leave-icon">
                                    <%= leaveIcon(leaveTypeName) %>
                                </div>

                                <div class="leave-name">

                                    <%= balanceEscape(
                                        leaveTypeName
                                    ) %>

                                </div>

                            </div>


                            <% if (requiresDocument) { %>

                                <span class="document-badge">
                                    DOKUMEN
                                </span>

                            <% } %>

                        </div>


                        <div class="no-quota-body">

                            <div class="available-pill">

                                <span class="available-dot"></span>

                                Boleh Dipohon

                            </div>

                            <p>
                                Jenis cuti ini tidak mempunyai
                                kuota tetap. Permohonan tertakluk
                                kepada kelulusan Pengurusan.
                            </p>

                        </div>

                    </div>


                <!-- =================================================
                     NOT CONFIGURED
                     ================================================= -->

                <% } else if (!balanceConfigured) { %>

                    <div class="leave-card">

                        <div class="leave-card-top">

                            <div class="leave-name-wrap">

                                <div class="leave-icon">
                                    <%= leaveIcon(leaveTypeName) %>
                                </div>

                                <div class="leave-name">

                                    <%= balanceEscape(
                                        leaveTypeName
                                    ) %>

                                </div>

                            </div>


                            <% if (requiresDocument) { %>

                                <span class="document-badge">
                                    DOKUMEN
                                </span>

                            <% } %>

                        </div>


                        <div class="not-configured">

                            Kuota bagi jenis cuti ini belum
                            ditetapkan oleh Pentadbir Sistem.

                        </div>

                    </div>


                <!-- =================================================
                     NORMAL LEAVE
                     ================================================= -->

                <% } else { %>

                    <div class="leave-card">

                        <div class="leave-card-top">

                            <div class="leave-name-wrap">

                                <div class="leave-icon">
                                    <%= leaveIcon(leaveTypeName) %>
                                </div>

                                <div class="leave-name">

                                    <%= balanceEscape(
                                        leaveTypeName
                                    ) %>

                                </div>

                            </div>


                            <% if (requiresDocument) { %>

                                <span class="document-badge">
                                    DOKUMEN
                                </span>

                            <% } %>

                        </div>


                        <div class="leave-balance-number">

                            <strong>
                                <%= remainingDays %>
                            </strong>

                            <span>
                                hari berbaki
                            </span>

                        </div>


                        <div
                            class="leave-progress"
                            title="<%= remainingDays %> daripada <%= entitlement %> hari"
                        >

                            <div
                                style="width: <%= remainingPercentage %>%;"
                            ></div>

                        </div>


                        <div class="leave-stats">

                            <div class="leave-stat">

                                <span>
                                    Kelayakan
                                </span>

                                <strong>
                                    <%= entitlement %> hari
                                </strong>

                            </div>


                            <div class="leave-stat">

                                <span>
                                    Digunakan
                                </span>

                                <strong>
                                    <%= usedDays %> hari
                                </strong>

                            </div>

                        </div>

                    </div>

                <% } %>


            <%
                }
            %>


            </div>


            <% } else { %>

                <div class="empty-state">
                    Tiada maklumat baki cuti dijumpai.
                </div>

            <% } %>


            <!-- =====================================================
                 INFORMATION
                 ===================================================== -->

            <div class="balance-info-panel">

                <div class="balance-info-icon">
                    i
                </div>

                <div class="balance-info-content">

                    <strong>
                        Maklumat Baki Cuti
                    </strong>

                    <p>
                        Cuti Tahunan dan Cuti Kecemasan menggunakan
                        satu baki bersama. Cuti Tanpa Rekod,
                        Cuti Tanpa Gaji dan Lain-lain tidak mempunyai
                        kuota tetap dan boleh dipohon tertakluk kepada
                        kelulusan Pengurusan.
                    </p>

                </div>

            </div>


            <!-- =====================================================
                 ACTION
                 ===================================================== -->

            <div class="balance-actions">

                <a
                    href="<%= request.getContextPath() %>/apply"
                    class="balance-action-btn"
                >

                    + Buat Permohonan Cuti

                </a>

            </div>


        </div>

    </main>

</div>

</body>

</html>