package com.leavehub;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


/**
 * Utility untuk mengurus baki bersama:
 *
 * Cuti Tahunan + Cuti Kecemasan.
 *
 * STRUKTUR FINAL:
 *
 * 1. Cuti Tahunan = MASTER BALANCE
 * 2. Cuti Kecemasan = menggunakan baki Cuti Tahunan
 * 3. Row Cuti Kecemasan TIDAK menyimpan salinan baki.
 * 4. Carry Forward disimpan pada row Cuti Tahunan sahaja.
 * 5. Carry Forward digunakan dahulu sebelum entitlement tahun semasa.
 */
public final class LeaveCarryForwardUtil {

    public static final int ANNUAL_LEAVE_ID = 1;
    public static final int EMERGENCY_LEAVE_ID = 2;

    public static final int DEFAULT_SHARED_ENTITLEMENT = 30;


    private LeaveCarryForwardUtil() {
        // Utility class
    }


    // =========================================================
    // ENSURE SHARED BALANCE
    // =========================================================

    /**
     * Memastikan baki Cuti Tahunan / Cuti Kecemasan
     * untuk sesuatu tahun telah diwujudkan.
     *
     * Annual = master.
     * Emergency = placeholder sahaja.
     */
    public static void ensureSharedBalance(
            Connection conn,
            int userId,
            int year,
            int newEntitlement) throws SQLException {

        validate(
            conn,
            userId,
            year,
            newEntitlement
        );


        // =====================================================
        // CHECK ANNUAL MASTER
        // =====================================================

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        // =====================================================
        // JIKA ANNUAL BELUM WUJUD
        // =====================================================

        if (annual == null) {

            int previousYear =
                year - 1;


            int carryForward =
                getPreviousRemainingBalance(
                    conn,
                    userId,
                    previousYear
                );


            int entitlement =
                newEntitlement;


            int usedDays = 0;

            int carryForwardUsed = 0;


            int remainingDays =
                entitlement
                +
                carryForward;


            insertBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year,
                entitlement,
                carryForward,
                carryForwardUsed,
                usedDays,
                remainingDays
            );

        } else {

            /*
             * Annual sudah wujud.
             *
             * Jangan:
             * - reset used_days
             * - reset carry_forward
             * - reset carry_forward_used
             *
             * Ini penting supaya ensureSharedBalance()
             * selamat dipanggil banyak kali.
             */

            normalizeAnnualBalance(
                conn,
                annual
            );
        }


        // =====================================================
        // ENSURE EMERGENCY PLACEHOLDER
        // =====================================================

