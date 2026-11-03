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
import java.sql.SQLException;


@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {


        HttpSession session =
                req.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // OPEN CHANGE PASSWORD PAGE
        // =====================================================

        req.getRequestDispatcher(
            "/change-password.jsp"
        ).forward(
            req,
            resp
        );
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {


        req.setCharacterEncoding(
            "UTF-8"
        );


        HttpSession session =
                req.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // GET USER ID
        // =====================================================

        int userId;


        try {

            userId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );


            if (
                userId <= 0
            ) {

                throw new NumberFormatException();
            }


        } catch (
            NumberFormatException e
        ) {

            session.invalidate();


            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // GET PASSWORD
        // =====================================================

        String newPassword =
                req.getParameter(
                    "newPassword"
                );


        String confirmPassword =
                req.getParameter(
                    "confirmPassword"
                );


        // =====================================================
        // REQUIRED
        // =====================================================

        if (
            newPassword == null
            ||
            confirmPassword == null
            ||
            newPassword.isBlank()
            ||
            confirmPassword.isBlank()
        ) {

            resp.sendRedirect(
                req.getContextPath()
                + "/change-password?error=required"
            );

            return;
        }


        // =====================================================
        // PASSWORD LENGTH
        // =====================================================

        if (
            newPassword.length() < 6
        ) {

            resp.sendRedirect(
                req.getContextPath()
                + "/change-password?error=length"
            );

            return;
        }


        // =====================================================
        // MAX LENGTH
        // =====================================================

        if (
            newPassword.length() > 100
        ) {

            resp.sendRedirect(
                req.getContextPath()
                + "/change-password?error=length"
            );

            return;
        }


        // =====================================================
        // PASSWORD MATCH
        // =====================================================

        if (
            !newPassword.equals(
                confirmPassword
            )
        ) {

            resp.sendRedirect(
                req.getContextPath()
                + "/change-password?error=match"
            );

            return;
        }


        // =====================================================
        // HASH PASSWORD
        //
        // IMPORTANT:
        // The original password is never stored in the audit.
        // The password hash is also never stored in the audit.
        // =====================================================

        String hashedPassword;


        try {

            hashedPassword =
                    PasswordUtil.hash(
                        newPassword
                    );


        } catch (Exception e) {

            throw new ServletException(
                "Tidak dapat memproses kata laluan baharu.",
                e
            );
        }


        // =====================================================
        // DATABASE TRANSACTION
        // =====================================================

        Connection con =
                null;


        try {

            con =
                    DBConnection.getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // UPDATE PASSWORD
            // =================================================

            String sql = """

                UPDATE users

                SET
                    password = ?,
                    force_password_change = 0

                WHERE id = ?

            """;


            int affected;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            sql
                        )
            ) {


                ps.setString(
                    1,
                    hashedPassword
                );


                ps.setInt(
                    2,
                    userId
                );


                affected =
                        ps.executeUpdate();
            }


            // =================================================
            // USER NOT FOUND
            // =================================================

            if (
                affected != 1
            ) {

                con.rollback();


                session.invalidate();


                resp.sendRedirect(
                    req.getContextPath()
                    + "/?error=session"
                );

                return;
            }


            // =================================================
            // AUDIT TRAIL
            //
            // NEVER log:
            // - newPassword
            // - confirmPassword
            // - hashedPassword
            //
            // Only the security action itself is recorded.
            // =================================================

            ActivityLogUtil.log(
                con,
                req,
                "CHANGE_PASSWORD",
                "Menukar kata laluan akaun",
                "USER",
                userId
            );


            // =================================================
            // COMMIT
            //
            // Password change + audit trail are committed
            // together.
            // =================================================

            con.commit();


            // =================================================
            // UPDATE SESSION
            // =================================================

            session.setAttribute(
                "forcePasswordChange",
                false
            );


            // =================================================
            // REDIRECT
            // =================================================

            resp.sendRedirect(
                req.getContextPath()
                + "/dashboard?success=passwordChanged"
            );


        } catch (SQLException e) {


            // =================================================
            // ROLLBACK
            // =================================================

            rollbackQuietly(
                con
            );


            throw new ServletException(
                "Tidak dapat menukar kata laluan.",
                e
            );


        } finally {


            // =================================================
            // CLOSE CONNECTION
            // =================================================

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
    // ROLLBACK QUIETLY
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