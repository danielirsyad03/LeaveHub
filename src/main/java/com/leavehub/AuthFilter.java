package com.leavehub;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;


@WebFilter(
    urlPatterns = {

        // =====================================================
        // PORTAL STAF
        // =====================================================

        "/dashboard",
        "/apply",
        "/applications",
        "/calendar",
        "/my-leave-balance",


        // =====================================================
        // PERMOHONAN CUTI
        // =====================================================

        "/edit-leave",
        "/cancel",
        "/print-leave",


        // =====================================================
        // KETUA UNIT / PENGURUSAN
        // =====================================================

        "/admin",
        "/approval",
        "/hod-staff",


        // =====================================================
        // CETAK SENARAI
        // =====================================================

        "/print-staff-list",
        "/print-leave-list",
        "/print-inventory-list",
        "/print-inventory-request-list",


        // =====================================================
        // PENTADBIR SISTEM
        // =====================================================

        "/staff",
        "/leave-balance",
        "/public-holidays",


        // =====================================================
        // INVENTORI
        // =====================================================

        "/inventory",
        "/inventory-request",
        "/inventory-requests",

        "/inventory-admin",
        "/inventory-request-admin",

        "/inventory-return-admin",
        "/inventory-transactions",


        // =====================================================
        // LOG AKTIVITI
        // =====================================================

        "/activity-log",
        "/print-activity-log",


        // =====================================================
        // NOTIFICATION
        // =====================================================

        "/notifications",
        "/notification-count",
        "/notification-read",


        // =====================================================
        // AKAUN
        // =====================================================

        "/change-password"
    }
)
public class AuthFilter implements Filter {


    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {


        HttpServletRequest req =
                (HttpServletRequest) request;


        HttpServletResponse resp =
                (HttpServletResponse) response;


        HttpSession session =
                req.getSession(false);


        // =====================================================
        // 1. CHECK LOGIN
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
        // 2. GET ROLE
        // =====================================================

        Object roleObject =
                session.getAttribute("userRole");


        if (roleObject == null) {

            session.invalidate();

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        String role =
                roleObject
                    .toString()
                    .trim()
                    .toUpperCase();


        // =====================================================
        // 3. VALID ROLE
        // =====================================================

        boolean isStaff =
                "STAFF".equals(role);


        boolean isHOD =
                "HOD".equals(role);


        boolean isHR =
                "HR".equals(role);


        boolean isManagement =
                "MANAGEMENT".equals(role);


        if (
            !isStaff
            &&
            !isHOD
            &&
            !isHR
            &&
            !isManagement
        ) {

            session.invalidate();

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // 4. CURRENT PATH
        // =====================================================

        String path =
                req.getServletPath();


        if (path == null) {

            path = "";
        }


        // =====================================================
        // 5. ADMIN PAGE
        //
        // HOD:
        // Sokongan permohonan
        //
        // MANAGEMENT:
        // Keputusan akhir
        //
        // HR:
        // Lihat rekod
        // =====================================================

        if (
            "/admin".equals(path)
        ) {

            if (
                !isHOD
                &&
                !isManagement
                &&
                !isHR
            ) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 6. APPROVAL ACTION
        //
        // HOD + MANAGEMENT
        // =====================================================

        if (
            "/approval".equals(path)
        ) {

            if (
                !isHOD
                &&
                !isManagement
            ) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 7. HOD STAFF
        // =====================================================

        if (
            "/hod-staff".equals(path)
        ) {

            if (!isHOD) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 8. PRINT STAFF LIST
        //
        // HR + HOD
        // =====================================================

        if (
            "/print-staff-list".equals(path)
        ) {

            if (
                !isHR
                &&
                !isHOD
            ) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 9. PRINT LEAVE LIST
        //
        // HR + HOD + MANAGEMENT
        // =====================================================

        if (
            "/print-leave-list".equals(path)
        ) {

            if (
                !isHR
                &&
                !isHOD
                &&
                !isManagement
            ) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 10. PRINT INVENTORY
        //
        // HR ONLY
        // =====================================================

        if (
            "/print-inventory-list".equals(path)
            ||
            "/print-inventory-request-list".equals(path)
        ) {

            if (!isHR) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 11. STAFF MANAGEMENT
        //
        // HR ONLY
        // =====================================================

        if (
            "/staff".equals(path)
            ||
            "/leave-balance".equals(path)
            ||
            "/public-holidays".equals(path)
        ) {

            if (!isHR) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 12. INVENTORY ADMIN
        //
        // HR ONLY
        //
        // Includes:
        // - Inventory Management
        // - Inventory Request Management
        // - Inventory Return Management
        // - Inventory Transaction History
        // =====================================================

        if (
            "/inventory-admin".equals(path)
            ||
            "/inventory-request-admin".equals(path)
            ||
            "/inventory-return-admin".equals(path)
            ||
            "/inventory-transactions".equals(path)
        ) {

            if (!isHR) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 13. ACTIVITY LOG
        //
        // HR ONLY
        //
        // Includes:
        // - View Activity Log
        // - Print Activity Log
        // =====================================================

        if (
            "/activity-log".equals(path)
            ||
            "/print-activity-log".equals(path)
        ) {

            if (!isHR) {

                sendForbidden(
                    req,
                    resp
                );

                return;
            }


            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 14. NOTIFICATIONS
        //
        // ALL LOGGED-IN USERS
        // =====================================================

        if (
            "/notifications".equals(path)
            ||
            "/notification-count".equals(path)
            ||
            "/notification-read".equals(path)
        ) {

            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 15. GENERAL LOGGED-IN FUNCTIONS
        //
        // ALL VALID ROLES
        // =====================================================

        if (
            "/dashboard".equals(path)
            ||
            "/apply".equals(path)
            ||
            "/applications".equals(path)
            ||
            "/calendar".equals(path)
            ||
            "/my-leave-balance".equals(path)
            ||
            "/edit-leave".equals(path)
            ||
            "/cancel".equals(path)
            ||
            "/print-leave".equals(path)
            ||
            "/inventory".equals(path)
            ||
            "/inventory-request".equals(path)
            ||
            "/inventory-requests".equals(path)
            ||
            "/change-password".equals(path)
        ) {

            chain.doFilter(
                request,
                response
            );

            return;
        }


        // =====================================================
        // 16. FALLBACK
        // =====================================================

        chain.doFilter(
            request,
            response
        );
    }


    // =========================================================
    // FORBIDDEN
    // =========================================================

    private void sendForbidden(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws IOException {


        resp.sendRedirect(
            req.getContextPath()
            + "/dashboard?error=forbidden"
        );
    }
}