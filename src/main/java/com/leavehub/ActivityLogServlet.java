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


@WebServlet("/activity-log")
public class ActivityLogServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /*
     * Jumlah rekod setiap halaman.
     */
    private static final int PAGE_SIZE = 20;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (session == null
                || session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );

            return;
        }


        // =====================================================
        // CHECK ROLE
        // =====================================================

        String role =
                session.getAttribute("userRole") == null
                        ? ""
                        : String.valueOf(
                                session.getAttribute("userRole")
                        );

        /*
         * Log Aktiviti hanya untuk HR/Admin.
         *
         * Jika sistem anda menggunakan role HR untuk admin,
         * code ini sudah sesuai.
         */

        if (!"HR".equalsIgnoreCase(role)
                && !"ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(
                    request.getContextPath() + "/dashboard"
            );

            return;
        }


        // =====================================================
        // GET FILTER
        // =====================================================

        String search =
                cleanParameter(
                        request.getParameter("search")
                );

        String selectedAction =
                cleanParameter(
                        request.getParameter("action")
                );

        String selectedRole =
                cleanParameter(
                        request.getParameter("role")
                );

        String dateFrom =
                cleanParameter(
                        request.getParameter("dateFrom")
                );

        String dateTo =
                cleanParameter(
                        request.getParameter("dateTo")
                );


        // =====================================================
        // PAGE
        // =====================================================

        int currentPage = 1;

        String pageParameter =
                request.getParameter("page");

        if (pageParameter != null
                && !pageParameter.isBlank()) {

            try {

                currentPage =
                        Integer.parseInt(
                                pageParameter
                        );

                if (currentPage < 1) {
                    currentPage = 1;
                }

            } catch (NumberFormatException ignored) {

                currentPage = 1;
            }
        }


        // =====================================================
        // LOAD DATA
        // =====================================================

        try (Connection connection =
                     DBConnection.getConnection()) {


            // =================================================
            // TOTAL RECORD
            // =================================================

            int totalRecords =
                    getTotalRecords(
                            connection,
                            search,
                            selectedAction,
                            selectedRole,
                            dateFrom,
                            dateTo
                    );


            // =================================================
            // TOTAL PAGE
            // =================================================

            int totalPages =
                    (int) Math.ceil(
                            (double) totalRecords
                                    / PAGE_SIZE
                    );

            if (totalPages < 1) {
                totalPages = 1;
            }


            /*
             * Jika user pergi ke page yang lebih besar
             * daripada jumlah page.
             */

            if (currentPage > totalPages) {
                currentPage = totalPages;
            }


            // =================================================
            // LOAD LOG
            // =================================================

            List<Map<String, Object>> logs =
                    getLogs(
                            connection,
                            search,
                            selectedAction,
                            selectedRole,
                            dateFrom,
                            dateTo,
                            currentPage
                    );


            // =================================================
            // LOAD ACTION LIST
            // =================================================

            List<String> actions =
                    getAvailableActions(
                            connection
                    );


            // =================================================
            // SET ATTRIBUTE
            // =================================================

            request.setAttribute(
                    "logs",
                    logs
            );

            request.setAttribute(
                    "actions",
                    actions
            );

            request.setAttribute(
                    "search",
                    search
            );

            request.setAttribute(
                    "selectedAction",
                    selectedAction
            );

            request.setAttribute(
                    "selectedRole",
                    selectedRole
            );

            request.setAttribute(
                    "dateFrom",
                    dateFrom
            );

            request.setAttribute(
                    "dateTo",
                    dateTo
            );

            request.setAttribute(
                    "currentPage",
                    currentPage
            );

            request.setAttribute(
                    "totalPages",
                    totalPages
            );

            request.setAttribute(
                    "totalRecords",
                    totalRecords
            );


            // =================================================
            // FORWARD JSP
            // =================================================

            request.getRequestDispatcher(
                    "/activity-log.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            e.printStackTrace();

            throw new ServletException(
                    "Ralat semasa mendapatkan Log Aktiviti.",
                    e
            );
        }
    }


    // =========================================================
    // GET LOGS
    // =========================================================

    private List<Map<String, Object>> getLogs(
            Connection connection,
            String search,
            String action,
            String role,
            String dateFrom,
            String dateTo,
            int page
    ) throws SQLException {

        List<Map<String, Object>> logs =
                new ArrayList<>();


        StringBuilder sql =
                new StringBuilder();

        sql.append(
                "SELECT "
        );

        sql.append(
                "al.id, "
        );

        sql.append(
                "al.user_id, "
        );

        sql.append(
                "al.action, "
        );

        sql.append(
                "al.description, "
        );

        sql.append(
                "al.reference_type, "
        );

        sql.append(
                "al.reference_id, "
        );

        sql.append(
                "al.ip_address, "
        );

        sql.append(
                "al.created_at, "
        );

        sql.append(
                "u.name AS user_name, "
        );

        sql.append(
                "u.email AS user_email, "
        );

        sql.append(
                "u.role AS user_role "
        );

        sql.append(
                "FROM activity_logs al "
        );

        sql.append(
                "LEFT JOIN users u "
        );

        sql.append(
                "ON al.user_id = u.id "
        );

        sql.append(
                "WHERE 1 = 1 "
        );


        // =====================================================
        // PARAMETERS
        // =====================================================

        List<Object> parameters =
                new ArrayList<>();


        // =====================================================
        // SEARCH
        // =====================================================

        if (!search.isBlank()) {

            sql.append(
                    "AND ("
            );

            sql.append(
                    "u.name LIKE ? "
            );

            sql.append(
                    "OR u.email LIKE ? "
            );

            sql.append(
                    "OR al.action LIKE ? "
            );

            sql.append(
                    "OR al.description LIKE ? "
            );

            sql.append(
                    "OR al.reference_type LIKE ? "
            );

            sql.append(
                    "OR CAST(al.reference_id AS CHAR) LIKE ? "
            );

            sql.append(
                    "OR al.ip_address LIKE ?"
            );

            sql.append(
                    ") "
            );


            String searchValue =
                    "%" + search + "%";

            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
        }


        // =====================================================
        // ACTION
        // =====================================================

        if (!action.isBlank()) {

            sql.append(
                    "AND al.action = ? "
            );

            parameters.add(
                    action
            );
        }


        // =====================================================
        // ROLE
        // =====================================================

        if (!role.isBlank()) {

            sql.append(
                    "AND u.role = ? "
            );

            parameters.add(
                    role
            );
        }


        // =====================================================
        // DATE FROM
        // =====================================================

        if (!dateFrom.isBlank()) {

            sql.append(
                    "AND DATE(al.created_at) >= ? "
            );

            parameters.add(
                    dateFrom
            );
        }


        // =====================================================
        // DATE TO
        // =====================================================

        if (!dateTo.isBlank()) {

            sql.append(
                    "AND DATE(al.created_at) <= ? "
            );

            parameters.add(
                    dateTo
            );
        }


        // =====================================================
        // SORT
        // =====================================================

        sql.append(
                "ORDER BY al.created_at DESC, al.id DESC "
        );


        // =====================================================
        // PAGINATION
        // =====================================================

        sql.append(
                "LIMIT ? OFFSET ?"
        );


        int offset =
                (page - 1) * PAGE_SIZE;


        parameters.add(
                PAGE_SIZE
        );

        parameters.add(
                offset
        );


        // =====================================================
        // EXECUTE
        // =====================================================

        try (PreparedStatement statement =
                     connection.prepareStatement(
                             sql.toString()
                     )) {


            setParameters(
                    statement,
                    parameters
            );


            try (ResultSet rs =
                         statement.executeQuery()) {


                while (rs.next()) {


                    Map<String, Object> log =
                            new HashMap<>();


                    log.put(
                            "id",
                            rs.getInt("id")
                    );


                    log.put(
                            "userId",
                            rs.getObject("user_id")
                    );


                    // =========================================
                    // USER NAME
                    // =========================================

                    String userName =
                            rs.getString(
                                    "user_name"
                            );

                    if (userName == null
                            || userName.isBlank()) {

                        userName =
                                "Sistem";
                    }


                    log.put(
                            "userName",
                            userName
                    );


                    log.put(
                            "userEmail",
                            rs.getString(
                                    "user_email"
                            )
                    );


                    // =========================================
                    // ROLE
                    // =========================================

                    String userRole =
                            rs.getString(
                                    "user_role"
                            );

                    if (userRole == null
                            || userRole.isBlank()) {

                        userRole =
                                "SYSTEM";
                    }


                    log.put(
                            "userRole",
                            userRole
                    );


                    // =========================================
                    // ACTION
                    // =========================================

                    log.put(
                            "action",
                            rs.getString(
                                    "action"
                            )
                    );


                    // =========================================
                    // DESCRIPTION
                    // =========================================

                    String description =
                            rs.getString(
                                    "description"
                            );

                    if (description == null
                            || description.isBlank()) {

                        description =
                                "—";
                    }


                    log.put(
                            "description",
                            description
                    );


                    // =========================================
                    // REFERENCE
                    // =========================================

                    log.put(
                            "referenceType",
                            rs.getString(
                                    "reference_type"
                            )
                    );


                    Object referenceId =
                            rs.getObject(
                                    "reference_id"
                            );


                    log.put(
                            "referenceId",
                            referenceId
                    );


                    // =========================================
                    // IP
                    // =========================================

                    String ipAddress =
                            rs.getString(
                                    "ip_address"
                            );


                    if (ipAddress == null
                            || ipAddress.isBlank()) {

                        ipAddress =
                                "—";
                    }


                    log.put(
                            "ipAddress",
                            ipAddress
                    );


                    // =========================================
                    // DATE
                    // =========================================

                    log.put(
                            "createdAt",
                            rs.getTimestamp(
                                    "created_at"
                            )
                    );


                    logs.add(
                            log
                    );
                }
            }
        }


        return logs;
    }


    // =========================================================
    // GET TOTAL RECORD
    // =========================================================

    private int getTotalRecords(
            Connection connection,
            String search,
            String action,
            String role,
            String dateFrom,
            String dateTo
    ) throws SQLException {


        StringBuilder sql =
                new StringBuilder();


        sql.append(
                "SELECT COUNT(*) "
        );

        sql.append(
                "FROM activity_logs al "
        );

        sql.append(
                "LEFT JOIN users u "
        );

        sql.append(
                "ON al.user_id = u.id "
        );

        sql.append(
                "WHERE 1 = 1 "
        );


        List<Object> parameters =
                new ArrayList<>();


        // =====================================================
        // SEARCH
        // =====================================================

        if (!search.isBlank()) {

            sql.append(
                    "AND ("
            );

            sql.append(
                    "u.name LIKE ? "
            );

            sql.append(
                    "OR u.email LIKE ? "
            );

            sql.append(
                    "OR al.action LIKE ? "
            );

            sql.append(
                    "OR al.description LIKE ? "
            );

            sql.append(
                    "OR al.reference_type LIKE ? "
            );

            sql.append(
                    "OR CAST(al.reference_id AS CHAR) LIKE ? "
            );

            sql.append(
                    "OR al.ip_address LIKE ?"
            );

            sql.append(
                    ") "
            );


            String searchValue =
                    "%" + search + "%";

            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
            parameters.add(searchValue);
        }


        // =====================================================
        // ACTION
        // =====================================================

        if (!action.isBlank()) {

            sql.append(
                    "AND al.action = ? "
            );

            parameters.add(
                    action
            );
        }


        // =====================================================
        // ROLE
        // =====================================================

        if (!role.isBlank()) {

            sql.append(
                    "AND u.role = ? "
            );

            parameters.add(
                    role
            );
        }


        // =====================================================
        // DATE FROM
        // =====================================================

        if (!dateFrom.isBlank()) {

            sql.append(
                    "AND DATE(al.created_at) >= ? "
            );

            parameters.add(
                    dateFrom
            );
        }


        // =====================================================
        // DATE TO
        // =====================================================

        if (!dateTo.isBlank()) {

            sql.append(
                    "AND DATE(al.created_at) <= ? "
            );

            parameters.add(
                    dateTo
            );
        }


        // =====================================================
        // EXECUTE
        // =====================================================

        try (PreparedStatement statement =
                     connection.prepareStatement(
                             sql.toString()
                     )) {


            setParameters(
                    statement,
                    parameters
            );


            try (ResultSet rs =
                         statement.executeQuery()) {


                if (rs.next()) {

                    return rs.getInt(1);
                }
            }
        }


        return 0;
    }


    // =========================================================
    // GET AVAILABLE ACTION
    // =========================================================

    private List<String> getAvailableActions(
            Connection connection
    ) throws SQLException {


        List<String> actions =
                new ArrayList<>();


        String sql =
                "SELECT DISTINCT action "
                + "FROM activity_logs "
                + "WHERE action IS NOT NULL "
                + "AND TRIM(action) <> '' "
                + "ORDER BY action ASC";


        try (PreparedStatement statement =
                     connection.prepareStatement(sql);

             ResultSet rs =
                     statement.executeQuery()) {


            while (rs.next()) {


                String action =
                        rs.getString(
                                "action"
                        );


                if (action != null
                        && !action.isBlank()) {

                    actions.add(
                            action
                    );
                }
            }
        }


        return actions;
    }


    // =========================================================
    // SET PARAMETERS
    // =========================================================

    private void setParameters(
            PreparedStatement statement,
            List<Object> parameters
    ) throws SQLException {


        for (
                int i = 0;
                i < parameters.size();
                i++
        ) {

            Object value =
                    parameters.get(i);


            if (value instanceof Integer) {

                statement.setInt(
                        i + 1,
                        (Integer) value
                );

            } else {

                statement.setString(
                        i + 1,
                        String.valueOf(value)
                );
            }
        }
    }


    // =========================================================
    // CLEAN PARAMETER
    // =========================================================

    private String cleanParameter(
            String value
    ) {


        if (value == null) {
            return "";
        }


        return value.trim();
    }
}