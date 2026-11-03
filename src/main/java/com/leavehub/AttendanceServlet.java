package com.leavehub;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.DayOfWeek;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /*
     * ============================================================
     * LOKASI PEJABAT PKB
     * ============================================================
     *
     * Gunakan koordinat yang telah digunakan semasa ujian anda.
     */
    private static final double OFFICE_LATITUDE = 6.12358;
    private static final double OFFICE_LONGITUDE = 100.37186;
    private static final double OFFICE_RADIUS_METERS = 100.0;


    // ============================================================
    // GET
    // ============================================================

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        Integer userId = getUserId(session);

        if (userId == null) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        String role = getSessionRole(session);

        try (Connection con = DBConnection.getConnection()) {

            // Rekod pengguna yang sedang login.
            Map<String, Object> attendance =
                    loadTodayAttendance(con, userId);

            req.setAttribute("attendance", attendance);

            Map<String, Object> approvedLeave =
                    loadApprovedLeave(con, userId, LocalDate.now());
            req.setAttribute("approvedLeave", approvedLeave);
            req.setAttribute("hasApprovedLeave", approvedLeave != null);

            /*
             * HR boleh melihat rekod semua pengguna.
             * Staff biasa hanya melihat rekod sendiri.
             */
            if ("HR".equals(role)) {

                List<Map<String, Object>> allAttendance =
                        loadAllTodayAttendance(con);

                req.setAttribute(
                    "allAttendance",
                    allAttendance
                );

                Map<String, Integer> summary =
                        buildAttendanceSummary(allAttendance);

                req.setAttribute(
                    "attendanceSummary",
                    summary
                );

                req.setAttribute(
                    "isAttendanceAdmin",
                    Boolean.TRUE
                );

            } else {

                req.setAttribute(
                    "allAttendance",
                    new ArrayList<Map<String, Object>>()
                );

                req.setAttribute(
                    "attendanceSummary",
                    new HashMap<String, Integer>()
                );

                req.setAttribute(
                    "isAttendanceAdmin",
                    Boolean.FALSE
                );
            }

            // Mesej Check In / Check Out.
            Object success =
                    session.getAttribute("attendanceSuccess");

            Object error =
                    session.getAttribute("attendanceError");

            if (success != null) {
                req.setAttribute(
                    "attendanceSuccess",
                    success.toString()
                );

                session.removeAttribute("attendanceSuccess");
            }

            if (error != null) {
                req.setAttribute(
                    "attendanceError",
                    error.toString()
                );

                session.removeAttribute("attendanceError");
            }

            req.getRequestDispatcher(
                "/attendance.jsp"
            ).forward(req, resp);

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan rekod kehadiran.",
                e
            );
        }
    }


    // ============================================================
    // POST
    // ============================================================

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        Integer userId = getUserId(session);

        if (userId == null) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        String action = trim(req.getParameter("action"));
        String latitudeText = trim(req.getParameter("latitude"));
        String longitudeText = trim(req.getParameter("longitude"));
        String lateReason = trim(req.getParameter("lateReason"));
        String earlyCheckoutReason = trim(req.getParameter("earlyCheckoutReason"));
        if (earlyCheckoutReason.length() > 1000) {
            earlyCheckoutReason = earlyCheckoutReason.substring(0, 1000);
        }
        if (lateReason.length() > 1000) {
            lateReason = lateReason.substring(0, 1000);
        }

        if (!"check_in".equals(action) && !"check_out".equals(action)) {
            setError(
                session,
                "Tindakan kehadiran tidak sah."
            );
            redirectAttendance(req, resp);
            return;
        }

        if (latitudeText.isBlank() || longitudeText.isBlank()) {
            setError(
                session,
                "Lokasi anda tidak dapat dikesan. Sila benarkan akses lokasi pada pelayar."
            );
            redirectAttendance(req, resp);
            return;
        }

        double latitude;
        double longitude;

        try {
            latitude = Double.parseDouble(latitudeText);
            longitude = Double.parseDouble(longitudeText);
        } catch (NumberFormatException e) {
            setError(
                session,
                "Koordinat lokasi tidak sah."
            );
            redirectAttendance(req, resp);
            return;
        }

        if (!validCoordinate(latitude, longitude)) {
            setError(
                session,
                "Koordinat lokasi tidak sah."
            );
            redirectAttendance(req, resp);
            return;
        }

        double distance = calculateDistance(
            latitude,
            longitude,
            OFFICE_LATITUDE,
            OFFICE_LONGITUDE
        );

        if (distance > OFFICE_RADIUS_METERS) {
            setError(
                session,
                "Anda berada di luar kawasan pejabat. Jarak anda ialah "
                + formatDistance(distance)
                + "."
            );
            redirectAttendance(req, resp);
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            if ("check_in".equals(action)) {

                Map<String, Object> approvedLeave =
                        loadApprovedLeave(con, userId, LocalDate.now());

                if (approvedLeave != null) {
                    setError(
                        session,
                        "Check In tidak dibenarkan kerana anda mempunyai cuti yang telah diluluskan pada hari ini."
                    );
                    redirectAttendance(req, resp);
                    return;
                }

                processCheckIn(
                    con,
                    session,
                    userId,
                    latitude,
                    longitude,
                    distance,
                    lateReason
                );

            } else {

                processCheckOut(
                    con,
                    session,
                    userId,
                    latitude,
                    longitude,
                    distance,
                    earlyCheckoutReason
                );
            }

        } catch (SQLException e) {

            e.printStackTrace();

            setError(
                session,
                "Ralat database semasa merekod kehadiran. Sila semak Console Tomcat."
            );
        }

        redirectAttendance(req, resp);
    }


    // ============================================================
    // CHECK IN
    // ============================================================

    private void processCheckIn(
            Connection con,
            HttpSession session,
            int userId,
            double latitude,
            double longitude,
            double distance,
            String lateReason)
            throws SQLException {

        Map<String, Object> attendance =
                loadTodayAttendance(con, userId);

        String status =
                attendance.get("status") == null
                    ? "BELUM_HADIR"
                    : attendance.get("status").toString();

        if ("HADIR".equalsIgnoreCase(status)
                || "SELESAI".equalsIgnoreCase(status)) {

            setError(
                session,
                "Anda sudah membuat Check In untuk hari ini."
            );
            return;
        }

        String sql = """
            INSERT INTO attendance (
                user_id,
                attendance_date,
                check_in,
                check_in_latitude,
                check_in_longitude,
                check_in_distance,
                late_reason,
                status
            )
            VALUES (
                ?,
                CURDATE(),
                NOW(),
                ?,
                ?,
                ?,
                ?,
                'HADIR'
            )
            ON DUPLICATE KEY UPDATE
                check_in = NOW(),
                check_in_latitude = VALUES(check_in_latitude),
                check_in_longitude = VALUES(check_in_longitude),
                check_in_distance = VALUES(check_in_distance),
                late_reason = VALUES(late_reason),
                status = 'HADIR'
            """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.setDouble(4, distance);
            ps.setString(5, lateReason == null || lateReason.isBlank() ? null : lateReason);

            ps.executeUpdate();
        }

        try {
            logActivity(
                con,
                session,
                userId,
                "ATTENDANCE_CHECK_IN",
                "Membuat Check In kehadiran. Jarak daripada pejabat: "
                    + formatDistance(distance),
                "ATTENDANCE",
                String.valueOf(userId)
            );
        } catch (SQLException logError) {
            logError.printStackTrace();
        }

        setSuccess(
            session,
            "Check In berjaya. Kehadiran anda telah direkodkan."
        );
    }


    // ============================================================
    // CHECK OUT
    // ============================================================

    private void processCheckOut(
            Connection con,
            HttpSession session,
            int userId,
            double latitude,
            double longitude,
            double distance,
            String earlyCheckoutReason)
            throws SQLException {

        Map<String, Object> attendance =
                loadTodayAttendance(con, userId);

        String status =
                attendance.get("status") == null
                    ? "BELUM_HADIR"
                    : attendance.get("status").toString();

        if ("SELESAI".equalsIgnoreCase(status)) {
            setError(
                session,
                "Anda sudah membuat Check Out untuk hari ini."
            );
            return;
        }

        if (!"HADIR".equalsIgnoreCase(status)) {
            setError(
                session,
                "Anda belum membuat Check In untuk hari ini."
            );
            return;
        }

        LocalDate today = LocalDate.now();
        LocalTime scheduledEnd = getScheduledEndTime(today);
        LocalTime currentTime = LocalTime.now();
        boolean earlyCheckout = scheduledEnd != null && currentTime.isBefore(scheduledEnd);

        if (earlyCheckout && (earlyCheckoutReason == null || earlyCheckoutReason.isBlank())) {
            setError(session, "Sebab Check Out awal wajib diisi.");
            return;
        }

        String sql = """
            UPDATE attendance
            SET
                check_out = NOW(),
                check_out_latitude = ?,
                check_out_longitude = ?,
                check_out_distance = ?,
                early_checkout_reason = ?,
                status = 'SELESAI'
            WHERE user_id = ?
              AND attendance_date = CURDATE()
              AND check_in IS NOT NULL
              AND check_out IS NULL
            """;

        int updated;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, latitude);
            ps.setDouble(2, longitude);
            ps.setDouble(3, distance);
            ps.setString(4, earlyCheckout ? earlyCheckoutReason : null);
            ps.setInt(5, userId);

            updated = ps.executeUpdate();
        }

        if (updated == 0) {
            setError(
                session,
                "Check Out tidak dapat dilakukan. Sila cuba semula."
            );
            return;
        }

        try {
            logActivity(
                con,
                session,
                userId,
                "ATTENDANCE_CHECK_OUT",
                (earlyCheckout
                    ? "Check Out awal. Sebab: " + earlyCheckoutReason + ". "
                    : "Membuat Check Out kehadiran. ")
                    + "Jarak daripada pejabat: " + formatDistance(distance),
                "ATTENDANCE",
                String.valueOf(userId)
            );
        } catch (SQLException logError) {
            logError.printStackTrace();
        }

        setSuccess(
            session,
            earlyCheckout
                ? "Check Out awal berjaya direkodkan bersama sebab yang diberikan."
                : "Check Out berjaya. Kehadiran hari ini telah lengkap."
        );
    }

    private LocalTime getScheduledEndTime(LocalDate date) {
        DayOfWeek day = date.getDayOfWeek();
        if (day == DayOfWeek.SUNDAY || day == DayOfWeek.MONDAY
                || day == DayOfWeek.TUESDAY || day == DayOfWeek.WEDNESDAY) {
            return LocalTime.of(16, 45);
        }
        if (day == DayOfWeek.THURSDAY) {
            return LocalTime.of(16, 30);
        }
        return null; // Jumaat dan Sabtu bukan hari bekerja.
    }


    // ============================================================
    // REKOD PENGGUNA SENDIRI
    // ============================================================

    private Map<String, Object> loadTodayAttendance(
            Connection con,
            int userId)
            throws SQLException {

        Map<String, Object> result =
                new HashMap<>();

        result.put("status", "BELUM_HADIR");
        result.put("checkIn", null);
        result.put("checkOut", null);
        result.put("checkInDistance", null);
        result.put("checkOutDistance", null);
        result.put("lateReason", null);
        result.put("earlyCheckoutReason", null);
        result.put("adminNote", null);
        result.put("checkInLatitude", null);
        result.put("checkInLongitude", null);
        result.put("checkOutLatitude", null);
        result.put("checkOutLongitude", null);

        String sql = """
            SELECT
                id,
                attendance_date,
                check_in,
                check_out,
                check_in_latitude,
                check_in_longitude,
                check_out_latitude,
                check_out_longitude,
                check_in_distance,
                check_out_distance,
                late_reason,
                early_checkout_reason,
                admin_note,
                status
            FROM attendance
            WHERE user_id = ?
              AND attendance_date = CURDATE()
            LIMIT 1
            """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    result.put(
                        "id",
                        rs.getInt("id")
                    );

                    result.put(
                        "date",
                        rs.getDate("attendance_date")
                    );

                    result.put(
                        "checkIn",
                        rs.getTimestamp("check_in")
                    );

                    result.put(
                        "checkOut",
                        rs.getTimestamp("check_out")
                    );

                    result.put(
                        "checkInLatitude",
                        rs.getObject("check_in_latitude")
                    );

                    result.put(
                        "checkInLongitude",
                        rs.getObject("check_in_longitude")
                    );

                    result.put(
                        "checkOutLatitude",
                        rs.getObject("check_out_latitude")
                    );

                    result.put(
                        "checkOutLongitude",
                        rs.getObject("check_out_longitude")
                    );

                    result.put(
                        "checkInDistance",
                        rs.getObject("check_in_distance")
                    );

                    result.put(
                        "checkOutDistance",
                        rs.getObject("check_out_distance")
                    );

                    result.put("lateReason", rs.getString("late_reason"));
                    result.put("earlyCheckoutReason", rs.getString("early_checkout_reason"));
                    result.put("adminNote", rs.getString("admin_note"));

                    String dbStatus =
                            rs.getString("status");

                    if (dbStatus != null && !dbStatus.isBlank()) {
                        result.put(
                            "status",
                            dbStatus
                        );
                    }
                }
            }
        }

        return result;
    }


    // ============================================================
    // REKOD SEMUA PENGGUNA UNTUK HR
    // ============================================================

    private List<Map<String, Object>> loadAllTodayAttendance(
            Connection con)
            throws SQLException {

        List<Map<String, Object>> list =
                new ArrayList<>();

        String sql = """
            SELECT
                u.id AS user_id,
                u.name,
                u.position,
                u.department,
                a.id AS attendance_id,
                a.attendance_date,
                a.check_in,
                a.check_out,
                a.check_in_latitude,
                a.check_in_longitude,
                a.check_out_latitude,
                a.check_out_longitude,
                a.check_in_distance,
                a.check_out_distance,
                a.late_reason,
                a.early_checkout_reason,
                a.admin_note,
                COALESCE(
                    a.status,
                    'BELUM_HADIR'
                ) AS attendance_status
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

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> row =
                        new HashMap<>();

                row.put("userId", rs.getInt("user_id"));
                row.put("name", rs.getString("name"));
                row.put("position", rs.getString("position"));
                row.put("department", rs.getString("department"));
                row.put("attendanceId", rs.getObject("attendance_id"));
                row.put("date", rs.getDate("attendance_date"));
                row.put("checkIn", rs.getTimestamp("check_in"));
                row.put("checkOut", rs.getTimestamp("check_out"));
                row.put("checkInLatitude", rs.getObject("check_in_latitude"));
                row.put("checkInLongitude", rs.getObject("check_in_longitude"));
                row.put("checkOutLatitude", rs.getObject("check_out_latitude"));
                row.put("checkOutLongitude", rs.getObject("check_out_longitude"));
                row.put("checkInDistance", rs.getObject("check_in_distance"));
                row.put("checkOutDistance", rs.getObject("check_out_distance"));
                row.put("lateReason", rs.getString("late_reason"));
                row.put("earlyCheckoutReason", rs.getString("early_checkout_reason"));
                row.put("adminNote", rs.getString("admin_note"));
                row.put("status", rs.getString("attendance_status"));

                list.add(row);
            }
        }

        return list;
    }


    // ============================================================
    // RINGKASAN
    // ============================================================

    private Map<String, Integer> buildAttendanceSummary(
            List<Map<String, Object>> list) {

        Map<String, Integer> summary =
                new HashMap<>();

        int total = list.size();
        int hadir = 0;
        int selesai = 0;
        int belum = 0;

        for (Map<String, Object> row : list) {

            String status =
                    row.get("status") == null
                        ? "BELUM_HADIR"
                        : row.get("status").toString();

            if ("SELESAI".equalsIgnoreCase(status)) {
                selesai++;
            } else if ("HADIR".equalsIgnoreCase(status)) {
                hadir++;
            } else {
                belum++;
            }
        }

        summary.put("total", total);
        summary.put("hadir", hadir);
        summary.put("selesai", selesai);
        summary.put("belum", belum);

        return summary;
    }


    // ============================================================
    // ACTIVITY LOG
    // ============================================================

    private void logActivity(
            Connection con,
            HttpSession session,
            int userId,
            String action,
            String description,
            String referenceType,
            String referenceId)
            throws SQLException {

        String userName =
                session.getAttribute("userName") == null
                    ? "Pengguna"
                    : session.getAttribute("userName").toString();

        String userRole =
                session.getAttribute("userRole") == null
                    ? "STAFF"
                    : session.getAttribute("userRole").toString();

        String ipAddress =
                session.getAttribute("ipAddress") == null
                    ? null
                    : session.getAttribute("ipAddress").toString();

        String sql = """
            INSERT INTO activity_logs (
                id,
                user_id,
                user_name,
                user_role,
                action,
                description,
                reference_type,
                reference_id,
                ip_address
            )
            SELECT
                COALESCE(MAX(id), 0) + 1,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?
            FROM activity_logs
            """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, userName);
            ps.setString(3, userRole);
            ps.setString(4, action);
            ps.setString(5, description);
            ps.setString(6, referenceType);
            ps.setString(7, referenceId);
            ps.setString(8, ipAddress);

            ps.executeUpdate();
        }
    }


    // ============================================================
    // SEMAK CUTI YANG TELAH DILULUSKAN
    // ============================================================

    private Map<String, Object> loadApprovedLeave(
            Connection con,
            int userId,
            LocalDate date) throws SQLException {

        String sql = """
            SELECT
                la.id,
                COALESCE(lt.leave_type_name, la.leave_type) AS leave_type,
                la.start_date,
                la.end_date
            FROM leave_applications la
            LEFT JOIN leave_types lt
                ON lt.leave_type_id = la.leave_type_id
            WHERE la.user_id = ?
              AND la.status = 'APPROVED'
              AND la.start_date <= ?
              AND la.end_date >= ?
            ORDER BY la.start_date ASC, la.id DESC
            LIMIT 1
            """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            ps.setDate(3, java.sql.Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> leave = new HashMap<>();
                    leave.put("leaveId", rs.getInt("id"));
                    leave.put("leaveType", rs.getString("leave_type"));
                    leave.put("startDate", rs.getDate("start_date"));
                    leave.put("endDate", rs.getDate("end_date"));
                    return leave;
                }
            }
        }

        return null;
    }


    // ============================================================
    // HAVERSINE
    // ============================================================

    private double calculateDistance(
            double latitude1,
            double longitude1,
            double latitude2,
            double longitude2) {

        final double earthRadius = 6371000.0;

        double lat1 = Math.toRadians(latitude1);
        double lat2 = Math.toRadians(latitude2);

        double deltaLat =
                Math.toRadians(latitude2 - latitude1);

        double deltaLon =
                Math.toRadians(longitude2 - longitude1);

        double a =
                Math.sin(deltaLat / 2)
                * Math.sin(deltaLat / 2)
                +
                Math.cos(lat1)
                * Math.cos(lat2)
                * Math.sin(deltaLon / 2)
                * Math.sin(deltaLon / 2);

        double c =
                2.0
                * Math.atan2(
                    Math.sqrt(a),
                    Math.sqrt(1.0 - a)
                );

        return earthRadius * c;
    }


    // ============================================================
    // HELPER
    // ============================================================

    private boolean validCoordinate(
            double latitude,
            double longitude) {

        return !Double.isNaN(latitude)
                && !Double.isNaN(longitude)
                && !Double.isInfinite(latitude)
                && !Double.isInfinite(longitude)
                && latitude >= -90.0
                && latitude <= 90.0
                && longitude >= -180.0
                && longitude <= 180.0;
    }


    private Integer getUserId(HttpSession session) {

        Object value =
                session.getAttribute("userId");

        if (value == null) {
            return null;
        }

        if (value instanceof Integer) {
            return (Integer) value;
        }

        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }


    private String getSessionRole(HttpSession session) {

        Object value =
                session.getAttribute("userRole");

        if (value == null) {
            return "STAFF";
        }

        return value.toString()
                .trim()
                .toUpperCase();
    }


    private String trim(String value) {

        return value == null
                ? ""
                : value.trim();
    }


    private String formatDistance(double distance) {

        if (distance < 1000.0) {

            return String.format(
                "%.0f meter",
                distance
            );
        }

        return String.format(
            "%.2f km",
            distance / 1000.0
        );
    }


    private void setSuccess(
            HttpSession session,
            String message) {

        session.setAttribute(
            "attendanceSuccess",
            message
        );

        session.removeAttribute(
            "attendanceError"
        );
    }


    private void setError(
            HttpSession session,
            String message) {

        session.setAttribute(
            "attendanceError",
            message
        );

        session.removeAttribute(
            "attendanceSuccess"
        );
    }


    private void redirectAttendance(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws IOException {

        resp.sendRedirect(
            req.getContextPath()
            + "/attendance"
        );
    }
}
