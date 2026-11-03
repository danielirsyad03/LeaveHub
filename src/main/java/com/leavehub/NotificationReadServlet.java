package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


@WebServlet("/notification-read")
public class NotificationReadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        process(
            request,
            response
        );
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        process(
            request,
            response
        );
    }


    // =========================================================
    // PROCESS
    // =========================================================

    private void process(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // SESSION
        // =====================================================

        HttpSession session =
            request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            if (isAjax(request)) {

                sendJson(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    false,
                    "Sesi pengguna tidak sah."
                );

            } else {

                response.sendRedirect(
                    request.getContextPath() + "/"
                );
            }

            return;
        }


        Integer userId =
            parseInteger(
                session.getAttribute("userId")
            );


        if (userId == null) {

            if (isAjax(request)) {

                sendJson(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    false,
                    "ID pengguna tidak sah."
                );

            } else {

                response.sendRedirect(
                    request.getContextPath() + "/"
                );
            }

            return;
        }


        // =====================================================
        // MARK ALL AS READ
        // =====================================================

        String action =
            request.getParameter("action");


        if (
            action != null
            &&
            "all".equalsIgnoreCase(
                action.trim()
            )
        ) {

            markAllAsRead(
                request,
                response,
                userId
            );

            return;
        }


        // =====================================================
        // SINGLE NOTIFICATION
        // =====================================================

        Integer notificationId =
            parseInteger(
                request.getParameter("id")
            );


        if (notificationId == null) {

            if (isAjax(request)) {

                sendJson(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    false,
                    "ID notifikasi tidak sah."
                );

            } else {

                response.sendRedirect(
                    request.getContextPath()
                    + "/notifications"
                );
            }

            return;
        }


        // =====================================================
        // ROLE
        // =====================================================

        String role =
            session.getAttribute("userRole") == null
                ? "STAFF"
                : session
                    .getAttribute("userRole")
                    .toString()
                    .trim()
                    .toUpperCase();


        String referenceType =
            null;


        // =====================================================
        // DATABASE
        // =====================================================

        try (
            Connection con =
                DBConnection.getConnection()
        ) {

            con.setAutoCommit(false);


            // =================================================
            // GET NOTIFICATION
            // =================================================

            String selectSql = """

                SELECT
                    reference_type,
                    reference_id

                FROM notifications

                WHERE id = ?
                  AND user_id = ?

                LIMIT 1

                FOR UPDATE

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        selectSql
                    )
            ) {

                ps.setInt(
                    1,
                    notificationId
                );


                ps.setInt(
                    2,
                    userId
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (!rs.next()) {

                        con.rollback();


                        if (isAjax(request)) {

                            sendJson(
                                response,
                                HttpServletResponse.SC_NOT_FOUND,
                                false,
                                "Notifikasi tidak ditemui."
                            );

                        } else {

                            response.sendRedirect(
                                request.getContextPath()
                                + "/notifications"
                            );
                        }

                        return;
                    }


                    referenceType =
                        rs.getString(
                            "reference_type"
                        );
                }
            }


            // =================================================
            // MARK ONE AS READ
            // =================================================

            String updateSql = """

                UPDATE notifications

                SET is_read = 1

                WHERE id = ?
                  AND user_id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateSql
                    )
            ) {

                ps.setInt(
                    1,
                    notificationId
                );


                ps.setInt(
                    2,
                    userId
                );


                ps.executeUpdate();
            }


            con.commit();


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat membuka notifikasi.",
                e
            );
        }


        // =====================================================
        // DESTINATION
        // =====================================================


        // =====================================================
        // LEAVE
        // =====================================================

        if (
            referenceType != null
            &&
            "LEAVE".equalsIgnoreCase(
                referenceType
            )
        ) {

            if (
                "HOD".equals(role)
                ||
                "MANAGEMENT".equals(role)
                ||
                "HR".equals(role)
            ) {

                response.sendRedirect(
                    request.getContextPath()
                    + "/admin"
                );

            } else {

                response.sendRedirect(
                    request.getContextPath()
                    + "/applications"
                );
            }

            return;
        }


        // =====================================================
        // INVENTORY REQUEST
        // =====================================================

        if (
            referenceType != null
            &&
            (
                "INVENTORY_REQUEST".equalsIgnoreCase(
                    referenceType
                )
                ||
                "INVENTORY".equalsIgnoreCase(
                    referenceType
                )
            )
        ) {

            if ("HR".equals(role)) {

                response.sendRedirect(
                    request.getContextPath()
                    + "/inventory-request-admin"
                );

            } else {

                response.sendRedirect(
                    request.getContextPath()
                    + "/inventory-requests"
                );
            }

            return;
        }


        // =====================================================
        // VEHICLE REQUEST
        // =====================================================

        if (
            referenceType != null
            &&
            (
                "VEHICLE".equalsIgnoreCase(
                    referenceType
                )
                ||
                "VEHICLE_REQUEST".equalsIgnoreCase(
                    referenceType
                )
                ||
                "VEHICLE_APPLICATION".equalsIgnoreCase(
                    referenceType
                )
            )
        ) {

            if (
                "HR".equals(role)
                ||
                "HOD".equals(role)
                ||
                "MANAGEMENT".equals(role)
            ) {

                response.sendRedirect(
                    request.getContextPath()
                    + "/vehicle-approval"
                );

            } else {

                response.sendRedirect(
                    request.getContextPath()
                    + "/my-vehicle-applications"
                );
            }

            return;
        }


        // =====================================================
        // FALLBACK
        // =====================================================

        response.sendRedirect(
            request.getContextPath()
            + "/notifications"
        );
    }


    // =========================================================
    // MARK ALL AS READ
    // =========================================================

    private void markAllAsRead(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId)
            throws ServletException, IOException {


        int updatedRows = 0;


        try (
            Connection con =
                DBConnection.getConnection()
        ) {

            String sql = """

                UPDATE notifications

                SET is_read = 1

                WHERE user_id = ?
                  AND is_read = 0

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(sql)
            ) {

                ps.setInt(
                    1,
                    userId
                );


                updatedRows =
                    ps.executeUpdate();
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menandakan semua notifikasi sebagai dibaca.",
                e
            );
        }


        response.setStatus(
            HttpServletResponse.SC_OK
        );


        response.setContentType(
            "application/json"
        );


        response.setCharacterEncoding(
            "UTF-8"
        );


        response.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate, max-age=0"
        );


        try (
            PrintWriter out =
                response.getWriter()
        ) {

            out.print(
                "{"
                + "\"success\":true,"
                + "\"updated\":"
                + updatedRows
                + "}"
            );
        }
    }


    // =========================================================
    // AJAX CHECK
    // =========================================================

    private boolean isAjax(
            HttpServletRequest request) {


        String requestedWith =
            request.getHeader(
                "X-Requested-With"
            );


        return (
            requestedWith != null
            &&
            "XMLHttpRequest".equalsIgnoreCase(
                requestedWith.trim()
            )
        );
    }


    // =========================================================
    // SEND JSON
    // =========================================================

    private void sendJson(
            HttpServletResponse response,
            int status,
            boolean success,
            String message)
            throws IOException {


        response.setStatus(
            status
        );


        response.setContentType(
            "application/json"
        );


        response.setCharacterEncoding(
            "UTF-8"
        );


        response.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate, max-age=0"
        );


        String safeMessage =
            message == null
                ? ""
                : message
                    .replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "\\r")
                    .replace("\n", "\\n");


        try (
            PrintWriter out =
                response.getWriter()
        ) {

            out.print(
                "{"
                + "\"success\":"
                + success
                + ","
                + "\"message\":\""
                + safeMessage
                + "\""
                + "}"
            );
        }
    }


    // =========================================================
    // PARSE INTEGER
    // =========================================================

    private Integer parseInteger(
            Object value) {


        if (value == null) {

            return null;
        }


        try {

            int number =
                Integer.parseInt(
                    value
                        .toString()
                        .trim()
                );


            return number > 0
                ? number
                : null;


        } catch (Exception e) {

            return null;
        }
    }
}
