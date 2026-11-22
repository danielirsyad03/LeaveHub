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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/my-vehicle-applications")
public class MyVehicleApplicationsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();
        String selectedStatus = clean(request.getParameter("status")).toUpperCase();

        if (!selectedStatus.isEmpty()
                && !selectedStatus.equals("PENDING")
                && !selectedStatus.equals("APPROVED")
                && !selectedStatus.equals("REJECTED")
                && !selectedStatus.equals("CANCELLED")) {
            selectedStatus = "";
        }

        List<Map<String, Object>> applications = new ArrayList<>();
        Map<String, Integer> counts = new HashMap<>();

        String listSql = """
            SELECT
                va.id,
                va.application_no,
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
                va.created_at,
                va.cancellation_reason,
                va.cancelled_at,
                v.plate_number,
                v.vehicle_name,
                (
                    SELECT vac.id
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_change_id,
                (
                    SELECT vac.new_use_date
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_new_use_date,
                (
                    SELECT vac.new_start_time
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_new_start_time,
                (
                    SELECT vac.new_return_date
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_new_return_date,
                (
                    SELECT vac.new_return_time
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_new_return_time,
                (
                    SELECT vac.reason
                    FROM vehicle_application_changes vac
                    WHERE vac.application_id = va.id
                      AND vac.status = 'PENDING'
                    ORDER BY vac.id DESC
                    LIMIT 1
                ) AS pending_change_reason
            FROM vehicle_applications va
            INNER JOIN vehicles v ON v.id = va.vehicle_id
            WHERE va.user_id = ?
              AND (? = '' OR va.status = ?)
            ORDER BY va.created_at DESC, va.id DESC
        """;

        String countSql = """
            SELECT status, COUNT(*) AS total
            FROM vehicle_applications
            WHERE user_id = ?
            GROUP BY status
        """;

        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(listSql)) {
                ps.setInt(1, userId);
                ps.setString(2, selectedStatus);
                ps.setString(3, selectedStatus);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> app = new HashMap<>();
                        app.put("id", rs.getInt("id"));
                        app.put("application_no", rs.getString("application_no"));
                        app.put("vehicle_id", rs.getInt("vehicle_id"));
                        app.put("use_date", rs.getDate("use_date"));
                        app.put("start_time", rs.getTime("start_time"));
                        app.put("expected_return_date", rs.getDate("expected_return_date"));
                        app.put("expected_return_time", rs.getTime("expected_return_time"));
                        app.put("actual_return_date", rs.getDate("actual_return_date"));
                        app.put("actual_return_time", rs.getTime("actual_return_time"));
                        app.put("driver_name", rs.getString("driver_name"));
                        app.put("destination", rs.getString("destination"));
                        app.put("purpose", rs.getString("purpose"));
                        app.put("status", rs.getString("status"));
                        app.put("approval_remark", rs.getString("approval_remark"));
                        app.put("created_at", rs.getTimestamp("created_at"));
                        app.put("cancellation_reason", rs.getString("cancellation_reason"));
                        app.put("cancelled_at", rs.getTimestamp("cancelled_at"));
                        app.put("plate_number", rs.getString("plate_number"));
                        app.put("vehicle_name", rs.getString("vehicle_name"));

                        Object pendingChangeId = rs.getObject("pending_change_id");
                        app.put("pending_change_id", pendingChangeId);
                        app.put("pending_new_use_date", rs.getDate("pending_new_use_date"));
                        app.put("pending_new_start_time", rs.getTime("pending_new_start_time"));
                        app.put("pending_new_return_date", rs.getDate("pending_new_return_date"));
                        app.put("pending_new_return_time", rs.getTime("pending_new_return_time"));
                        app.put("pending_change_reason", rs.getString("pending_change_reason"));

                        applications.add(app);
                    }
                }
            }

            counts.put("PENDING", 0);
            counts.put("APPROVED", 0);
            counts.put("REJECTED", 0);
            counts.put("CANCELLED", 0);

            try (PreparedStatement ps = con.prepareStatement(countSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    int all = 0;
                    while (rs.next()) {
                        String status = rs.getString("status");
                        int total = rs.getInt("total");
                        counts.put(status, total);
                        all += total;
                    }
                    counts.put("ALL", all);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Tidak dapat memuatkan permohonan kenderaan.", e);
        }

        request.setAttribute("applications", applications);
        request.setAttribute("counts", counts);
        request.setAttribute("selectedStatus", selectedStatus);
        request.setAttribute("pageTitle", "Permohonan Kenderaan Saya");
        request.getRequestDispatcher("/my-vehicle-applications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();
        String action = clean(request.getParameter("action"));

        try {
            if ("cancel".equals(action)) {
                cancelApplication(request, response, userId);
                return;
            }

            if ("requestChange".equals(action)) {
                requestChange(request, response, userId);
                return;
            }

            redirectError(request, response, "Tindakan tidak sah.");

        } catch (SQLException e) {
            throw new ServletException("Operasi permohonan kenderaan gagal.", e);
        }
    }

    private void cancelApplication(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws SQLException, IOException {

        int applicationId = parseId(request.getParameter("id"));
        String reason = clean(request.getParameter("cancellation_reason"));

        if (applicationId <= 0) {
            redirectError(request, response, "Permohonan tidak sah.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                String lockSql = """
                    SELECT id, status, use_date, start_time
                    FROM vehicle_applications
                    WHERE id = ? AND user_id = ?
                    FOR UPDATE
                """;

                String status;
                LocalDateTime start;

                try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                    ps.setInt(1, applicationId);
                    ps.setInt(2, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            redirectError(request, response, "Permohonan tidak ditemui.");
                            return;
                        }

                        status = rs.getString("status");
                        start = LocalDateTime.of(
                                rs.getDate("use_date").toLocalDate(),
                                rs.getTime("start_time").toLocalTime()
                        );
                    }
                }

                if (!"PENDING".equals(status) && !"APPROVED".equals(status)) {
                    con.rollback();
                    redirectError(request, response, "Permohonan ini tidak boleh dibatalkan.");
                    return;
                }

                if ("APPROVED".equals(status)) {
                    if (reason.isBlank()) {
                        con.rollback();
                        redirectError(request, response,
                                "Sila masukkan sebab pembatalan untuk tempahan yang telah diluluskan.");
                        return;
                    }

                    if (!LocalDateTime.now().isBefore(start)) {
                        con.rollback();
                        redirectError(request, response,
                                "Tempahan tidak boleh dibatalkan selepas waktu penggunaan bermula.");
                        return;
                    }
                }

                String updateSql = """
                    UPDATE vehicle_applications
                    SET status = 'CANCELLED',
                        cancellation_reason = ?,
                        cancelled_by = ?,
                        cancelled_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ? AND user_id = ?
                """;

                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    if (reason.isBlank()) {
                        ps.setNull(1, java.sql.Types.VARCHAR);
                    } else {
                        ps.setString(1, reason);
                    }
                    ps.setInt(2, userId);
                    ps.setInt(3, applicationId);
                    ps.setInt(4, userId);
                    ps.executeUpdate();
                }

                String cancelPendingChangeSql = """
                    UPDATE vehicle_application_changes
                    SET status = 'CANCELLED'
                    WHERE application_id = ?
                      AND status = 'PENDING'
                """;

                try (PreparedStatement ps = con.prepareStatement(cancelPendingChangeSql)) {
                    ps.setInt(1, applicationId);
                    ps.executeUpdate();
                }

                ActivityLogUtil.log(con, request, "CANCEL_VEHICLE_APPLICATION",
                        "Membatalkan permohonan kenderaan #" + applicationId
                                + (reason.isBlank() ? "." : ". Sebab: " + reason),
                        "VEHICLE_APPLICATION", applicationId);

                con.commit();
                redirectSuccess(request, response, "Permohonan kenderaan berjaya dibatalkan.");

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private void requestChange(
            HttpServletRequest request,
            HttpServletResponse response,
            int userId) throws SQLException, IOException {

        int applicationId = parseId(request.getParameter("id"));
        String newUseDateValue = clean(request.getParameter("new_use_date"));
        String newStartTimeValue = clean(request.getParameter("new_start_time"));
        String newReturnDateValue = clean(request.getParameter("new_return_date"));
        String newReturnTimeValue = clean(request.getParameter("new_return_time"));
        String reason = clean(request.getParameter("change_reason"));

        if (applicationId <= 0
                || newUseDateValue.isBlank()
                || newStartTimeValue.isBlank()
                || newReturnDateValue.isBlank()
                || newReturnTimeValue.isBlank()
                || reason.isBlank()) {
            redirectError(request, response, "Sila lengkapkan semua maklumat perubahan.");
            return;
        }

        LocalDateTime newStart;
        LocalDateTime newEnd;

        try {
            newStart = LocalDateTime.of(
                    java.time.LocalDate.parse(newUseDateValue),
                    java.time.LocalTime.parse(newStartTimeValue)
            );
            newEnd = LocalDateTime.of(
                    java.time.LocalDate.parse(newReturnDateValue),
                    java.time.LocalTime.parse(newReturnTimeValue)
            );
        } catch (Exception e) {
            redirectError(request, response, "Tarikh atau masa perubahan tidak sah.");
            return;
        }

        if (!newEnd.isAfter(newStart)) {
            redirectError(request, response,
                    "Tarikh dan masa pulang baharu mestilah selepas tarikh dan masa mula.");
            return;
        }

        if (newStart.isBefore(LocalDateTime.now())) {
            redirectError(request, response,
                    "Tarikh dan masa mula baharu tidak boleh sebelum waktu semasa.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                String lockSql = """
                    SELECT
                        id, status, vehicle_id,
                        use_date, start_time,
                        expected_return_date, expected_return_time
                    FROM vehicle_applications
                    WHERE id = ? AND user_id = ?
                    FOR UPDATE
                """;

                int vehicleId;
                Date oldUseDate;
                Time oldStartTime;
                Date oldReturnDate;
                Time oldReturnTime;

                try (PreparedStatement ps = con.prepareStatement(lockSql)) {
                    ps.setInt(1, applicationId);
                    ps.setInt(2, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            redirectError(request, response, "Permohonan tidak ditemui.");
                            return;
                        }

                        if (!"APPROVED".equals(rs.getString("status"))) {
                            con.rollback();
                            redirectError(request, response,
                                    "Hanya tempahan yang telah diluluskan boleh dipohon perubahan.");
                            return;
                        }

                        LocalDateTime oldStart = LocalDateTime.of(
                                rs.getDate("use_date").toLocalDate(),
                                rs.getTime("start_time").toLocalTime()
                        );

                        if (!LocalDateTime.now().isBefore(oldStart)) {
                            con.rollback();
                            redirectError(request, response,
                                    "Perubahan tidak dibenarkan selepas penggunaan kenderaan bermula.");
                            return;
                        }

                        vehicleId = rs.getInt("vehicle_id");
                        oldUseDate = rs.getDate("use_date");
                        oldStartTime = rs.getTime("start_time");
                        oldReturnDate = rs.getDate("expected_return_date");
                        oldReturnTime = rs.getTime("expected_return_time");
                    }
                }

                String pendingSql = """
                    SELECT id
                    FROM vehicle_application_changes
                    WHERE application_id = ?
                      AND status = 'PENDING'
                    LIMIT 1
                """;

                try (PreparedStatement ps = con.prepareStatement(pendingSql)) {
                    ps.setInt(1, applicationId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            con.rollback();
                            redirectError(request, response,
                                    "Permohonan perubahan untuk tempahan ini masih menunggu semakan.");
                            return;
                        }
                    }
                }

                // Early conflict feedback. Admin must check again during approval.
                String conflictSql = """
                    SELECT va.id
                    FROM vehicle_applications va
                    WHERE va.vehicle_id = ?
                      AND va.status = 'APPROVED'
                      AND va.id <> ?
                      AND TIMESTAMP(va.use_date, va.start_time) < ?
                      AND (
                            CASE
                                WHEN va.actual_return_date IS NOT NULL
                                 AND va.actual_return_time IS NOT NULL
                                THEN TIMESTAMP(va.actual_return_date, va.actual_return_time)
                                ELSE TIMESTAMP(
                                    COALESCE(va.expected_return_date, va.use_date),
                                    va.expected_return_time
                                )
                            END
                          ) > ?
                    LIMIT 1
                """;

                try (PreparedStatement ps = con.prepareStatement(conflictSql)) {
                    ps.setInt(1, vehicleId);
                    ps.setInt(2, applicationId);
                    ps.setTimestamp(3, Timestamp.valueOf(newEnd));
                    ps.setTimestamp(4, Timestamp.valueOf(newStart));

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            con.rollback();
                            redirectError(request, response,
                                    "Tarikh atau masa baharu bertindih dengan tempahan lain yang telah diluluskan.");
                            return;
                        }
                    }
                }

                String insertSql = """
                    INSERT INTO vehicle_application_changes
                    (
                        application_id,
                        requested_by,
                        old_use_date,
                        old_start_time,
                        old_return_date,
                        old_return_time,
                        new_use_date,
                        new_start_time,
                        new_return_date,
                        new_return_time,
                        reason,
                        status
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')
                """;

                try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                    ps.setInt(1, applicationId);
                    ps.setInt(2, userId);
                    ps.setDate(3, oldUseDate);
                    ps.setTime(4, oldStartTime);
                    ps.setDate(5, oldReturnDate);
                    ps.setTime(6, oldReturnTime);
                    ps.setDate(7, Date.valueOf(newStart.toLocalDate()));
                    ps.setTime(8, Time.valueOf(newStart.toLocalTime()));
                    ps.setDate(9, Date.valueOf(newEnd.toLocalDate()));
                    ps.setTime(10, Time.valueOf(newEnd.toLocalTime()));
                    ps.setString(11, reason);
                    ps.executeUpdate();
                }

                ActivityLogUtil.log(con, request, "CREATE_VEHICLE_CHANGE",
                        "Menghantar permohonan perubahan untuk tempahan kenderaan #" + applicationId
                                + " kepada " + newStart + " hingga " + newEnd + ".",
                        "VEHICLE_APPLICATION_CHANGE", applicationId);

                con.commit();
                redirectSuccess(request, response,
                        "Permohonan perubahan berjaya dihantar dan sedang menunggu semakan Admin/HR.");

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(clean(value));
        } catch (Exception e) {
            return -1;
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private void redirectSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            String message) throws IOException {
        response.sendRedirect(
                request.getContextPath()
                        + "/my-vehicle-applications?success="
                        + encode(message)
        );
    }

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message) throws IOException {
        response.sendRedirect(
                request.getContextPath()
                        + "/my-vehicle-applications?error="
                        + encode(message)
        );
    }
}
