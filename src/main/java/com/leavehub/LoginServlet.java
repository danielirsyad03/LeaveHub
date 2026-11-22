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


@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


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


        if (
            session != null
            &&
            session.getAttribute("userId") != null
        ) {

            response.sendRedirect(
                request.getContextPath()
                + "/dashboard"
            );

            return;
        }


        response.sendRedirect(
            request.getContextPath()
            + "/"
        );
    }


    // =========================================================
    // POST
    // LOGIN
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
        // GET FORM DATA
        // =====================================================

        String email =
                clean(
                    request.getParameter(
                        "email"
                    )
                );


        String password =
                request.getParameter(
                    "password"
                );


        // =====================================================
        // BASIC VALIDATION
        // =====================================================

        if (
            email.isBlank()
            ||
            password == null
            ||
            password.isBlank()
        ) {

            response.sendRedirect(
                request.getContextPath()
                + "/?error=1"
            );

            return;
        }


        // =====================================================
        // NORMALIZE EMAIL
        // =====================================================

        email =
                email
                    .trim()
                    .toLowerCase();


        // =====================================================
        // SQL
        // =====================================================

        String sql = """

            SELECT

                id,

                name,

                email,

                role,

                department,

                annual_leave,

                medical_leave,

                force_password_change

            FROM users

            WHERE LOWER(TRIM(email)) = ?

              AND password = ?

            LIMIT 1

        """;


        // =====================================================
        // DATABASE
        // =====================================================

        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {


            // =================================================
            // EMAIL
            // =================================================

            ps.setString(
                1,
                email
            );


            // =================================================
            // HASH PASSWORD
            // =================================================

            String hashedPassword =
                    PasswordUtil.hash(
                        password
                    );


            ps.setString(
                2,
                hashedPassword
            );


            // =================================================
            // EXECUTE
            // =================================================

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                // =============================================
                // LOGIN FAILED
                // =============================================

                if (!rs.next()) {

                    try {
                        ActivityLogUtil.log(
                                request,
                                "LOGIN_FAILED",
                                "Percubaan log masuk gagal untuk akaun " + email + ".",
                                "AUTHENTICATION",
                                email
                        );
                    } catch (SQLException auditError) {
                        auditError.printStackTrace();
                    }

                    response.sendRedirect(
                        request.getContextPath()
                        + "/?error=1"
                    );

                    return;
                }


                // =============================================
                // GET USER DATA
                // =============================================

                int userId =
                        rs.getInt(
                            "id"
                        );


                String userName =
                        rs.getString(
                            "name"
                        );


                String userEmail =
                        rs.getString(
                            "email"
                        );


                String userRole =
                        rs.getString(
                            "role"
                        );


                String userDepartment =
                        rs.getString(
                            "department"
                        );


                int annualLeave =
                        rs.getInt(
                            "annual_leave"
                        );


                int medicalLeave =
                        rs.getInt(
                            "medical_leave"
                        );


                boolean forcePasswordChange =
                        rs.getBoolean(
                            "force_password_change"
                        );


                // =============================================
                // INVALIDATE OLD SESSION
                // =============================================

                HttpSession oldSession =
                        request.getSession(
                            false
                        );


                if (oldSession != null) {

                    oldSession.invalidate();
                }


                // =============================================
                // CREATE NEW SESSION
                // =============================================

                HttpSession newSession =
                        request.getSession(
                            true
                        );


                // =============================================
                // SESSION DATA
                // =============================================

                newSession.setAttribute(
                    "userId",
                    userId
                );


                newSession.setAttribute(
                    "userName",
                    userName
                );


                newSession.setAttribute(
                    "userEmail",
                    userEmail
                );


                newSession.setAttribute(
                    "userRole",
                    userRole
                );


                newSession.setAttribute(
                    "userDepartment",
                    userDepartment
                );


                /*
                 * Legacy values.
                 *
                 * Sistem baki cuti utama sekarang menggunakan
                 * leave_balances, tetapi kita kekalkan attribute
                 * ini supaya page lama tidak rosak.
                 */

                newSession.setAttribute(
                    "annualLeave",
                    annualLeave
                );


                newSession.setAttribute(
                    "medicalLeave",
                    medicalLeave
                );


                newSession.setAttribute(
                    "forcePasswordChange",
                    forcePasswordChange
                );

                try {
                    ActivityLogUtil.log(
                            request,
                            "LOGIN",
                            "Log masuk berjaya.",
                            "USER",
                            userId
                    );
                } catch (SQLException auditError) {
                    auditError.printStackTrace();
                }


                // =============================================
                // SESSION TIMEOUT
                // 30 MINUTES
                // =============================================

                newSession.setMaxInactiveInterval(
                    30 * 60
                );


                
                // =============================================
                // FORCE PASSWORD CHANGE
                // =============================================

                if (forcePasswordChange) {

                    response.sendRedirect(
                        request.getContextPath()
                        + "/change-password"
                    );

                    return;
                }


                // =============================================
                // NORMAL LOGIN
                // =============================================

                response.sendRedirect(
                    request.getContextPath()
                    + "/dashboard"
                );
            }


        } catch (SQLException e) {

            e.printStackTrace();


            throw new ServletException(
                "Ralat pangkalan data semasa proses log masuk.",
                e
            );
        }
    }


    // =========================================================
    // CLEAN STRING
    // =========================================================

    private String clean(
            String value) {


        if (value == null) {

            return "";
        }


        return value.trim();
    }
}
