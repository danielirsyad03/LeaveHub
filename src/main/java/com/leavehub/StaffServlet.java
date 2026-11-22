package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import java.time.Year;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/staff")
public class StaffServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // DEFAULT LEAVE QUOTAS
    // =========================================================

    private static final int DEFAULT_SHARED_ANNUAL_EMERGENCY = 50;
    private static final int DEFAULT_MEDICAL_LEAVE = 30;
    private static final int DEFAULT_MATERNITY_LEAVE = 98;
    private static final int DEFAULT_MARRIAGE_LEAVE = 7;
    private static final int DEFAULT_COMPASSIONATE_LEAVE = 10;


    // =========================================================
    // TEMP PASSWORD
    // =========================================================

    private static final SecureRandom RANDOM =
        new SecureRandom();


    private static final String TEMP_PASSWORD_CHARS =
        "ABCDEFGHJKLMNPQRSTUVWXYZ"
        + "abcdefghijkmnopqrstuvwxyz"
        + "23456789";


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // HR ONLY
        // =====================================================

        if (!isHR(request)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        int currentYear =
            Year.now().getValue();


        List<Map<String, Object>> staff =
            new ArrayList<>();


        List<Map<String, Object>> hods =
            new ArrayList<>();


        List<Map<String, Object>> leaveTypes =
            new ArrayList<>();


        // =====================================================
        // USERS
        // =====================================================

        String staffSql = """

            SELECT
                u.id,
                u.name,
                u.position,
                u.email,
                u.role,
                u.department,
                u.hod_id,
                h.name AS hod_name,
                u.force_password_change

            FROM users u

            LEFT JOIN users h
                ON u.hod_id = h.id

            ORDER BY
                CASE u.role
                    WHEN 'HR' THEN 1
                    WHEN 'MANAGEMENT' THEN 2
                    WHEN 'HOD' THEN 3
                    WHEN 'STAFF' THEN 4
                    ELSE 5
                END,
                u.name ASC

        """;


        // =====================================================
        // HODS
        // =====================================================

        String hodSql = """

            SELECT
                id,
                name,
                position,
                department

            FROM users

            WHERE role = 'HOD'
              AND department IS NOT NULL

            ORDER BY
                department ASC,
                name ASC

        """;


        // =====================================================
        // LEAVE TYPES
        // =====================================================

        String leaveTypeSql = """

            SELECT
                leave_type_id,
                leave_type_name,
                requires_document

            FROM leave_types

            WHERE is_active = 1

            ORDER BY
                leave_type_id ASC

        """;


        // =====================================================
        // BALANCES
        // =====================================================

        String balanceSql = """

            SELECT
                lb.balance_id,
                lb.leave_type_id,
                lt.leave_type_name,
                lb.leave_year,
                lb.entitlement,
                lb.carry_forward_days,
                lb.carry_forward_used,
                lb.used_days,
                lb.remaining_days

            FROM leave_balances lb

            INNER JOIN leave_types lt
                ON lt.leave_type_id =
                   lb.leave_type_id

            WHERE lb.user_id = ?
              AND lb.leave_year = ?

            ORDER BY
                lt.leave_type_id ASC

        """;


        try (
            Connection con =
                DBConnection.getConnection()
        ) {


            // =================================================
            // LOAD USERS
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        staffSql
                    );

                ResultSet rs =
                    ps.executeQuery()
            ) {


                while (rs.next()) {


                    Map<String, Object> row =
                        new HashMap<>();


                    int userId =
                        rs.getInt(
                            "id"
                        );


                    row.put(
                        "id",
                        userId
                    );


                    row.put(
                        "name",
                        rs.getString(
                            "name"
                        )
                    );


                    row.put(
                        "position",
                        rs.getString(
                            "position"
                        )
                    );


                    row.put(
                        "email",
                        rs.getString(
                            "email"
                        )
                    );


                    row.put(
                        "role",
                        rs.getString(
                            "role"
                        )
                    );


                    row.put(
                        "department",
                        rs.getString(
                            "department"
                        )
                    );


                    int hodId =
                        rs.getInt(
                            "hod_id"
                        );


                    if (rs.wasNull()) {

                        row.put(
                            "hodId",
                            null
                        );

                    } else {

                        row.put(
                            "hodId",
                            hodId
                        );
                    }


                    row.put(
                        "hodName",
                        rs.getString(
                            "hod_name"
                        )
                    );


                    row.put(
                        "forcePasswordChange",
                        rs.getBoolean(
                            "force_password_change"
                        )
                    );


                    // =========================================
                    // CURRENT YEAR BALANCES
                    // =========================================

                    List<Map<String, Object>> balances =
                        new ArrayList<>();


                    try (
                        PreparedStatement balancePs =
                            con.prepareStatement(
                                balanceSql
                            )
                    ) {


                        balancePs.setInt(
                            1,
                            userId
                        );


                        balancePs.setInt(
                            2,
                            currentYear
                        );


                        try (
                            ResultSet balanceRs =
                                balancePs.executeQuery()
                        ) {


                            while (
                                balanceRs.next()
                            ) {


                                Map<String, Object> balance =
                                    new HashMap<>();


                                balance.put(
                                    "balanceId",
                                    balanceRs.getInt(
                                        "balance_id"
                                    )
                                );


                                balance.put(
                                    "leaveTypeId",
                                    balanceRs.getInt(
                                        "leave_type_id"
                                    )
                                );


                                balance.put(
                                    "leaveTypeName",
                                    balanceRs.getString(
                                        "leave_type_name"
                                    )
                                );


                                balance.put(
                                    "leaveYear",
                                    balanceRs.getInt(
                                        "leave_year"
                                    )
                                );


                                balance.put(
                                    "entitlement",
                                    balanceRs.getInt(
                                        "entitlement"
                                    )
                                );


                                balance.put(
                                    "carryForwardDays",
                                    balanceRs.getInt(
                                        "carry_forward_days"
                                    )
                                );


                                balance.put(
                                    "carryForwardUsed",
                                    balanceRs.getInt(
                                        "carry_forward_used"
                                    )
                                );


                                balance.put(
                                    "usedDays",
                                    balanceRs.getInt(
                                        "used_days"
                                    )
                                );


                                balance.put(
                                    "remainingDays",
                                    balanceRs.getInt(
                                        "remaining_days"
                                    )
                                );


                                balances.add(
                                    balance
                                );
                            }
                        }
                    }


                    row.put(
                        "balances",
                        balances
                    );


                    staff.add(
                        row
                    );
                }
            }


            // =================================================
            // LOAD HODS
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        hodSql
                    );

                ResultSet rs =
                    ps.executeQuery()
            ) {


                while (rs.next()) {


                    Map<String, Object> hod =
                        new HashMap<>();


                    hod.put(
                        "id",
                        rs.getInt(
                            "id"
                        )
                    );


                    hod.put(
                        "name",
                        rs.getString(
                            "name"
                        )
                    );


                    hod.put(
                        "position",
                        rs.getString(
                            "position"
                        )
                    );


                    hod.put(
                        "department",
                        rs.getString(
                            "department"
                        )
                    );


                    hods.add(
                        hod
                    );
                }
            }


            // =================================================
            // LOAD LEAVE TYPES
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        leaveTypeSql
                    );

                ResultSet rs =
                    ps.executeQuery()
            ) {


                while (rs.next()) {


                    Map<String, Object> leaveType =
                        new HashMap<>();


                    leaveType.put(
                        "id",
                        rs.getInt(
                            "leave_type_id"
                        )
                    );


                    leaveType.put(
                        "name",
                        rs.getString(
                            "leave_type_name"
                        )
                    );


                    leaveType.put(
                        "requiresDocument",
                        rs.getBoolean(
                            "requires_document"
                        )
                    );


                    leaveTypes.add(
                        leaveType
                    );
                }
            }


        } catch (SQLException e) {


            throw new ServletException(
                "Tidak dapat memuatkan maklumat staf.",
                e
            );
        }


        // =====================================================
        // JSP ATTRIBUTES
        // =====================================================

        request.setAttribute(
            "staff",
            staff
        );


        request.setAttribute(
            "hods",
            hods
        );


        request.setAttribute(
            "leaveTypes",
            leaveTypes
        );


        request.setAttribute(
            "currentYear",
            currentYear
        );


        request.setAttribute(
            "pageTitle",
            "Pengurusan Staf"
        );


        request
            .getRequestDispatcher(
                "/staff.jsp"
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


        if (!isHR(request)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        String action =
            clean(
                request.getParameter(
                    "action"
                )
            );


        // =====================================================
        // CLEAR TEMP PASSWORD
        //
        // Tidak perlu Audit Trail.
        // =====================================================

        if (
            "clearTemp".equalsIgnoreCase(
                action
            )
        ) {


            HttpSession session =
                request.getSession(false);


            if (session != null) {


                session.removeAttribute(
                    "temporaryPassword"
                );


                session.removeAttribute(
                    "temporaryEmail"
                );

                session.removeAttribute(
                    "temporaryPasswordReset"
                );
            }


            response.sendRedirect(
                request.getContextPath()
                + "/staff"
            );


            return;
        }


        try {


            switch (
                action.toLowerCase()
            ) {


                case "add":

                    addUser(
                        request,
                        response
                    );

                    break;


                case "edit":

                    editUser(
                        request,
                        response
                    );

                    break;


                case "delete":

                    deleteUser(
                        request,
                        response
                    );

                    break;


                case "resetpassword":

                    resetTemporaryPassword(
                        request,
                        response
                    );

                    break;


                default:

                    response.sendRedirect(
                        request.getContextPath()
                        + "/staff?error=invalidAction"
                    );

                    break;
            }


        } catch (SQLException e) {


            throw new ServletException(
                "Operasi pengurusan staf gagal.",
                e
            );
        }
    }


    // =========================================================
    // RESET TEMPORARY PASSWORD
    // =========================================================

    private void resetTemporaryPassword(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {

        int userId;

        try {
            userId = Integer.parseInt(
                clean(request.getParameter("id"))
            );
            if (userId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            redirectError(request, response, "notFound");
            return;
        }

        String email;
        String name;
        String role;
        String temporaryPassword = generateTemporaryPassword();

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                String sql = """
                    SELECT email, name, role
                    FROM users
                    WHERE id = ?
                    FOR UPDATE
                """;

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || "HR".equalsIgnoreCase(rs.getString("role"))) {
                            con.rollback();
                            redirectError(request, response, "notFound");
                            return;
                        }
                        email = rs.getString("email");
                        name = rs.getString("name");
                        role = rs.getString("role");
                    }
                }

                String updateSql = """
                    UPDATE users
                    SET password = ?, force_password_change = 1
                    WHERE id = ?
                """;
                try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setString(1, PasswordUtil.hash(temporaryPassword));
                    ps.setInt(2, userId);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException("Kata laluan sementara tidak dapat ditetapkan.");
                    }
                }

                ActivityLogUtil.log(
                    con,
                    request,
                    "RESET_TEMP_PASSWORD",
                    "Menetapkan semula kata laluan sementara untuk: " + name + " (" + role + ")",
                    "USER",
                    userId
                );
                con.commit();
            } catch (SQLException | RuntimeException e) {
                try { con.rollback(); } catch (SQLException ignored) { }
                throw e;
            } finally {
                try { con.setAutoCommit(true); } catch (SQLException ignored) { }
            }
        }

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute("temporaryPassword", temporaryPassword);
            session.setAttribute("temporaryEmail", email);
            session.setAttribute("temporaryPasswordReset", Boolean.TRUE);
        }

        response.sendRedirect(request.getContextPath() + "/staff?success=passwordReset");
    }


    // =========================================================
    // ADD USER
    // =========================================================

    private void addUser(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {


        String name =
            clean(
                request.getParameter(
                    "name"
                )
            );


        String position =
            clean(
                request.getParameter(
                    "position"
                )
            );


        String email =
            clean(
                request.getParameter(
                    "email"
                )
            ).toLowerCase();


        String role =
            normalizeRole(
                request.getParameter(
                    "role"
                )
            );


        String department =
            normalizeDepartment(
                request.getParameter(
                    "department"
                )
            );


        Integer hodId =
            parsePositiveInteger(
                request.getParameter(
                    "hodId"
                )
            );


        // =====================================================
        // BASIC VALIDATION
        // =====================================================

        if (
            name.isBlank()
            ||
            position.isBlank()
            ||
            email.isBlank()
        ) {


            redirectError(
                request,
                response,
                "invalid"
            );


            return;
        }


        if (
            name.length() > 120
        ) {


            redirectError(
                request,
                response,
                "nameLength"
            );


            return;
        }


        if (
            position.length() > 150
        ) {


            redirectError(
                request,
                response,
                "positionLength"
            );


            return;
        }


        if (
            email.length() > 160
            ||
            !isBasicEmailValid(
                email
            )
        ) {


            redirectError(
                request,
                response,
                "invalidEmail"
            );


            return;
        }


        if (
            role == null
        ) {


            redirectError(
                request,
                response,
                "invalidRole"
            );


            return;
        }


        // =====================================================
        // ROLE RULES
        // =====================================================

        if (
            "STAFF".equals(
                role
            )
        ) {


            if (
                department == null
            ) {


                redirectError(
                    request,
                    response,
                    "departmentRequired"
                );


                return;
            }


        } else if (
            "HOD".equals(
                role
            )
        ) {


            if (
                department == null
            ) {


                redirectError(
                    request,
                    response,
                    "departmentRequired"
                );


                return;
            }


            hodId =
                null;


        } else if (
            "MANAGEMENT".equals(
                role
            )
        ) {


            department =
                null;


            hodId =
                null;


        } else if (
            "HR".equals(
                role
            )
        ) {


            department =
                null;


            hodId =
                null;
        }


        Connection con =
            null;


        try {


            con =
                DBConnection
                    .getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // VALIDATE OPTIONAL HOD
            // =================================================

            if (
                "STAFF".equals(
                    role
                )
                &&
                hodId != null
                &&
                !isValidHodForDepartment(
                    con,
                    hodId,
                    department
                )
            ) {


                con.rollback();


                redirectError(
                    request,
                    response,
                    "invalidHod"
                );


                return;
            }


            // =================================================
            // EMAIL EXISTS
            // =================================================

            if (
                emailExists(
                    con,
                    email,
                    null
                )
            ) {


                con.rollback();


                redirectError(
                    request,
                    response,
                    "emailExists"
                );


                return;
            }


            // =================================================
            // TEMP PASSWORD
            // =================================================

            String temporaryPassword =
                generateTemporaryPassword();


            // =================================================
            // INSERT USER
            // =================================================

            String sql = """

                INSERT INTO users
                (
                    name,
                    position,
                    email,
                    password,
                    role,
                    department,
                    hod_id,
                    force_password_change
                )

                VALUES
                (
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    1
                )

            """;


            int newUserId;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS
                    )
            ) {


                ps.setString(
                    1,
                    name
                );


                ps.setString(
                    2,
                    position
                );


                ps.setString(
                    3,
                    email
                );


                ps.setString(
                    4,
                    PasswordUtil.hash(
                        temporaryPassword
                    )
                );


                ps.setString(
                    5,
                    role
                );


                setNullableString(
                    ps,
                    6,
                    department
                );


                setNullableInteger(
                    ps,
                    7,
                    hodId
                );


                int inserted =
                    ps.executeUpdate();


                if (
                    inserted != 1
                ) {


                    throw new SQLException(
                        "Akaun pengguna tidak dapat dicipta."
                    );
                }


                try (
                    ResultSet keys =
                        ps.getGeneratedKeys()
                ) {


                    if (!keys.next()) {


                        throw new SQLException(
                            "ID pengguna baharu tidak dapat diperoleh."
                        );
                    }


                    newUserId =
                        keys.getInt(1);
                }
            }


            // =================================================
            // CREATE DEFAULT LEAVE QUOTAS
            // =================================================
            createInitialLeaveBalances(
                con,
                newUserId,
                Year.now().getValue()
            );


            // =================================================
            // AUDIT TRAIL
            //
            // Temporary password dan password hash TIDAK
            // dimasukkan ke dalam Audit Trail.
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "ADD_USER",
                "Menambah akaun pengguna: "
                    + name
                    + " ("
                    + role
                    + ")",
                "USER",
                newUserId
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


            // =================================================
            // SAVE TEMP PASSWORD IN SESSION
            // =================================================

            HttpSession session =
                request.getSession(false);


            if (session != null) {


                session.setAttribute(
                    "temporaryPassword",
                    temporaryPassword
                );


                session.setAttribute(
                    "temporaryEmail",
                    email
                );

                session.removeAttribute(
                    "temporaryPasswordReset"
                );
            }


        } catch (SQLException e) {


            if (con != null) {


                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            throw e;


        } finally {


            if (con != null) {


                try {

                    con.setAutoCommit(
                        true
                    );

                } catch (
                    SQLException ignored
                ) {
                }


                try {

                    con.close();

                } catch (
                    SQLException ignored
                ) {
                }
            }
        }


        response.sendRedirect(
            request.getContextPath()
            + "/staff?success=added"
        );
    }


    // =========================================================
    // CREATE INITIAL LEAVE BALANCES
    // =========================================================

    private void createInitialLeaveBalances(
            Connection con,
            int userId,
            int year)
            throws SQLException {

        // Cuti Tahunan ialah master balance untuk
        // Cuti Tahunan + Cuti Kecemasan.
        // Row Cuti Kecemasan kekal 0 supaya quota tidak berganda.
        // Carry forward hanya disimpan pada row Cuti Tahunan.
        //
        // ON DUPLICATE KEY tidak reset data sedia ada kerana method
        // ini turut dipanggil semasa Edit User.

        String sql = """

            INSERT INTO leave_balances
            (
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
            )

            SELECT
                ?,
                lt.leave_type_id,
                ?,

                CASE
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti tahunan'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti kecemasan'
                        THEN 0
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti sakit'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti bersalin'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti kahwin'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti ihsan'
                        THEN ?
                    ELSE 0
                END,

                0,
                0,
                0,

                CASE
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti tahunan'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti kecemasan'
                        THEN 0
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti sakit'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti bersalin'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti kahwin'
                        THEN ?
                    WHEN TRIM(LOWER(lt.leave_type_name)) = 'cuti ihsan'
                        THEN ?
                    ELSE 0
                END

            FROM leave_types lt

            WHERE lt.is_active = 1
              AND TRIM(LOWER(lt.leave_type_name)) IN
              (
                  'cuti tahunan',
                  'cuti kecemasan',
                  'cuti sakit',
                  'cuti bersalin',
                  'cuti kahwin',
                  'cuti ihsan'
              )

            ON DUPLICATE KEY UPDATE
                user_id = VALUES(user_id)

        """;

        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            int index = 1;

            ps.setInt(index++, userId);
            ps.setInt(index++, year);

            // ENTITLEMENT
            ps.setInt(index++, DEFAULT_SHARED_ANNUAL_EMERGENCY);
            ps.setInt(index++, DEFAULT_MEDICAL_LEAVE);
            ps.setInt(index++, DEFAULT_MATERNITY_LEAVE);
            ps.setInt(index++, DEFAULT_MARRIAGE_LEAVE);
            ps.setInt(index++, DEFAULT_COMPASSIONATE_LEAVE);

            // REMAINING
            ps.setInt(index++, DEFAULT_SHARED_ANNUAL_EMERGENCY);
            ps.setInt(index++, DEFAULT_MEDICAL_LEAVE);
            ps.setInt(index++, DEFAULT_MATERNITY_LEAVE);
            ps.setInt(index++, DEFAULT_MARRIAGE_LEAVE);
            ps.setInt(index++, DEFAULT_COMPASSIONATE_LEAVE);

            ps.executeUpdate();
        }
    }


    // =========================================================
    // EDIT USER
    // =========================================================

    private void editUser(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {


        Integer id =
            parsePositiveInteger(
                request.getParameter(
                    "id"
                )
            );


        String name =
            clean(
                request.getParameter(
                    "name"
                )
            );


        String position =
            clean(
                request.getParameter(
                    "position"
                )
            );


        String email =
            clean(
                request.getParameter(
                    "email"
                )
            ).toLowerCase();


        String role =
            normalizeRole(
                request.getParameter(
                    "role"
                )
            );


        String department =
            normalizeDepartment(
                request.getParameter(
                    "department"
                )
            );


        Integer hodId =
            parsePositiveInteger(
                request.getParameter(
                    "hodId"
                )
            );


        // =====================================================
        // VALIDATION
        // =====================================================

        if (
            id == null
            ||
            name.isBlank()
            ||
            position.isBlank()
            ||
            email.isBlank()
        ) {


            redirectError(
                request,
                response,
                "invalid"
            );


            return;
        }


        if (
            name.length() > 120
        ) {


            redirectError(
                request,
                response,
                "nameLength"
            );


            return;
        }


        if (
            position.length() > 150
        ) {


            redirectError(
                request,
                response,
                "positionLength"
            );


            return;
        }


        if (
            email.length() > 160
            ||
            !isBasicEmailValid(
                email
            )
        ) {


            redirectError(
                request,
                response,
                "invalidEmail"
            );


            return;
        }


        if (
            role == null
        ) {


            redirectError(
                request,
                response,
                "invalidRole"
            );


            return;
        }


        Integer currentUserId =
            getCurrentUserId(
                request
            );


        if (
            currentUserId == null
        ) {


            response.sendRedirect(
                request.getContextPath()
                + "/"
            );


            return;
        }


        if (
            id.equals(
                currentUserId
            )
            &&
            !"HR".equals(
                role
            )
        ) {


            redirectError(
                request,
                response,
                "selfRole"
            );


            return;
        }


        // =====================================================
        // ROLE RULES
        // =====================================================

        if (
            "STAFF".equals(
                role
            )
        ) {


            if (
                department == null
            ) {


                redirectError(
                    request,
                    response,
                    "departmentRequired"
                );


                return;
            }


            if (
                hodId != null
                &&
                id.equals(
                    hodId
                )
            ) {


                redirectError(
                    request,
                    response,
                    "selfHod"
                );


                return;
            }


        } else if (
            "HOD".equals(
                role
            )
        ) {


            if (
                department == null
            ) {


                redirectError(
                    request,
                    response,
                    "departmentRequired"
                );


                return;
            }


            hodId =
                null;


        } else if (
            "MANAGEMENT".equals(
                role
            )
        ) {


            department =
                null;


            hodId =
                null;


        } else if (
            "HR".equals(
                role
            )
        ) {


            department =
                null;


            hodId =
                null;
        }


        Connection con =
            null;


        try {


            con =
                DBConnection
                    .getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // GET EXISTING USER
            //
            // Data lama diambil supaya Audit Trail boleh
            // menerangkan perubahan penting.
            // =================================================

            String currentUserSql = """

                SELECT
                    name,
                    position,
                    email,
                    role,
                    department,
                    hod_id

                FROM users

                WHERE id = ?

                FOR UPDATE

            """;


            String oldName;
            String oldPosition;
            String oldEmail;
            String oldRole;
            String oldDepartment;
            Integer oldHodId;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        currentUserSql
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


                        con.rollback();


                        redirectError(
                            request,
                            response,
                            "notFound"
                        );


                        return;
                    }


                    oldName =
                        rs.getString(
                            "name"
                        );


                    oldPosition =
                        rs.getString(
                            "position"
                        );


                    oldEmail =
                        rs.getString(
                            "email"
                        );


                    oldRole =
                        rs.getString(
                            "role"
                        );


                    oldDepartment =
                        rs.getString(
                            "department"
                        );


                    int oldHodValue =
                        rs.getInt(
                            "hod_id"
                        );


                    if (rs.wasNull()) {

                        oldHodId =
                            null;

                    } else {

                        oldHodId =
                            oldHodValue;
                    }
                }
            }


            // =================================================
            // VALIDATE OPTIONAL HOD
            // =================================================

            if (
                "STAFF".equals(
                    role
                )
                &&
                hodId != null
                &&
                !isValidHodForDepartment(
                    con,
                    hodId,
                    department
                )
            ) {


                con.rollback();


                redirectError(
                    request,
                    response,
                    "invalidHod"
                );


                return;
            }


            // =================================================
            // EMAIL EXISTS
            // =================================================

            if (
                emailExists(
                    con,
                    email,
                    id
                )
            ) {


                con.rollback();


                redirectError(
                    request,
                    response,
                    "emailExists"
                );


                return;
            }


            // =================================================
            // UPDATE USER
            // =================================================

            String updateSql = """

                UPDATE users

                SET
                    name = ?,
                    position = ?,
                    email = ?,
                    role = ?,
                    department = ?,
                    hod_id = ?

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
                    name
                );


                ps.setString(
                    2,
                    position
                );


                ps.setString(
                    3,
                    email
                );


                ps.setString(
                    4,
                    role
                );


                setNullableString(
                    ps,
                    5,
                    department
                );


                setNullableInteger(
                    ps,
                    6,
                    hodId
                );


                ps.setInt(
                    7,
                    id
                );


                int updated =
                    ps.executeUpdate();


                if (
                    updated != 1
                ) {


                    throw new SQLException(
                        "Maklumat pengguna tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // ENSURE QUOTA ROWS EXIST
            // =================================================

            createInitialLeaveBalances(
                con,
                id,
                Year.now().getValue()
            );


            // =================================================
            // OLD HOD IS NO LONGER HOD
            // =================================================

            if (
                "HOD".equalsIgnoreCase(
                    oldRole
                )
                &&
                !"HOD".equals(
                    role
                )
            ) {


                String clearHodSql = """

                    UPDATE users

                    SET hod_id = NULL

                    WHERE hod_id = ?

                """;


                try (
                    PreparedStatement ps =
                        con.prepareStatement(
                            clearHodSql
                        )
                ) {


                    ps.setInt(
                        1,
                        id
                    );


                    ps.executeUpdate();
                }
            }


            // =================================================
            // BUILD AUDIT DESCRIPTION
            // =================================================

            StringBuilder changes =
                new StringBuilder();


            if (
                !sameText(
                    oldName,
                    name
                )
            ) {

                appendChange(
                    changes,
                    "Nama: "
                        + safeText(oldName)
                        + " → "
                        + safeText(name)
                );
            }


            if (
                !sameText(
                    oldPosition,
                    position
                )
            ) {

                appendChange(
                    changes,
                    "Jawatan: "
                        + safeText(oldPosition)
                        + " → "
                        + safeText(position)
                );
            }


            if (
                !sameText(
                    oldEmail,
                    email
                )
            ) {

                appendChange(
                    changes,
                    "E-mel: "
                        + safeText(oldEmail)
                        + " → "
                        + safeText(email)
                );
            }


            if (
                !sameText(
                    oldRole,
                    role
                )
            ) {

                appendChange(
                    changes,
                    "Peranan: "
                        + safeText(oldRole)
                        + " → "
                        + safeText(role)
                );
            }


            if (
                !sameText(
                    oldDepartment,
                    department
                )
            ) {

                appendChange(
                    changes,
                    "Unit: "
                        + safeText(oldDepartment)
                        + " → "
                        + safeText(department)
                );
            }


            if (
                !sameInteger(
                    oldHodId,
                    hodId
                )
            ) {

                appendChange(
                    changes,
                    "Ketua Unit ID: "
                        + safeInteger(oldHodId)
                        + " → "
                        + safeInteger(hodId)
                );
            }


            String auditDescription =
                "Mengemaskini akaun pengguna: "
                + name
                + " ("
                + role
                + ")";


            if (
                changes.length() > 0
            ) {

                auditDescription +=
                    " — "
                    + changes;
            }


            // =================================================
            // AUDIT TRAIL
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "EDIT_USER",
                auditDescription,
                "USER",
                id
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


        } catch (SQLException e) {


            if (con != null) {


                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            throw e;


        } finally {


            if (con != null) {


                try {

                    con.setAutoCommit(
                        true
                    );

                } catch (
                    SQLException ignored
                ) {
                }


                try {

                    con.close();

                } catch (
                    SQLException ignored
                ) {
                }
            }
        }


        response.sendRedirect(
            request.getContextPath()
            + "/staff?success=edited"
        );
    }


    // =========================================================
    // DELETE USER
    // =========================================================

    private void deleteUser(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException, IOException {


        Integer id =
            parsePositiveInteger(
                request.getParameter(
                    "id"
                )
            );


        if (
            id == null
        ) {


            redirectError(
                request,
                response,
                "invalid"
            );


            return;
        }


        Integer currentUserId =
            getCurrentUserId(
                request
            );


        if (
            currentUserId == null
        ) {


            response.sendRedirect(
                request.getContextPath()
                + "/"
            );


            return;
        }


        if (
            id.equals(
                currentUserId
            )
        ) {


            redirectError(
                request,
                response,
                "selfDelete"
            );


            return;
        }


        Connection con =
            null;


        try {


            con =
                DBConnection
                    .getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // GET TARGET USER
            //
            // Name + role mesti diambil sebelum DELETE untuk
            // digunakan dalam Audit Trail.
            // =================================================

            String targetSql = """

                SELECT
                    name,
                    role

                FROM users

                WHERE id = ?

                FOR UPDATE

            """;


            String targetName;
            String targetRole;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        targetSql
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


                        con.rollback();


                        redirectError(
                            request,
                            response,
                            "notFound"
                        );


                        return;
                    }


                    targetName =
                        rs.getString(
                            "name"
                        );


                    targetRole =
                        rs.getString(
                            "role"
                        );
                }
            }


            // =================================================
            // HR CANNOT BE DELETED
            // =================================================

            if (
                "HR".equalsIgnoreCase(
                    targetRole
                )
            ) {


                con.rollback();


                redirectError(
                    request,
                    response,
                    "cannotDeleteHR"
                );


                return;
            }


            // =================================================
            // CLEAR HOD REFERENCES
            // =================================================

            if (
                "HOD".equalsIgnoreCase(
                    targetRole
                )
            ) {


                String clearSql = """

                    UPDATE users

                    SET hod_id = NULL

                    WHERE hod_id = ?

                """;


                try (
                    PreparedStatement ps =
                        con.prepareStatement(
                            clearSql
                        )
                ) {


                    ps.setInt(
                        1,
                        id
                    );


                    ps.executeUpdate();
                }
            }


            // =================================================
            // DELETE USER
            // =================================================

            String deleteSql = """

                DELETE FROM users

                WHERE id = ?

                  AND role IN
                  (
                      'STAFF',
                      'HOD',
                      'MANAGEMENT'
                  )

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


                if (
                    deleted != 1
                ) {


                    throw new SQLException(
                        "Akaun pengguna tidak dapat dipadam."
                    );
                }
            }


            // =================================================
            // AUDIT TRAIL
            //
            // Dibuat selepas DELETE tetapi sebelum COMMIT.
            // Jika Audit Trail gagal, DELETE turut rollback.
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "DELETE_USER",
                "Memadam akaun pengguna: "
                    + targetName
                    + " ("
                    + targetRole
                    + ")",
                "USER",
                id
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


        } catch (SQLException e) {


            if (con != null) {


                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            redirectError(
                request,
                response,
                "deleteReferenced"
            );


            return;


        } finally {


            if (con != null) {


                try {

                    con.setAutoCommit(
                        true
                    );

                } catch (
                    SQLException ignored
                ) {
                }


                try {

                    con.close();

                } catch (
                    SQLException ignored
                ) {
                }
            }
        }


        response.sendRedirect(
            request.getContextPath()
            + "/staff?success=deleted"
        );
    }


    // =========================================================
    // CHECK HR
    // =========================================================

    private boolean isHR(
            HttpServletRequest request) {


        HttpSession session =
            request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute(
                "userId"
            ) == null
        ) {

            return false;
        }


        Object roleObject =
            session.getAttribute(
                "userRole"
            );


        if (
            roleObject == null
        ) {

            return false;
        }


        return
            "HR".equalsIgnoreCase(
                roleObject
                    .toString()
                    .trim()
            );
    }


    // =========================================================
    // CURRENT USER
    // =========================================================

    private Integer getCurrentUserId(
            HttpServletRequest request) {


        HttpSession session =
            request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute(
                "userId"
            ) == null
        ) {

            return null;
        }


        try {


            int id =
                Integer.parseInt(
                    session
                        .getAttribute(
                            "userId"
                        )
                        .toString()
                );


            return
                id > 0
                    ? id
                    : null;


        } catch (
            NumberFormatException e
        ) {


            return null;
        }
    }


    // =========================================================
    // VALIDATE HOD
    // =========================================================

    private boolean isValidHodForDepartment(
            Connection con,
            Integer hodId,
            String department)
            throws SQLException {


        if (
            hodId == null
            ||
            department == null
        ) {

            return false;
        }


        String sql = """

            SELECT
                id

            FROM users

            WHERE id = ?
              AND role = 'HOD'
              AND department = ?

            LIMIT 1

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setInt(
                1,
                hodId
            );


            ps.setString(
                2,
                department
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                return rs.next();
            }
        }
    }


    // =========================================================
    // EMAIL EXISTS
    // =========================================================

    private boolean emailExists(
            Connection con,
            String email,
            Integer excludeId)
            throws SQLException {


        String sql;


        if (
            excludeId == null
        ) {


            sql = """

                SELECT
                    id

                FROM users

                WHERE LOWER(email) =
                      LOWER(?)

                LIMIT 1

            """;


        } else {


            sql = """

                SELECT
                    id

                FROM users

                WHERE LOWER(email) =
                      LOWER(?)

                  AND id <> ?

                LIMIT 1

            """;
        }


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setString(
                1,
                email
            );


            if (
                excludeId != null
            ) {


                ps.setInt(
                    2,
                    excludeId
                );
            }


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                return rs.next();
            }
        }
    }


    // =========================================================
    // NORMALIZE ROLE
    // =========================================================

    private String normalizeRole(
            String role) {


        if (
            role == null
            ||
            role.isBlank()
        ) {

            return null;
        }


        role =
            role
                .trim()
                .toUpperCase();


        switch (role) {


            case "STAFF":
            case "HOD":
            case "HR":
            case "MANAGEMENT":

                return role;


            default:

                return null;
        }
    }


    // =========================================================
    // NORMALIZE DEPARTMENT
    // =========================================================

    private String normalizeDepartment(
            String department) {


        if (
            department == null
            ||
            department.isBlank()
        ) {

            return null;
        }


        department =
            department
                .trim()
                .toUpperCase();


        switch (department) {


            case "PENTADBIRAN_KORPORAT":
            case "KEWANGAN":
            case "PEMBANGUNAN_PERNIAGAAN_OPERASI":

                return department;


            default:

                return null;
        }
    }


    // =========================================================
    // EMAIL VALIDATION
    // =========================================================

    private boolean isBasicEmailValid(
            String email) {


        if (
            email == null
            ||
            email.isBlank()
        ) {

            return false;
        }


        int at =
            email.indexOf(
                '@'
            );


        int lastAt =
            email.lastIndexOf(
                '@'
            );


        int dot =
            email.lastIndexOf(
                '.'
            );


        return
            at > 0
            &&
            at == lastAt
            &&
            dot > at + 1
            &&
            dot < email.length() - 1
            &&
            !email.contains(
                " "
            );
    }


    // =========================================================
    // POSITIVE INTEGER
    // =========================================================

    private Integer parsePositiveInteger(
            String value) {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            return null;
        }


        try {


            int number =
                Integer.parseInt(
                    value.trim()
                );


            return
                number > 0
                    ? number
                    : null;


        } catch (
            NumberFormatException e
        ) {


            return null;
        }
    }


    // =========================================================
    // NULLABLE STRING
    // =========================================================

    private void setNullableString(
            PreparedStatement ps,
            int index,
            String value)
            throws SQLException {


        if (
            value == null
            ||
            value.isBlank()
        ) {


            ps.setNull(
                index,
                Types.VARCHAR
            );


        } else {


            ps.setString(
                index,
                value.trim()
            );
        }
    }


    // =========================================================
    // NULLABLE INTEGER
    // =========================================================

    private void setNullableInteger(
            PreparedStatement ps,
            int index,
            Integer value)
            throws SQLException {


        if (
            value == null
        ) {


            ps.setNull(
                index,
                Types.INTEGER
            );


        } else {


            ps.setInt(
                index,
                value
            );
        }
    }


    // =========================================================
    // COMPARE TEXT
    // =========================================================

    private boolean sameText(
            String first,
            String second) {


        String firstValue =
            first == null
                ? ""
                : first.trim();


        String secondValue =
            second == null
                ? ""
                : second.trim();


        return
            firstValue.equalsIgnoreCase(
                secondValue
            );
    }


    // =========================================================
    // COMPARE INTEGER
    // =========================================================

    private boolean sameInteger(
            Integer first,
            Integer second) {


        if (
            first == null
            &&
            second == null
        ) {

            return true;
        }


        if (
            first == null
            ||
            second == null
        ) {

            return false;
        }


        return
            first.equals(
                second
            );
    }


    // =========================================================
    // SAFE TEXT FOR AUDIT
    // =========================================================

    private String safeText(
            String value) {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            return "-";
        }


        return value.trim();
    }


    // =========================================================
    // SAFE INTEGER FOR AUDIT
    // =========================================================

    private String safeInteger(
            Integer value) {


        return
            value == null
                ? "-"
                : value.toString();
    }


    // =========================================================
    // APPEND AUDIT CHANGE
    // =========================================================

    private void appendChange(
            StringBuilder builder,
            String change) {


        if (
            builder.length() > 0
        ) {

            builder.append(
                "; "
            );
        }


        builder.append(
            change
        );
    }


    // =========================================================
    // CLEAN
    // =========================================================

    private String clean(
            String value) {


        return
            value == null
                ? ""
                : value.trim();
    }


    // =========================================================
    // ERROR REDIRECT
    // =========================================================

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws IOException {


        response.sendRedirect(
            request.getContextPath()
            + "/staff?error="
            + error
        );
    }


    // =========================================================
    // TEMP PASSWORD
    // =========================================================

    private String generateTemporaryPassword() {


        StringBuilder password =
            new StringBuilder();


        for (
            int i = 0;
            i < 10;
            i++
        ) {


            password.append(
                TEMP_PASSWORD_CHARS.charAt(
                    RANDOM.nextInt(
                        TEMP_PASSWORD_CHARS.length()
                    )
                )
            );
        }


        return password.toString();
    }
}
