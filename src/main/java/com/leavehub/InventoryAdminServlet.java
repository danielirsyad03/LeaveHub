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
import java.sql.Statement;
import java.sql.Types;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


@WebServlet("/inventory-admin")
public class InventoryAdminServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

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


        String userRole =
                (String) session.getAttribute(
                    "userRole"
                );


        if (
            userRole == null
            ||
            !"HR".equalsIgnoreCase(
                userRole.trim()
            )
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        List<Map<String, Object>> items =
                new ArrayList<>();
        Set<String> inventoryTypes = new LinkedHashSet<>();
        Set<String> inventoryUnits = new LinkedHashSet<>();

        List<Map<String, Object>> requests =
                new ArrayList<>();

        List<Map<String, Object>> categories =
                new ArrayList<>();


        // =====================================================
        // LOAD CATEGORIES
        // =====================================================

        String categorySql = """

            SELECT
                id,
                category_name,
                code_prefix,
                is_active,
                created_at

            FROM inventory_categories

            WHERE is_active = 1

            ORDER BY
                category_name ASC

        """;


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(categorySql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> category =
                        new HashMap<>();

                category.put(
                    "id",
                    rs.getInt("id")
                );

                category.put(
                    "category_name",
                    rs.getString("category_name")
                );

                category.put(
                    "code_prefix",
                    rs.getString("code_prefix")
                );

                category.put(
                    "is_active",
                    rs.getInt("is_active")
                );

                category.put(
                    "created_at",
                    rs.getTimestamp("created_at")
                );

                categories.add(category);
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan kategori inventori.",
                e
            );
        }


        // =====================================================
        // LOAD INVENTORY ITEMS
        // =====================================================

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


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(itemSql);

            ResultSet rs =
                    ps.executeQuery()
        ) {

            while (rs.next()) {

                Map<String, Object> item =
                        new HashMap<>();

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

                item.put(
                    "category",
                    rs.getString("category")
                );

                item.put(
                    "item_type",
                    rs.getString("item_type")
                );

                item.put(
                    "quantity",
                    rs.getInt("quantity")
                );

                item.put(
                    "available_quantity",
                    rs.getInt(
                        "available_quantity"
                    )
                );

                item.put(
                    "unit",
                    rs.getString("unit")
                );
                String savedType = rs.getString("item_type");
                String savedUnit = rs.getString("unit");
                if (savedType != null && !savedType.isBlank()) inventoryTypes.add(savedType.trim());
                if (savedUnit != null && !savedUnit.isBlank()) inventoryUnits.add(savedUnit.trim());

                item.put(
                    "item_condition",
                    rs.getString(
                        "item_condition"
                    )
                );

                item.put(
                    "location",
                    rs.getString("location")
                );

                item.put(
                    "description",
                    rs.getString("description")
                );

                // Status dikira berdasarkan baki berbanding jumlah asal,
                // bukan nombor baki sahaja (contoh 2/2 kekal Tersedia).
                item.put(
                    "status",
                    calculateStockStatus(
                        rs.getInt("available_quantity"),
                        rs.getInt("quantity")
                    )
                );

                items.add(item);
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat memuatkan senarai inventori.",
                e
            );
        }


        // =====================================================
        // LOAD INVENTORY REQUESTS
        // =====================================================

        String requestSql = """

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

                u.name AS staff_name,
                u.email AS staff_email,

                i.item_code,
                i.item_name,
                i.brand,
                i.size,
                i.color,
                i.category,
                i.item_type,
                i.available_quantity,
                i.unit

            FROM inventory_requests r

            JOIN users u
                ON r.user_id = u.id

            JOIN inventory_items i
                ON r.item_id = i.id

            ORDER BY

                CASE

                    WHEN r.status = 'PENDING'
                    THEN 0

                    ELSE 1

                END,

                r.requested_at DESC

        """;


        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(requestSql);

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

                row.put(
                    "category",
                    rs.getString("category")
                );

                row.put(
                    "item_type",
                    rs.getString("item_type")
                );

                row.put(
                    "available_quantity",
                    rs.getInt(
                        "available_quantity"
                    )
                );

                row.put(
                    "unit",
                    rs.getString("unit")
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
        // REQUEST COUNTERS
        // =====================================================

        int totalRequests =
                requests.size();

        int pendingRequests = 0;
        int approvedRequests = 0;
        int rejectedRequests = 0;


        for (
            Map<String, Object> row :
            requests
        ) {

            String status =
                    String.valueOf(
                        row.get("status")
                    );


            if (
                "PENDING".equalsIgnoreCase(status)
            ) {

                pendingRequests++;

            } else if (
                "APPROVED".equalsIgnoreCase(status)
            ) {

                approvedRequests++;

            } else if (
                "REJECTED".equalsIgnoreCase(status)
            ) {

                rejectedRequests++;
            }
        }


        // =====================================================
        // INVENTORY COUNTERS
        // =====================================================

        int totalItems =
                items.size();

        int availableItems = 0;
        int lowStockItems = 0;
        int outOfStockItems = 0;


        for (
            Map<String, Object> item :
            items
        ) {

            String status =
                    String.valueOf(
                        item.get("status")
                    );


            if (
                "AVAILABLE".equalsIgnoreCase(status)
            ) {

                availableItems++;

            } else if (
                "LOW_STOCK".equalsIgnoreCase(status)
            ) {

                lowStockItems++;

            } else if (
                "OUT_OF_STOCK".equalsIgnoreCase(status)
            ) {

                outOfStockItems++;
            }
        }


        // =====================================================
        // SEND TO JSP
        // =====================================================

        request.setAttribute(
            "items",
            items
        );

        request.setAttribute(
            "requests",
            requests
        );

        request.setAttribute(
            "categories",
            categories
        );
        request.setAttribute("inventoryTypes", inventoryTypes);
        request.setAttribute("inventoryUnits", inventoryUnits);


        request.setAttribute(
            "totalRequests",
            totalRequests
        );

        request.setAttribute(
            "pendingRequests",
            pendingRequests
        );

        request.setAttribute(
            "approvedRequests",
            approvedRequests
        );

        request.setAttribute(
            "rejectedRequests",
            rejectedRequests
        );


        request.setAttribute(
            "totalItems",
            totalItems
        );

        request.setAttribute(
            "availableItems",
            availableItems
        );

        request.setAttribute(
            "lowStockItems",
            lowStockItems
        );

        request.setAttribute(
            "outOfStockItems",
            outOfStockItems
        );


        request.setAttribute(
            "pageTitle",
            "Pengurusan Inventori"
        );


        request.getRequestDispatcher(
            "/inventory-admin.jsp"
        ).forward(
            request,
            response
        );
    }


    // =========================================================
    // POST
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


        String userRole =
                (String) session.getAttribute(
                    "userRole"
                );


        if (
            userRole == null
            ||
            !"HR".equalsIgnoreCase(
                userRole.trim()
            )
        ) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        int reviewerId;


        try {

            reviewerId =
                    Integer.parseInt(
                        session
                            .getAttribute("userId")
                            .toString()
                    );

        } catch (
            NumberFormatException e
        ) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        String action =
                clean(
                    request.getParameter(
                        "action"
                    )
                );


        try {

            switch (action) {

                case "add":

                    addItem(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Inventori berjaya ditambah.",
                        false
                    );

                    break;


                case "edit":

                    editItem(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Maklumat inventori berjaya dikemas kini.",
                        false
                    );

                    break;


                case "delete":

                    deleteItem(request, reviewerId);

                    redirectWithMessage(
                        request,
                        response,
                        "Inventori berjaya dipadam.",
                        false
                    );

                    break;


                case "stock-in":

                    addStock(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Stok inventori berjaya ditambah.",
                        false
                    );

                    break;


                case "add-category":

                    addCategory(request);

                    redirectWithMessage(
                        request,
                        response,
                        "Kategori inventori berjaya ditambah.",
                        false
                    );

                    break;


                case "approve-request":

                    approveRequest(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Permohonan inventori berjaya diluluskan.",
                        false
                    );

                    break;


                case "reject-request":

                    rejectRequest(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Permohonan inventori telah ditolak.",
                        false
                    );

                    break;


                case "return-request":

                    returnRequest(
                        request,
                        reviewerId
                    );

                    redirectWithMessage(
                        request,
                        response,
                        "Pemulangan inventori berjaya direkodkan.",
                        false
                    );

                    break;


                default:

                    redirectWithMessage(
                        request,
                        response,
                        "Tindakan inventori tidak sah.",
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
                        "Tidak dapat melaksanakan tindakan inventori.";
            }


            redirectWithMessage(
                request,
                response,
                message,
                true
            );
        }
    }


    // =========================================================
    // ADD ITEM
    // =========================================================

    private void addItem(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        String itemName =
                clean(
                    request.getParameter(
                        "item_name"
                    )
                );

        String category =
                clean(
                    request.getParameter(
                        "category"
                    )
                );

        String newCategoryName =
                clean(
                    request.getParameter(
                        "new_category_name"
                    )
                );

        boolean createNewCategory =
                "__NEW__".equals(category);

        if (createNewCategory) {

            if (newCategoryName.isBlank()) {
                throw new Exception(
                    "Nama kategori baharu diperlukan."
                );
            }

            category = newCategoryName;
        }

        String brand =
                clean(
                    request.getParameter(
                        "brand"
                    )
                );

        String size =
                clean(
                    request.getParameter(
                        "size"
                    )
                );

        String color =
                clean(
                    request.getParameter(
                        "color"
                    )
                );

        String itemType = clean(request.getParameter("item_type"));
        if ("__NEW__".equals(itemType)) {
            itemType = clean(request.getParameter("new_item_type"));
        }
        if ("CONSUMABLE".equalsIgnoreCase(itemType) || "ASSET".equalsIgnoreCase(itemType)) {
            itemType = itemType.toUpperCase(java.util.Locale.ROOT);
        }

        String unit = clean(request.getParameter("unit"));
        if ("__NEW__".equals(unit)) {
            unit = clean(request.getParameter("new_unit"));
        }

        String condition =
                clean(
                    request.getParameter(
                        "item_condition"
                    )
                );

        String location =
                clean(
                    request.getParameter(
                        "location"
                    )
                );

        String description =
                clean(
                    request.getParameter(
                        "description"
                    )
                );


        int quantity =
                parsePositiveOrZero(
                    request.getParameter(
                        "quantity"
                    ),
                    "Jumlah kuantiti"
                );

        int availableQuantity =
                parsePositiveOrZero(
                    request.getParameter(
                        "available_quantity"
                    ),
                    "Kuantiti tersedia"
                );


        if (unit.isBlank()) {

            unit = "Unit";
        }


        if (condition.isBlank()) {
            condition = "Baik";
        }


        /*
         * Untuk sistem PKB sekarang lokasi inventori
         * ditetapkan kepada Stor.
         *
         * Walaupun JSP menghantar location, backend
         * masih memastikan nilai yang digunakan
         * adalah "Stor".
         */
        location = "Stor";


        validateItem(
            itemName,
            category,
            itemType,
            unit,
            quantity,
            availableQuantity
        );


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            // =================================================
            // CREATE NEW CATEGORY WHEN REQUESTED
            // =================================================

            if (createNewCategory) {
                ensureNewCategoryExists(
                    con,
                    category
                );
            }


            // =================================================
            // GET + LOCK CATEGORY
            // =================================================

            String prefix =
                    getCategoryPrefixForUpdate(
                        con,
                        category
                    );


            // =================================================
            // GENERATE AUTOMATIC ITEM CODE
            // =================================================

            String itemCode =
                    generateNextItemCode(
                        con,
                        prefix
                    );


            String status =
                    calculateStockStatus(
                        availableQuantity,
                        quantity
                    );


            // =================================================
            // INSERT ITEM
            // =================================================

            String sql = """

                INSERT INTO inventory_items
                (
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
                )

                VALUES
                (
                    ?, ?, ?, ?, ?, ?, ?,
                    ?, ?, ?, ?, ?, ?, ?
                )

            """;


            int newItemId;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            sql,
                            Statement.RETURN_GENERATED_KEYS
                        )
            ) {

                ps.setString(
                    1,
                    itemCode
                );

                ps.setString(
                    2,
                    itemName
                );

                setNullableString(
                    ps,
                    3,
                    brand
                );

                setNullableString(
                    ps,
                    4,
                    size
                );

                setNullableString(
                    ps,
                    5,
                    color
                );

                ps.setString(
                    6,
                    category
                );

                ps.setString(
                    7,
                    itemType
                );

                ps.setInt(
                    8,
                    quantity
                );

                ps.setInt(
                    9,
                    availableQuantity
                );

                ps.setString(
                    10,
                    unit
                );

                ps.setString(
                    11,
                    condition
                );

                ps.setString(
                    12,
                    location
                );

                setNullableString(
                    ps,
                    13,
                    description
                );

                ps.setString(
                    14,
                    status
                );


                int inserted =
                        ps.executeUpdate();


                if (inserted != 1) {

                    throw new Exception(
                        "Inventori tidak dapat ditambah."
                    );
                }


                try (
                    ResultSet keys =
                            ps.getGeneratedKeys()
                ) {

                    if (!keys.next()) {

                        throw new Exception(
                            "ID inventori tidak dapat dijana."
                        );
                    }


                    newItemId =
                            keys.getInt(1);
                }
            }


            // =================================================
            // INITIAL STOCK TRANSACTION
            // =================================================

            if (availableQuantity > 0) {

                insertInventoryTransaction(
                    con,
                    newItemId,
                    null,
                    null,
                    "STOCK_IN",
                    availableQuantity,
                    0,
                    availableQuantity,
                    "Stok awal semasa inventori ditambah.",
                    reviewerId
                );
            }


            // =================================================
            // AUDIT TRAIL
            // =================================================

            StringBuilder audit =
                    new StringBuilder();

            audit.append(
                "Menambah inventori: "
            );

            audit.append(
                itemName
            );

            if (!brand.isBlank()) {

                audit.append(
                    " - "
                );

                audit.append(
                    brand
                );
            }


            audit.append(
                " ("
            );

            audit.append(
                itemCode
            );

            audit.append(
                ") — "
            );

            audit.append(
                availableQuantity
            );

            audit.append(
                " "
            );

            audit.append(
                unit
            );

            audit.append(
                " tersedia"
            );


            ActivityLogUtil.log(
                con,
                request,
                "ADD_INVENTORY",
                audit.toString(),
                "INVENTORY_ITEM",
                newItemId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // EDIT ITEM
    // =========================================================

    private void editItem(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int id =
                parsePositiveId(
                    request.getParameter(
                        "id"
                    ),
                    "ID inventori"
                );


        String itemName =
                clean(
                    request.getParameter(
                        "item_name"
                    )
                );

        String category = clean(request.getParameter("category"));
        String newCategoryName = clean(request.getParameter("new_category_name"));
        boolean createNewCategory = "__NEW__".equals(category);
        if (createNewCategory) {
            if (newCategoryName.isBlank()) {
                throw new Exception("Nama kategori baharu diperlukan.");
            }
            category = newCategoryName;
        }

        String brand =
                clean(
                    request.getParameter(
                        "brand"
                    )
                );

        String size =
                clean(
                    request.getParameter(
                        "size"
                    )
                );

        String color =
                clean(
                    request.getParameter(
                        "color"
                    )
                );

        String itemType = clean(request.getParameter("item_type"));
        if ("__NEW__".equals(itemType)) {
            itemType = clean(request.getParameter("new_item_type"));
        }
        if ("CONSUMABLE".equalsIgnoreCase(itemType) || "ASSET".equalsIgnoreCase(itemType)) {
            itemType = itemType.toUpperCase(java.util.Locale.ROOT);
        }

        String unit = clean(request.getParameter("unit"));
        if ("__NEW__".equals(unit)) {
            unit = clean(request.getParameter("new_unit"));
        }

        String condition =
                clean(
                    request.getParameter(
                        "item_condition"
                    )
                );

        String description =
                clean(
                    request.getParameter(
                        "description"
                    )
                );


        int quantity =
                parsePositiveOrZero(
                    request.getParameter(
                        "quantity"
                    ),
                    "Jumlah kuantiti"
                );

        int availableQuantity =
                parsePositiveOrZero(
                    request.getParameter(
                        "available_quantity"
                    ),
                    "Kuantiti tersedia"
                );


        if (unit.isBlank()) {

            unit = "Unit";
        }


        if (condition.isBlank()) {

            condition = "Good";
        }


        String location =
                "Stor";


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);

            if (createNewCategory) {
                ensureNewCategoryExists(con, category);
            }

            // =================================================
            // LOCK CURRENT ITEM
            // =================================================

            String oldSql = """

                SELECT
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

                FOR UPDATE

            """;


            String itemCode;
            String oldCategory;

            String oldItemName;
            String oldBrand;
            String oldSize;
            String oldColor;
            String oldItemType;

            int oldQuantity;
            int oldAvailableQuantity;

            String oldUnit;
            String oldCondition;
            String oldLocation;
            String oldDescription;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            oldSql
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

                    if (!rs.next()) {

                        throw new Exception(
                            "Inventori tidak dijumpai."
                        );
                    }


                    /*
                     * Kod dan kategori dibaca daripada
                     * database dan BUKAN daripada form.
                     *
                     * Jadi admin tidak boleh menyebabkan
                     * kod seperti INK-001 berubah menjadi
                     * kategori Pen.
                     */
                    itemCode =
                            rs.getString(
                                "item_code"
                            );

                    oldCategory =
                            rs.getString(
                                "category"
                            );


                    oldItemName =
                            rs.getString(
                                "item_name"
                            );

                    oldBrand =
                            rs.getString(
                                "brand"
                            );

                    oldSize =
                            rs.getString(
                                "size"
                            );

                    oldColor =
                            rs.getString(
                                "color"
                            );

                    oldItemType =
                            rs.getString(
                                "item_type"
                            );

                    oldQuantity =
                            rs.getInt(
                                "quantity"
                            );

                    oldAvailableQuantity =
                            rs.getInt(
                                "available_quantity"
                            );

                    oldUnit =
                            rs.getString(
                                "unit"
                            );

                    oldCondition =
                            rs.getString(
                                "item_condition"
                            );

                    oldLocation =
                            rs.getString(
                                "location"
                            );

                    oldDescription =
                            rs.getString(
                                "description"
                            );
                }
            }


            validateItem(
                itemName,
                category,
                itemType,
                unit,
                quantity,
                availableQuantity
            );


            String status =
                    calculateStockStatus(
                        availableQuantity,
                        quantity
                    );


            // =================================================
            // UPDATE
            // =================================================

            String sql = """

                UPDATE inventory_items

                SET
                    item_name = ?,
                    brand = ?,
                    size = ?,
                    color = ?,
                    category = ?,
                    item_type = ?,
                    quantity = ?,
                    available_quantity = ?,
                    unit = ?,
                    item_condition = ?,
                    location = ?,
                    description = ?,
                    status = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(sql)
            ) {

                ps.setString(
                    1,
                    itemName
                );

                setNullableString(
                    ps,
                    2,
                    brand
                );

                setNullableString(
                    ps,
                    3,
                    size
                );

                setNullableString(
                    ps,
                    4,
                    color
                );

                ps.setString(
                    5,
                    category
                );

                ps.setString(
                    6,
                    itemType
                );

                ps.setInt(
                    7,
                    quantity
                );

                ps.setInt(
                    8,
                    availableQuantity
                );

                ps.setString(
                    9,
                    unit
                );

                ps.setString(
                    10,
                    condition
                );

                ps.setString(
                    11,
                    location
                );

                setNullableString(
                    ps,
                    12,
                    description
                );

                ps.setString(
                    13,
                    status
                );

                ps.setInt(
                    14,
                    id
                );


                int updated =
                        ps.executeUpdate();


                if (updated == 0) {

                    throw new Exception(
                        "Inventori tidak dijumpai."
                    );
                }
            }


            // =================================================
            // STOCK ADJUSTMENT TRANSACTION
            // =================================================

            if (availableQuantity != oldAvailableQuantity) {

                int difference =
                        availableQuantity
                        - oldAvailableQuantity;

                insertInventoryTransaction(
                    con,
                    id,
                    null,
                    null,
                    "ADJUSTMENT",
                    Math.abs(difference),
                    oldAvailableQuantity,
                    availableQuantity,
                    difference > 0
                        ? "Pelarasan stok melalui kemas kini inventori (stok bertambah)."
                        : "Pelarasan stok melalui kemas kini inventori (stok berkurang).",
                    reviewerId
                );
            }


            // =================================================
            // AUDIT CHANGES
            // =================================================

            StringBuilder changes =
                    new StringBuilder();


            appendChange(
                changes,
                "nama",
                oldItemName,
                itemName
            );

            appendChange(
                changes,
                "jenama",
                oldBrand,
                brand
            );

            appendChange(
                changes,
                "saiz / variasi",
                oldSize,
                size
            );

            appendChange(
                changes,
                "warna",
                oldColor,
                color
            );

            appendChange(
                changes,
                "kategori",
                oldCategory,
                category
            );

            appendChange(
                changes,
                "jenis",
                oldItemType,
                itemType
            );

            appendChange(
                changes,
                "jumlah kuantiti",
                String.valueOf(
                    oldQuantity
                ),
                String.valueOf(
                    quantity
                )
            );

            appendChange(
                changes,
                "stok tersedia",
                String.valueOf(
                    oldAvailableQuantity
                ),
                String.valueOf(
                    availableQuantity
                )
            );

            appendChange(
                changes,
                "unit",
                oldUnit,
                unit
            );

            appendChange(
                changes,
                "keadaan",
                oldCondition,
                condition
            );

            appendChange(
                changes,
                "lokasi",
                oldLocation,
                location
            );

            appendChange(
                changes,
                "keterangan",
                oldDescription,
                description
            );


            if (
                changes.length() > 0
            ) {

                ActivityLogUtil.log(
                    con,
                    request,
                    "EDIT_INVENTORY",
                    "Mengemaskini inventori: "
                        + itemName
                        + " ("
                        + itemCode
                        + ") — "
                        + changes,
                    "INVENTORY_ITEM",
                    id
                );
            }


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // ADD STOCK
    // =========================================================

    private void addStock(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int itemId =
                parsePositiveId(
                    request.getParameter(
                        "item_id"
                    ),
                    "ID inventori"
                );

        int addedQuantity =
                parsePositiveId(
                    request.getParameter(
                        "quantity"
                    ),
                    "Kuantiti stok masuk"
                );

        String remarks =
                clean(
                    request.getParameter(
                        "remarks"
                    )
                );


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            // =================================================
            // LOCK CURRENT INVENTORY
            // =================================================

            String selectSql = """

                SELECT
                    item_code,
                    item_name,
                    quantity,
                    available_quantity,
                    unit

                FROM inventory_items

                WHERE id = ?

                FOR UPDATE

            """;


            String itemCode;
            String itemName;
            String unit;

            int currentQuantity;
            int currentAvailable;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            selectSql
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


                    itemCode =
                            rs.getString(
                                "item_code"
                            );

                    itemName =
                            rs.getString(
                                "item_name"
                            );

                    currentQuantity =
                            rs.getInt(
                                "quantity"
                            );

                    currentAvailable =
                            rs.getInt(
                                "available_quantity"
                            );

                    unit =
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
                }
            }


            // =================================================
            // CALCULATE NEW STOCK
            // =================================================

            int newQuantity;

            int newAvailable;


            try {

                newQuantity =
                        Math.addExact(
                            currentQuantity,
                            addedQuantity
                        );

                newAvailable =
                        Math.addExact(
                            currentAvailable,
                            addedQuantity
                        );

            } catch (
                ArithmeticException e
            ) {

                throw new Exception(
                    "Kuantiti stok terlalu besar."
                );
            }


            String newStatus =
                    calculateStockStatus(
                        newAvailable
                    );


            // =================================================
            // UPDATE INVENTORY
            // =================================================

            String updateSql = """

                UPDATE inventory_items

                SET
                    quantity = ?,
                    available_quantity = ?,
                    status = ?

                WHERE id = ?

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            updateSql
                        )
            ) {

                ps.setInt(
                    1,
                    newQuantity
                );

                ps.setInt(
                    2,
                    newAvailable
                );

                ps.setString(
                    3,
                    newStatus
                );

                ps.setInt(
                    4,
                    itemId
                );


                int updated =
                        ps.executeUpdate();


                if (updated != 1) {

                    throw new Exception(
                        "Stok inventori tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // INVENTORY TRANSACTION
            // =================================================

            insertInventoryTransaction(
                con,
                itemId,
                null,
                null,
                "STOCK_IN",
                addedQuantity,
                currentAvailable,
                newAvailable,
                remarks.isBlank()
                    ? "Penambahan stok oleh HR."
                    : remarks,
                reviewerId
            );


            // =================================================
            // AUDIT TRAIL
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "INVENTORY_STOCK_IN",
                "Menambah stok inventori: "
                    + itemName
                    + " ("
                    + itemCode
                    + ") — +"
                    + addedQuantity
                    + " "
                    + unit
                    + " (Stok: "
                    + currentAvailable
                    + " → "
                    + newAvailable
                    + ")",
                "INVENTORY_ITEM",
                itemId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // INSERT INVENTORY TRANSACTION
    // =========================================================

    private void insertInventoryTransaction(
            Connection con,
            int itemId,
            Integer requestId,
            Integer userId,
            String transactionType,
            int quantity,
            int stockBefore,
            int stockAfter,
            String remarks,
            int performedBy)
            throws SQLException {

        String sql = """

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
                ?, ?, ?, ?, ?, ?, ?, ?, ?
            )

        """;


        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                itemId
            );


            if (requestId == null) {

                ps.setNull(
                    2,
                    Types.INTEGER
                );

            } else {

                ps.setInt(
                    2,
                    requestId
                );
            }


            if (userId == null) {

                ps.setNull(
                    3,
                    Types.INTEGER
                );

            } else {

                ps.setInt(
                    3,
                    userId
                );
            }


            ps.setString(
                4,
                transactionType
            );

            ps.setInt(
                5,
                quantity
            );

            ps.setInt(
                6,
                stockBefore
            );

            ps.setInt(
                7,
                stockAfter
            );

            setNullableString(
                ps,
                8,
                remarks
            );

            ps.setInt(
                9,
                performedBy
            );


            int inserted =
                    ps.executeUpdate();


            if (inserted != 1) {

                throw new SQLException(
                    "Rekod transaksi inventori tidak dapat disimpan."
                );
            }
        }
    }


    // =========================================================
    // CREATE CATEGORY AUTOMATICALLY FROM ADD ITEM MODAL
    // =========================================================

    private void ensureNewCategoryExists(
            Connection con,
            String categoryName)
            throws Exception {

        String checkSql = """
            SELECT category_id
            FROM inventory_categories
            WHERE LOWER(category_name) = LOWER(?)
            LIMIT 1
        """;

        try (PreparedStatement ps = con.prepareStatement(checkSql)) {
            ps.setString(1, categoryName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new Exception(
                        "Kategori tersebut telah wujud. Sila pilih kategori sedia ada."
                    );
                }
            }
        }

        String normalized =
                categoryName
                    .toUpperCase()
                    .replaceAll("[^A-Z0-9 ]", " ")
                    .trim();

        StringBuilder base = new StringBuilder();

        if (!normalized.isBlank()) {
            String[] words = normalized.split("\\s+");

            if (words.length > 1) {
                for (String word : words) {
                    if (!word.isBlank()) {
                        base.append(word.charAt(0));
                    }
                }
            } else {
                base.append(normalized);
            }
        }

        String prefix = base.toString().replaceAll("[^A-Z0-9]", "");

        if (prefix.isBlank()) {
            prefix = "INV";
        }

        if (prefix.length() < 3 && normalized.length() >= 3) {
            prefix = normalized.replaceAll("[^A-Z0-9]", "");
        }

        if (prefix.length() > 8) {
            prefix = prefix.substring(0, 8);
        }

        String basePrefix = prefix;
        int suffix = 2;

        while (categoryPrefixExists(con, prefix)) {
            String suffixText = String.valueOf(suffix++);
            int maxBaseLength = Math.max(1, 8 - suffixText.length());
            String shortened = basePrefix.length() > maxBaseLength
                    ? basePrefix.substring(0, maxBaseLength)
                    : basePrefix;
            prefix = shortened + suffixText;
        }

        String insertSql = """
            INSERT INTO inventory_categories
                (category_name, code_prefix, is_active)
            VALUES (?, ?, 1)
        """;

        try (PreparedStatement ps = con.prepareStatement(insertSql)) {
            ps.setString(1, categoryName);
            ps.setString(2, prefix);

            if (ps.executeUpdate() != 1) {
                throw new Exception(
                    "Kategori baharu tidak dapat disimpan."
                );
            }
        }
    }


    private boolean categoryPrefixExists(
            Connection con,
            String prefix)
            throws SQLException {

        String sql = """
            SELECT COUNT(*)
            FROM inventory_categories
            WHERE UPPER(code_prefix) = UPPER(?)
        """;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, prefix);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }


    // =========================================================
    // ADD CATEGORY
    // =========================================================

    private void addCategory(
            HttpServletRequest request)
            throws Exception {

        String categoryName =
                clean(
                    request.getParameter(
                        "category_name"
                    )
                );

        String codePrefix =
                clean(
                    request.getParameter(
                        "code_prefix"
                    )
                ).toUpperCase();


        if (
            categoryName.isBlank()
        ) {

            throw new Exception(
                "Nama kategori diperlukan."
            );
        }


        if (
            codePrefix.isBlank()
        ) {

            throw new Exception(
                "Prefix kod diperlukan."
            );
        }


        /*
         * Hanya huruf dan nombor.
         * Contoh:
         * INK
         * BCLIP
         * A4
         */
        if (
            !codePrefix.matches(
                "[A-Z0-9]+"
            )
        ) {

            throw new Exception(
                "Prefix kod hanya boleh mengandungi huruf dan nombor tanpa ruang."
            );
        }


        if (
            codePrefix.length() > 20
        ) {

            throw new Exception(
                "Prefix kod terlalu panjang."
            );
        }


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            // =================================================
            // CHECK DUPLICATE CATEGORY NAME
            // =================================================

            String checkNameSql = """

                SELECT COUNT(*)

                FROM inventory_categories

                WHERE LOWER(category_name)
                      = LOWER(?)

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            checkNameSql
                        )
            ) {

                ps.setString(
                    1,
                    categoryName
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        rs.next()
                        &&
                        rs.getInt(1) > 0
                    ) {

                        throw new Exception(
                            "Kategori tersebut telah wujud."
                        );
                    }
                }
            }


            // =================================================
            // CHECK DUPLICATE PREFIX
            // =================================================

            String checkPrefixSql = """

                SELECT COUNT(*)

                FROM inventory_categories

                WHERE UPPER(code_prefix)
                      = UPPER(?)

            """;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            checkPrefixSql
                        )
            ) {

                ps.setString(
                    1,
                    codePrefix
                );


                try (
                    ResultSet rs =
                            ps.executeQuery()
                ) {

                    if (
                        rs.next()
                        &&
                        rs.getInt(1) > 0
                    ) {

                        throw new Exception(
                            "Prefix kod tersebut telah digunakan."
                        );
                    }
                }
            }


            // =================================================
            // INSERT CATEGORY
            // =================================================

            String insertSql = """

                INSERT INTO inventory_categories
                (
                    category_name,
                    code_prefix,
                    is_active
                )

                VALUES
                (
                    ?, ?, 1
                )

            """;


            int categoryId;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            insertSql,
                            Statement.RETURN_GENERATED_KEYS
                        )
            ) {

                ps.setString(
                    1,
                    categoryName
                );

                ps.setString(
                    2,
                    codePrefix
                );


                int inserted =
                        ps.executeUpdate();


                if (
                    inserted != 1
                ) {

                    throw new Exception(
                        "Kategori tidak dapat ditambah."
                    );
                }


                try (
                    ResultSet keys =
                            ps.getGeneratedKeys()
                ) {

                    if (!keys.next()) {

                        throw new Exception(
                            "ID kategori tidak dapat dijana."
                        );
                    }


                    categoryId =
                            keys.getInt(1);
                }
            }


            // =================================================
            // AUDIT CATEGORY
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "ADD_INVENTORY_CATEGORY",
                "Menambah kategori inventori: "
                    + categoryName
                    + " (Prefix: "
                    + codePrefix
                    + ")",
                "INVENTORY_CATEGORY",
                categoryId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // GET CATEGORY PREFIX + LOCK CATEGORY
    // =========================================================

    private String getCategoryPrefixForUpdate(
            Connection con,
            String category)
            throws Exception {

        String sql = """

            SELECT
                code_prefix

            FROM inventory_categories

            WHERE category_name = ?
              AND is_active = 1

            FOR UPDATE

        """;


        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                category
            );


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (!rs.next()) {

                    throw new Exception(
                        "Kategori inventori tidak sah atau tidak aktif."
                    );
                }


                String prefix =
                        clean(
                            rs.getString(
                                "code_prefix"
                            )
                        ).toUpperCase();


                if (prefix.isBlank()) {

                    throw new Exception(
                        "Prefix kategori tidak ditetapkan."
                    );
                }


                return prefix;
            }
        }
    }


    // =========================================================
    // GENERATE NEXT ITEM CODE
    // =========================================================

    private String generateNextItemCode(
            Connection con,
            String prefix)
            throws Exception {

        /*
         * Contoh:
         *
         * INK-001
         * INK-002
         * INK-003
         *
         * Fungsi mencari nombor TERBESAR yang pernah
         * digunakan untuk prefix tersebut, kemudian +1.
         *
         * Jika INK-003 dipadam sekalipun, item baru
         * tidak akan menggunakan semula kod itu selagi
         * terdapat nombor yang lebih tinggi.
         */

        String sql = """

            SELECT
                MAX(
                    CAST(
                        SUBSTRING(
                            item_code,
                            LENGTH(?) + 2
                        )
                        AS UNSIGNED
                    )
                ) AS max_number

            FROM inventory_items

            WHERE item_code
                  LIKE CONCAT(?, '-%')

        """;


        int nextNumber = 1;


        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                prefix
            );

            ps.setString(
                2,
                prefix
            );


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (rs.next()) {

                    int max =
                            rs.getInt(
                                "max_number"
                            );


                    if (
                        !rs.wasNull()
                    ) {

                        nextNumber =
                                max + 1;
                    }
                }
            }
        }


        String itemCode =
                prefix
                + "-"
                + String.format(
                    "%03d",
                    nextNumber
                );


        // =====================================================
        // EXTRA DUPLICATE SAFETY CHECK
        // =====================================================

        String duplicateSql = """

            SELECT COUNT(*)

            FROM inventory_items

            WHERE item_code = ?

        """;


        try (
            PreparedStatement ps =
                    con.prepareStatement(
                        duplicateSql
                    )
        ) {

            ps.setString(
                1,
                itemCode
            );


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {

                if (
                    rs.next()
                    &&
                    rs.getInt(1) > 0
                ) {

                    throw new Exception(
                        "Kod inventori automatik bertindih. Sila cuba semula."
                    );
                }
            }
        }


        return itemCode;
    }


    // =========================================================
    // DELETE ITEM (SOFT DELETE)
    // =========================================================

    private void deleteItem(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int id = parsePositiveId(
                request.getParameter("id"),
                "ID inventori"
        );

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String itemSql = """
                SELECT
                    item_code,
                    item_name,
                    is_active,
                    available_quantity
                FROM inventory_items
                WHERE id = ?
                FOR UPDATE
            """;

            String itemCode;
            String itemName;
            int isActive;
            int availableQuantity;

            try (PreparedStatement ps = con.prepareStatement(itemSql)) {
                ps.setInt(1, id);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new Exception("Inventori tidak dijumpai.");
                    }

                    itemCode = rs.getString("item_code");
                    itemName = rs.getString("item_name");
                    isActive = rs.getInt("is_active");
                    availableQuantity = rs.getInt("available_quantity");
                }
            }

            if (isActive == 0) {
                throw new Exception("Inventori ini telah dinyahaktifkan.");
            }

            /*
             * Soft delete: rekod inventori tidak dipadam daripada database.
             * Rekod transaksi khas direkodkan dengan kuantiti 0 dan stok
             * sebelum/selepas yang sama supaya tindakan ini tidak dikira
             * sebagai stok masuk atau stok keluar.
             */
            String deactivateSql = """
                UPDATE inventory_items
                SET is_active = 0
                WHERE id = ?
                  AND is_active = 1
            """;

            try (PreparedStatement ps = con.prepareStatement(deactivateSql)) {
                ps.setInt(1, id);

                int updated = ps.executeUpdate();
                if (updated != 1) {
                    throw new Exception(
                            "Inventori tidak dijumpai atau telah dinyahaktifkan."
                    );
                }
            }

            insertInventoryTransaction(
                    con,
                    id,
                    null,
                    null,
                    "DELETE_INVENTORY",
                    0,
                    availableQuantity,
                    availableQuantity,
                    "Inventori dinyahaktifkan: "
                            + itemName
                            + " ("
                            + itemCode
                            + "). Tiada perubahan kuantiti stok.",
                    reviewerId
            );

            ActivityLogUtil.log(
                    con,
                    request,
                    "DELETE_INVENTORY",
                    "Menyahaktifkan inventori: "
                            + itemName
                            + " ("
                            + itemCode
                            + ")",
                    "INVENTORY_ITEM",
                    id
            );

            con.commit();

        } catch (Exception e) {
            rollbackQuietly(con);
            throw e;

        } finally {
            closeConnection(con);
        }
    }


    // =========================================================
    // APPROVE INVENTORY REQUEST
    // =========================================================

    private void approveRequest(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int requestId =
                parsePositiveId(
                    request.getParameter(
                        "request_id"
                    ),
                    "ID permohonan"
                );


        String remarks =
                clean(
                    request.getParameter(
                        "remarks"
                    )
                );


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            // =================================================
            // LOCK REQUEST
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


            if (
                !"PENDING".equalsIgnoreCase(
                    currentStatus
                )
            ) {

                throw new Exception(
                    "Permohonan ini telah diproses sebelum ini."
                );
            }


            if (
                requestedQuantity <= 0
            ) {

                throw new Exception(
                    "Kuantiti permohonan tidak sah."
                );
            }


            // =================================================
            // LOCK INVENTORY
            // =================================================

            String stockSql = """

                SELECT
                    available_quantity,
                    unit

                FROM inventory_items

                WHERE id = ?

                FOR UPDATE

            """;


            int available;
            String unit;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            stockSql
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

                    unit =
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
                }
            }


            if (
                requestedQuantity > available
            ) {

                throw new Exception(
                    "Permohonan tidak dapat diluluskan. "
                    + "Hanya "
                    + available
                    + " "
                    + unit
                    + " tersedia."
                );
            }


            int newAvailable =
                    available
                    -
                    requestedQuantity;


            String newStockStatus =
                    calculateStockStatus(
                        newAvailable
                    );


            // =================================================
            // UPDATE STOCK
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
                    newStockStatus
                );

                ps.setInt(
                    3,
                    itemId
                );


                int updated =
                        ps.executeUpdate();


                if (
                    updated == 0
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
                    updated == 0
                ) {

                    throw new Exception(
                        "Permohonan ini telah diproses."
                    );
                }
            }


            // =================================================
            // STOCK OUT TRANSACTION
            // =================================================

            insertInventoryTransaction(
                con,
                itemId,
                requestId,
                applicantUserId,
                "STOCK_OUT",
                requestedQuantity,
                available,
                newAvailable,
                remarks.isBlank()
                    ? "Stok keluar melalui permohonan inventori yang diluluskan."
                    : remarks,
                reviewerId
            );


            // =================================================
            // NOTIFICATION
            // =================================================

            String notificationMessage =
                    "Permohonan anda untuk "
                    + requestedQuantity
                    + " "
                    + unit
                    + " "
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
            // AUDIT
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "APPROVE_INVENTORY_REQUEST",
                "Meluluskan permohonan inventori #"
                    + requestId
                    + ": "
                    + requestedQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " (Stok: "
                    + available
                    + " → "
                    + newAvailable
                    + ")",
                "INVENTORY_REQUEST",
                requestId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // REJECT INVENTORY REQUEST
    // =========================================================

    private void rejectRequest(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int requestId =
                parsePositiveId(
                    request.getParameter(
                        "request_id"
                    ),
                    "ID permohonan"
                );


        String remarks =
                clean(
                    request.getParameter(
                        "remarks"
                    )
                );


        if (
            remarks.isBlank()
        ) {

            throw new Exception(
                "Sila masukkan sebab permohonan ditolak."
            );
        }


        Connection con = null;


        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            String selectSql = """

                SELECT
                    r.user_id,
                    r.quantity,
                    r.status,
                    i.item_name,
                    i.unit

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
            String unit;


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

                    if (!rs.next()) {

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

                    unit =
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
                }
            }


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
            // REJECT
            // =================================================

            String sql = """

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
                            sql
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
                    updated == 0
                ) {

                    throw new Exception(
                        "Permohonan tidak dijumpai atau telah diproses."
                    );
                }
            }


            // =================================================
            // NOTIFICATION
            // =================================================

            NotificationUtil.create(
                con,
                applicantUserId,
                "INVENTORY_REQUEST_REJECTED",
                "Permohonan Inventori Ditolak",
                "Permohonan anda untuk "
                    + requestedQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " telah ditolak. Sebab: "
                    + remarks,
                "INVENTORY_REQUEST",
                requestId
            );


            // =================================================
            // AUDIT
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "REJECT_INVENTORY_REQUEST",
                "Menolak permohonan inventori #"
                    + requestId
                    + ": "
                    + requestedQuantity
                    + " "
                    + unit
                    + " "
                    + itemName,
                "INVENTORY_REQUEST",
                requestId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // RETURN INVENTORY REQUEST
    // Menyokong partial return untuk SEMUA jenis barang.
    //
    // Contoh:
    // Diluluskan 5, pulang 2 -> baki boleh pulang 3.
    // Pulang lagi 1 -> baki boleh pulang 2.
    // Sistem tidak membenarkan jumlah pulangan melebihi
    // kuantiti asal yang diluluskan.
    // =========================================================

    private void returnRequest(
            HttpServletRequest request,
            int reviewerId)
            throws Exception {

        int requestId =
                parsePositiveId(
                    request.getParameter(
                        "request_id"
                    ),
                    "ID permohonan"
                );

        int returnQuantity =
                parsePositiveId(
                    request.getParameter(
                        "return_quantity"
                    ),
                    "Kuantiti dipulangkan"
                );

        String returnRemarks =
                clean(
                    request.getParameter(
                        "return_remarks"
                    )
                );

        Connection con = null;

        try {

            con =
                    DBConnection.getConnection();

            con.setAutoCommit(false);


            // =====================================================
            // LOCK REQUEST + GET ITEM / STAFF INFORMATION
            // =====================================================

            String requestSql = """

                SELECT
                    r.user_id,
                    r.item_id,
                    r.quantity,
                    r.status,

                    u.name AS staff_name,

                    i.item_code,
                    i.item_name,
                    i.available_quantity,
                    i.unit

                FROM inventory_requests r

                JOIN users u
                    ON r.user_id = u.id

                JOIN inventory_items i
                    ON r.item_id = i.id

                WHERE r.id = ?

                FOR UPDATE

            """;


            int applicantUserId;
            int itemId;
            int approvedQuantity;
            int currentAvailable;

            String currentStatus;
            String staffName;
            String itemCode;
            String itemName;
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

                    approvedQuantity =
                            rs.getInt(
                                "quantity"
                            );

                    currentStatus =
                            rs.getString(
                                "status"
                            );

                    staffName =
                            rs.getString(
                                "staff_name"
                            );

                    itemCode =
                            rs.getString(
                                "item_code"
                            );

                    itemName =
                            rs.getString(
                                "item_name"
                            );

                    currentAvailable =
                            rs.getInt(
                                "available_quantity"
                            );

                    unit =
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
                }
            }


            // Hanya permohonan yang pernah diluluskan boleh dipulangkan.
            if (
                !"APPROVED".equalsIgnoreCase(
                    currentStatus
                )
            ) {

                throw new Exception(
                    "Hanya permohonan yang telah diluluskan boleh dipulangkan."
                );
            }


            if (approvedQuantity <= 0) {

                throw new Exception(
                    "Kuantiti permohonan tidak sah."
                );
            }


            // =====================================================
            // CALCULATE TOTAL PREVIOUS RETURN
            // =====================================================

            String returnedSql = """

                SELECT
                    COALESCE(
                        SUM(quantity),
                        0
                    ) AS total_returned

                FROM inventory_transactions

                WHERE request_id = ?
                  AND transaction_type = 'RETURN'

            """;


            int totalReturned = 0;


            try (
                PreparedStatement ps =
                        con.prepareStatement(
                            returnedSql
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

                    if (rs.next()) {

                        totalReturned =
                                rs.getInt(
                                    "total_returned"
                                );
                    }
                }
            }


            int remainingReturnable =
                    approvedQuantity
                    -
                    totalReturned;


            if (remainingReturnable <= 0) {

                throw new Exception(
                    "Semua barang bagi permohonan ini telah dipulangkan."
                );
            }


            if (
                returnQuantity
                >
                remainingReturnable
            ) {

                throw new Exception(
                    "Kuantiti pulangan melebihi baki yang boleh dipulangkan. "
                    + "Baki maksimum ialah "
                    + remainingReturnable
                    + " "
                    + unit
                    + "."
                );
            }


            // =====================================================
            // CALCULATE NEW AVAILABLE STOCK
            // =====================================================

            int newAvailable;


            try {

                newAvailable =
                        Math.addExact(
                            currentAvailable,
                            returnQuantity
                        );

            } catch (
                ArithmeticException e
            ) {

                throw new Exception(
                    "Kuantiti stok terlalu besar."
                );
            }


            String newStockStatus =
                    calculateStockStatus(
                        newAvailable
                    );


            // =====================================================
            // UPDATE INVENTORY AVAILABLE STOCK
            //
            // quantity TIDAK ditambah kerana barang yang dipulangkan
            // memang sudah termasuk dalam jumlah aset/stok syarikat.
            // Hanya available_quantity bertambah semula.
            // =====================================================

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
                    newStockStatus
                );

                ps.setInt(
                    3,
                    itemId
                );


                int updated =
                        ps.executeUpdate();


                if (updated != 1) {

                    throw new Exception(
                        "Stok inventori tidak dapat dikemas kini."
                    );
                }
            }


            // =====================================================
            // RECORD RETURN TRANSACTION
            // =====================================================

            int totalReturnedAfter =
                    totalReturned
                    +
                    returnQuantity;

            int remainingAfter =
                    approvedQuantity
                    -
                    totalReturnedAfter;


            String transactionRemarks;

            if (returnRemarks.isBlank()) {

                transactionRemarks =
                        "Pemulangan inventori oleh "
                        + staffName
                        + ". Baki belum dipulangkan: "
                        + remainingAfter
                        + " "
                        + unit
                        + ".";

            } else {

                transactionRemarks =
                        returnRemarks
                        + " | Baki belum dipulangkan: "
                        + remainingAfter
                        + " "
                        + unit
                        + ".";
            }


            insertInventoryTransaction(
                con,
                itemId,
                requestId,
                applicantUserId,
                "RETURN",
                returnQuantity,
                currentAvailable,
                newAvailable,
                transactionRemarks,
                reviewerId
            );


            // =====================================================
            // NOTIFICATION TO STAFF
            // =====================================================

            String notificationMessage =
                    returnQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " telah direkodkan sebagai dipulangkan."
                    + " Jumlah dipulangkan: "
                    + totalReturnedAfter
                    + " daripada "
                    + approvedQuantity
                    + " "
                    + unit
                    + ".";


            if (remainingAfter > 0) {

                notificationMessage +=
                        " Baki yang masih boleh dipulangkan: "
                        + remainingAfter
                        + " "
                        + unit
                        + ".";

            } else {

                notificationMessage +=
                        " Semua kuantiti bagi permohonan ini telah dipulangkan.";
            }


            NotificationUtil.create(
                con,
                applicantUserId,
                "INVENTORY_RETURN",
                "Pemulangan Inventori Direkodkan",
                notificationMessage,
                "INVENTORY_REQUEST",
                requestId
            );


            // =====================================================
            // AUDIT TRAIL
            // =====================================================

            ActivityLogUtil.log(
                con,
                request,
                "RETURN_INVENTORY",
                "Merekod pemulangan inventori #"
                    + requestId
                    + ": "
                    + returnQuantity
                    + " "
                    + unit
                    + " "
                    + itemName
                    + " ("
                    + itemCode
                    + ") oleh "
                    + staffName
                    + " — Stok: "
                    + currentAvailable
                    + " → "
                    + newAvailable
                    + "; Jumlah dipulangkan: "
                    + totalReturnedAfter
                    + "/"
                    + approvedQuantity
                    + "; Baki: "
                    + remainingAfter
                    + " "
                    + unit,
                "INVENTORY_REQUEST",
                requestId
            );


            con.commit();

        } catch (Exception e) {

            rollbackQuietly(con);

            throw e;

        } finally {

            closeConnection(con);
        }
    }


    // =========================================================
    // VALIDATE ITEM
    // =========================================================

    private void validateItem(
            String itemName,
            String category,
            String itemType,
            String unit,
            int quantity,
            int availableQuantity)
            throws Exception {


        if (
            itemName == null
            ||
            itemName.isBlank()
        ) {

            throw new Exception(
                "Nama barang diperlukan."
            );
        }


        if (
            category == null
            ||
            category.isBlank()
        ) {

            throw new Exception(
                "Kategori diperlukan."
            );
        }


        if (itemType == null || itemType.isBlank() || "__NEW__".equals(itemType)) {
            throw new Exception("Jenis barang diperlukan.");
        }


        if (
            unit == null
            ||
            unit.isBlank()
        ) {

            throw new Exception(
                "Unit inventori diperlukan."
            );
        }


        if (
            quantity < 0
        ) {

            throw new Exception(
                "Jumlah kuantiti tidak boleh negatif."
            );
        }


        if (
            availableQuantity < 0
        ) {

            throw new Exception(
                "Kuantiti tersedia tidak boleh negatif."
            );
        }


        if (
            availableQuantity > quantity
        ) {

            throw new Exception(
                "Kuantiti tersedia tidak boleh melebihi jumlah kuantiti."
            );
        }
    }


    // =========================================================
    // APPEND AUDIT CHANGE
    // =========================================================

    private void appendChange(
            StringBuilder builder,
            String label,
            String oldValue,
            String newValue) {

        String oldClean =
                oldValue == null
                    ? ""
                    : oldValue.trim();

        String newClean =
                newValue == null
                    ? ""
                    : newValue.trim();


        if (
            oldClean.equals(newClean)
        ) {

            return;
        }


        if (
            builder.length() > 0
        ) {

            builder.append("; ");
        }


        builder
            .append(label)
            .append(": ")
            .append(
                oldClean.isBlank()
                    ? "-"
                    : oldClean
            )
            .append(" → ")
            .append(
                newClean.isBlank()
                    ? "-"
                    : newClean
            );
    }


    // =========================================================
    // STOCK STATUS
    // =========================================================

    private String calculateStockStatus(
            int availableQuantity) {

        // Digunakan oleh operasi yang hanya mempunyai nilai baki.
        if (availableQuantity <= 0) {
            return "OUT_OF_STOCK";
        }
        return "AVAILABLE";
    }


    private String calculateStockStatus(
            int availableQuantity,
            int totalQuantity) {

        if (availableQuantity <= 0) {
            return "OUT_OF_STOCK";
        }

        if (totalQuantity > 0
                && availableQuantity * 100L <= totalQuantity * 20L) {
            return "LOW_STOCK";
        }

        return "AVAILABLE";
    }


    // =========================================================
    // PARSE POSITIVE OR ZERO
    // =========================================================

    private int parsePositiveOrZero(
            String value,
            String fieldName)
            throws Exception {

        if (
            value == null
            ||
            value.isBlank()
        ) {

            throw new Exception(
                fieldName
                + " diperlukan."
            );
        }


        try {

            int number =
                    Integer.parseInt(
                        value.trim()
                    );


            if (
                number < 0
            ) {

                throw new Exception(
                    fieldName
                    + " tidak boleh negatif."
                );
            }


            return number;

        } catch (
            NumberFormatException e
        ) {

            throw new Exception(
                fieldName
                + " mestilah nombor yang sah."
            );
        }
    }


    // =========================================================
    // PARSE POSITIVE ID
    // =========================================================

    private int parsePositiveId(
            String value,
            String fieldName)
            throws Exception {

        try {

            int id =
                    Integer.parseInt(
                        value
                    );


            if (
                id <= 0
            ) {

                throw new Exception(
                    fieldName
                    + " tidak sah."
                );
            }


            return id;

        } catch (
            NullPointerException
            |
            NumberFormatException e
        ) {

            throw new Exception(
                fieldName
                + " tidak sah."
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
    // ROLLBACK
    // =========================================================

    private void rollbackQuietly(
            Connection con) {

        if (
            con == null
        ) {

            return;
        }


        try {

            con.rollback();

        } catch (
            SQLException ignored
        ) {
        }
    }


    // =========================================================
    // CLOSE CONNECTION
    // =========================================================

    private void closeConnection(
            Connection con) {

        if (
            con == null
        ) {

            return;
        }


        try {

            con.setAutoCommit(true);

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


    // =========================================================
    // REDIRECT MESSAGE
    // =========================================================

    private void redirectWithMessage(
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
            + "/inventory-admin?"
            + (
                error
                    ? "error="
                    : "success="
            )
            + encoded
        );
    }
}