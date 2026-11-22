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
import java.sql.Timestamp;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/announcements")
public class AnnouncementManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        if (!isHr(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Akses hanya dibenarkan kepada HR/Admin.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            request.setAttribute("announcements", loadAnnouncements(con));
            request.setAttribute("events", loadEvents(con));
            request.setAttribute("staff", loadStaff(con));
            request.getRequestDispatcher("/announcements.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Tidak dapat memuatkan pengurusan pengumuman dan aktiviti.", e);
        }
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
        if (!isHr(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Akses hanya dibenarkan kepada HR/Admin.");
            return;
        }

        int userId = parseUserId(session.getAttribute("userId"));
        String action = clean(request.getParameter("action"));

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                switch (action) {
                    case "saveAnnouncement":
                        saveAnnouncement(con, request, userId);
                        break;
                    case "deleteAnnouncement":
                        deleteAnnouncement(con, positiveId(request.getParameter("id")), request);
                        break;
                    case "saveEvent":
                        saveEvent(con, request, userId);
                        break;
                    case "deleteEvent":
                        deleteEvent(con, positiveId(request.getParameter("id")), request);
                        break;
                    default:
                        throw new IllegalArgumentException("Tindakan tidak sah.");
                }
                con.commit();
                session.setAttribute("announcementSuccess", "Maklumat berjaya disimpan.");
            } catch (Exception e) {
                try { con.rollback(); } catch (SQLException ignored) {}
                session.setAttribute("announcementError", safeMessage(e));
            } finally {
                try { con.setAutoCommit(true); } catch (SQLException ignored) {}
            }
        } catch (SQLException e) {
            throw new ServletException("Tidak dapat menyimpan maklumat.", e);
        }
        response.sendRedirect(request.getContextPath() + "/announcements");
    }

    private void saveAnnouncement(Connection con, HttpServletRequest req, int userId) throws Exception {
        int id = optionalId(req.getParameter("id"));
        boolean editing = id > 0;
        String title = required(req.getParameter("title"), "Tajuk pengumuman");
        String content = required(req.getParameter("content"), "Kandungan pengumuman");
        String category = clean(req.getParameter("category"));
        String audience = clean(req.getParameter("audience_type"));
        String department = clean(req.getParameter("target_department"));
        String publishText = clean(req.getParameter("published_at"));
        String expiryText = clean(req.getParameter("expires_at"));

        if (!List.of("UMUM", "PENTING", "HR", "NOTIS").contains(category))
            throw new IllegalArgumentException("Kategori pengumuman tidak sah.");
        if (!List.of("ALL", "DEPARTMENT", "SELECTED_STAFF").contains(audience))
            throw new IllegalArgumentException("Sasaran penerima tidak sah.");
        if ("DEPARTMENT".equals(audience) && department.isBlank())
            throw new IllegalArgumentException("Sila pilih jabatan sasaran.");

        // Pengumuman terus diterbitkan apabila disimpan. Jika tarikh pada masa hadapan,
        // paparan akan menunjukkan status Dijadualkan sehingga tiba waktunya.
        Timestamp publishedAt = publishText.isBlank()
                ? new Timestamp(System.currentTimeMillis())
                : Timestamp.valueOf(LocalDateTime.parse(publishText));
        String status = "PUBLISHED";
        Timestamp expiresAt = expiryText.isBlank() ? null : Timestamp.valueOf(LocalDateTime.parse(expiryText));
        if (expiresAt != null && publishedAt != null && !expiresAt.after(publishedAt))
            throw new IllegalArgumentException("Tarikh tamat mesti selepas tarikh/waktu terbitan.");

        if (id > 0) {
            String sql = """
                UPDATE announcements
                SET title=?, content=?, category=?, audience_type=?, target_department=?,
                    status=?, published_at=?, expires_at=?
                WHERE id=?
                """;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                bindAnnouncement(ps, title, content, category, audience, department, status, publishedAt, expiresAt);
                ps.setInt(9, id);
                if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Pengumuman tidak dijumpai.");
            }
        } else {
            String sql = """
                INSERT INTO announcements
                    (title, content, category, audience_type, target_department,
                     status, published_at, expires_at, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
            try (PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                bindAnnouncement(ps, title, content, category, audience, department, status, publishedAt, expiresAt);
                ps.setInt(9, userId);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) id = keys.getInt(1);
                }
            }
        }

        try (PreparedStatement ps = con.prepareStatement("DELETE FROM announcement_recipients WHERE announcement_id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
        if ("SELECTED_STAFF".equals(audience)) {
            String[] selected = req.getParameterValues("staff_ids");
            if (selected == null || selected.length == 0)
                throw new IllegalArgumentException("Pilih sekurang-kurangnya seorang staf.");
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO announcement_recipients (announcement_id, staff_id) VALUES (?, ?)")) {
                for (String value : selected) {
                    int staffId = positiveId(value);
                    ps.setInt(1, id);
                    ps.setInt(2, staffId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }

        ActivityLogUtil.log(con, req,
                editing ? "UPDATE_ANNOUNCEMENT" : "ADD_ANNOUNCEMENT",
                (editing ? "Mengemas kini" : "Menerbitkan") + " pengumuman: " + title + ".",
                "ANNOUNCEMENT", id);
    }

    private void bindAnnouncement(PreparedStatement ps, String title, String content, String category,
            String audience, String department, String status, Timestamp publishedAt, Timestamp expiresAt)
            throws SQLException {
        ps.setString(1, title);
        ps.setString(2, content);
        ps.setString(3, category);
        ps.setString(4, audience);
        ps.setString(5, department.isBlank() ? null : department);
        ps.setString(6, status);
        if (publishedAt == null) ps.setNull(7, java.sql.Types.TIMESTAMP); else ps.setTimestamp(7, publishedAt);
        if (expiresAt == null) ps.setNull(8, java.sql.Types.TIMESTAMP); else ps.setTimestamp(8, expiresAt);
    }

    private void deleteAnnouncement(Connection con, int id, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM announcement_recipients WHERE announcement_id=?")) {
            ps.setInt(1, id); ps.executeUpdate();
        }
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM announcements WHERE id=?")) {
            ps.setInt(1, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Pengumuman tidak dijumpai.");
        }
        ActivityLogUtil.log(con, req, "DELETE_ANNOUNCEMENT",
                "Memadam pengumuman ID " + id + ".", "ANNOUNCEMENT", id);
    }

    private void saveEvent(Connection con, HttpServletRequest req, int userId) throws Exception {
        int id = optionalId(req.getParameter("event_id"));
        boolean editing = id > 0;
        String title = required(req.getParameter("event_title"), "Nama aktiviti");
        String description = clean(req.getParameter("event_description"));
        String location = clean(req.getParameter("location"));
        String dateText = required(req.getParameter("event_date"), "Tarikh aktiviti");
        String startText = clean(req.getParameter("start_time"));
        String endText = clean(req.getParameter("end_time"));
        String status = clean(req.getParameter("event_status"));

        if (!List.of("DRAFT", "PUBLISHED").contains(status))
            throw new IllegalArgumentException("Status aktiviti tidak sah.");
        Date eventDate = Date.valueOf(LocalDate.parse(dateText));
        Time startTime = startText.isBlank() ? null : Time.valueOf(LocalTime.parse(startText));
        Time endTime = endText.isBlank() ? null : Time.valueOf(LocalTime.parse(endText));
        if (startTime != null && endTime != null && endTime.before(startTime))
            throw new IllegalArgumentException("Waktu tamat mesti selepas waktu mula.");

        if (id > 0) {
            String sql = """
                UPDATE company_events
                SET title=?, description=?, event_date=?, start_time=?, end_time=?, location=?, status=?
                WHERE id=?
                """;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                bindEvent(ps, title, description, eventDate, startTime, endTime, location, status);
                ps.setInt(8, id);
                if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Aktiviti tidak dijumpai.");
            }
        } else {
            String sql = """
                INSERT INTO company_events
                    (title, description, event_date, start_time, end_time, location, status, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                bindEvent(ps, title, description, eventDate, startTime, endTime, location, status);
                ps.setInt(8, userId);
                ps.executeUpdate();
            }
        }
        ActivityLogUtil.log(con, req,
                editing ? "UPDATE_COMPANY_EVENT" : "ADD_COMPANY_EVENT",
                (editing ? "Mengemas kini" : "Menambah") + " aktiviti syarikat: " + title
                        + " pada " + eventDate + ".",
                "COMPANY_EVENT", id > 0 ? id : title);
    }

    private void bindEvent(PreparedStatement ps, String title, String description, Date eventDate,
            Time startTime, Time endTime, String location, String status) throws SQLException {
        ps.setString(1, title);
        ps.setString(2, description.isBlank() ? null : description);
        ps.setDate(3, eventDate);
        if (startTime == null) ps.setNull(4, java.sql.Types.TIME); else ps.setTime(4, startTime);
        if (endTime == null) ps.setNull(5, java.sql.Types.TIME); else ps.setTime(5, endTime);
        ps.setString(6, location.isBlank() ? null : location);
        ps.setString(7, status);
    }

    private void deleteEvent(Connection con, int id, HttpServletRequest req) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM company_events WHERE id=?")) {
            ps.setInt(1, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Aktiviti tidak dijumpai.");
        }
        ActivityLogUtil.log(con, req, "DELETE_COMPANY_EVENT",
                "Memadam aktiviti syarikat ID " + id + ".", "COMPANY_EVENT", id);
    }

    private List<Map<String, Object>> loadAnnouncements(Connection con) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = """
            SELECT a.id, a.title, a.content, a.category, a.audience_type, a.target_department,
                   a.status, a.published_at, a.expires_at, a.created_at, u.name AS creator_name
            FROM announcements a
            LEFT JOIN users u ON u.id=a.created_by
            ORDER BY a.created_at DESC, a.id DESC
            """;
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id")); row.put("title", rs.getString("title"));
                row.put("content", rs.getString("content")); row.put("category", rs.getString("category"));
                row.put("audienceType", rs.getString("audience_type"));
                row.put("targetDepartment", rs.getString("target_department"));
                row.put("status", rs.getString("status")); row.put("publishedAt", rs.getTimestamp("published_at"));
                row.put("expiresAt", rs.getTimestamp("expires_at")); row.put("createdAt", rs.getTimestamp("created_at"));
                row.put("creatorName", rs.getString("creator_name")); rows.add(row);
            }
        }
        return rows;
    }

    private List<Map<String, Object>> loadEvents(Connection con) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = """
            SELECT id, title, description, event_date, start_time, end_time, location, status
            FROM company_events
            ORDER BY event_date DESC, start_time DESC, id DESC
            """;
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id")); row.put("title", rs.getString("title"));
                row.put("description", rs.getString("description")); row.put("eventDate", rs.getDate("event_date"));
                row.put("startTime", rs.getTime("start_time")); row.put("endTime", rs.getTime("end_time"));
                row.put("location", rs.getString("location")); row.put("status", rs.getString("status"));
                rows.add(row);
            }
        }
        return rows;
    }

    private List<Map<String, Object>> loadStaff(Connection con) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT id, name, department FROM users ORDER BY department, name";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id")); row.put("name", rs.getString("name"));
                row.put("department", rs.getString("department")); rows.add(row);
            }
        }
        return rows;
    }

    private boolean isHr(HttpSession session) {
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        return role != null && "HR".equalsIgnoreCase(role.toString().trim());
    }

    private int parseUserId(Object value) {
        try { return Integer.parseInt(String.valueOf(value)); }
        catch (Exception e) { return -1; }
    }

    private int optionalId(String value) {
        if (value == null || value.isBlank()) return 0;
        return positiveId(value);
    }

    private int positiveId(String value) {
        try {
            int id = Integer.parseInt(value);
            if (id <= 0) throw new NumberFormatException();
            return id;
        } catch (Exception e) {
            throw new IllegalArgumentException("ID tidak sah.");
        }
    }

    private String required(String value, String label) {
        String result = clean(value);
        if (result.isBlank()) throw new IllegalArgumentException(label + " wajib diisi.");
        return result;
    }

    private String clean(String value) { return value == null ? "" : value.trim(); }

    private String safeMessage(Exception e) {
        String message = e.getMessage();
        return message == null || message.isBlank() ? "Operasi tidak berjaya. Sila semak data dan cuba lagi." : message;
    }
}
