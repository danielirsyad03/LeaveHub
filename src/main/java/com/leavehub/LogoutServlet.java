package com.leavehub;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;


@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // LOGOUT
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {


        // =====================================================
        // GET CURRENT SESSION
        // =====================================================

        HttpSession session =
                request.getSession(false);



        // =====================================================
        // DESTROY SESSION
        // =====================================================

        if (session != null) {

            session.invalidate();
        }



        // =====================================================
        // REDIRECT TO LOGIN PAGE
        // =====================================================

        response.sendRedirect(
            request.getContextPath() + "/"
        );
    }
}