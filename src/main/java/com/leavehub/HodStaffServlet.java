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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/hod-staff")
public class HodStaffServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // SESSION
        // =====================================================

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


        // =====================================================
        // ROLE
        // =====================================================

        String role =
            session.getAttribute("userRole") == null
                ? ""
                : session.getAttribute("userRole")
                    .toString()
                    .trim()
                    .toUpperCase();


        if (!"HOD".equals(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        // =====================================================
        // HOD ID
        // =====================================================

        int hodId;


        try {

            hodId =
                Integer.parseInt(
                    session.getAttribute("userId")
                        .toString()
                );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // LIST
        // =====================================================

        List<Map<String, Object>> staff =
            new ArrayList<>();


        String sql = """

            SELECT
                id,
                name,
                position,
                email,
                department,
                role

            FROM users

            WHERE role = 'STAFF'
              AND hod_id = ?

            ORDER BY name ASC

        """;


        try (
            Connection con =
                DBConnection.getConnection();

            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {


            ps.setInt(
                1,
                hodId
            );


            try (
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
                        "name",
                        rs.getString("name")
                    );


                    row.put(
                        "position",
                        rs.getString("position")
                    );


                    row.put(
                        "email",
                        rs.getString("email")
                    );


                    row.put(
                        "department",
                        rs.getString("department")
                    );


                    row.put(
                        "role",
                        rs.getString("role")
                    );


                    staff.add(
                        row
                    );
                }
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan senarai staf di bawah seliaan.",
                e
            );
        }


        // =====================================================
        // ATTRIBUTES
        // =====================================================

        request.setAttribute(
            "staff",
            staff
        );


        request.setAttribute(
            "totalStaff",
            staff.size()
        );


        request.setAttribute(
            "pageTitle",
            "Staf Di Bawah Seliaan"
        );


        request
            .getRequestDispatcher(
                "/hod-staff.jsp"
            )
            .forward(
                request,
                response
            );
    }
}