<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ms">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Borang Permohonan Kenderaan - ${application.application_no}</title>

    <style>

        /* =========================================================
           GLOBAL
           ========================================================= */

        * {
            box-sizing: border-box;
        }

        html,
        body {
            margin: 0;
            padding: 0;
        }

        body {
            padding: 28px;

            background: #f3f5f8;
            color: #111827;

            font-family: Arial, Helvetica, sans-serif;
            font-size: 14px;
        }


        /* =========================================================
           PAGE WRAPPER
           ========================================================= */

        .page-wrapper {
            width: 100%;
            max-width: 1150px;

            margin: 0 auto;
        }


        /* =========================================================
           TOOLBAR
           ========================================================= */

        .screen-toolbar {
            width: 100%;

            margin-bottom: 16px;
            padding: 16px 18px;

            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;

            background: #ffffff;

            border: 1px solid #dfe4ea;
            border-radius: 12px;

            box-shadow:
                0 4px 16px
                rgba(15, 23, 42, 0.04);
        }


        .toolbar-info {
            min-width: 0;
        }


        .toolbar-title {
            margin: 0 0 5px 0;

            color: #111827;

            font-size: 17px;
            line-height: 1.25;
            font-weight: 700;
        }


        .toolbar-description {
            margin: 0;

            color: #7b8798;

            font-size: 12px;
            line-height: 1.4;
        }


        .toolbar-actions {
            display: flex;
            align-items: center;
            gap: 10px;

            flex-shrink: 0;
        }


        /* =========================================================
           BUTTON
           ========================================================= */

        .btn {
            min-height: 42px;

            padding: 0 19px;

            display: inline-flex;
            align-items: center;
            justify-content: center;

            background: #ffffff;
            color: #25364d;

            border: 1px solid #d7dde5;
            border-radius: 8px;

            font-family: Arial, Helvetica, sans-serif;
            font-size: 13px;
            font-weight: 700;

            text-decoration: none;
            white-space: nowrap;

            cursor: pointer;
        }


        .btn:hover {
            background: #f8fafc;
        }


        .btn-print {
            background: #970d20;
            border-color: #970d20;

            color: #ffffff;

            box-shadow:
                0 4px 10px
                rgba(151, 13, 32, 0.16);
        }


        .btn-print:hover {
            background: #7d0b1b;
            border-color: #7d0b1b;
        }


        /* =========================================================
           DOCUMENT
           ========================================================= */

        .print-document {
            width: 100%;

            padding: 30px 34px;

            background: #ffffff;

            border: 1px solid #dfe4ea;
            border-radius: 12px;

            box-shadow:
                0 4px 16px
                rgba(15, 23, 42, 0.04);
        }


        /* =========================================================
           COMPANY HEADER
           ========================================================= */

        .company-header {
            display: flex;
            align-items: center;

            gap: 24px;

            padding:
                0
                4px
                18px
                4px;

            border-bottom:
                3px solid
                #970d20;
        }


        .company-logo {
            display: block;

            width: 140px;
            max-width: 140px;

            height: auto;

            object-fit: contain;

            flex-shrink: 0;
        }


        .company-info {
            min-width: 0;
        }


        .company-name {
            margin: 0 0 5px 0;

            color: #970d20;

            font-size: 24px;
            line-height: 1.2;
            font-weight: 700;
        }


        .company-details {
            margin: 0;

            color: #718096;

            font-size: 12px;
            line-height: 1.4;
        }


        /* =========================================================
           DOCUMENT TITLE
           ========================================================= */

        .document-title {
            padding:
                22px
                0
                18px;

            text-align: center;
        }


        .document-title h1 {
            margin: 0 0 7px 0;

            color: #111827;

            font-size: 18px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;
        }


        .application-number {
            margin: 0;

            color: #64748b;

            font-size: 12px;
            line-height: 1.4;
        }


        .application-number strong {
            color: #970d20;
            font-weight: 700;
        }


        /* =========================================================
           SECTION
           ========================================================= */

        .section {
            width: 100%;

            margin-bottom: 12px;
        }


        .section-title {
            width: 100%;

            padding: 8px 11px;

            background: #970d20;
            color: #ffffff;

            border: 1px solid #970d20;

            font-size: 11px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;
        }


        /* =========================================================
           TABLE
           ========================================================= */

        table {
            width: 100%;

            border-collapse: collapse;
            border-spacing: 0;
        }


        .detail-table {
            table-layout: fixed;
        }


        .detail-table td {
            padding: 8px 11px;

            border:
                1px solid
                #dfe4ea;

            color: #25364d;

            font-size: 11px;
            line-height: 1.35;

            vertical-align: middle;

            overflow-wrap: break-word;
        }


        .detail-table .label {
            width: 28%;

            background: #f6f7f9;

            color: #4d5f76;

            font-weight: 700;
        }


        .detail-table .value {
            width: 72%;

            background: #ffffff;

            color: #111827;

            font-weight: 500;
        }


        /* =========================================================
           APPROVAL
           ========================================================= */

        .approval-box {
            width: 100%;

            margin-top: 14px;

            background: #f5fbf7;

            border: 1px solid #b9dfc8;

            overflow: hidden;
        }


        .approval-header {
            padding: 8px 11px;

            background: #e3f5e9;

            border-bottom:
                1px solid
                #b9dfc8;

            color: #13733d;

            font-size: 11px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;
        }


        .approval-content {
            padding: 11px 12px;
        }


        .approval-grid {
            display: grid;

            grid-template-columns:
                repeat(
                    4,
                    minmax(0, 1fr)
                );

            gap: 14px;
        }


        .approval-item {
            min-width: 0;
        }


        .approval-label {
            display: block;

            margin-bottom: 4px;

            color: #738195;

            font-size: 9px;
            line-height: 1.3;
            font-weight: 700;

            text-transform: uppercase;
        }


        .approval-value {
            color: #111827;

            font-size: 11px;
            line-height: 1.35;
            font-weight: 600;

            overflow-wrap: break-word;
        }


        .status-approved {
            display: inline-flex;
            align-items: center;

            padding: 4px 8px;

            background: #e5f7eb;
            color: #13733d;

            border: 1px solid #b9dfc8;
            border-radius: 999px;

            font-size: 9px;
            line-height: 1.2;
            font-weight: 700;
        }


        .remark-box {
            margin-top: 10px;
            padding-top: 9px;

            border-top:
                1px solid
                #cfe8d8;
        }


        /* =========================================================
           COMPUTER GENERATED NOTE
           ========================================================= */

        .system-note {
            margin-top: 14px;
            padding-top: 10px;

            border-top:
                1px solid
                #dfe4ea;

            color: #7b8798;

            text-align: center;

            font-size: 9px;
            line-height: 1.5;
        }


        .system-note strong {
            color: #4b5563;
        }


        /* =========================================================
           RESPONSIVE
           ========================================================= */

        @media screen and (max-width: 800px) {

            body {
                padding: 14px;
            }


            .screen-toolbar {
                flex-direction: column;
                align-items: stretch;
            }


            .toolbar-actions {
                width: 100%;
            }


            .btn {
                flex: 1;
            }


            .print-document {
                padding: 22px 18px;
            }


            .company-logo {
                width: 110px;
            }


            .company-name {
                font-size: 19px;
            }


            .approval-grid {
                grid-template-columns:
                    1fr
                    1fr;
            }
        }


        /* =========================================================
           PRINT - A4 PORTRAIT
           ========================================================= */

        @page {
            size: A4 portrait;
            margin: 8mm;
        }


        @media print {

            * {
                -webkit-print-color-adjust:
                    exact !important;

                print-color-adjust:
                    exact !important;
            }


            html,
            body {
                margin: 0 !important;
                padding: 0 !important;

                background:
                    #ffffff !important;

                font-family:
                    Arial,
                    Helvetica,
                    sans-serif !important;
            }


            body {
                width: auto !important;
                min-width: 0 !important;

                overflow: visible !important;
            }


            /* =============================================
               HIDE TOOLBAR
               ============================================= */

            .screen-toolbar {
                display: none !important;
            }


            /* =============================================
               WRAPPER
               ============================================= */

            .page-wrapper {
                width: 100% !important;
                max-width: none !important;

                margin: 0 !important;
                padding: 0 !important;
            }


            /* =============================================
               DOCUMENT
               ============================================= */

            .print-document {
                width: 100% !important;
                max-width: none !important;

                margin: 0 !important;
                padding: 0 !important;

                background:
                    #ffffff !important;

                border: none !important;
                border-radius: 0 !important;

                box-shadow: none !important;
            }


            /* =============================================
               HEADER
               ============================================= */

            .company-header {
                display: flex !important;
                align-items: center !important;

                gap: 7mm !important;

                margin: 0 !important;

                padding:
                    0
                    1mm
                    3.5mm
                    1mm !important;

                border-bottom:
                    1.5pt solid
                    #970d20 !important;

                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .company-logo {
                width: 29mm !important;
                max-width: 29mm !important;

                height: auto !important;
            }


            .company-info {
                flex: 1 !important;
            }


            .company-name {
                margin:
                    0
                    0
                    0.8mm
                    0 !important;

                color:
                    #970d20 !important;

                font-size:
                    14.5pt !important;

                line-height:
                    1.1 !important;

                font-weight:
                    700 !important;
            }


            .company-details {
                margin: 0 !important;

                color:
                    #64748b !important;

                font-size:
                    7.5pt !important;

                line-height:
                    1.2 !important;
            }


            /* =============================================
               DOCUMENT TITLE
               ============================================= */

            .document-title {
                margin: 0 !important;

                padding:
                    4mm
                    0
                    3.5mm !important;

                text-align:
                    center !important;

                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .document-title h1 {
                margin:
                    0
                    0
                    1mm
                    0 !important;

                color:
                    #111827 !important;

                font-size:
                    11.5pt !important;

                line-height:
                    1.15 !important;

                font-weight:
                    700 !important;
            }


            .application-number {
                margin: 0 !important;

                color:
                    #64748b !important;

                font-size:
                    7.5pt !important;

                line-height:
                    1.2 !important;
            }


            .application-number strong {
                color:
                    #970d20 !important;
            }


            /* =============================================
               SECTION
               ============================================= */

            .section {
                width: 100% !important;

                margin:
                    0
                    0
                    2.2mm
                    0 !important;

                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .section-title {
                width: 100% !important;

                margin: 0 !important;

                padding:
                    1.8mm
                    2.5mm !important;

                background:
                    #970d20 !important;

                color:
                    #ffffff !important;

                border:
                    none !important;

                font-size:
                    7.5pt !important;

                line-height:
                    1.1 !important;

                font-weight:
                    700 !important;
            }


            /* =============================================
               TABLE
               ============================================= */

            table {
                width: 100% !important;

                border-collapse:
                    collapse !important;
            }


            .detail-table {
                table-layout:
                    fixed !important;
            }


            .detail-table tr {
                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .detail-table td {
                padding:
                    1.7mm
                    2.5mm !important;

                border:
                    0.5pt solid
                    #d7dde5 !important;

                font-size:
                    7.5pt !important;

                line-height:
                    1.15 !important;

                vertical-align:
                    middle !important;
            }


            .detail-table .label {
                width:
                    28% !important;

                background:
                    #f4f6f8 !important;

                color:
                    #34465d !important;

                font-weight:
                    700 !important;
            }


            .detail-table .value {
                width:
                    72% !important;

                background:
                    #ffffff !important;

                color:
                    #111827 !important;
            }


            /* =============================================
               APPROVAL
               ============================================= */

            .approval-box {
                width: 100% !important;

                margin:
                    0.5mm
                    0
                    0
                    0 !important;

                background:
                    #f4fbf6 !important;

                border:
                    0.6pt solid
                    #b9dfc8 !important;

                border-radius:
                    0 !important;

                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .approval-header {
                padding:
                    1.8mm
                    2.5mm !important;

                background:
                    #e3f5e9 !important;

                color:
                    #13733d !important;

                border-bottom:
                    0.5pt solid
                    #b9dfc8 !important;

                font-size:
                    7.5pt !important;

                line-height:
                    1.1 !important;

                font-weight:
                    700 !important;
            }


            .approval-content {
                padding:
                    2mm
                    2.5mm !important;
            }


            .approval-grid {
                display:
                    grid !important;

                grid-template-columns:
                    1.15fr
                    1fr
                    0.8fr
                    1.25fr !important;

                gap:
                    2mm !important;
            }


            .approval-label {
                margin:
                    0
                    0
                    0.6mm
                    0 !important;

                color:
                    #64748b !important;

                font-size:
                    5.8pt !important;

                line-height:
                    1.1 !important;

                font-weight:
                    700 !important;
            }


            .approval-value {
                color:
                    #111827 !important;

                font-size:
                    7pt !important;

                line-height:
                    1.15 !important;

                font-weight:
                    600 !important;
            }


            .status-approved {
                padding:
                    0.6mm
                    1.5mm !important;

                background:
                    #e5f7eb !important;

                color:
                    #13733d !important;

                border:
                    0.5pt solid
                    #b9dfc8 !important;

                font-size:
                    6pt !important;

                line-height:
                    1.1 !important;
            }


            .remark-box {
                margin-top:
                    1.5mm !important;

                padding-top:
                    1.5mm !important;

                border-top:
                    0.5pt solid
                    #cfe8d8 !important;
            }


            /* =============================================
               SYSTEM NOTE
               ============================================= */

            .system-note {
                margin:
                    2mm
                    0
                    0
                    0 !important;

                padding:
                    1.5mm
                    0
                    0
                    0 !important;

                border-top:
                    0.5pt solid
                    #d7dde5 !important;

                color:
                    #64748b !important;

                text-align:
                    center !important;

                font-size:
                    6pt !important;

                line-height:
                    1.25 !important;

                page-break-inside:
                    avoid !important;

                break-inside:
                    avoid !important;
            }


            .system-note strong {
                color:
                    #374151 !important;
            }
        }

    </style>

</head>


<body>


<div class="page-wrapper">


    <!-- =========================================================
         TOOLBAR
         ========================================================= -->

    <div class="screen-toolbar">


        <div class="toolbar-info">

            <h2 class="toolbar-title">
                Borang Permohonan Kenderaan
            </h2>

            <p class="toolbar-description">
                Cetak borang permohonan penggunaan kenderaan syarikat
                atau kembali ke senarai permohonan.
            </p>

        </div>


        <div class="toolbar-actions">


            <!--
                WINDOW.PRINT()
                PRINT PADA TAB YANG SAMA
                TIDAK MEMBUKA TAB BARU
            -->

            <button
                type="button"
                class="btn btn-print"
                onclick="window.print();">

                Cetak Borang

            </button>


            <a
                href="my-vehicle-applications"
                class="btn">

                Kembali

            </a>


        </div>


    </div>



    <!-- =========================================================
         BORANG
         ========================================================= -->

    <div class="print-document">


        <!-- =====================================================
             HEADER
             ===================================================== -->

        <div class="company-header">


            <img
                src="images/logo-pkb.png"
                alt="Permodalan Kedah Berhad"
                class="company-logo">


            <div class="company-info">


                <h2 class="company-name">
                    Permodalan Kedah Berhad
                </h2>


                <p class="company-details">
                    PKB Staff Management System
                </p>


            </div>


        </div>



        <!-- =====================================================
             DOCUMENT TITLE
             ===================================================== -->

        <div class="document-title">


            <h1>
                Borang Permohonan Menggunakan Kenderaan Syarikat
            </h1>


            <p class="application-number">

                No. Permohonan:

                <strong>
                    ${application.application_no}
                </strong>

            </p>


        </div>



        <!-- =====================================================
             A. MAKLUMAT PEMOHON
             ===================================================== -->

        <div class="section">


            <div class="section-title">
                A. Maklumat Pemohon
            </div>


            <table class="detail-table">


                <tr>

                    <td class="label">
                        Nama Pemohon
                    </td>

                    <td class="value">
                        ${application.applicant_name}
                    </td>

                </tr>


                <tr>

                    <td class="label">
                        Jawatan
                    </td>

                    <td class="value">

                        ${empty application.applicant_position
                            ? '-'
                            : application.applicant_position}

                    </td>

                </tr>


                <tr>

                    <td class="label">
                        Jabatan / Unit
                    </td>

                    <td class="value">

                        ${empty application.applicant_department
                            ? '-'
                            : application.applicant_department}

                    </td>

                </tr>


            </table>


        </div>



        <!-- =====================================================
             B. MAKLUMAT KENDERAAN
             ===================================================== -->

        <div class="section">


            <div class="section-title">
                B. Maklumat Kenderaan
            </div>


            <table class="detail-table">


                <tr>

                    <td class="label">
                        No. Pendaftaran
                    </td>

                    <td class="value">
                        ${application.plate_number}
                    </td>

                </tr>


                <tr>

                    <td class="label">
                        Nama / Model Kenderaan
                    </td>

                    <td class="value">
                        ${application.vehicle_name}
                    </td>

                </tr>


            </table>


        </div>



       <!-- =====================================================
     C. MAKLUMAT PENGGUNAAN
     ===================================================== -->

<div class="section">

    <div class="section-title">
        C. Maklumat Penggunaan Kenderaan
    </div>

    <table class="detail-table">

        <tr>

            <td class="label">
                Tarikh Penggunaan
            </td>

            <td class="value">
                ${application.use_date}
            </td>

        </tr>


        <tr>

            <td class="label">
                Masa Bertolak
            </td>

            <td class="value">
                ${application.start_time}
            </td>

        </tr>


        <tr>

            <td class="label">
                Tarikh Dijangka Pulang
            </td>

            <td class="value">
                ${application.expected_return_date}
            </td>

        </tr>


        <tr>

            <td class="label">
                Masa Dijangka Pulang
            </td>

            <td class="value">
                ${application.expected_return_time}
            </td>

        </tr>


        <tr>

            <td class="label">
                Nama Pemandu
            </td>

            <td class="value">
                ${application.driver_name}
            </td>

        </tr>

    </table>

</div>



        <!-- =====================================================
             D. DESTINASI & TUJUAN
             ===================================================== -->

        <div class="section">


            <div class="section-title">
                D. Destinasi &amp; Tujuan
            </div>


            <table class="detail-table">


                <tr>

                    <td class="label">
                        Tempat Tuju / Destinasi
                    </td>

                    <td class="value">
                        ${application.destination}
                    </td>

                </tr>


                <tr>

                    <td class="label">
                        Tujuan / Tugas
                    </td>

                    <td class="value">
                        ${application.purpose}
                    </td>

                </tr>


            </table>


        </div>



        <!-- =====================================================
             E. KELULUSAN
             ===================================================== -->

        <div class="approval-box">


            <div class="approval-header">
                &#10003; Permohonan Diluluskan
            </div>


            <div class="approval-content">


                <div class="approval-grid">


                    <!-- APPROVER -->

                    <div class="approval-item">


                        <span class="approval-label">
                            Diluluskan Oleh
                        </span>


                        <div class="approval-value">

                            ${empty application.approver_name
                                ? '-'
                                : application.approver_name}

                        </div>


                    </div>



                    <!-- POSITION -->

                    <div class="approval-item">


                        <span class="approval-label">
                            Jawatan
                        </span>


                        <div class="approval-value">

                            ${empty application.approver_position
                                ? '-'
                                : application.approver_position}

                        </div>


                    </div>



                    <!-- STATUS -->

                    <div class="approval-item">


                        <span class="approval-label">
                            Status
                        </span>


                        <div>

                            <span class="status-approved">
                                DILULUSKAN
                            </span>

                        </div>


                    </div>



                    <!-- DATE -->

                    <div class="approval-item">


                        <span class="approval-label">
                            Tarikh / Masa Kelulusan
                        </span>


                        <div class="approval-value">

                            ${empty application.approved_at
                                ? '-'
                                : application.approved_at}

                        </div>


                    </div>


                </div>



                <!-- REMARK -->

                <div class="remark-box">


                    <span class="approval-label">
                        Catatan Kelulusan
                    </span>


                    <div class="approval-value">

                        ${empty application.approval_remark
                            ? 'Tiada catatan.'
                            : application.approval_remark}

                    </div>


                </div>


            </div>


        </div>



        <!-- =====================================================
             COMPUTER GENERATED NOTE
             ===================================================== -->

        <div class="system-note">


            Borang ini dijana secara automatik melalui
            <strong>
                Sistem Pengurusan Staf Permodalan Kedah Berhad
            </strong>.


            <br>


            Dokumen ini adalah cetakan komputer dan
            <strong>
                tidak memerlukan tandatangan.
            </strong>


            <br>


            No. Permohonan:

            <strong>
                ${application.application_no}
            </strong>


        </div>


    </div>


</div>


</body>

</html>