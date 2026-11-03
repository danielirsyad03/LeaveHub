package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Types;

import java.time.Year;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // DEFAULT QUOTAS FOR NEW USERS
    // =========================================================

    private static final int DEFAULT_SHARED_LEAVE = 50;

    private static final int DEFAULT_MEDICAL_LEAVE = 30;

    private static final int DEFAULT_MATERNITY_LEAVE = 98;

    private static final int DEFAULT_MARRIAGE_LEAVE = 7;

    private static final int DEFAULT_COMPASSIONATE_LEAVE = 10;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        loadHods(
            request
        );


        request
            .getRequestDispatcher(
                "/register.jsp"
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


        // =====================================================
        // FORM
        // =====================================================

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


        String password =
            request.getParameter(
                "password"
            );


        String confirmPassword =
            request.getParameter(
                "confirmPassword"
            );


        String department =
            clean(
                request.getParameter(
                    "department"
                )
            ).toUpperCase();


        String hodValue =
            clean(
                request.getParameter(
                    "hodId"
                )
            );


        // =====================================================
        // REQUIRED
        // HOD IS OPTIONAL
        // =====================================================

        if (
            name.isBlank()
            ||
            position.isBlank()
            ||
            email.isBlank()
            ||
            password == null
            ||
            password.isBlank()
            ||
            confirmPassword == null
            ||
            confirmPassword.isBlank()
            ||
            department.isBlank()
        ) {


            forwardError(
                request,
                response,
                "required"
            );


            return;
        }


        // =====================================================
        // NAME
        // =====================================================

        if (
            name.length() > 120
        ) {


            forwardError(
                request,
                response,
                "nameLength"
            );


            return;
        }


        // =====================================================
        // POSITION
        // =====================================================

        if (
            position.length() > 150
        ) {


            forwardError(
                request,
                response,
                "positionLength"
            );


            return;
        }


        // =====================================================
        // EMAIL
        // =====================================================

        if (
            email.length() > 160
            ||
            !isValidEmail(
                email
            )
        ) {


            forwardError(
                request,
                response,
                "invalidEmail"
            );


            return;
        }


        // =====================================================
        // PASSWORD
        // =====================================================

        if (
            password.length() < 6
            ||
            password.length() > 100
        ) {


            forwardError(
                request,
                response,
                "passwordLength"
            );


            return;
        }


        if (
            !password.equals(
                confirmPassword
            )
        ) {


            forwardError(
                request,
                response,
                "password"
            );


            return;
        }


        // =====================================================
        // DEPARTMENT
        // =====================================================

        if (
            !isValidDepartment(
                department
            )
        ) {


            forwardError(
                request,
                response,
                "department"
            );


            return;
        }


        // =====================================================
        // OPTIONAL HOD
        // =====================================================

        Integer hodId =
            null;


        if (
            hodValue != null
            &&
            !hodValue.isBlank()
        ) {


            try {


                int value =
                    Integer.parseInt(
                        hodValue
                    );


                if (
                    value <= 0
                ) {


                    forwardError(
                        request,
                        response,
                        "hod"
                    );


                    return;
                }


                hodId =
                    value;


            } catch (
                NumberFormatException e
            ) {


                forwardError(
                    request,
                    response,
                    "hod"
                );


                return;
            }
        }


        Connection con =
            null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // EMAIL DUPLICATE
            // =================================================

            if (
                emailExists(
                    con,
                    email
                )
            ) {


                con.rollback();


                forwardError(
                    request,
                    response,
                    "emailExists"
                );


                return;
            }


            // =================================================
            // VALIDATE HOD ONLY IF SELECTED
            // =================================================

            if (
                hodId != null
                &&
                !isValidHod(
                    con,
                    hodId,
                    department
                )
            ) {


                con.rollback();


                forwardError(
                    request,
                    response,
                    "hod"
                );


                return;
            }


            // =================================================
            // INSERT USER
            //
            // SELF-REGISTERED ACCOUNT:
            // ROLE ALWAYS STAFF
            // =================================================

            String insertUserSql = """

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
                    'STAFF',
                    ?,
                    ?,
                    0
                )

            """;


            int newUserId;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        insertUserSql,
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
                        password
                    )
                );


                ps.setString(
                    5,
                    department
                );


                if (
                    hodId == null
                ) {


                    ps.setNull(
                        6,
                        Types.INTEGER
                    );


                } else {


                    ps.setInt(
                        6,
                        hodId
                    );
                }


                int affected =
                    ps.executeUpdate();


                if (
                    affected != 1
                ) {


                    throw new SQLException(
                        "Akaun staf tidak dapat diwujudkan."
                    );
                }


                try (
                    ResultSet keys =
                        ps.getGeneratedKeys()
                ) {


                    if (
                        !keys.next()
                    ) {


                        throw new SQLException(
                            "ID pengguna baharu tidak dapat diperoleh."
                        );
                    }


                    newUserId =
                        keys.getInt(1);
                }
            }


            // =================================================
            // AUTO CREATE LEAVE QUOTA
            // =================================================

            int currentYear =
                Year.now().getValue();


            int createdBalances =
                createInitialLeaveBalances(
                    con,
                    newUserId,
                    currentYear
                );


            /*
             * We expect exactly these six quota rows:
             *
             * Tahunan
             * Kecemasan
             * Sakit
             * Bersalin
             * Kahwin
             * Ihsan
             */
            if (
                createdBalances < 6
            ) {


                throw new SQLException(
                    "Tidak semua rekod kuota cuti awal berjaya diwujudkan."
                );
            }


            // =================================================
            // AUDIT TRAIL
            //
            // User is not logged in yet, therefore we insert
            // the actor information directly.
            //
            // IMPORTANT:
            // Password / password hash is NEVER stored here.
            // =================================================

            insertRegistrationAuditLog(
                con,
                request,
                newUserId,
                name
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


            response.sendRedirect(
                request.getContextPath()
                + "/?success=registered"
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {


            rollbackQuietly(
                con
            );


            forwardError(
                request,
                response,
                "emailExists"
            );


        } catch (
            SQLException e
        ) {


            rollbackQuietly(
                con
            );


            throw new ServletException(
                "Tidak dapat mendaftarkan akaun staf.",
                e
            );


        } finally {


            if (
                con != null
            ) {


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
    }


    // =========================================================
    // INSERT SELF-REGISTRATION AUDIT LOG
    // =========================================================

    private void insertRegistrationAuditLog(
            Connection con,
            HttpServletRequest request,
            int userId,
            String userName)
            throws SQLException {


        String sql = """

            INSERT INTO activity_logs
            (
                user_id,
                user_name,
                user_role,
                action,
                description,
                reference_type,
                reference_id,
                ip_address
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
                ?
            )

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setInt(
                1,
                userId
            );


            ps.setString(
                2,
                userName
            );


            ps.setString(
                3,
                "STAFF"
            );


            ps.setString(
                4,
                "REGISTER_ACCOUNT"
            );


            ps.setString(
                5,
                "Mendaftar akaun pengguna sendiri"
            );


            ps.setString(
                6,
                "USER"
            );


            ps.setString(
                7,
                String.valueOf(
                    userId
                )
            );


            ps.setString(
                8,
                getClientIpAddress(
                    request
                )
            );


            int affected =
                ps.executeUpdate();


            if (
                affected != 1
            ) {


                throw new SQLException(
                    "Audit pendaftaran akaun tidak dapat direkodkan."
                );
            }
        }
    }


    // =========================================================
    // CLIENT IP ADDRESS
    // =========================================================

    private String getClientIpAddress(
            HttpServletRequest request) {


        String ip =
            request.getHeader(
                "X-Forwarded-For"
            );


        if (
            ip != null
            &&
            !ip.isBlank()
            &&
            !"unknown".equalsIgnoreCase(
                ip
            )
        ) {


            int commaIndex =
                ip.indexOf(
                    ','
                );


            if (
                commaIndex >= 0
            ) {


                ip =
                    ip.substring(
                        0,
                        commaIndex
                    );
            }


            ip =
                ip.trim();


        } else {


            ip =
                request.getRemoteAddr();
        }


        if (
            ip == null
            ||
            ip.isBlank()
        ) {


            return "UNKNOWN";
        }


        if (
            ip.length() > 45
        ) {


            return ip.substring(
                0,
                45
            );
        }


        return ip;
    }


    // =========================================================
    // LOAD HODS
    // =========================================================

    private void loadHods(
            HttpServletRequest request)
            throws ServletException {


        List<Map<String, Object>> hods =
            new ArrayList<>();


        String sql = """

            SELECT
                id,
                name,
                department

            FROM users

            WHERE role = 'HOD'
              AND department IS NOT NULL

            ORDER BY
                department ASC,
                name ASC

        """;


        try (
            Connection con =
                DBConnection.getConnection();

            PreparedStatement ps =
                con.prepareStatement(
                    sql
                );

            ResultSet rs =
                ps.executeQuery()
        ) {


            while (
                rs.next()
            ) {


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
                    "department",
                    rs.getString(
                        "department"
                    )
                );


                hods.add(
                    hod
                );
            }


        } catch (
            SQLException e
        ) {


            throw new ServletException(
                "Tidak dapat memuatkan senarai Ketua Unit.",
                e
            );
        }


        request.setAttribute(
            "hods",
            hods
        );
    }


    // =========================================================
    // EMAIL EXISTS
    // =========================================================

    private boolean emailExists(
            Connection con,
            String email)
            throws SQLException {


        String sql = """

            SELECT id

            FROM users

            WHERE LOWER(email) =
                  LOWER(?)

            LIMIT 1

        """;


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


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                return rs.next();
            }
        }
    }


    // =========================================================
    // VALIDATE HOD
    // =========================================================

    private boolean isValidHod(
            Connection con,
            int hodId,
            String department)
            throws SQLException {


        String sql = """

            SELECT id

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
    // CREATE INITIAL LEAVE BALANCES
    // =========================================================

    private int createInitialLeaveBalances(
            Connection con,
            int userId,
            int year)
            throws SQLException {


        String sql = """

            INSERT INTO leave_balances
            (
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                used_days,
                remaining_days
            )

            SELECT

                ?,
                lt.leave_type_id,
                ?,

                CASE

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti tahunan'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti kecemasan'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti sakit'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti bersalin'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti kahwin'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti ihsan'
                    THEN ?

                END,

                0,

                CASE

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti tahunan'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti kecemasan'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti sakit'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti bersalin'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti kahwin'
                    THEN ?

                    WHEN TRIM(
                        LOWER(
                            lt.leave_type_name
                        )
                    ) = 'cuti ihsan'
                    THEN ?

                END

            FROM leave_types lt

            WHERE lt.is_active = 1

              AND TRIM(
                    LOWER(
                        lt.leave_type_name
                    )
                  ) IN
                  (
                      'cuti tahunan',
                      'cuti kecemasan',
                      'cuti sakit',
                      'cuti bersalin',
                      'cuti kahwin',
                      'cuti ihsan'
                  )

            ON DUPLICATE KEY UPDATE

                user_id =
                    VALUES(user_id)

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            int index =
                1;


            ps.setInt(
                index++,
                userId
            );


            ps.setInt(
                index++,
                year
            );


            // =================================================
            // ENTITLEMENT
            // =================================================

            ps.setInt(
                index++,
                DEFAULT_SHARED_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_SHARED_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MEDICAL_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MATERNITY_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MARRIAGE_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_COMPASSIONATE_LEAVE
            );


            // =================================================
            // REMAINING
            // =================================================

            ps.setInt(
                index++,
                DEFAULT_SHARED_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_SHARED_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MEDICAL_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MATERNITY_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_MARRIAGE_LEAVE
            );


            ps.setInt(
                index++,
                DEFAULT_COMPASSIONATE_LEAVE
            );


            return ps.executeUpdate();
        }
    }


    // =========================================================
    // VALID DEPARTMENT
    // =========================================================

    private boolean isValidDepartment(
            String department) {


        if (
            department == null
        ) {

            return false;
        }


        return
            "PENTADBIRAN_KORPORAT"
                .equals(
                    department
                )
            ||
            "KEWANGAN"
                .equals(
                    department
                )
            ||
            "PEMBANGUNAN_PERNIAGAAN_OPERASI"
                .equals(
                    department
                );
    }


    // =========================================================
    // BASIC EMAIL VALIDATION
    // =========================================================

    private boolean isValidEmail(
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
    // CLEAN
    // =========================================================

    private String clean(
            String value) {


        if (
            value == null
        ) {

            return "";
        }


        return value.trim();
    }


    // =========================================================
    // FORWARD ERROR
    // =========================================================

    private void forwardError(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws ServletException, IOException {


        loadHods(
            request
        );


        request
            .getRequestDispatcher(
                "/register.jsp?error="
                + error
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // ROLLBACK
    // =========================================================

    private void rollbackQuietly(
            Connection con) {


        if (
            con == null
        ) {

            return;
        }


        try {

            con.rollback();

        } catch (
            SQLException ignored
        ) {
        }
    }
}