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
import java.sql.Statement;
import java.sql.Types;


@WebServlet("/inventory-return")
public class InventoryReturnServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // POST
    // STAFF SUBMIT INVENTORY RETURN REQUEST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        request.setCharacterEncoding("UTF-8");


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
        // GET CURRENT USER ID
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
        // GET FORM PARAMETERS
        // =====================================================

        String requestIdText =
                request.getParameter("requestId");


        String quantityText =
                request.getParameter("quantity");


        String remarks =
                request.getParameter("remarks");


        // =====================================================
        // BASIC VALIDATION
        // =====================================================

        if (
            requestIdText == null
            ||
            requestIdText.isBlank()
            ||
            quantityText == null
            ||
            quantityText.isBlank()
        ) {

            redirectError(
                request,
                response,
                "Maklumat pemulangan tidak lengkap."
            );

            return;
        }


        int requestId;
        int returnQuantity;


        try {

            requestId =
                    Integer.parseInt(
                        requestIdText.trim()
                    );


            returnQuantity =
                    Integer.parseInt(
                        quantityText.trim()
                    );

        } catch (NumberFormatException e) {

            redirectError(
                request,
                response,
                "Kuantiti pemulangan tidak sah."
            );

            return;
        }


        if (
            requestId <= 0
            ||
            returnQuantity <= 0
        ) {

            redirectError(
                request,
                response,
                "Kuantiti pemulangan mestilah sekurang-kurangnya 1."
            );

            return;
        }


        // =====================================================
        // CLEAN REMARKS
        // =====================================================

        if (remarks != null) {

            remarks =
                    remarks.trim();


            if (
                remarks.isEmpty()
            ) {

                remarks = null;
            }
        }


        // =====================================================
        // DATABASE CONNECTION
        // =====================================================

        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();


            con.setAutoCommit(false);


            // =================================================
            // STEP 1
            // LOAD ORIGINAL INVENTORY REQUEST
            //
            // FOR UPDATE prevents two simultaneous return
            // submissions from bypassing validation.
            // =================================================

            String requestSql = """

                SELECT

                    r.id,
                    r.user_id,
                    r.item_id,
                    r.quantity,
                    r.returned_quantity,
                    r.status,

                    i.item_name,
                    i.item_code,
                    i.unit

                FROM inventory_requests r

                INNER JOIN inventory_items i
                    ON r.item_id = i.id

                WHERE
                    r.id = ?
                    AND r.user_id = ?

                FOR UPDATE

            """;


            int itemId;
            int approvedQuantity;
            int returnedQuantity;

            String status;
            String itemName;
            String itemCode;
            String unit;


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


                ps.setInt(
                    2,
                    userId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        !rs.next()
                    ) {

                        con.rollback();


                        redirectError(
                            request,
                            response,
                            "Permohonan inventori tidak ditemui."
                        );

                        return;
                    }


                    itemId =
                            rs.getInt(
                                "item_id"
                            );


                    approvedQuantity =
                            rs.getInt(
                                "quantity"
                            );


                    returnedQuantity =
                            rs.getInt(
                                "returned_quantity"
                            );


                    status =
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
            // STEP 2
            // ONLY APPROVED REQUEST CAN BE RETURNED
            // =================================================

            if (
                status == null
                ||
                !"APPROVED".equalsIgnoreCase(
                    status
                )
            ) {

                con.rollback();


                redirectError(
                    request,
                    response,
                    "Hanya permohonan yang telah diluluskan boleh dipulangkan."
                );

                return;
            }


            // =================================================
            // DEFAULT ITEM NAME
            // =================================================

            if (
                itemName == null
                ||
                itemName.isBlank()
            ) {

                itemName =
                        "Inventori";
            }


            // =================================================
            // DEFAULT ITEM CODE
            // =================================================

            if (
                itemCode == null
                ||
                itemCode.isBlank()
            ) {

                itemCode =
                        "-";
            }


            // =================================================
            // DEFAULT UNIT
            // =================================================

            if (
                unit == null
                ||
                unit.isBlank()
            ) {

                unit =
                        "Unit";
            }


            // =================================================
            // STEP 3
            // GET TOTAL PENDING RETURN
            //
            // Pending returns must also be deducted from the
            // quantity staff is allowed to submit again.
            // =================================================

            String pendingSql = """

                SELECT

                    COALESCE(
                        SUM(quantity),
                        0
                    ) AS pending_quantity

                FROM inventory_returns

                WHERE
                    request_id = ?
                    AND user_id = ?
                    AND status = 'PENDING'

            """;


            int pendingQuantity = 0;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            pendingSql
                        )
            ) {

                ps.setInt(
                    1,
                    requestId
                );


                ps.setInt(
                    2,
                    userId
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        rs.next()
                    ) {

                        pendingQuantity =
                                rs.getInt(
                                    "pending_quantity"
                                );
                    }
                }
            }


            // =================================================
            // STEP 4
            // CALCULATE RETURNABLE QUANTITY
            // =================================================

            int remainingQuantity =
                    approvedQuantity
                    -
                    returnedQuantity
                    -
                    pendingQuantity;


            if (
                remainingQuantity <= 0
            ) {

                con.rollback();


                if (
                    pendingQuantity > 0
                ) {

                    redirectError(
                        request,
                        response,
                        "Tiada baki yang boleh dipulangkan buat masa ini kerana pemulangan anda masih menunggu pengesahan HR."
                    );

                } else {

                    redirectError(
                        request,
                        response,
                        "Semua inventori bagi permohonan ini telah dipulangkan."
                    );
                }


                return;
            }


            // =================================================
            // STEP 5
            // VALIDATE RETURN QUANTITY
            // =================================================

            if (
                returnQuantity
                >
                remainingQuantity
            ) {

                con.rollback();


                redirectError(
                    request,
                    response,
                    "Kuantiti pemulangan melebihi baki yang boleh dipulangkan. "
                    +
                    "Baki maksimum ialah "
                    +
                    remainingQuantity
                    +
                    " "
                    +
                    unit
                    +
                    "."
                );


                return;
            }


            // =================================================
            // STEP 6
            // CREATE RETURN REQUEST
            //
            // IMPORTANT:
            // Stock is NOT increased here.
            //
            // HR must approve / confirm the physical return
            // before stock is returned into inventory.
            // =================================================

            String insertSql = """

                INSERT INTO inventory_returns
                (
                    request_id,
                    item_id,
                    user_id,
                    quantity,
                    remarks,
                    status
                )

                VALUES
                (
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    'PENDING'
                )

            """;


            int returnId;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            insertSql,
                            Statement.RETURN_GENERATED_KEYS
                        )
            ) {

                ps.setInt(
                    1,
                    requestId
                );


                ps.setInt(
                    2,
                    itemId
                );


                ps.setInt(
                    3,
                    userId
                );


                ps.setInt(
                    4,
                    returnQuantity
                );


                if (
                    remarks == null
                    ||
                    remarks.isBlank()
                ) {

                    ps.setNull(
                        5,
                        Types.VARCHAR
                    );

                } else {

                    ps.setString(
                        5,
                        remarks
                    );
                }


                int inserted =
                        ps.executeUpdate();


                if (
                    inserted != 1
                ) {

                    throw new SQLException(
                        "Permohonan pemulangan inventori tidak dapat disimpan."
                    );
                }


                try (
                    ResultSet keys =
                            ps.getGeneratedKeys()
                ) {

                    if (
                        !keys.next()
                    ) {

                        throw new SQLException(
                            "ID permohonan pemulangan inventori gagal dijana."
                        );
                    }


                    returnId =
                            keys.getInt(1);
                }
            }


            // =================================================
            // STEP 7
            // ACTIVITY LOG
            //
            // Record when staff submits an inventory return
            // request.
            //
            // Do not record remarks because remarks are
            // free-text information.
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "CREATE_INVENTORY_RETURN",

                "Membuat permohonan pemulangan inventori #"
                    + returnId
                    + " untuk "
                    + itemName
                    + " ("
                    + itemCode
                    + ") sebanyak "
                    + returnQuantity
                    + " "
                    + unit,

                "INVENTORY_RETURN",
                returnId
            );


            // =================================================
            // STEP 8
            // COMMIT
            //
            // Return request + activity log are committed
            // together.
            // =================================================

            con.commit();


            // =================================================
            // SUCCESS MESSAGE
            // =================================================

            String successMessage =
                    "Permohonan pemulangan "
                    +
                    returnQuantity
                    +
                    " "
                    +
                    unit
                    +
                    " "
                    +
                    itemName
                    +
                    " ("
                    +
                    itemCode
                    +
                    ") telah dihantar dan sedang menunggu pengesahan HR.";


            redirectSuccess(
                request,
                response,
                successMessage
            );


        } catch (
            SQLException e
        ) {


            // =================================================
            // ROLLBACK IF ERROR
            // =================================================

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


            throw new ServletException(
                "Tidak dapat menghantar permohonan pemulangan inventori.",
                e
            );


        } finally {


            // =================================================
            // CLOSE CONNECTION
            // =================================================

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
    // REDIRECT SUCCESS
    // =========================================================

    private void redirectSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws IOException {


        response.sendRedirect(

            request.getContextPath()
            +
            "/inventory-requests?success="
            +
            java.net.URLEncoder.encode(
                message,
                java.nio.charset.StandardCharsets.UTF_8
            )
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
            +
            "/inventory-requests?error="
            +
            java.net.URLEncoder.encode(
                message,
                java.nio.charset.StandardCharsets.UTF_8
            )
        );
    }
}