        ensureEmergencyPlaceholder(
            conn,
            userId,
            year
        );
    }


    // =========================================================
    // OVERLOAD - DEFAULT 30 DAYS
    // =========================================================

    public static void ensureSharedBalance(
            Connection conn,
            int userId,
            int year) throws SQLException {

        ensureSharedBalance(
            conn,
            userId,
            year,
            DEFAULT_SHARED_ENTITLEMENT
        );
    }


    // =========================================================
    // GET AVAILABLE SHARED BALANCE
    // =========================================================

    public static int getAvailableSharedBalance(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.remainingDays
        );
    }


    // =========================================================
    // GET ENTITLEMENT
    // =========================================================

    public static int getEntitlement(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.entitlement
        );
    }


    // =========================================================
    // GET CARRY FORWARD
    // =========================================================

    public static int getCarryForward(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.carryForwardDays
        );
    }


    // =========================================================
    // GET CARRY FORWARD USED
    // =========================================================

    public static int getCarryForwardUsed(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.carryForwardUsed
        );
    }


    // =========================================================
    // GET TOTAL USED
    // =========================================================

    public static int getTotalUsed(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.usedDays
        );
    }


    // =========================================================
    // GET CURRENT YEAR USED
    // =========================================================

    /**
     * used_days pada master Annual menyimpan jumlah penggunaan:
     *
     * CF Used + Current Year Used
     *
     * Maka:
     *
     * Current Year Used =
     * Total Used - CF Used
     */
    public static int getCurrentYearUsed(
            Connection conn,
            int userId,
            int year) throws SQLException {

        BalanceInfo annual =
            getBalance(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            return 0;
        }


        return Math.max(
            0,
            annual.usedDays
            -
            annual.carryForwardUsed
        );
    }


    // =========================================================
    // DEDUCT SHARED BALANCE
    // =========================================================

    /**
     * Digunakan apabila Management APPROVE permohonan
     * Cuti Tahunan atau Cuti Kecemasan.
     *
     * RULE:
     *
     * Carry Forward digunakan dahulu.
     *
     * Contoh:
     *
     * CF = 5
     * Entitlement = 30
     *
     * Mohon 3 hari:
     *
     * CF Used = 3
     * Current Year Used = 0
     *
     * Mohon lagi 4 hari:
     *
     * CF Used = 2
     * Current Year Used = 2
     *
     * Method return Allocation supaya ApprovalServlet
     * boleh simpan pecahan penggunaan dalam
     * leave_applications.
     */
    public static Allocation deductSharedBalance(
            Connection conn,
            int userId,
            int year,
            int requestedDays) throws SQLException {

        if (requestedDays <= 0) {
            throw new SQLException(
                "Jumlah hari cuti mestilah lebih daripada 0."
            );
        }


        ensureSharedBalance(
            conn,
            userId,
            year,
            DEFAULT_SHARED_ENTITLEMENT
        );


        BalanceInfo annual =
            getBalanceForUpdate(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            throw new SQLException(
                "Rekod baki Cuti Tahunan tidak dijumpai."
            );
        }


        if (
            annual.remainingDays
            <
            requestedDays
        ) {

            throw new SQLException(
                "Baki cuti tidak mencukupi."
            );
        }


        // =====================================================
        // AVAILABLE CARRY FORWARD
        // =====================================================

        int carryForwardAvailable =
            Math.max(
                0,
                annual.carryForwardDays
                -
                annual.carryForwardUsed
            );


        // =====================================================
        // USE CF FIRST
        // =====================================================

        int carryForwardDaysUsed =
            Math.min(
                requestedDays,
                carryForwardAvailable
            );


        int currentYearDaysUsed =
            requestedDays
            -
            carryForwardDaysUsed;


        // =====================================================
        // NEW VALUES
        // =====================================================

        int newCarryForwardUsed =
            annual.carryForwardUsed
            +
            carryForwardDaysUsed;


        int newUsedDays =
            annual.usedDays
            +
            requestedDays;


        int newRemaining =
            annual.remainingDays
            -
            requestedDays;


        updateAnnualMaster(
            conn,
            annual.balanceId,
            annual.entitlement,
            annual.carryForwardDays,
            newCarryForwardUsed,
            newUsedDays,
            newRemaining
        );


        // Emergency mesti kekal placeholder.
        ensureEmergencyPlaceholder(
            conn,
            userId,
            year
        );


        return new Allocation(
            carryForwardDaysUsed,
            currentYearDaysUsed
        );
    }


    // =========================================================
    // RESTORE SHARED BALANCE
    // =========================================================

    /**
     * Digunakan apabila:
     *
     * APPROVED -> REJECTED
     *
     * atau
     *
     * APPROVED -> CANCELLED
     *
     * Pecahan hari MESTI datang daripada
     * leave_applications:
     *
     * carry_forward_days_used
     * current_year_days_used
     */
    public static void restoreSharedBalance(
            Connection conn,
            int userId,
            int year,
            int carryForwardDaysUsed,
            int currentYearDaysUsed)
            throws SQLException {

        carryForwardDaysUsed =
            Math.max(
                0,
                carryForwardDaysUsed
            );


        currentYearDaysUsed =
            Math.max(
                0,
                currentYearDaysUsed
            );


        int totalRestore =
            carryForwardDaysUsed
            +
            currentYearDaysUsed;


        if (totalRestore <= 0) {
            return;
        }


        BalanceInfo annual =
            getBalanceForUpdate(
                conn,
                userId,
                ANNUAL_LEAVE_ID,
                year
            );


        if (annual == null) {
            throw new SQLException(
                "Rekod baki Cuti Tahunan tidak dijumpai."
            );
        }


        // =====================================================
        // RESTORE CF USED
        // =====================================================

        int newCarryForwardUsed =
            Math.max(
                0,
                annual.carryForwardUsed
                -
                carryForwardDaysUsed
            );


        // =====================================================
        // RESTORE TOTAL USED
        // =====================================================

        int newUsedDays =
            Math.max(
                0,
                annual.usedDays
                -
                totalRestore
            );


        // =====================================================
        // RECALCULATE REMAINING
        // =====================================================

        int currentYearUsed =
            Math.max(
                0,
                newUsedDays
                -
                newCarryForwardUsed
            );


        int carryForwardRemaining =
            Math.max(
                0,
                annual.carryForwardDays
                -
                newCarryForwardUsed
            );


        int currentYearRemaining =
            Math.max(
                0,
                annual.entitlement
                -
                currentYearUsed
            );


        int newRemaining =
            carryForwardRemaining
            +
            currentYearRemaining;


        updateAnnualMaster(
            conn,
            annual.balanceId,
            annual.entitlement,
            annual.carryForwardDays,
            newCarryForwardUsed,
            newUsedDays,
            newRemaining
        );


        ensureEmergencyPlaceholder(
            conn,
            userId,
            year
        );
    }


    // =========================================================
    // NORMALIZE ANNUAL MASTER
    // =========================================================

    private static void normalizeAnnualBalance(
            Connection conn,
            BalanceInfo annual)
            throws SQLException {

        int entitlement =
            Math.max(
                0,
                annual.entitlement
            );


        int carryForward =
            Math.max(
                0,
                annual.carryForwardDays
            );


        int carryForwardUsed =
            Math.max(
                0,
                Math.min(
                    annual.carryForwardUsed,
                    carryForward
                )
            );


        int usedDays =
            Math.max(
                0,
                annual.usedDays
            );


        /*
         * Total used tidak boleh kurang daripada CF used.
         */
        if (
            usedDays
            <
            carryForwardUsed
        ) {

            usedDays =
                carryForwardUsed;
        }


        int currentYearUsed =
            Math.max(
                0,
                usedDays
                -
                carryForwardUsed
            );


        int carryForwardRemaining =
            Math.max(
                0,
                carryForward
                -
                carryForwardUsed
            );


        int currentYearRemaining =
            Math.max(
                0,
                entitlement
                -
                currentYearUsed
            );


        int remaining =
            carryForwardRemaining
            +
            currentYearRemaining;


        updateAnnualMaster(
            conn,
            annual.balanceId,
            entitlement,
            carryForward,
            carryForwardUsed,
            usedDays,
            remaining
        );
    }


    // =========================================================
    // PREVIOUS YEAR REMAINING
    // =========================================================

    /**
     * Hanya Annual master digunakan untuk rollover.
     *
     * Emergency TIDAK dikira supaya tidak berlaku
     * double carry forward.
     */
    private static int getPreviousRemainingBalance(
            Connection conn,
            int userId,
            int previousYear)
            throws SQLException {

        if (previousYear <= 0) {
            return 0;
        }


        /*
         * POLISI CARRY FORWARD FINAL
         *
         * Carry Forward lama hanya sah untuk SATU tahun.
         * Baki CF yang tidak digunakan pada hujung tahun akan LUPUT.
         *
         * Hanya baki daripada entitlement tahun semasa dibawa ke
         * tahun berikutnya sebagai Carry Forward baharu.
         *
         * currentYearUsed =
         *     used_days - carry_forward_used
         *
         * nextYearCarryForward =
         *     entitlement - currentYearUsed
         *
         * Contoh 2027:
         * entitlement = 30
         * CF dari 2026 = 5
         * CF used = 3
         * total used = 3
         *
         * currentYearUsed = 0
         * baki entitlement 2027 = 30
         *
         * Baki CF lama 2 hari LUPUT.
         * CF ke 2028 = 30 hari.
         */


        String sql = """
            SELECT
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days
            FROM leave_balances
            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?
            LIMIT 1
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);
            ps.setInt(2, ANNUAL_LEAVE_ID);
            ps.setInt(3, previousYear);


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (rs.next()) {

                    int entitlement =
                        Math.max(
                            0,
                            rs.getInt("entitlement")
                        );


                    int carryForwardDays =
                        Math.max(
                            0,
                            rs.getInt("carry_forward_days")
                        );


                    int carryForwardUsed =
                        Math.max(
                            0,
                            Math.min(
                                rs.getInt("carry_forward_used"),
                                carryForwardDays
                            )
                        );


                    int totalUsed =
                        Math.max(
                            0,
                            rs.getInt("used_days")
                        );


                    int currentYearUsed =
                        Math.max(
                            0,
                            totalUsed - carryForwardUsed
                        );


                    // Bawa hanya baki entitlement tahun sebelumnya.
                    // Baki Carry Forward lama tidak dibawa lagi.
                    return Math.max(
                        0,
                        entitlement - currentYearUsed
                    );
                }
            }
        }


        return 0;
    }


    // =========================================================
    // ENSURE EMERGENCY PLACEHOLDER
    // =========================================================

    /**
     * Emergency tidak mempunyai baki sendiri.
     *
     * Row ini dikekalkan untuk compatibility dengan
     * struktur leave_balances / paparan sedia ada.
     */
    private static void ensureEmergencyPlaceholder(
            Connection conn,
            int userId,
            int year)
            throws SQLException {

        String sql = """
            INSERT INTO leave_balances
            (
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
            )
            VALUES
            (
                ?,
                ?,
                ?,
                0,
                0,
                0,
                0,
                0
            )

            ON DUPLICATE KEY UPDATE

                entitlement = 0,
                carry_forward_days = 0,
                carry_forward_used = 0,
                used_days = 0,
                remaining_days = 0
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                userId
            );

            ps.setInt(
                2,
                EMERGENCY_LEAVE_ID
            );

            ps.setInt(
                3,
                year
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // GET BALANCE
    // =========================================================

    private static BalanceInfo getBalance(
            Connection conn,
            int userId,
            int leaveTypeId,
            int year)
            throws SQLException {

        String sql = """
            SELECT
                balance_id,
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
            FROM leave_balances
            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?
            LIMIT 1
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
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
                year
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (!rs.next()) {
                    return null;
                }


                return mapBalance(
                    rs
                );
            }
        }
    }


    // =========================================================
    // GET BALANCE FOR UPDATE
    // =========================================================

    private static BalanceInfo getBalanceForUpdate(
            Connection conn,
            int userId,
            int leaveTypeId,
            int year)
            throws SQLException {

        String sql = """
            SELECT
                balance_id,
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
            FROM leave_balances
            WHERE user_id = ?
              AND leave_type_id = ?
              AND leave_year = ?
            LIMIT 1
            FOR UPDATE
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
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
                year
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                if (!rs.next()) {
                    return null;
                }


                return mapBalance(
                    rs
                );
            }
        }
    }


    // =========================================================
    // MAP BALANCE
    // =========================================================

    private static BalanceInfo mapBalance(
            ResultSet rs)
            throws SQLException {

        BalanceInfo balance =
            new BalanceInfo();


        balance.balanceId =
            rs.getInt(
                "balance_id"
            );


        balance.entitlement =
            rs.getInt(
                "entitlement"
            );


        balance.carryForwardDays =
            rs.getInt(
                "carry_forward_days"
            );


        balance.carryForwardUsed =
            rs.getInt(
                "carry_forward_used"
            );


        balance.usedDays =
            rs.getInt(
                "used_days"
            );


        balance.remainingDays =
            rs.getInt(
                "remaining_days"
            );


        return balance;
    }


    // =========================================================
    // INSERT BALANCE
    // =========================================================

    private static void insertBalance(
            Connection conn,
            int userId,
            int leaveTypeId,
            int year,
            int entitlement,
            int carryForwardDays,
            int carryForwardUsed,
            int usedDays,
            int remainingDays)
            throws SQLException {

        String sql = """
            INSERT INTO leave_balances
            (
                user_id,
                leave_type_id,
                leave_year,
                entitlement,
                carry_forward_days,
                carry_forward_used,
                used_days,
                remaining_days
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
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
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
                year
            );

            ps.setInt(
                4,
                entitlement
            );

            ps.setInt(
                5,
                carryForwardDays
            );

            ps.setInt(
                6,
                carryForwardUsed
            );

            ps.setInt(
                7,
                usedDays
            );

            ps.setInt(
                8,
                remainingDays
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // UPDATE ANNUAL MASTER
    // =========================================================

    private static void updateAnnualMaster(
            Connection conn,
            int balanceId,
            int entitlement,
            int carryForwardDays,
            int carryForwardUsed,
            int usedDays,
            int remainingDays)
            throws SQLException {

        String sql = """
            UPDATE leave_balances

            SET
                entitlement = ?,
                carry_forward_days = ?,
                carry_forward_used = ?,
                used_days = ?,
                remaining_days = ?

            WHERE balance_id = ?
        """;


        try (
            PreparedStatement ps =
                conn.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                Math.max(
                    0,
                    entitlement
                )
            );


            ps.setInt(
                2,
                Math.max(
                    0,
                    carryForwardDays
                )
            );


            ps.setInt(
                3,
                Math.max(
                    0,
                    carryForwardUsed
                )
            );


            ps.setInt(
                4,
                Math.max(
                    0,
                    usedDays
                )
            );


            ps.setInt(
                5,
                Math.max(
                    0,
                    remainingDays
                )
            );


            ps.setInt(
                6,
                balanceId
            );


            int affected =
                ps.executeUpdate();


            if (affected != 1) {

                throw new SQLException(
                    "Baki Cuti Tahunan tidak dapat dikemas kini."
                );
            }
        }
    }


    // =========================================================
    // VALIDATE
    // =========================================================

    private static void validate(
            Connection conn,
            int userId,
            int year,
            int entitlement) {

        if (conn == null) {

            throw new IllegalArgumentException(
                "Database connection tidak boleh null."
            );
        }


        if (userId <= 0) {

            throw new IllegalArgumentException(
                "User ID tidak sah."
            );
        }


        if (year <= 0) {

            throw new IllegalArgumentException(
                "Tahun tidak sah."
            );
        }


        if (entitlement < 0) {

            throw new IllegalArgumentException(
                "Peruntukan cuti tidak boleh negatif."
            );
        }
    }


    // =========================================================
    // ALLOCATION RESULT
    // =========================================================

    /**
     * Digunakan oleh ApprovalServlet untuk mengetahui
     * berapa hari permohonan menggunakan:
     *
     * 1. Carry Forward
     * 2. Entitlement tahun semasa
     */
    public static final class Allocation {

        private final int carryForwardDaysUsed;

        private final int currentYearDaysUsed;


        public Allocation(
                int carryForwardDaysUsed,
                int currentYearDaysUsed) {

            this.carryForwardDaysUsed =
                Math.max(
                    0,
                    carryForwardDaysUsed
                );


            this.currentYearDaysUsed =
                Math.max(
                    0,
                    currentYearDaysUsed
                );
        }


        public int getCarryForwardDaysUsed() {

            return carryForwardDaysUsed;
        }


        public int getCurrentYearDaysUsed() {

            return currentYearDaysUsed;
        }


        public int getTotalDaysUsed() {

            return carryForwardDaysUsed
                +
                currentYearDaysUsed;
        }
    }


    // =========================================================
    // BALANCE INFO
    // =========================================================

    private static final class BalanceInfo {

        int balanceId;

        int entitlement;

        int carryForwardDays;

        int carryForwardUsed;

        int usedDays;

        int remainingDays;
    }
}