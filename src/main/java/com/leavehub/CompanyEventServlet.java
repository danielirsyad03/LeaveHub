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
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/company-events")
public class CompanyEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) { response.sendRedirect(request.getContextPath() + "/"); return; }
        if (!isHr(session)) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Akses hanya dibenarkan kepada HR/Admin."); return; }
        try (Connection con = DBConnection.getConnection()) {
            request.setAttribute("events", loadEvents(con));
            request.getRequestDispatcher("/company-events.jsp").forward(request, response);
        } catch (SQLException e) { throw new ServletException("Tidak dapat memuatkan aktiviti syarikat.", e); }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) { response.sendRedirect(request.getContextPath() + "/"); return; }
        if (!isHr(session)) { response.sendError(HttpServletResponse.SC_FORBIDDEN, "Akses hanya dibenarkan kepada HR/Admin."); return; }
        int userId = parseUserId(session.getAttribute("userId"));
        String action = clean(request.getParameter("action"));
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                if ("saveEvent".equals(action)) saveEvent(con, request, userId);
                else if ("deleteEvent".equals(action)) deleteEvent(con, positiveId(request.getParameter("id")));
                else throw new IllegalArgumentException("Tindakan aktiviti tidak sah.");
                con.commit(); session.setAttribute("eventSuccess", "Aktiviti berjaya disimpan.");
            } catch (Exception e) {
                try { con.rollback(); } catch (SQLException ignored) {}
                session.setAttribute("eventError", safeMessage(e));
            } finally { try { con.setAutoCommit(true); } catch (SQLException ignored) {} }
        } catch (SQLException e) { throw new ServletException("Tidak dapat menyimpan aktiviti.", e); }
        response.sendRedirect(request.getContextPath() + "/company-events");
    }

    
      

    private void saveEvent(Connection con, HttpServletRequest req, int userId) throws Exception {
        int id = optionalId(req.getParameter("event_id"));
        String title = required(req.getParameter("event_title"), "Nama aktiviti");
        String description = clean(req.getParameter("event_description"));
        String location = clean(req.getParameter("location"));
        String dateText = required(req.getParameter("event_date"), "Tarikh aktiviti");
        String startText = clean(req.getParameter("start_time"));
        String endText = clean(req.getParameter("end_time"));
        String status = "PUBLISHED";

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

    private void deleteEvent(Connection con, int id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM company_events WHERE id=?")) {
            ps.setInt(1, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Aktiviti tidak dijumpai.");
        }
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
