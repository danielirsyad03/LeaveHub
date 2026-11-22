package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/attendance-records")
public class AttendanceRecordsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }
        if (!"HR".equalsIgnoreCase(sessionString(session, "userRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Akses hanya dibenarkan untuk Pentadbir Sistem.");
            return;
        }

        LocalDate selectedDate = parseDate(req.getParameter("date"));
        try (Connection con = DBConnection.getConnection()) {
            List<Map<String, Object>> records = loadAttendanceRecords(con, selectedDate);
            req.setAttribute("selectedDate", selectedDate);
            req.setAttribute("records", records);
            req.setAttribute("summary", buildSummary(records));
            req.getRequestDispatcher("/attendance-records.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Tidak dapat memuatkan rekod kehadiran.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }
        if (!"HR".equalsIgnoreCase(sessionString(session, "userRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Akses hanya dibenarkan untuk Pentadbir Sistem.");
            return;
        }

        int adminId;
        try {
            adminId = Integer.parseInt(String.valueOf(session.getAttribute("userId")));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        LocalDate date = parseDate(req.getParameter("attendanceDate"));
        Integer staffId = parseInteger(req.getParameter("staffId"));
        String checkInText = trim(req.getParameter("checkInTime"));
        String checkOutText = trim(req.getParameter("checkOutTime"));
        String adminNote = trim(req.getParameter("adminNote"));

        if (staffId == null || adminNote.isBlank()) {
            redirectWithMessage(req, resp, date, "error", "Sila pilih staf dan masukkan sebab pembetulan.");
            return;
        }

        LocalDateTime checkIn;
        LocalDateTime checkOut;
        try {
            checkIn = checkInText.isBlank() ? null : LocalDateTime.parse(checkInText);
            checkOut = checkOutText.isBlank() ? null : LocalDateTime.parse(checkOutText);
        } catch (Exception e) {
            redirectWithMessage(req, resp, date, "error", "Format masa tidak sah. Sila pilih tarikh dan masa yang betul.");
            return;
        }

        if (checkOut != null && checkIn == null) {
            redirectWithMessage(req, resp, date, "error", "Masa Check In perlu diisi sebelum masa Check Out.");
            return;
        }
        if (checkIn != null && !checkIn.toLocalDate().equals(date)) {
            redirectWithMessage(req, resp, date, "error", "Tarikh Check In mesti sama dengan tarikh rekod yang dipilih.");
            return;
        }
        if (checkOut != null && !checkOut.toLocalDate().equals(date)) {
            redirectWithMessage(req, resp, date, "error", "Tarikh Check Out mesti sama dengan tarikh rekod yang dipilih.");
            return;
        }
        if (checkIn != null && checkOut != null && checkOut.isBefore(checkIn)) {
            redirectWithMessage(req, resp, date, "error", "Masa Check Out tidak boleh lebih awal daripada Check In.");
            return;
        }
        if (adminNote.length() > 1000) adminNote = adminNote.substring(0, 1000);

        String status = checkIn == null ? "BELUM_HADIR" : (checkOut == null ? "HADIR" : "SELESAI");
        try (Connection con = DBConnection.getConnection()) {
            boolean exists;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM attendance WHERE user_id = ? AND attendance_date = ? LIMIT 1")) {
                ps.setInt(1, staffId);
                ps.setDate(2, Date.valueOf(date));
                try (ResultSet rs = ps.executeQuery()) { exists = rs.next(); }
            }

            if (exists) {
                String sql = """
                    UPDATE attendance SET
                        check_in = ?, check_out = ?, status = ?,
                        admin_modified_by = ?, admin_note = ?, updated_at = CURRENT_TIMESTAMP
                    WHERE user_id = ? AND attendance_date = ?
                    """;
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    setTimestampOrNull(ps, 1, checkIn);
                    setTimestampOrNull(ps, 2, checkOut);
                    ps.setString(3, status);
                    ps.setInt(4, adminId);
                    ps.setString(5, adminNote);
                    ps.setInt(6, staffId);
                    ps.setDate(7, Date.valueOf(date));
                    ps.executeUpdate();
                }
            } else {
                String sql = """
                    INSERT INTO attendance
                        (user_id, attendance_date, check_in, check_out, status,
                         admin_modified_by, admin_note, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    """;
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, staffId);
                    ps.setDate(2, Date.valueOf(date));
                    setTimestampOrNull(ps, 3, checkIn);
                    setTimestampOrNull(ps, 4, checkOut);
                    ps.setString(5, status);
                    ps.setInt(6, adminId);
                    ps.setString(7, adminNote);
                    ps.executeUpdate();
                }
            }
            ActivityLogUtil.log(con, req, "UPDATE_ATTENDANCE_RECORD",
                    "Mengemas kini rekod kehadiran staf ID " + staffId + " untuk " + date
                            + " (status: " + status + ").",
                    "ATTENDANCE", staffId + "-" + date);
            redirectWithMessage(req, resp, date, "success", "Rekod kehadiran staf berjaya dikemaskini.");
        } catch (SQLException e) {
            throw new ServletException("Tidak dapat mengemaskini rekod kehadiran.", e);
        }
    }

    private List<Map<String, Object>> loadAttendanceRecords(Connection con, LocalDate date) throws SQLException {
        List<Map<String, Object>> records = new ArrayList<>();
        String sql = """
            SELECT u.id AS user_id, u.name, u.position, u.department,
                   a.attendance_date, a.check_in, a.check_out,
                   a.check_in_distance, a.check_out_distance,
                   a.check_in_latitude, a.check_in_longitude,
                   a.check_out_latitude, a.check_out_longitude,
                   a.late_reason, a.early_checkout_reason, a.admin_note,
                   a.admin_modified_by, a.status,
                   la.leave_type AS approved_leave_type,
                   la.start_date AS approved_leave_start,
                   la.end_date AS approved_leave_end
            FROM users u
            LEFT JOIN attendance a ON a.user_id = u.id AND a.attendance_date = ?
            LEFT JOIN leave_applications la ON la.id = (
                SELECT MAX(la2.id) FROM leave_applications la2
                WHERE la2.user_id = u.id AND la2.status = 'APPROVED'
                  AND la2.start_date <= ? AND la2.end_date >= ?
            )
            ORDER BY u.name ASC
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            ps.setDate(2, Date.valueOf(date));
            ps.setDate(3, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("userId", rs.getInt("user_id"));
                    row.put("name", rs.getString("name"));
                    row.put("position", rs.getString("position"));
                    row.put("department", rs.getString("department"));
                    row.put("attendanceDate", rs.getDate("attendance_date"));
                    row.put("checkIn", rs.getTimestamp("check_in"));
                    row.put("checkOut", rs.getTimestamp("check_out"));
                    row.put("checkInDistance", rs.getObject("check_in_distance"));
                    row.put("checkOutDistance", rs.getObject("check_out_distance"));
                    row.put("checkInLatitude", rs.getObject("check_in_latitude"));
                    row.put("checkInLongitude", rs.getObject("check_in_longitude"));
                    row.put("checkOutLatitude", rs.getObject("check_out_latitude"));
                    row.put("checkOutLongitude", rs.getObject("check_out_longitude"));
                    row.put("lateReason", rs.getString("late_reason"));
                    row.put("earlyCheckoutReason", rs.getString("early_checkout_reason"));
                    row.put("adminNote", rs.getString("admin_note"));
                    row.put("adminModifiedBy", rs.getObject("admin_modified_by"));
                    row.put("approvedLeaveType", rs.getString("approved_leave_type"));
                    row.put("approvedLeaveStart", rs.getDate("approved_leave_start"));
                    row.put("approvedLeaveEnd", rs.getDate("approved_leave_end"));
                    String status = rs.getString("status");
                    row.put("status", status == null || status.isBlank() ? "BELUM_HADIR" : status);
                    records.add(row);
                }
            }
        }
        return records;
    }

    private Map<String, Integer> buildSummary(List<Map<String, Object>> records) {
        Map<String, Integer> summary = new HashMap<>();
        int total = records.size(), hadir = 0, selesai = 0, belum = 0;
        for (Map<String, Object> row : records) {
            String status = String.valueOf(row.get("status"));
            if ("SELESAI".equalsIgnoreCase(status)) selesai++;
            else if ("HADIR".equalsIgnoreCase(status)) hadir++;
            else belum++;
        }
        summary.put("total", total);
        summary.put("hadir", hadir);
        summary.put("selesai", selesai);
        summary.put("belumHadir", belum);
        return summary;
    }

    private void setTimestampOrNull(PreparedStatement ps, int index, LocalDateTime value) throws SQLException {
        if (value == null) ps.setNull(index, java.sql.Types.TIMESTAMP);
        else ps.setTimestamp(index, Timestamp.valueOf(value));
    }

    private void redirectWithMessage(HttpServletRequest req, HttpServletResponse resp,
            LocalDate date, String type, String message) throws IOException {
        HttpSession session = req.getSession();
        session.setAttribute("attendanceRecords" + ("success".equals(type) ? "Success" : "Error"), message);
        resp.sendRedirect(req.getContextPath() + "/attendance-records?date=" + date);
    }

    private Integer parseInteger(String value) {
        try { return value == null || value.isBlank() ? null : Integer.valueOf(value); }
        catch (NumberFormatException e) { return null; }
    }

    private LocalDate parseDate(String value) {
        try { return value == null || value.isBlank() ? LocalDate.now() : LocalDate.parse(value); }
        catch (Exception e) { return LocalDate.now(); }
    }

    private String trim(String value) { return value == null ? "" : value.trim(); }

    private String sessionString(HttpSession session, String name) {
        Object value = session.getAttribute(name);
        return value == null ? "" : value.toString().trim();
    }
}
