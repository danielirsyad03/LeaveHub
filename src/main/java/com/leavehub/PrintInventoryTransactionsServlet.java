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


@WebServlet("/print-inventory-transactions")
public class PrintInventoryTransactionsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");


        // =====================================================
        // SESSION CHECK
        // =====================================================

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // ROLE CHECK
        // HR ONLY
        // =====================================================

        String role = "";

        if (session.getAttribute("userRole") != null) {

            role = session
                    .getAttribute("userRole")
                    .toString()
                    .trim();
        }


        if (!"HR".equalsIgnoreCase(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mengakses halaman ini."
            );

            return;
        }


        // =====================================================
        // GET FILTER PARAMETERS
        // =====================================================

        String search =
                clean(
                    request.getParameter("search")
                );

        String type =
                clean(
                    request.getParameter("type")
                );

        String dateFrom =
                clean(
                    request.getParameter("dateFrom")
                );

        String dateTo =
                clean(
                    request.getParameter("dateTo")
                );


        // =====================================================
        // TRANSACTION LIST
        // =====================================================

        List<Map<String, Object>> transactions =
                new ArrayList<>();


        // =====================================================
        // SQL
        //
        // DATABASE STRUCTURE:
        //
        // inventory_transactions.item_id
        //          ↓
        // inventory_items.id
        //
        // inventory_transactions.user_id
        //          ↓
        // users.id
        //
        // inventory_transactions.performed_by
        //          ↓
        // users.id
        //
        // =====================================================

        StringBuilder sql = new StringBuilder();

        sql.append("""

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
                i.unit,

                u.name AS user_name,

                p.name AS performed_by_name

            FROM inventory_transactions t

            LEFT JOIN inventory_items i
                ON t.item_id = i.id

            LEFT JOIN users u
                ON t.user_id = u.id

            LEFT JOIN users p
                ON t.performed_by = p.id

            WHERE 1 = 1

        """);


        // =====================================================
        // PARAMETERS
        // =====================================================

        List<Object> parameters =
                new ArrayList<>();


        // =====================================================
        // SEARCH FILTER
        // =====================================================

        if (!search.isEmpty()) {

            sql.append("""

                AND (

                    LOWER(
                        COALESCE(i.item_code, '')
                    ) LIKE ?

                    OR

                    LOWER(
                        COALESCE(i.item_name, '')
                    ) LIKE ?

                    OR

                    LOWER(
                        COALESCE(i.category, '')
                    ) LIKE ?

                    OR

                    LOWER(
                        COALESCE(u.name, '')
                    ) LIKE ?

                    OR

                    LOWER(
                        COALESCE(p.name, '')
                    ) LIKE ?

                    OR

                    LOWER(
                        COALESCE(t.remarks, '')
                    ) LIKE ?

                    OR

                    CAST(
                        t.request_id AS CHAR
                    ) LIKE ?

                )

            """);


            String keyword =
                    "%" +
                    search.toLowerCase() +
                    "%";


            parameters.add(keyword);
            parameters.add(keyword);
            parameters.add(keyword);
            parameters.add(keyword);
            parameters.add(keyword);
            parameters.add(keyword);
            parameters.add(keyword);
        }


        // =====================================================
        // TRANSACTION TYPE FILTER
        // =====================================================

        if (!type.isEmpty()) {

            sql.append(
                " AND t.transaction_type = ? "
            );

            parameters.add(type);
        }


        // =====================================================
        // DATE FROM
        // =====================================================

        if (!dateFrom.isEmpty()) {

            sql.append(
                " AND DATE(t.created_at) >= ? "
            );

            parameters.add(dateFrom);
        }


        // =====================================================
        // DATE TO
        // =====================================================

        if (!dateTo.isEmpty()) {

            sql.append(
                " AND DATE(t.created_at) <= ? "
            );

            parameters.add(dateTo);
        }


        // =====================================================
        // ORDER
        // =====================================================

        sql.append(
            " ORDER BY t.created_at DESC, t.id DESC "
        );


        // =====================================================
        // DATABASE
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
            // EXECUTE QUERY
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

                    row.put(
                        "request_id",
                        rs.getObject("request_id")
                    );

                    row.put(
                        "user_id",
                        rs.getObject("user_id")
                    );

                    row.put(
                        "transaction_type",
                        rs.getString("transaction_type")
                    );

                    row.put(
                        "quantity",
                        rs.getInt("quantity")
                    );

                    row.put(
                        "stock_before",
                        rs.getInt("stock_before")
                    );

                    row.put(
                        "stock_after",
                        rs.getInt("stock_after")
                    );

                    row.put(
                        "remarks",
                        rs.getString("remarks")
                    );

                    row.put(
                        "performed_by",
                        rs.getObject("performed_by")
                    );

                    row.put(
                        "created_at",
                        rs.getTimestamp("created_at")
                    );


                    // =========================================
                    // INVENTORY ITEM
                    // =========================================

                    row.put(
                        "item_code",
                        rs.getString("item_code")
                    );

                    row.put(
                        "item_name",
                        rs.getString("item_name")
                    );

                    row.put(
                        "category",
                        rs.getString("category")
                    );


                    String unit =
                            rs.getString("unit");

                    if (unit == null ||
                        unit.isBlank()) {

                        unit = "Unit";
                    }

                    row.put(
                        "unit",
                        unit
                    );


                    // =========================================
                    // USER / RECEIVER
                    // =========================================

                    String userName =
                            rs.getString("user_name");

                    if (userName == null ||
                        userName.isBlank()) {

                        userName = "-";
                    }

                    row.put(
                        "user_name",
                        userName
                    );


                    // =========================================
                    // PERFORMED BY
                    // =========================================

                    String performedByName =
                            rs.getString(
                                "performed_by_name"
                            );

                    if (performedByName == null ||
                        performedByName.isBlank()) {

                        performedByName = "-";
                    }

                    row.put(
                        "performed_by_name",
                        performedByName
                    );


                    // =========================================
                    // ADD TO LIST
                    // =========================================

                    transactions.add(row);
                }
            }


        } catch (SQLException e) {

            e.printStackTrace();

            throw new ServletException(
                "Gagal mendapatkan sejarah transaksi inventori.",
                e
            );
        }


        // =====================================================
        // USER INFORMATION FOR PRINT HEADER
        // =====================================================

        String printedBy = "HR Admin";

        if (session.getAttribute("userName") != null) {

            printedBy =
                    session
                        .getAttribute("userName")
                        .toString();
        }


        // =====================================================
        // REQUEST ATTRIBUTES
        // =====================================================

        request.setAttribute(
            "transactions",
            transactions
        );

        request.setAttribute(
            "search",
            search
        );

        request.setAttribute(
            "type",
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

        request.setAttribute(
            "totalRecords",
            transactions.size()
        );

        request.setAttribute(
            "printedBy",
            printedBy
        );

        request.setAttribute(
            "printedRole",
            role
        );


        // =====================================================
        // FORWARD TO PRINT JSP
        // =====================================================

        request
            .getRequestDispatcher(
                "/print-inventory-transactions.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // CLEAN PARAMETER
    // =========================================================

    private String clean(String value) {

        return value == null
                ? ""
                : value.trim();
    }
}