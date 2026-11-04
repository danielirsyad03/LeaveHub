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
import java.util.List;


@WebServlet("/leave-balance")
public class LeaveBalanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // LEAVE NAMES
    // =========================================================

    private static final String ANNUAL =
        "Cuti Tahunan";

    private static final String EMERGENCY =
        "Cuti Kecemasan";

    


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


        // =====================================================
        // HR ONLY
        // =====================================================

        if (!isHR(request)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }


        // =====================================================
        // PARAMETERS
        // =====================================================

        Integer userId =
            parsePositiveInteger(
                request.getParameter(
                    "userId"
                )
            );


        Integer leaveYear =
            parsePositiveInteger(
                request.getParameter(
                    "leaveYear"
                )
            );


        if (userId == null) {

            redirectError(
                request,
                response,
                "invalidBalance"
            );

            return;
        }


        if (leaveYear == null) {

            leaveYear =
                Year.now().getValue();
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
            // LOCK USER + GET USER INFO FOR AUDIT
            // =================================================

            UserInfo targetUser =
                lockUser(
                    con,
                    userId
                );


            if (targetUser == null) {

                con.rollback();

                redirectError(
                    request,
                    response,
                    "balanceNotFound"
                );

                return;
            }


            // =================================================
            // LOAD ACTIVE QUOTA LEAVE TYPES
            //
            // No fixed quota:
            // - Cuti Tanpa Rekod
            // - Cuti Tanpa Gaji
            // - Lain-lain
            // =================================================

            List<LeaveTypeInfo> leaveTypes =
                loadQuotaLeaveTypes(
                    con
                );


            if (leaveTypes.isEmpty()) {

                con.rollback();

                redirectError(
                    request,
                    response,
                    "invalidBalance"
                );

                return;
            }


            // =================================================
            // IDENTIFY ANNUAL + EMERGENCY
            // =================================================

            Integer annualTypeId =
                null;

            Integer emergencyTypeId =
                null;


            for (
                LeaveTypeInfo type :
                leaveTypes
            ) {


                if (
                    ANNUAL.equalsIgnoreCase(
                        type.name
                    )
                ) {

                    annualTypeId =
                        type.id;


                } else if (
                    EMERGENCY.equalsIgnoreCase(
                        type.name
                    )
                ) {

                    emergencyTypeId =
                        type.id;
                }
            }


            boolean hasAnyInput =
                false;


            boolean sharedHandled =
                false;


            boolean hasChanges =
                false;


            StringBuilder auditChanges =
                new StringBuilder();


            // =================================================
            // PROCESS FORM
            // =================================================

            for (
                LeaveTypeInfo type :
                leaveTypes
            ) {


                // =============================================
                // ANNUAL / EMERGENCY SHARED POOL
                // =============================================

                if (
                    ANNUAL.equalsIgnoreCase(
                        type.name
                    )
                    ||
                    EMERGENCY.equalsIgnoreCase(
                        type.name
                    )
                ) {


                    if (sharedHandled) {

                        continue;
                    }


                    sharedHandled =
                        true;


                    String sharedParam =
                        firstNonBlank(

                            request.getParameter(
                                "sharedEntitlement"
                            ),

                            annualTypeId == null
                                ? null
                                : request.getParameter(
                                    "entitlement_"
                                    + annualTypeId
                                ),

                            emergencyTypeId == null
                                ? null
                                : request.getParameter(
                                    "entitlement_"
                                    + emergencyTypeId
                                )
                        );


                    // =========================================
                    // FIELD NOT SUBMITTED
                    // =========================================

                    if (sharedParam == null) {

                        continue;
                    }


                    hasAnyInput =
                        true;


                    Integer newSharedEntitlement =
                        parseNonNegativeInteger(
                            sharedParam
                        );


                    if (
                        newSharedEntitlement == null
                    ) {

                        con.rollback();

                        redirectError(
                            request,
                            response,
                            "invalidBalance"
                        );

                        return;
                    }


                    if (
                        annualTypeId == null
                        ||
                        emergencyTypeId == null
                    ) {

                        con.rollback();

                        redirectError(
                            request,
                            response,
                            "sharedBalanceMissing"
                        );

                        return;
                    }


                    // =========================================
                    // LOCK ANNUAL MASTER BALANCE
                    //
                    // Cuti Tahunan ialah SATU-SATUNYA row yang
                    // menyimpan shared balance Tahunan/Kecemasan.
                    // Row Cuti Kecemasan mesti kekal 0.
                    // =========================================

                    BalanceInfo annualBalance =
                        getBalanceForUpdate(
                            con,
                            userId,
                            annualTypeId,
                            leaveYear
                        );

                    int totalSharedUsed =
                        annualBalance == null
                            ? 0
                            : annualBalance.usedDays;

                    int carryForwardDays =
                        annualBalance == null
                            ? 0
                            : annualBalance.carryForwardDays;

                    int carryForwardUsed =
                        annualBalance == null
                            ? 0
                            : annualBalance.carryForwardUsed;

                    if (
                        totalSharedUsed < 0
                        ||
                        carryForwardDays < 0
                        ||
                        carryForwardUsed < 0
                        ||
                        carryForwardUsed > carryForwardDays
                    ) {
                        con.rollback();
                        redirectError(
                            request,
                            response,
                            "invalidBalance"
                        );
                        return;
                    }

                    int currentYearUsed =
                        totalSharedUsed - carryForwardUsed;

                    if (currentYearUsed < 0) {
                        con.rollback();
                        redirectError(
                            request,
                            response,
                            "invalidBalance"
                        );
                        return;
                    }

                    Integer oldSharedEntitlement =
                        annualBalance == null
                            ? null
                            : annualBalance.entitlement;

                    if (newSharedEntitlement < currentYearUsed) {
                        con.rollback();
                        redirectError(
                            request,
                            response,
                            "quotaBelowUsed"
                        );
                        return;
                    }

                    int carryForwardRemaining =
                        carryForwardDays - carryForwardUsed;

                    int currentYearRemaining =
                        newSharedEntitlement - currentYearUsed;

                    int sharedRemaining =
                        carryForwardRemaining + currentYearRemaining;

                    // Simpan shared balance pada Cuti Tahunan sahaja.
                    upsertBalance(
                        con,
                        userId,
                        annualTypeId,
                        leaveYear,
                        newSharedEntitlement,
                        totalSharedUsed,
                        sharedRemaining,
                        carryForwardDays,
                        carryForwardUsed
                    );

                    // Cuti Kecemasan menggunakan shared balance Cuti Tahunan.
                    // Row ini dikekalkan 0 untuk compatibility.
                    upsertBalance(
                        con,
                        userId,
                        emergencyTypeId,
                        leaveYear,
                        0,
                        0,
                        0,
                        0,
                        0
                    );


                    // =========================================
                    // AUDIT CHANGE
                    // =========================================

                    if (
                        oldSharedEntitlement == null
                        ||
                        oldSharedEntitlement.intValue()
                        != newSharedEntitlement.intValue()
                    ) {


                        hasChanges =
                            true;


                        appendAuditChange(
                            auditChanges,
                            "Cuti Tahunan/Kecemasan: "
                                + (
                                    oldSharedEntitlement == null
                                        ? "-"
                                        : oldSharedEntitlement
                                )
                                + " → "
                                + newSharedEntitlement
                        );
                    }


                    continue;
                }


                // =============================================
                // NORMAL QUOTA LEAVE
                // =============================================

                String entitlementParam =
                    request.getParameter(
                        "entitlement_"
                        + type.id
                    );


                if (
                    entitlementParam == null
                ) {

                    continue;
                }


                hasAnyInput =
                    true;


                Integer newEntitlement =
                    parseNonNegativeInteger(
                        entitlementParam
                    );


                if (
                    newEntitlement == null
                ) {

                    con.rollback();

                    redirectError(
                        request,
                        response,
                        "invalidBalance"
                    );

                    return;
                }


                // =============================================
                // LOCK CURRENT BALANCE
                // =============================================

                BalanceInfo existing =
                    getBalanceForUpdate(
                        con,
                        userId,
                        type.id,
                        leaveYear
                    );


                int usedDays =
                    existing == null
                        ? 0
                        : existing.usedDays;


                Integer oldEntitlement =
                    existing == null
                        ? null
                        : existing.entitlement;


                // =============================================
                // QUOTA CANNOT BE LOWER THAN USED
                // =============================================

                if (
                    newEntitlement
                    <
                    usedDays
                ) {

                    con.rollback();

                    redirectError(
                        request,
                        response,
                        "quotaBelowUsed"
                    );

                    return;
                }


                int remainingDays =
                    newEntitlement
                    -
                    usedDays;


                // =============================================
                // SAVE
                // =============================================

                int carryForwardDays =
                    existing == null
                        ? 0
                        : existing.carryForwardDays;

                int carryForwardUsed =
                    existing == null
                        ? 0
                        : existing.carryForwardUsed;


                upsertBalance(
                    con,
                    userId,
                    type.id,
                    leaveYear,
                    newEntitlement,
                    usedDays,
                    remainingDays,
                    carryForwardDays,
                    carryForwardUsed
                );


                // =============================================
                // AUDIT CHANGE
                // =============================================

                if (
                    oldEntitlement == null
                    ||
                    oldEntitlement.intValue()
                    != newEntitlement.intValue()
                ) {


                    hasChanges =
                        true;


                    appendAuditChange(
                        auditChanges,
                        type.name
                            + ": "
                            + (
                                oldEntitlement == null
                                    ? "-"
                                    : oldEntitlement
                            )
                            + " → "
                            + newEntitlement
                    );
                }
            }


            // =================================================
            // NOTHING SUBMITTED
            // =================================================

            if (!hasAnyInput) {

                con.rollback();

                redirectError(
                    request,
                    response,
                    "invalidBalance"
                );

                return;
            }


            // =================================================
            // AUDIT TRAIL
            //
            // Only log if at least one entitlement changed.
            // =================================================

            if (hasChanges) {


                String description =
                    "Mengemaskini kuota cuti "
                    + targetUser.name
                    + " ("
                    + leaveYear
                    + ")";


                if (
                    auditChanges.length() > 0
                ) {

                    description +=
                        ": "
                        + auditChanges;
                }


                ActivityLogUtil.log(
                    con,
                    request,
                    "UPDATE_LEAVE_BALANCE",
                    description,
                    "USER",
                    userId
                );
            }


            // =================================================
            // COMMIT
            //
            // Balance update + Audit Trail are committed
            // together.
            // =================================================

            con.commit();


            response.sendRedirect(
                request.getContextPath()
                + "/staff?success=balanceUpdated"
            );


        } catch (
            SQLException e
        ) {


            if (con != null) {

                try {

                    con.rollback();

                } catch (
                    SQLException ignored
                ) {
                }
            }


            throw new ServletException(
                "Tidak dapat mengemas kini kuota cuti.",
                e
            );


        } finally {


            if (con != null) {

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
    // LOCK USER + GET INFO
    // =========================================================

    private UserInfo lockUser(
            Connection con,
            int userId)
            throws SQLException {


        String sql = """

            SELECT
                id,
                name,
                role

            FROM users

            WHERE id = ?

            FOR UPDATE

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
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

                    return null;
                }


                UserInfo user =
                    new UserInfo();


                rs.getInt(
				    "id"
				);


                user.name =
                    rs.getString(
                        "name"
                    );


                rs.getString(
				    "role"
				);


                return user;
            }
        }
    }


    // =========================================================
    // LOAD QUOTA LEAVE TYPES
    //
    // NO FIXED QUOTA:
    //
    // - Cuti Tanpa Rekod
    // - Cuti Tanpa Gaji
    // - Lain-lain
    // =========================================================

    private List<LeaveTypeInfo> loadQuotaLeaveTypes(
            Connection con)
            throws SQLException {


        List<LeaveTypeInfo> list =
            new ArrayList<>();


        String sql = """

            SELECT
                leave_type_id,
                leave_type_name

            FROM leave_types

            WHERE is_active = 1

              AND leave_type_name NOT IN
              (
                  'Cuti Tanpa Rekod',
                  'Cuti Tanpa Gaji',
                  'Lain-lain'
              )

            ORDER BY leave_type_id

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                );

            ResultSet rs =
                ps.executeQuery()
        ) {


            while (rs.next()) {


                LeaveTypeInfo info =
                    new LeaveTypeInfo();


                info.id =
                    rs.getInt(
                        "leave_type_id"
                    );


                info.name =
                    rs.getString(
                        "leave_type_name"
                    );


                list.add(
                    info
                );
            }
        }


        return list;
    }


    // =========================================================
    // GET BALANCE + LOCK
    // =========================================================

    private BalanceInfo getBalanceForUpdate(
            Connection con,
            int userId,
            int leaveTypeId,
            int leaveYear)
            throws SQLException {


        String sql = """

            SELECT
                balance_id,
                entitlement,
                used_days,
                remaining_days,
                carry_forward_days,
                carry_forward_used

            FROM leave_balances

            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?

            FOR UPDATE

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setInt(
                1,
                userId
            );


            ps.setInt(
                2,
                leaveTypeId
            );


            ps.setInt(
                3,
                leaveYear
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                if (!rs.next()) {

                    return null;
                }


                BalanceInfo balance =
                    new BalanceInfo();


                rs.getInt(
				    "balance_id"
				);


                balance.entitlement =
                    rs.getInt(
                        "entitlement"
                    );


                balance.usedDays =
                    rs.getInt(
                        "used_days"
                    );


                rs.getInt(
				    "remaining_days"
				);

                balance.carryForwardDays =
                    rs.getInt(
                        "carry_forward_days"
                    );

                balance.carryForwardUsed =
                    rs.getInt(
                        "carry_forward_used"
                    );


                return balance;
            }
        }
    }


    // =========================================================
    // UPSERT BALANCE
    //
    // Existing used_days is preserved.
    // Changing entitlement does NOT erase leave usage.
    // =========================================================

    private void upsertBalance(
            Connection con,
            int userId,
            int leaveTypeId,
            int leaveYear,
            int entitlement,
            int usedDays,
            int remainingDays,
            int carryForwardDays,
            int carryForwardUsed)
            throws SQLException {


        String sql = """

            INSERT INTO leave_balances
            (
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                used_days,
                remaining_days,
                carry_forward_days,
                carry_forward_used
            )

            VALUES
            (
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                ?
            )

            ON DUPLICATE KEY UPDATE

                entitlement =
                    VALUES(entitlement),

                used_days =
                    VALUES(used_days),

                remaining_days =
                    VALUES(remaining_days),

                carry_forward_days =
                    VALUES(carry_forward_days),

                carry_forward_used =
                    VALUES(carry_forward_used)

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, leaveYear);
            ps.setInt(4, entitlement);
            ps.setInt(5, usedDays);
            ps.setInt(6, remainingDays);
            ps.setInt(7, carryForwardDays);
            ps.setInt(8, carryForwardUsed);


            ps.executeUpdate();
        }
    }


    // =========================================================
    // APPEND AUDIT CHANGE
    // =========================================================

    private void appendAuditChange(
            StringBuilder builder,
            String value) {


        if (
            builder == null
            ||
            value == null
            ||
            value.isBlank()
        ) {

            return;
        }


        if (
            builder.length() > 0
        ) {

            builder.append(
                "; "
            );
        }


        builder.append(
            value.trim()
        );
    }


    // =========================================================
    // FIRST NON-BLANK
    // =========================================================

    private String firstNonBlank(
            String... values) {


        if (values == null) {

            return null;
        }


        for (
            String value :
            values
        ) {


            if (
                value != null
                &&
                !value.isBlank()
            ) {

                return value.trim();
            }
        }


        return null;
    }


    // =========================================================
    // HR ONLY
    // =========================================================

    private boolean isHR(
            HttpServletRequest request) {


        HttpSession session =
            request.getSession(
                false
            );


        if (
            session == null
            ||
            session.getAttribute(
                "userId"
            ) == null
        ) {

            return false;
        }


        Object role =
            session.getAttribute(
                "userRole"
            );


        return
            role != null
            &&
            "HR".equalsIgnoreCase(
                role
                    .toString()
                    .trim()
            );
    }


    // =========================================================
    // POSITIVE INTEGER
    // =========================================================

    private Integer parsePositiveInteger(
            String value) {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            return null;
        }


        try {


            int number =
                Integer.parseInt(
                    value.trim()
                );


            return
                number > 0
                    ? number
                    : null;


        } catch (
            NumberFormatException e
        ) {

            return null;
        }
    }


    // =========================================================
    // NON-NEGATIVE INTEGER
    // =========================================================

    private Integer parseNonNegativeInteger(
            String value) {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            return null;
        }


        try {


            int number =
                Integer.parseInt(
                    value.trim()
                );


            return
                number >= 0
                    ? number
                    : null;


        } catch (
            NumberFormatException e
        ) {

            return null;
        }
    }


    // =========================================================
    // ERROR REDIRECT
    // =========================================================

    private void redirectError(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws IOException {


        response.sendRedirect(
            request.getContextPath()
            + "/staff?error="
            + error
        );
    }


    // =========================================================
    // INNER CLASS - USER
    // =========================================================

    private static class UserInfo {

        String name;
    }


    // =========================================================
    // INNER CLASS - LEAVE TYPE
    // =========================================================

    private static class LeaveTypeInfo {

        int id;

        String name;
    }


    // =========================================================
    // INNER CLASS - BALANCE
    // =========================================================

    private static class BalanceInfo {

        int entitlement;

        int usedDays;

        int carryForwardDays;

        int carryForwardUsed;

    }
}
