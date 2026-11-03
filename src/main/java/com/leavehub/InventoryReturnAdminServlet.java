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
import java.sql.Types;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/inventory-return-admin")
public class InventoryReturnAdminServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // PAPARKAN SENARAI PERMOHONAN PEMULANGAN
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
        // Sistem PKB menggunakan session "userRole"
        // =====================================================

        String role =
                session.getAttribute("userRole") == null
                    ? ""
                    : session
                        .getAttribute("userRole")
                        .toString();


        if (
            !"HR".equalsIgnoreCase(
                role.trim()
            )
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mengakses halaman ini."
            );

            return;
        }


        // =====================================================
        // LIST
        // =====================================================

        List<Map<String, Object>> returns =
                new ArrayList<>();


        // =====================================================
        // SQL
        // =====================================================

        String sql = """

            SELECT

                ir.id,
                ir.request_id,
                ir.item_id,
                ir.user_id,
                ir.quantity,
                ir.remarks,
                ir.status,
                ir.requested_at,
                ir.reviewed_at,
                ir.reviewed_by,

                req.quantity AS requested_quantity,
                req.returned_quantity,

                u.name AS staff_name,
                u.email AS staff_email,

                i.item_code,
                i.item_name,
                i.category,
                i.item_type,
                i.brand,
                i.size,
                i.color,
                i.unit,
                i.available_quantity,

                reviewer.name AS reviewer_name

            FROM inventory_returns ir

            INNER JOIN inventory_requests req
                ON ir.request_id = req.id

            INNER JOIN users u
                ON ir.user_id = u.id

            INNER JOIN inventory_items i
                ON ir.item_id = i.id

            LEFT JOIN users reviewer
                ON ir.reviewed_by = reviewer.id

            ORDER BY

                CASE

                    WHEN ir.status = 'PENDING'
                    THEN 0

                    WHEN ir.status = 'APPROVED'
                    THEN 1

                    WHEN ir.status = 'REJECTED'
                    THEN 2

                    ELSE 3

                END,

                ir.requested_at DESC,
                ir.id DESC

        """;


        // =====================================================
        // LOAD DATA
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

                Map<String, Object> row =
                        new HashMap<>();


                row.put(
                    "id",
                    rs.getInt("id")
                );


                row.put(
                    "request_id",
                    rs.getInt("request_id")
                );


                row.put(
                    "item_id",
                    rs.getInt("item_id")
                );


                row.put(
                    "user_id",
                    rs.getInt("user_id")
                );


                row.put(
                    "quantity",
                    rs.getInt("quantity")
                );


                row.put(
                    "remarks",
                    rs.getString("remarks")
                );


                row.put(
                    "status",
                    rs.getString("status")
                );


                row.put(
                    "requested_at",
                    rs.getTimestamp("requested_at")
                );


                row.put(
                    "reviewed_at",
                    rs.getTimestamp("reviewed_at")
                );


                row.put(
                    "reviewed_by",
                    rs.getObject("reviewed_by")
                );


                row.put(
                    "requested_quantity",
                    rs.getInt("requested_quantity")
                );


                row.put(
                    "returned_quantity",
                    rs.getInt("returned_quantity")
                );


                row.put(
                    "staff_name",
                    rs.getString("staff_name")
                );


                row.put(
                    "staff_email",
                    rs.getString("staff_email")
                );


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


                row.put(
                    "item_type",
                    rs.getString("item_type")
                );


                row.put(
                    "brand",
                    rs.getString("brand")
                );


                row.put(
                    "size",
                    rs.getString("size")
                );


                row.put(
                    "color",
                    rs.getString("color")
                );


                String unit =
                        rs.getString("unit");


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


                row.put(
                    "available_quantity",
                    rs.getInt("available_quantity")
                );


                row.put(
                    "reviewer_name",
                    rs.getString("reviewer_name")
                );


                returns.add(row);
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan permohonan pemulangan inventori.",
                e
            );
        }


        // =====================================================
        // COUNTERS
        // =====================================================

        int total = returns.size();

        int pending = 0;
        int approved = 0;
        int rejected = 0;


        for (
            Map<String, Object> row :
            returns
        ) {

            String status =
                    String.valueOf(
                        row.get("status")
                    );


            if (
                "PENDING".equalsIgnoreCase(
                    status
                )
            ) {

                pending++;


            } else if (
                "APPROVED".equalsIgnoreCase(
                    status
                )
            ) {

                approved++;


            } else if (
                "REJECTED".equalsIgnoreCase(
                    status
                )
            ) {

                rejected++;
            }
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "returns",
            returns
        );


        request.setAttribute(
            "totalReturns",
            total
        );


        request.setAttribute(
            "pendingReturns",
            pending
        );


        request.setAttribute(
            "approvedReturns",
            approved
        );


        request.setAttribute(
            "rejectedReturns",
            rejected
        );


        request.setAttribute(
            "pageTitle",
            "Pemulangan Inventori"
        );


        // =====================================================
        // OPEN JSP
        // =====================================================

        request
            .getRequestDispatcher(
                "/inventory-return-admin.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // POST
    // APPROVE / REJECT RETURN
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding(
            "UTF-8"
        );


        HttpSession session =
                request.getSession(false);


        // =====================================================
        // CHECK LOGIN
        // =====================================================

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
        // =====================================================

        String role =
                session.getAttribute("userRole") == null
                    ? ""
                    : session
                        .getAttribute("userRole")
                        .toString();


        if (
            !"HR".equalsIgnoreCase(
                role.trim()
            )
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Anda tidak mempunyai kebenaran untuk mengakses halaman ini."
            );

            return;
        }


        // =====================================================
        // REVIEWER ID
        // =====================================================

        int reviewerId;


        try {

            reviewerId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );


            if (
                reviewerId <= 0
            ) {

                throw new NumberFormatException();
            }


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
        // ACTION
        // =====================================================

        String action =
                clean(
                    request.getParameter(
                        "action"
                    )
                );


        try {

            if (
                "approve".equalsIgnoreCase(
                    action
                )
            ) {

                approveReturn(
                    request,
                    reviewerId
                );


                redirect(
                    request,
                    response,
                    "Pemulangan inventori berjaya diluluskan dan stok telah dikemas kini.",
                    false
                );


            } else if (
                "reject".equalsIgnoreCase(
                    action
                )
            ) {

                rejectReturn(
                    request,
                    reviewerId
                );


                redirect(
                    request,
                    response,
                    "Permohonan pemulangan inventori telah ditolak.",
                    false
                );


            } else {

                redirect(
                    request,
                    response,
                    "Tindakan pemulangan tidak sah.",
                    true
                );
            }


        } catch (Exception e) {

            String message =
                    e.getMessage();


            if (
                message == null
                ||
                message.isBlank()
            ) {

                message =
                        "Tidak dapat memproses pemulangan inventori.";
            }


            redirect(
                request,
                response,
                message,
                true
            );
        }
    }


    // =========================================================
    // APPROVE RETURN
    // =========================================================

    private void approveReturn(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {


        int returnId =
                parsePositiveId(
                    request.getParameter(
                        "return_id"
                    )
                );


        String adminRemarks =
                clean(
                    request.getParameter(
                        "admin_remarks"
                    )
                );


        Connection con =
                null;


        try {

            con =
                    DBConnection.getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // LOCK RETURN REQUEST
            // =================================================

            String returnSql = """

                SELECT

                    ir.request_id,
                    ir.item_id,
                    ir.user_id,
                    ir.quantity,
                    ir.remarks,
                    ir.status,

                    i.item_name,
                    i.item_code,
                    i.unit

                FROM inventory_returns ir

                INNER JOIN inventory_items i
                    ON ir.item_id = i.id

                WHERE ir.id = ?

                FOR UPDATE

            """;


            int requestId;
            int itemId;
            int staffUserId;
            int returnQuantity;

            String returnRemarks;
            String returnStatus;

            String itemName;
            String itemCode;
            String unit;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            returnSql
                        )
            ) {

                ps.setInt(
                    1,
                    returnId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        !rs.next()
                    ) {

                        throw new Exception(
                            "Permohonan pemulangan tidak dijumpai."
                        );
                    }


                    requestId =
                            rs.getInt(
                                "request_id"
                            );


                    itemId =
                            rs.getInt(
                                "item_id"
                            );


                    staffUserId =
                            rs.getInt(
                                "user_id"
                            );


                    returnQuantity =
                            rs.getInt(
                                "quantity"
                            );


                    returnRemarks =
                            rs.getString(
                                "remarks"
                            );


                    returnStatus =
                            rs.getString(
                                "status"
                            );


                    itemName =
                            rs.getString(
                                "item_name"
                            );


                    itemCode =
                            rs.getString(
                                "item_code"
                            );


                    unit =
                            rs.getString(
                                "unit"
                            );
                }
            }


            // =================================================
            // VALIDATE STATUS
            // =================================================

            if (
                !"PENDING".equalsIgnoreCase(
                    returnStatus
                )
            ) {

                throw new Exception(
                    "Permohonan pemulangan ini telah diproses sebelum ini."
                );
            }


            // =================================================
            // VALIDATE QUANTITY
            // =================================================

            if (
                returnQuantity <= 0
            ) {

                throw new Exception(
                    "Kuantiti pemulangan tidak sah."
                );
            }


            if (
                unit == null
                ||
                unit.isBlank()
            ) {

                unit = "Unit";
            }


            // =================================================
            // LOCK ORIGINAL REQUEST
            // =================================================

            String originalRequestSql = """

                SELECT

                    quantity,
                    returned_quantity,
                    status

                FROM inventory_requests

                WHERE id = ?

                FOR UPDATE

            """;


            int originalQuantity;
            int currentReturnedQuantity;
            String originalStatus;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            originalRequestSql
                        )
            ) {

                ps.setInt(
                    1,
                    requestId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        !rs.next()
                    ) {

                        throw new Exception(
                            "Permohonan inventori asal tidak dijumpai."
                        );
                    }


                    originalQuantity =
                            rs.getInt(
                                "quantity"
                            );


                    currentReturnedQuantity =
                            rs.getInt(
                                "returned_quantity"
                            );


                    originalStatus =
                            rs.getString(
                                "status"
                            );
                }
            }


            if (
                !"APPROVED".equalsIgnoreCase(
                    originalStatus
                )
            ) {

                throw new Exception(
                    "Hanya barang daripada permohonan yang diluluskan boleh dipulangkan."
                );
            }


            // =================================================
            // GET PREVIOUS APPROVED RETURN QUANTITY
            // =================================================

            String approvedReturnSql = """

                SELECT
                    COALESCE(
                        SUM(quantity),
                        0
                    ) AS total_returned

                FROM inventory_returns

                WHERE request_id = ?
                  AND status = 'APPROVED'
                  AND id <> ?

            """;


            int alreadyReturned;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            approvedReturnSql
                        )
            ) {

                ps.setInt(
                    1,
                    requestId
                );


                ps.setInt(
                    2,
                    returnId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    rs.next();


                    alreadyReturned =
                            rs.getInt(
                                "total_returned"
                            );
                }
            }


            // =================================================
            // DATA CONSISTENCY
            //
            // inventory_returns yang APPROVED menjadi sumber
            // utama jumlah yang telah dipulangkan.
            // =================================================

            if (
                currentReturnedQuantity !=
                alreadyReturned
            ) {

                currentReturnedQuantity =
                        alreadyReturned;
            }


            // =================================================
            // MAKE SURE TOTAL RETURN DOES NOT EXCEED REQUEST
            // =================================================

            if (
                alreadyReturned
                +
                returnQuantity
                >
                originalQuantity
            ) {

                throw new Exception(
                    "Jumlah barang yang dipulangkan melebihi kuantiti asal permohonan."
                );
            }


            // =================================================
            // LOCK INVENTORY ITEM
            // =================================================

            String itemSql = """

                SELECT
                    available_quantity

                FROM inventory_items

                WHERE id = ?

                FOR UPDATE

            """;


            int stockBefore;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            itemSql
                        )
            ) {

                ps.setInt(
                    1,
                    itemId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        !rs.next()
                    ) {

                        throw new Exception(
                            "Barang inventori tidak dijumpai."
                        );
                    }


                    stockBefore =
                            rs.getInt(
                                "available_quantity"
                            );
                }
            }


            // =================================================
            // CALCULATE NEW STOCK
            // =================================================

            int stockAfter =
                    stockBefore
                    +
                    returnQuantity;


            String stockStatus =
                    calculateStockStatus(
                        stockAfter
                    );


            // =================================================
            // UPDATE INVENTORY STOCK
            // =================================================

            String updateItemSql = """

                UPDATE inventory_items

                SET
                    available_quantity = ?,
                    status = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateItemSql
                        )
            ) {

                ps.setInt(
                    1,
                    stockAfter
                );


                ps.setString(
                    2,
                    stockStatus
                );


                ps.setInt(
                    3,
                    itemId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Stok inventori tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // APPROVE RETURN
            // =================================================

            String updateReturnSql = """

                UPDATE inventory_returns

                SET
                    status = 'APPROVED',
                    reviewed_at = CURRENT_TIMESTAMP,
                    reviewed_by = ?

                WHERE id = ?
                  AND status = 'PENDING'

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateReturnSql
                        )
            ) {

                ps.setInt(
                    1,
                    reviewerId
                );


                ps.setInt(
                    2,
                    returnId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Permohonan pemulangan telah diproses."
                    );
                }
            }


            // =================================================
            // INVENTORY TRANSACTION
            // RETURN
            // =================================================

            String transactionRemarks =
                    "Pemulangan barang";


            if (
                returnRemarks != null
                &&
                !returnRemarks.isBlank()
            ) {

                transactionRemarks +=
                        " - "
                        + returnRemarks;
            }


            if (
                !adminRemarks.isBlank()
            ) {

                transactionRemarks +=
                        " | Catatan HR: "
                        + adminRemarks;
            }


            String transactionSql = """

                INSERT INTO inventory_transactions
                (
                    item_id,
                    request_id,
                    user_id,
                    transaction_type,
                    quantity,
                    stock_before,
                    stock_after,
                    remarks,
                    performed_by
                )

                VALUES
                (
                    ?,
                    ?,
                    ?,
                    'RETURN',
                    ?,
                    ?,
                    ?,
                    ?,
                    ?
                )

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            transactionSql
                        )
            ) {

                ps.setInt(
                    1,
                    itemId
                );


                ps.setInt(
                    2,
                    requestId
                );


                ps.setInt(
                    3,
                    staffUserId
                );


                ps.setInt(
                    4,
                    returnQuantity
                );


                ps.setInt(
                    5,
                    stockBefore
                );


                ps.setInt(
                    6,
                    stockAfter
                );


                setNullableString(
                    ps,
                    7,
                    transactionRemarks
                );


                ps.setInt(
                    8,
                    reviewerId
                );


                int inserted =
                        ps.executeUpdate();


                if (
                    inserted != 1
                ) {

                    throw new Exception(
                        "Sejarah transaksi pemulangan tidak dapat direkodkan."
                    );
                }
            }


            // =================================================
            // CALCULATE TOTAL RETURNED
            // AFTER THIS APPROVAL
            // =================================================

            int totalReturned =
                    alreadyReturned
                    +
                    returnQuantity;


            // =================================================
            // UPDATE RETURNED QUANTITY
            //
            // INI BAHAGIAN PENTING:
            // Selepas HR approve, jumlah barang yang telah
            // dipulangkan akan disimpan dalam inventory_requests.
            // =================================================

            String updateReturnedQuantitySql = """

                UPDATE inventory_requests

                SET returned_quantity = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateReturnedQuantitySql
                        )
            ) {

                ps.setInt(
                    1,
                    totalReturned
                );


                ps.setInt(
                    2,
                    requestId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Jumlah pemulangan permohonan inventori tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // IF FULLY RETURNED
            // SET returned_at
            // =================================================

            if (
                totalReturned >=
                originalQuantity
            ) {

                String updateOriginalSql = """

                    UPDATE inventory_requests

                    SET returned_at =
                        CURRENT_TIMESTAMP

                    WHERE id = ?

                """;


                try (
                    PreparedStatement ps =
                            con.prepareStatement(
                                updateOriginalSql
                            )
                ) {

                    ps.setInt(
                        1,
                        requestId
                    );


                    int updated =
                            ps.executeUpdate();


                    if (
                        updated != 1
                    ) {

                        throw new Exception(
                            "Tarikh pemulangan penuh tidak dapat dikemas kini."
                        );
                    }
                }


            } else {

                // =================================================
                // PARTIAL RETURN
                //
                // Pastikan returned_at masih NULL selagi belum
                // semua unit dipulangkan.
                // =================================================

                String clearReturnedAtSql = """

                    UPDATE inventory_requests

                    SET returned_at = NULL

                    WHERE id = ?

                """;


                try (
                    PreparedStatement ps =
                            con.prepareStatement(
                                clearReturnedAtSql
                            )
                ) {

                    ps.setInt(
                        1,
                        requestId
                    );


                    ps.executeUpdate();
                }
            }


            // =================================================
            // NOTIFICATION
            // =================================================

            String notificationMessage =
                    "Pemulangan "
                    + returnQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " telah diluluskan oleh HR."
                    + " Jumlah dipulangkan: "
                    + totalReturned
                    + " daripada "
                    + originalQuantity
                    + " "
                    + unit
                    + ".";


            if (
                !adminRemarks.isBlank()
            ) {

                notificationMessage +=
                        " Catatan HR: "
                        + adminRemarks;
            }


            NotificationUtil.create(
                con,
                staffUserId,
                "INVENTORY_RETURN_APPROVED",
                "Pemulangan Inventori Diluluskan",
                notificationMessage,
                "INVENTORY_RETURN",
                returnId
            );


            // =================================================
            // ACTIVITY LOG
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "APPROVE_INVENTORY_RETURN",
                "Meluluskan pemulangan inventori #"
                    + returnId
                    + " untuk "
                    + itemName
                    + " ("
                    + itemCode
                    + ") sebanyak "
                    + returnQuantity
                    + " "
                    + unit
                    + " (Stok: "
                    + stockBefore
                    + " → "
                    + stockAfter
                    + ", Dipulangkan: "
                    + totalReturned
                    + "/"
                    + originalQuantity
                    + ")",
                "INVENTORY_RETURN",
                returnId
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


        } catch (Exception e) {

            if (
                con != null
            ) {

                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            throw e;


        } finally {

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
    // REJECT RETURN
    // =========================================================

    private void rejectReturn(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {


        int returnId =
                parsePositiveId(
                    request.getParameter(
                        "return_id"
                    )
                );


        String adminRemarks =
                clean(
                    request.getParameter(
                        "admin_remarks"
                    )
                );


        // =====================================================
        // REJECTION REASON REQUIRED
        // =====================================================

        if (
            adminRemarks.isBlank()
        ) {

            throw new Exception(
                "Sila masukkan sebab pemulangan ditolak."
            );
        }


        Connection con =
                null;


        try {

            con =
                    DBConnection.getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // LOCK RETURN
            // =================================================

            String selectSql = """

                SELECT

                    ir.request_id,
                    ir.user_id,
                    ir.quantity,
                    ir.status,

                    i.item_name,
                    i.item_code,
                    i.unit

                FROM inventory_returns ir

                INNER JOIN inventory_items i
                    ON ir.item_id = i.id

                WHERE ir.id = ?

                FOR UPDATE

            """;


            int requestId;
            int staffUserId;
            int returnQuantity;

            String currentStatus;

            String itemName;
            String itemCode;
            String unit;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            selectSql
                        )
            ) {

                ps.setInt(
                    1,
                    returnId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        !rs.next()
                    ) {

                        throw new Exception(
                            "Permohonan pemulangan tidak dijumpai."
                        );
                    }


                    requestId =
                            rs.getInt(
                                "request_id"
                            );


                    staffUserId =
                            rs.getInt(
                                "user_id"
                            );


                    returnQuantity =
                            rs.getInt(
                                "quantity"
                            );


                    currentStatus =
                            rs.getString(
                                "status"
                            );


                    itemName =
                            rs.getString(
                                "item_name"
                            );


                    itemCode =
                            rs.getString(
                                "item_code"
                            );


                    unit =
                            rs.getString(
                                "unit"
                            );
                }
            }


            if (
                !"PENDING".equalsIgnoreCase(
                    currentStatus
                )
            ) {

                throw new Exception(
                    "Permohonan pemulangan ini telah diproses sebelum ini."
                );
            }


            if (
                unit == null
                ||
                unit.isBlank()
            ) {

                unit = "Unit";
            }


            // =================================================
            // REJECT
            // =================================================

            String updateSql = """

                UPDATE inventory_returns

                SET
                    status = 'REJECTED',
                    reviewed_at = CURRENT_TIMESTAMP,
                    reviewed_by = ?,
                    remarks = CASE
                        WHEN remarks IS NULL
                             OR TRIM(remarks) = ''
                        THEN ?
                        ELSE CONCAT(
                            remarks,
                            ' | HR: ',
                            ?
                        )
                    END

                WHERE id = ?
                  AND status = 'PENDING'

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateSql
                        )
            ) {

                ps.setInt(
                    1,
                    reviewerId
                );


                ps.setString(
                    2,
                    adminRemarks
                );


                ps.setString(
                    3,
                    adminRemarks
                );


                ps.setInt(
                    4,
                    returnId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Permohonan pemulangan tidak dijumpai atau telah diproses."
                    );
                }
            }


            // =================================================
            // NOTIFICATION
            // =================================================

            String notificationMessage =
                    "Permohonan pemulangan "
                    + returnQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " telah ditolak."
                    + " Sebab: "
                    + adminRemarks;


            NotificationUtil.create(
                con,
                staffUserId,
                "INVENTORY_RETURN_REJECTED",
                "Pemulangan Inventori Ditolak",
                notificationMessage,
                "INVENTORY_RETURN",
                returnId
            );


            // =================================================
            // ACTIVITY LOG
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "REJECT_INVENTORY_RETURN",
                "Menolak pemulangan inventori #"
                    + returnId
                    + " untuk "
                    + itemName
                    + " ("
                    + itemCode
                    + ") sebanyak "
                    + returnQuantity
                    + " "
                    + unit
                    + ". Sebab: "
                    + adminRemarks,
                "INVENTORY_RETURN",
                returnId
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


        } catch (Exception e) {

            if (
                con != null
            ) {

                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            throw e;


        } finally {

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
    // CALCULATE STOCK STATUS
    // =========================================================

    private String calculateStockStatus(
            int availableQuantity) {


        if (
            availableQuantity <= 0
        ) {

            return "OUT_OF_STOCK";
        }


        if (
            availableQuantity <= 5
        ) {

            return "LOW_STOCK";
        }


        return "AVAILABLE";
    }


    // =========================================================
    // POSITIVE ID
    // =========================================================

    private int parsePositiveId(
            String value)
            throws Exception {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            throw new Exception(
                "ID pemulangan tidak sah."
            );
        }


        try {

            int id =
                    Integer.parseInt(
                        value.trim()
                    );


            if (
                id <= 0
            ) {

                throw new Exception(
                    "ID pemulangan tidak sah."
                );
            }


            return id;


        } catch (
            NumberFormatException e
        ) {

            throw new Exception(
                "ID pemulangan tidak sah."
            );
        }
    }


    // =========================================================
    // NULLABLE STRING
    // =========================================================

    private void setNullableString(
            PreparedStatement ps,
            int index,
            String value)
            throws SQLException {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            ps.setNull(
                index,
                Types.VARCHAR
            );


        } else {

            ps.setString(
                index,
                value
            );
        }
    }


    // =========================================================
    // CLEAN
    // =========================================================

    private String clean(
            String value) {


        if (
            value == null
        ) {

            return "";
        }


        return value.trim();
    }


    // =========================================================
    // REDIRECT
    // =========================================================

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            String message,
            boolean error)
            throws IOException {


        String encoded =
                URLEncoder.encode(
                    message,
                    StandardCharsets.UTF_8
                );


        response.sendRedirect(
            request.getContextPath()
            + "/inventory-return-admin?"
            + (
                error
                    ? "error="
                    : "success="
            )
            + encoded
        );
    }
}