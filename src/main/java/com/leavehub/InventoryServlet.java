
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

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // =========================================================
    // GET
    // LOAD INVENTORY LIST
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================================
        // CHECK LOGIN
        // =====================================================

        HttpSession session = request.getSession(false);

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
        // ITEM LIST
        // =====================================================

        List<Map<String, Object>> items =
                new ArrayList<>();


        // =====================================================
        // SQL
        // =====================================================

        String sql = """
            SELECT
                id,
                item_code,
                item_name,
                category,
                item_type,
                brand,
                size,
                color,
                quantity,
                available_quantity,
                unit,
                item_condition,
                location,
                description,
                status
            FROM inventory_items
            WHERE is_active = 1
            ORDER BY
                category ASC,
                item_name ASC,
                brand ASC,
                size ASC,
                color ASC
        """;


        // =====================================================
        // LOAD INVENTORY
        // =====================================================

        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> item =
                        new HashMap<>();


                // =============================================
                // BASIC INFORMATION
                // =============================================

                item.put(
                    "id",
                    rs.getInt("id")
                );

                item.put(
                    "item_code",
                    rs.getString("item_code")
                );

                item.put(
                    "item_name",
                    rs.getString("item_name")
                );

                item.put(
                    "category",
                    rs.getString("category")
                );

                item.put(
                    "item_type",
                    rs.getString("item_type")
                );


                // =============================================
                // BRAND / SIZE / COLOR
                // =============================================

                item.put(
                    "brand",
                    rs.getString("brand")
                );

                item.put(
                    "size",
                    rs.getString("size")
                );

                item.put(
                    "color",
                    rs.getString("color")
                );


                // =============================================
                // STOCK
                // =============================================

                int totalQuantity =
                    rs.getInt("quantity");

                int availableQuantity =
                    rs.getInt("available_quantity");

                item.put(
                    "quantity",
                    totalQuantity
                );

                item.put(
                    "available_quantity",
                    availableQuantity
                );

                item.put(
                    "unit",
                    rs.getString("unit")
                );


                // =============================================
                // CONDITION / LOCATION
                // =============================================

                item.put(
                    "item_condition",
                    rs.getString("item_condition")
                );

                item.put(
                    "location",
                    rs.getString("location")
                );


                // =============================================
                // DESCRIPTION
                // =============================================

                item.put(
                    "description",
                    rs.getString("description")
                );


                // =============================================
                // STOCK STATUS
                //
                // SAME LOGIC AS InventoryAdminServlet
                //
                // available_quantity <= 0
                //     = OUT_OF_STOCK
                //
                // available_quantity <= 20% of quantity
                //     = LOW_STOCK
                //
                // Otherwise
                //     = AVAILABLE
                // =============================================

                String stockStatus;

                if (availableQuantity <= 0) {

                    stockStatus = "OUT_OF_STOCK";

                } else if (
                    totalQuantity > 0
                    &&
                    availableQuantity * 100L
                        <= totalQuantity * 20L
                ) {

                    stockStatus = "LOW_STOCK";

                } else {

                    stockStatus = "AVAILABLE";
                }

                item.put(
                    "status",
                    stockStatus
                );


                // =============================================
                // ADD ITEM TO LIST
                // =============================================

                items.add(item);
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan senarai inventori.",
                e
            );
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "items",
            items
        );

        request.setAttribute(
            "pageTitle",
            "Inventori"
        );


        // =====================================================
        // OPEN JSP
        // =====================================================

        request.getRequestDispatcher(
            "/inventory.jsp"
        ).forward(
            request,
            response
        );
    }
}
