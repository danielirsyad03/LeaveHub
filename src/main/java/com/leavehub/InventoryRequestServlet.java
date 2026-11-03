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

import java.util.HashMap;
import java.util.Map;


@WebServlet("/inventory-request")
public class InventoryRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // PAPARKAN BORANG PERMOHONAN INVENTORI
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================================
        // SEMAK LOGIN
        // =====================================================

        HttpSession session = request.getSession(false);

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
        // DAPATKAN ID INVENTORI
        // =====================================================

        String idParam = request.getParameter("id");

        if (
            idParam == null
            ||
            idParam.trim().isEmpty()
        ) {

            response.sendRedirect(
                request.getContextPath() + "/inventory"
            );

            return;
        }


        int itemId;

        try {

            itemId = Integer.parseInt(
                idParam.trim()
            );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath() + "/inventory"
            );

            return;
        }


        // =====================================================
        // SQL INVENTORY ITEM
        // =====================================================

        String sql = """

            SELECT
                id,
                item_code,
                item_name,
                brand,
                size,
                color,
                category,
                item_type,
                quantity,
                available_quantity,
                unit,
                item_condition,
                location,
                description,
                status

            FROM inventory_items

            WHERE id = ?

        """;


        Map<String, Object> item = null;


        // =====================================================
        // LOAD INVENTORI
        // =====================================================

        try (
            Connection con =
                DBConnection.getConnection();

            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                itemId
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (rs.next()) {

                    item = new HashMap<>();

                    item.put(
                        "id",
                        rs.getInt("id")
                    );

                    item.put(
                        "item_code",
                        safe(rs.getString("item_code"))
                    );

                    item.put(
                        "item_name",
                        safe(rs.getString("item_name"))
                    );

                    item.put(
                        "brand",
                        safe(rs.getString("brand"))
                    );

                    item.put(
                        "size",
                        safe(rs.getString("size"))
                    );

                    item.put(
                        "color",
                        safe(rs.getString("color"))
                    );

                    item.put(
                        "category",
                        safe(rs.getString("category"))
                    );

                    item.put(
                        "item_type",
                        safe(rs.getString("item_type"))
                    );

                    item.put(
                        "quantity",
                        rs.getInt("quantity")
                    );

                    item.put(
                        "available_quantity",
                        rs.getInt("available_quantity")
                    );

                    item.put(
                        "unit",
                        safe(rs.getString("unit"))
                    );

                    item.put(
                        "item_condition",
                        safe(rs.getString("item_condition"))
                    );

                    item.put(
                        "location",
                        safe(rs.getString("location"))
                    );

                    item.put(
                        "description",
                        safe(rs.getString("description"))
                    );

                    item.put(
                        "status",
                        safe(rs.getString("status"))
                    );
                }
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan maklumat inventori.",
                e
            );
        }


        // =====================================================
        // ITEM TIDAK DIJUMPAI
        // =====================================================

        if (item == null) {

            response.sendRedirect(
                request.getContextPath() + "/inventory"
            );

            return;
        }


        // =====================================================
        // SEMAK SAMA ADA ITEM BOLEH DIMOHON
        // =====================================================

        int availableQuantity =
            (Integer) item.get(
                "available_quantity"
            );


        String status =
            String.valueOf(
                item.get("status")
            );


        boolean canRequest =
            availableQuantity > 0
            &&
            !"OUT_OF_STOCK".equalsIgnoreCase(status)
            &&
            !"INACTIVE".equalsIgnoreCase(status);


        item.put(
            "can_request",
            canRequest
        );


        // =====================================================
        // HANTAR DATA KE JSP
        // =====================================================

        request.setAttribute(
            "item",
            item
        );


        request.setAttribute(
            "pageTitle",
            "Permohonan Inventori"
        );


        request
            .getRequestDispatcher(
                "/inventory-request.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // POST
    // HANTAR PERMOHONAN INVENTORI
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");


        // =====================================================
        // SEMAK LOGIN
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
        // DAPATKAN USER ID
        // =====================================================

        int userId;

        Object userIdObject =
            session.getAttribute("userId");


        try {

            if (userIdObject instanceof Integer) {

                userId =
                    (Integer) userIdObject;

            } else {

                userId =
                    Integer.parseInt(
                        String.valueOf(
                            userIdObject
                        )
                    );
            }

        } catch (Exception e) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // PARAMETER ITEM ID
        // SUPPORT itemId DAN item_id
        // =====================================================

        String itemIdParam =
            request.getParameter("itemId");


        if (
            itemIdParam == null
            ||
            itemIdParam.trim().isEmpty()
        ) {

            itemIdParam =
                request.getParameter("item_id");
        }


        // =====================================================
        // PARAMETER LAIN
        // =====================================================

        String quantityParam =
            request.getParameter("quantity");


        String purpose =
            request.getParameter("purpose");


        // =====================================================
        // PURPOSE OPTIONAL
        // =====================================================

        if (purpose == null) {

            purpose = "";

        } else {

            purpose = purpose.trim();
        }


        // =====================================================
        // VALIDATE ITEM ID
        // =====================================================

        if (
            itemIdParam == null
            ||
            itemIdParam.trim().isEmpty()
        ) {

            response.sendRedirect(
                request.getContextPath()
                + "/inventory"
            );

            return;
        }


        // =====================================================
        // VALIDATE QUANTITY
        // =====================================================

        if (
            quantityParam == null
            ||
            quantityParam.trim().isEmpty()
        ) {

            response.sendRedirect(
                request.getContextPath()
                + "/inventory-request?id="
                + itemIdParam
                + "&error=quantity"
            );

            return;
        }


        int itemId;
        int requestedQuantity;


        try {

            itemId =
                Integer.parseInt(
                    itemIdParam.trim()
                );


            requestedQuantity =
                Integer.parseInt(
                    quantityParam.trim()
                );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                request.getContextPath()
                + "/inventory"
            );

            return;
        }


        // =====================================================
        // QUANTITY MESTI > 0
        // =====================================================

        if (requestedQuantity <= 0) {

            response.sendRedirect(
                request.getContextPath()
                + "/inventory-request?id="
                + itemId
                + "&error=quantity"
            );

            return;
        }


        Connection con = null;


        try {

            // =================================================
            // OPEN CONNECTION
            // =================================================

            con =
                DBConnection.getConnection();


            con.setAutoCommit(false);


            // =================================================
            // LOCK DAN DAPATKAN MAKLUMAT INVENTORI
            // =================================================

            String itemSql = """

                SELECT
                    id,
                    item_code,
                    item_name,
                    brand,
                    size,
                    color,
                    category,
                    item_type,
                    quantity,
                    available_quantity,
                    unit,
                    item_condition,
                    location,
                    status

                FROM inventory_items

                WHERE id = ?

                FOR UPDATE

            """;


            int availableQuantity = 0;

            String itemStatus = null;

            String itemName = "";

            String itemCode = "";

            String itemBrand = "";

            String itemSize = "";

            String itemColor = "";

            String itemUnit = "unit";

            boolean itemExists = false;


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

                    if (rs.next()) {

                        itemExists = true;


                        availableQuantity =
                            rs.getInt(
                                "available_quantity"
                            );


                        itemStatus =
                            rs.getString(
                                "status"
                            );


                        itemName =
                            cleanForMessage(
                                rs.getString(
                                    "item_name"
                                )
                            );


                        itemCode =
                            cleanForMessage(
                                rs.getString(
                                    "item_code"
                                )
                            );


                        itemBrand =
                            cleanForMessage(
                                rs.getString(
                                    "brand"
                                )
                            );


                        itemSize =
                            cleanForMessage(
                                rs.getString(
                                    "size"
                                )
                            );


                        itemColor =
                            cleanForMessage(
                                rs.getString(
                                    "color"
                                )
                            );


                        String databaseUnit =
                            cleanForMessage(
                                rs.getString(
                                    "unit"
                                )
                            );


                        if (
                            databaseUnit != null
                            &&
                            !databaseUnit.isBlank()
                        ) {

                            itemUnit =
                                databaseUnit;
                        }
                    }
                }
            }


            // =================================================
            // ITEM TIDAK WUJUD
            // =================================================

            if (!itemExists) {

                con.rollback();


                response.sendRedirect(
                    request.getContextPath()
                    + "/inventory"
                );

                return;
            }


            // =================================================
            // ITEM TIDAK AKTIF / KEHABISAN STOK
            // =================================================

            if (
                "OUT_OF_STOCK".equalsIgnoreCase(
                    itemStatus
                )
                ||
                "INACTIVE".equalsIgnoreCase(
                    itemStatus
                )
            ) {

                con.rollback();


                response.sendRedirect(
                    request.getContextPath()
                    + "/inventory-request?id="
                    + itemId
                    + "&error=unavailable"
                );

                return;
            }


            // =================================================
            // SEMAK STOK
            // =================================================

            if (
                availableQuantity <= 0
                ||
                requestedQuantity
                    > availableQuantity
            ) {

                con.rollback();


                response.sendRedirect(
                    request.getContextPath()
                    + "/inventory-request?id="
                    + itemId
                    + "&error=stock"
                );

                return;
            }


            // =================================================
            // INSERT PERMOHONAN
            // =================================================

            String insertSql = """

                INSERT INTO inventory_requests
                (
                    user_id,
                    item_id,
                    quantity,
                    purpose,
                    status
                )

                VALUES
                (
                    ?,
                    ?,
                    ?,
                    ?,
                    'PENDING'
                )

            """;


            int requestId;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        insertSql,
                        Statement.RETURN_GENERATED_KEYS
                    )
            ) {

                ps.setInt(
                    1,
                    userId
                );


                ps.setInt(
                    2,
                    itemId
                );


                ps.setInt(
                    3,
                    requestedQuantity
                );


                // =============================================
                // PURPOSE OPTIONAL
                // =============================================

                ps.setString(
                    4,
                    purpose
                );


                int affectedRows =
                    ps.executeUpdate();


                if (affectedRows <= 0) {

                    throw new SQLException(
                        "Permohonan inventori tidak berjaya disimpan."
                    );
                }


                // =============================================
                // DAPATKAN REQUEST ID
                // =============================================

                try (
                    ResultSet keys =
                        ps.getGeneratedKeys()
                ) {

                    if (keys.next()) {

                        requestId =
                            keys.getInt(1);

                    } else {

                        throw new SQLException(
                            "ID permohonan inventori tidak dapat diperoleh."
                        );
                    }
                }
            }


            // =================================================
            // DAPATKAN NAMA PEMOHON
            // =================================================

            String userName =
                getUserName(
                    con,
                    userId
                );


            if (
                userName == null
                ||
                userName.isBlank()
            ) {

                userName =
                    "Seorang staf";
            }


            // =================================================
            // BINA NAMA BARANG UNTUK NOTIFIKASI
            //
            // Contoh:
            // Binder Clips 25mm
            // Canon 98 Colour
            // Glue Stick
            // =================================================

            String notificationItemName =
                buildNotificationItemName(
                    itemName,
                    itemBrand,
                    itemSize,
                    itemColor
                );


            // =================================================
            // BINA MESEJ NOTIFIKASI
            // =================================================

            String notificationMessage =
                userName
                + " telah memohon "
                + requestedQuantity
                + " "
                + itemUnit
                + " "
                + notificationItemName
                + ".";


            // =================================================
            // CIPTA NOTIFIKASI KEPADA SEMUA HR
            // =================================================
            //
            // PENTING:
            // Ini ialah bahagian yang sebelum ini tiada.
            //
            // reference_type = INVENTORY_REQUEST
            //
            // Apabila HR tekan "Buka",
            // NotificationReadServlet akan redirect ke:
            //
            // /inventory-request-admin
            //
            // =================================================

            NotificationUtil.createForRole(
            	    con,
            	    "HR",
            	    null,
            	    "INVENTORY_REQUEST",
            	    "Permohonan Inventori Baharu",
            	    notificationMessage,
            	    "INVENTORY_REQUEST",
            	    requestId
            	);

            // =================================================
            // COMMIT
            // =================================================
            //
            // Permohonan + notifikasi disimpan sekali.
            //
            // Jika notification gagal, transaction rollback.
            //
            // Stok BELUM ditolak di sini.
            // Stok hanya ditolak apabila HR meluluskan.
            //
            // =================================================

            con.commit();


            // =================================================
            // SUCCESS
            // =================================================

            response.sendRedirect(
                request.getContextPath()
                + "/inventory-requests?success=requested"
            );


        } catch (SQLException e) {

            // =================================================
            // ROLLBACK
            // =================================================

            if (con != null) {

                try {

                    con.rollback();

                } catch (SQLException ignored) {
                }
            }


            throw new ServletException(
                "Tidak dapat menghantar permohonan inventori.",
                e
            );


        } finally {

            // =================================================
            // CLOSE CONNECTION
            // =================================================

            if (con != null) {

                try {

                    con.setAutoCommit(true);

                } catch (SQLException ignored) {
                }


                try {

                    con.close();

                } catch (SQLException ignored) {
                }
            }
        }
    }


    // =========================================================
    // DAPATKAN NAMA USER
    // =========================================================

    private String getUserName(
            Connection con,
            int userId)
            throws SQLException {


        /*
         * Cuba beberapa column nama yang biasa digunakan.
         *
         * Berdasarkan sistem LeaveHub, kita elakkan
         * bergantung kepada session userName kerana session
         * mungkin menggunakan nama attribute yang berbeza.
         *
         * Kita ambil terus daripada database.
         */


        // =====================================================
        // CUBA COLUMN name
        // =====================================================

        try {

            String sql = """

                SELECT name

                FROM users

                WHERE id = ?

                LIMIT 1

            """;


            try (
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

                    if (rs.next()) {

                        String name =
                            cleanForMessage(
                                rs.getString("name")
                            );


                        if (
                            name != null
                            &&
                            !name.isBlank()
                        ) {

                            return name;
                        }
                    }
                }
            }

        } catch (SQLException ignored) {

            /*
             * Jika users tidak mempunyai column "name",
             * cuba column lain di bawah.
             */
        }


        // =====================================================
        // CUBA COLUMN full_name
        // =====================================================

        try {

            String sql = """

                SELECT full_name

                FROM users

                WHERE id = ?

                LIMIT 1

            """;


            try (
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

                    if (rs.next()) {

                        String name =
                            cleanForMessage(
                                rs.getString(
                                    "full_name"
                                )
                            );


                        if (
                            name != null
                            &&
                            !name.isBlank()
                        ) {

                            return name;
                        }
                    }
                }
            }

        } catch (SQLException ignored) {
        }


        // =====================================================
        // CUBA COLUMN username
        // =====================================================

        try {

            String sql = """

                SELECT username

                FROM users

                WHERE id = ?

                LIMIT 1

            """;


            try (
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

                    if (rs.next()) {

                        String name =
                            cleanForMessage(
                                rs.getString(
                                    "username"
                                )
                            );


                        if (
                            name != null
                            &&
                            !name.isBlank()
                        ) {

                            return name;
                        }
                    }
                }
            }

        } catch (SQLException ignored) {
        }


        return "Staf";
    }


    // =========================================================
    // BINA NAMA ITEM UNTUK NOTIFIKASI
    // =========================================================

    private String buildNotificationItemName(
            String itemName,
            String brand,
            String size,
            String color) {


        StringBuilder result =
            new StringBuilder();


        // =====================================================
        // ITEM NAME
        // =====================================================

        appendPart(
            result,
            itemName
        );


        // =====================================================
        // BRAND
        //
        // Tidak masukkan brand jika sudah terdapat
        // dalam item name.
        // =====================================================

        if (
            !containsIgnoreCase(
                result.toString(),
                brand
            )
        ) {

            appendPart(
                result,
                brand
            );
        }


        // =====================================================
        // SIZE
        // =====================================================

        if (
            !containsIgnoreCase(
                result.toString(),
                size
            )
        ) {

            appendPart(
                result,
                size
            );
        }


        // =====================================================
        // COLOR
        // =====================================================

        if (
            !containsIgnoreCase(
                result.toString(),
                color
            )
        ) {

            appendPart(
                result,
                color
            );
        }


        String value =
            result.toString().trim();


        if (value.isBlank()) {

            return "inventori";
        }


        return value;
    }


    // =========================================================
    // APPEND PART
    // =========================================================

    private void appendPart(
            StringBuilder builder,
            String value) {


        String cleanValue =
            cleanForMessage(value);


        if (
            cleanValue == null
            ||
            cleanValue.isBlank()
            ||
            "-".equals(cleanValue)
        ) {

            return;
        }


        if (builder.length() > 0) {

            builder.append(" ");
        }


        builder.append(
            cleanValue
        );
    }


    // =========================================================
    // CONTAINS IGNORE CASE
    // =========================================================

    private boolean containsIgnoreCase(
            String source,
            String value) {


        if (
            source == null
            ||
            value == null
            ||
            value.isBlank()
            ||
            "-".equals(value.trim())
        ) {

            return false;
        }


        return source
            .toLowerCase()
            .contains(
                value
                    .trim()
                    .toLowerCase()
            );
    }


    // =========================================================
    // CLEAN STRING UNTUK MESEJ
    // =========================================================

    private String cleanForMessage(
            String value) {


        if (value == null) {

            return "";
        }


        String clean =
            value.trim();


        if ("-".equals(clean)) {

            return "";
        }


        return clean;
    }


    // =========================================================
    // SAFE STRING UNTUK PAPARAN JSP
    // =========================================================

    private String safe(
            String value) {


        if (
            value == null
            ||
            value.trim().isEmpty()
        ) {

            return "-";
        }


        return value.trim();
    }
}