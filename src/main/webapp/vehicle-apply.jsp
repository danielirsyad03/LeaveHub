<%@ page contentType="text/html;charset=UTF-8" %>

<%
    // =========================================================
    // LOGIN CHECK
    // =========================================================
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }

    // =========================================================
    // DATA
    // =========================================================
    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> vehicles =
        (java.util.List<java.util.Map<String,Object>>)
        request.getAttribute("vehicles");

    @SuppressWarnings("unchecked")
    java.util.Map<String,Object> applicant =
        (java.util.Map<String,Object>)
        request.getAttribute("applicant");

    // =========================================================
    // USER
    // =========================================================
    String applicantName = "";

    if (applicant != null && applicant.get("name") != null) {
        applicantName = String.valueOf(applicant.get("name"));
    }

    if (applicantName == null || applicantName.isBlank()) {
        Object sessionName = session.getAttribute("userName");

        applicantName =
            sessionName == null
            ? "Pengguna"
            : String.valueOf(sessionName);
    }

    String userName = applicantName;

    String userInitial =
        userName != null && !userName.isBlank()
        ? userName.substring(0,1).toUpperCase()
        : "P";

    // =========================================================
    // MESSAGES
    // =========================================================
    String successMessage =
        request.getParameter("success");

    String errorMessage =
        request.getParameter("error");

    // =========================================================
    // ESCAPE HTML
    // =========================================================
    java.util.function.Function<Object,String> esc = value -> {

        if (value == null) {
            return "";
        }

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
    };

    // =========================================================
    // VEHICLE AVAILABILITY
    // =========================================================
    boolean hasVehicle =
        vehicles != null &&
        !vehicles.isEmpty();
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
        Permohonan Kenderaan - PKB
    </title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=vehicle-apply-20261004-v4"
    >

    <style>

        * {
            box-sizing: border-box;
        }

        html,
        body {
            width: 100%;
            max-width: 100%;
            margin: 0;
            overflow-x: hidden;
        }

        .app-layout {
            width: 100%;
            max-width: 100%;
            min-width: 0;
        }

        .main-content {
            min-width: 0;
            max-width: 100%;
            overflow-x: hidden;
        }


        /* =====================================================
           PAGE
           ===================================================== */

        .vehicle-apply-page {
            width: 100%;
            max-width: 100%;
            min-width: 0;

            color: #3f4857;

            font-size: 14px;
        }


        /* =====================================================
           PAGE HEADER
           ===================================================== */

        .vehicle-page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;

            gap: 20px;

            margin-bottom: 20px;
        }

        .vehicle-page-title {
            min-width: 0;
        }

        .vehicle-page-title h1 {
            margin: 0 0 6px;

            color: #172033;

            font-size: 27px;
            font-weight: 750;

            line-height: 1.2;

            letter-spacing: -0.4px;
        }

        .vehicle-page-title p {
            margin: 0;

            color: #7f899a;

            font-size: 14px;
            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           HEADER ACTIONS
           ===================================================== */

        .vehicle-header-actions {
            display: flex;
            align-items: center;

            gap: 10px;

            flex-shrink: 0;
        }


        /* =====================================================
           NOTIFICATION
           ===================================================== */

        .notification-button {
            position: relative;

            width: 46px;
            height: 46px;

            display: grid;
            place-items: center;

            padding: 0;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 12px;

            color: #738095;

            cursor: pointer;

            box-shadow:
                0 3px 12px
                rgba(31, 41, 61, .04);

            transition: .15s ease;
        }

        .notification-button:hover {
            background: #fff7f8;

            border-color: #e3c5ca;

            color: #8d1f2d;
        }

        .notification-button svg {
            width: 20px;
            height: 20px;

            stroke: currentColor;
        }


        /* =====================================================
           USER CHIP
           ===================================================== */

        .vehicle-user-chip {
            display: flex;
            align-items: center;

            gap: 10px;

            min-height: 46px;

            padding: 6px 14px 6px 7px;

            background: #ffffff;

            border: 1px solid #e5e8ed;
            border-radius: 12px;

            box-shadow:
                0 3px 12px
                rgba(31, 41, 61, .04);
        }

        .vehicle-user-avatar {
            width: 34px;
            height: 34px;

            display: grid;
            place-items: center;

            flex-shrink: 0;

            border-radius: 9px;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8e9
                );

            border: 1px solid #efd8dc;

            color: #8d1f2d;

            font-size: 13px;
            font-weight: 700;
        }

        .vehicle-user-name {
            color: #2e3748;

            font-size: 13px;
            font-weight: 650;

            white-space: nowrap;
        }


        /* =====================================================
           MESSAGE
           ===================================================== */

        .form-message {
            margin-bottom: 16px;

            padding: 13px 15px;

            border-radius: 9px;

            font-size: 13px;

            line-height: 1.5;
        }

        .form-message.success {
            background: #eef8f2;

            border: 1px solid #cfe7d8;

            color: #256847;
        }

        .form-message.error {
            background: #fff1f2;

            border: 1px solid #efced3;

            color: #9f2f3a;
        }


        /* =====================================================
           NO VEHICLE
           ===================================================== */

        .no-vehicle-box {
            margin-bottom: 18px;

            padding: 14px 16px;

            background: #fff8e9;

            border: 1px solid #ead9ae;
            border-radius: 9px;

            color: #7c611f;

            font-size: 13px;

            line-height: 1.55;
        }


        /* =====================================================
           MAIN CARD
           ===================================================== */

        .application-card {
            width: 100%;

            background: #ffffff;

            border: 1px solid #e4e7ec;
            border-radius: 15px;

            box-shadow:
                0 7px 24px
                rgba(31, 41, 61, .055);

            overflow: hidden;
        }


        /* =====================================================
           CARD HEADER
           ===================================================== */

        .application-card-header {
            display: flex;
            align-items: center;

            gap: 14px;

            padding: 18px 22px;

            background:
                linear-gradient(
                    180deg,
                    #ffffff,
                    #fdfdfe
                );

            border-bottom:
                1px solid #eceef2;
        }

        .header-icon {
            width: 44px;
            height: 44px;

            flex: 0 0 44px;

            display: flex;
            align-items: center;
            justify-content: center;

            background:
                linear-gradient(
                    135deg,
                    #fff0f2,
                    #fff8f8
                );

            border: 1px solid #ecd9dc;
            border-radius: 11px;

            color: #8d1f2d;
        }

        .header-icon svg {
            width: 21px;
            height: 21px;
        }

        .application-card-header h2 {
            margin: 0 0 4px;

            color: #263043;

            font-size: 17px;
            font-weight: 700;

            line-height: 1.3;
        }

        .application-card-header p {
            margin: 0;

            color: #8b94a1;

            font-size: 13px;

            line-height: 1.4;
        }


        /* =====================================================
           FORM BODY
           ===================================================== */

        .application-body {
            padding: 22px;
        }


        /* =====================================================
           FORM SECTION
           ===================================================== */

        .form-section {
            margin-bottom: 28px;
        }

        .form-section:last-of-type {
            margin-bottom: 0;
        }

        .section-heading {
            display: flex;
            align-items: center;

            gap: 10px;

            margin-bottom: 18px;

            padding-bottom: 11px;

            border-bottom:
                1px solid #eef0f3;
        }

        .section-number {
            width: 27px;
            height: 27px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            flex-shrink: 0;

            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a92839
                );

            border-radius: 50%;

            color: #ffffff;

            font-size: 12px;
            font-weight: 700;

            box-shadow:
                0 2px 5px
                rgba(141,31,45,.12);
        }

        .section-heading h3 {
            margin: 0;

            color: #354052;

            font-size: 14px;
            font-weight: 700;
        }


        /* =====================================================
           FORM GRID
           ===================================================== */

        .form-grid {
            display: grid;

            grid-template-columns:
                repeat(2, minmax(0,1fr));

            gap: 18px 20px;
        }

        .form-group {
            min-width: 0;
        }

        .form-group.full {
            grid-column: 1 / -1;
        }


        /* =====================================================
           LABEL
           ===================================================== */

        .form-label {
            display: block;

            margin-bottom: 7px;

            color: #465166;

            font-size: 13px;
            font-weight: 600;

            line-height: 1.35;
        }

        .required {
            color: #a8323d;
        }


        /* =====================================================
           INPUT
           ===================================================== */

        .form-control {
            width: 100%;

            min-height: 44px;

            padding: 10px 12px;

            background: #ffffff;

            border: 1px solid #dce0e5;
            border-radius: 9px;

            outline: none;

            color: #465064;

            font-family: inherit;

            font-size: 13px;

            transition:
                border-color .15s ease,
                box-shadow .15s ease,
                background .15s ease;
        }

        .form-control:hover {
            border-color: #cfd4dc;
        }

        .form-control:focus {
            border-color: #a85c67;

            box-shadow:
                0 0 0 3px
                rgba(126,16,32,.055);
        }

        .form-control[readonly] {
            background: #f7f8fa;

            border-color: #e3e6ea;

            color: #5c6676;

            cursor: default;
        }

        select.form-control {
            cursor: pointer;
        }

        textarea.form-control {
            min-height: 100px;

            resize: vertical;

            line-height: 1.55;
        }

        .form-hint {
            display: block;

            margin-top: 6px;

            color: #929baa;

            font-size: 11.5px;

            line-height: 1.45;
        }


        /* =====================================================
           VEHICLE NOTE
           ===================================================== */

        .vehicle-option-note {
            margin-top: 8px;

            padding: 10px 12px;

            background: #f8f9fb;

            border: 1px solid #e7e9ed;
            border-radius: 8px;

            color: #7b8492;

            font-size: 11.5px;

            line-height: 1.5;
        }

        .vehicle-option-note strong {
            color: #566173;
        }


        /* =====================================================
           INFORMATION BOX
           ===================================================== */

        .info-box {
            display: flex;

            gap: 11px;

            margin-top: 22px;

            padding: 13px 15px;

            background:
                linear-gradient(
                    135deg,
                    #fafbfc,
                    #f8f9fb
                );

            border: 1px solid #e4e7ec;
            border-radius: 9px;
        }

        .info-icon {
            flex: 0 0 auto;

            color: #8d1f2d;

            font-size: 17px;

            line-height: 1.3;
        }

        .info-content {
            color: #6e7888;

            font-size: 12px;

            line-height: 1.55;
        }

        .info-content strong {
            color: #4c5668;
        }


        /* =====================================================
           FOOTER
           ===================================================== */

        .application-footer {
            display: flex;
            align-items: center;
            justify-content: flex-end;

            gap: 10px;

            padding: 17px 22px;

            background: #fafbfc;

            border-top:
                1px solid #eceef2;
        }


        /* =====================================================
           BUTTON
           ===================================================== */

        .form-btn {
            min-height: 40px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            padding: 9px 16px;

            border-radius: 8px;

            font-family: inherit;

            font-size: 12.5px;
            font-weight: 600;

            text-decoration: none;

            cursor: pointer;

            transition: .15s ease;
        }

        .form-btn.secondary {
            background: #ffffff;

            border: 1px solid #dce0e5;

            color: #687284;
        }

        .form-btn.secondary:hover {
            border-color: #c6cbd2;

            background: #f8f9fa;
        }

        .form-btn.primary {
            background: #971d2d;

            border: 1px solid #971d2d;

            color: #ffffff;
        }

        .form-btn.primary:hover {
            background: #7e1724;

            border-color: #7e1724;

            box-shadow:
                0 4px 10px
                rgba(141,31,45,.14);

            transform: translateY(-1px);
        }

        .form-btn.primary:disabled {
            background: #b8bcc3;

            border-color: #b8bcc3;

            box-shadow: none;

            cursor: not-allowed;

            transform: none;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 760px) {

            .vehicle-page-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .vehicle-header-actions {
                width: 100%;

                justify-content: flex-end;
            }

            .vehicle-page-title h1 {
                font-size: 24px;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-group.full {
                grid-column: auto;
            }

            .application-body {
                padding: 18px;
            }

            .application-card-header {
                padding: 17px 18px;
            }

            .application-footer {
                flex-direction: column-reverse;

                align-items: stretch;

                padding: 16px 18px;
            }

            .form-btn {
                width: 100%;
            }

        }

    </style>

</head>


<body>


<div class="app-layout">


    <%@ include file="includes/sidebar.jspf" %>


    <main class="main-content">


        <div class="vehicle-apply-page">


            <!-- =================================================
                 PAGE HEADER
                 ================================================= -->

            <div class="vehicle-page-header">


                <div class="vehicle-page-title">

                    <h1>
                        Permohonan Kenderaan
                    </h1>

                    <p>
                        Lengkapkan maklumat penggunaan kenderaan syarikat.
                    </p>

                </div>


                <div class="vehicle-header-actions">


                    <!-- =========================================
                         NOTIFICATION BELL
                         HANYA SATU IKON
                         ========================================= -->

                    <button
                        type="button"
                        class="notification-button"
                        title="Notifikasi"
                        aria-label="Notifikasi"
                    >

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >

                            <path
                                d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                            />

                            <path
                                d="M13.73 21a2 2 0 0 1-3.46 0"
                            />

                        </svg>

                    </button>


                    <!-- =========================================
                         USER
                         ========================================= -->

                    <div class="vehicle-user-chip">


                        <div class="vehicle-user-avatar">

                            <%= esc.apply(userInitial) %>

                        </div>


                        <div class="vehicle-user-name">

                            <%= esc.apply(userName) %>

                        </div>


                    </div>


                </div>


            </div>


            <!-- =================================================
                 SUCCESS MESSAGE
                 ================================================= -->

            <%
                if (
                    successMessage != null &&
                    !successMessage.isBlank()
                ) {
            %>

                <div class="form-message success">

                    <%= esc.apply(successMessage) %>

                </div>

            <%
                }
            %>


            <!-- =================================================
                 ERROR MESSAGE
                 ================================================= -->

            <%
                if (
                    errorMessage != null &&
                    !errorMessage.isBlank()
                ) {
            %>

                <div class="form-message error">

                    <%= esc.apply(errorMessage) %>

                </div>

            <%
                }
            %>


            <!-- =================================================
                 NO VEHICLE WARNING
                 ================================================= -->

            <%
                if (!hasVehicle) {
            %>

                <div class="no-vehicle-box">

                    <strong>
                        Tiada kenderaan tersedia.
                    </strong>

                    <br>

                    Buat masa ini tiada kenderaan berstatus
                    Aktif yang boleh dipohon. Sila hubungi
                    pihak pentadbiran.

                </div>

            <%
                }
            %>


            <!-- =================================================
                 APPLICATION CARD
                 ================================================= -->

            <div class="application-card">


                <!-- =============================================
                     CARD HEADER
                     ============================================= -->

                <div class="application-card-header">


                    <div class="header-icon">

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >

                            <path d="M5 17h14"/>

                            <path d="M6 17l1-7h10l1 7"/>

                            <path d="M8 10l1.5-3h5L16 10"/>

                            <circle
                                cx="8"
                                cy="17"
                                r="2"
                            />

                            <circle
                                cx="16"
                                cy="17"
                                r="2"
                            />

                        </svg>

                    </div>


                    <div>

                        <h2>
                            Borang Permohonan Mengguna Kenderaan Syarikat
                        </h2>

                        <p>
                            Permohonan akan dihantar kepada Admin untuk kelulusan.
                        </p>

                    </div>


                </div>


                <!-- =============================================
                     FORM
                     ============================================= -->

                <form
                    action="<%= request.getContextPath() %>/vehicle-apply"
                    method="post"
                    autocomplete="off"
                    id="vehicleApplicationForm"
                >


                    <div class="application-body">


                        <!-- =====================================
                             SECTION 1
                             ===================================== -->

                        <div class="form-section">


                            <div class="section-heading">

                                <span class="section-number">
                                    1
                                </span>

                                <h3>
                                    Maklumat Pemohon
                                </h3>

                            </div>


                            <div class="form-grid">


                                <div class="form-group full">


                                    <label class="form-label">
                                        Nama Pemohon
                                    </label>


                                    <input
                                        type="text"
                                        class="form-control"
                                        value="<%= esc.apply(applicantName) %>"
                                        readonly
                                    >


                                    <span class="form-hint">
                                        Maklumat pemohon diambil secara automatik daripada akaun yang sedang log masuk.
                                    </span>


                                </div>


                            </div>


                        </div>


                        <!-- =====================================
                             SECTION 2
                             ===================================== -->

                        <div class="form-section">


                            <div class="section-heading">

                                <span class="section-number">
                                    2
                                </span>

                                <h3>
    Maklumat Kenderaan &amp; Penggunaan
</h3>

                            </div>


                            <div class="form-grid">


                                <!-- VEHICLE -->

                                <div class="form-group full">


                                    <label class="form-label">

                                        Kenderaan

                                        <span class="required">
                                            *
                                        </span>

                                    </label>


                                    <select
                                        name="vehicle_id"
                                        id="vehicleId"
                                        class="form-control"
                                        required
                                        <%= !hasVehicle ? "disabled" : "" %>
                                    >

                                        <option value="">
                                            -- Pilih Kenderaan --
                                        </option>


                                        <%
                                            if (vehicles != null) {

                                                for (
                                                    java.util.Map<String,Object> vehicle
                                                    : vehicles
                                                ) {

                                                    int vehicleId =
                                                        ((Number)
                                                            vehicle.get("id")
                                                        ).intValue();

                                                    String plate =
                                                        esc.apply(
                                                            vehicle.get(
                                                                "plate_number"
                                                            )
                                                        );

                                                    String vehicleName =
                                                        esc.apply(
                                                            vehicle.get(
                                                                "vehicle_name"
                                                            )
                                                        );
                                        %>


                                            <option
                                                value="<%= vehicleId %>"
                                            >
                                                <%= plate %> - <%= vehicleName %>
                                            </option>


                                        <%
                                                }
                                            }
                                        %>


                                    </select>


                                    <div class="vehicle-option-note">

                                        Hanya kenderaan berstatus

                                        <strong>
                                            Aktif
                                        </strong>

                                        dipaparkan dalam senarai ini.

                                    </div>


                                </div>


                                <!-- DATE -->

<div class="form-group">

    <label class="form-label">
        Tarikh Guna Kenderaan
        <span class="required">*</span>
    </label>

    <input
        type="date"
        name="use_date"
        id="useDate"
        class="form-control"
        required
    >

    <span class="form-hint">
        Tarikh mula penggunaan kenderaan.
    </span>

</div>


<!-- START TIME -->

<div class="form-group">

    <label class="form-label">
        Masa Mula
        <span class="required">*</span>
    </label>

    <input
        type="time"
        name="start_time"
        id="startTime"
        class="form-control"
        required
    >

    <span class="form-hint">
        Masa mula penggunaan kenderaan.
    </span>

</div>


<!-- RETURN DATE -->

<div class="form-group">

    <label class="form-label">
        Tarikh Dijangka Pulang
        <span class="required">*</span>
    </label>

    <input
        type="date"
        name="expected_return_date"
        id="returnDate"
        class="form-control"
        required
    >

    <span class="form-hint">
        Pilih tarikh kenderaan dijangka dipulangkan.
    </span>

</div>


<!-- RETURN TIME -->

<div class="form-group">

    <label class="form-label">
        Masa Dijangka Pulang
        <span class="required">*</span>
    </label>

    <input
        type="time"
        name="expected_return_time"
        id="returnTime"
        class="form-control"
        required
    >

    <span class="form-hint">
        Masa kenderaan dijangka dipulangkan.
    </span>

</div>


                                <!-- DRIVER -->

                                <div class="form-group">


                                    <label class="form-label">

                                        Nama Pemandu

                                        <span class="required">
                                            *
                                        </span>

                                    </label>


                                    <input
                                        type="text"
                                        name="driver_name"
                                        class="form-control"
                                        maxlength="150"
                                        placeholder="Masukkan nama pemandu"
                                        required
                                    >


                                </div>


                            </div>


                        </div>


                        <!-- =====================================
                             SECTION 3
                             ===================================== -->

                        <div class="form-section">


                            <div class="section-heading">

                                <span class="section-number">
                                    3
                                </span>

                                <h3>
    Destinasi &amp; Tujuan
</h3>

                            </div>


                            <div class="form-grid">


                                <!-- DESTINATION -->

                                <div class="form-group full">


                                    <label class="form-label">

                                        Tempat Tuju / Destinasi

                                        <span class="required">
                                            *
                                        </span>

                                    </label>


                                    <textarea
                                        name="destination"
                                        class="form-control"
                                        maxlength="1000"
                                        placeholder="Contoh: Pejabat Daerah Kuala Muda, Sungai Petani"
                                        required
                                    ></textarea>


                                </div>


                                <!-- PURPOSE -->

                                <div class="form-group full">


                                    <label class="form-label">

                                        Tujuan / Tugas

                                        <span class="required">
                                            *
                                        </span>

                                    </label>


                                    <textarea
                                        name="purpose"
                                        class="form-control"
                                        maxlength="1500"
                                        placeholder="Nyatakan tujuan penggunaan kenderaan syarikat"
                                        required
                                    ></textarea>


                                </div>


                            </div>


                        </div>


                        <!-- =====================================
                             INFORMATION
                             ===================================== -->

                        <div class="info-box">


                            <div class="info-icon">
                                ⓘ
                            </div>


                            <div class="info-content">

                                Selepas permohonan dihantar,
                                status permohonan akan menjadi

                                <strong>
                                    Menunggu Kelulusan
                                </strong>.

                                Permohonan perlu diluluskan oleh
                                Admin sebelum penggunaan kenderaan
                                dianggap telah disahkan.

                            </div>


                        </div>


                    </div>


                    <!-- =========================================
                         FOOTER
                         ========================================= -->

                    <div class="application-footer">


                        <button
                            type="reset"
                            class="form-btn secondary"
                        >
                            Reset
                        </button>


                        <button
                            type="submit"
                            class="form-btn primary"
                            id="submitVehicleButton"
                            <%= !hasVehicle ? "disabled" : "" %>
                        >
                            Hantar Permohonan
                        </button>


                    </div>


                </form>


            </div>


        </div>


    </main>


</div>


<script>

    /* =========================================================
       DATE SETUP
       ========================================================= */

    const useDate =
        document.getElementById("useDate");

    const returnDate =
        document.getElementById("returnDate");

    const startTime =
        document.getElementById("startTime");

    const returnTime =
        document.getElementById("returnTime");


    /* =========================================================
       TODAY
       ========================================================= */

    function getTodayString() {

        const today = new Date();

        const year =
            today.getFullYear();

        const month =
            String(
                today.getMonth() + 1
            ).padStart(2, "0");

        const day =
            String(
                today.getDate()
            ).padStart(2, "0");

        return year + "-" + month + "-" + day;
    }


    const todayString =
        getTodayString();


    if (useDate) {
        useDate.min = todayString;
    }


    if (returnDate) {
        returnDate.min = todayString;
    }


    /* =========================================================
       WHEN START DATE CHANGES
       ========================================================= */

    if (useDate && returnDate) {

        useDate.addEventListener(
            "change",
            function() {

                /*
                 * Tarikh pulang tidak boleh sebelum
                 * tarikh penggunaan.
                 */
                returnDate.min =
                    useDate.value || todayString;


                /*
                 * Jika belum pilih tarikh pulang,
                 * automatik gunakan tarikh mula.
                 *
                 * Ini memudahkan permohonan satu hari.
                 */
                if (!returnDate.value) {

                    returnDate.value =
                        useDate.value;

                }
                else if (
                    returnDate.value <
                    useDate.value
                ) {

                    returnDate.value =
                        useDate.value;
                }
            }
        );
    }


    /* =========================================================
       FORM VALIDATION
       ========================================================= */

    const vehicleForm =
        document.getElementById(
            "vehicleApplicationForm"
        );


    if (vehicleForm) {

        vehicleForm.addEventListener(
            "submit",
            function(event) {

                const startDateValue =
                    useDate
                    ? useDate.value
                    : "";

                const returnDateValue =
                    returnDate
                    ? returnDate.value
                    : "";

                const startTimeValue =
                    startTime
                    ? startTime.value
                    : "";

                const returnTimeValue =
                    returnTime
                    ? returnTime.value
                    : "";


                /* =============================================
                   CHECK DATE RANGE
                   ============================================= */

                if (
                    startDateValue &&
                    returnDateValue &&
                    returnDateValue < startDateValue
                ) {

                    event.preventDefault();

                    alert(
                        "Tarikh dijangka pulang tidak boleh sebelum tarikh penggunaan."
                    );

                    return;
                }


                /* =============================================
                   CHECK SAME-DAY TIME
                   ============================================= */

                if (
                    startDateValue &&
                    returnDateValue &&
                    startTimeValue &&
                    returnTimeValue &&
                    startDateValue === returnDateValue &&
                    returnTimeValue <= startTimeValue
                ) {

                    event.preventDefault();

                    alert(
                        "Jika penggunaan pada hari yang sama, masa dijangka pulang mestilah selepas masa mula."
                    );

                    return;
                }


                /* =============================================
                   DISABLE BUTTON
                   ============================================= */

                const button =
                    document.getElementById(
                        "submitVehicleButton"
                    );

                if (button) {

                    button.disabled = true;

                    button.textContent =
                        "Menghantar...";
                }
            }
        );
    }

</script>


</body>

</html>