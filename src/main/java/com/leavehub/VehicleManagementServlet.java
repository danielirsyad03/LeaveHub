package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/vehicle-management")
public class VehicleManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // GET
    // PAPARKAN SENARAI KENDERAAN
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );
            return;
        }

        // =====================================================
        // CHECK ROLE
        // Hanya HR/Admin
        // =====================================================

        String role =
            (String) session.getAttribute("userRole");

        if (role == null ||
            !"HR".equalsIgnoreCase(role.trim())) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );
            return;
        }

        // =====================================================
        // LOAD VEHICLES
        // =====================================================

        List<Map<String, Object>> vehicles =
            new ArrayList<>();

        String sql = """
            SELECT
                id,
                plate_number,
                vehicle_name,
                status,
                created_at,
                updated_at
            FROM vehicles
            ORDER BY
                plate_number ASC
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

                Map<String, Object> vehicle =
                    new HashMap<>();

                vehicle.put(
                    "id",
                    rs.getInt("id")
                );

                vehicle.put(
                    "plate_number",
                    rs.getString("plate_number")
                );

                vehicle.put(
                    "vehicle_name",
                    rs.getString("vehicle_name")
                );

                vehicle.put(
                    "status",
                    rs.getString("status")
                );

                vehicle.put(
                    "created_at",
                    rs.getTimestamp("created_at")
                );

                vehicle.put(
                    "updated_at",
                    rs.getTimestamp("updated_at")
                );

                vehicles.add(vehicle);
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan senarai kenderaan.",
                e
            );
        }

        // =====================================================
        // SEND TO JSP
        // =====================================================

        request.setAttribute(
            "vehicles",
            vehicles
        );

        request.setAttribute(
            "pageTitle",
            "Pengurusan Kenderaan"
        );

        request.getRequestDispatcher(
            "/vehicle-management.jsp"
        ).forward(
            request,
            response
        );
    }


    // =========================================================
    // POST
    // ADD / EDIT / DELETE VEHICLE
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
            request.getSession(false);

        // =====================================================
        // CHECK LOGIN
        // =====================================================

        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );
            return;
        }

        // =====================================================
        // CHECK ROLE
        // =====================================================

        String role =
            (String) session.getAttribute("userRole");

        if (role == null ||
            !"HR".equalsIgnoreCase(role.trim())) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );
            return;
        }

        // =====================================================
        // ACTION
        // =====================================================

        String action =
            request.getParameter("action");

        if (action == null) {

            redirectError(
                request,
                response,
                "Tindakan tidak sah."
            );

            return;
        }

        switch (action.toLowerCase()) {

            case "add":
                addVehicle(
                    request,
                    response
                );
                break;

            case "edit":
                editVehicle(
                    request,
                    response
                );
                break;

            case "delete":
                deleteVehicle(
                    request,
                    response
                );
                break;

            default:

                redirectError(
                    request,
                    response,
                    "Tindakan tidak sah."
                );
        }
    }


    // =========================================================
    // ADD VEHICLE
    // =========================================================

    private void addVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String plateNumber =
            clean(request.getParameter("plate_number"));

        String vehicleName =
            clean(request.getParameter("vehicle_name"));

        String status =
            clean(request.getParameter("status"));

        // =====================================================
        // VALIDATION
        // =====================================================

        if (plateNumber.isEmpty() ||
            vehicleName.isEmpty()) {

            redirectError(
                request,
                response,
                "No. pendaftaran dan nama kenderaan wajib diisi."
            );

            return;
        }

        plateNumber =
            plateNumber.toUpperCase();

        if (!isValidStatus(status)) {
            status = "ACTIVE";
        }

        // =====================================================
        // CHECK DUPLICATE PLATE
        // =====================================================

        String duplicateSql = """
            SELECT id
            FROM vehicles
            WHERE UPPER(plate_number) = UPPER(?)
            LIMIT 1
        """;

        String insertSql = """
            INSERT INTO vehicles
            (
                plate_number,
                vehicle_name,
                status
            )
            VALUES (?, ?, ?)
        """;

        try (
            Connection con =
                DBConnection.getConnection()
        ) {

            // -------------------------------------------------
            // DUPLICATE CHECK
            // -------------------------------------------------

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        duplicateSql
                    )
            ) {

                ps.setString(
                    1,
                    plateNumber
                );

                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (rs.next()) {

                        redirectError(
                            request,
                            response,
                            "No. pendaftaran tersebut telah wujud."
                        );

                        return;
                    }
                }
            }

            // -------------------------------------------------
            // INSERT
            // -------------------------------------------------

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        insertSql
                    )
            ) {

                ps.setString(
                    1,
                    plateNumber
                );

                ps.setString(
                    2,
                    vehicleName
                );

                ps.setString(
                    3,
                    status
                );

                ps.executeUpdate();
            }

            redirectSuccess(
                request,
                response,
                "Kenderaan berjaya ditambah."
            );

        } catch (SQLException e) {

            e.printStackTrace();

            redirectError(
                request,
                response,
                "Kenderaan tidak dapat ditambah."
            );
        }
    }


    // =========================================================
    // EDIT VEHICLE
    // =========================================================

    private void editVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int id;

        try {

            id = Integer.parseInt(
                request.getParameter("id")
            );

        } catch (
            NumberFormatException |
            NullPointerException e
        ) {

            redirectError(
                request,
                response,
                "ID kenderaan tidak sah."
            );

            return;
        }

        String plateNumber =
            clean(request.getParameter("plate_number"));

        String vehicleName =
            clean(request.getParameter("vehicle_name"));

        String status =
            clean(request.getParameter("status"));

        if (plateNumber.isEmpty() ||
            vehicleName.isEmpty()) {

            redirectError(
                request,
                response,
                "No. pendaftaran dan nama kenderaan wajib diisi."
            );

            return;
        }

        plateNumber =
            plateNumber.toUpperCase();

        if (!isValidStatus(status)) {

            redirectError(
                request,
                response,
                "Status kenderaan tidak sah."
            );

            return;
        }

        // =====================================================
        // CHECK DUPLICATE
        // Exclude current vehicle
        // =====================================================

        String duplicateSql = """
            SELECT id
            FROM vehicles
            WHERE UPPER(plate_number) = UPPER(?)
              AND id <> ?
            LIMIT 1
        """;

        String updateSql = """
            UPDATE vehicles
            SET
                plate_number = ?,
                vehicle_name = ?,
                status = ?
            WHERE id = ?
        """;

        try (
            Connection con =
                DBConnection.getConnection()
        ) {

            // -------------------------------------------------
            // DUPLICATE CHECK
            // -------------------------------------------------

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        duplicateSql
                    )
            ) {

                ps.setString(
                    1,
                    plateNumber
                );

                ps.setInt(
                    2,
                    id
                );

                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (rs.next()) {

                        redirectError(
                            request,
                            response,
                            "No. pendaftaran tersebut digunakan oleh kenderaan lain."
                        );

                        return;
                    }
                }
            }

            // -------------------------------------------------
            // UPDATE
            // -------------------------------------------------

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateSql
                    )
            ) {

                ps.setString(
                    1,
                    plateNumber
                );

                ps.setString(
                    2,
                    vehicleName
                );

                ps.setString(
                    3,
                    status
                );

                ps.setInt(
                    4,
                    id
                );

                int affected =
                    ps.executeUpdate();

                if (affected == 0) {

                    redirectError(
                        request,
                        response,
                        "Kenderaan tidak ditemui."
                    );

                    return;
                }
            }

            redirectSuccess(
                request,
                response,
                "Maklumat kenderaan berjaya dikemas kini."
            );

        } catch (SQLException e) {

            e.printStackTrace();

            redirectError(
                request,
                response,
                "Maklumat kenderaan tidak dapat dikemas kini."
            );
        }
    }


    // =========================================================
    // DELETE VEHICLE
    // =========================================================

    private void deleteVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int id;

        try {

            id = Integer.parseInt(
                request.getParameter("id")
            );

        } catch (
            NumberFormatException |
            NullPointerException e
        ) {

            redirectError(
                request,
                response,
                "ID kenderaan tidak sah."
            );

            return;
        }

        /*
         * Jangan padam kenderaan sekiranya sudah mempunyai
         * rekod permohonan. Ini penting supaya sejarah
         * permohonan dan cetakan borang tidak rosak.
         */

        String checkSql = """
            SELECT COUNT(*) AS total
            FROM vehicle_applications
            WHERE vehicle_id = ?
        """;

        String deleteSql = """
            DELETE FROM vehicles
            WHERE id = ?
        """;

        try (
            Connection con =
                DBConnection.getConnection()
        ) {

            // -------------------------------------------------
            // CHECK APPLICATION HISTORY
            // -------------------------------------------------

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        checkSql
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

                    if (rs.next() &&
                        rs.getInt("total") > 0) {

                        redirectError(
                            request,
                            response,
                            "Kenderaan ini mempunyai rekod permohonan dan tidak boleh dipadam. Tukar status kepada Tidak Aktif."
                        );

                        return;
                    }
                }
            }

            // -------------------------------------------------
            // DELETE
            // -------------------------------------------------

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

                int affected =
                    ps.executeUpdate();

                if (affected == 0) {

                    redirectError(
                        request,
                        response,
                        "Kenderaan tidak ditemui."
                    );

                    return;
                }
            }

            redirectSuccess(
                request,
                response,
                "Kenderaan berjaya dipadam."
            );

        } catch (SQLException e) {

            e.printStackTrace();

            redirectError(
                request,
                response,
                "Kenderaan tidak dapat dipadam."
            );
        }
    }


    // =========================================================
    // VALID STATUS
    // =========================================================

    private boolean isValidStatus(
            String status) {

        return
            "ACTIVE".equalsIgnoreCase(status) ||
            "MAINTENANCE".equalsIgnoreCase(status) ||
            "INACTIVE".equalsIgnoreCase(status);
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


    // =========================================================
    // REDIRECT SUCCESS
    // =========================================================

    private void redirectSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws IOException {

        response.sendRedirect(
            request.getContextPath()
            + "/vehicle-management?success="
            + encode(message)
        );
    }


    // =========================================================
    // REDIRECT ERROR
    // =========================================================

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws IOException {

        response.sendRedirect(
            request.getContextPath()
            + "/vehicle-management?error="
            + encode(message)
        );
    }


    // =========================================================
    // URL ENCODE
    // =========================================================

    private String encode(
            String value) {

        return URLEncoder.encode(
            value,
            StandardCharsets.UTF_8
        );
    }
}