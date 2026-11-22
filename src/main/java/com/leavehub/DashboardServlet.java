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
import java.time.Year;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String OTHER = "Lain-lain";


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session =
                req.getSession(false);

        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
                getUserId(session);

        if (userId == null) {

            session.invalidate();

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        int currentYear =
                Year.now().getValue();


        try (
            Connection con =
                    DBConnection.getConnection()
        ) {

            // =================================================
            // USER
            // =================================================

            UserInfo user =
                    loadUser(
                        con,
                        userId
                    );

            if (user == null) {

                session.invalidate();

                resp.sendRedirect(
                    req.getContextPath() + "/"
                );

                return;
            }


            String role =
                    normalizeRole(
                        user.role
                    );


            // Kehadiran pengguna yang sedang log masuk.
            // Digunakan pada kad ringkas dashboard untuk semua peranan.
            req.setAttribute(
                "todayAttendance",
                loadTodayAttendance(
                    con,
                    userId
                )
            );


            // =================================================
            // SESSION
            // =================================================

            session.setAttribute(
                "userName",
                user.name
            );

            session.setAttribute(
                "userRole",
                role
            );

            session.setAttribute(
                "userDepartment",
                user.department
            );


            // =================================================
            // USER INFORMATION
            // =================================================

            req.setAttribute(
                "dashboardName",
                user.name
            );

            req.setAttribute(
                "position",
                user.position
            );

            req.setAttribute(
                "email",
                user.email
            );

            req.setAttribute(
                "dashboardRole",
                role
            );

            req.setAttribute(
                "department",
                user.department
            );

            req.setAttribute(
                "currentYear",
                currentYear
            );


            // =================================================
            // MY APPLICATION SUMMARY
            // =================================================

            Map<String, Integer> mySummary =
                    loadMyApplicationSummary(
                        con,
                        userId
                    );

            req.setAttribute(
                "myTotal",
                mySummary.getOrDefault(
                    "total",
                    0
                )
            );

            req.setAttribute(
                "myPending",
                mySummary.getOrDefault(
                    "pending",
                    0
                )
            );

            req.setAttribute(
                "myApproved",
                mySummary.getOrDefault(
                    "approved",
                    0
                )
            );

            req.setAttribute(
                "myRejected",
                mySummary.getOrDefault(
                    "rejected",
                    0
                )
            );

            // Compatibility
            req.setAttribute(
                "pending",
                mySummary.getOrDefault(
                    "pending",
                    0
                )
            );


            // =================================================
            // MY CURRENT LEAVE
            // =================================================

            List<Map<String, Object>> currentLeave =
                    loadCurrentLeave(
                        con,
                        userId
                    );

            req.setAttribute(
                "currentLeave",
                currentLeave
            );

            req.setAttribute(
                "isCurrentlyOnLeave",
                !currentLeave.isEmpty()
            );


            // =================================================
            // MY UPCOMING LEAVE
            // =================================================

            List<Map<String, Object>> upcoming =
                    loadUpcomingLeave(
                        con,
                        userId
                    );

            req.setAttribute(
                "upcoming",
                upcoming
            );


            // =================================================
            // RECENT APPLICATIONS
            // =================================================

            List<Map<String, Object>> recentApplications =
                    loadRecentApplications(
                        con,
                        userId
                    );

            req.setAttribute(
                "recentApplications",
                recentApplications
            );



            // =================================================
            // VEHICLE DASHBOARD
            // =================================================

            req.setAttribute("activeVehicleCount", 0);
            req.setAttribute("maintenanceVehicleCount", 0);
            req.setAttribute("myVehicleApplicationCount", 0);
            req.setAttribute("myPendingVehicleApplicationCount", 0);
            req.setAttribute("todayVehicleApplicationCount", 0);
            req.setAttribute("pendingVehicleApplicationCount", 0);
            req.setAttribute(
                "myRecentVehicleApplications",
                new ArrayList<Map<String, Object>>()
            );
            req.setAttribute(
                "organizationRecentVehicleApplications",
                new ArrayList<Map<String, Object>>()
            );
            req.setAttribute(
                "activeVehicles",
                new ArrayList<Map<String, Object>>()
            );

            loadVehicleDashboard(
                con,
                req,
                userId,
                role
            );


            // =================================================
            // DEFAULT ROLE VALUES
            // =================================================

            req.setAttribute(
                "supervisedStaffCount",
                0
            );

            req.setAttribute(
                "hodPendingReviewCount",
                0
            );

            req.setAttribute(
                "hodCompletedCount",
                0
            );

            req.setAttribute(
                "managementPendingCount",
                0
            );

            req.setAttribute(
                "managementApprovedCount",
                0
            );

            req.setAttribute(
                "managementRejectedCount",
                0
            );

            req.setAttribute(
                "totalStaffCount",
                0
            );

            req.setAttribute(
                "organizationLeaveCount",
                0
            );

            req.setAttribute(
                "organizationPendingCount",
                0
            );

            req.setAttribute(
                "organizationApprovedCount",
                0
            );

            req.setAttribute(
                "organizationRejectedCount",
                0
            );

            req.setAttribute(
                "inventoryItemCount",
                0
            );

            req.setAttribute(
                "inventoryRequestCount",
                0
            );

            req.setAttribute(
                "pendingInventoryRequestCount",
                0
            );


            // =================================================
            // DEFAULT LEAVE LISTS
            // =================================================

            req.setAttribute(
                "supervisedCurrentLeave",
                new ArrayList<Map<String, Object>>()
            );

            req.setAttribute(
                "organizationCurrentLeave",
                new ArrayList<Map<String, Object>>()
            );

            req.setAttribute(
                "supervisedUpcomingLeave",
                new ArrayList<Map<String, Object>>()
            );

            req.setAttribute(
                "organizationUpcomingLeave",
                new ArrayList<Map<String, Object>>()
            );


            req.setAttribute(
                "organizationAttendanceToday",
                new ArrayList<Map<String, Object>>()
            );


            // =================================================
            // HOD
            // =================================================

            if ("HOD".equals(role)) {

                loadHodDashboard(
                    con,
                    req,
                    userId
                );


                List<Map<String, Object>> supervisedCurrentLeave =
                        loadSupervisedCurrentLeave(
                            con,
                            userId
                        );

                req.setAttribute(
                    "supervisedCurrentLeave",
                    supervisedCurrentLeave
                );


                List<Map<String, Object>> supervisedUpcomingLeave =
                        loadSupervisedUpcomingLeave(
                            con,
                            userId
                        );

                req.setAttribute(
                    "supervisedUpcomingLeave",
                    supervisedUpcomingLeave
                );
            }


            // =================================================
            // MANAGEMENT
            // =================================================

            if ("MANAGEMENT".equals(role)) {

                loadManagementDashboard(
                    con,
                    req
                );


                List<Map<String, Object>> organizationCurrentLeave =
                        loadOrganizationCurrentLeave(
                            con
                        );

                req.setAttribute(
                    "organizationCurrentLeave",
                    organizationCurrentLeave
                );


                List<Map<String, Object>> organizationUpcomingLeave =
                        loadOrganizationUpcomingLeave(
                            con
                        );

                req.setAttribute(
                    "organizationUpcomingLeave",
                    organizationUpcomingLeave
                );
            }


            // =================================================
            // HR
            // =================================================

            if ("HR".equals(role)) {

                loadHrDashboard(
                    con,
                    req
                );

                // Paparan kehadiran semua pengguna untuk HR/Admin
                req.setAttribute(
                    "organizationAttendanceToday",
                    loadOrganizationAttendanceToday(con)
                );


                List<Map<String, Object>> organizationCurrentLeave =
                        loadOrganizationCurrentLeave(
                            con
                        );

                req.setAttribute(
                    "organizationCurrentLeave",
                    organizationCurrentLeave
                );


                List<Map<String, Object>> organizationUpcomingLeave =
                        loadOrganizationUpcomingLeave(
                            con
                        );

                req.setAttribute(
                    "organizationUpcomingLeave",
                    organizationUpcomingLeave
                );
            }


            // =================================================
            // PENGUMUMAN & EVENT SYARIKAT
            // =================================================

            req.setAttribute(
                "dashboardAnnouncements",
                loadDashboardAnnouncements(con, userId, user.department)
            );

            req.setAttribute(
                "dashboardEvents",
                loadDashboardEvents(con)
            );


            // =================================================
            // JSP
            // =================================================

            req.getRequestDispatcher(
                "/dashboard.jsp"
            ).forward(
                req,
                resp
            );


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan halaman utama.",
                e
            );
        }
    }


    // =========================================================
    // PENGUMUMAN AKTIF UNTUK DASHBOARD
    // =========================================================

    private List<Map<String, Object>> loadDashboardAnnouncements(
            Connection con,
            int userId,
            String department) throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT
                a.id,
                a.title,
                a.content,
                a.category,
                a.published_at,
                a.expires_at,
                u.name AS creator_name
            FROM announcements a
            LEFT JOIN users u ON u.id = a.created_by
            WHERE a.status = 'PUBLISHED'
              AND a.published_at IS NOT NULL
              AND a.published_at <= NOW()
              AND (a.expires_at IS NULL OR a.expires_at > NOW())
              AND (
                    a.audience_type = 'ALL'
                    OR (
                        a.audience_type = 'DEPARTMENT'
                        AND a.target_department = ?
                    )
                    OR (
                        a.audience_type = 'SELECTED_STAFF'
                        AND EXISTS (
                            SELECT 1
                            FROM announcement_recipients ar
                            WHERE ar.announcement_id = a.id
                              AND ar.staff_id = ?
                        )
                    )
              )
            ORDER BY
                CASE WHEN a.category = 'PENTING' THEN 0 ELSE 1 END,
                a.published_at DESC,
                a.id DESC
            LIMIT 5
            """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, department);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("title", rs.getString("title"));
                    row.put("content", rs.getString("content"));
                    row.put("category", rs.getString("category"));
                    row.put("publishedAt", rs.getTimestamp("published_at"));
                    row.put("expiresAt", rs.getTimestamp("expires_at"));
                    row.put("creatorName", rs.getString("creator_name"));
                    list.add(row);
                }
            }
        }

        return list;
    }


    // =========================================================
    // EVENT SYARIKAT AKAN DATANG
    // =========================================================

    private List<Map<String, Object>> loadDashboardEvents(
            Connection con) throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT
                id,
                title,
                description,
                event_date,
                start_time,
                end_time,
                location
            FROM company_events
            WHERE status = 'PUBLISHED'
              AND (
                    event_date > CURDATE()
                    OR (event_date = CURDATE() AND (end_time IS NULL OR end_time >= CURTIME()))
              )
            ORDER BY event_date ASC, start_time ASC, id ASC
            LIMIT 5
            """;

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("title", rs.getString("title"));
                row.put("description", rs.getString("description"));
                row.put("eventDate", rs.getDate("event_date"));
                row.put("startTime", rs.getTime("start_time"));
                row.put("endTime", rs.getTime("end_time"));
                row.put("location", rs.getString("location"));
                list.add(row);
            }
        }

        return list;
    }


    // =========================================================
    // LOAD USER
    // =========================================================

    private UserInfo loadUser(
            Connection con,
            int userId)
            throws SQLException {

        String sql = """
            SELECT
                id,
                name,
                position,
                email,
                role,
                department
            FROM users
            WHERE id = ?
            LIMIT 1
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                userId
            );

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (!rs.next()) {
                    return null;
                }

                UserInfo user =
                        new UserInfo();

                rs.getInt("id");

                user.name =
                        rs.getString("name");

                user.position =
                        rs.getString("position");

                user.email =
                        rs.getString("email");

                user.role =
                        rs.getString("role");

                user.department =
                        rs.getString("department");

                return user;
            }
        }
    }


    // =========================================================
    // MY APPLICATION SUMMARY
    // =========================================================

    private Map<String, Integer> loadMyApplicationSummary(
            Connection con,
            int userId)
            throws SQLException {

        Map<String, Integer> result =
                new HashMap<>();

        String sql = """
            SELECT
                COUNT(*) AS total,

                SUM(
                    CASE
                        WHEN status IN (
                            'PENDING_HEAD',
                            'PENDING_ADMIN',
                            'PENDING_MANAGEMENT',
                            'PENDING'
                        )
                        THEN 1
                        ELSE 0
                    END
                ) AS pending_count,

                SUM(
                    CASE
                        WHEN status = 'APPROVED'
                        THEN 1
                        ELSE 0
                    END
                ) AS approved_count,

                SUM(
                    CASE
                        WHEN status = 'REJECTED'
                        THEN 1
                        ELSE 0
                    END
                ) AS rejected_count

            FROM leave_applications
            WHERE user_id = ?
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
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

                    result.put(
                        "total",
                        rs.getInt("total")
                    );

                    result.put(
                        "pending",
                        rs.getInt("pending_count")
                    );

                    result.put(
                        "approved",
                        rs.getInt("approved_count")
                    );

                    result.put(
                        "rejected",
                        rs.getInt("rejected_count")
                    );
                }
            }
        }

        return result;
    }


    // =========================================================
    // CURRENT OWN LEAVE
    // =========================================================

    private List<Map<String, Object>> loadCurrentLeave(
            Connection con,
            int userId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE la.user_id = ?
              AND la.status = 'APPROVED'
              AND la.start_date <= CURDATE()
              AND la.end_date >= CURDATE()

            ORDER BY
                la.start_date ASC,
                la.id DESC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
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

                    list.add(
                        buildLeaveRow(rs)
                    );
                }
            }
        }

        return list;
    }


    // =========================================================
    // UPCOMING OWN LEAVE
    // =========================================================

    private List<Map<String, Object>> loadUpcomingLeave(
            Connection con,
            int userId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE la.user_id = ?
              AND la.status = 'APPROVED'
              AND la.start_date > CURDATE()

            ORDER BY
                la.start_date ASC,
                la.submitted_at DESC

            LIMIT 5
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
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

                    list.add(
                        buildLeaveRow(rs)
                    );
                }
            }
        }

        return list;
    }


    // =========================================================
    // RECENT APPLICATIONS
    // =========================================================

    private List<Map<String, Object>> loadRecentApplications(
            Connection con,
            int userId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status,
                la.submitted_at

            FROM leave_applications la

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE la.user_id = ?

            ORDER BY
                la.submitted_at DESC,
                la.id DESC

            LIMIT 5
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
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

                    Map<String, Object> row =
                            buildLeaveRow(rs);

                    row.put(
                        "submittedAt",
                        rs.getTimestamp(
                            "submitted_at"
                        )
                    );

                    list.add(row);
                }
            }
        }

        return list;
    }


    // =========================================================
    // HOD - STAFF CURRENTLY ON LEAVE
    // =========================================================

    private List<Map<String, Object>> loadSupervisedCurrentLeave(
            Connection con,
            int hodId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                u.id AS staff_id,
                u.name AS staff_name,
                u.position AS staff_position,
                u.department AS staff_department,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE u.hod_id = ?
              AND la.user_id <> ?
              AND la.status = 'APPROVED'
              AND la.start_date <= CURDATE()
              AND la.end_date >= CURDATE()

            ORDER BY
                u.name ASC,
                la.start_date ASC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                hodId
            );

            ps.setInt(
                2,
                hodId
            );

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                while (rs.next()) {

                    Map<String, Object> row =
                            buildStaffLeaveRow(rs);

                    list.add(row);
                }
            }
        }

        return list;
    }


    // =========================================================
    // HOD - STAFF UPCOMING LEAVE
    // =========================================================

    private List<Map<String, Object>> loadSupervisedUpcomingLeave(
            Connection con,
            int hodId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                u.id AS staff_id,
                u.name AS staff_name,
                u.position AS staff_position,
                u.department AS staff_department,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE u.hod_id = ?
              AND la.user_id <> ?
              AND la.status = 'APPROVED'
              AND la.start_date > CURDATE()

            ORDER BY
                la.start_date ASC,
                u.name ASC,
                la.id DESC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                hodId
            );

            ps.setInt(
                2,
                hodId
            );

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                while (rs.next()) {

                    Map<String, Object> row =
                            buildStaffLeaveRow(rs);

                    list.add(row);
                }
            }
        }

        return list;
    }


    // =========================================================
    // HR / MANAGEMENT
    // ORGANIZATION CURRENTLY ON LEAVE
    // =========================================================

    private List<Map<String, Object>> loadOrganizationCurrentLeave(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                u.id AS staff_id,
                u.name AS staff_name,
                u.position AS staff_position,
                u.department AS staff_department,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE la.status = 'APPROVED'
              AND la.start_date <= CURDATE()
              AND la.end_date >= CURDATE()

            ORDER BY
                u.name ASC,
                la.start_date ASC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> row =
                        buildStaffLeaveRow(rs);

                list.add(row);
            }
        }

        return list;
    }


    // =========================================================
    // HR / MANAGEMENT
    // ORGANIZATION UPCOMING LEAVE
    // =========================================================

    private List<Map<String, Object>> loadOrganizationUpcomingLeave(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                la.id,
                la.application_no,

                u.id AS staff_id,
                u.name AS staff_name,
                u.position AS staff_position,
                u.department AS staff_department,

                COALESCE(
                    lt.leave_type_name,
                    la.leave_type
                ) AS leave_type_name,

                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,
                la.status

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id

            WHERE la.status = 'APPROVED'
              AND la.start_date > CURDATE()

            ORDER BY
                la.start_date ASC,
                u.name ASC,
                la.id DESC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> row =
                        buildStaffLeaveRow(rs);

                list.add(row);
            }
        }

        return list;
    }


    // =========================================================
    // BUILD STAFF LEAVE ROW
    // =========================================================

    private Map<String, Object> buildStaffLeaveRow(
            ResultSet rs)
            throws SQLException {

        Map<String, Object> row =
                buildLeaveRow(rs);

        row.put(
            "staffId",
            rs.getInt("staff_id")
        );

        row.put(
            "staffName",
            rs.getString("staff_name")
        );

        row.put(
            "staffPosition",
            rs.getString("staff_position")
        );

        row.put(
            "staffDepartment",
            rs.getString("staff_department")
        );

        return row;
    }


    // =========================================================
    // BUILD LEAVE ROW
    // =========================================================

    private Map<String, Object> buildLeaveRow(
            ResultSet rs)
            throws SQLException {

        Map<String, Object> row =
                new HashMap<>();

        int id =
                rs.getInt("id");

        String applicationNo =
                rs.getString("application_no");

        if (
            applicationNo == null
            ||
            applicationNo.isBlank()
        ) {

            applicationNo =
                    "PKB-CUTI-" + id;
        }


        String leaveType =
                rs.getString(
                    "leave_type_name"
                );

        String otherLeaveType =
                rs.getString(
                    "other_leave_type"
                );

        if (
            OTHER.equalsIgnoreCase(
                leaveType
            )
            &&
            otherLeaveType != null
            &&
            !otherLeaveType.isBlank()
        ) {

            leaveType =
                    "Lain-lain - "
                    + otherLeaveType;
        }


        row.put(
            "id",
            id
        );

        row.put(
            "applicationNo",
            applicationNo
        );

        row.put(
            "type",
            leaveType
        );

        row.put(
            "start",
            rs.getDate(
                "start_date"
            )
        );

        row.put(
            "end",
            rs.getDate(
                "end_date"
            )
        );

        row.put(
            "duration",
            rs.getInt(
                "duration"
            )
        );

        row.put(
            "status",
            rs.getString(
                "status"
            )
        );

        return row;
    }


    // =========================================================
    // HOD DASHBOARD
    // =========================================================

    private void loadHodDashboard(
            Connection con,
            HttpServletRequest req,
            int hodId)
            throws SQLException {

        String staffSql = """
            SELECT COUNT(*)
            FROM users
            WHERE hod_id = ?
        """;

        req.setAttribute(
            "supervisedStaffCount",
            queryCount(
                con,
                staffSql,
                hodId
            )
        );


        String pendingReviewSql = """
            SELECT COUNT(*)

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            WHERE u.hod_id = ?
              AND la.user_id <> ?

              AND la.status NOT IN (
                    'APPROVED',
                    'REJECTED',
                    'CANCELLED'
              )

              AND NOT EXISTS (
                    SELECT 1

                    FROM leave_approvals ap

                    WHERE ap.leave_id = la.id

                      AND ap.approval_level =
                          'HEAD_OF_UNIT'

                      AND ap.decision IN (
                            'SUPPORTED',
                            'NOT_SUPPORTED'
                      )
              )
        """;

        req.setAttribute(
            "hodPendingReviewCount",
            queryCount(
                con,
                pendingReviewSql,
                hodId,
                hodId
            )
        );


        String completedSql = """
            SELECT COUNT(*)

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            WHERE u.hod_id = ?
              AND la.user_id <> ?

              AND (
                    la.status IN (
                        'APPROVED',
                        'REJECTED',
                        'CANCELLED'
                    )

                    OR EXISTS (
                        SELECT 1

                        FROM leave_approvals ap

                        WHERE ap.leave_id = la.id

                          AND ap.approval_level =
                              'HEAD_OF_UNIT'

                          AND ap.decision IN (
                                'SUPPORTED',
                                'NOT_SUPPORTED'
                          )
                    )
              )
        """;

        req.setAttribute(
            "hodCompletedCount",
            queryCount(
                con,
                completedSql,
                hodId,
                hodId
            )
        );
    }


    // =========================================================
    // MANAGEMENT DASHBOARD
    // =========================================================

    private void loadManagementDashboard(
            Connection con,
            HttpServletRequest req)
            throws SQLException {

        String pendingSql = """
            SELECT COUNT(*)

            FROM leave_applications

            WHERE status IN (
                'PENDING_MANAGEMENT',
                'PENDING_HEAD',
                'PENDING_ADMIN',
                'PENDING'
            )
        """;

        req.setAttribute(
            "managementPendingCount",
            queryCount(
                con,
                pendingSql
            )
        );


        String approvedSql = """
            SELECT COUNT(*)
            FROM leave_applications
            WHERE status = 'APPROVED'
        """;

        req.setAttribute(
            "managementApprovedCount",
            queryCount(
                con,
                approvedSql
            )
        );


        String rejectedSql = """
            SELECT COUNT(*)
            FROM leave_applications
            WHERE status = 'REJECTED'
        """;

        req.setAttribute(
            "managementRejectedCount",
            queryCount(
                con,
                rejectedSql
            )
        );
    }


    // =========================================================
    // HR DASHBOARD
    // =========================================================

    private void loadHrDashboard(
            Connection con,
            HttpServletRequest req)
            throws SQLException {

        req.setAttribute(
            "totalStaffCount",
            queryCount(
                con,
                "SELECT COUNT(*) FROM users"
            )
        );


        req.setAttribute(
            "organizationLeaveCount",
            queryCount(
                con,
                "SELECT COUNT(*) FROM leave_applications"
            )
        );


        String pendingSql = """
            SELECT COUNT(*)

            FROM leave_applications

            WHERE status IN (
                'PENDING_MANAGEMENT',
                'PENDING_HEAD',
                'PENDING_ADMIN',
                'PENDING'
            )
        """;

        req.setAttribute(
            "organizationPendingCount",
            queryCount(
                con,
                pendingSql
            )
        );


        req.setAttribute(
            "organizationApprovedCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM leave_applications
                WHERE status = 'APPROVED'
                """
            )
        );


        req.setAttribute(
            "organizationRejectedCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM leave_applications
                WHERE status = 'REJECTED'
                """
            )
        );


        req.setAttribute(
            "inventoryItemCount",
            queryCount(
                con,
                "SELECT COUNT(*) FROM inventory_items"
            )
        );


        req.setAttribute(
            "inventoryRequestCount",
            queryCount(
                con,
                "SELECT COUNT(*) FROM inventory_requests"
            )
        );


        req.setAttribute(
            "pendingInventoryRequestCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM inventory_requests
                WHERE UPPER(TRIM(status)) = 'PENDING'
                """
            )
        );
    }



    // =========================================================
    // VEHICLE DASHBOARD
    // =========================================================

    private void loadVehicleDashboard(
            Connection con,
            HttpServletRequest req,
            int userId,
            String role)
            throws SQLException {

        List<Map<String, Object>> activeVehicles =
                loadActiveVehicles(con);

        req.setAttribute(
            "activeVehicles",
            activeVehicles
        );

        req.setAttribute(
            "activeVehicleCount",
            activeVehicles.size()
        );

        req.setAttribute(
            "maintenanceVehicleCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM vehicles
                WHERE status = 'MAINTENANCE'
                """
            )
        );

        req.setAttribute(
            "myVehicleApplicationCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM vehicle_applications
                WHERE user_id = ?
                """,
                userId
            )
        );

        req.setAttribute(
            "myPendingVehicleApplicationCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM vehicle_applications
                WHERE user_id = ?
                  AND status = 'PENDING'
                """,
                userId
            )
        );

        req.setAttribute(
            "todayVehicleApplicationCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM vehicle_applications
                WHERE use_date = CURDATE()
                  AND status = 'APPROVED'
                """
            )
        );

        req.setAttribute(
            "pendingVehicleApplicationCount",
            queryCount(
                con,
                """
                SELECT COUNT(*)
                FROM vehicle_applications
                WHERE status = 'PENDING'
                """
            )
        );

        req.setAttribute(
            "myRecentVehicleApplications",
            loadMyRecentVehicleApplications(
                con,
                userId
            )
        );

        if (
            "HR".equals(role)
            ||
            "MANAGEMENT".equals(role)
        ) {

            req.setAttribute(
                "organizationRecentVehicleApplications",
                loadOrganizationRecentVehicleApplications(con)
            );
        }
    }


    // =========================================================
    // ACTIVE VEHICLES
    // LOAD ALL ACTIVE COMPANY VEHICLES FOR DASHBOARD
    // =========================================================

    private List<Map<String, Object>> loadActiveVehicles(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                id,
                plate_number,
                vehicle_name,
                image_path,
                status
            FROM vehicles
            WHERE UPPER(TRIM(status)) = 'ACTIVE'
            ORDER BY
                vehicle_name ASC,
                plate_number ASC,
                id ASC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> row =
                        new HashMap<>();

                row.put(
                    "id",
                    rs.getInt("id")
                );

                row.put(
                    "plateNumber",
                    rs.getString("plate_number")
                );

                row.put(
                    "vehicleName",
                    rs.getString("vehicle_name")
                );

                row.put(
                    "imagePath",
                    rs.getString("image_path")
                );

                row.put(
                    "status",
                    rs.getString("status")
                );

                list.add(row);
            }
        }

        return list;
    }


    private List<Map<String, Object>> loadMyRecentVehicleApplications(
            Connection con,
            int userId)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                va.id,
                va.application_no,
                va.use_date,
                va.start_time,
                va.expected_return_time,
                va.driver_name,
                va.destination,
                va.purpose,
                va.status,
                v.plate_number,
                v.vehicle_name

            FROM vehicle_applications va

            JOIN vehicles v
                ON v.id = va.vehicle_id

            WHERE va.user_id = ?

            ORDER BY
                va.created_at DESC,
                va.id DESC

            LIMIT 5
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                while (rs.next()) {

                    Map<String, Object> row =
                            buildVehicleApplicationRow(rs);

                    list.add(row);
                }
            }
        }

        return list;
    }


    private List<Map<String, Object>> loadOrganizationRecentVehicleApplications(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                va.id,
                va.application_no,
                va.use_date,
                va.start_time,
                va.expected_return_time,
                va.driver_name,
                va.destination,
                va.purpose,
                va.status,
                v.plate_number,
                v.vehicle_name,
                u.name AS applicant_name

            FROM vehicle_applications va

            JOIN vehicles v
                ON v.id = va.vehicle_id

            JOIN users u
                ON u.id = va.user_id

            ORDER BY
                va.created_at DESC,
                va.id DESC

            LIMIT 8
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> row =
                        buildVehicleApplicationRow(rs);

                row.put(
                    "applicantName",
                    rs.getString("applicant_name")
                );

                list.add(row);
            }
        }

        return list;
    }


    private Map<String, Object> buildVehicleApplicationRow(
            ResultSet rs)
            throws SQLException {

        Map<String, Object> row =
                new HashMap<>();

        row.put("id", rs.getInt("id"));
        row.put("applicationNo", rs.getString("application_no"));
        row.put("useDate", rs.getDate("use_date"));
        row.put("startTime", rs.getTime("start_time"));
        row.put("returnTime", rs.getTime("expected_return_time"));
        row.put("driverName", rs.getString("driver_name"));
        row.put("destination", rs.getString("destination"));
        row.put("purpose", rs.getString("purpose"));
        row.put("status", rs.getString("status"));
        row.put("plateNumber", rs.getString("plate_number"));
        row.put("vehicleName", rs.getString("vehicle_name"));

        return row;
    }


    // =========================================================
    // KEHADIRAN PENGGUNA HARI INI
    // =========================================================

    private Map<String, Object> loadTodayAttendance(
            Connection con,
            int userId)
            throws SQLException {

        Map<String, Object> attendance =
                new HashMap<>();

        attendance.put(
            "status",
            "BELUM_HADIR"
        );

        attendance.put(
            "checkIn",
            null
        );

        attendance.put(
            "checkOut",
            null
        );

        attendance.put(
            "checkInDistance",
            null
        );

        attendance.put(
            "checkOutDistance",
            null
        );

        String sql = """
            SELECT
                attendance_date,
                check_in,
                check_out,
                check_in_distance,
                check_out_distance,
                status
            FROM attendance
            WHERE user_id = ?
              AND attendance_date = CURDATE()
            LIMIT 1
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
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

                    String status =
                            rs.getString("status");

                    if (
                        status != null
                        &&
                        !status.isBlank()
                    ) {
                        attendance.put(
                            "status",
                            status
                        );
                    }

                    attendance.put(
                        "checkIn",
                        rs.getTimestamp("check_in")
                    );

                    attendance.put(
                        "checkOut",
                        rs.getTimestamp("check_out")
                    );

                    attendance.put(
                        "checkInDistance",
                        rs.getObject("check_in_distance")
                    );

                    attendance.put(
                        "checkOutDistance",
                        rs.getObject("check_out_distance")
                    );
                }
            }
        }

        return attendance;
    }


    // =========================================================
    // HR / ADMIN - KEHADIRAN HARI INI
    // =========================================================

    private List<Map<String, Object>> loadOrganizationAttendanceToday(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                u.id,
                u.name,
                u.position,
                u.department,
                u.role,

                a.check_in,
                a.check_out,
                a.check_in_distance,
                a.check_out_distance,
                a.status

            FROM users u

            LEFT JOIN attendance a
                ON a.user_id = u.id
               AND a.attendance_date = CURDATE()

            ORDER BY
                CASE
                    WHEN a.status = 'HADIR' THEN 1
                    WHEN a.status = 'SELESAI' THEN 2
                    ELSE 3
                END,
                u.name ASC
        """;

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> row =
                        new HashMap<>();

                row.put(
                    "userId",
                    rs.getInt("id")
                );

                row.put(
                    "name",
                    rs.getString("name")
                );

                row.put(
                    "position",
                    rs.getString("position")
                );

                row.put(
                    "department",
                    rs.getString("department")
                );

                row.put(
                    "role",
                    rs.getString("role")
                );

                row.put(
                    "checkIn",
                    rs.getTimestamp("check_in")
                );

                row.put(
                    "checkOut",
                    rs.getTimestamp("check_out")
                );

                row.put(
                    "checkInDistance",
                    rs.getObject("check_in_distance")
                );

                row.put(
                    "checkOutDistance",
                    rs.getObject("check_out_distance")
                );

                String status =
                        rs.getString("status");

                if (
                    status == null
                    ||
                    status.isBlank()
                ) {
                    status = "BELUM_HADIR";
                }

                row.put(
                    "status",
                    status
                );

                list.add(row);
            }
        }

        return list;
    }


    // =========================================================
    // QUERY COUNT
    // =========================================================

    private int queryCount(
            Connection con,
            String sql)
            throws SQLException {

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }


    private int queryCount(
            Connection con,
            String sql,
            int value)
            throws SQLException {

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                value
            );

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }


    private int queryCount(
            Connection con,
            String sql,
            int value1,
            int value2)
            throws SQLException {

        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                value1
            );

            ps.setInt(
                2,
                value2
            );

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }


    // =========================================================
    // ROLE
    // =========================================================

    private String normalizeRole(
            String role) {

        if (
            role == null
            ||
            role.isBlank()
        ) {

            return "STAFF";
        }


        String normalized =
                role
                    .trim()
                    .toUpperCase();

        switch (normalized) {

            case "STAFF":
            case "HOD":
            case "HR":
            case "MANAGEMENT":
                return normalized;

            default:
                return "STAFF";
        }
    }


    // =========================================================
    // USER ID
    // =========================================================

    private Integer getUserId(
            HttpSession session) {

        try {

            int id =
                    Integer.parseInt(
                        session
                            .getAttribute(
                                "userId"
                            )
                            .toString()
                    );

            return id > 0
                    ? id
                    : null;

        } catch (Exception e) {

            return null;
        }
    }


    // =========================================================
    // USER INFO
    // =========================================================

    private static class UserInfo {

        String name;
        String position;
        String email;
        String role;
        String department;
    }
}
