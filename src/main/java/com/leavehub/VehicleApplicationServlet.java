package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/vehicle-apply")
public class VehicleApplicationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // PAPARKAN BORANG PERMOHONAN KENDERAAN
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (session == null
                || session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // LOAD ACTIVE VEHICLES
        // =====================================================

        List<Map<String, Object>> vehicles =
                new ArrayList<>();


        String vehicleSql = """
            SELECT
                id,
                plate_number,
                vehicle_name,
                status
            FROM vehicles
            WHERE status = 'ACTIVE'
            ORDER BY plate_number ASC
        """;


        try (
                Connection con =
                        DBConnection.getConnection();

                PreparedStatement ps =
                        con.prepareStatement(vehicleSql);

                ResultSet rs =
                        ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> vehicle =
                        new HashMap<>();


                vehicle.put(
                        "id",
                        rs.getInt("id")
                );

                vehicle.put(
                        "plate_number",
                        rs.getString("plate_number")
                );

                vehicle.put(
                        "vehicle_name",
                        rs.getString("vehicle_name")
                );

                vehicle.put(
                        "status",
                        rs.getString("status")
                );


                vehicles.add(vehicle);
            }

        } catch (SQLException e) {

            throw new ServletException(
                    "Tidak dapat memuatkan senarai kenderaan.",
                    e
            );
        }


        // =====================================================
        // LOAD USER INFORMATION
        // =====================================================

        int userId =
                ((Number) session.getAttribute("userId"))
                        .intValue();


        Map<String, Object> applicant =
                new HashMap<>();


        String userSql = """
            SELECT
                id,
                name
            FROM users
            WHERE id = ?
            LIMIT 1
        """;


        try (
                Connection con =
                        DBConnection.getConnection();

                PreparedStatement ps =
                        con.prepareStatement(userSql)
        ) {

            ps.setInt(
                    1,
                    userId
            );


            try (
                    ResultSet rs =
                            ps.executeQuery()
            ) {

                if (rs.next()) {

                    applicant.put(
                            "id",
                            rs.getInt("id")
                    );

                    applicant.put(
                            "name",
                            rs.getString("name")
                    );
                }
            }

        } catch (SQLException e) {

            /*
             * Fallback kepada session jika query users gagal.
             */

            applicant.put(
                    "id",
                    userId
            );

            applicant.put(
                    "name",
                    session.getAttribute("userName")
            );
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
                "vehicles",
                vehicles
        );

        request.setAttribute(
                "applicant",
                applicant
        );

        request.setAttribute(
                "pageTitle",
                "Permohonan Kenderaan"
        );


        request.getRequestDispatcher(
                "/vehicle-apply.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // POST
    // HANTAR PERMOHONAN KENDERAAN
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");


        HttpSession session =
                request.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (session == null
                || session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // USER ID
        // =====================================================

        int userId =
                ((Number) session.getAttribute("userId"))
                        .intValue();


        // =====================================================
        // GET FORM DATA
        // =====================================================

        String vehicleIdValue =
                clean(
                        request.getParameter(
                                "vehicle_id"
                        )
                );


        String useDateValue =
                clean(
                        request.getParameter(
                                "use_date"
                        )
                );


        String startTimeValue =
                clean(
                        request.getParameter(
                                "start_time"
                        )
                );


        String expectedReturnDateValue =
                clean(
                        request.getParameter(
                                "expected_return_date"
                        )
                );


        String expectedReturnTimeValue =
                clean(
                        request.getParameter(
                                "expected_return_time"
                        )
                );


        String driverName =
                clean(
                        request.getParameter(
                                "driver_name"
                        )
                );


        String destination =
                clean(
                        request.getParameter(
                                "destination"
                        )
                );


        String purpose =
                clean(
                        request.getParameter(
                                "purpose"
                        )
                );


        // =====================================================
        // REQUIRED VALIDATION
        // =====================================================

        if (vehicleIdValue.isEmpty()
                || useDateValue.isEmpty()
                || startTimeValue.isEmpty()
                || expectedReturnDateValue.isEmpty()
                || expectedReturnTimeValue.isEmpty()
                || driverName.isEmpty()
                || destination.isEmpty()
                || purpose.isEmpty()) {

            redirectError(
                    request,
                    response,
                    "Sila lengkapkan semua maklumat permohonan."
            );

            return;
        }


        // =====================================================
        // PARSE VEHICLE ID
        // =====================================================

        int vehicleId;

        try {

            vehicleId =
                    Integer.parseInt(
                            vehicleIdValue
                    );

        } catch (NumberFormatException e) {

            redirectError(
                    request,
                    response,
                    "Kenderaan yang dipilih tidak sah."
            );

            return;
        }


        // =====================================================
        // PARSE DATE / TIME
        // =====================================================

        LocalDate useDate;
        LocalTime startTime;

        LocalDate expectedReturnDate;
        LocalTime expectedReturnTime;


        try {

            useDate =
                    LocalDate.parse(
                            useDateValue
                    );


            startTime =
                    LocalTime.parse(
                            startTimeValue
                    );


            expectedReturnDate =
                    LocalDate.parse(
                            expectedReturnDateValue
                    );


            expectedReturnTime =
                    LocalTime.parse(
                            expectedReturnTimeValue
                    );

        } catch (Exception e) {

            redirectError(
                    request,
                    response,
                    "Tarikh atau masa yang dimasukkan tidak sah."
            );

            return;
        }


        // =====================================================
        // DATE VALIDATION
        // =====================================================

        if (useDate.isBefore(
                LocalDate.now()
        )) {

            redirectError(
                    request,
                    response,
                    "Tarikh penggunaan tidak boleh sebelum tarikh hari ini."
            );

            return;
        }


        // =====================================================
        // RETURN DATE VALIDATION
        // =====================================================

        if (expectedReturnDate.isBefore(
                useDate
        )) {

            redirectError(
                    request,
                    response,
                    "Tarikh dijangka pulang tidak boleh sebelum tarikh penggunaan."
            );

            return;
        }


        // =====================================================
        // CREATE COMPLETE DATE/TIME
        // =====================================================

        LocalDateTime requestedStart =
                LocalDateTime.of(
                        useDate,
                        startTime
                );


        LocalDateTime requestedEnd =
                LocalDateTime.of(
                        expectedReturnDate,
                        expectedReturnTime
                );


        // =====================================================
        // COMPLETE DATE/TIME VALIDATION
        // =====================================================

        if (!requestedEnd.isAfter(
                requestedStart
        )) {

            redirectError(
                    request,
                    response,
                    "Tarikh dan masa dijangka pulang mestilah selepas tarikh dan masa mula."
            );

            return;
        }


        // =====================================================
        // OPEN DATABASE
        // =====================================================

        try (
                Connection con =
                        DBConnection.getConnection()
        ) {


            // =================================================
            // 1. CHECK VEHICLE EXISTS & ACTIVE
            // =================================================

            String checkVehicleSql = """
                SELECT
                    id,
                    plate_number,
                    vehicle_name,
                    status
                FROM vehicles
                WHERE id = ?
                  AND status = 'ACTIVE'
                LIMIT 1
            """;


            try (
                    PreparedStatement ps =
                            con.prepareStatement(
                                    checkVehicleSql
                            )
            ) {

                ps.setInt(
                        1,
                        vehicleId
                );


                try (
                        ResultSet rs =
                                ps.executeQuery()
                ) {

                    if (!rs.next()) {

                        redirectError(
                                request,
                                response,
                                "Kenderaan yang dipilih tidak tersedia."
                        );

                        return;
                    }
                }
            }


            // =================================================
            // 2. CHECK BOOKING CONFLICT
            //
            // Formula overlap:
            //
            // EXISTING START < NEW END
            // DAN
            // EXISTING EFFECTIVE END > NEW START
            //
            // EFFECTIVE END:
            //
            // Jika actual_return_date + actual_return_time ada:
            //      guna ACTUAL RETURN.
            //
            // Jika tiada:
            //      guna EXPECTED RETURN.
            //
            // Ini membolehkan kenderaan ditempah semula
            // selepas ia dipulangkan lebih awal.
            //
            // Hanya APPROVED booking block booking baru.
            // =================================================

            String conflictSql = """
                SELECT
                    va.id,
                    va.application_no,

                    va.use_date,
                    va.start_time,

                    va.expected_return_date,
                    va.expected_return_time,

                    va.actual_return_date,
                    va.actual_return_time

                FROM vehicle_applications va

                WHERE va.vehicle_id = ?
                  AND va.status = 'APPROVED'

                  AND TIMESTAMP(
                        va.use_date,
                        va.start_time
                      ) < ?

                  AND (
                        CASE

                            WHEN va.actual_return_date IS NOT NULL
                             AND va.actual_return_time IS NOT NULL

                            THEN TIMESTAMP(
                                va.actual_return_date,
                                va.actual_return_time
                            )

                            ELSE TIMESTAMP(
                                COALESCE(
                                    va.expected_return_date,
                                    va.use_date
                                ),
                                va.expected_return_time
                            )

                        END
                      ) > ?

                LIMIT 1
            """;


            try (
                    PreparedStatement ps =
                            con.prepareStatement(
                                    conflictSql
                            )
            ) {

                ps.setInt(
                        1,
                        vehicleId
                );


                // =============================================
                // NEW BOOKING END
                // =============================================

                ps.setTimestamp(
                        2,
                        Timestamp.valueOf(
                                requestedEnd
                        )
                );


                // =============================================
                // NEW BOOKING START
                // =============================================

                ps.setTimestamp(
                        3,
                        Timestamp.valueOf(
                                requestedStart
                        )
                );


                try (
                        ResultSet rs =
                                ps.executeQuery()
                ) {

                    if (rs.next()) {

                        redirectError(
                                request,
                                response,
                                "Kenderaan ini telah ditempah pada waktu yang dipilih. "
                                        + "Sila pilih waktu atau kenderaan lain."
                        );

                        return;
                    }
                }
            }


            // =================================================
            // 3. GENERATE APPLICATION NUMBER
            // =================================================

            String applicationNo =
                    generateApplicationNo(
                            con
                    );


            // =================================================
            // 4. INSERT APPLICATION
            // =================================================

            String insertSql = """
                INSERT INTO vehicle_applications
                (
                    application_no,
                    user_id,
                    vehicle_id,

                    use_date,
                    start_time,

                    expected_return_date,
                    expected_return_time,

                    driver_name,
                    destination,
                    purpose,

                    status
                )

                VALUES
                (
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    'PENDING'
                )
            """;


            try (
                    PreparedStatement ps =
                            con.prepareStatement(
                                    insertSql
                            )
            ) {

                ps.setString(
                        1,
                        applicationNo
                );


                ps.setInt(
                        2,
                        userId
                );


                ps.setInt(
                        3,
                        vehicleId
                );


                ps.setDate(
                        4,
                        Date.valueOf(
                                useDate
                        )
                );


                ps.setTime(
                        5,
                        Time.valueOf(
                                startTime
                        )
                );


                ps.setDate(
                        6,
                        Date.valueOf(
                                expectedReturnDate
                        )
                );


                ps.setTime(
                        7,
                        Time.valueOf(
                                expectedReturnTime
                        )
                );


                ps.setString(
                        8,
                        driverName
                );


                ps.setString(
                        9,
                        destination
                );


                ps.setString(
                        10,
                        purpose
                );


                ps.executeUpdate();
            }


            // =================================================
            // SUCCESS
            // =================================================

            response.sendRedirect(
                    request.getContextPath()
                            + "/vehicle-apply?success="
                            + encode(
                                    "Permohonan kenderaan berjaya dihantar. "
                                            + "No. Permohonan: "
                                            + applicationNo
                            )
            );


        } catch (SQLException e) {

            e.printStackTrace();


            redirectError(
                    request,
                    response,
                    "Permohonan kenderaan tidak dapat dihantar."
            );
        }
    }


    // =========================================================
    // GENERATE APPLICATION NUMBER
    //
    // Example:
    // PKB-KEND-20261006-0001
    // =========================================================

    private String generateApplicationNo(
            Connection con)
            throws SQLException {


        String datePart =
                LocalDate.now().format(
                        DateTimeFormatter.ofPattern(
                                "yyyyMMdd"
                        )
                );


        String prefix =
                "PKB-KEND-"
                        + datePart
                        + "-";


        String sql = """
            SELECT application_no

            FROM vehicle_applications

            WHERE application_no LIKE ?

            ORDER BY application_no DESC

            LIMIT 1
        """;


        int nextNumber = 1;


        try (
                PreparedStatement ps =
                        con.prepareStatement(sql)
        ) {

            ps.setString(
                    1,
                    prefix + "%"
            );


            try (
                    ResultSet rs =
                            ps.executeQuery()
            ) {

                if (rs.next()) {

                    String lastApplicationNo =
                            rs.getString(
                                    "application_no"
                            );


                    if (lastApplicationNo != null
                            && lastApplicationNo.length()
                            >= prefix.length() + 4) {


                        String sequence =
                                lastApplicationNo.substring(
                                        prefix.length()
                                );


                        try {

                            nextNumber =
                                    Integer.parseInt(
                                            sequence
                                    ) + 1;

                        } catch (NumberFormatException ignored) {

                            nextNumber = 1;
                        }
                    }
                }
            }
        }


        return prefix
                + String.format(
                        "%04d",
                        nextNumber
                );
    }


    // =========================================================
    // CLEAN STRING
    // =========================================================

    private String clean(
            String value) {

        if (value == null) {
            return "";
        }

        return value.trim();
    }


    // =========================================================
    // REDIRECT ERROR
    // =========================================================

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws IOException {


        response.sendRedirect(
                request.getContextPath()
                        + "/vehicle-apply?error="
                        + encode(message)
        );
    }


    // =========================================================
    // URL ENCODE
    // =========================================================

    private String encode(
            String value) {

        return URLEncoder.encode(
                value,
                StandardCharsets.UTF_8
        );
    }
}