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
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Types;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/public-holidays")
public class PublicHolidayServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private static final DateTimeFormatter DISPLAY_DATE =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        HttpSession session =
            request.getSession(false);


        // =====================================================
        // LOGIN CHECK
        // =====================================================

        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // HR ONLY
        // =====================================================

        String role =
            getRole(session);


        if (!"HR".equals(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        // =====================================================
        // HOLIDAY LIST
        // =====================================================

        List<Map<String, Object>> holidays =
            new ArrayList<>();


        String sql = """

            SELECT
                id,
                holiday_name,
                holiday_date,
                start_date,
                end_date,
                description,
                is_active,
                created_at

            FROM public_holidays

            ORDER BY
                start_date DESC,
                end_date DESC,
                holiday_name ASC

        """;


        try (
            Connection con =
                DBConnection.getConnection();

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
                    "holidayName",
                    rs.getString("holiday_name")
                );


                row.put(
                    "startDate",
                    rs.getDate("start_date")
                );


                row.put(
                    "endDate",
                    rs.getDate("end_date")
                );


                row.put(
                    "description",
                    rs.getString("description")
                );


                row.put(
                    "active",
                    rs.getBoolean("is_active")
                );


                row.put(
                    "createdAt",
                    rs.getTimestamp("created_at")
                );


                holidays.add(row);
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan senarai cuti umum.",
                e
            );
        }


        // =====================================================
        // COUNTERS
        // =====================================================

        int totalHolidays =
            holidays.size();


        int activeHolidays =
            0;


        int inactiveHolidays =
            0;


        int currentYearHolidays =
            0;


        int currentYear =
            LocalDate.now().getYear();


        LocalDate currentYearStart =
            LocalDate.of(
                currentYear,
                1,
                1
            );


        LocalDate currentYearEnd =
            LocalDate.of(
                currentYear,
                12,
                31
            );


        for (
            Map<String, Object> holiday :
            holidays
        ) {


            boolean active =
                Boolean.TRUE.equals(
                    holiday.get("active")
                );


            if (active) {

                activeHolidays++;

            } else {

                inactiveHolidays++;
            }


            Object startObject =
                holiday.get("startDate");


            Object endObject =
                holiday.get("endDate");


            if (
                startObject instanceof Date &&
                endObject instanceof Date
            ) {


                LocalDate startDate =
                    ((Date) startObject)
                        .toLocalDate();


                LocalDate endDate =
                    ((Date) endObject)
                        .toLocalDate();


                boolean overlapsCurrentYear =
                    !endDate.isBefore(
                        currentYearStart
                    )
                    &&
                    !startDate.isAfter(
                        currentYearEnd
                    );


                if (overlapsCurrentYear) {

                    currentYearHolidays++;
                }
            }
        }


        // =====================================================
        // REQUEST ATTRIBUTES
        // =====================================================

        request.setAttribute(
            "holidays",
            holidays
        );


        request.setAttribute(
            "totalHolidays",
            totalHolidays
        );


        request.setAttribute(
            "activeHolidays",
            activeHolidays
        );


        request.setAttribute(
            "inactiveHolidays",
            inactiveHolidays
        );


        request.setAttribute(
            "currentYearHolidays",
            currentYearHolidays
        );


        request.setAttribute(
            "currentYear",
            currentYear
        );


        request.setAttribute(
            "pageTitle",
            "Pengurusan Cuti Umum"
        );


        request
            .getRequestDispatcher(
                "/public-holidays.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding(
            "UTF-8"
        );


        HttpSession session =
            request.getSession(false);


        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        String role =
            getRole(session);


        if (!"HR".equals(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        // =====================================================
        // ACTION
        // =====================================================

        String action =
            trim(
                request.getParameter("action")
            );


        if (action == null) {

            redirect(
                request,
                response,
                "invalid"
            );

            return;
        }


        try {


            switch (
                action.toLowerCase()
            ) {


                case "add":

                    addHoliday(request);


                    response.sendRedirect(
                        request.getContextPath()
                        + "/public-holidays?success=added"
                    );

                    break;


                case "update":

                    updateHoliday(request);


                    response.sendRedirect(
                        request.getContextPath()
                        + "/public-holidays?success=updated"
                    );

                    break;


                case "toggle":

                    toggleHoliday(request);


                    response.sendRedirect(
                        request.getContextPath()
                        + "/public-holidays?success=status"
                    );

                    break;


                case "delete":

                    deleteHoliday(request);


                    response.sendRedirect(
                        request.getContextPath()
                        + "/public-holidays?success=deleted"
                    );

                    break;


                default:

                    redirect(
                        request,
                        response,
                        "invalid"
                    );

                    break;
            }


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {


            redirect(
                request,
                response,
                "duplicate"
            );


        } catch (
            IllegalArgumentException e
        ) {


            redirect(
                request,
                response,
                e.getMessage()
            );


        } catch (SQLException e) {


            if (
                e.getErrorCode() == 1062
            ) {

                redirect(
                    request,
                    response,
                    "duplicate"
                );

                return;
            }


            throw new ServletException(
                "Tidak dapat mengemas kini rekod cuti umum.",
                e
            );
        }
    }


    // =========================================================
    // ADD
    // =========================================================

    private void addHoliday(
            HttpServletRequest request)
            throws SQLException {


        String holidayName =
            trim(
                request.getParameter("holidayName")
            );


        String startDateText =
            trim(
                request.getParameter("startDate")
            );


        String endDateText =
            trim(
                request.getParameter("endDate")
            );


        String description =
            trim(
                request.getParameter("description")
            );


        // =====================================================
        // REQUIRED
        // =====================================================

        if (
            holidayName == null ||
            startDateText == null ||
            endDateText == null
        ) {

            throw new IllegalArgumentException(
                "required"
            );
        }


        // =====================================================
        // LENGTH
        // =====================================================

        if (
            holidayName.length() > 150
        ) {

            throw new IllegalArgumentException(
                "nameLength"
            );
        }


        if (
            description != null &&
            description.length() > 255
        ) {

            throw new IllegalArgumentException(
                "descriptionLength"
            );
        }


        // =====================================================
        // DATES
        // =====================================================

        LocalDate startDate;
        LocalDate endDate;


        try {


            startDate =
                LocalDate.parse(
                    startDateText
                );


            endDate =
                LocalDate.parse(
                    endDateText
                );


        } catch (Exception e) {


            throw new IllegalArgumentException(
                "date"
            );
        }


        if (
            endDate.isBefore(startDate)
        ) {

            throw new IllegalArgumentException(
                "dateRange"
            );
        }


        // =====================================================
        // INSERT
        // =====================================================

        String sql = """

            INSERT INTO public_holidays
            (
                holiday_name,
                holiday_date,
                start_date,
                end_date,
                description,
                is_active
            )

            VALUES
            (
                ?,
                ?,
                ?,
                ?,
                ?,
                1
            )

        """;


        Connection con = null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(false);


            int holidayId;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS
                    )
            ) {


                ps.setString(
                    1,
                    holidayName
                );


                ps.setDate(
                    2,
                    Date.valueOf(startDate)
                );


                ps.setDate(
                    3,
                    Date.valueOf(startDate)
                );


                ps.setDate(
                    4,
                    Date.valueOf(endDate)
                );


                if (description == null) {

                    ps.setNull(
                        5,
                        Types.VARCHAR
                    );

                } else {

                    ps.setString(
                        5,
                        description
                    );
                }


                int inserted =
                    ps.executeUpdate();


                if (inserted != 1) {

                    throw new SQLException(
                        "Rekod cuti umum gagal ditambah."
                    );
                }


                try (
                    ResultSet keys =
                        ps.getGeneratedKeys()
                ) {


                    if (!keys.next()) {

                        throw new SQLException(
                            "ID cuti umum tidak dapat diperoleh."
                        );
                    }


                    holidayId =
                        keys.getInt(1);
                }
            }


            // =================================================
            // AUDIT
            // =================================================

            String auditDescription =
                "Menambah cuti umum "
                + holidayName
                + " ("
                + formatDateRange(
                    startDate,
                    endDate
                )
                + ")";


            ActivityLogUtil.log(
                con,
                request,
                "ADD_PUBLIC_HOLIDAY",
                auditDescription,
                "PUBLIC_HOLIDAY",
                holidayId
            );


            con.commit();


        } catch (
            SQLException |
            RuntimeException e
        ) {


            rollbackQuietly(con);


            throw e;


        } finally {


            closeConnection(con);
        }
    }


    // =========================================================
    // UPDATE
    // =========================================================

    private void updateHoliday(
            HttpServletRequest request)
            throws SQLException {


        Integer id =
            parsePositiveInteger(
                request.getParameter("id")
            );


        String holidayName =
            trim(
                request.getParameter("holidayName")
            );


        String startDateText =
            trim(
                request.getParameter("startDate")
            );


        String endDateText =
            trim(
                request.getParameter("endDate")
            );


        String description =
            trim(
                request.getParameter("description")
            );


        if (
            id == null ||
            holidayName == null ||
            startDateText == null ||
            endDateText == null
        ) {

            throw new IllegalArgumentException(
                "required"
            );
        }


        if (
            holidayName.length() > 150
        ) {

            throw new IllegalArgumentException(
                "nameLength"
            );
        }


        if (
            description != null &&
            description.length() > 255
        ) {

            throw new IllegalArgumentException(
                "descriptionLength"
            );
        }


        LocalDate startDate;
        LocalDate endDate;


        try {


            startDate =
                LocalDate.parse(
                    startDateText
                );


            endDate =
                LocalDate.parse(
                    endDateText
                );


        } catch (Exception e) {


            throw new IllegalArgumentException(
                "date"
            );
        }


        if (
            endDate.isBefore(startDate)
        ) {

            throw new IllegalArgumentException(
                "dateRange"
            );
        }


        Connection con = null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(false);


            // =================================================
            // LOAD OLD RECORD
            // =================================================

            String oldName;
            LocalDate oldStartDate;
            LocalDate oldEndDate;
            String oldDescription;


            String selectSql = """

                SELECT
                    holiday_name,
                    start_date,
                    end_date,
                    description

                FROM public_holidays

                WHERE id = ?

                FOR UPDATE

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        selectSql
                    )
            ) {


                ps.setInt(
                    1,
                    id
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (!rs.next()) {

                        throw new IllegalArgumentException(
                            "notFound"
                        );
                    }


                    oldName =
                        rs.getString(
                            "holiday_name"
                        );


                    oldStartDate =
                        rs.getDate(
                            "start_date"
                        ).toLocalDate();


                    oldEndDate =
                        rs.getDate(
                            "end_date"
                        ).toLocalDate();


                    oldDescription =
                        rs.getString(
                            "description"
                        );
                }
            }


            // =================================================
            // UPDATE
            // =================================================

            String updateSql = """

                UPDATE public_holidays

                SET
                    holiday_name = ?,
                    holiday_date = ?,
                    start_date = ?,
                    end_date = ?,
                    description = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateSql
                    )
            ) {


                ps.setString(
                    1,
                    holidayName
                );


                ps.setDate(
                    2,
                    Date.valueOf(startDate)
                );


                ps.setDate(
                    3,
                    Date.valueOf(startDate)
                );


                ps.setDate(
                    4,
                    Date.valueOf(endDate)
                );


                if (description == null) {

                    ps.setNull(
                        5,
                        Types.VARCHAR
                    );

                } else {

                    ps.setString(
                        5,
                        description
                    );
                }


                ps.setInt(
                    6,
                    id
                );


                int updated =
                    ps.executeUpdate();


                if (updated == 0) {

                    throw new IllegalArgumentException(
                        "notFound"
                    );
                }
            }


            // =================================================
            // BUILD CHANGE DESCRIPTION
            // =================================================

            StringBuilder changes =
                new StringBuilder();


            appendChange(
                changes,
                "Nama",
                oldName,
                holidayName
            );


            appendChange(
                changes,
                "Tarikh",
                formatDateRange(
                    oldStartDate,
                    oldEndDate
                ),
                formatDateRange(
                    startDate,
                    endDate
                )
            );


            appendChange(
                changes,
                "Keterangan",
                oldDescription,
                description
            );


            // =================================================
            // ONLY LOG IF SOMETHING ACTUALLY CHANGED
            // =================================================

            if (
                changes.length() > 0
            ) {


                String auditDescription =
                    "Mengemaskini cuti umum "
                    + holidayName
                    + " — "
                    + changes;


                ActivityLogUtil.log(
                    con,
                    request,
                    "EDIT_PUBLIC_HOLIDAY",
                    auditDescription,
                    "PUBLIC_HOLIDAY",
                    id
                );
            }


            con.commit();


        } catch (
            SQLException |
            RuntimeException e
        ) {


            rollbackQuietly(con);


            throw e;


        } finally {


            closeConnection(con);
        }
    }


    // =========================================================
    // TOGGLE ACTIVE / INACTIVE
    // =========================================================

    private void toggleHoliday(
            HttpServletRequest request)
            throws SQLException {


        Integer id =
            parsePositiveInteger(
                request.getParameter("id")
            );


        if (id == null) {

            throw new IllegalArgumentException(
                "invalid"
            );
        }


        Connection con = null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(false);


            // =================================================
            // GET CURRENT STATUS
            // =================================================

            String holidayName;
            LocalDate startDate;
            LocalDate endDate;
            boolean currentActive;


            String selectSql = """

                SELECT
                    holiday_name,
                    start_date,
                    end_date,
                    is_active

                FROM public_holidays

                WHERE id = ?

                FOR UPDATE

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        selectSql
                    )
            ) {


                ps.setInt(
                    1,
                    id
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (!rs.next()) {

                        throw new IllegalArgumentException(
                            "notFound"
                        );
                    }


                    holidayName =
                        rs.getString(
                            "holiday_name"
                        );


                    startDate =
                        rs.getDate(
                            "start_date"
                        ).toLocalDate();


                    endDate =
                        rs.getDate(
                            "end_date"
                        ).toLocalDate();


                    currentActive =
                        rs.getBoolean(
                            "is_active"
                        );
                }
            }


            boolean newActive =
                !currentActive;


            // =================================================
            // UPDATE STATUS
            // =================================================

            String updateSql = """

                UPDATE public_holidays

                SET is_active = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateSql
                    )
            ) {


                ps.setBoolean(
                    1,
                    newActive
                );


                ps.setInt(
                    2,
                    id
                );


                int updated =
                    ps.executeUpdate();


                if (updated == 0) {

                    throw new IllegalArgumentException(
                        "notFound"
                    );
                }
            }


            // =================================================
            // AUDIT
            // =================================================

            String auditAction;

            String auditDescription;


            if (newActive) {


                auditAction =
                    "ACTIVATE_PUBLIC_HOLIDAY";


                auditDescription =
                    "Mengaktifkan cuti umum "
                    + holidayName
                    + " ("
                    + formatDateRange(
                        startDate,
                        endDate
                    )
                    + ")";


            } else {


                auditAction =
                    "DEACTIVATE_PUBLIC_HOLIDAY";


                auditDescription =
                    "Menyahaktifkan cuti umum "
                    + holidayName
                    + " ("
                    + formatDateRange(
                        startDate,
                        endDate
                    )
                    + ")";
            }


            ActivityLogUtil.log(
                con,
                request,
                auditAction,
                auditDescription,
                "PUBLIC_HOLIDAY",
                id
            );


            con.commit();


        } catch (
            SQLException |
            RuntimeException e
        ) {


            rollbackQuietly(con);


            throw e;


        } finally {


            closeConnection(con);
        }
    }


    // =========================================================
    // DELETE
    // =========================================================

    private void deleteHoliday(
            HttpServletRequest request)
            throws SQLException {


        Integer id =
            parsePositiveInteger(
                request.getParameter("id")
            );


        if (id == null) {

            throw new IllegalArgumentException(
                "invalid"
            );
        }


        Connection con = null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(false);


            // =================================================
            // LOAD RECORD BEFORE DELETE
            // =================================================

            String holidayName;
            LocalDate startDate;
            LocalDate endDate;


            String selectSql = """

                SELECT
                    holiday_name,
                    start_date,
                    end_date

                FROM public_holidays

                WHERE id = ?

                FOR UPDATE

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        selectSql
                    )
            ) {


                ps.setInt(
                    1,
                    id
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (!rs.next()) {

                        throw new IllegalArgumentException(
                            "notFound"
                        );
                    }


                    holidayName =
                        rs.getString(
                            "holiday_name"
                        );


                    startDate =
                        rs.getDate(
                            "start_date"
                        ).toLocalDate();


                    endDate =
                        rs.getDate(
                            "end_date"
                        ).toLocalDate();
                }
            }


            // =================================================
            // DELETE
            // =================================================

            String deleteSql = """

                DELETE FROM public_holidays

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        deleteSql
                    )
            ) {


                ps.setInt(
                    1,
                    id
                );


                int deleted =
                    ps.executeUpdate();


                if (deleted == 0) {

                    throw new IllegalArgumentException(
                        "notFound"
                    );
                }
            }


            // =================================================
            // AUDIT
            // =================================================

            String auditDescription =
                "Memadam cuti umum "
                + holidayName
                + " ("
                + formatDateRange(
                    startDate,
                    endDate
                )
                + ")";


            ActivityLogUtil.log(
                con,
                request,
                "DELETE_PUBLIC_HOLIDAY",
                auditDescription,
                "PUBLIC_HOLIDAY",
                id
            );


            con.commit();


        } catch (
            SQLException |
            RuntimeException e
        ) {


            rollbackQuietly(con);


            throw e;


        } finally {


            closeConnection(con);
        }
    }


    // =========================================================
    // FORMAT DATE RANGE
    // =========================================================

    private String formatDateRange(
            LocalDate startDate,
            LocalDate endDate) {


        if (
            startDate == null &&
            endDate == null
        ) {

            return "Tarikh tidak diketahui";
        }


        if (startDate == null) {

            return endDate.format(
                DISPLAY_DATE
            );
        }


        if (endDate == null) {

            return startDate.format(
                DISPLAY_DATE
            );
        }


        if (
            startDate.equals(
                endDate
            )
        ) {

            return startDate.format(
                DISPLAY_DATE
            );
        }


        return
            startDate.format(
                DISPLAY_DATE
            )
            + " hingga "
            + endDate.format(
                DISPLAY_DATE
            );
    }


    // =========================================================
    // APPEND CHANGE
    // =========================================================

    private void appendChange(
            StringBuilder builder,
            String fieldName,
            String oldValue,
            String newValue) {


        String oldText =
            normalizeForComparison(
                oldValue
            );


        String newText =
            normalizeForComparison(
                newValue
            );


        if (
            oldText.equals(
                newText
            )
        ) {

            return;
        }


        if (
            builder.length() > 0
        ) {

            builder.append(
                "; "
            );
        }


        builder
            .append(fieldName)
            .append(": ")
            .append(
                displayValue(oldValue)
            )
            .append(" → ")
            .append(
                displayValue(newValue)
            );
    }


    // =========================================================
    // NORMALIZE FOR COMPARISON
    // =========================================================

    private String normalizeForComparison(
            String value) {


        if (value == null) {

            return "";
        }


        return value.trim();
    }


    // =========================================================
    // DISPLAY VALUE
    // =========================================================

    private String displayValue(
            String value) {


        if (
            value == null ||
            value.trim().isEmpty()
        ) {

            return "Tiada";
        }


        return value.trim();
    }


    // =========================================================
    // ROLE
    // =========================================================

    private String getRole(
            HttpSession session) {


        Object roleObject =
            session.getAttribute(
                "userRole"
            );


        if (roleObject == null) {

            return "";
        }


        return roleObject
            .toString()
            .trim()
            .toUpperCase();
    }


    // =========================================================
    // POSITIVE INTEGER
    // =========================================================

    private Integer parsePositiveInteger(
            String value) {


        if (
            value == null ||
            value.isBlank()
        ) {

            return null;
        }


        try {


            int number =
                Integer.parseInt(
                    value.trim()
                );


            return number > 0
                ? number
                : null;


        } catch (
            NumberFormatException e
        ) {


            return null;
        }
    }


    // =========================================================
    // TRIM
    // =========================================================

    private String trim(
            String value) {


        if (value == null) {

            return null;
        }


        value =
            value.trim();


        return value.isEmpty()
            ? null
            : value;
    }


    // =========================================================
    // ROLLBACK
    // =========================================================

    private void rollbackQuietly(
            Connection con) {


        if (con == null) {

            return;
        }


        try {

            con.rollback();

        } catch (SQLException ignored) {

        }
    }


    // =========================================================
    // CLOSE CONNECTION
    // =========================================================

    private void closeConnection(
            Connection con) {


        if (con == null) {

            return;
        }


        try {

            con.setAutoCommit(true);

        } catch (SQLException ignored) {

        }


        try {

            con.close();

        } catch (SQLException ignored) {

        }
    }


    // =========================================================
    // ERROR REDIRECT
    // =========================================================

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws IOException {


        response.sendRedirect(
            request.getContextPath()
            + "/public-holidays?error="
            + error
        );
    }
}