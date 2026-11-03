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
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;

import java.time.LocalDateTime;
import java.time.LocalTime;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/vehicle-approval")
public class VehicleApprovalServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isHR(session)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Anda tidak mempunyai akses ke halaman ini."
            );
            return;
        }

        String view = clean(request.getParameter("view")).toLowerCase();

        if (!"changes".equals(view)) {
            view = "applications";
        }

        String status =
                clean(request.getParameter("status")).toUpperCase();

        if (!Set.of(
                "PENDING",
                "APPROVED",
                "REJECTED",
                "CANCELLED"
        ).contains(status)) {
            status = "";
        }

        try (Connection con = DBConnection.getConnection()) {

            request.setAttribute(
                    "applications",
                    loadApplications(con, status)
            );

            request.setAttribute(
                    "counts",
                    loadApplicationCounts(con)
            );

            request.setAttribute(
                    "changes",
                    loadChanges(con)
            );

            request.setAttribute(
                    "pendingChangeCount",
                    countPendingChanges(con)
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Tidak dapat memuatkan Kelulusan Kenderaan.",
                    e
            );
        }

        request.setAttribute(
                "selectedStatus",
                status
        );

        request.setAttribute(
                "selectedView",
                view
        );

        request.getRequestDispatcher(
                "/vehicle-approval.jsp"
        ).forward(request, response);
    }


    // =========================================================
    // LOAD APPLICATIONS
    // =========================================================

    private List<Map<String, Object>> loadApplications(
            Connection con,
            String status)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT
                va.id,
                va.application_no,
                va.user_id,
                va.vehicle_id,

                va.use_date,
                va.start_time,

                va.expected_return_date,
                va.expected_return_time,

                va.actual_return_date,
                va.actual_return_time,

                va.driver_name,
                va.destination,
                va.purpose,

                va.status,
                va.approval_remark,

                va.approved_by,
                va.approved_at,

                va.created_at,
                va.updated_at,

                va.cancellation_reason,
                va.cancelled_at,

                v.plate_number,
                v.vehicle_name,

                u.name AS applicant_name

            FROM vehicle_applications va

            INNER JOIN vehicles v
                ON v.id = va.vehicle_id

            INNER JOIN users u
                ON u.id = va.user_id

            WHERE 1 = 1
        """);

        if (!status.isBlank()) {
            sql.append(" AND va.status = ? ");
        }

        sql.append("""
            ORDER BY

                CASE va.status

                    WHEN 'PENDING'
                        THEN 1

                    WHEN 'APPROVED'
                        THEN 2

                    WHEN 'REJECTED'
                        THEN 3

                    WHEN 'CANCELLED'
                        THEN 4

                    ELSE 5

                END,

                va.created_at DESC,
                va.id DESC
        """);

        try (PreparedStatement ps =
                     con.prepareStatement(sql.toString())) {

            if (!status.isBlank()) {
                ps.setString(1, status);
            }

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> app =
                            new HashMap<>();

                    app.put(
                            "id",
                            rs.getInt("id")
                    );

                    app.put(
                            "application_no",
                            rs.getString("application_no")
                    );

                    app.put(
                            "user_id",
                            rs.getInt("user_id")
                    );

                    app.put(
                            "vehicle_id",
                            rs.getInt("vehicle_id")
                    );

                    app.put(
                            "use_date",
                            rs.getDate("use_date")
                    );

                    app.put(
                            "start_time",
                            rs.getTime("start_time")
                    );

                    app.put(
                            "expected_return_date",
                            rs.getDate("expected_return_date")
                    );

                    app.put(
                            "expected_return_time",
                            rs.getTime("expected_return_time")
                    );

                    app.put(
                            "actual_return_date",
                            rs.getDate("actual_return_date")
                    );

                    app.put(
                            "actual_return_time",
                            rs.getTime("actual_return_time")
                    );

                    app.put(
                            "driver_name",
                            rs.getString("driver_name")
                    );

                    app.put(
                            "destination",
                            rs.getString("destination")
                    );

                    app.put(
                            "purpose",
                            rs.getString("purpose")
                    );

                    app.put(
                            "status",
                            rs.getString("status")
                    );

                    app.put(
                            "approval_remark",
                            rs.getString("approval_remark")
                    );

                    app.put(
                            "approved_at",
                            rs.getTimestamp("approved_at")
                    );

                    app.put(
                            "created_at",
                            rs.getTimestamp("created_at")
                    );

                    app.put(
                            "cancellation_reason",
                            rs.getString("cancellation_reason")
                    );

                    app.put(
                            "cancelled_at",
                            rs.getTimestamp("cancelled_at")
                    );

                    app.put(
                            "plate_number",
                            rs.getString("plate_number")
                    );

                    app.put(
                            "vehicle_name",
                            rs.getString("vehicle_name")
                    );

                    app.put(
                            "applicant_name",
                            rs.getString("applicant_name")
                    );

                    list.add(app);
                }
            }
        }

        return list;
    }


    // =========================================================
    // APPLICATION COUNTS
    // =========================================================

    private Map<String, Integer> loadApplicationCounts(
            Connection con)
            throws SQLException {

        Map<String, Integer> counts =
                new HashMap<>();

        counts.put("ALL", 0);
        counts.put("PENDING", 0);
        counts.put("APPROVED", 0);
        counts.put("REJECTED", 0);
        counts.put("CANCELLED", 0);

        String sql = """
            SELECT
                status,
                COUNT(*) AS total

            FROM vehicle_applications

            GROUP BY status
        """;

        try (
                PreparedStatement ps =
                        con.prepareStatement(sql);

                ResultSet rs =
                        ps.executeQuery()
        ) {

            int all = 0;

            while (rs.next()) {

                String currentStatus =
                        rs.getString("status");

                int total =
                        rs.getInt("total");

                counts.put(
                        currentStatus,
                        total
                );

                all += total;
            }

            counts.put(
                    "ALL",
                    all
            );
        }

        return counts;
    }


    // =========================================================
    // LOAD CHANGE REQUESTS
    // =========================================================

    private List<Map<String, Object>> loadChanges(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT

                c.id AS change_id,
                c.application_id,
                c.requested_by,

                c.old_use_date,
                c.old_start_time,

                c.old_return_date,
                c.old_return_time,

                c.new_use_date,
                c.new_start_time,

                c.new_return_date,
                c.new_return_time,

                c.reason,

                c.status AS change_status,

                c.review_remark,
                c.reviewed_at,

                c.created_at AS change_created_at,

                va.application_no,
                va.vehicle_id,

                va.status AS application_status,

                va.driver_name,
                va.destination,
                va.purpose,

                v.plate_number,
                v.vehicle_name,

                u.name AS applicant_name

            FROM vehicle_application_changes c

            INNER JOIN vehicle_applications va
                ON va.id = c.application_id

            INNER JOIN vehicles v
                ON v.id = va.vehicle_id

            INNER JOIN users u
                ON u.id = c.requested_by

            ORDER BY

                CASE c.status

                    WHEN 'PENDING'
                        THEN 1

                    WHEN 'APPROVED'
                        THEN 2

                    WHEN 'REJECTED'
                        THEN 3

                    WHEN 'CANCELLED'
                        THEN 4

                    ELSE 5

                END,

                c.created_at DESC,
                c.id DESC
        """;

        try (
                PreparedStatement ps =
                        con.prepareStatement(sql);

                ResultSet rs =
                        ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> change =
                        new HashMap<>();

                change.put(
                        "change_id",
                        rs.getInt("change_id")
                );

                change.put(
                        "application_id",
                        rs.getInt("application_id")
                );

                change.put(
                        "application_no",
                        rs.getString("application_no")
                );

                change.put(
                        "vehicle_id",
                        rs.getInt("vehicle_id")
                );

                change.put(
                        "applicant_name",
                        rs.getString("applicant_name")
                );

                change.put(
                        "plate_number",
                        rs.getString("plate_number")
                );

                change.put(
                        "vehicle_name",
                        rs.getString("vehicle_name")
                );

                change.put(
                        "driver_name",
                        rs.getString("driver_name")
                );

                change.put(
                        "destination",
                        rs.getString("destination")
                );

                change.put(
                        "purpose",
                        rs.getString("purpose")
                );

                change.put(
                        "application_status",
                        rs.getString("application_status")
                );

                change.put(
                        "old_use_date",
                        rs.getDate("old_use_date")
                );

                change.put(
                        "old_start_time",
                        rs.getTime("old_start_time")
                );

                change.put(
                        "old_return_date",
                        rs.getDate("old_return_date")
                );

                change.put(
                        "old_return_time",
                        rs.getTime("old_return_time")
                );

                change.put(
                        "new_use_date",
                        rs.getDate("new_use_date")
                );

                change.put(
                        "new_start_time",
                        rs.getTime("new_start_time")
                );

                change.put(
                        "new_return_date",
                        rs.getDate("new_return_date")
                );

                change.put(
                        "new_return_time",
                        rs.getTime("new_return_time")
                );

                change.put(
                        "reason",
                        rs.getString("reason")
                );

                change.put(
                        "change_status",
                        rs.getString("change_status")
                );

                change.put(
                        "review_remark",
                        rs.getString("review_remark")
                );

                change.put(
                        "reviewed_at",
                        rs.getTimestamp("reviewed_at")
                );

                change.put(
                        "change_created_at",
                        rs.getTimestamp("change_created_at")
                );

                list.add(change);
            }
        }

        return list;
    }


    // =========================================================
    // COUNT PENDING CHANGES
    // =========================================================

    private int countPendingChanges(
            Connection con)
            throws SQLException {

        String sql = """
            SELECT COUNT(*)
            FROM vehicle_application_changes
            WHERE status = 'PENDING'
        """;

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


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession(false);

        if (!isLoggedIn(session)) {

            response.sendRedirect(
                    request.getContextPath() + "/"
            );

            return;
        }

        if (!isHR(session)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }

        int adminId =
                ((Number) session.getAttribute("userId"))
                        .intValue();

        String action =
                clean(request.getParameter("action"));

        try {

            switch (action) {

                case "approve":
                case "reject":

                    processNormalApplication(
                            request,
                            response,
                            adminId,
                            action
                    );

                    break;


                case "return":

                    recordReturn(
                            request,
                            response
                    );

                    break;


                case "approveChange":
                case "rejectChange":

                    processChange(
                            request,
                            response,
                            adminId,
                            action
                    );

                    break;


                default:

                    redirectError(
                            request,
                            response,
                            "Tindakan tidak sah.",
                            ""
                    );
            }

        } catch (SQLException e) {

            throw new ServletException(
                    "Tidak dapat memproses tindakan kenderaan.",
                    e
            );
        }
    }


    // =========================================================
    // APPROVE / REJECT NORMAL APPLICATION
    // =========================================================

    private void processNormalApplication(
            HttpServletRequest request,
            HttpServletResponse response,
            int adminId,
            String action)
            throws SQLException, IOException {

        int applicationId =
                parseId(request.getParameter("id"));

        String remark =
                clean(request.getParameter(
                        "approval_remark"
                ));

        if (applicationId <= 0) {

            redirectError(
                    request,
                    response,
                    "Permohonan tidak sah.",
                    ""
            );

            return;
        }

        try (Connection con =
                     DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {

                int vehicleId;

                java.sql.Date useDate;
                Time startTime;

                java.sql.Date returnDate;
                Time returnTime;

                String status;
                String applicationNo;


                // =============================================
                // LOCK APPLICATION
                // =============================================

                String lockSql = """
                    SELECT

                        id,
                        application_no,
                        vehicle_id,

                        use_date,
                        start_time,

                        expected_return_date,
                        expected_return_time,

                        status

                    FROM vehicle_applications

                    WHERE id = ?

                    FOR UPDATE
                """;

                try (PreparedStatement ps =
                             con.prepareStatement(lockSql)) {

                    ps.setInt(
                            1,
                            applicationId
                    );

                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (!rs.next()) {

                            con.rollback();

                            redirectError(
                                    request,
                                    response,
                                    "Permohonan tidak ditemui.",
                                    ""
                            );

                            return;
                        }

                        applicationNo =
                                rs.getString(
                                        "application_no"
                                );

                        vehicleId =
                                rs.getInt(
                                        "vehicle_id"
                                );

                        useDate =
                                rs.getDate(
                                        "use_date"
                                );

                        startTime =
                                rs.getTime(
                                        "start_time"
                                );

                        returnDate =
                                rs.getDate(
                                        "expected_return_date"
                                );

                        returnTime =
                                rs.getTime(
                                        "expected_return_time"
                                );

                        status =
                                rs.getString(
                                        "status"
                                );
                    }
                }


                // =============================================
                // ONLY PENDING CAN BE PROCESSED
                // =============================================

                if (!"PENDING".equals(status)) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Permohonan ini telah diproses.",
                            ""
                    );

                    return;
                }


                // =============================================
                // APPROVE
                // =============================================

                if ("approve".equals(action)) {

                    if (!vehicleActive(
                            con,
                            vehicleId
                    )) {

                        con.rollback();

                        redirectError(
                                request,
                                response,
                                "Kenderaan ini tidak lagi aktif.",
                                ""
                        );

                        return;
                    }


                    if (!isEndAfterStart(
                            useDate,
                            startTime,
                            returnDate,
                            returnTime
                    )) {

                        con.rollback();

                        redirectError(
                                request,
                                response,
                                "Tempoh penggunaan tidak sah.",
                                ""
                        );

                        return;
                    }


                    if (hasConflict(
                            con,
                            vehicleId,
                            applicationId,
                            useDate,
                            startTime,
                            returnDate,
                            returnTime
                    )) {

                        con.rollback();

                        redirectError(
                                request,
                                response,
                                "Permohonan tidak boleh diluluskan kerana bertindih dengan tempahan lain.",
                                ""
                        );

                        return;
                    }


                    String approveSql = """
                        UPDATE vehicle_applications

                        SET
                            status = 'APPROVED',
                            approval_remark = ?,
                            approved_by = ?,
                            approved_at = NOW(),
                            updated_at = CURRENT_TIMESTAMP

                        WHERE id = ?
                          AND status = 'PENDING'
                    """;

                    try (PreparedStatement ps =
                                 con.prepareStatement(
                                         approveSql
                                 )) {

                        ps.setString(
                                1,
                                remark
                        );

                        ps.setInt(
                                2,
                                adminId
                        );

                        ps.setInt(
                                3,
                                applicationId
                        );

                        ps.executeUpdate();
                    }


                    con.commit();

                    redirectSuccess(
                            request,
                            response,
                            "Permohonan "
                                    + applicationNo
                                    + " berjaya diluluskan.",
                            ""
                    );

                    return;
                }


                // =============================================
                // REJECT
                // =============================================

                String rejectSql = """
                    UPDATE vehicle_applications

                    SET
                        status = 'REJECTED',
                        approval_remark = ?,
                        approved_by = ?,
                        approved_at = NOW(),
                        updated_at = CURRENT_TIMESTAMP

                    WHERE id = ?
                      AND status = 'PENDING'
                """;

                try (PreparedStatement ps =
                             con.prepareStatement(
                                     rejectSql
                             )) {

                    ps.setString(
                            1,
                            remark
                    );

                    ps.setInt(
                            2,
                            adminId
                    );

                    ps.setInt(
                            3,
                            applicationId
                    );

                    ps.executeUpdate();
                }


                con.commit();

                redirectSuccess(
                        request,
                        response,
                        "Permohonan "
                                + applicationNo
                                + " berjaya ditolak.",
                        ""
                );


            } catch (SQLException | RuntimeException e) {

                con.rollback();

                throw e;

            } finally {

                con.setAutoCommit(true);
            }
        }
    }


    // =========================================================
    // RECORD ACTUAL RETURN
    // =========================================================

    private void recordReturn(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {

        int applicationId =
                parseId(request.getParameter("id"));

        String dateValue =
                clean(request.getParameter(
                        "actual_return_date"
                ));

        String timeValue =
                clean(request.getParameter(
                        "actual_return_time"
                ));


        if (applicationId <= 0
                || dateValue.isBlank()
                || timeValue.isBlank()) {

            redirectError(
                    request,
                    response,
                    "Sila lengkapkan tarikh dan masa pemulangan.",
                    ""
            );

            return;
        }


        java.time.LocalDate actualDate;
        LocalTime actualTime;


        try {

            actualDate =
                    java.time.LocalDate.parse(
                            dateValue
                    );

            actualTime =
                    LocalTime.parse(
                            timeValue
                    );

        } catch (Exception e) {

            redirectError(
                    request,
                    response,
                    "Tarikh atau masa pemulangan tidak sah.",
                    ""
            );

            return;
        }


        LocalDateTime actualDateTime =
                LocalDateTime.of(
                        actualDate,
                        actualTime
                );


        if (actualDateTime.isAfter(
                LocalDateTime.now()
        )) {

            redirectError(
                    request,
                    response,
                    "Masa pemulangan sebenar tidak boleh melebihi waktu semasa.",
                    ""
            );

            return;
        }


        try (Connection con =
                     DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {

                String applicationNo;
                String status;

                LocalDateTime startDateTime;
                LocalDateTime expectedDateTime;


                String lockSql = """
                    SELECT

                        application_no,
                        status,

                        use_date,
                        start_time,

                        expected_return_date,
                        expected_return_time

                    FROM vehicle_applications

                    WHERE id = ?

                    FOR UPDATE
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     lockSql
                             )) {

                    ps.setInt(
                            1,
                            applicationId
                    );

                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (!rs.next()) {

                            con.rollback();

                            redirectError(
                                    request,
                                    response,
                                    "Permohonan tidak ditemui.",
                                    ""
                            );

                            return;
                        }


                        applicationNo =
                                rs.getString(
                                        "application_no"
                                );

                        status =
                                rs.getString(
                                        "status"
                                );


                        startDateTime =
                                LocalDateTime.of(

                                        rs.getDate(
                                                "use_date"
                                        ).toLocalDate(),

                                        rs.getTime(
                                                "start_time"
                                        ).toLocalTime()
                                );


                        expectedDateTime =
                                LocalDateTime.of(

                                        rs.getDate(
                                                "expected_return_date"
                                        ).toLocalDate(),

                                        rs.getTime(
                                                "expected_return_time"
                                        ).toLocalTime()
                                );
                    }
                }


                if (!"APPROVED".equals(status)) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Pemulangan hanya boleh direkodkan untuk permohonan yang diluluskan.",
                            ""
                    );

                    return;
                }


                if (actualDateTime.isBefore(
                        startDateTime
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Masa pemulangan tidak boleh sebelum masa penggunaan bermula.",
                            ""
                    );

                    return;
                }


                String updateSql = """
                    UPDATE vehicle_applications

                    SET
                        actual_return_date = ?,
                        actual_return_time = ?,
                        updated_at = CURRENT_TIMESTAMP

                    WHERE id = ?
                      AND status = 'APPROVED'
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     updateSql
                             )) {

                    ps.setDate(
                            1,
                            java.sql.Date.valueOf(
                                    actualDate
                            )
                    );

                    ps.setTime(
                            2,
                            Time.valueOf(
                                    actualTime
                            )
                    );

                    ps.setInt(
                            3,
                            applicationId
                    );

                    ps.executeUpdate();
                }


                con.commit();


                String returnLabel;

                if (actualDateTime.isBefore(
                        expectedDateTime
                )) {

                    returnLabel =
                            "Pulang Awal";

                } else if (actualDateTime.isAfter(
                        expectedDateTime
                )) {

                    returnLabel =
                            "Pulang Lewat";

                } else {

                    returnLabel =
                            "Mengikut Jadual";
                }


                redirectSuccess(
                        request,
                        response,
                        "Pemulangan "
                                + applicationNo
                                + " berjaya direkodkan ("
                                + returnLabel
                                + ").",
                        "status=APPROVED"
                );


            } catch (SQLException | RuntimeException e) {

                con.rollback();

                throw e;

            } finally {

                con.setAutoCommit(true);
            }
        }
    }


    // =========================================================
    // APPROVE / REJECT CHANGE REQUEST
    // =========================================================

    private void processChange(
            HttpServletRequest request,
            HttpServletResponse response,
            int adminId,
            String action)
            throws SQLException, IOException {

        int changeId =
                parseId(
                        request.getParameter(
                                "change_id"
                        )
                );

        String reviewRemark =
                clean(
                        request.getParameter(
                                "review_remark"
                        )
                );


        if (changeId <= 0) {

            redirectError(
                    request,
                    response,
                    "Permohonan perubahan tidak sah.",
                    "view=changes"
            );

            return;
        }


        try (Connection con =
                     DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {

                int applicationId;
                int vehicleId;

                String changeStatus;
                String applicationStatus;
                String applicationNo;

                java.sql.Date newUseDate;
                Time newStartTime;

                java.sql.Date newReturnDate;
                Time newReturnTime;


                // =============================================
                // LOCK CHANGE REQUEST
                // =============================================

                String lockChangeSql = """
                    SELECT

                        c.application_id,

                        c.status AS change_status,

                        c.new_use_date,
                        c.new_start_time,

                        c.new_return_date,
                        c.new_return_time,

                        va.vehicle_id,

                        va.status AS application_status,

                        va.application_no

                    FROM vehicle_application_changes c

                    INNER JOIN vehicle_applications va
                        ON va.id = c.application_id

                    WHERE c.id = ?

                    FOR UPDATE
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     lockChangeSql
                             )) {

                    ps.setInt(
                            1,
                            changeId
                    );


                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (!rs.next()) {

                            con.rollback();

                            redirectError(
                                    request,
                                    response,
                                    "Permohonan perubahan tidak ditemui.",
                                    "view=changes"
                            );

                            return;
                        }


                        applicationId =
                                rs.getInt(
                                        "application_id"
                                );

                        vehicleId =
                                rs.getInt(
                                        "vehicle_id"
                                );

                        changeStatus =
                                rs.getString(
                                        "change_status"
                                );

                        applicationStatus =
                                rs.getString(
                                        "application_status"
                                );

                        applicationNo =
                                rs.getString(
                                        "application_no"
                                );

                        newUseDate =
                                rs.getDate(
                                        "new_use_date"
                                );

                        newStartTime =
                                rs.getTime(
                                        "new_start_time"
                                );

                        newReturnDate =
                                rs.getDate(
                                        "new_return_date"
                                );

                        newReturnTime =
                                rs.getTime(
                                        "new_return_time"
                                );
                    }
                }


                // =============================================
                // VALIDATE CHANGE STATUS
                // =============================================

                if (!"PENDING".equals(
                        changeStatus
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Permohonan perubahan ini telah diproses.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // ORIGINAL APPLICATION MUST STILL BE APPROVED
                // =============================================

                if (!"APPROVED".equals(
                        applicationStatus
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Tempahan asal bukan lagi berstatus diluluskan.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // REJECT CHANGE
                // =============================================

                if ("rejectChange".equals(
                        action
                )) {

                    String rejectSql = """
                        UPDATE vehicle_application_changes

                        SET
                            status = 'REJECTED',
                            reviewed_by = ?,
                            review_remark = ?,
                            reviewed_at = NOW()

                        WHERE id = ?
                          AND status = 'PENDING'
                    """;


                    try (PreparedStatement ps =
                                 con.prepareStatement(
                                         rejectSql
                                 )) {

                        ps.setInt(
                                1,
                                adminId
                        );

                        ps.setString(
                                2,
                                reviewRemark
                        );

                        ps.setInt(
                                3,
                                changeId
                        );

                        ps.executeUpdate();
                    }


                    con.commit();


                    redirectSuccess(
                            request,
                            response,
                            "Perubahan untuk "
                                    + applicationNo
                                    + " berjaya ditolak.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // VEHICLE MUST STILL BE ACTIVE
                // =============================================

                if (!vehicleActive(
                        con,
                        vehicleId
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Kenderaan ini tidak lagi aktif.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // VALIDATE NEW DATE RANGE
                // =============================================

                if (!isEndAfterStart(
                        newUseDate,
                        newStartTime,
                        newReturnDate,
                        newReturnTime
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Tempoh baharu tidak sah.",
                            "view=changes"
                    );

                    return;
                }


                LocalDateTime newStartDateTime =
                        LocalDateTime.of(
                                newUseDate.toLocalDate(),
                                newStartTime.toLocalTime()
                        );


                if (newStartDateTime.isBefore(
                        LocalDateTime.now()
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Tarikh atau masa mula baharu telah berlalu dan tidak boleh diluluskan.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // CHECK CONFLICT AGAIN
                // =============================================

                if (hasConflict(
                        con,
                        vehicleId,
                        applicationId,
                        newUseDate,
                        newStartTime,
                        newReturnDate,
                        newReturnTime
                )) {

                    con.rollback();

                    redirectError(
                            request,
                            response,
                            "Perubahan tidak boleh diluluskan kerana tempoh baharu bertindih dengan tempahan lain.",
                            "view=changes"
                    );

                    return;
                }


                // =============================================
                // LOCK ORIGINAL APPLICATION
                // =============================================

                String lockApplicationSql = """
                    SELECT id

                    FROM vehicle_applications

                    WHERE id = ?

                    FOR UPDATE
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     lockApplicationSql
                             )) {

                    ps.setInt(
                            1,
                            applicationId
                    );

                    try (ResultSet ignored =
                                 ps.executeQuery()) {

                        // Row lock only
                    }
                }


                // =============================================
                // UPDATE ORIGINAL BOOKING
                // =============================================

                String updateApplicationSql = """
                    UPDATE vehicle_applications

                    SET
                        use_date = ?,
                        start_time = ?,

                        expected_return_date = ?,
                        expected_return_time = ?,

                        actual_return_date = NULL,
                        actual_return_time = NULL,

                        updated_at = CURRENT_TIMESTAMP

                    WHERE id = ?
                      AND status = 'APPROVED'
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     updateApplicationSql
                             )) {

                    ps.setDate(
                            1,
                            newUseDate
                    );

                    ps.setTime(
                            2,
                            newStartTime
                    );

                    ps.setDate(
                            3,
                            newReturnDate
                    );

                    ps.setTime(
                            4,
                            newReturnTime
                    );

                    ps.setInt(
                            5,
                            applicationId
                    );

                    ps.executeUpdate();
                }


                // =============================================
                // APPROVE CHANGE HISTORY
                // =============================================

                String approveChangeSql = """
                    UPDATE vehicle_application_changes

                    SET
                        status = 'APPROVED',
                        reviewed_by = ?,
                        review_remark = ?,
                        reviewed_at = NOW()

                    WHERE id = ?
                      AND status = 'PENDING'
                """;


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     approveChangeSql
                             )) {

                    ps.setInt(
                            1,
                            adminId
                    );

                    ps.setString(
                            2,
                            reviewRemark
                    );

                    ps.setInt(
                            3,
                            changeId
                    );

                    ps.executeUpdate();
                }


                con.commit();


                redirectSuccess(
                        request,
                        response,
                        "Perubahan tempahan "
                                + applicationNo
                                + " berjaya diluluskan.",
                        "view=changes"
                );


            } catch (SQLException | RuntimeException e) {

                con.rollback();

                throw e;

            } finally {

                con.setAutoCommit(true);
            }
        }
    }


    // =========================================================
    // CHECK VEHICLE ACTIVE
    // =========================================================

    private boolean vehicleActive(
            Connection con,
            int vehicleId)
            throws SQLException {

        String sql = """
            SELECT id

            FROM vehicles

            WHERE id = ?
              AND status = 'ACTIVE'

            LIMIT 1
        """;


        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setInt(
                    1,
                    vehicleId
            );

            try (ResultSet rs =
                         ps.executeQuery()) {

                return rs.next();
            }
        }
    }


    // =========================================================
    // CHECK BOOKING CONFLICT
    // =========================================================

    private boolean hasConflict(
            Connection con,
            int vehicleId,
            int excludedApplicationId,
            java.sql.Date startDate,
            Time startTime,
            java.sql.Date endDate,
            Time endTime)
            throws SQLException {

        String sql = """
            SELECT

                id,
                application_no

            FROM vehicle_applications

            WHERE vehicle_id = ?

              AND status = 'APPROVED'

              AND id <> ?

              AND TIMESTAMP(
                    use_date,
                    start_time
                  ) < TIMESTAMP(?, ?)

              AND (

                    CASE

                        WHEN actual_return_date IS NOT NULL
                         AND actual_return_time IS NOT NULL

                        THEN TIMESTAMP(
                                actual_return_date,
                                actual_return_time
                             )

                        ELSE TIMESTAMP(
                                COALESCE(
                                    expected_return_date,
                                    use_date
                                ),
                                expected_return_time
                             )

                    END

                  ) > TIMESTAMP(?, ?)

            LIMIT 1
        """;


        try (PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setInt(
                    1,
                    vehicleId
            );

            ps.setInt(
                    2,
                    excludedApplicationId
            );

            ps.setDate(
                    3,
                    endDate
            );

            ps.setTime(
                    4,
                    endTime
            );

            ps.setDate(
                    5,
                    startDate
            );

            ps.setTime(
                    6,
                    startTime
            );


            try (ResultSet rs =
                         ps.executeQuery()) {

                return rs.next();
            }
        }
    }


    // =========================================================
    // VALIDATE DATE / TIME
    // =========================================================

    private boolean isEndAfterStart(
            java.sql.Date startDate,
            Time startTime,
            java.sql.Date endDate,
            Time endTime) {

        if (startDate == null
                || startTime == null
                || endDate == null
                || endTime == null) {

            return false;
        }


        LocalDateTime start =
                LocalDateTime.of(
                        startDate.toLocalDate(),
                        startTime.toLocalTime()
                );


        LocalDateTime end =
                LocalDateTime.of(
                        endDate.toLocalDate(),
                        endTime.toLocalTime()
                );


        return end.isAfter(start);
    }


    // =========================================================
    // SESSION CHECK
    // =========================================================

    private boolean isLoggedIn(
            HttpSession session) {

        return session != null
                && session.getAttribute(
                        "userId"
                ) != null;
    }


    // =========================================================
    // HR CHECK
    // =========================================================

    private boolean isHR(
            HttpSession session) {

        if (session == null) {
            return false;
        }

        Object role =
                session.getAttribute(
                        "userRole"
                );

        return role != null
                && "HR".equalsIgnoreCase(
                        String.valueOf(role)
                );
    }


    // =========================================================
    // PARSE ID
    // =========================================================

    private int parseId(
            String value) {

        try {

            return Integer.parseInt(
                    clean(value)
            );

        } catch (Exception e) {

            return -1;
        }
    }


    // =========================================================
    // CLEAN STRING
    // =========================================================

    private String clean(
            String value) {

        return value == null
                ? ""
                : value.trim();
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


    // =========================================================
    // SUCCESS REDIRECT
    // =========================================================

    private void redirectSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            String extraQuery)
            throws IOException {

        String url =
                request.getContextPath()
                        + "/vehicle-approval?success="
                        + encode(message);


        if (extraQuery != null
                && !extraQuery.isBlank()) {

            url += "&" + extraQuery;
        }


        response.sendRedirect(url);
    }


    // =========================================================
    // ERROR REDIRECT
    // =========================================================

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            String extraQuery)
            throws IOException {

        String url =
                request.getContextPath()
                        + "/vehicle-approval?error="
                        + encode(message);


        if (extraQuery != null
                && !extraQuery.isBlank()) {

            url += "&" + extraQuery;
        }


        response.sendRedirect(url);
    }
}