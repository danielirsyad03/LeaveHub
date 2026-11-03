package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import java.time.LocalDate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;


@WebServlet("/edit-leave")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5L * 1024 * 1024,
    maxRequestSize = 6L * 1024 * 1024
)
public class EditLeaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final long MAX_FILE_SIZE =
        5L * 1024L * 1024L;


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
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        // =====================================================
        // 1. SESSION
        // =====================================================

        HttpSession session =
            request.getSession(false);


        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
            getUserId(session);


        if (userId == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // 2. APPLICATION ID
        // =====================================================

        Integer applicationId =
            parsePositiveInteger(
                request.getParameter("id")
            );


        if (applicationId == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/applications?error=invalid"
            );

            return;
        }


        int leaveYear =
            LocalDate.now().getYear();


        List<Map<String, Object>> leaveTypes =
            new ArrayList<>();


        List<Map<String, Object>> publicHolidays =
            new ArrayList<>();


        // =====================================================
        // 3. APPLICATION SQL
        // =====================================================

        String applicationSql = """

            SELECT
                la.id,
                la.application_no,
                la.leave_type_id,
                la.leave_type,
                la.other_leave_type,
                la.start_date,
                la.end_date,
                la.duration,

                la.balance_before,
                la.balance_after,
                la.balance_verified_by,
                la.balance_verified_date,

                la.reason,
                la.contact_phone,
                la.contact_address,
                la.handover_staff_name,
                la.attachment,
                la.status,

                u.name,
                u.position,
                u.department

            FROM leave_applications la

            JOIN users u
                ON u.id = la.user_id

            WHERE la.id = ?
              AND la.user_id = ?

            LIMIT 1

        """;


        // =====================================================
        // 4. LEAVE TYPES SQL
        // =====================================================

        String leaveTypesSql = """

            SELECT
                lt.leave_type_id,
                lt.leave_type_name,
                lt.requires_document,

                lb.balance_id,
                lb.entitlement,
                lb.carry_forward_days,
                lb.carry_forward_used,
                lb.used_days,
                lb.remaining_days

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
            // 5. LOAD APPLICATION
            // =================================================

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


                    if (!rs.next()) {

                        response.sendRedirect(
                            request.getContextPath()
                            + "/applications?error=notFound"
                        );

                        return;
                    }


                    String status =
                        rs.getString("status");


                    if (
                        !isPendingStatus(status)
                    ) {

                        response.sendRedirect(
                            request.getContextPath()
                            + "/applications?error=cannotEdit"
                        );

                        return;
                    }


                    Integer selectedLeaveTypeId =
                        null;


                    int leaveTypeValue =
                        rs.getInt("leave_type_id");


                    if (!rs.wasNull()) {

                        selectedLeaveTypeId =
                            leaveTypeValue;
                    }


                    Date existingStartDate =
                        rs.getDate("start_date");


                    if (
                        existingStartDate != null
                    ) {

                        leaveYear =
                            existingStartDate
                                .toLocalDate()
                                .getYear();
                    }


                    request.setAttribute(
                        "applicationId",
                        rs.getInt("id")
                    );


                    request.setAttribute(
                        "applicationNo",
                        rs.getString(
                            "application_no"
                        )
                    );


                    request.setAttribute(
                        "selectedLeaveTypeId",
                        selectedLeaveTypeId
                    );


                    request.setAttribute(
                        "leaveType",
                        rs.getString("leave_type")
                    );


                    request.setAttribute(
                        "otherLeaveType",
                        rs.getString(
                            "other_leave_type"
                        )
                    );


                    request.setAttribute(
                        "startDate",
                        existingStartDate
                    );


                    request.setAttribute(
                        "endDate",
                        rs.getDate("end_date")
                    );


                    request.setAttribute(
                        "duration",
                        rs.getInt("duration")
                    );


                    int balanceBefore =
                        rs.getInt("balance_before");


                    request.setAttribute(
                        "balanceBefore",
                        rs.wasNull()
                            ? null
                            : balanceBefore
                    );


                    int balanceAfter =
                        rs.getInt("balance_after");


                    request.setAttribute(
                        "balanceAfter",
                        rs.wasNull()
                            ? null
                            : balanceAfter
                    );


                    request.setAttribute(
                        "balanceVerifiedBy",
                        rs.getString(
                            "balance_verified_by"
                        )
                    );


                    request.setAttribute(
                        "balanceVerifiedDate",
                        rs.getDate(
                            "balance_verified_date"
                        )
                    );


                    request.setAttribute(
                        "reason",
                        rs.getString("reason")
                    );


                    request.setAttribute(
                        "contactPhone",
                        rs.getString(
                            "contact_phone"
                        )
                    );


                    request.setAttribute(
                        "contactAddress",
                        rs.getString(
                            "contact_address"
                        )
                    );


                    request.setAttribute(
                        "handoverStaffName",
                        rs.getString(
                            "handover_staff_name"
                        )
                    );


                    request.setAttribute(
                        "attachment",
                        rs.getString(
                            "attachment"
                        )
                    );


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
                        "originalLeaveYear",
                        leaveYear
                    );
                }
            }


            // =================================================
            // 6. LOAD LEAVE TYPES
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        leaveTypesSql
                    )
            ) {


                ps.setInt(
                    1,
                    userId
                );


                ps.setInt(
                    2,
                    leaveYear
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    while (rs.next()) {


                        Map<String, Object> row =
                            new HashMap<>();


                        String leaveTypeName =
                            rs.getString(
                                "leave_type_name"
                            );


                        boolean balanceConfigured =
                            rs.getObject(
                                "balance_id"
                            ) != null;


                        int entitlement =
                            balanceConfigured
                                ? rs.getInt("entitlement")
                                : 0;


                        int usedDays =
                            balanceConfigured
                                ? rs.getInt("used_days")
                                : 0;


                        int remainingDays =
                            balanceConfigured
                                ? rs.getInt("remaining_days")
                                : 0;


                        row.put(
                            "leaveTypeId",
                            rs.getInt("leave_type_id")
                        );


                        row.put(
                            "leaveTypeName",
                            leaveTypeName
                        );


                        row.put(
                            "requiresDocument",
                            rs.getBoolean(
                                "requires_document"
                            )
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
                            "sharedBalance",
                            isSharedLeaveType(
                                leaveTypeName
                            )
                        );


                        row.put(
                            "hideBalance",
                            isNoBalanceDisplayLeaveType(
                                leaveTypeName
                            )
                        );


                        leaveTypes.add(row);
                    }
                }
            }


            // =================================================
            // 7. SHARED BALANCE DISPLAY
            //
            // Cuti Tahunan ialah MASTER balance.
            // Cuti Kecemasan hanya berkongsi baki yang sama.
            // =================================================

            Integer sharedEntitlement = null;
            Integer sharedRemaining = null;
            Integer sharedCarryForward = null;
            Integer sharedCarryForwardUsed = null;
            boolean annualMasterConfigured = false;


            for (Map<String, Object> leaveType : leaveTypes) {

                String leaveTypeName =
                    String.valueOf(
                        leaveType.get("leaveTypeName")
                    );


                if (ANNUAL.equalsIgnoreCase(leaveTypeName)) {

                    boolean configured =
                        Boolean.TRUE.equals(
                            leaveType.get("balanceConfigured")
                        );


                    if (configured) {

                        annualMasterConfigured = true;

                        sharedEntitlement =
                            ((Number) leaveType.get("entitlement"))
                                .intValue();

                        sharedRemaining =
                            ((Number) leaveType.get("remainingDays"))
                                .intValue();

                        sharedCarryForward =
                            ((Number) leaveType.get("carryForwardDays"))
                                .intValue();

                        sharedCarryForwardUsed =
                            ((Number) leaveType.get("carryForwardUsed"))
                                .intValue();
                    }

                    break;
                }
            }


            for (Map<String, Object> leaveType : leaveTypes) {

                String leaveTypeName =
                    String.valueOf(
                        leaveType.get("leaveTypeName")
                    );


                if (isSharedLeaveType(leaveTypeName)) {

                    leaveType.put(
                        "entitlement",
                        sharedEntitlement == null
                            ? 0
                            : sharedEntitlement
                    );

                    leaveType.put(
                        "remainingDays",
                        sharedRemaining == null
                            ? 0
                            : sharedRemaining
                    );

                    leaveType.put(
                        "carryForwardDays",
                        sharedCarryForward == null
                            ? 0
                            : sharedCarryForward
                    );

                    leaveType.put(
                        "carryForwardUsed",
                        sharedCarryForwardUsed == null
                            ? 0
                            : sharedCarryForwardUsed
                    );

                    leaveType.put(
                        "sharedBalance",
                        true
                    );

                    leaveType.put(
                        "balanceConfigured",
                        annualMasterConfigured
                    );
                }


                if (isNoBalanceDisplayLeaveType(leaveTypeName)) {

                    leaveType.put(
                        "hideBalance",
                        true
                    );

                    leaveType.put(
                        "balanceConfigured",
                        true
                    );
                }
            }


            // =================================================
            // 8. PUBLIC HOLIDAYS
            // =================================================

            publicHolidays =
                HolidayUtil
                    .getActivePublicHolidays(
                        con
                    );
        }


        catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat membuka permohonan.",
                e
            );
        }


        // =====================================================
        // 9. SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
            "leaveTypes",
            leaveTypes
        );


        request.setAttribute(
            "publicHolidays",
            publicHolidays
        );


        request.setAttribute(
            "currentYear",
            leaveYear
        );


        request
            .getRequestDispatcher(
                "/edit-leave.jsp"
            )
            .forward(
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


        // =====================================================
        // 1. SESSION
        // =====================================================

        HttpSession session =
            request.getSession(false);


        if (
            session == null ||
            session.getAttribute("userId") == null
        ) {

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        Integer userId =
            getUserId(session);


        if (userId == null) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
            );

            return;
        }


        // =====================================================
        // 2. APPLICATION ID
        // =====================================================

        Integer applicationId =
            parsePositiveInteger(
                request.getParameter("id")
            );


        if (applicationId == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/applications?error=invalid"
            );

            return;
        }


        // =====================================================
        // 3. FORM DATA
        // =====================================================

        Integer leaveTypeId =
            parsePositiveInteger(
                request.getParameter(
                    "leaveTypeId"
                )
            );


        String otherLeaveType =
            trim(
                request.getParameter(
                    "otherLeaveType"
                )
            );


        String startDateText =
            trim(
                request.getParameter(
                    "startDate"
                )
            );


        String endDateText =
            trim(
                request.getParameter(
                    "endDate"
                )
            );


        String reason =
            trim(
                request.getParameter(
                    "reason"
                )
            );


        String contactPhone =
            trim(
                request.getParameter(
                    "contactPhone"
                )
            );


        String contactAddress =
            trim(
                request.getParameter(
                    "contactAddress"
                )
            );


        String handoverStaffName =
            trim(
                request.getParameter(
                    "handoverStaffName"
                )
            );


        String balanceVerifiedBy =
            trim(
                request.getParameter(
                    "balanceVerifiedBy"
                )
            );


        String balanceVerifiedDateText =
            trim(
                request.getParameter(
                    "balanceVerifiedDate"
                )
            );


        if (
            leaveTypeId == null ||
            startDateText == null ||
            endDateText == null ||
            reason == null
        ) {

            redirectEditError(
                request,
                response,
                applicationId,
                "invalid"
            );

            return;
        }


        // =====================================================
        // 4. DATES
        // =====================================================

        LocalDate startDate;
        LocalDate endDate;


        try {

            startDate =
                LocalDate.parse(
                    startDateText
                );


            endDate =
                LocalDate.parse(
                    endDateText
                );


        } catch (Exception e) {

            redirectEditError(
                request,
                response,
                applicationId,
                "date"
            );

            return;
        }


        if (
            endDate.isBefore(
                startDate
            )
        ) {

            redirectEditError(
                request,
                response,
                applicationId,
                "date"
            );

            return;
        }


        // =====================================================
        // 5. NO CROSS-YEAR
        // =====================================================

        if (
            startDate.getYear()
            !=
            endDate.getYear()
        ) {

            redirectEditError(
                request,
                response,
                applicationId,
                "crossYear"
            );

            return;
        }


        int requestedLeaveYear =
            startDate.getYear();


        // =====================================================
        // 6. ATTACHMENT
        // =====================================================

        Part attachmentPart;


        try {

            attachmentPart =
                request.getPart(
                    "attachment"
                );


        } catch (
            IllegalStateException |
            ServletException e
        ) {

            redirectEditError(
                request,
                response,
                applicationId,
                "fileSize"
            );

            return;
        }


        boolean hasNewAttachment =
            attachmentPart != null
            &&
            attachmentPart.getSize() > 0;


        if (
            hasNewAttachment
            &&
            attachmentPart.getSize()
            >
            MAX_FILE_SIZE
        ) {

            redirectEditError(
                request,
                response,
                applicationId,
                "fileSize"
            );

            return;
        }


        String originalFileName =
            null;


        if (
            hasNewAttachment
        ) {


            originalFileName =
                getSafeFileName(
                    attachmentPart
                        .getSubmittedFileName()
                );


            if (
                originalFileName == null
                ||
                !isAllowedFile(
                    originalFileName
                )
            ) {

                redirectEditError(
                    request,
                    response,
                    applicationId,
                    "fileType"
                );

                return;
            }
        }


        // =====================================================
        // 7. DATABASE
        // =====================================================

        Connection con = null;

        String savedNewFileName = null;

        Path savedNewFilePath = null;


        try {


            con =
                DBConnection.getConnection();


            con.setAutoCommit(
                false
            );


            // =================================================
            // 8. LOCK APPLICATION
            //
            // application_no ditambah untuk Audit Trail.
            // =================================================

            String lockSql = """

                SELECT
                    application_no,
                    user_id,
                    status,
                    attachment,
                    start_date

                FROM leave_applications

                WHERE id = ?

                FOR UPDATE

            """;


            String existingAttachment =
                null;


            LocalDate originalStartDate =
                null;


            String applicationNo =
                null;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        lockSql
                    )
            ) {


                ps.setInt(
                    1,
                    applicationId
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (
                        !rs.next()
                        ||
                        rs.getInt("user_id")
                        !=
                        userId
                    ) {

                        con.rollback();


                        response.sendRedirect(
                            request.getContextPath()
                            + "/applications?error=notFound"
                        );

                        return;
                    }


                    if (
                        !isPendingStatus(
                            rs.getString(
                                "status"
                            )
                        )
                    ) {

                        con.rollback();


                        response.sendRedirect(
                            request.getContextPath()
                            + "/applications?error=cannotEdit"
                        );

                        return;
                    }


                    // =========================================
                    // APPLICATION NUMBER FOR AUDIT
                    // =========================================

                    applicationNo =
                        rs.getString(
                            "application_no"
                        );


                    existingAttachment =
                        trim(
                            rs.getString(
                                "attachment"
                            )
                        );


                    Date originalStartDateSql =
                        rs.getDate(
                            "start_date"
                        );


                    if (
                        originalStartDateSql
                        !=
                        null
                    ) {

                        originalStartDate =
                            originalStartDateSql
                                .toLocalDate();
                    }
                }
            }


            // =================================================
            // 9. ORIGINAL YEAR
            // =================================================

            if (
                originalStartDate == null
                ||
                requestedLeaveYear
                !=
                originalStartDate.getYear()
            ) {

                con.rollback();


                redirectEditError(
                    request,
                    response,
                    applicationId,
                    "yearChange"
                );

                return;
            }


            int leaveYear =
                originalStartDate
                    .getYear();


            // =================================================
            // 10. COUNT WORKING DAYS
            // =================================================

            int duration =
                HolidayUtil
                    .countWorkingLeaveDays(
                        con,
                        startDate,
                        endDate
                    );


            if (
                duration <= 0
            ) {

                con.rollback();


                redirectEditError(
                    request,
                    response,
                    applicationId,
                    "duration"
                );

                return;
            }


            // =================================================
            // 11. LEAVE TYPE
            // =================================================

            String leaveTypeSql = """

                SELECT
                    leave_type_name,
                    requires_document

                FROM leave_types

                WHERE leave_type_id = ?
                  AND is_active = 1

                LIMIT 1

            """;


            String leaveTypeName;

            boolean requiresDocument;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        leaveTypeSql
                    )
            ) {


                ps.setInt(
                    1,
                    leaveTypeId
                );


                try (
                    ResultSet rs =
                        ps.executeQuery()
                ) {


                    if (!rs.next()) {

                        con.rollback();


                        redirectEditError(
                            request,
                            response,
                            applicationId,
                            "invalidLeaveType"
                        );

                        return;
                    }


                    leaveTypeName =
                        rs.getString(
                            "leave_type_name"
                        );


                    requiresDocument =
                        rs.getBoolean(
                            "requires_document"
                        );
                }
            }


            // =================================================
            // 12. SPECIAL FLAGS
            // =================================================

            boolean sharedBalance =
                isSharedLeaveType(
                    leaveTypeName
                );


            boolean noBalanceRestriction =
                isNoBalanceDisplayLeaveType(
                    leaveTypeName
                );


            // =================================================
            // 13. LAIN-LAIN
            // =================================================

            if (
                OTHER.equalsIgnoreCase(
                    leaveTypeName
                )
            ) {


                if (
                    otherLeaveType == null
                ) {

                    con.rollback();


                    redirectEditError(
                        request,
                        response,
                        applicationId,
                        "otherLeaveType"
                    );

                    return;
                }


            } else {

                otherLeaveType =
                    null;
            }


            // =================================================
            // 14. DOCUMENT REQUIREMENT
            // =================================================

            boolean hasExistingAttachment =
                existingAttachment != null
                &&
                !existingAttachment.isBlank();


            if (
                requiresDocument
                &&
                !hasExistingAttachment
                &&
                !hasNewAttachment
            ) {

                con.rollback();


                redirectEditError(
                    request,
                    response,
                    applicationId,
                    "documentRequired"
                );

                return;
            }


            // =================================================
            // 15. BALANCE VERIFICATION
            // =================================================

            LocalDate balanceVerifiedDate =
                null;


            if (
                !noBalanceRestriction
            ) {


                if (
                    balanceVerifiedBy == null
                    ||
                    balanceVerifiedDateText == null
                ) {

                    con.rollback();


                    redirectEditError(
                        request,
                        response,
                        applicationId,
                        "balanceVerification"
                    );

                    return;
                }


                try {

                    balanceVerifiedDate =
                        LocalDate.parse(
                            balanceVerifiedDateText
                        );


                } catch (Exception e) {

                    con.rollback();


                    redirectEditError(
                        request,
                        response,
                        applicationId,
                        "balanceVerification"
                    );

                    return;
                }


            } else {


                balanceVerifiedBy =
                    null;


                balanceVerifiedDate =
                    null;
            }


            // =================================================
            // 16. BALANCE SNAPSHOT
            // =================================================

            Integer balanceBefore =
                null;


            Integer balanceAfter =
                null;


            // =================================================
            // SHARED BALANCE
            //
            // Annual = master row.
            // Emergency reads the exact same master remaining balance.
            // Editing a pending request does NOT deduct the balance.
            // Actual deduction only occurs when the request is approved.
            // =================================================

            if (sharedBalance) {

                // Ensure the master row exists for this year.
                LeaveCarryForwardUtil.ensureSharedBalance(
                    con,
                    userId,
                    leaveYear,
                    LeaveCarryForwardUtil.DEFAULT_SHARED_ENTITLEMENT
                );


                String sharedBalanceSql = """

                    SELECT
                        balance_id,
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
                        con.prepareStatement(sharedBalanceSql)
                ) {

                    ps.setInt(1, userId);

                    ps.setInt(
                        2,
                        LeaveCarryForwardUtil.ANNUAL_LEAVE_ID
                    );

                    ps.setInt(3, leaveYear);


                    try (
                        ResultSet rs =
                            ps.executeQuery()
                    ) {

                        if (!rs.next()) {

                            con.rollback();

                            redirectEditError(
                                request,
                                response,
                                applicationId,
                                "balanceNotConfigured"
                            );

                            return;
                        }


                        int entitlement =
                            rs.getInt("entitlement");

                        int carryForwardDays =
                            rs.getInt("carry_forward_days");

                        int carryForwardUsed =
                            rs.getInt("carry_forward_used");

                        int usedDays =
                            rs.getInt("used_days");

                        int remainingDays =
                            rs.getInt("remaining_days");


                        if (
                            entitlement < 0
                            ||
                            carryForwardDays < 0
                            ||
                            carryForwardUsed < 0
                            ||
                            usedDays < 0
                            ||
                            remainingDays < 0
                        ) {

                            throw new SQLException(
                                "Rekod kuota cuti bersama tidak sah."
                            );
                        }


                        balanceBefore =
                            Math.max(
                                0,
                                remainingDays
                            );
                    }
                }


                if (balanceBefore < duration) {

                    con.rollback();

                    redirectEditError(
                        request,
                        response,
                        applicationId,
                        "insufficientBalance"
                    );

                    return;
                }


                balanceAfter =
                    balanceBefore
                    -
                    duration;
            }


            // =================================================
            // NO QUOTA
            // =================================================

            else if (
                noBalanceRestriction
            ) {


                balanceBefore =
                    null;


                balanceAfter =
                    null;
            }


            // =================================================
            // NORMAL FINITE LEAVE
            // =================================================

            else {


                String balanceSql = """

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


                int entitlement;

                int usedDays;


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

                            con.rollback();


                            redirectEditError(
                                request,
                                response,
                                applicationId,
                                "balanceNotConfigured"
                            );

                            return;
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
                                "Rekod kuota cuti tidak sah."
                            );
                        }
                    }
                }


                balanceBefore =
                    Math.max(
                        0,
                        entitlement
                        -
                        usedDays
                    );


                if (
                    balanceBefore
                    <
                    duration
                ) {

                    con.rollback();


                    redirectEditError(
                        request,
                        response,
                        applicationId,
                        "insufficientBalance"
                    );

                    return;
                }


                balanceAfter =
                    balanceBefore
                    -
                    duration;
            }


            // =================================================
            // 17. OVERLAP
            // =================================================

            String overlapSql = """

                SELECT
                    COUNT(*)

                FROM leave_applications

                WHERE user_id = ?
                  AND id <> ?

                  AND status IN
                  (
                      'PENDING',
                      'PENDING_HEAD',
                      'PENDING_ADMIN',
                      'PENDING_MANAGEMENT',
                      'APPROVED'
                  )

                  AND start_date <= ?
                  AND end_date >= ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        overlapSql
                    )
            ) {


                ps.setInt(
                    1,
                    userId
                );


                ps.setInt(
                    2,
                    applicationId
                );


                ps.setDate(
                    3,
                    Date.valueOf(
                        endDate
                    )
                );


                ps.setDate(
                    4,
                    Date.valueOf(
                        startDate
                    )
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

                        con.rollback();


                        redirectEditError(
                            request,
                            response,
                            applicationId,
                            "overlap"
                        );

                        return;
                    }
                }
            }


            // =================================================
            // 18. SAVE NEW ATTACHMENT
            // =================================================

            String finalAttachment =
                existingAttachment;


            if (
                hasNewAttachment
            ) {


                String uploadDirectory =
                    getServletContext()
                        .getRealPath(
                            "/uploads"
                        );


                if (
                    uploadDirectory == null
                ) {

                    throw new IOException(
                        "Folder uploads tidak dapat ditentukan."
                    );
                }


                Path uploadPath =
                    Paths.get(
                        uploadDirectory
                    );


                Files.createDirectories(
                    uploadPath
                );


                String extension =
                    getExtension(
                        originalFileName
                    );


                savedNewFileName =
                    "leave_"
                    + userId
                    + "_"
                    + System.currentTimeMillis()
                    + "_"
                    + UUID.randomUUID()
                        .toString()
                        .substring(0, 8)
                    + extension;


                savedNewFilePath =
                    uploadPath.resolve(
                        savedNewFileName
                    );


                try (
                    InputStream inputStream =
                        attachmentPart
                            .getInputStream()
                ) {


                    Files.copy(
                        inputStream,
                        savedNewFilePath,
                        StandardCopyOption
                            .REPLACE_EXISTING
                    );
                }


                finalAttachment =
                    savedNewFileName;
            }


            // =================================================
            // 19. UPDATE APPLICATION
            // =================================================

            String updateSql = """

                UPDATE leave_applications

                SET
                    leave_type_id = ?,
                    leave_type = ?,
                    other_leave_type = ?,

                    start_date = ?,
                    end_date = ?,
                    duration = ?,

                    balance_before = ?,
                    balance_after = ?,
                    balance_verified_by = ?,
                    balance_verified_date = ?,

                    carry_forward_days_used = 0,
                    current_year_days_used = 0,

                    reason = ?,
                    contact_phone = ?,
                    contact_address = ?,
                    handover_staff_name = ?,

                    attachment = ?,

                    status = 'PENDING_MANAGEMENT',

                    remarks = NULL,
                    reviewed_at = NULL,
                    reviewed_by = NULL

                WHERE id = ?
                  AND user_id = ?

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        updateSql
                    )
            ) {


                ps.setInt(
                    1,
                    leaveTypeId
                );


                ps.setString(
                    2,
                    leaveTypeName
                );


                setNullableString(
                    ps,
                    3,
                    otherLeaveType
                );


                ps.setDate(
                    4,
                    Date.valueOf(
                        startDate
                    )
                );


                ps.setDate(
                    5,
                    Date.valueOf(
                        endDate
                    )
                );


                ps.setInt(
                    6,
                    duration
                );


                if (
                    balanceBefore == null
                ) {

                    ps.setNull(
                        7,
                        Types.INTEGER
                    );

                } else {

                    ps.setInt(
                        7,
                        balanceBefore
                    );
                }


                if (
                    balanceAfter == null
                ) {

                    ps.setNull(
                        8,
                        Types.INTEGER
                    );

                } else {

                    ps.setInt(
                        8,
                        balanceAfter
                    );
                }


                setNullableString(
                    ps,
                    9,
                    balanceVerifiedBy
                );


                if (
                    balanceVerifiedDate == null
                ) {

                    ps.setNull(
                        10,
                        Types.DATE
                    );

                } else {

                    ps.setDate(
                        10,
                        Date.valueOf(
                            balanceVerifiedDate
                        )
                    );
                }


                ps.setString(
                    11,
                    reason
                );


                setNullableString(
                    ps,
                    12,
                    contactPhone
                );


                setNullableString(
                    ps,
                    13,
                    contactAddress
                );


                setNullableString(
                    ps,
                    14,
                    handoverStaffName
                );


                setNullableString(
                    ps,
                    15,
                    finalAttachment
                );


                ps.setInt(
                    16,
                    applicationId
                );


                ps.setInt(
                    17,
                    userId
                );


                int affected =
                    ps.executeUpdate();


                if (
                    affected != 1
                ) {

                    throw new SQLException(
                        "Permohonan tidak dapat dikemas kini."
                    );
                }
            }


            // =================================================
            // 20. RESET APPROVALS
            // =================================================

            resetApprovals(
                con,
                applicationId,
                userId
            );


            // =================================================
            // 21. AUDIT TRAIL
            //
            // Menggunakan connection yang sama.
            // Jika transaction rollback, log juga rollback.
            // =================================================

            ActivityLogUtil.log(
                con,
                request,
                "EDIT_LEAVE",
                "Mengemaskini permohonan cuti "
                    + applicationNo,
                "LEAVE_APPLICATION",
                applicationId
            );


            // =================================================
            // 22. COMMIT
            // =================================================

            con.commit();


            // =================================================
            // 23. DELETE OLD FILE AFTER COMMIT
            // =================================================

            if (
                hasNewAttachment
                &&
                existingAttachment != null
                &&
                !existingAttachment.isBlank()
                &&
                !existingAttachment.equals(
                    savedNewFileName
                )
            ) {

                deleteAttachmentQuietly(
                    existingAttachment
                );
            }


            response.sendRedirect(
                request.getContextPath()
                + "/applications?success=updated"
            );


        } catch (Exception e) {


            rollbackQuietly(
                con
            );


            if (
                savedNewFilePath != null
            ) {


                try {

                    Files.deleteIfExists(
                        savedNewFilePath
                    );

                } catch (
                    IOException ignored
                ) {
                }
            }


            throw new ServletException(
                "Tidak dapat mengemas kini permohonan.",
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
    // SHARED LEAVE TYPE
    // =========================================================

    private boolean isSharedLeaveType(
            String leaveTypeName) {


        if (
            leaveTypeName == null
        ) {

            return false;
        }


        return
            ANNUAL.equalsIgnoreCase(
                leaveTypeName.trim()
            )
            ||
            EMERGENCY.equalsIgnoreCase(
                leaveTypeName.trim()
            );
    }


    // =========================================================
    // NO QUOTA / NO STAFF-FACING BALANCE
    // =========================================================

    private boolean isNoBalanceDisplayLeaveType(
            String leaveTypeName) {


        if (
            leaveTypeName == null
        ) {

            return false;
        }


        String name =
            leaveTypeName.trim();


        return
            NO_RECORD.equalsIgnoreCase(name)
            ||
            UNPAID.equalsIgnoreCase(name)
            ||
            OTHER.equalsIgnoreCase(name);
    }


    // =========================================================
    // RESET APPROVALS
    // =========================================================

    private void resetApprovals(
            Connection con,
            int leaveId,
            int userId)
            throws SQLException {


        String deleteSql = """

            DELETE FROM leave_approvals

            WHERE leave_id = ?

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    deleteSql
                )
        ) {


            ps.setInt(
                1,
                leaveId
            );


            ps.executeUpdate();
        }


        // =====================================================
        // CURRENT HOD
        // =====================================================

        Integer hodId =
            null;


        String hodSql = """

            SELECT
                hod_id

            FROM users

            WHERE id = ?

            LIMIT 1

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    hodSql
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


                if (
                    rs.next()
                ) {


                    int value =
                        rs.getInt(
                            "hod_id"
                        );


                    if (
                        !rs.wasNull()
                    ) {

                        hodId =
                            value;
                    }
                }
            }
        }


        // =====================================================
        // OPTIONAL HOD
        // =====================================================

        if (
            hodId != null
        ) {


            String hodApprovalSql = """

                INSERT INTO leave_approvals
                (
                    leave_id,
                    approver_id,
                    approval_level,
                    decision,
                    remarks,
                    decision_date
                )

                VALUES
                (
                    ?,
                    ?,
                    'HEAD_OF_UNIT',
                    'PENDING',
                    NULL,
                    NULL
                )

            """;


            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        hodApprovalSql
                    )
            ) {


                ps.setInt(
                    1,
                    leaveId
                );


                ps.setInt(
                    2,
                    hodId
                );


                ps.executeUpdate();
            }
        }


        // =====================================================
        // MANAGEMENT ALWAYS EXISTS
        // =====================================================

        String managementApprovalSql = """

            INSERT INTO leave_approvals
            (
                leave_id,
                approver_id,
                approval_level,
                decision,
                remarks,
                decision_date
            )

            VALUES
            (
                ?,
                NULL,
                'MANAGEMENT',
                'PENDING',
                NULL,
                NULL
            )

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    managementApprovalSql
                )
        ) {


            ps.setInt(
                1,
                leaveId
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // DELETE OLD ATTACHMENT
    // =========================================================

    private void deleteAttachmentQuietly(
            String fileName) {


        if (
            fileName == null
            ||
            fileName.isBlank()
        ) {

            return;
        }


        try {


            String uploadDirectory =
                getServletContext()
                    .getRealPath(
                        "/uploads"
                    );


            if (
                uploadDirectory == null
            ) {

                return;
            }


            Path uploadRoot =
                Paths.get(
                    uploadDirectory
                )
                .toAbsolutePath()
                .normalize();


            Path target =
                uploadRoot
                    .resolve(
                        Paths.get(
                            fileName
                        )
                        .getFileName()
                    )
                    .normalize();


            if (
                target.startsWith(
                    uploadRoot
                )
            ) {

                Files.deleteIfExists(
                    target
                );
            }


        } catch (
            Exception ignored
        ) {
        }
    }


    // =========================================================
    // SAFE FILE NAME
    // =========================================================

    private String getSafeFileName(
            String fileName) {


        if (
            fileName == null
            ||
            fileName.isBlank()
        ) {

            return null;
        }


        return Paths
            .get(fileName)
            .getFileName()
            .toString()
            .trim();
    }


    // =========================================================
    // FILE EXTENSION
    // =========================================================

    private String getExtension(
            String fileName) {


        if (
            fileName == null
        ) {

            return "";
        }


        int dot =
            fileName.lastIndexOf('.');


        if (
            dot < 0
            ||
            dot ==
            fileName.length() - 1
        ) {

            return "";
        }


        return fileName
            .substring(dot)
            .toLowerCase(
                Locale.ROOT
            );
    }


    // =========================================================
    // ALLOWED FILE
    // =========================================================

    private boolean isAllowedFile(
            String fileName) {


        String extension =
            getExtension(
                fileName
            );


        return
            ".pdf".equals(extension)
            ||
            ".jpg".equals(extension)
            ||
            ".jpeg".equals(extension)
            ||
            ".png".equals(extension)
            ||
            ".doc".equals(extension)
            ||
            ".docx".equals(extension);
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
                .equalsIgnoreCase(status)
            ||
            "PENDING_HEAD"
                .equalsIgnoreCase(status)
            ||
            "PENDING_ADMIN"
                .equalsIgnoreCase(status)
            ||
            "PENDING"
                .equalsIgnoreCase(status);
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


            return value > 0
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


            return number > 0
                ? number
                : null;


        } catch (
            NumberFormatException e
        ) {

            return null;
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
                value.trim()
            );
        }
    }


    // =========================================================
    // TRIM
    // =========================================================

    private String trim(
            String value) {


        if (
            value == null
        ) {

            return null;
        }


        value =
            value.trim();


        return value.isEmpty()
            ? null
            : value;
    }


    // =========================================================
    // REDIRECT
    // =========================================================

    private void redirectEditError(
            HttpServletRequest request,
            HttpServletResponse response,
            int applicationId,
            String error)
            throws IOException {


        response.sendRedirect(
            request.getContextPath()
            + "/edit-leave?id="
            + applicationId
            + "&error="
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
}