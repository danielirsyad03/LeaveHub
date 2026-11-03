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


@WebServlet("/inventory-transactions")
public class InventoryTransactionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // INVENTORY TRANSACTION HISTORY
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // CHECK LOGIN
        // =====================================================

        HttpSession session =
                request.getSession(false);


        if (
            session == null
            ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // CHECK ROLE
        // ONLY HR / MANAGEMENT
        // =====================================================

        String role =
                session.getAttribute("userRole") != null
                    ? session.getAttribute("userRole")
                        .toString()
                        .trim()
                        .toUpperCase()
                    : "";


        if (
            !"HR".equals(role)
            &&
            !"MANAGEMENT".equals(role)
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mengakses halaman ini."
            );

            return;
        }


        // =====================================================
        // FILTER PARAMETERS
        // =====================================================

        String search =
                cleanParameter(
                    request.getParameter("search")
                );


        String type =
                cleanParameter(
                    request.getParameter("type")
                );


        String dateFrom =
                cleanParameter(
                    request.getParameter("dateFrom")
                );


        String dateTo =
                cleanParameter(
                    request.getParameter("dateTo")
                );


        // =====================================================
        // TRANSACTION LIST
        // =====================================================

        List<Map<String, Object>> transactions =
                new ArrayList<>();


        // =====================================================
        // COUNTERS
        // =====================================================

        int totalTransactions = 0;

        int totalStockIn = 0;

        int totalStockOut = 0;

        int totalReturn = 0;

        int totalAdjustment = 0;


        // =====================================================
        // BUILD SQL
        //
        // IMPORTANT:
        // users table uses "name"
        // NOT "full_name"
        // =====================================================

        StringBuilder sql =
                new StringBuilder(
                    """

                    SELECT

                        t.id,
                        t.item_id,
                        t.request_id,
                        t.user_id,
                        t.transaction_type,
                        t.quantity,
                        t.stock_before,
                        t.stock_after,
                        t.remarks,
                        t.performed_by,
                        t.created_at,

                        i.item_code,
                        i.item_name,
                        i.category,
                        i.item_type,
                        i.brand,
                        i.size,
                        i.color,
                        i.unit,

                        u.name AS staff_name,
                        u.email AS staff_email,

                        p.name AS performed_by_name,
                        p.email AS performed_by_email

                    FROM inventory_transactions t

                    INNER JOIN inventory_items i
                        ON t.item_id = i.id

                    LEFT JOIN users u
                        ON t.user_id = u.id

                    LEFT JOIN users p
                        ON t.performed_by = p.id

                    WHERE 1 = 1

                    """
                );


        // =====================================================
        // SQL PARAMETERS
        // =====================================================

        List<Object> parameters =
                new ArrayList<>();


        // =====================================================
        // SEARCH FILTER
        // =====================================================

        if (!search.isBlank()) {

            sql.append(
                """

                AND (

                    i.item_code LIKE ?

                    OR i.item_name LIKE ?

                    OR i.category LIKE ?

                    OR i.brand LIKE ?

                    OR u.name LIKE ?

                    OR u.email LIKE ?

                    OR p.name LIKE ?

                    OR p.email LIKE ?

                    OR CAST(t.id AS CHAR) LIKE ?

                    OR CAST(t.request_id AS CHAR) LIKE ?

                    OR t.remarks LIKE ?

                )

                """
            );


            String searchValue =
                    "%" + search + "%";


            for (int i = 0; i < 11; i++) {

                parameters.add(
                    searchValue
                );
            }
        }


        // =====================================================
        // TRANSACTION TYPE FILTER
        // =====================================================

        if (!type.isBlank()) {

            if (
                "STOCK_IN".equals(type)
                ||
                "STOCK_OUT".equals(type)
                ||
                "RETURN".equals(type)
                ||
                "ADJUSTMENT".equals(type)
                ||
                "DELETE_INVENTORY".equals(type)
            ) {

                sql.append(
                    " AND t.transaction_type = ? "
                );

                parameters.add(type);
            }
        }


        // =====================================================
        // DATE FROM FILTER
        // =====================================================

        if (!dateFrom.isBlank()) {

            sql.append(
                " AND DATE(t.created_at) >= ? "
            );

            parameters.add(dateFrom);
        }


        // =====================================================
        // DATE TO FILTER
        // =====================================================

        if (!dateTo.isBlank()) {

            sql.append(
                " AND DATE(t.created_at) <= ? "
            );

            parameters.add(dateTo);
        }


        // =====================================================
        // ORDER
        // =====================================================

        sql.append(
            """

            ORDER BY
                t.created_at DESC,
                t.id DESC

            """
        );


        // =====================================================
        // EXECUTE QUERY
        // =====================================================

        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(
                        sql.toString()
                    )
        ) {


            // =================================================
            // SET PARAMETERS
            // =================================================

            for (
                int i = 0;
                i < parameters.size();
                i++
            ) {

                ps.setObject(
                    i + 1,
                    parameters.get(i)
                );
            }


            // =================================================
            // RESULT SET
            // =================================================

            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                while (rs.next()) {


                    Map<String, Object> row =
                            new HashMap<>();


                    // =========================================
                    // TRANSACTION
                    // =========================================

                    row.put(
                        "id",
                        rs.getInt("id")
                    );


                    row.put(
                        "item_id",
                        rs.getInt("item_id")
                    );


                    Object requestId =
                            rs.getObject(
                                "request_id"
                            );


                    row.put(
                        "request_id",
                        requestId
                    );


                    Object userId =
                            rs.getObject(
                                "user_id"
                            );


                    row.put(
                        "user_id",
                        userId
                    );


                    String transactionType =
                            rs.getString(
                                "transaction_type"
                            );


                    row.put(
                        "transaction_type",
                        transactionType
                    );


                    row.put(
                        "quantity",
                        rs.getInt(
                            "quantity"
                        )
                    );


                    row.put(
                        "stock_before",
                        rs.getInt(
                            "stock_before"
                        )
                    );


                    row.put(
                        "stock_after",
                        rs.getInt(
                            "stock_after"
                        )
                    );


                    row.put(
                        "remarks",
                        rs.getString(
                            "remarks"
                        )
                    );


                    row.put(
                        "performed_by",
                        rs.getObject(
                            "performed_by"
                        )
                    );


                    row.put(
                        "created_at",
                        rs.getTimestamp(
                            "created_at"
                        )
                    );


                    // =========================================
                    // INVENTORY ITEM
                    // =========================================

                    row.put(
                        "item_code",
                        rs.getString(
                            "item_code"
                        )
                    );


                    row.put(
                        "item_name",
                        rs.getString(
                            "item_name"
                        )
                    );


                    row.put(
                        "category",
                        rs.getString(
                            "category"
                        )
                    );


                    row.put(
                        "item_type",
                        rs.getString(
                            "item_type"
                        )
                    );


                    row.put(
                        "brand",
                        rs.getString(
                            "brand"
                        )
                    );


                    row.put(
                        "size",
                        rs.getString(
                            "size"
                        )
                    );


                    row.put(
                        "color",
                        rs.getString(
                            "color"
                        )
                    );


                    // =========================================
                    // UNIT
                    // =========================================

                    String unit =
                            rs.getString(
                                "unit"
                            );


                    if (
                        unit == null
                        ||
                        unit.isBlank()
                    ) {

                        unit = "Unit";
                    }


                    row.put(
                        "unit",
                        unit
                    );


                    // =========================================
                    // STAFF / RECEIVER
                    // =========================================

                    String staffName =
                            rs.getString(
                                "staff_name"
                            );


                    String staffEmail =
                            rs.getString(
                                "staff_email"
                            );


                    row.put(
                        "staff_name",
                        staffName
                    );


                    row.put(
                        "staff_email",
                        staffEmail
                    );


                    // =========================================
                    // PERFORMED BY
                    // =========================================

                    String performedByName =
                            rs.getString(
                                "performed_by_name"
                            );


                    String performedByEmail =
                            rs.getString(
                                "performed_by_email"
                            );


                    row.put(
                        "performed_by_name",
                        performedByName
                    );


                    row.put(
                        "performed_by_email",
                        performedByEmail
                    );


                    // =========================================
                    // DISPLAY RECEIVER
                    // =========================================

                    if (
                        staffName == null
                        ||
                        staffName.isBlank()
                    ) {

                        row.put(
                            "receiver_display",
                            "-"
                        );

                    } else {

                        row.put(
                            "receiver_display",
                            staffName
                        );
                    }


                    // =========================================
                    // DISPLAY PERFORMED BY
                    // =========================================

                    if (
                        performedByName == null
                        ||
                        performedByName.isBlank()
                    ) {

                        row.put(
                            "performed_by_display",
                            "-"
                        );

                    } else {

                        row.put(
                            "performed_by_display",
                            performedByName
                        );
                    }


                    // =========================================
                    // REFERENCE
                    // =========================================

                    if (requestId != null) {

                        row.put(
                            "reference",
                            "INV-REQ-" +
                            requestId
                        );

                    } else {

                        row.put(
                            "reference",
                            "-"
                        );
                    }


                    // =========================================
                    // QUANTITY DISPLAY
                    // =========================================

                    int quantity =
                            rs.getInt(
                                "quantity"
                            );


                    String quantityPrefix =
                            "";


                    if (
                        "STOCK_IN".equals(
                            transactionType
                        )
                        ||
                        "RETURN".equals(
                            transactionType
                        )
                    ) {

                        quantityPrefix = "+";

                    } else if (
                        "STOCK_OUT".equals(
                            transactionType
                        )
                    ) {

                        quantityPrefix = "-";
                    }


                    row.put(
                        "quantity_display",
                        quantityPrefix
                        +
                        quantity
                        +
                        " "
                        +
                        unit
                    );


                    // =========================================
                    // ADD ROW
                    // =========================================

                    transactions.add(row);


                    // =========================================
                    // COUNTERS
                    // =========================================

                    totalTransactions++;


                    if (
                        "STOCK_IN".equals(
                            transactionType
                        )
                    ) {

                        totalStockIn++;

                    } else if (
                        "STOCK_OUT".equals(
                            transactionType
                        )
                    ) {

                        totalStockOut++;

                    } else if (
                        "RETURN".equals(
                            transactionType
                        )
                    ) {

                        totalReturn++;

                    } else if (
                        "ADJUSTMENT".equals(
                            transactionType
                        )
                    ) {

                        totalAdjustment++;
                    }
                }
            }


        } catch (SQLException e) {


            // =================================================
            // PRINT REAL ERROR IN ECLIPSE / TOMCAT CONSOLE
            // =================================================

            e.printStackTrace();


            throw new ServletException(
                "Tidak dapat memuatkan sejarah transaksi inventori.",
                e
            );
        }


        // =====================================================
        // SEND TRANSACTION DATA TO JSP
        // =====================================================

        request.setAttribute(
            "transactions",
            transactions
        );


        // =====================================================
        // SUMMARY CARDS
        // =====================================================

        request.setAttribute(
            "totalTransactions",
            totalTransactions
        );


        request.setAttribute(
            "totalStockIn",
            totalStockIn
        );


        request.setAttribute(
            "totalStockOut",
            totalStockOut
        );


        request.setAttribute(
            "totalReturn",
            totalReturn
        );


        request.setAttribute(
            "totalAdjustment",
            totalAdjustment
        );


        // =====================================================
        // KEEP FILTER VALUES
        // =====================================================

        request.setAttribute(
            "search",
            search
        );


        request.setAttribute(
            "selectedType",
            type
        );


        request.setAttribute(
            "dateFrom",
            dateFrom
        );


        request.setAttribute(
            "dateTo",
            dateTo
        );


        // =====================================================
        // PAGE TITLE
        // =====================================================

        request.setAttribute(
            "pageTitle",
            "Sejarah Transaksi Inventori"
        );


        // =====================================================
        // FORWARD TO JSP
        // =====================================================

        request
            .getRequestDispatcher(
                "/inventory-transactions.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // CLEAN PARAMETER
    // =========================================================

    private String cleanParameter(
            String value
    ) {

        if (value == null) {

            return "";
        }


        return value.trim();
    }
}