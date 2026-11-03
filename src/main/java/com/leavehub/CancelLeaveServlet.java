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

import java.time.LocalDate;


@WebServlet("/cancel")
public class CancelLeaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // LEAVE TYPE NAMES
    // =========================================================

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


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {


        req.setCharacterEncoding(
            "UTF-8"
        );


        // =====================================================
        // LOGIN
        // =====================================================

        HttpSession session =
            req.getSession(false);


        if (
            session == null ||
            session.getAttribute(
                "userId"
            ) == null
        ) {

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
            getUserId(
                session
            );


        if (
            userId == null
        ) {

            session.invalidate();

            resp.sendRedirect(
                req.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // APPLICATION ID
        // =====================================================

        Integer applicationId =
            parsePositiveInteger(
                req.getParameter(
                    "id"
                )
            );


        if (
            applicationId == null
        ) {

            redirectError(
                req,
                resp,
                "invalid"
            );

            return;
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
            // LOCK APPLICATION
            //
            // application_no digunakan untuk Audit Trail.
            // =================================================

            String applicationSql = """

                SELECT
                    la.id,
                    la.application_no,
                    la.user_id,
                    la.leave_type_id,
                    la.duration,
                    la.start_date,
                    la.status,

                    COALESCE(
                        lt.leave_type_name,
                        la.leave_type
                    ) AS leave_type_name,
                    la.carry_forward_days_used,
                    la.current_year_days_used

                FROM leave_applications la

                LEFT JOIN leave_types lt
                    ON lt.leave_type_id =
                       la.leave_type_id

                WHERE la.id = ?
                  AND la.user_id = ?

                FOR UPDATE

            """;


            Integer leaveTypeId;

            String leaveTypeName;

            String applicationNo;

            int duration;

            LocalDate startDate;

            String status;

            int carryForwardDaysUsed = 0;

            int currentYearDaysUsed = 0;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        applicationSql
                    )
            ) {


                ps.setInt(
                    1,
                    applicationId
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
                            req,
                            resp,
                            "notFound"
                        );

                        return;
                    }


                    // =========================================
                    // APPLICATION NUMBER
                    // =========================================

                    applicationNo =
                        rs.getString(
                            "application_no"
                        );


                    int leaveTypeValue =
                        rs.getInt(
                            "leave_type_id"
                        );


                    if (
                        rs.wasNull()
                    ) {

                        leaveTypeId =
                            null;

                    } else {

                        leaveTypeId =
                            leaveTypeValue;
                    }


                    leaveTypeName =
                        rs.getString(
                            "leave_type_name"
                        );


                    duration =
                        rs.getInt(
                            "duration"
                        );


                    java.sql.Date sqlStartDate =
                        rs.getDate(
                            "start_date"
                        );


                    if (
                        sqlStartDate == null
                    ) {

                        throw new SQLException(
                            "Tarikh mula permohonan tidak ditemui."
                        );
                    }


                    startDate =
                        sqlStartDate
                            .toLocalDate();


                    status =
                        rs.getString(
                            "status"
                        );

                    carryForwardDaysUsed =
                        rs.getInt(
                            "carry_forward_days_used"
                        );

                    currentYearDaysUsed =
                        rs.getInt(
                            "current_year_days_used"
                        );
                }
            }


            // =================================================
            // CHECK LEAVE START DATE
            //
            // Staf hanya boleh membatalkan permohonan SEBELUM
            // tarikh cuti bermula.
            //
            // Contoh:
            //
            // Hari ini : 27/09/2026
            //
            // Cuti mula 28/09/2026
            // -> BOLEH batal
            //
            // Cuti mula 27/09/2026
            // -> TIDAK BOLEH batal
            //
            // Cuti mula 26/09/2026
            // -> TIDAK BOLEH batal
            //
            // Semakan ini dibuat SEBELUM sebarang pemulangan
            // baki cuti.
            // =================================================

            LocalDate today =
                LocalDate.now();


            if (
                !today.isBefore(
                    startDate
                )
            ) {

                con.rollback();

                redirectError(
                    req,
                    resp,
                    "leaveAlreadyStarted"
                );

                return;
            }


            // =================================================
            // CAN CANCEL?
            // =================================================

            boolean pending =
                isPendingStatus(
                    status
                );


            boolean approved =
                "APPROVED"
                    .equalsIgnoreCase(
                        status
                    );


            if (
                !pending &&
                !approved
            ) {

                con.rollback();

                redirectError(
                    req,
                    resp,
                    "cannotCancel"
                );

                return;
            }


            // =================================================
            // APPROVED APPLICATION
            //
            // Jika permohonan sudah diluluskan dan tarikh cuti
            // BELUM bermula, baki/penggunaan cuti dipulangkan.
            // =================================================

            if (
                approved
            ) {


                if (
                    leaveTypeId == null ||
                    leaveTypeName == null
                ) {

                    con.rollback();

                    redirectError(
                        req,
                        resp,
                        "missingLeaveType"
                    );

                    return;
                }


                if (
                    duration <= 0
                ) {

                    con.rollback();

                    redirectError(
                        req,
                        resp,
                        "invalidDuration"
                    );

                    return;
                }


                int leaveYear =
                    startDate.getYear();


                // =============================================
                // TAHUNAN / KECEMASAN
                // =============================================

                if (
                    isSharedLeave(
                        leaveTypeName
                    )
                ) {

                    restoreSharedLeaveBalance(
                        con,
                        userId,
                        leaveTypeId,
                        leaveYear,
                        duration,
                        carryForwardDaysUsed,
                        currentYearDaysUsed
                    );
                }


                // =============================================
                // NO-QUOTA LEAVE
                //
                // - Cuti Tanpa Rekod
                // - Cuti Tanpa Gaji
                // - Lain-lain
                // =============================================

                else if (
                    isNoBalanceRestrictionLeave(
                        leaveTypeName
                    )
                ) {

                    restoreUnrestrictedLeaveUsage(
                        con,
                        userId,
                        leaveTypeId,
                        leaveYear,
                        duration
                    );
                }


                // =============================================
                // NORMAL FINITE LEAVE
                // =============================================

                else {

                    restoreNormalLeaveBalance(
                        con,
                        userId,
                        leaveTypeId,
                        leaveYear,
                        duration
                    );
                }
            }


            // =================================================
            // CANCELLATION REMARK
            // =================================================

            String cancellationRemark =
                "Dibatalkan oleh staf.";


            // =================================================
            // UPDATE APPLICATION
            // =================================================

            String updateApplicationSql = """

                UPDATE leave_applications

                SET
                    status = 'CANCELLED',

                    remarks =
                        CASE

                            WHEN remarks IS NULL
                                 OR TRIM(remarks) = ''

                            THEN ?

                            ELSE CONCAT(
                                remarks,
                                CHAR(10),
                                ?
                            )

                        END,

                    reviewed_at = CURRENT_TIMESTAMP,
                    reviewed_by = NULL,
                    carry_forward_days_used = 0,
                    current_year_days_used = 0

                WHERE id = ?
                  AND user_id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateApplicationSql
                    )
            ) {


                ps.setString(
                    1,
                    cancellationRemark
                );


                ps.setString(
                    2,
                    cancellationRemark
                );


                ps.setInt(
                    3,
                    applicationId
                );


                ps.setInt(
                    4,
                    userId
                );


                int affected =
                    ps.executeUpdate();


                if (
                    affected != 1
                ) {

                    throw new SQLException(
                        "Status permohonan tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // CANCEL PENDING APPROVALS ONLY
            // =================================================

            String cancelPendingApprovalsSql = """

                UPDATE leave_approvals

                SET
                    decision = 'CANCELLED',
                    remarks = ?,
                    decision_date = CURRENT_TIMESTAMP

                WHERE leave_id = ?
                  AND decision = 'PENDING'

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        cancelPendingApprovalsSql
                    )
            ) {


                ps.setString(
                    1,
                    cancellationRemark
                );


                ps.setInt(
                    2,
                    applicationId
                );


                ps.executeUpdate();
            }


            // =================================================
            // AUDIT TRAIL
            // =================================================

            String auditDescription;


            if (
                approved
            ) {

                auditDescription =
                    "Membatalkan permohonan cuti "
                    + applicationNo
                    + " yang telah diluluskan"
                    + " dan memulangkan "
                    + duration
                    + " hari cuti";


            } else {

                auditDescription =
                    "Membatalkan permohonan cuti "
                    + applicationNo;
            }


            ActivityLogUtil.log(
                con,
                req,
                "CANCEL_LEAVE",
                auditDescription,
                "LEAVE_APPLICATION",
                applicationId
            );


            // =================================================
            // COMMIT
            // =================================================

            con.commit();


            resp.sendRedirect(
                req.getContextPath()
                + "/applications?success=cancelled"
            );


        } catch (
            BalanceNotFoundException e
        ) {


            rollbackQuietly(
                con
            );


            resp.sendRedirect(
                req.getContextPath()
                + "/applications?error=balanceNotFound"
            );


        } catch (
            InvalidUsedBalanceException e
        ) {


            rollbackQuietly(
                con
            );


            resp.sendRedirect(
                req.getContextPath()
                + "/applications?error=invalidUsedBalance"
            );


        } catch (
            Exception e
        ) {


            rollbackQuietly(
                con
            );


            throw new ServletException(
                "Tidak dapat membatalkan permohonan cuti.",
                e
            );


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
    // SHARED LEAVE
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
    // NO BALANCE RESTRICTION
    //
    // - Cuti Tanpa Rekod
    // - Cuti Tanpa Gaji
    // - Lain-lain
    // =========================================================

    private boolean isNoBalanceRestrictionLeave(
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
    // RESTORE SHARED LEAVE
    // =========================================================

    private void restoreSharedLeaveBalance(
            Connection con,
            int userId,
            int selectedLeaveTypeId,
            int leaveYear,
            int duration,
            int carryForwardDaysUsedByApplication,
            int currentYearDaysUsedByApplication)
            throws SQLException,
                   BalanceNotFoundException,
                   InvalidUsedBalanceException {

        // =====================================================
        // VALIDATE APPLICATION USAGE
        // =====================================================

        if (duration <= 0
                || carryForwardDaysUsedByApplication < 0
                || currentYearDaysUsedByApplication < 0
                || carryForwardDaysUsedByApplication
                   + currentYearDaysUsedByApplication != duration) {

            throw new InvalidUsedBalanceException();
        }


        // =====================================================
        // SHARED BALANCE
        //
        // Cuti Tahunan (leave_type_id = 1) ialah SATU-SATUNYA
        // row yang menyimpan baki untuk:
        //
        // - Cuti Tahunan
        // - Cuti Kecemasan
        //
        // Cuti Kecemasan tidak mempunyai baki sendiri.
        // =====================================================

        final int ANNUAL_LEAVE_ID = 1;


        // =====================================================
        // LOCK ANNUAL LEAVE BALANCE
        // =====================================================

        String selectSql = """
            SELECT
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
            FROM leave_balances
            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?
            FOR UPDATE
            """;


        int entitlement;
        int carryForwardDays;
        int carryForwardUsed;
        int usedDays;


        try (PreparedStatement ps = con.prepareStatement(selectSql)) {

            ps.setInt(1, userId);
            ps.setInt(2, ANNUAL_LEAVE_ID);
            ps.setInt(3, leaveYear);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    throw new BalanceNotFoundException();
                }

                entitlement =
                    rs.getInt("entitlement");

                carryForwardDays =
                    rs.getInt("carry_forward_days");

                carryForwardUsed =
                    rs.getInt("carry_forward_used");

                usedDays =
                    rs.getInt("used_days");
            }
        }


        // =====================================================
        // VALIDATE DATABASE BALANCE
        // =====================================================

        if (entitlement < 0
                || carryForwardDays < 0
                || carryForwardUsed < 0
                || usedDays < 0
                || carryForwardUsed > carryForwardDays) {

            throw new SQLException(
                "Rekod baki Cuti Tahunan tidak sah."
            );
        }


        // =====================================================
        // VALIDATE USAGE BEFORE RESTORE
        // =====================================================

        if (usedDays < duration) {

            throw new InvalidUsedBalanceException();
        }

        if (carryForwardUsed
                < carryForwardDaysUsedByApplication) {

            throw new InvalidUsedBalanceException();
        }


        // =====================================================
        // RESTORE USAGE
        // =====================================================

        int newCarryForwardUsed =
            carryForwardUsed
            - carryForwardDaysUsedByApplication;


        int newUsedDays =
            usedDays
            - duration;


        if (newCarryForwardUsed < 0
                || newUsedDays < 0) {

            throw new InvalidUsedBalanceException();
        }


        // =====================================================
        // CALCULATE CURRENT YEAR USAGE
        //
        // used_days menyimpan JUMLAH penggunaan:
        //
        // carry forward + current year
        // =====================================================

        int newCurrentYearUsed =
            newUsedDays
            - newCarryForwardUsed;


        if (newCurrentYearUsed < 0
                || newCurrentYearUsed > entitlement) {

            throw new InvalidUsedBalanceException();
        }


        // =====================================================
        // CALCULATE REMAINING BALANCE
        // =====================================================

        int carryForwardRemaining =
            carryForwardDays
            - newCarryForwardUsed;


        int currentYearRemaining =
            entitlement
            - newCurrentYearUsed;


        int newRemainingDays =
            carryForwardRemaining
            + currentYearRemaining;


        // =====================================================
        // UPDATE SHARED BALANCE
        //
        // HANYA row Cuti Tahunan dikemas kini.
        // =====================================================

        String updateSql = """
            UPDATE leave_balances
            SET
                carry_forward_used = ?,
                used_days = ?,
                remaining_days = ?
            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?
            """;


        try (PreparedStatement ps = con.prepareStatement(updateSql)) {

            ps.setInt(
                1,
                newCarryForwardUsed
            );

            ps.setInt(
                2,
                newUsedDays
            );

            ps.setInt(
                3,
                newRemainingDays
            );

            ps.setInt(
                4,
                userId
            );

            ps.setInt(
                5,
                ANNUAL_LEAVE_ID
            );

            ps.setInt(
                6,
                leaveYear
            );


            int affected =
                ps.executeUpdate();


            if (affected != 1) {

                throw new SQLException(
                    "Baki cuti bersama tidak dapat dipulangkan."
                );
            }
        }


        // =====================================================
        // ENSURE EMERGENCY BALANCE REMAINS ZERO
        //
        // Row Cuti Kecemasan boleh kekal dalam database untuk
        // compatibility, tetapi ia tidak menyimpan baki.
        // =====================================================

        String resetEmergencySql = """
            UPDATE leave_balances
            SET
                entitlement = 0,
                carry_forward_days = 0,
                carry_forward_used = 0,
                used_days = 0,
                remaining_days = 0
            WHERE user_id = ?
              AND leave_type_id = 2
              AND leave_year = ?
            """;


        try (PreparedStatement ps =
                con.prepareStatement(resetEmergencySql)) {

            ps.setInt(
                1,
                userId
            );

            ps.setInt(
                2,
                leaveYear
            );

            ps.executeUpdate();
        }
    }


    // =========================================================
    // RESTORE NO-QUOTA USAGE
    // =========================================================

    private void restoreUnrestrictedLeaveUsage(
            Connection con,
            int userId,
            int leaveTypeId,
            int leaveYear,
            int duration)
            throws SQLException,
                   InvalidUsedBalanceException {


        String selectSql = """

            SELECT
                balance_id,
                entitlement,
                used_days

            FROM leave_balances

            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?

            FOR UPDATE

        """;


        Integer entitlement =
            null;


        Integer usedDays =
            null;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    selectSql
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


                if (
                    rs.next()
                ) {

                    entitlement =
                        rs.getInt(
                            "entitlement"
                        );


                    usedDays =
                        rs.getInt(
                            "used_days"
                        );
                }
            }
        }


        // No balance row.
        // Cancellation can still continue.

        if (
            entitlement == null
            ||
            usedDays == null
        ) {

            return;
        }


        if (
            entitlement < 0
            ||
            usedDays < 0
        ) {

            throw new SQLException(
                "Rekod penggunaan cuti tidak sah."
            );
        }


        if (
            usedDays <
            duration
        ) {

            throw new InvalidUsedBalanceException();
        }


        int newUsedDays =
            usedDays
            -
            duration;


        int newRemainingDays =
            Math.max(
                entitlement
                -
                newUsedDays,
                0
            );


        String updateSql = """

            UPDATE leave_balances

            SET
                used_days = ?,
                remaining_days = ?

            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    updateSql
                )
        ) {


            ps.setInt(
                1,
                newUsedDays
            );


            ps.setInt(
                2,
                newRemainingDays
            );


            ps.setInt(
                3,
                userId
            );


            ps.setInt(
                4,
                leaveTypeId
            );


            ps.setInt(
                5,
                leaveYear
            );


            int affected =
                ps.executeUpdate();


            if (
                affected != 1
            ) {

                throw new SQLException(
                    "Rekod penggunaan cuti tidak dapat dipulangkan."
                );
            }
        }
    }


    // =========================================================
    // RESTORE NORMAL LEAVE BALANCE
    // =========================================================

    private void restoreNormalLeaveBalance(
            Connection con,
            int userId,
            int leaveTypeId,
            int leaveYear,
            int duration)
            throws SQLException,
                   BalanceNotFoundException,
                   InvalidUsedBalanceException {


        String selectSql = """

            SELECT
                balance_id,
                entitlement,
                used_days,
                remaining_days

            FROM leave_balances

            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?

            FOR UPDATE

        """;


        int entitlement;

        int usedDays;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    selectSql
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


                if (
                    !rs.next()
                ) {

                    throw new BalanceNotFoundException();
                }


                entitlement =
                    rs.getInt(
                        "entitlement"
                    );


                usedDays =
                    rs.getInt(
                        "used_days"
                    );


                if (
                    entitlement < 0
                    ||
                    usedDays < 0
                ) {

                    throw new SQLException(
                        "Rekod baki cuti mengandungi nilai yang tidak sah."
                    );
                }
            }
        }


        if (
            usedDays <
            duration
        ) {

            throw new InvalidUsedBalanceException();
        }


        int newUsedDays =
            usedDays
            -
            duration;


        int newRemainingDays =
            entitlement
            -
            newUsedDays;


        if (
            newRemainingDays < 0
        ) {

            newRemainingDays =
                0;
        }


        if (
            newRemainingDays >
            entitlement
        ) {

            newRemainingDays =
                entitlement;
        }


        String updateSql = """

            UPDATE leave_balances

            SET
                used_days = ?,
                remaining_days = ?

            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    updateSql
                )
        ) {


            ps.setInt(
                1,
                newUsedDays
            );


            ps.setInt(
                2,
                newRemainingDays
            );


            ps.setInt(
                3,
                userId
            );


            ps.setInt(
                4,
                leaveTypeId
            );


            ps.setInt(
                5,
                leaveYear
            );


            int affected =
                ps.executeUpdate();


            if (
                affected != 1
            ) {

                throw new SQLException(
                    "Baki cuti pengguna tidak dapat dipulangkan."
                );
            }
        }
    }


    // =========================================================
    // PENDING STATUS
    // =========================================================

    private boolean isPendingStatus(
            String status) {


        if (
            status == null
        ) {

            return false;
        }


        return
            "PENDING_MANAGEMENT"
                .equalsIgnoreCase(
                    status
                )
            ||
            "PENDING_HEAD"
                .equalsIgnoreCase(
                    status
                )
            ||
            "PENDING_ADMIN"
                .equalsIgnoreCase(
                    status
                )
            ||
            "PENDING"
                .equalsIgnoreCase(
                    status
                );
    }


    // =========================================================
    // USER ID
    // =========================================================

    private Integer getUserId(
            HttpSession session) {


        try {


            int value =
                Integer.parseInt(
                    session
                        .getAttribute(
                            "userId"
                        )
                        .toString()
                );


            return
                value > 0
                    ? value
                    : null;


        } catch (
            Exception e
        ) {

            return null;
        }
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
    // REDIRECT ERROR
    // =========================================================

    private void redirectError(
            HttpServletRequest req,
            HttpServletResponse resp,
            String error)
            throws IOException {


        resp.sendRedirect(
            req.getContextPath()
            + "/applications?error="
            + error
        );
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
    // EXCEPTIONS
    // =========================================================

    private static class BalanceNotFoundException
            extends Exception {


        private static final long serialVersionUID =
            1L;
    }


    private static class InvalidUsedBalanceException
            extends Exception {


        private static final long serialVersionUID =
            1L;
    }
}