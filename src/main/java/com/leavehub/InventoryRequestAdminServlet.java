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


@WebServlet("/inventory-request-admin")
public class InventoryRequestAdminServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // PAPARKAN SENARAI PERMOHONAN INVENTORI
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
                HttpServletResponse.SC_FORBIDDEN
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
        // =====================================================

        String sql = """

            SELECT
                r.id,
                r.user_id,
                r.item_id,
                r.quantity,
                r.purpose,
                r.status,
                r.remarks,
                r.requested_at,
                r.reviewed_at,
                r.reviewed_by,
                r.returned_at,

                u.name AS staff_name,
                u.email AS staff_email,

                i.item_code,
                i.item_name,
                i.category,
                i.item_type,
                i.available_quantity

            FROM inventory_requests r

            JOIN users u
                ON r.user_id = u.id

            JOIN inventory_items i
                ON r.item_id = i.id

            ORDER BY

                CASE

                    WHEN r.status = 'PENDING'
                    THEN 0

                    WHEN r.status = 'APPROVED'
                    THEN 1

                    WHEN r.status = 'REJECTED'
                    THEN 2

                    WHEN r.status = 'CANCELLED'
                    THEN 3

                    ELSE 4

                END,

                r.requested_at DESC

        """;


        // =====================================================
        // LOAD REQUESTS
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
                    "user_id",
                    rs.getInt("user_id")
                );


                row.put(
                    "item_id",
                    rs.getInt("item_id")
                );


                row.put(
                    "quantity",
                    rs.getInt("quantity")
                );


                row.put(
                    "purpose",
                    rs.getString("purpose")
                );


                row.put(
                    "status",
                    rs.getString("status")
                );


                row.put(
                    "remarks",
                    rs.getString("remarks")
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


                row.put(
                    "staff_name",
                    rs.getString(
                        "staff_name"
                    )
                );


                row.put(
                    "staff_email",
                    rs.getString(
                        "staff_email"
                    )
                );


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
                    "available_quantity",
                    rs.getInt(
                        "available_quantity"
                    )
                );


                requests.add(row);
            }


        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan permohonan inventori.",
                e
            );
        }


        // =====================================================
        // COUNTERS
        // =====================================================

        int total =
                requests.size();

        int pending = 0;
        int approved = 0;
        int rejected = 0;
        int cancelled = 0;


        for (
            Map<String, Object> row :
            requests
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


            } else if (
                "CANCELLED".equalsIgnoreCase(
                    status
                )
            ) {

                cancelled++;
            }
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "requests",
            requests
        );


        request.setAttribute(
            "totalRequests",
            total
        );


        request.setAttribute(
            "pendingRequests",
            pending
        );


        request.setAttribute(
            "approvedRequests",
            approved
        );


        request.setAttribute(
            "rejectedRequests",
            rejected
        );


        request.setAttribute(
            "cancelledRequests",
            cancelled
        );


        request.setAttribute(
            "pageTitle",
            "Permohonan Inventori"
        );


        // =====================================================
        // OPEN JSP
        // =====================================================

        request.getRequestDispatcher(
            "/inventory-request-admin.jsp"
        ).forward(
            request,
            response
        );
    }


    // =========================================================
    // POST
    // APPROVE / REJECT
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
                HttpServletResponse.SC_FORBIDDEN
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


        } catch (NumberFormatException e) {

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

                approveRequest(
                    request,
                    reviewerId
                );


                redirect(
                    request,
                    response,
                    "Permohonan inventori berjaya diluluskan.",
                    false
                );


            } else if (
                "reject".equalsIgnoreCase(
                    action
                )
            ) {

                rejectRequest(
                    request,
                    reviewerId
                );


                redirect(
                    request,
                    response,
                    "Permohonan inventori telah ditolak.",
                    false
                );


            } else {

                redirect(
                    request,
                    response,
                    "Tindakan permohonan tidak sah.",
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
                        "Tidak dapat memproses permohonan inventori.";
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
    // APPROVE REQUEST
    // =========================================================

    private void approveRequest(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {


        int requestId =
                parsePositiveId(
                    request.getParameter(
                        "request_id"
                    )
                );


        String remarks =
                clean(
                    request.getParameter(
                        "remarks"
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
            // LOCK REQUEST + GET APPLICANT
            // =================================================

            String requestSql = """

                SELECT
                    r.user_id,
                    r.item_id,
                    r.quantity,
                    r.status,
                    i.item_name

                FROM inventory_requests r

                JOIN inventory_items i
                    ON r.item_id = i.id

                WHERE r.id = ?

                FOR UPDATE

            """;


            int applicantUserId;
            int itemId;
            int requestedQuantity;

            String currentStatus;
            String itemName;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            requestSql
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

                    if (!rs.next()) {

                        throw new Exception(
                            "Permohonan inventori tidak dijumpai."
                        );
                    }


                    applicantUserId =
                            rs.getInt(
                                "user_id"
                            );


                    itemId =
                            rs.getInt(
                                "item_id"
                            );


                    requestedQuantity =
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
                }
            }


            // =================================================
            // MUST STILL BE PENDING
            // =================================================

            if (
                !"PENDING".equalsIgnoreCase(
                    currentStatus
                )
            ) {

                throw new Exception(
                    "Permohonan ini telah diproses sebelum ini."
                );
            }


            // =================================================
            // VALID QUANTITY
            // =================================================

            if (
                requestedQuantity <= 0
            ) {

                throw new Exception(
                    "Kuantiti permohonan tidak sah."
                );
            }


            // =================================================
            // LOCK ITEM
            // =================================================

            String itemSql = """

                SELECT
                    available_quantity

                FROM inventory_items

                WHERE id = ?

                FOR UPDATE

            """;


            int available;


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

                    if (!rs.next()) {

                        throw new Exception(
                            "Inventori tidak dijumpai."
                        );
                    }


                    available =
                            rs.getInt(
                                "available_quantity"
                            );
                }
            }


            // =================================================
            // STOCK CHECK
            // =================================================

            if (
                requestedQuantity >
                available
            ) {

                throw new Exception(
                    "Stok tidak mencukupi. "
                    + "Hanya "
                    + available
                    + " unit tersedia."
                );
            }


            // =================================================
            // NEW STOCK
            // =================================================

            int newAvailable =
                    available
                    -
                    requestedQuantity;


            String stockStatus =
                    calculateStockStatus(
                        newAvailable
                    );


            // =================================================
            // UPDATE INVENTORY
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
                    newAvailable
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
                        "Inventori tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // APPROVE REQUEST
            // =================================================

            String updateRequestSql = """

                UPDATE inventory_requests

                SET
                    status = 'APPROVED',
                    remarks = ?,
                    reviewed_at = CURRENT_TIMESTAMP,
                    reviewed_by = ?

                WHERE id = ?
                  AND status = 'PENDING'

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateRequestSql
                        )
            ) {

                setNullableString(
                    ps,
                    1,
                    remarks
                );


                ps.setInt(
                    2,
                    reviewerId
                );


                ps.setInt(
                    3,
                    requestId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Permohonan ini telah diproses."
                    );
                }
            }


            // =================================================
            // INVENTORY TRANSACTION HISTORY
            // =================================================
            //
            // Simpan sejarah pergerakan stok.
            //
            // available    = stok sebelum
            // newAvailable = stok selepas
            //
            // =================================================

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
                    'STOCK_OUT',
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

                // =============================================
                // ITEM
                // =============================================

                ps.setInt(
                    1,
                    itemId
                );


                // =============================================
                // REQUEST
                // =============================================

                ps.setInt(
                    2,
                    requestId
                );


                // =============================================
                // STAFF YANG MEMOHON
                // =============================================

                ps.setInt(
                    3,
                    applicantUserId
                );


                // =============================================
                // KUANTITI KELUAR
                // =============================================

                ps.setInt(
                    4,
                    requestedQuantity
                );


                // =============================================
                // STOK SEBELUM
                // =============================================

                ps.setInt(
                    5,
                    available
                );


                // =============================================
                // STOK SELEPAS
                // =============================================

                ps.setInt(
                    6,
                    newAvailable
                );


                // =============================================
                // CATATAN
                // =============================================

                setNullableString(
                    ps,
                    7,
                    remarks
                );


                // =============================================
                // HR YANG MELULUSKAN
                // =============================================

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
                        "Sejarah transaksi inventori tidak dapat direkodkan."
                    );
                }
            }


            // =================================================
            // CREATE STAFF NOTIFICATION
            // =================================================

            String notificationMessage =
                    "Permohonan anda untuk "
                    + requestedQuantity
                    + " unit "
                    + itemName
                    + " telah diluluskan.";


            if (
                !remarks.isBlank()
            ) {

                notificationMessage +=
                        " Catatan: "
                        + remarks;
            }


            NotificationUtil.create(
                con,
                applicantUserId,
                "INVENTORY_REQUEST_APPROVED",
                "Permohonan Inventori Diluluskan",
                notificationMessage,
                "INVENTORY_REQUEST",
                requestId
            );


            // =================================================
            // AUDIT TRAIL
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "APPROVE_INVENTORY_REQUEST",
                "Meluluskan permohonan inventori #"
                    + requestId
                    + ": "
                    + requestedQuantity
                    + " unit "
                    + itemName
                    + " (Stok: "
                    + available
                    + " → "
                    + newAvailable
                    + ")",
                "INVENTORY_REQUEST",
                requestId
            );


            // =================================================
            // COMMIT
            // =================================================
            //
            // Semua perubahan dibuat sekali:
            //
            // 1. Stok inventori
            // 2. Status permohonan
            // 3. Sejarah transaksi
            // 4. Notifikasi
            // 5. Activity Log
            //
            // Jika salah satu gagal, semuanya akan rollback.
            //
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
    // REJECT REQUEST
    // =========================================================

    private void rejectRequest(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {


        int requestId =
                parsePositiveId(
                    request.getParameter(
                        "request_id"
                    )
                );


        String remarks =
                clean(
                    request.getParameter(
                        "remarks"
                    )
                );


        // =====================================================
        // REMARK REQUIRED
        // =====================================================

        if (
            remarks.isBlank()
        ) {

            throw new Exception(
                "Sila masukkan sebab permohonan ditolak."
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
            // LOCK REQUEST + GET APPLICANT
            // =================================================

            String selectSql = """

                SELECT
                    r.user_id,
                    r.quantity,
                    r.status,
                    i.item_name

                FROM inventory_requests r

                JOIN inventory_items i
                    ON r.item_id = i.id

                WHERE r.id = ?

                FOR UPDATE

            """;


            int applicantUserId;
            int requestedQuantity;

            String currentStatus;
            String itemName;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            selectSql
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
                            "Permohonan inventori tidak dijumpai."
                        );
                    }


                    applicantUserId =
                            rs.getInt(
                                "user_id"
                            );


                    requestedQuantity =
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
                }
            }


            // =================================================
            // MUST STILL BE PENDING
            // =================================================

            if (
                !"PENDING".equalsIgnoreCase(
                    currentStatus
                )
            ) {

                throw new Exception(
                    "Permohonan ini telah diproses sebelum ini."
                );
            }


            // =================================================
            // REJECT REQUEST
            // =================================================

            String updateSql = """

                UPDATE inventory_requests

                SET
                    status = 'REJECTED',
                    remarks = ?,
                    reviewed_at = CURRENT_TIMESTAMP,
                    reviewed_by = ?

                WHERE id = ?
                  AND status = 'PENDING'

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateSql
                        )
            ) {

                ps.setString(
                    1,
                    remarks
                );


                ps.setInt(
                    2,
                    reviewerId
                );


                ps.setInt(
                    3,
                    requestId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated != 1
                ) {

                    throw new Exception(
                        "Permohonan tidak dijumpai atau telah diproses."
                    );
                }
            }


            // =================================================
            // CREATE STAFF NOTIFICATION
            // =================================================

            String notificationMessage =
                    "Permohonan anda untuk "
                    + requestedQuantity
                    + " unit "
                    + itemName
                    + " telah ditolak."
                    + " Sebab: "
                    + remarks;


            NotificationUtil.create(
                con,
                applicantUserId,
                "INVENTORY_REQUEST_REJECTED",
                "Permohonan Inventori Ditolak",
                notificationMessage,
                "INVENTORY_REQUEST",
                requestId
            );


            // =================================================
            // AUDIT TRAIL
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "REJECT_INVENTORY_REQUEST",
                "Menolak permohonan inventori #"
                    + requestId
                    + ": "
                    + requestedQuantity
                    + " unit "
                    + itemName,
                "INVENTORY_REQUEST",
                requestId
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
                "ID permohonan tidak sah."
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
                    "ID permohonan tidak sah."
                );
            }


            return id;


        } catch (
            NumberFormatException e
        ) {

            throw new Exception(
                "ID permohonan tidak sah."
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
            + "/inventory-request-admin?"
            + (
                error
                    ? "error="
                    : "success="
            )
            + encoded
        );
    }
}