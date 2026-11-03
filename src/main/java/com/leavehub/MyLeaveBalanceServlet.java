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

import java.time.Year;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@WebServlet("/my-leave-balance")
public class MyLeaveBalanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private static final String ANNUAL =
        "Cuti Tahunan";

    private static final String EMERGENCY =
        "Cuti Kecemasan";

    private static final String NO_RECORD =
        "Cuti Tanpa Rekod";

    private static final String UNPAID =
        "Cuti Tanpa Gaji";

    private static final String OTHER =
        "Lain-lain";


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // SESSION
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


        Integer userId =
            getUserId(
                session
            );


        if (userId == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // CURRENT YEAR
        // =====================================================

        int currentYear =
            Year.now().getValue();


        List<Map<String,Object>> balances =
            new ArrayList<>();


        // =====================================================
        // SQL - USER
        // =====================================================

        String userSql = """

            SELECT

                name,
                position,
                department,
                role

            FROM users

            WHERE id = ?

            LIMIT 1

        """;


        // =====================================================
        // SQL - BALANCE
        // =====================================================

        String balanceSql = """

            SELECT

                lt.leave_type_id,
                lt.leave_type_name,
                lt.requires_document,

                lb.balance_id,
                lb.entitlement,
                lb.used_days,
                lb.remaining_days,
                lb.carry_forward_days,
                lb.carry_forward_used

            FROM leave_types lt

            LEFT JOIN leave_balances lb

                ON lb.leave_type_id =
                   lt.leave_type_id

                AND lb.user_id = ?

                AND lb.leave_year = ?

            WHERE lt.is_active = 1

            ORDER BY
                lt.leave_type_id ASC

        """;


        try (
            Connection con =
                DBConnection.getConnection()
        ) {


            // =================================================
            // ENSURE CURRENT YEAR SHARED BALANCE
            // =================================================
            //
            // Sistem perlu memastikan balance Cuti Tahunan
            // untuk tahun semasa wujud.
            //
            // Jika sudah wujud:
            // - guna entitlement tahun semasa.
            //
            // Jika belum wujud:
            // - cari entitlement Cuti Tahunan terbaru
            //   daripada tahun sebelumnya.
            // - gunakan entitlement tersebut untuk tahun baru.
            // - LeaveCarryForwardUtil akan menguruskan
            //   Carry Forward.
            //
            // TIADA entitlement hardcoded di sini.
            // =================================================


            Integer entitlementForCurrentYear =
                null;


            // =================================================
            // 1. CHECK CURRENT YEAR ENTITLEMENT
            // =================================================

            String currentYearSql = """

                SELECT entitlement

                FROM leave_balances

                WHERE user_id = ?
                  AND leave_type_id = 1
                  AND leave_year = ?

                LIMIT 1

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        currentYearSql
                    )
            ) {

                ps.setInt(
                    1,
                    userId
                );

                ps.setInt(
                    2,
                    currentYear
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {

                    if (rs.next()) {

                        entitlementForCurrentYear =
                            rs.getInt(
                                "entitlement"
                            );
                    }
                }
            }


            // =================================================
            // 2. IF CURRENT YEAR DOES NOT EXIST,
            //    FIND LATEST PREVIOUS ENTITLEMENT
            // =================================================

            if (entitlementForCurrentYear == null) {


                String previousEntitlementSql = """

                    SELECT entitlement

                    FROM leave_balances

                    WHERE user_id = ?
                      AND leave_type_id = 1
                      AND leave_year < ?

                    ORDER BY leave_year DESC

                    LIMIT 1

                """;


                try (
                    PreparedStatement ps =
                        con.prepareStatement(
                            previousEntitlementSql
                        )
                ) {

                    ps.setInt(
                        1,
                        userId
                    );

                    ps.setInt(
                        2,
                        currentYear
                    );


                    try (
                        ResultSet rs =
                            ps.executeQuery()
                    ) {

                        if (rs.next()) {

                            entitlementForCurrentYear =
                                rs.getInt(
                                    "entitlement"
                                );
                        }
                    }
                }
            }


            // =================================================
            // 3. CREATE / ENSURE CURRENT YEAR BALANCE
            // =================================================
            //
            // Hanya jalankan jika entitlement memang diketahui.
            //
            // Ini mengelakkan sistem daripada meneka 30, 50,
            // atau nilai lain bagi staff yang belum mempunyai
            // konfigurasi.
            // =================================================

            if (
                entitlementForCurrentYear != null
                &&
                entitlementForCurrentYear >= 0
            ) {

                LeaveCarryForwardUtil.ensureSharedBalance(
                    con,
                    userId,
                    currentYear,
                    entitlementForCurrentYear
                );
            }


            // =================================================
            // USER
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        userSql
                    )
            ) {


                ps.setInt(
                    1,
                    userId
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (!rs.next()) {

                        session.invalidate();

                        response.sendRedirect(
                            request.getContextPath()
                            + "/"
                        );

                        return;
                    }


                    request.setAttribute(
                        "staffName",
                        rs.getString("name")
                    );


                    request.setAttribute(
                        "position",
                        rs.getString("position")
                    );


                    request.setAttribute(
                        "department",
                        rs.getString("department")
                    );


                    request.setAttribute(
                        "role",
                        rs.getString("role")
                    );
                }
            }


            // =================================================
            // LOAD BALANCES
            // =================================================

            int annualEntitlement = 0;

            int annualUsed = 0;

            int annualCarryForwardDays = 0;

            int annualCarryForwardUsed = 0;

            boolean annualConfigured = false;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        balanceSql
                    )
            ) {


                ps.setInt(
                    1,
                    userId
                );


                ps.setInt(
                    2,
                    currentYear
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    while (rs.next()) {


                        Map<String,Object> row =
                            new HashMap<>();


                        int leaveTypeId =
                            rs.getInt(
                                "leave_type_id"
                            );


                        String leaveTypeName =
                            rs.getString(
                                "leave_type_name"
                            );


                        boolean requiresDocument =
                            rs.getBoolean(
                                "requires_document"
                            );


                        Object balanceId =
                            rs.getObject(
                                "balance_id"
                            );


                        boolean balanceConfigured =
                            balanceId != null;


                        int entitlement =
                            0;


                        int usedDays =
                            0;


                        int remainingDays =
                            0;


                        int carryForwardDays =
                            0;


                        int carryForwardUsed =
                            0;


                        if (balanceConfigured) {


                            entitlement =
                                rs.getInt(
                                    "entitlement"
                                );


                            usedDays =
                                rs.getInt(
                                    "used_days"
                                );


                            remainingDays =
                                rs.getInt(
                                    "remaining_days"
                                );


                            carryForwardDays =
                                rs.getInt(
                                    "carry_forward_days"
                                );


                            carryForwardUsed =
                                rs.getInt(
                                    "carry_forward_used"
                                );
                        }


                        boolean sharedBalance =
                            isSharedLeave(
                                leaveTypeName
                            );


                        boolean noQuota =
                            isNoQuotaLeave(
                                leaveTypeName
                            );


                        // =========================================
                        // ANNUAL BALANCE IS THE SHARED SOURCE
                        // =========================================

                        if (
                            ANNUAL.equalsIgnoreCase(
                                leaveTypeName
                            )
                        ) {

                            annualConfigured =
                                balanceConfigured;


                            annualEntitlement =
                                entitlement;


                            annualUsed =
                                usedDays;


                            annualCarryForwardDays =
                                carryForwardDays;


                            annualCarryForwardUsed =
                                carryForwardUsed;
                        }


                        // =========================================
                        // ROW DATA
                        // =========================================

                        row.put(
                            "leaveTypeId",
                            leaveTypeId
                        );


                        row.put(
                            "leaveTypeName",
                            leaveTypeName
                        );


                        row.put(
                            "requiresDocument",
                            requiresDocument
                        );


                        row.put(
                            "balanceConfigured",
                            balanceConfigured
                        );


                        row.put(
                            "entitlement",
                            entitlement
                        );


                        row.put(
                            "usedDays",
                            usedDays
                        );


                        row.put(
                            "remainingDays",
                            remainingDays
                        );


                        row.put(
                            "carryForwardDays",
                            carryForwardDays
                        );


                        row.put(
                            "carryForwardUsed",
                            carryForwardUsed
                        );


                        row.put(
                            "carryForwardRemaining",
                            Math.max(
                                0,
                                carryForwardDays
                                    - carryForwardUsed
                            )
                        );


                        row.put(
                            "sharedBalance",
                            sharedBalance
                        );


                        row.put(
                            "noQuota",
                            noQuota
                        );


                        balances.add(
                            row
                        );
                    }
                }
            }


            // =================================================
            // SHARED ANNUAL + EMERGENCY
            // =================================================
            //
            // Cuti Tahunan dan Cuti Kecemasan berkongsi
            // baki yang sama.
            //
            // Semua baki sebenar disimpan pada:
            //
            // leave_type_id = 1
            //
            // iaitu Cuti Tahunan.
            //
            // Cuti Kecemasan hanya merupakan jenis
            // permohonan yang menggunakan pool sama.
            // =================================================


            boolean sharedConfigured =
                annualConfigured;


            int sharedEntitlement =
                annualEntitlement;


            int sharedUsed =
                annualUsed;


            int sharedCarryForwardDays =
                annualCarryForwardDays;


            int sharedCarryForwardUsed =
                annualCarryForwardUsed;


            // =================================================
            // CARRY FORWARD REMAINING
            // =================================================

            int sharedCarryForwardRemaining =
                Math.max(
                    0,
                    sharedCarryForwardDays
                        - sharedCarryForwardUsed
                );


            // =================================================
            // CURRENT YEAR USAGE
            // =================================================
            //
            // Carry Forward digunakan terlebih dahulu.
            //
            // Contoh:
            //
            // CF = 5
            // used = 3
            //
            // CF used = 3
            // current year used = 0
            //
            // Jika used = 8:
            //
            // CF used = 5
            // current year used = 3
            // =================================================

            int sharedCurrentYearUsed =
                Math.max(
                    0,
                    sharedUsed
                        - sharedCarryForwardUsed
                );


            // =================================================
            // CURRENT YEAR REMAINING
            // =================================================

            int sharedCurrentYearRemaining =
                Math.max(
                    0,
                    sharedEntitlement
                        - sharedCurrentYearUsed
                );


            // =================================================
            // TOTAL REMAINING
            // =================================================
            //
            // Total baki =
            //
            // CF remaining
            // +
            // current year entitlement remaining
            // =================================================

            int sharedRemaining =
                sharedCarryForwardRemaining
                    + sharedCurrentYearRemaining;


            // =================================================
            // UPDATE DISPLAY ROWS
            // =================================================

            for (
                Map<String,Object> row :
                balances
            ) {


                boolean sharedBalance =
                    Boolean.TRUE.equals(
                        row.get(
                            "sharedBalance"
                        )
                    );


                boolean noQuota =
                    Boolean.TRUE.equals(
                        row.get(
                            "noQuota"
                        )
                    );


                // =============================================
                // SHARED LEAVE
                // =============================================

                if (sharedBalance) {


                    row.put(
                        "balanceConfigured",
                        sharedConfigured
                    );


                    row.put(
                        "entitlement",
                        sharedEntitlement
                    );


                    row.put(
                        "usedDays",
                        sharedUsed
                    );


                    row.put(
                        "remainingDays",
                        sharedRemaining
                    );


                    row.put(
                        "carryForwardDays",
                        sharedCarryForwardDays
                    );


                    row.put(
                        "carryForwardUsed",
                        sharedCarryForwardUsed
                    );


                    row.put(
                        "carryForwardRemaining",
                        sharedCarryForwardRemaining
                    );


                    row.put(
                        "currentYearUsed",
                        sharedCurrentYearUsed
                    );


                    row.put(
                        "currentYearRemaining",
                        sharedCurrentYearRemaining
                    );
                }


                // =============================================
                // NO QUOTA LEAVE
                // =============================================

                if (noQuota) {

                    row.put(
                        "balanceConfigured",
                        true
                    );
                }
            }


            // =================================================
            // ATTRIBUTES
            // =================================================

            request.setAttribute(
                "balances",
                balances
            );


            request.setAttribute(
                "currentYear",
                currentYear
            );


            request.setAttribute(
                "sharedEntitlement",
                sharedEntitlement
            );


            request.setAttribute(
                "sharedUsed",
                sharedUsed
            );


            request.setAttribute(
                "sharedRemaining",
                sharedRemaining
            );


            request.setAttribute(
                "sharedCarryForwardDays",
                sharedCarryForwardDays
            );


            request.setAttribute(
                "sharedCarryForwardUsed",
                sharedCarryForwardUsed
            );


            request.setAttribute(
                "sharedCarryForwardRemaining",
                sharedCarryForwardRemaining
            );


            request.setAttribute(
                "sharedCurrentYearUsed",
                sharedCurrentYearUsed
            );


            request.setAttribute(
                "sharedCurrentYearRemaining",
                sharedCurrentYearRemaining
            );


            request
                .getRequestDispatcher(
                    "/my-leave-balance.jsp"
                )
                .forward(
                    request,
                    response
                );


        } catch (
            SQLException e
        ) {


            throw new ServletException(
                "Tidak dapat memuatkan baki cuti anda.",
                e
            );
        }
    }


    // =========================================================
    // SHARED
    // =========================================================

    private boolean isSharedLeave(
            String leaveTypeName) {


        if (
            leaveTypeName == null
        ) {

            return false;
        }


        return
            ANNUAL.equalsIgnoreCase(
                leaveTypeName
            )
            ||
            EMERGENCY.equalsIgnoreCase(
                leaveTypeName
            );
    }


    // =========================================================
    // NO QUOTA
    // =========================================================

    private boolean isNoQuotaLeave(
            String leaveTypeName) {


        if (
            leaveTypeName == null
        ) {

            return false;
        }


        return
            NO_RECORD.equalsIgnoreCase(
                leaveTypeName
            )
            ||
            UNPAID.equalsIgnoreCase(
                leaveTypeName
            )
            ||
            OTHER.equalsIgnoreCase(
                leaveTypeName
            );
    }


    // =========================================================
    // USER ID
    // =========================================================

    private Integer getUserId(
            HttpSession session) {


        try {


            int id =
                Integer.parseInt(
                    session
                        .getAttribute(
                            "userId"
                        )
                        .toString()
                );


            return
                id > 0
                    ? id
                    : null;


        } catch (
            Exception e
        ) {


            return null;
        }
    }
}