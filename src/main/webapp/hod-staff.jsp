<%@ page contentType="text/html;charset=UTF-8" %>

<%!

    private String h(Object value) {

        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }


    private String departmentName(
            String department) {

        if (
            department == null ||
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

%>


<%

    String role =
        (String) session.getAttribute(
            "userRole"
        );


    String name =
        (String) session.getAttribute(
            "userName"
        );


    if (
        session.getAttribute("userId") == null ||
        role == null ||
        !"HOD".equalsIgnoreCase(role)
    ) {

        response.sendError(403);
        return;
    }


    if (
        name == null ||
        name.isBlank()
    ) {
        name = "Pengguna";
    }


    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String, Object>> staff =
        (java.util.List<java.util.Map<String, Object>>)
        request.getAttribute("staff");


    int totalStaff =
        staff == null
            ? 0
            : staff.size();

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
        Staf Di Bawah Seliaan - PKB
    </title>


    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css?v=20260930-hod-staff"
    >


    <style>

        /* =====================================================
           PAGE
        ===================================================== */

        .hod-staff-page {
            width: 100%;
            max-width: 1400px;
            margin: 0 auto;
        }


        /* =====================================================
           PAGE HEADER
        ===================================================== */

        .hod-staff-header {

            display: flex;

            justify-content: space-between;
            align-items: flex-start;

            gap: 24px;

            margin-bottom: 22px;
        }


        .hod-staff-title {

            min-width: 0;
        }


        .hod-staff-title h1 {

            margin: 0 0 5px;

            color: #172033;

            font-size: 28px;

            /*
             * Sebelum ini 800.
             * 700 lebih hampir dengan standard page lain.
             */
            font-weight: 700;

            line-height: 1.2;

            letter-spacing: -0.4px;
        }


        .hod-staff-title p {

            margin: 0;

            color: #7d8799;

            font-size: 14px;

            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           HEADER ACTIONS
        ===================================================== */

        .hod-header-actions {

            display: flex;

            align-items: center;

            gap: 10px;

            flex-shrink: 0;
        }


        /* =====================================================
           NOTIFICATION BUTTON
        ===================================================== */

        .hod-notification-button {

            position: relative;

            display: flex;

            align-items: center;
            justify-content: center;

            width: 46px;
            height: 46px;

            padding: 0;

            background: #ffffff;

            border: 1px solid #e2e6ed;

            border-radius: 12px;

            color: #718096;

            text-decoration: none;

            box-shadow:
                0 3px 10px
                rgba(31,41,61,.035);

            transition:
                border-color .15s ease,
                background .15s ease,
                transform .15s ease;
        }


        .hod-notification-button:hover {

            background: #fdfafa;

            border-color: #d9b6bc;

            color: #8d1f2d;

            transform: translateY(-1px);
        }


        .hod-notification-button svg {

            width: 20px;
            height: 20px;

            stroke: currentColor;

            stroke-width: 1.8;

            fill: none;

            stroke-linecap: round;
            stroke-linejoin: round;
        }


        /* =====================================================
           USER CHIP
        ===================================================== */

        .hod-user-chip {

            display: flex;

            align-items: center;

            gap: 10px;

            min-height: 46px;

            padding: 5px 13px 5px 7px;

            background: #ffffff;

            border: 1px solid #e2e6ed;

            border-radius: 12px;

            box-shadow:
                0 3px 10px
                rgba(31,41,61,.035);
        }


        .hod-user-avatar {

            display: flex;

            align-items: center;
            justify-content: center;

            width: 34px;
            height: 34px;

            flex-shrink: 0;

            background: #fff7ef;

            border: 1px solid #eed9d0;

            border-radius: 9px;

            color: #8d1f2d;

            font-size: 13px;

            font-weight: 700;
        }


        .hod-user-information {

            display: flex;

            flex-direction: column;

            min-width: 0;
        }


        .hod-user-information strong {

            max-width: 180px;

            overflow: hidden;

            color: #172033;

            font-size: 13px;

            font-weight: 600;

            line-height: 1.3;

            text-overflow: ellipsis;

            white-space: nowrap;
        }


        .hod-user-information span {

            margin-top: 1px;

            color: #929bab;

            font-size: 10px;

            font-weight: 400;

            line-height: 1.3;
        }


        /* =====================================================
           SUMMARY
        ===================================================== */

        .staff-summary-card {

            position: relative;

            width: 100%;

            max-width: 300px;

            margin-bottom: 18px;

            padding: 17px 19px;

            background: #ffffff;

            border: 1px solid #e7e9ef;

            border-radius: 13px;

            box-shadow:
                0 4px 14px
                rgba(27,36,53,.04);

            overflow: hidden;
        }


        .staff-summary-card::before {

            content: "";

            position: absolute;

            left: 0;
            top: 13px;
            bottom: 13px;

            width: 3px;

            background:
                linear-gradient(
                    180deg,
                    #8d1f2d,
                    #d5a12b
                );

            border-radius:
                0 4px 4px 0;
        }


        .staff-summary-card span {

            display: block;

            color: #8b94a4;

            font-size: 11px;

            font-weight: 600;

            text-transform: uppercase;

            letter-spacing: .1px;
        }


        .staff-summary-card strong {

            display: block;

            margin-top: 7px;

            color: #172033;

            font-size: 27px;

            font-weight: 700;

            line-height: 1.15;
        }


        .staff-summary-card small {

            display: block;

            margin-top: 5px;

            color: #8f98a7;

            font-size: 11px;

            font-weight: 400;
        }


        /* =====================================================
           STAFF LIST CARD
        ===================================================== */

        .staff-list-card {

            overflow: hidden;

            background: #ffffff;

            border: 1px solid #e7e9ef;

            border-radius: 16px;

            box-shadow:
                0 7px 23px
                rgba(31,41,61,.045);
        }


        /* =====================================================
           LIST HEADER
        ===================================================== */

        .staff-list-header {

            display: flex;

            justify-content: space-between;
            align-items: center;

            gap: 15px;

            padding: 18px 20px;

            border-bottom:
                1px solid #eceef2;
        }


        .staff-list-header h2 {

            margin: 0 0 4px;

            color: #202a3b;

            font-size: 18px;

            font-weight: 700;

            line-height: 1.3;
        }


        .staff-list-header p {

            margin: 0;

            color: #8992a2;

            font-size: 12px;

            font-weight: 400;

            line-height: 1.5;
        }


        /* =====================================================
           PRINT BUTTON
        ===================================================== */

        .print-button {

            display: inline-flex;

            align-items: center;
            justify-content: center;

            min-height: 40px;

            padding: 8px 14px;

            background:
                linear-gradient(
                    135deg,
                    #8d1f2d,
                    #a72a3b
                );

            border: 1px solid #8d1f2d;

            border-radius: 9px;

            color: #ffffff;

            font-size: 12px;

            font-weight: 600;

            text-decoration: none;

            white-space: nowrap;

            box-shadow:
                0 4px 10px
                rgba(141,31,45,.10);

            transition:
                background .15s ease,
                transform .15s ease,
                box-shadow .15s ease;
        }


        .print-button:hover {

            background:
                linear-gradient(
                    135deg,
                    #701722,
                    #8d1f2d
                );

            transform: translateY(-1px);

            box-shadow:
                0 5px 13px
                rgba(141,31,45,.14);
        }


        /* =====================================================
           SEARCH
        ===================================================== */

        .staff-search-bar {

            padding: 11px 20px;

            background: #fafbfc;

            border-bottom:
                1px solid #eceef2;
        }


        .staff-search-bar input {

            width: 100%;

            max-width: 380px;

            min-height: 40px;

            padding: 0 13px;

            background: #ffffff;

            border: 1px solid #dfe3e9;

            border-radius: 9px;

            color: #344054;

            font-family: inherit;

            font-size: 13px;

            font-weight: 400;

            outline: none;

            transition:
                border-color .15s ease,
                box-shadow .15s ease;
        }


        .staff-search-bar input::placeholder {

            color: #9aa3b2;

            font-weight: 400;
        }


        .staff-search-bar input:focus {

            border-color: #a84754;

            box-shadow:
                0 0 0 3px
                rgba(141,31,45,.08);
        }


        /* =====================================================
           TABLE
        ===================================================== */

        .staff-table-wrap {

            overflow-x: auto;
        }


        .staff-table {

            width: 100%;

            border-collapse: collapse;

            table-layout: auto;
        }


        .staff-table th {

            padding: 13px 15px;

            background: #f9fafc;

            border-bottom:
                1px solid #e7e9ef;

            color: #788396;

            font-size: 12px;

            font-weight: 600;

            text-align: left;

            text-transform: uppercase;

            white-space: nowrap;
        }


        .staff-table td {

            padding: 15px;

            border-bottom:
                1px solid #eef0f4;

            color: #566173;

            font-size: 13px;

            font-weight: 400;

            line-height: 1.5;

            vertical-align: middle;
        }


        .staff-table tbody tr:last-child td {

            border-bottom: none;
        }


        .staff-table tbody tr:hover {

            background: #fdfafa;
        }


        .staff-table strong {

            color: #273144;

            font-size: 14px;

            font-weight: 600;
        }


        /* =====================================================
           DEPARTMENT
        ===================================================== */

        .department-chip {

            display: inline-block;

            padding: 6px 9px;

            background: #f7f4f2;

            border: 1px solid #ebe3de;

            border-radius: 7px;

            color: #655b54;

            font-size: 11px;

            font-weight: 500;

            white-space: nowrap;
        }


        /* =====================================================
           EMPTY STATE
        ===================================================== */

        .empty-state {

            padding: 50px !important;

            text-align: center;

            color: #8992a2 !important;

            font-size: 13px !important;

            font-weight: 400 !important;
        }


        /* =====================================================
           MOBILE
        ===================================================== */

        @media (max-width: 800px) {

            .hod-staff-header {

                align-items: stretch;
            }


            .hod-user-information {

                display: none;
            }


            .hod-user-chip {

                padding-right: 7px;
            }

        }


        @media (max-width: 700px) {

            .hod-staff-header {

                gap: 15px;
            }


            .hod-staff-title h1 {

                font-size: 24px;
            }


            .staff-list-header {

                flex-direction: column;

                align-items: stretch;
            }


            .print-button {

                width: 100%;
            }


            .staff-search-bar input {

                max-width: none;
            }


            .staff-summary-card {

                max-width: none;
            }

        }


        @media (max-width: 520px) {

            .hod-staff-header {

                flex-direction: column;
            }


            .hod-header-actions {

                align-self: flex-end;
            }


            .staff-table {

                min-width: 720px;
            }

        }

    </style>

</head>


<body>


<div class="app">


    <%@ include file="includes/sidebar.jspf" %>


    <main>


        <div class="hod-staff-page">


            <!-- =================================================
                 PAGE HEADER
            ================================================== -->

            <div class="hod-staff-header">


                <div class="hod-staff-title">

                    <h1>
                        Staf Di Bawah Seliaan
                    </h1>

                    <p>
                        Senarai staf yang ditetapkan di bawah seliaan anda
                    </p>

                </div>


                <div class="hod-header-actions">


                    <!-- NOTIFICATION -->

                    <a
                        href="<%= request.getContextPath() %>/notifications"
                        class="hod-notification-button"
                        title="Notifikasi"
                        aria-label="Notifikasi"
                    >

                        <svg
                            viewBox="0 0 24 24"
                            aria-hidden="true"
                        >
                            <path
                                d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                            ></path>

                            <path
                                d="M13.73 21a2 2 0 0 1-3.46 0"
                            ></path>
                        </svg>

                    </a>


                    <!-- USER -->

                    <div class="hod-user-chip">


                        <div class="hod-user-avatar">

                            <%= h(
                                name.substring(
                                    0,
                                    1
                                ).toUpperCase()
                            ) %>

                        </div>


                        <div class="hod-user-information">

                            <strong>
                                <%= h(name) %>
                            </strong>

                            <span>
                                Ketua Unit
                            </span>

                        </div>


                    </div>


                </div>


            </div>



            <!-- =================================================
                 SUMMARY
            ================================================== -->

            <div class="staff-summary-card">

                <span>
                    Jumlah Staf
                </span>

                <strong>
                    <%= totalStaff %>
                </strong>

                <small>
                    Staf di bawah seliaan anda
                </small>

            </div>



            <!-- =================================================
                 STAFF LIST
            ================================================== -->

            <div class="staff-list-card">


                <div class="staff-list-header">


                    <div>

                        <h2>
                            Senarai Staf
                        </h2>

                        <p>
                            Maklumat staf yang ditetapkan kepada Ketua Unit ini.
                        </p>

                    </div>


                    <a
                        href="<%= request.getContextPath() %>/print-staff-list"
                        class="print-button"
                    >
                        Cetak Senarai Staf
                    </a>


                </div>



                <!-- =================================================
                     SEARCH
                ================================================== -->

                <div class="staff-search-bar">

                    <input
                        type="text"
                        id="staffSearch"
                        placeholder="Cari nama, jawatan atau e-mel..."
                        autocomplete="off"
                    >

                </div>



                <!-- =================================================
                     TABLE
                ================================================== -->

                <div class="staff-table-wrap">


                    <table class="staff-table">


                        <thead>

                            <tr>

                                <th>
                                    Bil.
                                </th>

                                <th>
                                    Nama
                                </th>

                                <th>
                                    Jawatan
                                </th>

                                <th>
                                    E-mel
                                </th>

                                <th>
                                    Jabatan
                                </th>

                            </tr>

                        </thead>


                        <tbody id="staffTableBody">


                        <%

                            if (
                                staff != null &&
                                !staff.isEmpty()
                            ) {


                                int number = 1;


                                for (
                                    java.util.Map<String, Object> row :
                                    staff
                                ) {


                                    String department =
                                        row.get("department") == null
                                            ? ""
                                            : row.get("department")
                                                .toString();

                        %>


                            <tr class="staff-row">


                                <td>
                                    <%= number++ %>
                                </td>


                                <td>

                                    <strong>
                                        <%= h(
                                            row.get("name")
                                        ) %>
                                    </strong>

                                </td>


                                <td>

                                    <%= row.get("position") == null
                                        ? "—"
                                        : h(
                                            row.get("position")
                                        )
                                    %>

                                </td>


                                <td>

                                    <%= h(
                                        row.get("email")
                                    ) %>

                                </td>


                                <td>

                                    <span class="department-chip">

                                        <%= h(
                                            departmentName(
                                                department
                                            )
                                        ) %>

                                    </span>

                                </td>


                            </tr>


                        <%

                                }

                            } else {

                        %>


                            <tr id="databaseEmptyRow">

                                <td
                                    colspan="5"
                                    class="empty-state"
                                >
                                    Tiada staf ditetapkan di bawah seliaan anda.
                                </td>

                            </tr>


                        <%

                            }

                        %>


                        </tbody>


                    </table>


                </div>


            </div>


        </div>


    </main>


</div>



<script>

    /* =========================================================
       SEARCH STAFF
    ========================================================= */

    const searchInput =
        document.getElementById(
            "staffSearch"
        );


    if (searchInput) {

        searchInput.addEventListener(
            "input",
            function() {


                const keyword =
                    this.value
                        .toLowerCase()
                        .trim();


                const rows =
                    document.querySelectorAll(
                        ".staff-row"
                    );


                rows.forEach(
                    function(row) {


                        const text =
                            row.textContent
                                .toLowerCase();


                        row.style.display =
                            text.includes(keyword)
                                ? ""
                                : "none";

                    }
                );


                /*
                 * Check sama ada hasil carian masih ada.
                 */

                let visibleCount = 0;


                rows.forEach(
                    function(row) {

                        if (
                            row.style.display
                            !== "none"
                        ) {

                            visibleCount++;

                        }

                    }
                );


                let noResultRow =
                    document.getElementById(
                        "searchNoResult"
                    );


                /*
                 * Hanya paparkan mesej "tiada hasil"
                 * jika database sebenarnya mempunyai staff.
                 */

                if (
                    rows.length > 0 &&
                    visibleCount === 0
                ) {


                    if (!noResultRow) {


                        noResultRow =
                            document.createElement(
                                "tr"
                            );


                        noResultRow.id =
                            "searchNoResult";


                        noResultRow.innerHTML =
                            '<td colspan="5" class="empty-state">'
                            +
                            'Tiada staf sepadan dengan carian anda.'
                            +
                            '</td>';


                        document
                            .getElementById(
                                "staffTableBody"
                            )
                            .appendChild(
                                noResultRow
                            );

                    }


                    noResultRow.style.display =
                        "";


                } else {


                    if (noResultRow) {

                        noResultRow.style.display =
                            "none";

                    }

                }

            }
        );

    }

</script>


</body>

</html>