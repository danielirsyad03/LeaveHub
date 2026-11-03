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
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/vehicle-calendar")
public class VehicleCalendarServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        LocalDate today = LocalDate.now();
        int year = today.getYear();
        int month = today.getMonthValue();

        String yearParam = request.getParameter("year");
        if (yearParam != null && !yearParam.isBlank()) {
            try {
                int requestedYear = Integer.parseInt(yearParam);
                if (requestedYear >= 2000 && requestedYear <= 2100) {
                    year = requestedYear;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        String monthParam = request.getParameter("month");
        if (monthParam != null && !monthParam.isBlank()) {
            try {
                int requestedMonth = Integer.parseInt(monthParam);
                if (requestedMonth >= 1 && requestedMonth <= 12) {
                    month = requestedMonth;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        YearMonth selectedMonth = YearMonth.of(year, month);
        LocalDate firstDay = selectedMonth.atDay(1);
        LocalDate lastDay = selectedMonth.atEndOfMonth();
        YearMonth previousMonth = selectedMonth.minusMonths(1);
        YearMonth nextMonth = selectedMonth.plusMonths(1);

        List<Map<String, Object>> applications = new ArrayList<>();

        /*
         * Effective return:
         * - Jika actual_return_date/time sudah direkodkan, kalendar guna masa sebenar.
         * - Jika belum, kalendar guna expected_return_date/time.
         * - Data lama yang tiada expected_return_date fallback kepada use_date.
         */
        String sql = """
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
                v.plate_number,
                v.vehicle_name,
                u.name AS applicant_name
            FROM vehicle_applications va
            INNER JOIN vehicles v ON va.vehicle_id = v.id
            INNER JOIN users u ON va.user_id = u.id
            WHERE va.status = 'APPROVED'
              AND va.use_date <= ?
              AND COALESCE(
                    va.actual_return_date,
                    va.expected_return_date,
                    va.use_date
                  ) >= ?
            ORDER BY
                va.use_date ASC,
                va.start_time ASC,
                v.plate_number ASC
        """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(lastDay));
            ps.setDate(2, java.sql.Date.valueOf(firstDay));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> app = new HashMap<>();

                    app.put("id", rs.getInt("id"));
                    app.put("application_no", rs.getString("application_no"));
                    app.put("user_id", rs.getInt("user_id"));
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

                    app.put("plate_number", rs.getString("plate_number"));
                    app.put("vehicle_name", rs.getString("vehicle_name"));
                    app.put("applicant_name", rs.getString("applicant_name"));

                    // Effective end used by calendar.
                    java.sql.Date effectiveReturnDate = rs.getDate("actual_return_date");
                    java.sql.Time effectiveReturnTime = rs.getTime("actual_return_time");

                    if (effectiveReturnDate == null) {
                        effectiveReturnDate = rs.getDate("expected_return_date");
                        effectiveReturnTime = rs.getTime("expected_return_time");
                    }

                    if (effectiveReturnDate == null) {
                        effectiveReturnDate = rs.getDate("use_date");
                    }

                    app.put("effective_return_date", effectiveReturnDate);
                    app.put("effective_return_time", effectiveReturnTime);
                    app.put("has_actual_return", rs.getDate("actual_return_date") != null);

                    applications.add(app);
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Tidak dapat memuatkan kalendar kenderaan.",
                e
            );
        }

        Map<LocalDate, List<Map<String, Object>>> applicationsByDate =
            new HashMap<>();

        for (Map<String, Object> app : applications) {

            java.sql.Date sqlStartDate =
                (java.sql.Date) app.get("use_date");

            if (sqlStartDate == null) {
                continue;
            }

            LocalDate startDate = sqlStartDate.toLocalDate();

            java.sql.Date sqlEffectiveReturnDate =
                (java.sql.Date) app.get("effective_return_date");

            LocalDate returnDate =
                sqlEffectiveReturnDate != null
                    ? sqlEffectiveReturnDate.toLocalDate()
                    : startDate;

            if (returnDate.isBefore(startDate)) {
                returnDate = startDate;
            }

            LocalDate displayStart =
                startDate.isBefore(firstDay) ? firstDay : startDate;

            LocalDate displayEnd =
                returnDate.isAfter(lastDay) ? lastDay : returnDate;

            LocalDate currentDate = displayStart;

            while (!currentDate.isAfter(displayEnd)) {
                applicationsByDate
                    .computeIfAbsent(currentDate, key -> new ArrayList<>())
                    .add(app);

                currentDate = currentDate.plusDays(1);
            }
        }

        int totalBookings = applications.size();

        Set<String> uniqueVehicles = new HashSet<>();
        for (Map<String, Object> app : applications) {
            Object plate = app.get("plate_number");

            if (plate != null && !String.valueOf(plate).isBlank()) {
                uniqueVehicles.add(String.valueOf(plate));
            }
        }

        int totalVehicles = uniqueVehicles.size();

        int todayBookings = 0;
        List<Map<String, Object>> todayApplications =
            applicationsByDate.get(today);

        if (todayApplications != null) {
            todayBookings = todayApplications.size();
        }

        request.setAttribute("today", today);
        request.setAttribute("selectedMonth", selectedMonth);
        request.setAttribute("previousMonth", previousMonth);
        request.setAttribute("nextMonth", nextMonth);

        request.setAttribute("applications", applications);
        request.setAttribute("applicationsByDate", applicationsByDate);

        request.setAttribute("totalBookings", totalBookings);
        request.setAttribute("totalVehicles", totalVehicles);
        request.setAttribute("todayBookings", todayBookings);

        request.setAttribute("pageTitle", "Kalendar Kenderaan");

        request.getRequestDispatcher("/vehicle-calendar.jsp")
               .forward(request, response);
    }
}
