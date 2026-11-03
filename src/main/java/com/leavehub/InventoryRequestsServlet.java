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


@WebServlet("/inventory-requests")
public class InventoryRequestsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // LOAD CURRENT USER'S INVENTORY REQUESTS
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

        } catch (
            NumberFormatException
            |
            NullPointerException e
        ) {

            session.invalidate();


            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // REQUEST LIST
        // =====================================================

        List<Map<String, Object>> requests =
                new ArrayList<>();


        // =====================================================
        // SQL
        //
        // return information:
        //
        // returned_quantity
        //     = quantity already confirmed by HR
        //
        // pending_return_quantity
        //     = quantity submitted by staff but still
        //       waiting for HR confirmation
        //
        // rejected_return_quantity
        //     = historical rejected return quantity
        //
        // remaining_quantity
        //     = calculated later in Java:
        //
        //       approved
        //       - returned
        //       - pending
        // =====================================================

        String sql = """

            SELECT

                r.id,
                r.item_id,
                r.quantity,
                r.returned_quantity,
                r.purpose,
                r.status,
                r.remarks,
                r.requested_at,
                r.reviewed_at,
                r.reviewed_by,
                r.returned_at,

                i.item_code,
                i.item_name,
                i.brand,
                i.size,
                i.color,
                i.category,
                i.item_type,
                i.unit,
                i.location,

                COALESCE(
                    ret.pending_return_quantity,
                    0
                ) AS pending_return_quantity,

                COALESCE(
                    ret.rejected_return_quantity,
                    0
                ) AS rejected_return_quantity,

                COALESCE(
                    ret.total_return_requests,
                    0
                ) AS total_return_requests,

                COALESCE(
                    ret.pending_return_requests,
                    0
                ) AS pending_return_requests

            FROM inventory_requests r

            INNER JOIN inventory_items i
                ON r.item_id = i.id


            LEFT JOIN
            (
                SELECT

                    request_id,

                    SUM(
                        CASE
                            WHEN status = 'PENDING'
                            THEN quantity
                            ELSE 0
                        END
                    ) AS pending_return_quantity,

                    SUM(
                        CASE
                            WHEN status = 'REJECTED'
                            THEN quantity
                            ELSE 0
                        END
                    ) AS rejected_return_quantity,

                    COUNT(*) AS total_return_requests,

                    SUM(
                        CASE
                            WHEN status = 'PENDING'
                            THEN 1
                            ELSE 0
                        END
                    ) AS pending_return_requests

                FROM inventory_returns

                GROUP BY request_id

            ) ret
                ON ret.request_id = r.id


            WHERE r.user_id = ?

            ORDER BY
                r.requested_at DESC,
                r.id DESC

        """;


        // =====================================================
        // LOAD DATA
        // =====================================================

        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {


            ps.setInt(
                1,
                userId
            );


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                while (rs.next()) {


                    Map<String, Object> row =
                            new HashMap<>();


                    // =========================================
                    // REQUEST INFORMATION
                    // =========================================

                    int requestId =
                            rs.getInt(
                                "id"
                            );


                    int approvedQuantity =
                            rs.getInt(
                                "quantity"
                            );


                    int returnedQuantity =
                            rs.getInt(
                                "returned_quantity"
                            );


                    int pendingReturnQuantity =
                            rs.getInt(
                                "pending_return_quantity"
                            );


                    int rejectedReturnQuantity =
                            rs.getInt(
                                "rejected_return_quantity"
                            );


                    int totalReturnRequests =
                            rs.getInt(
                                "total_return_requests"
                            );


                    int pendingReturnRequests =
                            rs.getInt(
                                "pending_return_requests"
                            );


                    String status =
                            rs.getString(
                                "status"
                            );


                    // =========================================
                    // CALCULATE REMAINING QUANTITY
                    //
                    // IMPORTANT:
                    // Pending quantity is included so staff
                    // cannot submit the same quantity twice.
                    // =========================================

                    int remainingQuantity =
                            approvedQuantity
                            -
                            returnedQuantity
                            -
                            pendingReturnQuantity;


                    if (remainingQuantity < 0) {

                        remainingQuantity = 0;
                    }


                    // =========================================
                    // CALCULATE QUANTITY STILL WITH STAFF
                    //
                    // This excludes only confirmed returns.
                    //
                    // Example:
                    //
                    // Approved = 5
                    // Returned = 2
                    //
                    // Staff physically still responsible for 3.
                    //
                    // A pending return is still considered
                    // awaiting HR confirmation.
                    // =========================================

                    int quantityWithStaff =
                            approvedQuantity
                            -
                            returnedQuantity;


                    if (quantityWithStaff < 0) {

                        quantityWithStaff = 0;
                    }


                    // =========================================
                    // RETURN FLAGS
                    // =========================================

                    boolean approved =
                            status != null
                            &&
                            "APPROVED".equalsIgnoreCase(
                                status
                            );


                    boolean canReturn =
                            approved
                            &&
                            remainingQuantity > 0;


                    boolean hasPendingReturn =
                            pendingReturnQuantity > 0;


                    boolean fullyReturned =
                            approved
                            &&
                            approvedQuantity > 0
                            &&
                            returnedQuantity >= approvedQuantity;


                    boolean partiallyReturned =
                            approved
                            &&
                            returnedQuantity > 0
                            &&
                            returnedQuantity < approvedQuantity;


                    // =========================================
                    // BASIC REQUEST DATA
                    // =========================================

                    row.put(
                        "id",
                        requestId
                    );


                    row.put(
                        "item_id",
                        rs.getInt(
                            "item_id"
                        )
                    );


                    row.put(
                        "quantity",
                        approvedQuantity
                    );


                    row.put(
                        "returned_quantity",
                        returnedQuantity
                    );


                    row.put(
                        "pending_return_quantity",
                        pendingReturnQuantity
                    );


                    row.put(
                        "rejected_return_quantity",
                        rejectedReturnQuantity
                    );


                    row.put(
                        "remaining_quantity",
                        remainingQuantity
                    );


                    row.put(
                        "quantity_with_staff",
                        quantityWithStaff
                    );


                    row.put(
                        "total_return_requests",
                        totalReturnRequests
                    );


                    row.put(
                        "pending_return_requests",
                        pendingReturnRequests
                    );


                    row.put(
                        "can_return",
                        canReturn
                    );


                    row.put(
                        "has_pending_return",
                        hasPendingReturn
                    );


                    row.put(
                        "fully_returned",
                        fullyReturned
                    );


                    row.put(
                        "partially_returned",
                        partiallyReturned
                    );


                    row.put(
                        "purpose",
                        rs.getString(
                            "purpose"
                        )
                    );


                    row.put(
                        "status",
                        status
                    );


                    row.put(
                        "remarks",
                        rs.getString(
                            "remarks"
                        )
                    );


                    row.put(
                        "requested_at",
                        rs.getTimestamp(
                            "requested_at"
                        )
                    );


                    row.put(
                        "reviewed_at",
                        rs.getTimestamp(
                            "reviewed_at"
                        )
                    );


                    row.put(
                        "reviewed_by",
                        rs.getObject(
                            "reviewed_by"
                        )
                    );


                    row.put(
                        "returned_at",
                        rs.getTimestamp(
                            "returned_at"
                        )
                    );


                    // =========================================
                    // INVENTORY ITEM INFORMATION
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
                    // LOCATION
                    // =========================================

                    row.put(
                        "location",
                        rs.getString(
                            "location"
                        )
                    );


                    // =========================================
                    // ADD TO LIST
                    // =========================================

                    requests.add(
                        row
                    );
                }
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan permohonan inventori anda.",
                e
            );
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "requests",
            requests
        );


        request.setAttribute(
            "pageTitle",
            "Permohonan Inventori Saya"
        );


        // =====================================================
        // OPEN JSP
        // =====================================================

        request
            .getRequestDispatcher(
                "/inventory-requests.jsp"
            )
            .forward(
                request,
                response
            );
    }
}