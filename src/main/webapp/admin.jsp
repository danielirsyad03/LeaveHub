<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!

    /* =========================================================
       HELPER - ESCAPE HTML
       ========================================================= */

    private String adminEscape(Object value) {

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


    /* =========================================================
       HELPER - ATTRIBUTE
       ========================================================= */

    private String adminAttr(Object value) {

        return adminEscape(value)
            .replace("\n", " ")
            .replace("\r", " ");
    }


    /* =========================================================
       HELPER - NUMBER
       ========================================================= */

    private int adminNum(Object value) {

        if (value == null) {
            return 0;
        }

        if (value instanceof Number) {
            return ((Number)value).intValue();
        }

        try {

            return Integer.parseInt(
                value.toString().trim()
            );

        } catch (Exception e) {

            return 0;
        }
    }


    /* =========================================================
       HELPER - DAYS
       ========================================================= */

    private String adminDays(Object value) {

        if (value == null) {
            return "—";
        }

        try {

            BigDecimal number =
                new BigDecimal(
                    value.toString()
                );

            return number
                .stripTrailingZeros()
                .toPlainString();

        } catch (Exception e) {

            return value.toString();
        }
    }


    /* =========================================================
       HELPER - DEPARTMENT
       ========================================================= */

    private String adminDepartment(String department) {

        if (
            department == null
            ||
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


    /* =========================================================
       HELPER - DATE
       ========================================================= */

    private String adminDate(Object value) {

        if (value == null) {
            return "—";
        }

        try {

            if (value instanceof Date) {

                return ((Date)value)
                    .toLocalDate()
                    .format(
                        DateTimeFormatter.ofPattern(
                            "dd/MM/yyyy"
                        )
                    );
            }

            if (value instanceof Timestamp) {

                return ((Timestamp)value)
                    .toLocalDateTime()
                    .format(
                        DateTimeFormatter.ofPattern(
                            "dd/MM/yyyy, hh:mm a"
                        )
                    );
            }

        } catch (Exception ignored) {
        }

        return String.valueOf(value);
    }


    /* =========================================================
       HELPER - STATUS LABEL
       ========================================================= */

    private String adminStatusLabel(String status) {

        if (status == null) {
            return "—";
        }

        switch (
            status.trim().toUpperCase()
        ) {

            case "APPROVED":
                return "Diluluskan";

            case "REJECTED":
                return "Tidak Diluluskan";

            case "CANCELLED":
                return "Dibatalkan";

            case "PENDING":
            case "PENDING_HEAD":
                return "Menunggu Ketua Unit";

            case "PENDING_ADMIN":
            case "PENDING_MANAGEMENT":
                return "Menunggu Pengurusan";

            default:
                return status;
        }
    }


    /* =========================================================
       HELPER - STATUS CLASS
       ========================================================= */

    private String adminStatusClass(String status) {

        if (status == null) {
            return "pending";
        }

        switch (
            status.trim().toUpperCase()
        ) {

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


    /* =========================================================
       HELPER - BOOLEAN
       ========================================================= */

    private boolean adminBool(Object value) {

        return Boolean.TRUE.equals(value)
            ||
            (
                value != null
                &&
                "true".equalsIgnoreCase(
                    value.toString()
                )
            );
    }


    /* =========================================================
       HELPER - TEXT
       ========================================================= */

    private String adminText(
            Object value,
            String fallback) {

        if (value == null) {
            return fallback;
        }

        String text =
            value.toString().trim();

        return text.isBlank()
            ? fallback
            : text;
    }


    /* =========================================================
       HELPER - HIDE BALANCE
       ========================================================= */

    private boolean adminHideBalance(String leaveType) {

        if (leaveType == null) {
            return false;
        }

        String value =
            leaveType.trim();

        return
            "Cuti Tanpa Rekod".equalsIgnoreCase(value)
            ||
            "Cuti Tanpa Gaji".equalsIgnoreCase(value)
            ||
            "Lain-lain".equalsIgnoreCase(value);
    }

%>


<%

    /* =========================================================
       SECURITY
       ========================================================= */

    if (
        session.getAttribute("userId") == null
    ) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    String role =
        session.getAttribute("userRole") == null
            ? ""
            : session
                .getAttribute("userRole")
                .toString()
                .trim()
                .toUpperCase();


    boolean isHR =
        "HR".equals(role);

    boolean isHOD =
        "HOD".equals(role);

    boolean isManagement =
        "MANAGEMENT".equals(role);


    if (
        !isHR
        &&
        !isHOD
        &&
        !isManagement
    ) {

        response.sendError(403);

        return;
    }


    /* =========================================================
       PAGE INFORMATION
       ========================================================= */

    String pageTitle =
        adminText(
            request.getAttribute("pageTitle"),
            isManagement
                ? "Kelulusan Permohonan Cuti"
                : (
                    isHOD
                        ? "Sokongan Permohonan Cuti"
                        : "Rekod Permohonan Cuti"
                )
        );


    String pageDescription =
        adminText(
            request.getAttribute("pageDescription"),
            isManagement
                ? "Semak dan buat keputusan akhir permohonan cuti staf"
                : (
                    isHOD
                        ? "Semak dan beri sokongan kepada permohonan cuti staf di bawah seliaan anda"
                        : "Lihat rekod dan status permohonan cuti staf"
                )
        );


    @SuppressWarnings("unchecked")
    List<Map<String,Object>> rows =
        (List<Map<String,Object>>)
            request.getAttribute("rows");


    /* =========================================================
       STATISTICS
       ========================================================= */

    int totalApplications =
        adminNum(
            request.getAttribute(
                "totalApplications"
            )
        );


    int pendingApplications =
        adminNum(
            request.getAttribute(
                "pendingApplications"
            )
        );


    int approvedApplications =
        adminNum(
            request.getAttribute(
                "approvedApplications"
            )
        );


    int rejectedApplications =
        adminNum(
            request.getAttribute(
                "rejectedApplications"
            )
        );


    int cancelledApplications =
        adminNum(
            request.getAttribute(
                "cancelledApplications"
            )
        );


    int notReviewedApplications =
        adminNum(
            request.getAttribute(
                "notReviewedByHodApplications"
            )
        );


    int completedHodApplications =
        adminNum(
            request.getAttribute(
                "completedHodApplications"
            )
        );


    int completedApplications =
        approvedApplications
        +
        rejectedApplications;


    String success =
        request.getParameter("success");


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
    LeaveHub - <%= adminEscape(pageTitle) %>
</title>

<link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260927-admin-v2"
/>


<style>
.approval-page {
    width: 100%;
    max-width: 1450px;
    margin: 0 auto;
}

.approval-header {
    width: 100%;
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 24px;
    margin-bottom: 22px;
}

.approval-header h1 {
    margin: 0 0 6px;
    color: #172033;
    font-size: 28px;
    line-height: 1.2;
    font-weight: 700;
    letter-spacing: -0.3px;
}

.approval-header p {
    margin: 0;
    color: #7e899c;
    font-size: 14px;
    line-height: 1.5;
}

.approval-message {
    margin-bottom: 16px;
    padding: 14px 16px;
    border-radius: 12px;
    font-size: 13px;
    font-weight: 600;
    line-height: 1.5;
}

.approval-message.success {
    background: #e9f8f0;
    border: 1px solid #cde8d9;
    color: #18794e;
}

.approval-message.error {
    background: #fff0f2;
    border: 1px solid #efcdd2;
    color: #b32636;
}

.approval-role-card {
    position: relative;
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 20px;
    padding: 16px 18px;
    overflow: hidden;
    background: linear-gradient(
            135deg,
            #fffafa,
            #ffffff 65%,
            #fffaf0
        );
    border: 1px solid #eadde0;
    border-radius: 14px;
}

.approval-role-card::before {
    content: "";
    position: absolute;
    top: 10px;
    bottom: 10px;
    left: 0;
    width: 3px;
    border-radius: 0 3px 3px 0;
    background: linear-gradient(
            180deg,
            #8d1f2d,
            #d5a12b
        );
}

.approval-role-icon {
    width: 42px;
    height: 42px;
    flex: 0 0 42px;
    display: grid;
    place-items: center;
    border: 1px solid #efdadd;
    border-radius: 11px;
    background: #fff4f5;
    color: #8d1f2d;
}

.approval-role-icon svg {
    width: 19px;
    height: 19px;
    fill: none;
    stroke: currentColor;
    stroke-width: 1.8;
    stroke-linecap: round;
    stroke-linejoin: round;
}

.approval-role-card strong {
    display: block;
    margin-bottom: 3px;
    color: #8d1f2d;
    font-size: 15px;
    font-weight: 800;
}

.approval-role-card p {
    margin: 0;
    color: #778194;
    font-size: 13px;
    line-height: 1.5;
}

.approval-stats {
    display: grid;
    grid-template-columns: repeat(
            6,
            minmax(0, 1fr)
        );
    gap: 12px;
    margin-bottom: 22px;
}

.approval-stat {
    position: relative;
    min-width: 0;
    min-height: 124px;
    padding: 16px;
    overflow: hidden;
    border: 1px solid #e3e7ed;
    border-radius: 14px;
    background: #ffffff;
    text-align: left;
    cursor: pointer;
    transition: transform .18s ease,
        border-color .18s ease,
        box-shadow .18s ease;
}

.approval-stat:hover {
    transform: translateY(-2px);
    border-color: #dec6ca;
    box-shadow: 0 8px 22px
        rgba(24, 32, 51, .05);
}

.approval-stat.active {
    border-color: #ddb7bd;
    background: #fff9fa;
    box-shadow: inset 3px 0 0 #8d1f2d;
}

.approval-stat span {
    display: block;
    margin-bottom: 10px;
    color: #7d899c;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: .15px;
    text-transform: uppercase;
}

.approval-stat strong {
    display: block;
    color: #172033;
    font-size: 29px;
    line-height: 1;
    font-weight: 800;
}

.approval-stat small {
    display: block;
    margin-top: 11px;
    color: #929baa;
    font-size: 11px;
    line-height: 1.45;
}

.application-panel {
    width: 100%;
    overflow: hidden;
    border: 1px solid #e3e7ed;
    border-radius: 16px;
    background: #ffffff;
    box-shadow: 0 4px 16px
        rgba(24, 32, 51, .025);
}

.application-panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    padding: 20px 22px;
    border-bottom: 1px solid #e9ebef;
}

.application-panel-header h2 {
    margin: 0 0 4px;
    color: #273144;
    font-size: 18px;
    line-height: 1.3;
    font-weight: 700;
}

.application-panel-header p {
    margin: 0;
    color: #8490a3;
    font-size: 13px;
    line-height: 1.5;
}

.application-tools {
    display: flex;
    align-items: center;
    gap: 10px;
}

.application-search {
    width: 310px;
    max-width: 40vw;
    min-height: 43px;
    padding: 10px 13px;
    border: 1px solid #dce1e8;
    border-radius: 11px;
    outline: none;
    background: #ffffff;
    color: #364054;
    font-family: inherit;
    font-size: 13px;
    transition: .18s ease;
}

.application-search::placeholder {
    color: #9aa3b2;
}

.application-search:focus {
    border-color: #a94b58;
    box-shadow: 0 0 0 3px
        rgba(141, 31, 45, .08);
}

.application-filter-bar {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 22px;
    overflow-x: auto;
    border-bottom: 1px solid #eceef2;
    background: #fafbfc;
}

.application-filter {
    flex: 0 0 auto;
    min-height: 34px;
    padding: 7px 13px;
    border: 1px solid #e0e4ea;
    border-radius: 999px;
    background: #ffffff;
    color: #626e82;
    cursor: pointer;
    font-family: inherit;
    font-size: 11px;
    font-weight: 700;
    transition: .15s ease;
}

.application-filter:hover {
    border-color: #dfc4c8;
    color: #8d1f2d;
}

.application-filter.active {
    border-color: #e3bdc3;
    background: #fff4f5;
    color: #8d1f2d;
}

.application-list {
    width: 100%;
}

.application-row {
    position: relative;
    width: 100%;
    display: grid;
    grid-template-columns: minmax(200px, 1.35fr)
        minmax(150px, .95fr)
        minmax(215px, 1.25fr)
        minmax(85px, .45fr)
        minmax(145px, .75fr)
        38px;
    align-items: center;
    gap: 16px;
    padding: 17px 20px;
    border: 0;
    border-bottom: 1px solid #edf0f3;
    background: #ffffff;
    color: inherit;
    font-family: inherit;
    text-align: left;
    cursor: pointer;
    transition: background .15s ease,
        box-shadow .15s ease;
}

.application-row:last-child {
    border-bottom: 0;
}

.application-row:hover {
    background: #fffafa;
    box-shadow: inset 3px 0 0
        rgba(141, 31, 45, .7);
}

.application-row.pending-row {
    background: linear-gradient(
            90deg,
            rgba(255, 247, 232, .55),
            #ffffff 30%
        );
}

.application-staff {
    min-width: 0;
}

.application-staff strong {
    display: block;
    margin-bottom: 4px;
    overflow: hidden;
    color: #202b3e;
    font-size: 14px;
    font-weight: 700;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.application-staff small {
    display: block;
    margin-bottom: 2px;
    overflow: hidden;
    color: #778397;
    font-size: 12px;
    line-height: 1.45;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.application-staff .staff-department {
    color: #9aa3b1;
    font-size: 11.5px;
}

.row-label {
    display: block;
    margin-bottom: 5px;
    color: #8994a6;
    font-size: 10.5px;
    font-weight: 800;
    letter-spacing: .25px;
    text-transform: uppercase;
}

.row-value {
    display: block;
    color: #455166;
    font-size: 13px;
    line-height: 1.5;
}

.row-value strong {
    color: #293448;
    font-weight: 700;
}

.row-date-range {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.row-date-separator {
    color: #9aa3b2;
    font-size: 11px;
}

.row-days {
    display: inline-flex;
    align-items: baseline;
    gap: 4px;
    color: #8d1f2d;
}

.row-days strong {
    font-size: 21px;
    line-height: 1;
    font-weight: 800;
}

.row-days span {
    font-size: 12px;
    font-weight: 600;
}

.status-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    max-width: 100%;
    min-height: 29px;
    padding: 6px 11px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 800;
    line-height: 1.2;
    text-align: center;
}

.status-pill.pending {
    background: #fff4df;
    color: #91630c;
}

.status-pill.approved,
.status-pill.supported {
    background: #e8f7ef;
    color: #167348;
}

.status-pill.rejected,
.status-pill.not-supported {
    background: #fff0f2;
    color: #b32636;
}

.status-pill.cancelled {
    background: #f0f2f5;
    color: #697386;
}

.status-pill.completed {
    background: #eef4f1;
    color: #347159;
}

.row-chevron {
    width: 34px;
    height: 34px;
    display: grid;
    place-items: center;
    border-radius: 9px;
    color: #8490a3;
    transition: .15s ease;
}

.application-row:hover .row-chevron {
    background: #fff0f2;
    color: #8d1f2d;
    transform: translateX(2px);
}

.row-chevron svg {
    width: 17px;
    height: 17px;
    fill: none;
    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
}

.application-empty {
    padding: 55px 22px;
    color: #8d97a7;
    text-align: center;
    font-size: 13px;
}

.application-modal {
    position: fixed;
    inset: 0;
    z-index: 9999;
    display: none;
    align-items: center;
    justify-content: center;
    padding: 24px;
    background: rgba(20, 27, 41, .55);
    backdrop-filter: blur(4px);
}

.application-modal.open {
    display: flex;
}

.application-modal-dialog {
    width: min(980px, 100%);
    max-height: 92vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    border: 1px solid #e3e7ed;
    border-radius: 18px;
    background: #ffffff;
    box-shadow: 0 28px 75px
        rgba(20, 28, 45, .24);
}

.application-modal-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 18px;
    padding: 21px 24px;
    border-bottom: 1px solid #e8ebef;
    background: linear-gradient(
            135deg,
            #ffffff,
            #fffafb
        );
}

.application-modal-header h2 {
    margin: 0 0 5px;
    color: #202b3e;
    font-size: 21px;
    line-height: 1.3;
    font-weight: 800;
}

.application-modal-header p {
    margin: 0;
    color: #8993a2;
    font-size: 12px;
    font-weight: 600;
}

.modal-close-button {
    width: 38px;
    height: 38px;
    display: grid;
    place-items: center;
    flex: 0 0 38px;
    padding: 0;
    border: 0;
    border-radius: 10px;
    background: #f3f5f7;
    color: #657084;
    cursor: pointer;
    transition: .15s ease;
}

.modal-close-button:hover {
    background: #fff0f2;
    color: #8d1f2d;
}

.modal-close-button svg {
    width: 18px;
    height: 18px;
    fill: none;
    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
}

.application-modal-body {
    flex: 1;
    overflow-y: auto;
    padding: 24px;
}

.modal-section {
    margin-bottom: 26px;
}

.modal-section:last-child {
    margin-bottom: 0;
}

.modal-section-title {
    position: relative;
    margin: 0 0 13px;
    padding-left: 12px;
    color: #8d1f2d;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: .35px;
    text-transform: uppercase;
}

.modal-section-title::before {
    content: "";
    position: absolute;
    top: 2px;
    bottom: 2px;
    left: 0;
    width: 3px;
    border-radius: 3px;
    background: #d5a12b;
}

.detail-grid {
    display: grid;
    grid-template-columns: repeat(
            3,
            minmax(0, 1fr)
        );
    gap: 12px;
}

.detail-box {
    min-width: 0;
    padding: 14px 15px;
    border: 1px solid #e7eaf0;
    border-radius: 11px;
    background: #fafbfc;
}

.detail-box.wide {
    grid-column: span 2;
}

.detail-box.full {
    grid-column: 1 / -1;
}

.detail-label {
    display: block;
    margin-bottom: 6px;
    color: #8e98a8;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .2px;
    text-transform: uppercase;
}

.detail-value {
    display: block;
    overflow-wrap: anywhere;
    color: #414d61;
    font-size: 13px;
    line-height: 1.55;
}

.detail-value strong {
    color: #263145;
    font-weight: 800;
}

.detail-box.highlight {
    border-color: #eadde0;
    background: linear-gradient(
            135deg,
            #fffafa,
            #ffffff
        );
}

.detail-box.balance {
    background: #fffdf7;
    border-color: #eee2c4;
}

.detail-box.note {
    background: #fcfcfd;
}

.attachment-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 34px;
    padding: 7px 12px;
    border: 1px solid #dfc4c8;
    border-radius: 8px;
    background: #ffffff;
    color: #8d1f2d;
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
}

.attachment-link:hover {
    background: #fff4f5;
    color: #711622;
}

.decision-panel {
    padding: 17px;
    border: 1px solid #eadde0;
    border-radius: 13px;
    background: linear-gradient(
            135deg,
            #fffafa,
            #ffffff
        );
    font-size: 13px;
}

.decision-panel > strong {
    color: #283347;
    font-size: 14px;
}

.decision-panel textarea {
    width: 100%;
    min-height: 100px;
    padding: 12px 13px;
    margin-top: 12px;
    resize: vertical;
    border: 1px solid #dce1e8;
    border-radius: 10px;
    outline: none;
    font-family: inherit;
    font-size: 13px;
    line-height: 1.5;
}

.decision-panel textarea:focus {
    border-color: #a64a57;
    box-shadow: 0 0 0 3px
        rgba(141, 31, 45, .08);
}

.decision-help {
    display: block;
    margin-top: 6px;
    color: #8e97a6;
    font-size: 11px;
    line-height: 1.55;
}

.modal-actions {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 9px;
    margin-top: 16px;
}

.action-button {
    min-height: 41px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 9px 16px;
    border: 1px solid transparent;
    border-radius: 9px;
    cursor: pointer;
    font-family: inherit;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none;
    transition: .15s ease;
}

.action-button:hover {
    transform: translateY(-1px);
}

.action-button.approve,
.action-button.support {
    background: #18794e;
    color: #ffffff;
}

.action-button.approve:hover,
.action-button.support:hover {
    background: #12633f;
}

.action-button.reject {
    background: #fff0f2;
    border-color: #efcdd2;
    color: #b32636;
}

.action-button.not-support {
    background: #fff4df;
    border-color: #e9d6a8;
    color: #8d630e;
}

.action-button.print {
    border-color: #dce1e8;
    background: #ffffff;
    color: #566176;
}

.action-button.print:hover {
    background: #f7f8fa;
    color: #364054;
}

@media (max-width: 1200px) {
.approval-stats {
    grid-template-columns: repeat(
                3,
                minmax(0, 1fr)
            );
}

.application-row {
    grid-template-columns: minmax(170px, 1.25fr)
            minmax(135px, .9fr)
            minmax(175px, 1.15fr)
            75px
            minmax(125px, .75fr)
            34px;
    gap: 12px;
}
}

@media (max-width: 850px) {
.application-panel-header {
    align-items: stretch;
    flex-direction: column;
}

.application-tools {
    width: 100%;
}

.application-search {
    flex: 1;
    width: auto;
    max-width: none;
}

.application-row {
    grid-template-columns: minmax(0, 1fr)
            auto;
    gap: 10px;
    padding: 16px;
}

.application-row > div:not(.application-staff):not(.row-chevron) {
    grid-column: 1 / 2;
}

.row-chevron {
    grid-column: 2;
    grid-row: 1 / span 5;
}

.detail-grid {
    grid-template-columns: repeat(
                2,
                minmax(0, 1fr)
            );
}
}

@media (max-width: 650px) {
.approval-header {
    flex-direction: column;
    align-items: stretch;
}

.approval-header h1 {
    font-size: 28px;
    font-weight: 700;
    letter-spacing: -0.3px;
}

.approval-stats {
    grid-template-columns: repeat(
                2,
                minmax(0, 1fr)
            );
    gap: 9px;
}

.approval-stat {
    min-height: 110px;
    padding: 13px;
}

.approval-stat strong {
    font-size: 25px;
}

.application-tools {
    flex-direction: column;
    align-items: stretch;
}

.application-filter-bar {
    padding-left: 15px;
    padding-right: 15px;
}

.application-modal {
    padding: 8px;
}

.application-modal-dialog {
    max-height: 96vh;
    border-radius: 14px;
}

.application-modal-header {
    padding: 17px;
}

.application-modal-body {
    padding: 17px;
}

.detail-grid {
    grid-template-columns: 1fr;
}

.detail-box.wide,
    .detail-box.full {
    grid-column: auto;
}

.modal-actions {
    align-items: stretch;
    flex-direction: column;
}

.modal-actions .action-button {
    width: 100%;
}
}

@media (max-width: 430px) {
.approval-stats {
    grid-template-columns: 1fr 1fr;
}

.approval-role-card {
    align-items: flex-start;
}

.application-panel-header {
    padding: 17px;
}

.application-row {
    padding: 15px;
}
}

.approval-page .application-tools .btn-print {
    height: 43px !important;
    min-height: 43px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 0 18px !important;
    background: #981d2d !important;
    color: #ffffff !important;
    border: 1px solid #981d2d !important;
    border-radius: 10px !important;
    font-family: inherit !important;
    font-size: 13px !important;
    font-weight: 700 !important;
    line-height: 1 !important;
    text-decoration: none !important;
    white-space: nowrap !important;
    cursor: pointer !important;
    box-shadow: 0 3px 8px rgba(152, 29, 45, 0.12) !important;
    transition: background 0.15s ease,
        border-color 0.15s ease,
        transform 0.15s ease,
        box-shadow 0.15s ease !important;
}

.approval-page .application-tools .btn-print:hover {
    background: #7d1725 !important;
    border-color: #7d1725 !important;
    color: #ffffff !important;
    transform: translateY(-1px) !important;
    box-shadow: 0 5px 12px rgba(152, 29, 45, 0.18) !important;
}

.approval-page .application-tools .btn-print:visited,
.approval-page .application-tools .btn-print:active,
.approval-page .application-tools .btn-print:focus {
    color: #ffffff !important;
    text-decoration: none !important;
}

.approval-page .application-panel-header {
    padding: 18px 22px !important;
}

.approval-page .application-panel-header h2 {
    font-size: 18px !important;
    font-weight: 800 !important;
}

.approval-page .application-panel-header p {
    font-size: 12px !important;
}

.approval-page .application-search {
    width: 310px !important;
    height: 43px !important;
    min-height: 43px !important;
    padding: 0 14px !important;
    font-size: 12px !important;
    border: 1px solid #dce1e8 !important;
    border-radius: 10px !important;
}

.approval-page .application-filter-bar {
    padding: 11px 22px !important;
    gap: 8px !important;
}

.approval-page .application-filter {
    min-height: 34px !important;
    padding: 6px 13px !important;
    font-size: 11px !important;
    font-weight: 700 !important;
}

.approval-page .application-row .row-label {
    display: block !important;
    margin-bottom: 4px !important;
    color: #8994a6 !important;
    font-size: 9px !important;
    line-height: 1.2 !important;
    font-weight: 700 !important;
    letter-spacing: 0.2px !important;
    text-transform: uppercase !important;
}

.approval-page .application-row .row-value {
    display: block !important;
    color: #455166 !important;
    font-size: 12px !important;
    line-height: 1.35 !important;
    text-transform: none !important;
}

.approval-page .application-row .row-value strong {
    color: #293448 !important;
    font-size: 12px !important;
    line-height: 1.35 !important;
    font-weight: 700 !important;
}

.approval-page .application-row .row-date-range {
    gap: 1px !important;
}

.approval-page .application-row .row-date-separator {
    font-size: 9px !important;
    line-height: 1.2 !important;
    color: #9aa3b2 !important;
}

.approval-page .application-row .row-days {
    display: inline-flex !important;
    align-items: baseline !important;
    gap: 3px !important;
    color: #8d1f2d !important;
}

.approval-page .application-row .row-days strong {
    font-size: 12px !important;
    line-height: 1.3 !important;
    font-weight: 800 !important;
    color: #8d1f2d !important;
}

.approval-page .application-row .row-days span {
    font-size: 10px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
    color: #8d1f2d !important;
}

.approval-page .application-row .status-pill {
    min-height: 25px !important;
    padding: 4px 10px !important;
    border-radius: 999px !important;
    font-size: 10px !important;
    line-height: 1.2 !important;
    font-weight: 700 !important;
    white-space: nowrap !important;
}

.approval-page .application-row .status-pill.approved,
.approval-page .application-row .status-pill.supported {
    background: #e8f7ef !important;
    color: #167348 !important;
}

.approval-page .application-row .status-pill.rejected,
.approval-page .application-row .status-pill.not-supported {
    background: #fff0f2 !important;
    color: #b32636 !important;
}

.approval-page .application-row .status-pill.pending {
    background: #fff4df !important;
    color: #91630c !important;
}

.approval-page .application-row .status-pill.cancelled {
    background: #f0f2f5 !important;
    color: #697386 !important;
}

.approval-page .application-row .row-chevron {
    width: 30px !important;
    height: 30px !important;
}

.approval-page .application-row .row-chevron svg {
    width: 15px !important;
    height: 15px !important;
}

@media (max-width: 850px) {
.approval-page .application-tools {
    width: 100% !important;
}

.approval-page .application-tools .btn-print {
    min-height: 41px !important;
}

.approval-page .application-search {
    flex: 1 !important;
    width: auto !important;
    max-width: none !important;
}

.approval-page .application-row {
    grid-template-columns: minmax(0, 1fr)
            auto !important;
    padding: 14px 16px !important;
}
}

@media (max-width: 650px) {
.approval-page .application-tools {
    flex-direction: column !important;
    align-items: stretch !important;
}

.approval-page .application-tools .btn-print {
    width: 100% !important;
}

.approval-page .application-search {
    width: 100% !important;
}
}

.approval-page .application-row .application-staff strong {
    display: block !important;
    margin-bottom: 2px !important;
    color: #202b3e !important;
    font-size: 12px !important;
    line-height: 1.25 !important;
    font-weight: 700 !important;
    text-transform: none !important;
}

.approval-page .application-row .application-staff small {
    display: block !important;
    margin-bottom: 1px !important;
    color: #778397 !important;
    font-size: 10px !important;
    line-height: 1.3 !important;
    font-weight: 500 !important;
    text-transform: none !important;
}

.approval-page .application-row .application-staff .staff-department {
    color: #929cad !important;
    font-size: 10px !important;
    line-height: 1.3 !important;
    font-weight: 500 !important;
    text-transform: none !important;
}

.approval-page .application-row .application-info-label,
.approval-page .application-row .application-meta-label,
.approval-page .application-row .application-label {
    font-size: 9px !important;
    line-height: 1.2 !important;
    font-weight: 700 !important;
    letter-spacing: 0.02em !important;
}

.approval-page .application-row .application-info-value,
.approval-page .application-row .application-meta-value,
.approval-page .application-row .application-value {
    font-size: 11px !important;
    line-height: 1.3 !important;
    font-weight: 600 !important;
}

.approval-page .application-row .leave-type {
    font-size: 11px !important;
    line-height: 1.3 !important;
}

.approval-page .application-row .leave-period,
.approval-page .application-row .leave-date {
    font-size: 11px !important;
    line-height: 1.3 !important;
}

.approval-page .application-row .leave-days {
    font-size: 11px !important;
    line-height: 1.3 !important;
}

.approval-page .application-row .status-badge {
    font-size: 10px !important;
    line-height: 1 !important;
    padding: 7px 11px !important;
    min-height: 27px !important;
    border-radius: 999px !important;
    display: inline-flex !important;
    align-items: center !important;
    justify-content: center !important;
}

.approval-page .application-row {
    grid-template-columns: minmax(200px, 1.35fr)
        minmax(150px, .95fr)
        minmax(190px, 1.10fr)
        minmax(75px, .40fr)
        minmax(135px, .70fr)
        34px !important;
    gap: 14px !important;
    padding: 13px 20px !important;
    min-height: 66px !important;
    padding-top: 12px !important;
    padding-bottom: 12px !important;
}

.approval-page .application-row > div {
    line-height: 1.3 !important;
}
</style>

</head><body>

<div class="app">

    <%@ include file="includes/sidebar.jspf" %>

    <main>

        <div class="approval-page">

            <!-- =====================================================
                 PAGE HEADER
                 ===================================================== -->

            <div class="approval-header">

                <div>

                    <h1>
                        <%= adminEscape(pageTitle) %>
                    </h1>

                    <p>
                        <%= adminEscape(pageDescription) %>
                    </p>

                </div>


                <!--
                    Gunakan header action standard sistem:
                    Bell notification + user profile
                -->

                <%@ include file="includes/header-actions.jspf" %>

            </div>


            <!-- =====================================================
     SUCCESS / ERROR MESSAGE
     ===================================================== -->

<%
    String successMessage = null;

    if (success != null && !success.isBlank()) {

        switch (success.trim().toLowerCase()) {

            // =============================================
            // KETUA UNIT - SOKONG
            // =============================================
            case "supported":
                successMessage =
                    "Sokongan bagi permohonan cuti telah berjaya direkodkan.";
                break;


            // =============================================
            // KETUA UNIT - TIDAK SOKONG
            // =============================================
            case "not-supported":
                successMessage =
                    "Keputusan tidak menyokong permohonan cuti telah berjaya direkodkan.";
                break;


            // =============================================
            // PENGURUSAN - LULUS
            // =============================================
            case "approved":
                successMessage =
                    "Permohonan cuti telah berjaya diluluskan oleh Pengurusan.";
                break;


            // =============================================
            // PENGURUSAN - TIDAK LULUS
            // =============================================
            case "rejected":
                successMessage =
                    "Permohonan cuti telah ditetapkan sebagai Tidak Diluluskan oleh Pengurusan.";
                break;


            // =============================================
            // DEFAULT
            // =============================================
            default:
                successMessage = success;
                break;
        }
    }
%>


<!-- =====================================================
     SUCCESS MESSAGE
     ===================================================== -->

<% if (successMessage != null && !successMessage.isBlank()) { %>

    <div class="approval-message success">
        <%= adminEscape(successMessage) %>
    </div>

<% } %>


<!-- =====================================================
     ERROR MESSAGE
     ===================================================== -->

<% if (error != null && !error.isBlank()) { %>

    <div class="approval-message error">
        <%= adminEscape(error) %>
    </div>

<% } %>



            <!-- =====================================================
                 ROLE INFORMATION
                 ===================================================== -->

            <div class="approval-role-card">

                <div class="approval-role-icon">

                    <svg viewBox="0 0 24 24">

                        <rect
                            x="5"
                            y="3"
                            width="14"
                            height="18"
                            rx="2"
                        ></rect>

                        <path d="M9 7h6"></path>

                        <path d="M9 11h6"></path>

                        <path d="M9 15h4"></path>

                    </svg>

                </div>


                <div>

                    <% if (isHR) { %>

                        <strong>
                            Rekod Pentadbiran
                        </strong>

                        <p>
                            Klik permohonan untuk melihat semua maklumat berkaitan permohonan cuti.
                        </p>

                    <% } else if (isHOD) { %>

                        <strong>
                            Sokongan Ketua Unit
                        </strong>

                        <p>
                            Semak maklumat permohonan sebelum memberi sokongan atau tidak menyokong permohonan staf.
                        </p>

                    <% } else { %>

                        <strong>
                            Kelulusan Pengurusan
                        </strong>

                        <p>
                            Semak maklumat dan sokongan Ketua Unit sebelum membuat keputusan akhir.
                        </p>

                    <% } %>

                </div>

            </div>



            <!-- =====================================================
                 STATISTIC CARDS
                 ===================================================== -->

            <div class="approval-stats">

                <!-- SEMUA -->

                <button
                    type="button"
                    class="approval-stat active"
                    data-filter="ALL"
                    onclick="setApplicationFilter('ALL', this)"
                >

                    <span>
                        Semua
                    </span>

                    <strong>
                        <%= totalApplications %>
                    </strong>

                    <small>
                        Keseluruhan permohonan
                    </small>

                </button>


                <% if (isHOD) { %>

                    <!-- MENUNGGU HOD -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="PENDING"
                        onclick="setApplicationFilter('PENDING', this)"
                    >

                        <span>
                            Menunggu Tindakan
                        </span>

                        <strong>
                            <%= notReviewedApplications %>
                        </strong>

                        <small>
                            Perlu semakan Ketua Unit
                        </small>

                    </button>


                    <!-- SELESAI HOD -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="COMPLETED"
                        onclick="setApplicationFilter('COMPLETED', this)"
                    >

                        <span>
                            Selesai Disemak
                        </span>

                        <strong>
                            <%= completedHodApplications %>
                        </strong>

                        <small>
                            Sokongan telah diberikan
                        </small>

                    </button>

                <% } else { %>

                    <!-- PENDING -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="PENDING"
                        onclick="setApplicationFilter('PENDING', this)"
                    >

                        <span>
                            Menunggu Keputusan
                        </span>

                        <strong>
                            <%= pendingApplications %>
                        </strong>

                        <small>
                            Perlu tindakan
                        </small>

                    </button>


                    <!-- APPROVED -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="APPROVED"
                        onclick="setApplicationFilter('APPROVED', this)"
                    >

                        <span>
                            Diluluskan
                        </span>

                        <strong>
                            <%= approvedApplications %>
                        </strong>

                        <small>
                            Permohonan diluluskan
                        </small>

                    </button>


                    <!-- REJECTED -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="REJECTED"
                        onclick="setApplicationFilter('REJECTED', this)"
                    >

                        <span>
                            Tidak Diluluskan
                        </span>

                        <strong>
                            <%= rejectedApplications %>
                        </strong>

                        <small>
                            Keputusan tidak diluluskan
                        </small>

                    </button>


                    <!-- COMPLETED -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="COMPLETED"
                        onclick="setApplicationFilter('COMPLETED', this)"
                    >

                        <span>
                            Selesai
                        </span>

                        <strong>
                            <%= completedApplications %>
                        </strong>

                        <small>
                            Keputusan akhir
                        </small>

                    </button>


                    <!-- CANCELLED -->

                    <button
                        type="button"
                        class="approval-stat"
                        data-filter="CANCELLED"
                        onclick="setApplicationFilter('CANCELLED', this)"
                    >

                        <span>
                            Dibatalkan
                        </span>

                        <strong>
                            <%= cancelledApplications %>
                        </strong>

                        <small>
                            Dibatalkan oleh staf
                        </small>

                    </button>

                <% } %>

            </div>



            <!-- =====================================================
                 MAIN APPLICATION PANEL
                 ===================================================== -->

            <section class="application-panel">

                <!-- HEADER -->

                <div class="application-panel-header">

                    <div>

                        <h2>
                            Permohonan Cuti Staf
                        </h2>

                        <p>
                            Klik permohonan untuk melihat maklumat lengkap.
                        </p>

                    </div>


                    <div class="application-tools">


                        <!-- PRINT -->

                        <a href="<%= request.getContextPath() %>/print-leave-list"
   class="btn-print">
    Cetak Senarai Permohonan
</a>


                        <!-- SEARCH -->

                        <input
                            type="search"
                            id="applicationSearch"
                            class="application-search"
                            placeholder="Cari nama, jawatan, jabatan, jenis cuti..."
                            autocomplete="off"
                            oninput="filterApplicationRows()"
                        >

                    </div>

                </div>



                <!-- =================================================
                     FILTER BUTTON
                     ================================================= -->

                <div class="application-filter-bar">


                    <button
                        type="button"
                        class="application-filter active"
                        data-filter="ALL"
                        onclick="setApplicationFilter('ALL', this)"
                    >
                        Semua
                    </button>


                    <% if (isHOD) { %>

                        <button
                            type="button"
                            class="application-filter"
                            data-filter="PENDING"
                            onclick="setApplicationFilter('PENDING', this)"
                        >
                            Menunggu Tindakan
                        </button>


                        <button
                            type="button"
                            class="application-filter"
                            data-filter="COMPLETED"
                            onclick="setApplicationFilter('COMPLETED', this)"
                        >
                            Selesai Disemak
                        </button>

                    <% } else { %>

                        <button
                            type="button"
                            class="application-filter"
                            data-filter="PENDING"
                            onclick="setApplicationFilter('PENDING', this)"
                        >
                            Menunggu Tindakan
                        </button>


                        <button
                            type="button"
                            class="application-filter"
                            data-filter="APPROVED"
                            onclick="setApplicationFilter('APPROVED', this)"
                        >
                            Diluluskan
                        </button>


                        <button
                            type="button"
                            class="application-filter"
                            data-filter="REJECTED"
                            onclick="setApplicationFilter('REJECTED', this)"
                        >
                            Tidak Diluluskan
                        </button>


                        <button
                            type="button"
                            class="application-filter"
                            data-filter="COMPLETED"
                            onclick="setApplicationFilter('COMPLETED', this)"
                        >
                            Selesai
                        </button>


                        <button
                            type="button"
                            class="application-filter"
                            data-filter="CANCELLED"
                            onclick="setApplicationFilter('CANCELLED', this)"
                        >
                            Dibatalkan
                        </button>

                    <% } %>

                </div>



                <!-- =================================================
                     APPLICATION LIST
                     ================================================= -->

                <div
                    id="applicationList"
                    class="application-list"
                >


                <%

                    if (
                        rows == null
                        ||
                        rows.isEmpty()
                    ) {

                %>


                    <div
                        id="applicationEmpty"
                        class="application-empty"
                    >

                        Tiada rekod permohonan cuti ditemui.

                    </div>


                <%
    } else {

        for (
            Map<String,Object> leaveRow : rows
        ) {

            int applicationId =
                adminNum(
                    leaveRow.get("id")
                );

            String staffName =
                adminText(
                    leaveRow.get("name"),
                    "-"
                );

            String staffEmail =
                adminText(
                    leaveRow.get("email"),
                    "-"
                );


                            String staffPosition =
                                adminText(
                                		leaveRow.get("position"),
                                    "—"
                                );


                            String staffDepartment =
                                adminDepartment(
                                    adminText(
                                    		leaveRow.get("department"),
                                        ""
                                    )
                                );


                            String leaveType =
                                adminText(
                                		leaveRow.get("type"),
                                    "—"
                                );


                            String startDate =
                                adminDate(
                                		leaveRow.get("start")
                                );


                            String endDate =
                                adminDate(
                                		leaveRow.get("end")
                                );


                            String totalDays =
                                adminDays(
                                		leaveRow.get("duration")
                                );


                            String reason =
                                adminText(
                                		leaveRow.get("reason"),
                                    "—"
                                );


                            String status =
                                adminText(
                                		leaveRow.get("status"),
                                    "PENDING"
                                )
                                .trim()
                                .toUpperCase();


                            String statusLabel =
                                adminStatusLabel(status);


                            String statusClass =
                                adminStatusClass(status);


                            /*
                             * HOD review information
                             */

                            String hodStatus =
                                adminText(
                                		leaveRow.get("hodStatus"),
                                    ""
                                );


                            String hodRemarks =
                                adminText(
                                		leaveRow.get("hodRemarks"),
                                    "Tiada catatan."
                                );


                            String hodReviewedAt =
                                adminDate(
                                		leaveRow.get("hodReviewedAt")
                                );


                            String hodReviewedBy =
                                adminText(
                                		leaveRow.get("hodReviewedByName"),
                                    "—"
                                );


                            /*
                             * Management information
                             */

                            String managementRemarks =
                                adminText(
                                		leaveRow.get("managementRemarks"),
                                    adminText(
                                    		leaveRow.get("adminRemarks"),
                                        "Tiada catatan."
                                    )
                                );


                            String reviewedAt =
                                adminDate(
                                		leaveRow.get("reviewedAt")
                                );


                            String reviewedBy =
                                adminText(
                                		leaveRow.get("reviewedByName"),
                                    "—"
                                );


                            /*
                             * Contact information
                             */

                            String contactPhone =
                                adminText(
                                		leaveRow.get("contactPhone"),
                                    "—"
                                );


                            String contactAddress =
                                adminText(
                                		leaveRow.get("contactAddress"),
                                    "—"
                                );


                            String handoverStaff =
                                adminText(
                                		leaveRow.get("handoverStaffName"),
                                    "—"
                                );


                            String submittedAt =
                                adminDate(
                                		leaveRow.get("submittedAt")
                                );


                            String attachment =
                                adminText(
                                		leaveRow.get("attachment"),
                                    ""
                                );


                            /*
                             * HOD information
                             */

                            String hodName =
                                adminText(
                                		leaveRow.get("hodName"),
                                    "—"
                                );


                            /*
                             * Leave balance
                             */

                            String balanceBefore =
                                adminDays(
                                		leaveRow.get("balanceBefore")
                                );


                            String balanceAfter =
                                adminDays(
                                		leaveRow.get("balanceAfter")
                                );


                            boolean hideBalance =
                                adminHideBalance(
                                    leaveType
                                );


                            /*
                             * Search data
                             */

                            String searchText =
                                (
                                    staffName
                                    + " "
                                    + staffEmail
                                    + " "
                                    + staffPosition
                                    + " "
                                    + staffDepartment
                                    + " "
                                    + leaveType
                                    + " "
                                    + reason
                                    + " "
                                    + statusLabel
                                )
                                .toLowerCase();


                            /*
                             * Filter values
                             */

                            boolean completed =
                                "APPROVED".equals(status)
                                ||
                                "REJECTED".equals(status);


                            boolean pending =
                                !completed
                                &&
                                !"CANCELLED".equals(status);


                            boolean hodCompleted =
                                hodStatus != null
                                &&
                                !hodStatus.isBlank()
                                &&
                                !"PENDING".equalsIgnoreCase(
                                    hodStatus
                                );


                            String rowFilterStatus;


                            if (isHOD) {

                                rowFilterStatus =
                                    hodCompleted
                                        ? "COMPLETED"
                                        : "PENDING";

                            } else {

                                rowFilterStatus =
                                    status;
                            }

                %>



                    <!-- =============================================
                         APPLICATION ROW
                         ============================================= -->

                    <button
                        type="button"
                        class="application-row <%= pending ? "pending-row" : "" %>"

                        data-status="<%= adminAttr(rowFilterStatus) %>"

                        data-final-status="<%= adminAttr(status) %>"

                        data-completed="<%= completed ? "true" : "false" %>"

                        data-search="<%= adminAttr(searchText) %>"

                        onclick="openApplicationModal('applicationModal<%= applicationId %>')"
                    >


                        <!-- STAFF -->

                        <div class="application-staff">

                            <strong>
                                <%= adminEscape(staffName) %>
                            </strong>

                            <small>
                                <%= adminEscape(staffPosition) %>
                            </small>

                            <small class="staff-department">
                                <%= adminEscape(staffDepartment) %>
                            </small>

                        </div>



                        <!-- LEAVE TYPE -->

                        <div>

                            <span class="row-label">
                                Jenis Cuti
                            </span>

                            <span class="row-value">

                                <strong>
                                    <%= adminEscape(leaveType) %>
                                </strong>

                            </span>

                        </div>



                        <!-- DATE -->

                        <div>

                            <span class="row-label">
                                Tempoh Cuti
                            </span>

                            <div class="row-date-range">

                                <span class="row-value">
                                    <strong>
                                        <%= adminEscape(startDate) %>
                                    </strong>
                                </span>

                                <% if (!startDate.equals(endDate)) { %>

                                    <span class="row-date-separator">
                                        hingga
                                    </span>

                                    <span class="row-value">
                                        <strong>
                                            <%= adminEscape(endDate) %>
                                        </strong>
                                    </span>

                                <% } %>

                            </div>

                        </div>



                        <!-- TOTAL DAYS -->

                        <div>

                            <span class="row-label">
                                Jumlah
                            </span>

                            <span class="row-days">

                                <strong>
                                    <%= adminEscape(totalDays) %>
                                </strong>

                                <span>
                                    hari
                                </span>

                            </span>

                        </div>



                        <!-- STATUS -->

                        <div>

                            <span class="row-label">
                                Status
                            </span>

                            <span
                                class="status-pill <%= adminEscape(statusClass) %>"
                            >
                                <%= adminEscape(statusLabel) %>
                            </span>

                        </div>



                        <!-- ARROW -->

                        <div class="row-chevron">

                            <svg viewBox="0 0 24 24">

                                <path d="M9 18l6-6-6-6"></path>

                            </svg>

                        </div>

                    </button>



                    <!-- =============================================
                         APPLICATION DETAIL MODAL
                         ============================================= -->

                    <div
                        id="applicationModal<%= applicationId %>"
                        class="application-modal"
                        onclick="closeModalFromBackdrop(event, this)"
                    >


                        <div
                            class="application-modal-dialog"
                            role="dialog"
                            aria-modal="true"
                            aria-labelledby="modalTitle<%= applicationId %>"
                        >


                            <!-- =====================================
                                 MODAL HEADER
                                 ===================================== -->

                            <div class="application-modal-header">


                                <div>

                                    <h2
                                        id="modalTitle<%= applicationId %>"
                                    >
                                        Butiran Permohonan Cuti
                                    </h2>

                                    <p>
                                        No. Permohonan:
                                        <strong>
                                            <%= applicationId %>
                                        </strong>
                                    </p>

                                </div>


                                <button
                                    type="button"
                                    class="modal-close-button"
                                    onclick="closeApplicationModal('applicationModal<%= applicationId %>')"
                                    aria-label="Tutup"
                                >

                                    <svg viewBox="0 0 24 24">

                                        <path d="M6 6l12 12"></path>

                                        <path d="M18 6L6 18"></path>

                                    </svg>

                                </button>

                            </div>



                            <!-- =====================================
                                 MODAL BODY
                                 ===================================== -->

                            <div class="application-modal-body">


                                <!-- =================================
                                     MAKLUMAT PEMOHON
                                     ================================= -->

                                <section class="modal-section">

                                    <h3 class="modal-section-title">
                                        Maklumat Pemohon
                                    </h3>


                                    <div class="detail-grid">


                                        <div class="detail-box highlight">

                                            <span class="detail-label">
                                                Nama
                                            </span>

                                            <span class="detail-value">
                                                <strong>
                                                    <%= adminEscape(staffName) %>
                                                </strong>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Jawatan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(staffPosition) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Jabatan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(staffDepartment) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                E-mel
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(staffEmail) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Ketua Unit
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(hodName) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                No. Permohonan
                                            </span>

                                            <span class="detail-value">
                                                <strong>
                                                    <%= applicationId %>
                                                </strong>
                                            </span>

                                        </div>

                                    </div>

                                </section>



                                <!-- =================================
                                     MAKLUMAT CUTI
                                     ================================= -->

                                <section class="modal-section">

                                    <h3 class="modal-section-title">
                                        Maklumat Cuti
                                    </h3>


                                    <div class="detail-grid">


                                        <div class="detail-box highlight">

                                            <span class="detail-label">
                                                Jenis Cuti
                                            </span>

                                            <span class="detail-value">
                                                <strong>
                                                    <%= adminEscape(leaveType) %>
                                                </strong>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Mula
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(startDate) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Akhir
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(endDate) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Jumlah Hari
                                            </span>

                                            <span class="detail-value">

                                                <strong>
                                                    <%= adminEscape(totalDays) %>
                                                </strong>
                                                hari

                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Status
                                            </span>

                                            <span class="detail-value">

                                                <span
                                                    class="status-pill <%= adminEscape(statusClass) %>"
                                                >
                                                    <%= adminEscape(statusLabel) %>
                                                </span>

                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Dihantar
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(submittedAt) %>
                                            </span>

                                        </div>


                                        <div class="detail-box full note">

                                            <span class="detail-label">
                                                Alasan Permohonan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(reason) %>
                                            </span>

                                        </div>

                                    </div>

                                </section>



                                <!-- =================================
                                     REKOD BAKI CUTI
                                     ================================= -->

                                <% if (!hideBalance) { %>

                                    <section class="modal-section">

                                        <h3 class="modal-section-title">
                                            Rekod Baki Cuti
                                        </h3>


                                        <div class="detail-grid">


                                            <div class="detail-box balance">

                                                <span class="detail-label">
                                                    Baki Sebelum
                                                </span>

                                                <span class="detail-value">

                                                    <strong>
                                                        <%= adminEscape(balanceBefore) %>
                                                    </strong>
                                                    hari

                                                </span>

                                            </div>


                                            <div class="detail-box balance">

                                                <span class="detail-label">
                                                    Baki Selepas
                                                </span>

                                                <span class="detail-value">

                                                    <strong>
                                                        <%= adminEscape(balanceAfter) %>
                                                    </strong>
                                                    hari

                                                </span>

                                            </div>

                                        </div>

                                    </section>

                                <% } %>



                                <!-- =================================
                                     MAKLUMAT SEMASA CUTI
                                     ================================= -->

                                <section class="modal-section">

                                    <h3 class="modal-section-title">
                                        Maklumat Semasa Cuti
                                    </h3>


                                    <div class="detail-grid">


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                No. Telefon
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(contactPhone) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Serah Tugas Kepada
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(handoverStaff) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Dihantar
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(submittedAt) %>
                                            </span>

                                        </div>


                                        <div class="detail-box full">

                                            <span class="detail-label">
                                                Alamat Semasa Cuti
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(contactAddress) %>
                                            </span>

                                        </div>


                                        <div class="detail-box full">

                                            <span class="detail-label">
                                                Lampiran
                                            </span>

                                            <span class="detail-value">

                                                <% if (
                                                    attachment != null
                                                    &&
                                                    !attachment.isBlank()
                                                ) { %>

                                                    <a
                                                        href="<%= request.getContextPath() %>/uploads/<%= adminAttr(attachment) %>"
                                                                                                                class="attachment-link"
                                                    >
                                                        Lihat Lampiran
                                                    </a>

                                                <% } else { %>

                                                    Tiada lampiran.

                                                <% } %>

                                            </span>

                                        </div>

                                    </div>

                                </section>



                                <!-- =================================
                                     SOKONGAN KETUA UNIT
                                     ================================= -->

                                <section class="modal-section">

                                    <h3 class="modal-section-title">
                                        Sokongan Ketua Unit
                                    </h3>


                                    <div class="detail-grid">


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Ketua Unit
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(hodName) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Status Sokongan
                                            </span>

                                            <span class="detail-value">

                                                <%

                                                    String hodLabel =
                                                        "Belum Disemak";

                                                    String hodClass =
                                                        "pending";


                                                    if (
                                                        "SUPPORTED".equalsIgnoreCase(
                                                            hodStatus
                                                        )
                                                        ||
                                                        "APPROVED".equalsIgnoreCase(
                                                            hodStatus
                                                        )
                                                    ) {

                                                        hodLabel =
                                                            "Disokong";

                                                        hodClass =
                                                            "supported";

                                                    } else if (
                                                        "NOT_SUPPORTED".equalsIgnoreCase(
                                                            hodStatus
                                                        )
                                                        ||
                                                        "REJECTED".equalsIgnoreCase(
                                                            hodStatus
                                                        )
                                                    ) {

                                                        hodLabel =
                                                            "Tidak Disokong";

                                                        hodClass =
                                                            "not-supported";
                                                    }

                                                %>


                                                <span
                                                    class="status-pill <%= hodClass %>"
                                                >
                                                    <%= adminEscape(hodLabel) %>
                                                </span>

                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Keputusan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(hodReviewedAt) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Disemak Oleh
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(hodReviewedBy) %>
                                            </span>

                                        </div>


                                        <div class="detail-box full note">

                                            <span class="detail-label">
                                                Catatan Ketua Unit
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(hodRemarks) %>
                                            </span>

                                        </div>

                                    </div>


                                    <!-- =============================
                                         HOD ACTION
                                         ============================= -->

                                    <%
                                        boolean canHodReview =
                                            adminBool(
                                                leaveRow.get("canHodReview")
                                            );

                                        /*
                                         * Fallback untuk versi lama jika
                                         * canHodReview belum dibekalkan
                                         * oleh servlet.
                                         */
                                        if (!leaveRow.containsKey("canHodReview")) {
                                            canHodReview =
                                                isHOD
                                                &&
                                                !hodCompleted
                                                &&
                                                !"CANCELLED".equals(status)
                                                &&
                                                !"APPROVED".equals(status)
                                                &&
                                                !"REJECTED".equals(status);
                                        }
                                    %>

                                    <% if (isHOD && canHodReview) { %>

                                        <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/approval"
                                            class="decision-panel"
                                            style="margin-top:16px;"
                                        >

                                            <input
                                                type="hidden"
                                                name="id"
                                                value="<%= applicationId %>"
                                            >


                                            <strong>
                                                Tindakan Ketua Unit
                                            </strong>


                                            <textarea
                                                name="remarks"
                                                placeholder="Masukkan catatan jika perlu..."
                                            ></textarea>

                                            <span class="decision-help">
                                                Catatan adalah pilihan untuk Sokong dan wajib sekiranya memilih Tidak Sokong.
                                            </span>


                                            <div class="modal-actions">

                                                <button
                                                    type="submit"
                                                    name="action"
                                                    value="NOT_SUPPORT"
                                                    class="action-button not-support"
                                                >
                                                    Tidak Sokong
                                                </button>


                                                <button
                                                    type="submit"
                                                    name="action"
                                                    value="SUPPORT"
                                                    class="action-button support"
                                                >
                                                    Sokong
                                                </button>

                                            </div>

                                        </form>

                                    <% } %>

                                </section>



                                <!-- =================================
                                     KEPUTUSAN PENGURUSAN
                                     ================================= -->

                                <section class="modal-section">

                                    <h3 class="modal-section-title">
                                        Keputusan Pengurusan
                                    </h3>


                                    <div class="detail-grid">


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Keputusan
                                            </span>

                                            <span class="detail-value">

                                                <span
                                                    class="status-pill <%= adminEscape(statusClass) %>"
                                                >
                                                    <%= adminEscape(statusLabel) %>
                                                </span>

                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Oleh
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(reviewedBy) %>
                                            </span>

                                        </div>


                                        <div class="detail-box">

                                            <span class="detail-label">
                                                Tarikh Keputusan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(reviewedAt) %>
                                            </span>

                                        </div>


                                        <div class="detail-box full note">

                                            <span class="detail-label">
                                                Catatan / Alasan
                                            </span>

                                            <span class="detail-value">
                                                <%= adminEscape(managementRemarks) %>
                                            </span>

                                        </div>

                                    </div>



                                    <!-- =============================
                                         MANAGEMENT ACTION
                                         ============================= -->

                                    <%

                                        boolean managementCanAct =
                                            isManagement
                                            &&
                                            !"CANCELLED".equals(status);

                                    %>


                                    <% if (managementCanAct) { %>

                                        <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/approval"
                                            class="decision-panel"
                                            style="margin-top:16px;"
                                        >

                                            <input
                                                type="hidden"
                                                name="id"
                                                value="<%= applicationId %>"
                                            >


                                            <strong>
                                                Keputusan Pengurusan
                                            </strong>


                                            <textarea
                                                name="remarks"
                                                placeholder="Masukkan catatan atau alasan keputusan..."
                                            ></textarea>


                                            <span class="decision-help">
                                                Catatan digalakkan dan perlu diberikan sekiranya permohonan tidak diluluskan.
                                            </span>


                                            <div class="modal-actions">


                                                <button
                                                    type="submit"
                                                    name="action"
                                                    value="APPROVE"
                                                    class="action-button approve"
                                                >
                                                    Luluskan
                                                </button>


                                                <button
                                                    type="submit"
                                                    name="action"
                                                    value="REJECT"
                                                    class="action-button reject"
                                                >
                                                    Tidak Luluskan
                                                </button>

                                            </div>

                                        </form>

                                    <% } %>



                                    <!-- =============================
                                         HR INFORMATION
                                         ============================= -->

                                    <% if (isHR) { %>

                                        <div
                                            class="decision-panel"
                                            style="margin-top:16px;"
                                        >

                                            <strong>
                                                Rekod Pentadbiran
                                            </strong>

                                            <span
                                                class="decision-help"
                                                style="margin-top:7px;"
                                            >
                                                Paparan ini menunjukkan keputusan Ketua Unit dan Pengurusan bagi permohonan ini.
                                            </span>

                                        </div>

                                    <% } %>

                                </section>



                                <!-- =================================
                                     BOTTOM ACTION
                                     ================================= -->

                                <div class="modal-actions">


                                    <a
                                        href="<%= request.getContextPath() %>/print-leave?id=<%= applicationId %>"
                                        
                                        class="action-button print"
                                    >
                                        Cetak Borang
                                    </a>


                                    <button
                                        type="button"
                                        class="action-button print"
                                        onclick="closeApplicationModal('applicationModal<%= applicationId %>')"
                                    >
                                        Tutup
                                    </button>

                                </div>


                            </div>
                            <!-- END MODAL BODY -->


                        </div>
                        <!-- END MODAL DIALOG -->


                    </div>
                    <!-- END MODAL -->


                <%

                        }

                    }

                %>


                    <!-- =================================================
                         SEARCH EMPTY STATE
                         ================================================= -->

                    <div
                        id="filteredApplicationEmpty"
                        class="application-empty"
                        style="display:none;"
                    >

                        Tiada permohonan yang sepadan dengan carian atau kategori yang dipilih.

                    </div>


                </div>
                <!-- END APPLICATION LIST -->


            </section>
            <!-- END PANEL -->


        </div>
        <!-- END APPROVAL PAGE -->


    </main>

</div><script>

/* ============================================================
   APPLICATION PAGE STATE
   ============================================================ */

let currentApplicationFilter = "ALL";


/* ============================================================
   SET FILTER
   ============================================================ */

function setApplicationFilter(filter, clickedElement) {

    currentApplicationFilter =
        filter || "ALL";


    /*
     * Update all statistic cards
     */

    document
        .querySelectorAll(".approval-stat")
        .forEach(function(card) {

            card.classList.remove("active");

            if (
                card.dataset.filter ===
                currentApplicationFilter
            ) {

                card.classList.add("active");
            }

        });


    /*
     * Update filter buttons
     */

    document
        .querySelectorAll(".application-filter")
        .forEach(function(button) {

            button.classList.remove("active");

            if (
                button.dataset.filter ===
                currentApplicationFilter
            ) {

                button.classList.add("active");
            }

        });


    filterApplicationRows();
}


/* ============================================================
   FILTER APPLICATION ROWS
   ============================================================ */

function filterApplicationRows() {

    const searchInput =
        document.getElementById(
            "applicationSearch"
        );


    const searchText =
        searchInput
            ? searchInput.value
                .trim()
                .toLowerCase()
            : "";


    const rows =
        document.querySelectorAll(
            ".application-row"
        );


    let visibleCount = 0;


    rows.forEach(function(row) {

        const rowStatus =
            (
                row.dataset.status || ""
            )
            .trim()
            .toUpperCase();


        const finalStatus =
            (
                row.dataset.finalStatus || ""
            )
            .trim()
            .toUpperCase();


        const rowSearch =
            (
                row.dataset.search || ""
            )
            .trim()
            .toLowerCase();


        const completed =
            row.dataset.completed === "true";


        /* ================================================
           SEARCH
           ================================================ */

        const matchesSearch =
            searchText === ""
            ||
            rowSearch.includes(searchText);


        /* ================================================
           FILTER
           ================================================ */

        let matchesFilter = false;


        switch (
            currentApplicationFilter
        ) {

            case "ALL":

                matchesFilter = true;

                break;


            case "COMPLETED":

                /*
                 * Untuk HR / Management:
                 *
                 * APPROVED + REJECTED
                 *
                 * Untuk HOD:
                 *
                 * data-status row sudah ditetapkan kepada
                 * COMPLETED selepas HOD memberi keputusan.
                 */

                matchesFilter =
                    completed
                    ||
                    rowStatus === "COMPLETED";

                break;


            case "PENDING":

                /*
                 * Semua status belum selesai.
                 */

                matchesFilter =
                    rowStatus === "PENDING"
                    ||
                    rowStatus === "PENDING_HEAD"
                    ||
                    rowStatus === "PENDING_ADMIN"
                    ||
                    rowStatus === "PENDING_MANAGEMENT";

                break;


            case "APPROVED":

                matchesFilter =
                    finalStatus === "APPROVED";

                break;


            case "REJECTED":

                matchesFilter =
                    finalStatus === "REJECTED";

                break;


            case "CANCELLED":

                matchesFilter =
                    finalStatus === "CANCELLED";

                break;


            default:

                matchesFilter =
                    rowStatus ===
                    currentApplicationFilter;

                break;
        }


        /* ================================================
           SHOW / HIDE
           ================================================ */

        if (
            matchesSearch
            &&
            matchesFilter
        ) {

            row.style.display = "";

            visibleCount++;

        } else {

            row.style.display = "none";
        }

    });


    /* ====================================================
       EMPTY SEARCH RESULT
       ==================================================== */

    const filteredEmpty =
        document.getElementById(
            "filteredApplicationEmpty"
        );


    if (filteredEmpty) {

        filteredEmpty.style.display =
            visibleCount === 0
            &&
            rows.length > 0
                ? "block"
                : "none";
    }

}


/* ============================================================
   OPEN APPLICATION MODAL
   ============================================================ */

function openApplicationModal(modalId) {

    const modal =
        document.getElementById(
            modalId
        );


    if (!modal) {
        return;
    }


    /*
     * Close another modal first.
     */

    document
        .querySelectorAll(
            ".application-modal.open"
        )
        .forEach(function(openModal) {

            openModal.classList.remove(
                "open"
            );

        });


    modal.classList.add(
        "open"
    );


    /*
     * Prevent background scrolling.
     */

    document.body.style.overflow =
        "hidden";


    /*
     * Focus close button.
     */

    const closeButton =
        modal.querySelector(
            ".modal-close-button"
        );


    if (closeButton) {

        window.setTimeout(
            function() {

                closeButton.focus();

            },
            50
        );
    }

}


/* ============================================================
   CLOSE APPLICATION MODAL
   ============================================================ */

function closeApplicationModal(modalId) {

    const modal =
        document.getElementById(
            modalId
        );


    if (!modal) {
        return;
    }


    modal.classList.remove(
        "open"
    );


    /*
     * Only restore scroll when no modal is open.
     */

    const remainingModal =
        document.querySelector(
            ".application-modal.open"
        );


    if (!remainingModal) {

        document.body.style.overflow =
            "";
    }

}


/* ============================================================
   CLOSE FROM BACKDROP
   ============================================================ */

function closeModalFromBackdrop(
    event,
    modal
) {

    if (
        event.target === modal
    ) {

        modal.classList.remove(
            "open"
        );


        document.body.style.overflow =
            "";
    }

}


/* ============================================================
   ESC KEY
   ============================================================ */

document.addEventListener(
    "keydown",
    function(event) {

        if (
            event.key !== "Escape"
        ) {
            return;
        }


        const openModal =
            document.querySelector(
                ".application-modal.open"
            );


        if (openModal) {

            openModal.classList.remove(
                "open"
            );


            document.body.style.overflow =
                "";
        }

    }
);


/* ============================================================
   PREVENT FORM DOUBLE SUBMISSION
   ============================================================ */

document
    .querySelectorAll(
        ".decision-panel"
    )
    .forEach(function(form) {

        /*
         * Only forms need submit protection.
         */

        if (
            form.tagName.toLowerCase()
            !== "form"
        ) {

            return;
        }


        form.addEventListener(
            "submit",
            function(event) {

                const submitter =
                    event.submitter;


                if (!submitter) {
                    return;
                }


                /*
                 * Confirmation based on action.
                 */

                const action =
                    (
                        submitter.value || ""
                    )
                    .trim()
                    .toUpperCase();


                let message = "";


                if (
                    action === "APPROVE"
                ) {

                    message =
                        "Adakah anda pasti mahu meluluskan permohonan cuti ini?";

                } else if (
                    action === "REJECT"
                ) {

                    message =
                        "Adakah anda pasti mahu tidak meluluskan permohonan cuti ini?";

                } else if (
                    action === "SUPPORT"
                ) {

                    message =
                        "Adakah anda pasti mahu menyokong permohonan cuti ini?";

                } else if (
                    action === "NOT_SUPPORT"
                ) {

                    message =
                        "Adakah anda pasti mahu tidak menyokong permohonan cuti ini?";
                }


                if (
                    message !== ""
                    &&
                    !window.confirm(message)
                ) {

                    event.preventDefault();

                    return;
                }


                /*
                 * Disable other submit buttons after confirmed.
                 */

                form
                    .querySelectorAll(
                        'button[type="submit"]'
                    )
                    .forEach(function(button) {

                        button.disabled = true;

                        button.style.opacity =
                            ".65";

                        button.style.cursor =
                            "not-allowed";

                    });


                /*
                 * Keep clicked button's value when disabled.
                 *
                 * Disabled submit buttons are normally not sent.
                 */

                if (
                    submitter.name
                    &&
                    submitter.value
                ) {

                    const hiddenAction =
                        document.createElement(
                            "input"
                        );


                    hiddenAction.type =
                        "hidden";


                    hiddenAction.name =
                        submitter.name;


                    hiddenAction.value =
                        submitter.value;


                    form.appendChild(
                        hiddenAction
                    );
                }

            }
        );

    });


/* ============================================================
   SEARCH - ENTER SHOULD NOT SUBMIT ANYTHING
   ============================================================ */

const applicationSearch =
    document.getElementById(
        "applicationSearch"
    );


if (applicationSearch) {

    applicationSearch.addEventListener(
        "keydown",
        function(event) {

            if (
                event.key === "Enter"
            ) {

                event.preventDefault();
            }

        }
    );

}


/* ============================================================
   INITIAL FILTER
   ============================================================ */

document.addEventListener(
    "DOMContentLoaded",
    function() {

        currentApplicationFilter =
            "ALL";


        filterApplicationRows();

    }
);

</script>


</body>

</html>