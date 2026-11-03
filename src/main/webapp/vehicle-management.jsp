<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String vehicleRole = (String) session.getAttribute("userRole");
    String vehicleUserName = (String) session.getAttribute("userName");

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    if (vehicleRole == null || !"HR".equalsIgnoreCase(vehicleRole.trim())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
        return;
    }

    if (vehicleUserName == null || vehicleUserName.isBlank()) {
        vehicleUserName = "Pengguna";
    }

    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> vehicles =
        (java.util.List<java.util.Map<String,Object>>)
        request.getAttribute("vehicles");

    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");

    java.util.function.Function<Object,String> esc = value -> {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    };

    int totalVehicles = 0;
    int activeVehicles = 0;
    int maintenanceVehicles = 0;
    int inactiveVehicles = 0;

    if (vehicles != null) {

        totalVehicles = vehicles.size();

        for (java.util.Map<String,Object> vehicle : vehicles) {

            String status = vehicle.get("status") == null
                ? ""
                : String.valueOf(vehicle.get("status"));

            if ("ACTIVE".equalsIgnoreCase(status)) {
                activeVehicles++;
            }
            else if ("MAINTENANCE".equalsIgnoreCase(status)) {
                maintenanceVehicles++;
            }
            else if ("INACTIVE".equalsIgnoreCase(status)) {
                inactiveVehicles++;
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

<title>Pengurusan Kenderaan - PKB</title>

<link
    rel="stylesheet"
    href="<%= request.getContextPath() %>/css/style.css?v=20260930-vehicle"
>

<style>

* {
    box-sizing: border-box;
}

/* =========================================================
   PAGE
   ========================================================= */

.vehicle-page {
    width: 100%;
    max-width: 1450px;

    color: #3f4857;

    font-size: 13px;
}

.vehicle-page button,
.vehicle-page input,
.vehicle-page select,
.vehicle-page textarea {
    font-family: inherit;
}


/* =========================================================
   PAGE HEADER
   ========================================================= */

.vehicle-page-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;

    gap: 20px;

    margin-bottom: 20px;
}

.vehicle-page-header h1 {
    margin: 0 0 5px;

    color: #202938;

    font-size: 24px;
    line-height: 1.25;

    font-weight: 650;
}

.vehicle-page-header p {
    margin: 0;

    color: #87909e;

    font-size: 13px;
}


/* =========================================================
   MESSAGE
   ========================================================= */

.vehicle-message {
    margin-bottom: 16px;

    padding: 11px 14px;

    border-radius: 8px;

    font-size: 12.5px;
    font-weight: 500;
}

.vehicle-message.success {
    background: #eef8f2;

    border: 1px solid #cfe7d8;

    color: #256847;
}

.vehicle-message.error {
    background: #fff1f2;

    border: 1px solid #efced3;

    color: #9f2f3a;
}


/* =========================================================
   SUMMARY
   ========================================================= */

.vehicle-summary {
    display: grid;

    grid-template-columns:
        repeat(4, minmax(0, 1fr));

    gap: 12px;

    margin-bottom: 18px;
}

.summary-card {
    position: relative;

    display: flex;
    align-items: center;

    gap: 13px;

    min-height: 82px;

    padding: 14px 16px;

    background: #ffffff;

    border: 1px solid #e5e8ed;

    border-radius: 12px;

    box-shadow:
        0 3px 12px rgba(31,41,61,.035);

    overflow: hidden;
}

.summary-card::before {
    content: "";

    position: absolute;

    left: 0;
    top: 0;
    bottom: 0;

    width: 3px;

    background: #7E1020;
}

.summary-card.active::before {
    background: #2c805b;
}

.summary-card.maintenance::before {
    background: #d09a25;
}

.summary-card.inactive::before {
    background: #7c8491;
}

.summary-icon {
    width: 40px;
    height: 40px;

    flex: 0 0 40px;

    display: flex;
    align-items: center;
    justify-content: center;

    border-radius: 10px;

    background: #faf0f2;

    color: #7E1020;
}

.summary-card.active .summary-icon {
    background: #eef8f3;

    color: #287554;
}

.summary-card.maintenance .summary-icon {
    background: #fff7e7;

    color: #aa7818;
}

.summary-card.inactive .summary-icon {
    background: #f1f3f5;

    color: #697281;
}

.summary-icon svg {
    width: 19px;
    height: 19px;
}

.summary-info span {
    display: block;

    margin-bottom: 2px;

    color: #818b9a;

    font-size: 10px;
    font-weight: 550;

    letter-spacing: .25px;

    text-transform: uppercase;
}

.summary-info strong {
    display: block;

    color: #283141;

    font-size: 21px;
    line-height: 1.2;

    font-weight: 650;
}

.summary-info small {
    display: block;

    margin-top: 2px;

    color: #9ba2ad;

    font-size: 10.5px;
}


/* =========================================================
   MAIN CARD
   ========================================================= */

.vehicle-card {
    background: #ffffff;

    border: 1px solid #e4e7ec;

    border-radius: 14px;

    box-shadow:
        0 4px 18px rgba(31,41,61,.04);

    overflow: hidden;
}

.vehicle-card-header {
    display: flex;

    justify-content: space-between;
    align-items: center;

    gap: 18px;

    padding: 18px 20px;

    border-bottom:
        1px solid #eceef2;
}

.vehicle-card-header h2 {
    margin: 0 0 4px;

    color: #263043;

    font-size: 17px;

    font-weight: 650;
}

.vehicle-card-header p {
    margin: 0;

    color: #8b94a1;

    font-size: 12.5px;
}


/* =========================================================
   BUTTON
   ========================================================= */

.admin-btn {
    min-height: 37px;

    display: inline-flex;
    align-items: center;
    justify-content: center;

    gap: 6px;

    padding: 8px 13px;

    border-radius: 8px;

    font-size: 11.5px;
    font-weight: 550;

    text-decoration: none;

    cursor: pointer;

    transition: .15s ease;
}

.admin-btn.primary {
    background: #7E1020;

    border: 1px solid #7E1020;

    color: #ffffff;
}

.admin-btn.primary:hover {
    background: #69101d;

    border-color: #69101d;
}


/* =========================================================
   TOOLBAR
   ========================================================= */

.vehicle-toolbar {
    display: flex;

    align-items: center;
    justify-content: space-between;

    gap: 12px;

    padding: 13px 18px;

    background: #fafbfc;

    border-bottom:
        1px solid #eceef2;
}

.toolbar-left {
    flex: 1;

    display: flex;
    align-items: center;

    gap: 8px;

    flex-wrap: wrap;
}

.search-box {
    position: relative;

    width: 300px;
}

.search-box input {
    width: 100%;
    height: 36px;

    padding: 0 11px;

    background: #ffffff;

    border: 1px solid #dde1e6;

    border-radius: 8px;

    outline: none;

    color: #465064;

    font-size: 11.5px;
}

.filter-select {
    height: 36px;

    min-width: 155px;

    padding: 0 10px;

    background: #ffffff;

    border: 1px solid #dde1e6;

    border-radius: 8px;

    outline: none;

    color: #596476;

    font-size: 11.5px;
}

.search-box input:focus,
.filter-select:focus {
    border-color: #a85c67;

    box-shadow:
        0 0 0 3px rgba(126,16,32,.05);
}

.reset-btn {
    height: 36px;

    padding: 0 11px;

    background: #ffffff;

    border: 1px solid #dde1e6;

    border-radius: 8px;

    color: #687284;

    font-size: 11.5px;
    font-weight: 500;

    cursor: pointer;
}

.reset-btn:hover {
    border-color: #c9a5aa;

    color: #7E1020;
}

.result-count {
    flex-shrink: 0;

    color: #8c95a2;

    font-size: 11.5px;
}

.result-count strong {
    color: #7E1020;

    font-weight: 600;
}


/* =========================================================
   TABLE
   ========================================================= */

.vehicle-table-wrap {
    width: 100%;

    overflow-x: auto;
}

.vehicle-table {
    width: 100%;

    border-collapse: collapse;
}

.vehicle-table th {
    padding: 11px 13px;

    background: #f8f9fb;

    border-bottom:
        1px solid #e7eaf0;

    color: #737e8e;

    font-size: 10px;
    font-weight: 600;

    letter-spacing: .3px;

    text-align: left;

    text-transform: uppercase;

    white-space: nowrap;
}

.vehicle-table td {
    padding: 13px;

    border-bottom:
        1px solid #edf0f3;

    color: #566173;

    font-size: 12px;

    line-height: 1.45;

    vertical-align: middle;
}

.vehicle-table tbody tr:hover {
    background: #fdfbfb;
}

.vehicle-table tbody tr:last-child td {
    border-bottom: none;
}

.vehicle-number {
    color: #263043;

    font-size: 12px;

    font-weight: 650;

    white-space: nowrap;
}

.vehicle-number::before {
    content: "";

    display: inline-block;

    width: 5px;
    height: 5px;

    margin-right: 7px;

    border-radius: 50%;

    background: #D4A63A;

    vertical-align: middle;
}

.vehicle-name {
    color: #374153;

    font-size: 12.5px;

    font-weight: 550;
}


/* =========================================================
   STATUS
   ========================================================= */

.vehicle-status {
    display: inline-flex;

    align-items: center;

    gap: 5px;

    padding: 5px 8px;

    border-radius: 20px;

    font-size: 10px;
    font-weight: 550;

    white-space: nowrap;
}

.vehicle-status::before {
    content: "";

    width: 5px;
    height: 5px;

    border-radius: 50%;
}

.vehicle-status.ACTIVE {
    background: #edf8f2;

    border: 1px solid #d1e9dc;

    color: #2c6f50;
}

.vehicle-status.ACTIVE::before {
    background: #2f825d;
}

.vehicle-status.MAINTENANCE {
    background: #fff7e8;

    border: 1px solid #eddeb8;

    color: #89641c;
}

.vehicle-status.MAINTENANCE::before {
    background: #c08a1b;
}

.vehicle-status.INACTIVE {
    background: #f2f3f5;

    border: 1px solid #dfe2e6;

    color: #667080;
}

.vehicle-status.INACTIVE::before {
    background: #7d8794;
}


/* =========================================================
   ACTION BUTTONS
   ========================================================= */

.action-group {
    display: flex;

    align-items: center;

    gap: 5px;

    white-space: nowrap;
}

.table-btn {
    min-height: 30px;

    display: inline-flex;

    align-items: center;
    justify-content: center;

    padding: 5px 9px;

    border-radius: 7px;

    font-size: 10.5px;
    font-weight: 500;

    cursor: pointer;

    transition: .15s ease;
}

.table-btn.edit {
    background: #fffafb;

    border: 1px solid #ead5d8;

    color: #7E1020;
}

.table-btn.edit:hover {
    background: #faeef0;
}

.table-btn.delete {
    background: #fff3f4;

    border: 1px solid #efced2;

    color: #a02f3a;
}

.table-btn.delete:hover {
    background: #fde7e9;
}


/* =========================================================
   EMPTY
   ========================================================= */

.empty-row td {
    padding: 45px 20px !important;

    text-align: center;
}

.empty-row strong {
    display: block;

    color: #465064;

    font-size: 13px;

    font-weight: 600;
}

.empty-row span {
    display: block;

    margin-top: 4px;

    color: #969eab;

    font-size: 11px;
}

.no-result {
    display: none;

    padding: 35px 20px;

    border-top:
        1px solid #eef0f3;

    text-align: center;

    color: #8992a2;

    font-size: 11.5px;
}


/* =========================================================
   MODAL
   ========================================================= */

.vehicle-modal {
    position: fixed;

    inset: 0;

    z-index: 99999;

    display: none;

    align-items: center;
    justify-content: center;

    padding: 20px;

    background:
        rgba(20,25,34,.52);

    backdrop-filter: blur(2px);
}

.vehicle-modal.show {
    display: flex;
}

.modal-card {
    width: 100%;

    max-width: 520px;

    max-height: 90vh;

    overflow-y: auto;

    background: #ffffff;

    border-radius: 14px;

    box-shadow:
        0 18px 55px rgba(20,25,34,.20);
}

.modal-card.small {
    max-width: 440px;
}

.modal-header {
    display: flex;

    justify-content: space-between;
    align-items: flex-start;

    gap: 20px;

    padding: 19px 20px;

    border-bottom:
        1px solid #eceef2;
}

.modal-header h3 {
    margin: 0 0 4px;

    color: #263043;

    font-size: 17px;

    font-weight: 650;
}

.modal-header p {
    margin: 0;

    color: #8c95a2;

    font-size: 11.5px;

    line-height: 1.5;
}

.modal-close {
    width: 32px;
    height: 32px;

    flex: 0 0 32px;

    background: #ffffff;

    border: 1px solid #e0e3e8;

    border-radius: 8px;

    color: #737d8c;

    font-size: 20px;

    line-height: 1;

    cursor: pointer;
}

.modal-close:hover {
    background: #f6f7f9;

    color: #7E1020;
}

.modal-body {
    padding: 20px;
}


/* =========================================================
   FORM
   ========================================================= */

.form-group {
    margin-bottom: 16px;
}

.form-group:last-child {
    margin-bottom: 0;
}

.form-label {
    display: block;

    margin-bottom: 6px;

    color: #465064;

    font-size: 11.5px;

    font-weight: 600;
}

.required {
    color: #a8323d;
}

.form-control {
    width: 100%;
    height: 40px;

    padding: 0 11px;

    background: #ffffff;

    border: 1px solid #dce0e5;

    border-radius: 8px;

    outline: none;

    color: #465064;

    font-size: 12px;
}

.form-control:focus {
    border-color: #a85c67;

    box-shadow:
        0 0 0 3px rgba(126,16,32,.05);
}

.form-hint {
    display: block;

    margin-top: 5px;

    color: #969eaa;

    font-size: 10px;

    line-height: 1.4;
}


/* =========================================================
   MODAL FOOTER
   ========================================================= */

.modal-footer {
    display: flex;

    justify-content: flex-end;

    gap: 8px;

    padding: 15px 20px;

    background: #fafbfc;

    border-top:
        1px solid #eceef2;
}

.modal-btn {
    min-height: 37px;

    padding: 7px 14px;

    border-radius: 8px;

    font-size: 11.5px;

    font-weight: 550;

    cursor: pointer;
}

.modal-btn.cancel {
    background: #ffffff;

    border: 1px solid #dce0e5;

    color: #687284;
}

.modal-btn.primary {
    background: #7E1020;

    border: 1px solid #7E1020;

    color: #ffffff;
}

.modal-btn.danger {
    background: #a8323d;

    border: 1px solid #a8323d;

    color: #ffffff;
}


/* =========================================================
   DELETE
   ========================================================= */

.delete-message {
    color: #596476;

    font-size: 12.5px;

    line-height: 1.7;
}

.delete-message strong {
    color: #263043;
}


/* =========================================================
   RESPONSIVE
   ========================================================= */

@media (max-width: 950px) {

    .vehicle-summary {
        grid-template-columns:
            repeat(2, minmax(0,1fr));
    }

}

@media (max-width: 700px) {

    .vehicle-page-header,
    .vehicle-card-header,
    .vehicle-toolbar {
        flex-direction: column;

        align-items: stretch;
    }

    .vehicle-summary {
        grid-template-columns: 1fr;
    }

    .search-box {
        width: 100%;
    }

    .filter-select {
        width: 100%;
    }

    .reset-btn {
        width: 100%;
    }

    .result-count {
        margin-top: 4px;
    }

}

</style>

</head>


<body>

<div class="app-layout">

    <%@ include file="includes/sidebar.jspf" %>

    <main class="main-content">

        <div class="vehicle-page">


            <!-- =================================================
                 PAGE HEADER
                 ================================================= -->

            <div class="vehicle-page-header">

                <div>

                    <h1>
                        Pengurusan Kenderaan
                    </h1>

                    <p>
                        Urus senarai kenderaan syarikat untuk kegunaan permohonan staf.
                    </p>

                </div>

            </div>


            <!-- =================================================
                 MESSAGE
                 ================================================= -->

            <%
                if (successMessage != null &&
                    !successMessage.isBlank()) {
            %>

                <div class="vehicle-message success">
                    <%= esc.apply(successMessage) %>
                </div>

            <%
                }

                if (errorMessage != null &&
                    !errorMessage.isBlank()) {
            %>

                <div class="vehicle-message error">
                    <%= esc.apply(errorMessage) %>
                </div>

            <%
                }
            %>


            <!-- =================================================
                 SUMMARY
                 ================================================= -->

            <div class="vehicle-summary">


                <!-- TOTAL -->

                <div class="summary-card">

                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <path d="M5 17h14"/>
                            <path d="M6 17l1-7h10l1 7"/>
                            <path d="M8 10l1.5-3h5L16 10"/>
                            <circle cx="8" cy="17" r="2"/>
                            <circle cx="16" cy="17" r="2"/>
                        </svg>

                    </div>

                    <div class="summary-info">

                        <span>Jumlah Kenderaan</span>

                        <strong>
                            <%= totalVehicles %>
                        </strong>

                        <small>
                            Semua rekod
                        </small>

                    </div>

                </div>


                <!-- ACTIVE -->

                <div class="summary-card active">

                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <path d="M5 17h14"/>
                            <path d="M6 17l1-7h10l1 7"/>
                            <path d="M8 10l1.5-3h5L16 10"/>
                            <circle cx="8" cy="17" r="2"/>
                            <circle cx="16" cy="17" r="2"/>
                        </svg>

                    </div>

                    <div class="summary-info">

                        <span>Aktif</span>

                        <strong>
                            <%= activeVehicles %>
                        </strong>

                        <small>
                            Boleh digunakan
                        </small>

                    </div>

                </div>


                <!-- MAINTENANCE -->

                <div class="summary-card maintenance">

                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <path d="M14.5 6.5l3-3"/>
                            <path d="M15 3a4 4 0 0 0-4.7 5.2L4 14.5a2.1 2.1 0 0 0 3 3l6.3-6.3A4 4 0 0 0 18.5 6"/>
                        </svg>

                    </div>

                    <div class="summary-info">

                        <span>Penyelenggaraan</span>

                        <strong>
                            <%= maintenanceVehicles %>
                        </strong>

                        <small>
                            Tidak tersedia
                        </small>

                    </div>

                </div>


                <!-- INACTIVE -->

                <div class="summary-card inactive">

                    <div class="summary-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                        >
                            <circle cx="12" cy="12" r="8"/>
                            <path d="M8 8l8 8"/>
                        </svg>

                    </div>

                    <div class="summary-info">

                        <span>Tidak Aktif</span>

                        <strong>
                            <%= inactiveVehicles %>
                        </strong>

                        <small>
                            Tidak digunakan
                        </small>

                    </div>

                </div>

            </div>


            <!-- =================================================
                 MAIN CARD
                 ================================================= -->

            <div class="vehicle-card">


                <!-- HEADER -->

                <div class="vehicle-card-header">

                    <div>

                        <h2>
                            Senarai Kenderaan
                        </h2>

                        <p>
                            Senarai kenderaan syarikat yang didaftarkan dalam sistem.
                        </p>

                    </div>

                    <button
                        type="button"
                        class="admin-btn primary"
                        onclick="openModal('addVehicleModal')"
                    >
                        + Tambah Kenderaan
                    </button>

                </div>


                <!-- =================================================
                     TOOLBAR
                     ================================================= -->

                <div class="vehicle-toolbar">

                    <div class="toolbar-left">

                        <div class="search-box">

                            <input
                                type="text"
                                id="vehicleSearch"
                                placeholder="Cari no. pendaftaran atau kenderaan..."
                                oninput="filterVehicles()"
                            >

                        </div>


                        <select
                            id="vehicleStatusFilter"
                            class="filter-select"
                            onchange="filterVehicles()"
                        >

                            <option value="">
                                Semua Status
                            </option>

                            <option value="ACTIVE">
                                Aktif
                            </option>

                            <option value="MAINTENANCE">
                                Penyelenggaraan
                            </option>

                            <option value="INACTIVE">
                                Tidak Aktif
                            </option>

                        </select>


                        <button
                            type="button"
                            class="reset-btn"
                            onclick="resetVehicleFilter()"
                        >
                            Reset
                        </button>

                    </div>


                    <div class="result-count">

                        <strong id="visibleVehicleCount">
                            <%= totalVehicles %>
                        </strong>

                        kenderaan

                    </div>

                </div>


                <!-- =================================================
                     TABLE
                     ================================================= -->

                <div class="vehicle-table-wrap">

                    <table
                        class="vehicle-table"
                        id="vehicleTable"
                    >

                        <thead>

                            <tr>

                                <th>
                                    No. Pendaftaran
                                </th>

                                <th>
                                    Nama / Model Kenderaan
                                </th>

                                <th>
                                    Status
                                </th>

                                <th>
                                    Tindakan
                                </th>

                            </tr>

                        </thead>


                        <tbody>

                        <%
                            if (vehicles != null &&
                                !vehicles.isEmpty()) {

                                for (
                                    java.util.Map<String,Object> vehicle
                                    : vehicles
                                ) {

                                    int vehicleId =
                                        ((Number)
                                            vehicle.get("id")
                                        ).intValue();

                                    String plateNumber =
                                        esc.apply(
                                            vehicle.get("plate_number")
                                        );

                                    String vehicleName =
                                        esc.apply(
                                            vehicle.get("vehicle_name")
                                        );

                                    String status =
                                        vehicle.get("status") == null
                                        ? ""
                                        : String.valueOf(
                                            vehicle.get("status")
                                        );

                                    String statusLabel;

                                    if ("ACTIVE".equalsIgnoreCase(status)) {
                                        statusLabel = "Aktif";
                                    }
                                    else if (
                                        "MAINTENANCE".equalsIgnoreCase(status)
                                    ) {
                                        statusLabel = "Penyelenggaraan";
                                    }
                                    else {
                                        statusLabel = "Tidak Aktif";
                                    }
                        %>

                            <tr
                                class="vehicle-row"
                                data-search="<%= plateNumber.toLowerCase() %> <%= vehicleName.toLowerCase() %>"
                                data-status="<%= esc.apply(status) %>"
                            >

                                <td>

                                    <span class="vehicle-number">
                                        <%= plateNumber %>
                                    </span>

                                </td>


                                <td>

                                    <span class="vehicle-name">
                                        <%= vehicleName %>
                                    </span>

                                </td>


                                <td>

                                    <span
                                        class="vehicle-status <%= esc.apply(status) %>"
                                    >
                                        <%= statusLabel %>
                                    </span>

                                </td>


                                <td>

                                    <div class="action-group">


                                        <!-- EDIT -->

                                        <button
                                            type="button"
                                            class="table-btn edit"

                                            data-id="<%= vehicleId %>"
                                            data-plate="<%= plateNumber %>"
                                            data-name="<%= vehicleName %>"
                                            data-status="<%= esc.apply(status) %>"

                                            onclick="openEditVehicle(this)"
                                        >
                                            Edit
                                        </button>


                                        <!-- DELETE -->

                                        <button
                                            type="button"
                                            class="table-btn delete"

                                            data-id="<%= vehicleId %>"
                                            data-plate="<%= plateNumber %>"
                                            data-name="<%= vehicleName %>"

                                            onclick="openDeleteVehicle(this)"
                                        >
                                            Padam
                                        </button>

                                    </div>

                                </td>

                            </tr>

                        <%
                                }
                            }
                            else {
                        %>

                            <tr class="empty-row">

                                <td colspan="4">

                                    <strong>
                                        Tiada kenderaan didaftarkan
                                    </strong>

                                    <span>
                                        Tambah kenderaan syarikat untuk memulakan pengurusan kenderaan.
                                    </span>

                                </td>

                            </tr>

                        <%
                            }
                        %>

                        </tbody>

                    </table>

                </div>


                <!-- NO FILTER RESULT -->

                <div
                    id="vehicleNoResult"
                    class="no-result"
                >
                    Tiada kenderaan yang sepadan dengan carian atau penapis yang dipilih.
                </div>


            </div>

        </div>

    </main>

</div>


<!-- =========================================================
     ADD VEHICLE MODAL
     ========================================================= -->

<div
    id="addVehicleModal"
    class="vehicle-modal"
>

    <div class="modal-card">

        <div class="modal-header">

            <div>

                <h3>
                    Tambah Kenderaan
                </h3>

                <p>
                    Masukkan maklumat kenderaan syarikat baharu.
                </p>

            </div>

            <button
                type="button"
                class="modal-close"
                onclick="closeModal('addVehicleModal')"
            >
                &times;
            </button>

        </div>


        <form
            action="<%= request.getContextPath() %>/vehicle-management"
            method="post"
            autocomplete="off"
        >

            <input
                type="hidden"
                name="action"
                value="add"
            >


            <div class="modal-body">


                <div class="form-group">

                    <label class="form-label">

                        No. Pendaftaran

                        <span class="required">*</span>

                    </label>

                    <input
                        type="text"
                        name="plate_number"
                        class="form-control"
                        placeholder="Contoh: KDA 1234"
                        maxlength="30"
                        required
                    >

                    <span class="form-hint">
                        Nombor pendaftaran akan disimpan dalam huruf besar.
                    </span>

                </div>


                <div class="form-group">

                    <label class="form-label">

                        Nama / Model Kenderaan

                        <span class="required">*</span>

                    </label>

                    <input
                        type="text"
                        name="vehicle_name"
                        class="form-control"
                        placeholder="Contoh: Toyota Vios"
                        maxlength="100"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">

                        Status

                        <span class="required">*</span>

                    </label>

                    <select
                        name="status"
                        class="form-control"
                        required
                    >

                        <option value="ACTIVE">
                            Aktif
                        </option>

                        <option value="MAINTENANCE">
                            Penyelenggaraan
                        </option>

                        <option value="INACTIVE">
                            Tidak Aktif
                        </option>

                    </select>

                </div>


            </div>


            <div class="modal-footer">

                <button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('addVehicleModal')"
                >
                    Batal
                </button>

                <button
                    type="submit"
                    class="modal-btn primary"
                >
                    Tambah Kenderaan
                </button>

            </div>

        </form>

    </div>

</div>


<!-- =========================================================
     EDIT VEHICLE MODAL
     ========================================================= -->

<div
    id="editVehicleModal"
    class="vehicle-modal"
>

    <div class="modal-card">

        <div class="modal-header">

            <div>

                <h3>
                    Edit Kenderaan
                </h3>

                <p>
                    Kemaskini maklumat atau status kenderaan.
                </p>

            </div>

            <button
                type="button"
                class="modal-close"
                onclick="closeModal('editVehicleModal')"
            >
                &times;
            </button>

        </div>


        <form
            action="<%= request.getContextPath() %>/vehicle-management"
            method="post"
            autocomplete="off"
        >

            <input
                type="hidden"
                name="action"
                value="edit"
            >

            <input
                type="hidden"
                name="id"
                id="editVehicleId"
            >


            <div class="modal-body">


                <div class="form-group">

                    <label class="form-label">

                        No. Pendaftaran

                        <span class="required">*</span>

                    </label>

                    <input
                        type="text"
                        name="plate_number"
                        id="editPlateNumber"
                        class="form-control"
                        maxlength="30"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">

                        Nama / Model Kenderaan

                        <span class="required">*</span>

                    </label>

                    <input
                        type="text"
                        name="vehicle_name"
                        id="editVehicleName"
                        class="form-control"
                        maxlength="100"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">

                        Status

                        <span class="required">*</span>

                    </label>

                    <select
                        name="status"
                        id="editVehicleStatus"
                        class="form-control"
                        required
                    >

                        <option value="ACTIVE">
                            Aktif
                        </option>

                        <option value="MAINTENANCE">
                            Penyelenggaraan
                        </option>

                        <option value="INACTIVE">
                            Tidak Aktif
                        </option>

                    </select>

                </div>


            </div>


            <div class="modal-footer">

                <button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('editVehicleModal')"
                >
                    Batal
                </button>

                <button
                    type="submit"
                    class="modal-btn primary"
                >
                    Simpan Perubahan
                </button>

            </div>

        </form>

    </div>

</div>


<!-- =========================================================
     DELETE VEHICLE MODAL
     ========================================================= -->

<div
    id="deleteVehicleModal"
    class="vehicle-modal"
>

    <div class="modal-card small">

        <div class="modal-header">

            <div>

                <h3>
                    Padam Kenderaan
                </h3>

                <p>
                    Sahkan tindakan sebelum meneruskan.
                </p>

            </div>

            <button
                type="button"
                class="modal-close"
                onclick="closeModal('deleteVehicleModal')"
            >
                &times;
            </button>

        </div>


        <form
            action="<%= request.getContextPath() %>/vehicle-management"
            method="post"
        >

            <input
                type="hidden"
                name="action"
                value="delete"
            >

            <input
                type="hidden"
                name="id"
                id="deleteVehicleId"
            >


            <div class="modal-body">

                <div class="delete-message">

                    Adakah anda pasti mahu memadam kenderaan

                    <strong id="deleteVehicleText"></strong>?

                    <br><br>

                    Kenderaan yang mempunyai rekod permohonan tidak boleh dipadam.
                    Untuk kenderaan tersebut, tukarkan status kepada
                    <strong>Tidak Aktif</strong>.

                </div>

            </div>


            <div class="modal-footer">

                <button
                    type="button"
                    class="modal-btn cancel"
                    onclick="closeModal('deleteVehicleModal')"
                >
                    Batal
                </button>

                <button
                    type="submit"
                    class="modal-btn danger"
                >
                    Padam Kenderaan
                </button>

            </div>

        </form>

    </div>

</div>


<script>

/* =========================================================
   MODAL
   ========================================================= */

function openModal(id) {

    const modal =
        document.getElementById(id);

    if (modal) {
        modal.classList.add("show");
    }
}


function closeModal(id) {

    const modal =
        document.getElementById(id);

    if (modal) {
        modal.classList.remove("show");
    }
}


/* =========================================================
   EDIT
   ========================================================= */

function openEditVehicle(button) {

    document.getElementById(
        "editVehicleId"
    ).value =
        button.dataset.id || "";

    document.getElementById(
        "editPlateNumber"
    ).value =
        button.dataset.plate || "";

    document.getElementById(
        "editVehicleName"
    ).value =
        button.dataset.name || "";

    document.getElementById(
        "editVehicleStatus"
    ).value =
        button.dataset.status || "ACTIVE";

    openModal(
        "editVehicleModal"
    );
}


/* =========================================================
   DELETE
   ========================================================= */

function openDeleteVehicle(button) {

    document.getElementById(
        "deleteVehicleId"
    ).value =
        button.dataset.id || "";

    const plate =
        button.dataset.plate || "";

    const name =
        button.dataset.name || "";

    document.getElementById(
        "deleteVehicleText"
    ).textContent =
        plate + " - " + name;

    openModal(
        "deleteVehicleModal"
    );
}


/* =========================================================
   FILTER
   ========================================================= */

function filterVehicles() {

    const search =
        document.getElementById(
            "vehicleSearch"
        ).value
        .toLowerCase()
        .trim();

    const status =
        document.getElementById(
            "vehicleStatusFilter"
        ).value;

    const rows =
        document.querySelectorAll(
            ".vehicle-row"
        );

    let visible = 0;

    rows.forEach(function(row) {

        const rowSearch =
            (row.dataset.search || "")
            .toLowerCase();

        const rowStatus =
            row.dataset.status || "";

        const searchMatch =
            !search ||
            rowSearch.includes(search);

        const statusMatch =
            !status ||
            rowStatus === status;

        if (searchMatch && statusMatch) {

            row.style.display = "";

            visible++;

        }
        else {

            row.style.display = "none";

        }

    });


    const count =
        document.getElementById(
            "visibleVehicleCount"
        );

    if (count) {
        count.textContent = visible;
    }


    const noResult =
        document.getElementById(
            "vehicleNoResult"
        );

    if (noResult) {

        if (rows.length > 0 && visible === 0) {
            noResult.style.display = "block";
        }
        else {
            noResult.style.display = "none";
        }
    }
}


/* =========================================================
   RESET FILTER
   ========================================================= */

function resetVehicleFilter() {

    document.getElementById(
        "vehicleSearch"
    ).value = "";

    document.getElementById(
        "vehicleStatusFilter"
    ).value = "";

    filterVehicles();
}


/* =========================================================
   CLOSE MODAL WHEN CLICK OUTSIDE
   ========================================================= */

document.querySelectorAll(
    ".vehicle-modal"
).forEach(function(modal) {

    modal.addEventListener(
        "click",
        function(event) {

            if (event.target === modal) {

                modal.classList.remove(
                    "show"
                );

            }
        }
    );

});


/* =========================================================
   ESC KEY
   ========================================================= */

document.addEventListener(
    "keydown",
    function(event) {

        if (event.key === "Escape") {

            document.querySelectorAll(
                ".vehicle-modal.show"
            ).forEach(function(modal) {

                modal.classList.remove(
                    "show"
                );

            });

        }
    }
);

</script>

</body>
</html>