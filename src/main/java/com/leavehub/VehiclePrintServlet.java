package com.leavehub;

import jakarta.servlet.ServletException;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

import java.time.format.DateTimeFormatter;
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

import java.util.HashMap;
import java.util.Map;

@WebServlet("/vehicle-print")
public class VehiclePrintServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =========================================================
        // 1. CHECK LOGIN
        // =========================================================

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =========================================================
        // 2. CURRENT USER
        // =========================================================

        int currentUserId =
            ((Number) session.getAttribute("userId"))
            .intValue();


        /*
         * Sistem anda nampaknya pernah menggunakan kedua-dua:
         *
         * session.setAttribute("role", ...)
         * session.setAttribute("userRole", ...)
         *
         * Jadi kita support kedua-duanya supaya tidak conflict.
         */

        Object roleObject =
            session.getAttribute("role");

        if (roleObject == null) {
            roleObject =
                session.getAttribute("userRole");
        }

        String role =
            roleObject == null
            ? ""
            : String.valueOf(roleObject).trim();


        // =========================================================
        // 3. GET APPLICATION ID
        // =========================================================

        String idParam =
            request.getParameter("id");

        if (idParam == null ||
            idParam.trim().isEmpty()) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "ID permohonan tidak sah."
            );

            return;
        }


        int applicationId;

        try {

            applicationId =
                Integer.parseInt(
                    idParam.trim()
                );

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "ID permohonan tidak sah."
            );

            return;
        }


        // =========================================================
        // 4. SQL
        // =========================================================

        String sql = """

        	    SELECT

        	        va.id,
        	        va.application_no,
        	        va.user_id,
        	        va.vehicle_id,

        	        va.use_date,
        	        va.start_time,
        	        va.expected_return_date,
        	        va.expected_return_time,

        	        va.driver_name,
        	        va.destination,
        	        va.purpose,

        	        va.status,
        	        va.approval_remark,

        	        va.approved_by,
        	        va.approved_at,

        	        va.created_at,

        	        u.name AS applicant_name,
        	        u.position AS applicant_position,
        	        u.department AS applicant_department,

        	        v.plate_number,
        	        v.vehicle_name,

        	        approver.name AS approver_name,
        	        approver.position AS approver_position

        	    FROM vehicle_applications va

        	    INNER JOIN users u
        	        ON va.user_id = u.id

        	    INNER JOIN vehicles v
        	        ON va.vehicle_id = v.id

        	    LEFT JOIN users approver
        	        ON va.approved_by = approver.id

        	    WHERE va.id = ?

        	""";


        Map<String, Object> application = null;


        // =========================================================
        // 5. LOAD APPLICATION
        // =========================================================

        try (
            Connection con =
                DBConnection.getConnection();

            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                applicationId
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (rs.next()) {

                    application =
                        new HashMap<>();


                    application.put(
                        "id",
                        rs.getInt("id")
                    );

                    application.put(
                        "application_no",
                        rs.getString(
                            "application_no"
                        )
                    );

                    application.put(
                        "user_id",
                        rs.getInt(
                            "user_id"
                        )
                    );

                    application.put(
                        "vehicle_id",
                        rs.getInt(
                            "vehicle_id"
                        )
                    );


                 // =====================================================
                 // FORMAT TARIKH & MASA UNTUK CETAKAN
                 // =====================================================

                 DateTimeFormatter dateFormatter =
                     DateTimeFormatter.ofPattern(
                         "dd/MM/yyyy"
                     );

                 DateTimeFormatter timeFormatter =
                     DateTimeFormatter.ofPattern(
                         "HH:mm"
                     );


                 Date useDate =
                     rs.getDate(
                         "use_date"
                     );

                 Time startTime =
                     rs.getTime(
                         "start_time"
                     );

                 Date expectedReturnDate =
                     rs.getDate(
                         "expected_return_date"
                     );

                 Time expectedReturnTime =
                     rs.getTime(
                         "expected_return_time"
                     );


                 // TARIKH PENGGUNAAN

                 application.put(
                     "use_date",
                     useDate == null
                         ? "-"
                         : useDate
                             .toLocalDate()
                             .format(dateFormatter)
                 );


                 // MASA BERTOLAK

                 application.put(
                     "start_time",
                     startTime == null
                         ? "-"
                         : startTime
                             .toLocalTime()
                             .format(timeFormatter)
                 );


                 // TARIKH DIJANGKA PULANG

                 application.put(
                     "expected_return_date",
                     expectedReturnDate == null
                         ? "-"
                         : expectedReturnDate
                             .toLocalDate()
                             .format(dateFormatter)
                 );


                 // MASA DIJANGKA PULANG

                 application.put(
                     "expected_return_time",
                     expectedReturnTime == null
                         ? "-"
                         : expectedReturnTime
                             .toLocalTime()
                             .format(timeFormatter)
                 );


                    application.put(
                        "driver_name",
                        rs.getString(
                            "driver_name"
                        )
                    );

                    application.put(
                        "destination",
                        rs.getString(
                            "destination"
                        )
                    );

                    application.put(
                        "purpose",
                        rs.getString(
                            "purpose"
                        )
                    );


                    application.put(
                        "status",
                        rs.getString(
                            "status"
                        )
                    );

                    application.put(
                        "approval_remark",
                        rs.getString(
                            "approval_remark"
                        )
                    );


                    application.put(
                        "approved_by",
                        rs.getObject(
                            "approved_by"
                        )
                    );

                    Timestamp approvedAt =
                    	    rs.getTimestamp(
                    	        "approved_at"
                    	    );

                    	application.put(
                    	    "approved_at",
                    	    approvedAt == null
                    	        ? "-"
                    	        : approvedAt
                    	            .toLocalDateTime()
                    	            .format(
                    	                DateTimeFormatter.ofPattern(
                    	                    "dd/MM/yyyy HH:mm"
                    	                )
                    	            )
                    	);

                    application.put(
                        "created_at",
                        rs.getTimestamp(
                            "created_at"
                        )
                    );


                    application.put(
                        "applicant_name",
                        rs.getString(
                            "applicant_name"
                        )
                    );

                    application.put(
                        "applicant_position",
                        rs.getString(
                            "applicant_position"
                        )
                    );

                    application.put(
                        "applicant_department",
                        rs.getString(
                            "applicant_department"
                        )
                    );


                    application.put(
                        "plate_number",
                        rs.getString(
                            "plate_number"
                        )
                    );

                    application.put(
                        "vehicle_name",
                        rs.getString(
                            "vehicle_name"
                        )
                    );


                    application.put(
                        "approver_name",
                        rs.getString(
                            "approver_name"
                        )
                    );

                    application.put(
                        "approver_position",
                        rs.getString(
                            "approver_position"
                        )
                    );
                }
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan borang permohonan kenderaan.",
                e
            );
        }


        // =========================================================
        // 6. APPLICATION NOT FOUND
        // =========================================================

        if (application == null) {

            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Permohonan kenderaan tidak ditemui."
            );

            return;
        }


        // =========================================================
        // 7. ACCESS CONTROL
        // =========================================================

        int applicantId =
            ((Number) application.get("user_id"))
            .intValue();


        boolean isOwner =
            applicantId == currentUserId;


        /*
         * HR = Pentadbir sistem sekarang.
         *
         * MANAGEMENT turut diberi akses sekiranya role tersebut
         * digunakan kemudian.
         */

        boolean isAdministrator =
            "HR".equalsIgnoreCase(role)
            ||
            "ADMIN".equalsIgnoreCase(role)
            ||
            "MANAGEMENT".equalsIgnoreCase(role);


        /*
         * STAFF:
         * hanya boleh buka borang sendiri.
         *
         * HR / ADMIN / MANAGEMENT:
         * boleh buka semua borang.
         */

        if (!isOwner && !isAdministrator) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai akses kepada borang ini."
            );

            return;
        }


        // =========================================================
        // 8. ONLY APPROVED APPLICATION CAN BE PRINTED
        // =========================================================

        Object statusObject =
            application.get("status");

        String status =
            statusObject == null
            ? ""
            : String.valueOf(
                statusObject
            ).trim();


        if (!"APPROVED".equalsIgnoreCase(status)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Borang hanya boleh dicetak selepas permohonan diluluskan."
            );

            return;
        }


        // =========================================================
        // 9. SEND DATA TO JSP
        // =========================================================

        request.setAttribute(
            "application",
            application
        );

        request.setAttribute(
            "pageTitle",
            "Borang Permohonan Kenderaan"
        );

        request.setAttribute(
            "canPrint",
            true
        );

        request.setAttribute(
            "currentRole",
            role
        );


        // =========================================================
        // 10. FORWARD
        // =========================================================

        request
            .getRequestDispatcher(
                "/vehicle-print.jsp"
            )
            .forward(
                request,
                response
            );
    }
}