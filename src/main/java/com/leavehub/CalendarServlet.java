package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // 1. CHECK LOGIN
        // =====================================================

        HttpSession session =
                request.getSession(false);


        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        int userId;


        try {

            userId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );

        } catch (Exception e) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // 2. GET ROLE
        // =====================================================

        Object roleObject =
                session.getAttribute(
                    "userRole"
                );


        if (roleObject == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        String userRole =
                roleObject
                    .toString()
                    .trim()
                    .toUpperCase();


        // =====================================================
        // 3. ROLE CHECK
        // =====================================================

        boolean isHR =
                "HR".equals(
                    userRole
                );


        boolean isHOD =
                "HOD".equals(
                    userRole
                );


        boolean isStaff =
                "STAFF".equals(
                    userRole
                );


        boolean isManagement =
                "MANAGEMENT".equals(
                    userRole
                );


        // =====================================================
        // 4. INVALID ROLE
        // =====================================================

        if (
            !isHR &&
            !isHOD &&
            !isStaff &&
            !isManagement
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        // =====================================================
        // 5. DATA LISTS
        // =====================================================

        List<Map<String, Object>> applications =
                new ArrayList<>();


        List<Map<String, Object>> publicHolidays =
                new ArrayList<>();


        // =====================================================
        // 6. BASE SELECT
        // =====================================================

        String selectSQL = """

            SELECT
                l.id,
                l.application_no,
                l.user_id,

                u.name AS staff_name,
                u.email AS staff_email,
                u.department,
                u.hod_id,

                l.leave_type,
                l.other_leave_type,
                l.start_date,
                l.end_date,
                l.duration,
                l.reason,
                l.status

            FROM leave_applications l

            JOIN users u
                ON l.user_id = u.id

        """;


        // =====================================================
        // 7. SQL BY ROLE
        //
        // HR:
        //   Semua jadual cuti staf
        //
        // MANAGEMENT:
        //   Semua jadual cuti staf
        //
        // HOD:
        //   1. Permohonan sendiri
        //   2. Staf di bawah seliaan Ketua Unit
        //
        // STAFF:
        //   Permohonan sendiri
        //
        // REJECTED dan CANCELLED tidak dipaparkan.
        // =====================================================

        String sql;


        // =====================================================
        // HR / MANAGEMENT
        // =====================================================

        if (
            isHR ||
            isManagement
        ) {

            sql = selectSQL + """

                WHERE l.status IN
                (
                    'PENDING_HEAD',
                    'PENDING_ADMIN',
                    'PENDING_MANAGEMENT',
                    'PENDING',
                    'APPROVED'
                )

                ORDER BY
                    l.start_date ASC,
                    u.name ASC

            """;


        // =====================================================
        // HOD
        //
        // IMPORTANT:
        //
        // l.user_id = ?
        //     -> permohonan HOD sendiri
        //
        // u.hod_id = ?
        //     -> permohonan staf bawah seliaan HOD
        //
        // =====================================================

        } else if (isHOD) {

            sql = selectSQL + """

                WHERE
                (
                    l.user_id = ?
                    OR
                    u.hod_id = ?
                )

                AND l.status IN
                (
                    'PENDING_HEAD',
                    'PENDING_ADMIN',
                    'PENDING_MANAGEMENT',
                    'PENDING',
                    'APPROVED'
                )

                ORDER BY
                    l.start_date ASC,
                    u.name ASC

            """;


        // =====================================================
        // STAFF
        // =====================================================

        } else {

            sql = selectSQL + """

                WHERE l.user_id = ?

                AND l.status IN
                (
                    'PENDING_HEAD',
                    'PENDING_ADMIN',
                    'PENDING_MANAGEMENT',
                    'PENDING',
                    'APPROVED'
                )

                ORDER BY
                    l.start_date ASC

            """;
        }


        // =====================================================
        // 8. DATABASE
        // =====================================================

        try (
            Connection con =
                    DBConnection.getConnection()
        ) {


            // =================================================
            // LOAD LEAVE APPLICATIONS
            // =================================================

            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            sql
                        )
            ) {


                // =============================================
                // HOD
                //
                // TWO parameters:
                //
                // 1 = HOD's own user ID
                // 2 = staff.hod_id
                // =============================================

                if (isHOD) {

                    ps.setInt(
                        1,
                        userId
                    );


                    ps.setInt(
                        2,
                        userId
                    );


                // =============================================
                // STAFF
                //
                // ONE parameter:
                //
                // Own application only
                // =============================================

                } else if (isStaff) {

                    ps.setInt(
                        1,
                        userId
                    );
                }


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {


                    while (
                        rs.next()
                    ) {


                        Map<String, Object> row =
                                new HashMap<>();


                        // =====================================
                        // APPLICATION ID
                        // =====================================

                        row.put(
                            "id",
                            rs.getInt(
                                "id"
                            )
                        );


                        // =====================================
                        // APPLICATION NUMBER
                        // =====================================

                        String applicationNo =
                                rs.getString(
                                    "application_no"
                                );


                        if (
                            applicationNo == null ||
                            applicationNo.isBlank()
                        ) {

                            applicationNo =
                                    "PKB-CUTI-"
                                    +
                                    rs.getInt(
                                        "id"
                                    );
                        }


                        row.put(
                            "application_no",
                            applicationNo
                        );


                        // =====================================
                        // USER ID
                        // =====================================

                        int applicationUserId =
                                rs.getInt(
                                    "user_id"
                                );


                        row.put(
                            "user_id",
                            applicationUserId
                        );


                        // =====================================
                        // OWN APPLICATION
                        //
                        // Useful for calendar.jsp if later we
                        // want to distinguish HOD's own leave.
                        // =====================================

                        row.put(
                            "own_application",
                            applicationUserId == userId
                        );


                        // =====================================
                        // STAFF NAME
                        // =====================================

                        row.put(
                            "staff_name",
                            rs.getString(
                                "staff_name"
                            )
                        );


                        // =====================================
                        // STAFF EMAIL
                        // =====================================

                        row.put(
                            "staff_email",
                            rs.getString(
                                "staff_email"
                            )
                        );


                        // =====================================
                        // DEPARTMENT
                        // =====================================

                        row.put(
                            "department",
                            rs.getString(
                                "department"
                            )
                        );


                        // =====================================
                        // HOD ID
                        // =====================================

                        int hodId =
                                rs.getInt(
                                    "hod_id"
                                );


                        if (
                            rs.wasNull()
                        ) {

                            row.put(
                                "hod_id",
                                null
                            );

                        } else {

                            row.put(
                                "hod_id",
                                hodId
                            );
                        }


                        // =====================================
                        // LEAVE TYPE
                        // =====================================

                        row.put(
                            "leave_type",
                            rs.getString(
                                "leave_type"
                            )
                        );


                        // =====================================
                        // OTHER LEAVE TYPE
                        // =====================================

                        row.put(
                            "other_leave_type",
                            rs.getString(
                                "other_leave_type"
                            )
                        );


                        // =====================================
                        // START DATE
                        // =====================================

                        row.put(
                            "start_date",
                            rs.getDate(
                                "start_date"
                            )
                        );


                        // =====================================
                        // END DATE
                        // =====================================

                        row.put(
                            "end_date",
                            rs.getDate(
                                "end_date"
                            )
                        );


                        // =====================================
                        // DURATION
                        // =====================================

                        row.put(
                            "duration",
                            rs.getInt(
                                "duration"
                            )
                        );


                        // =====================================
                        // REASON
                        // =====================================

                        row.put(
                            "reason",
                            rs.getString(
                                "reason"
                            )
                        );


                        // =====================================
                        // STATUS
                        // =====================================

                        String status =
                                rs.getString(
                                    "status"
                                );


                        row.put(
                            "status",
                            status
                        );


                        // =====================================
                        // STATUS LABEL
                        //
                        // Useful if calendar.jsp needs it.
                        // =====================================

                        row.put(
                            "status_label",
                            getStatusLabel(
                                status
                            )
                        );


                        // =====================================
                        // ADD
                        // =====================================

                        applications.add(
                            row
                        );
                    }
                }
            }


            // =================================================
            // LOAD ACTIVE PUBLIC HOLIDAYS
            //
            // Semua role melihat cuti umum yang sama.
            // =================================================

            publicHolidays =
                    HolidayUtil
                        .getActivePublicHolidays(
                            con
                        );


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan kalendar cuti.",
                e
            );
        }


        // =====================================================
        // 9. SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "applications",
            applications
        );


        request.setAttribute(
            "publicHolidays",
            publicHolidays
        );


        request.setAttribute(
            "isHR",
            isHR
        );


        request.setAttribute(
            "isHOD",
            isHOD
        );


        request.setAttribute(
            "isStaff",
            isStaff
        );


        request.setAttribute(
            "isManagement",
            isManagement
        );


        request.setAttribute(
            "currentUserId",
            userId
        );


        // =====================================================
        // 10. PAGE TITLE
        // =====================================================

        request.setAttribute(
            "pageTitle",
            "Kalendar Cuti"
        );


        // =====================================================
        // 11. PAGE DESCRIPTION
        // =====================================================

        if (isManagement) {

            request.setAttribute(
                "pageDescription",
                "Lihat dan pantau jadual cuti semua staf serta cuti umum"
            );


        } else if (isHR) {

            request.setAttribute(
                "pageDescription",
                "Lihat dan pantau jadual cuti semua staf serta cuti umum"
            );


        } else if (isHOD) {

            request.setAttribute(
                "pageDescription",
                "Lihat jadual cuti anda dan staf di bawah seliaan serta cuti umum"
            );


        } else {

            request.setAttribute(
                "pageDescription",
                "Lihat jadual cuti anda serta cuti umum"
            );
        }


        // =====================================================
        // 12. OPEN CALENDAR JSP
        // =====================================================

        request
            .getRequestDispatcher(
                "/calendar.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // STATUS LABEL
    // =========================================================

    private String getStatusLabel(
            String status) {


        if (status == null) {

            return "—";
        }


        String normalized =
                status
                    .trim()
                    .toUpperCase();


        switch (normalized) {


            case "APPROVED":

                return "Diluluskan";


            case "PENDING_MANAGEMENT":

                return "Dalam Proses";


            case "PENDING_HEAD":

                return "Dalam Proses";


            case "PENDING_ADMIN":

                return "Dalam Proses";


            case "PENDING":

                return "Dalam Proses";


            case "REJECTED":

                return "Tidak Diluluskan";


            case "CANCELLED":

                return "Dibatalkan";


            default:

                return normalized;
        }
    }
}