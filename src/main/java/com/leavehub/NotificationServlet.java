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


@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // LOAD NOTIFICATIONS
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        HttpSession session =
            request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
            getUserId(session);


        if (userId == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // FILTER
        // =====================================================

        String filter =
            request.getParameter("filter");


        if (filter == null) {
            filter = "all";
        }


        filter =
            filter.trim().toLowerCase();


        if (
            !"all".equals(filter)
            &&
            !"unread".equals(filter)
        ) {

            filter = "all";
        }


        // =====================================================
        // LIST
        // =====================================================

        List<Map<String,Object>> notifications =
            new ArrayList<>();


        int unreadCount = 0;

        int totalCount = 0;


        try (
            Connection con =
                DBConnection.getConnection()
        ) {


            // =================================================
            // COUNT ALL + UNREAD
            // =================================================

            String countSql = """

                SELECT

                    COUNT(*) AS total_count,

                    SUM(
                        CASE
                            WHEN is_read = 0
                            THEN 1
                            ELSE 0
                        END
                    ) AS unread_count

                FROM notifications

                WHERE user_id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(countSql)
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

                        totalCount =
                            rs.getInt(
                                "total_count"
                            );


                        unreadCount =
                            rs.getInt(
                                "unread_count"
                            );
                    }
                }
            }


            // =================================================
            // LOAD NOTIFICATIONS
            // =================================================

            StringBuilder sql =
                new StringBuilder(
                    """

                    SELECT

                        id,
                        notification_type,
                        title,
                        message,
                        reference_type,
                        reference_id,
                        is_read,
                        created_at

                    FROM notifications

                    WHERE user_id = ?

                    """
                );


            if ("unread".equals(filter)) {

                sql.append(
                    """

                      AND is_read = 0

                    """
                );
            }


            sql.append(
                """

                ORDER BY
                    is_read ASC,
                    created_at DESC,
                    id DESC

                """
            );


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        sql.toString()
                    )
            ) {

                ps.setInt(
                    1,
                    userId
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    while (rs.next()) {


                        Map<String,Object> row =
                            new HashMap<>();


                        row.put(
                            "id",
                            rs.getInt("id")
                        );


                        row.put(
                            "notificationType",
                            rs.getString(
                                "notification_type"
                            )
                        );


                        row.put(
                            "title",
                            rs.getString(
                                "title"
                            )
                        );


                        row.put(
                            "message",
                            rs.getString(
                                "message"
                            )
                        );


                        row.put(
                            "referenceType",
                            rs.getString(
                                "reference_type"
                            )
                        );


                        row.put(
                            "referenceId",
                            rs.getObject(
                                "reference_id"
                            )
                        );


                        row.put(
                            "isRead",
                            rs.getBoolean(
                                "is_read"
                            )
                        );


                        row.put(
                            "createdAt",
                            rs.getTimestamp(
                                "created_at"
                            )
                        );


                        notifications.add(
                            row
                        );
                    }
                }
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan notifikasi.",
                e
            );
        }


        // =====================================================
        // REQUEST ATTRIBUTES
        // =====================================================

        request.setAttribute(
            "notifications",
            notifications
        );


        request.setAttribute(
            "unreadCount",
            unreadCount
        );


        request.setAttribute(
            "totalCount",
            totalCount
        );


        request.setAttribute(
            "filter",
            filter
        );


        request
            .getRequestDispatcher(
                "/notifications.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // POST
    // ACTIONS
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        HttpSession session =
            request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
            getUserId(session);


        if (userId == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        String action =
            request.getParameter("action");


        if (action == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/notifications"
            );

            return;
        }


        action =
            action.trim()
                .toLowerCase();


        try (
            Connection con =
                DBConnection.getConnection()
        ) {


            // =================================================
            // MARK ALL AS READ
            // =================================================

            if ("read-all".equals(action)) {


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


                    ps.executeUpdate();
                }


                session.setAttribute(
                    "notificationMessage",
                    "Semua notifikasi telah ditandakan sebagai dibaca."
                );
            }


            // =================================================
            // DELETE ONE
            // =================================================

            else if ("delete".equals(action)) {


                Integer notificationId =
                    parseInteger(
                        request.getParameter("id")
                    );


                if (notificationId != null) {


                    String sql = """

                        DELETE FROM notifications

                        WHERE id = ?
                          AND user_id = ?

                    """;


                    try (
                        PreparedStatement ps =
                            con.prepareStatement(sql)
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


                    session.setAttribute(
                        "notificationMessage",
                        "Notifikasi telah dipadam."
                    );
                }
            }


            // =================================================
            // DELETE ALL READ
            // =================================================

            else if ("delete-read".equals(action)) {


                String sql = """

                    DELETE FROM notifications

                    WHERE user_id = ?
                      AND is_read = 1

                """;


                try (
                    PreparedStatement ps =
                        con.prepareStatement(sql)
                ) {

                    ps.setInt(
                        1,
                        userId
                    );


                    ps.executeUpdate();
                }


                session.setAttribute(
                    "notificationMessage",
                    "Semua notifikasi yang telah dibaca telah dipadam."
                );
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memproses tindakan notifikasi.",
                e
            );
        }


        // =====================================================
        // RETURN TO FILTER
        // =====================================================

        String filter =
            request.getParameter("filter");


        if ("unread".equalsIgnoreCase(filter)) {

            response.sendRedirect(
                request.getContextPath()
                + "/notifications?filter=unread"
            );

        } else {

            response.sendRedirect(
                request.getContextPath()
                + "/notifications"
            );
        }
    }


    // =========================================================
    // GET USER ID
    // =========================================================

    private Integer getUserId(
            HttpSession session) {


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            return null;
        }


        try {

            int id =
                Integer.parseInt(
                    session
                        .getAttribute("userId")
                        .toString()
                        .trim()
                );


            return id > 0
                ? id
                : null;


        } catch (Exception e) {

            return null;
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