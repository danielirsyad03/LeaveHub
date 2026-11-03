package com.leavehub;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
@WebServlet("/apply")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5L * 1024 * 1024,
    maxRequestSize = 6L * 1024 * 1024
)
public class LeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final long MAX_FILE_SIZE =
        5L * 1024 * 1024;
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
            getUserId(session);
        if (userId == null) {
            session.invalidate();
            response.sendRedirect(
                request.getContextPath() + "/"
            );
            return;
        }
        int currentYear =
            LocalDate.now().getYear();
        List<Map<String,Object>> leaveTypes =
            new ArrayList<>();
        String userSql = """
            SELECT
                name,
                position,
                department
            FROM users
            WHERE id = ?
            LIMIT 1
        """;
        String leaveTypeSql = """
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
                ON lb.leave_type_id = lt.leave_type_id
                AND lb.user_id = ?
                AND lb.leave_year = ?
            WHERE lt.is_active = 1
            ORDER BY lt.leave_type_id ASC
        """;
        try (
            Connection con =
                DBConnection.getConnection()
        ) {
            // Pastikan baki tahun semasa wujud dan carry forward telah diproses.
        	ensureSharedBalanceForYear(
                    con,
                    userId,
                    currentYear
                );
            // =================================================
            // USER
            // =================================================
            try (
                PreparedStatement ps =
                    con.prepareStatement(userSql)
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
                            request.getContextPath() + "/"
                        );
                        return;
                    }
                    String staffName =
                        rs.getString("name");
                    request.setAttribute(
                        "staffName",
                        staffName
                    );
                    request.setAttribute(
                        "position",
                        rs.getString("position")
                    );
                    request.setAttribute(
                        "department",
                        rs.getString("department")
                    );
                    if (
                        staffName != null
                        &&
                        !staffName.isBlank()
                    ) {
                        session.setAttribute(
                            "userName",
                            staffName
                        );
                    }
                }
            }
            // =================================================
            // TYPES
            // =================================================
            int annualEntitlement = 0;
            int annualUsed = 0;
            int annualRemaining = 0;
            boolean annualConfigured = false;
            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        leaveTypeSql
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
                        boolean noQuota =
                            isNoQuotaLeave(
                                leaveTypeName
                            );
                        boolean shared =
                            isSharedLeave(
                                leaveTypeName
                            );
                        boolean configured =
                            rs.getObject(
                                "balance_id"
                            ) != null;
                        int entitlement =
                            configured
                                ? rs.getInt(
                                    "entitlement"
                                )
                                : 0;
                        int usedDays =
                            configured
                                ? rs.getInt(
                                    "used_days"
                                )
                                : 0;
                        int remainingDays =
                            configured
                                ? rs.getInt(
                                    "remaining_days"
                                )
                                : 0;

                        // remaining_days ialah baki efektif shared balance.
                        // Jangan kira semula kerana used_days sudah termasuk penggunaan CF.

                        if (
                        	    ANNUAL.equalsIgnoreCase(
                        	        leaveTypeName
                        	    )
                        	) {
                        	    annualConfigured =
                        	        configured;
                        	    annualEntitlement =
                        	        entitlement;
                        	    annualUsed =
                        	        usedDays;
                        	    annualRemaining =
                        	        remainingDays;
                        	}
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
                            rs.getBoolean(
                                "requires_document"
                            )
                        );
                        row.put(
                            "balanceConfigured",
                            noQuota
                                ? true
                                : configured
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
                            shared
                        );
                        row.put(
                            "hideBalance",
                            noQuota
                        );
                        leaveTypes.add(row);
                    }
                }
            }
         // =================================================
         // SHARED POOL
         //
         // Cuti Tahunan ialah MASTER BALANCE.
         // Cuti Kecemasan menggunakan baki yang sama.
         //
         // Contoh:
         // Entitlement      = 30
         // Carry Forward    = 5
         // Remaining Days   = 35
         //
         // Maka:
         // Cuti Tahunan     = 35
         // Cuti Kecemasan   = 35
         // =================================================
         boolean sharedConfigured =
             annualConfigured;
         int sharedEntitlement =
             annualEntitlement;
         int sharedUsed =
             annualUsed;
         int sharedRemaining =
             annualRemaining;
         for (
             Map<String,Object> row :
             leaveTypes
         ) {
             if (
                 Boolean.TRUE.equals(
                     row.get(
                         "sharedBalance"
                     )
                 )
             ) {
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
             }
         }
            request.setAttribute(
                "leaveTypes",
                leaveTypes
            );

            // Pass active public holidays to apply-leave.jsp.
            request.setAttribute(
                "publicHolidays",
                HolidayUtil.getActivePublicHolidays(con)
            );

            request.setAttribute(
                "leaveYear",
                currentYear
            );
            request.getRequestDispatcher(
                "/apply-leave.jsp"
            ).forward(
                request,
                response
            );
        } catch (SQLException e) {
            throw new ServletException(
                "Tidak dapat memuatkan halaman permohonan cuti.",
                e
            );
        }
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
        Integer userId =
            getUserId(session);
        if (userId == null) {
            session.invalidate();
            response.sendRedirect(
                request.getContextPath() + "/"
            );
            return;
        }
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
        if (
            leaveTypeId == null
            ||
            startDateText == null
            ||
            endDateText == null
            ||
            reason == null
        ) {
            redirect(
                request,
                response,
                "invalid"
            );
            return;
        }
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
            redirect(
                request,
                response,
                "date"
            );
            return;
        }
        if (
            endDate.isBefore(
                startDate
            )
            ||
            startDate.getYear()
                !=
            endDate.getYear()
        ) {
            redirect(
                request,
                response,
                endDate.isBefore(startDate)
                    ? "date"
                    : "crossYear"
            );
            return;
        }
        int leaveYear =
            startDate.getYear();
        Part attachmentPart;
        try {
            attachmentPart =
                request.getPart(
                    "attachment"
                );
        } catch (
            IllegalStateException
            |
            ServletException e
        ) {
            redirect(
                request,
                response,
                "file"
            );
            return;
        }
        String attachmentName =
            null;
        if (
            attachmentPart != null
            &&
            attachmentPart.getSize() > 0
        ) {
            if (
                attachmentPart.getSize()
                >
                MAX_FILE_SIZE
            ) {
                redirect(
                    request,
                    response,
                    "file"
                );
                return;
            }
            String extension =
                getExtension(
                    attachmentPart
                        .getSubmittedFileName()
                );
            if (
                !isAllowedExtension(
                    extension
                )
            ) {
                redirect(
                    request,
                    response,
                    "file"
                );
                return;
            }
            attachmentName =
                "leave_"
                + userId
                + "_"
                + System.currentTimeMillis()
                + extension;
        }
        Connection con =
            null;
        File savedFile =
            null;
        try {
            con =
                DBConnection.getConnection();
            con.setAutoCommit(
                false
            );
            // =================================================
            // LEAVE TYPE
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
                        redirect(
                            request,
                            response,
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
            boolean noQuota =
                isNoQuotaLeave(
                    leaveTypeName
                );
            boolean sharedLeave =
                isSharedLeave(
                    leaveTypeName
                );
            int duration =
                countWorkingLeaveDays(
                    con,
                    startDate,
                    endDate
                );
            if (duration <= 0) {
                con.rollback();
                redirect(
                    request,
                    response,
                    "duration"
                );
                return;
            }
            if (
                OTHER.equalsIgnoreCase(
                    leaveTypeName
                )
            ) {
                if (
                    otherLeaveType == null
                    ||
                    otherLeaveType.isBlank()
                ) {
                    con.rollback();
                    redirect(
                        request,
                        response,
                        "otherLeaveType"
                    );
                    return;
                }
            } else {
                otherLeaveType =
                    null;
            }
            if (
                requiresDocument
                &&
                (
                    attachmentPart == null
                    ||
                    attachmentPart
                        .getSize() <= 0
                )
            ) {
                con.rollback();
                redirect(
                    request,
                    response,
                    "documentRequired"
                );
                return;
            }
            Integer balanceBefore =
                null;
            Integer balanceAfter =
                null;
            String balanceVerifiedBy =
                null;
            LocalDate balanceVerifiedDate =
                null;
            if (sharedLeave) {

                // Pastikan shared balance tahun permohonan tersedia.

                ensureSharedBalanceForYear(con, userId, leaveYear);

            }

            if (!noQuota) {

                // Pengesahan baki dibuat secara automatik oleh sistem.
                // Borang JSP tidak lagi memerlukan pengguna mengisi
                // balanceVerifiedBy atau balanceVerifiedDate.
                balanceVerifiedBy = "Sistem";
                balanceVerifiedDate = LocalDate.now();
                if (sharedLeave) {
                    BalanceSnapshot snapshot =
                        loadSharedBalanceSnapshot(
                            con,
                            userId,
                            leaveYear,
                            duration
                        );
                    balanceBefore =
                        snapshot.before;
                    balanceAfter =
                        snapshot.after;
                } else {
                    BalanceSnapshot snapshot =
                        loadNormalBalanceSnapshot(
                            con,
                            userId,
                            leaveTypeId,
                            leaveYear,
                            duration
                        );
                    balanceBefore =
                        snapshot.before;
                    balanceAfter =
                        snapshot.after;
                }
            } else {
                balanceVerifiedBy =
                    null;
                balanceVerifiedDate =
                    null;
            }
            // =================================================
            // OVERLAP
            // =================================================
            String overlapSql = """
                SELECT COUNT(*)
                FROM leave_applications
                WHERE user_id = ?
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
                ps.setDate(
                    2,
                    Date.valueOf(
                        endDate
                    )
                );
                ps.setDate(
                    3,
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
                        redirect(
                            request,
                            response,
                            "overlap"
                        );
                        return;
                    }
                }
            }
            // =================================================
            // FILE
            // =================================================
            if (
                attachmentName != null
            ) {
                String uploadPath =
                    getServletContext()
                        .getRealPath(
                            "/uploads"
                        );
                if (
                    uploadPath == null
                ) {
                    throw new IOException(
                        "Direktori muat naik tidak tersedia."
                    );
                }
                File uploadDirectory =
                    new File(
                        uploadPath
                    );
                if (
                    !uploadDirectory.exists()
                    &&
                    !uploadDirectory.mkdirs()
                ) {
                    throw new IOException(
                        "Direktori muat naik tidak dapat dicipta."
                    );
                }
                savedFile =
                    new File(
                        uploadDirectory,
                        attachmentName
                    );
                attachmentPart.write(
                    savedFile.getAbsolutePath()
                );
            }
            // =================================================
            // APPLICATION NUMBER
            // =================================================
            String millis =
                String.valueOf(
                    System.currentTimeMillis()
                );
            String lastSix =
                millis.substring(
                    Math.max(
                        0,
                        millis.length() - 6
                    )
                );
            String applicationNo =
                "PKB-CUTI-"
                +
                LocalDate.now()
                    .toString()
                    .replace(
                        "-",
                        ""
                    )
                +
                "-"
                +
                userId
                +
                "-"
                +
                lastSix;
            // =================================================
            // INSERT APPLICATION
            // =================================================
            String insertSql = """
                INSERT INTO leave_applications
                (
                    application_no,
                    user_id,
                    leave_type_id,
                    leave_type,
                    other_leave_type,
                    start_date,
                    end_date,
                    duration,
                    balance_before,
                    balance_after,
                    balance_verified_by,
                    balance_verified_date,
                    reason,
                    contact_phone,
                    contact_address,
                    handover_staff_name,
                    attachment,
                    status,
                    submitted_at
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
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    'PENDING_MANAGEMENT',
                    CURRENT_TIMESTAMP
                )
            """;
            int leaveId;
            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        insertSql,
                        Statement.RETURN_GENERATED_KEYS
                    )
            ) {
                ps.setString(
                    1,
                    applicationNo
                );
                ps.setInt(
                    2,
                    userId
                );
                ps.setInt(
                    3,
                    leaveTypeId
                );
                ps.setString(
                    4,
                    leaveTypeName
                );
                setNullableString(
                    ps,
                    5,
                    otherLeaveType
                );
                ps.setDate(
                    6,
                    Date.valueOf(
                        startDate
                    )
                );
                ps.setDate(
                    7,
                    Date.valueOf(
                        endDate
                    )
                );
                ps.setInt(
                    8,
                    duration
                );
                setNullableInteger(
                    ps,
                    9,
                    balanceBefore
                );
                setNullableInteger(
                    ps,
                    10,
                    balanceAfter
                );
                setNullableString(
                    ps,
                    11,
                    balanceVerifiedBy
                );
                if (
                    balanceVerifiedDate == null
                ) {
                    ps.setNull(
                        12,
                        Types.DATE
                    );
                } else {
                    ps.setDate(
                        12,
                        Date.valueOf(
                            balanceVerifiedDate
                        )
                    );
                }
                ps.setString(
                    13,
                    reason
                );
                setNullableString(
                    ps,
                    14,
                    contactPhone
                );
                setNullableString(
                    ps,
                    15,
                    contactAddress
                );
                setNullableString(
                    ps,
                    16,
                    handoverStaffName
                );
                setNullableString(
                    ps,
                    17,
                    attachmentName
                );
                ps.executeUpdate();
                try (
                    ResultSet keys =
                        ps.getGeneratedKeys()
                ) {
                    if (!keys.next()) {
                        throw new SQLException(
                            "ID permohonan gagal dijana."
                        );
                    }
                    leaveId =
                        keys.getInt(1);
                }
            }
            // =================================================
            // OPTIONAL HOD
            // =================================================
            Integer hodId =
                findHodId(
                    con,
                    userId
                );
            if (
                hodId != null
                &&
                hodId != userId
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
            // =================================================
            // MANAGEMENT PENDING
            // =================================================
            String managementSql = """
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
                        managementSql
                    )
            ) {
                ps.setInt(
                    1,
                    leaveId
                );
                ps.executeUpdate();
            }
            // =================================================
            // APPLICANT NAME
            // =================================================
            String applicantName =
                getUserName(
                    con,
                    userId
                );
            if (
                applicantName == null
                ||
                applicantName.isBlank()
            ) {
                applicantName =
                    "Staf";
            }
            // =================================================
            // NOTIFY HOD
            // =================================================
            if (
                hodId != null
                &&
                hodId != userId
            ) {
                NotificationUtil.create(
                    con,
                    hodId,
                    "LEAVE_HOD_REVIEW",
                    "Permohonan Cuti Baharu",
                    applicantName
                    + " telah menghantar permohonan "
                    + leaveTypeName
                    + " dan memerlukan semakan anda.",
                    "LEAVE",
                    leaveId
                );
            }
            // =================================================
            // NOTIFY MANAGEMENT
            // =================================================
            NotificationUtil.createForRole(
                con,
                "MANAGEMENT",
                userId,
                "LEAVE_MANAGEMENT_REVIEW",
                "Permohonan Menunggu Keputusan",
                applicantName
                + " telah menghantar permohonan "
                + leaveTypeName
                + " untuk keputusan Pengurusan.",
                "LEAVE",
                leaveId
            );
            // =================================================
            // NOTIFY HR / ADMIN
            // =================================================
            NotificationUtil.createForRole(
                con,
                "HR",
                userId,
                "LEAVE_HR_INFO",
                "Permohonan Cuti Baharu",
                applicantName
                + " telah menghantar permohonan "
                + leaveTypeName
                + ".",
                "LEAVE",
                leaveId
            );
            // =================================================
            // AUDIT TRAIL
            //
            // Simpan dalam transaction yang sama.
            // Jika transaction gagal, audit juga rollback.
            // =================================================
            ActivityLogUtil.log(
                con,
                request,
                "SUBMIT_LEAVE",
                "Menghantar permohonan cuti "
                    + applicationNo,
                "LEAVE_APPLICATION",
                leaveId
            );
            // =================================================
            // NO DEDUCTION HERE
            //
            // Baki sebenar hanya berubah selepas Management
            // meluluskan permohonan.
            // =================================================
            con.commit();
            response.sendRedirect(
                request.getContextPath()
                    + "/applications?success=submitted"
            );
        } catch (Exception e) {
            rollbackQuietly(
                con
            );
            if (
                savedFile != null
                &&
                savedFile.exists()
            ) {
                try {
                    savedFile.delete();
                } catch (
                    Exception ignored
                ) {
                }
            }
            throw new ServletException(
                "Tidak dapat menghantar permohonan cuti.",
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
    // ENSURE SHARED BALANCE FOR YEAR
    // =========================================================
    private void ensureSharedBalanceForYear(
            Connection con,
            int userId,
            int leaveYear)
            throws SQLException {

        Integer entitlement = null;

        String currentSql = """
            SELECT entitlement
            FROM leave_balances
            WHERE user_id = ?
              AND leave_type_id = 1
              AND leave_year = ?
            LIMIT 1
        """;

        try (PreparedStatement ps = con.prepareStatement(currentSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, leaveYear);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    entitlement = rs.getInt("entitlement");
                }
            }
        }

        if (entitlement == null) {
            String previousSql = """
                SELECT entitlement
                FROM leave_balances
                WHERE user_id = ?
                  AND leave_type_id = 1
                  AND leave_year < ?
                ORDER BY leave_year DESC
                LIMIT 1
            """;

            try (PreparedStatement ps = con.prepareStatement(previousSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, leaveYear);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        entitlement = rs.getInt("entitlement");
                    }
                }
            }
        }

        // Jangan andaikan entitlement jika staff belum pernah
        // dikonfigurasi dalam leave_balances.
        if (entitlement == null || entitlement < 0) {
            return;
        }

        LeaveCarryForwardUtil.ensureSharedBalance(
            con,
            userId,
            leaveYear,
            entitlement
        );
    }


    // =========================================================
    // COUNT WORKING LEAVE DAYS
    //
    // PKB:
    // Sunday - Thursday = working days
    // Friday + Saturday = off days
    // Active public holidays are excluded.
    //
    // Both startDate and endDate are INCLUDED.
    // Example:
    // 24/09/2026 - 24/09/2026 = 1 working day
    // if the date is not Friday, Saturday or a public holiday.
    // =========================================================
    private int countWorkingLeaveDays(
            Connection con,
            LocalDate startDate,
            LocalDate endDate)
            throws SQLException {

        if (
            con == null
            ||
            startDate == null
            ||
            endDate == null
            ||
            endDate.isBefore(startDate)
        ) {
            return 0;
        }

        // Use the existing central utility so the backend
        // excludes Friday, Saturday and active public holidays,
        // including multi-day public holiday ranges.
        return HolidayUtil.countWorkingLeaveDays(
            con,
            startDate,
            endDate
        );
    }
    // =========================================================
    // PARSE PUBLIC HOLIDAY DATE
    // =========================================================
    private LocalDate parseHolidayDate(
            Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof LocalDate) {
            return (LocalDate) value;
        }
        if (value instanceof java.sql.Date) {
            return ((java.sql.Date) value)
                .toLocalDate();
        }
        String text =
            value.toString().trim();
        if (text.isEmpty()) {
            return null;
        }
        try {
            // yyyy-MM-dd
            if (
                text.matches(
                    "\\d{4}-\\d{2}-\\d{2}"
                )
            ) {
                return LocalDate.parse(
                    text
                );
            }
            // yyyy-MM-dd HH:mm:ss...
            if (
                text.length() >= 10
                &&
                text.substring(0, 10)
                    .matches(
                        "\\d{4}-\\d{2}-\\d{2}"
                    )
            ) {
                return LocalDate.parse(
                    text.substring(
                        0,
                        10
                    )
                );
            }
            // dd/MM/yyyy
            if (
                text.matches(
                    "\\d{2}/\\d{2}/\\d{4}"
                )
            ) {
                String[] parts =
                    text.split("/");
                return LocalDate.of(
                    Integer.parseInt(
                        parts[2]
                    ),
                    Integer.parseInt(
                        parts[1]
                    ),
                    Integer.parseInt(
                        parts[0]
                    )
                );
            }
        } catch (Exception ignored) {
        }
        return null;
    }
    // =========================================================
    // SHARED SNAPSHOT
    // =========================================================
    private BalanceSnapshot loadSharedBalanceSnapshot(
            Connection con,
            int userId,
            int leaveYear,
            int duration)
            throws SQLException {
        /*
         * Cuti Tahunan ialah MASTER BALANCE bagi pool bersama
         * Cuti Tahunan + Cuti Kecemasan.
         *
         * remaining_days pada rekod Cuti Tahunan sudah merangkumi:
         * entitlement + carry_forward_days - used_days.
         *
         * Oleh itu jangan kira semula menggunakan entitlement sahaja,
         * kerana carry forward akan hilang daripada pengiraan.
         */
        String sql = """
            SELECT
                lb.remaining_days
            FROM leave_balances lb
            JOIN leave_types lt
                ON lt.leave_type_id = lb.leave_type_id
            WHERE lb.user_id = ?
              AND lb.leave_year = ?
              AND lt.leave_type_name = 'Cuti Tahunan'
            LIMIT 1
            FOR UPDATE
        """;
        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, leaveYear);
            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {
                if (!rs.next()) {
                    throw new SQLException(
                        "Baki Cuti Tahunan belum dikonfigurasi."
                    );
                }
                int remaining =
                    rs.getInt("remaining_days");
                if (remaining < duration) {
                    throw new SQLException(
                        "Baki cuti tidak mencukupi."
                    );
                }
                return new BalanceSnapshot(
                    remaining,
                    remaining - duration
                );
            }
        }
    }
    // =========================================================
    // NORMAL SNAPSHOT
    // =========================================================
    private BalanceSnapshot loadNormalBalanceSnapshot(
            Connection con,
            int userId,
            int leaveTypeId,
            int leaveYear,
            int duration)
            throws SQLException {
        String sql = """
            SELECT
                remaining_days
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
                    throw new SQLException(
                        "Baki cuti belum dikonfigurasi."
                    );
                }
                int remaining =
                    rs.getInt(
                        "remaining_days"
                    );
                if (
                    remaining
                    <
                    duration
                ) {
                    throw new SQLException(
                        "Baki cuti tidak mencukupi."
                    );
                }
                return new BalanceSnapshot(
                    remaining,
                    remaining - duration
                );
            }
        }
    }
    // =========================================================
    // FIND HOD
    // =========================================================
    private Integer findHodId(
            Connection con,
            int userId)
            throws SQLException {
        String sql = """
            SELECT hod_id
            FROM users
            WHERE id = ?
            LIMIT 1
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
                if (rs.next()) {
                    int hodId =
                        rs.getInt(
                            "hod_id"
                        );
                    if (!rs.wasNull()) {
                        return hodId;
                    }
                }
            }
        }
        return null;
    }
    // =========================================================
    // USER NAME
    // =========================================================
    private String getUserName(
            Connection con,
            int userId)
            throws SQLException {
        String sql = """
            SELECT name
            FROM users
            WHERE id = ?
            LIMIT 1
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
                if (rs.next()) {
                    return rs.getString(
                        "name"
                    );
                }
            }
        }
        return null;
    }
    // =========================================================
    // SHARED LEAVE
    // =========================================================
    private boolean isSharedLeave(
            String leaveTypeName) {
        return
            leaveTypeName != null
            &&
            (
                ANNUAL.equalsIgnoreCase(
                    leaveTypeName
                )
                ||
                EMERGENCY.equalsIgnoreCase(
                    leaveTypeName
                )
            );
    }
    // =========================================================
    // NO QUOTA
    // =========================================================
    private boolean isNoQuotaLeave(
            String leaveTypeName) {
        return
            leaveTypeName != null
            &&
            (
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
                )
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
            return id > 0
                ? id
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
            int result =
                Integer.parseInt(
                    value.trim()
                );
            return result > 0
                ? result
                : null;
        } catch (
            Exception e
        ) {
            return null;
        }
    }
    // =========================================================
    // TRIM
    // =========================================================
    private String trim(
            String value) {
        if (value == null) {
            return null;
        }
        value =
            value.trim();
        return value.isEmpty()
            ? null
            : value;
    }
    // =========================================================
    // FILE EXTENSION
    // =========================================================
    private String getExtension(
            String fileName) {
        if (
            fileName == null
            ||
            fileName.isBlank()
        ) {
            return "";
        }
        int dot =
            fileName.lastIndexOf(
                '.'
            );
        if (
            dot < 0
            ||
            dot == fileName.length() - 1
        ) {
            return "";
        }
        return fileName
            .substring(
                dot
            )
            .toLowerCase(
                Locale.ROOT
            );
    }
    // =========================================================
    // ALLOWED FILE
    // =========================================================
    private boolean isAllowedExtension(
            String extension) {
        return
            ".pdf".equals(
                extension
            )
            ||
            ".jpg".equals(
                extension
            )
            ||
            ".jpeg".equals(
                extension
            )
            ||
            ".png".equals(
                extension
            )
            ||
            ".doc".equals(
                extension
            )
            ||
            ".docx".equals(
                extension
            );
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
    // NULLABLE INTEGER
    // =========================================================
    private void setNullableInteger(
            PreparedStatement ps,
            int index,
            Integer value)
            throws SQLException {
        if (value == null) {
            ps.setNull(
                index,
                Types.INTEGER
            );
        } else {
            ps.setInt(
                index,
                value
            );
        }
    }
    // =========================================================
    // REDIRECT
    // =========================================================
    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            String error)
            throws IOException {
        response.sendRedirect(
            request.getContextPath()
            + "/apply?error="
            + error
        );
    }
    // =========================================================
    // ROLLBACK
    // =========================================================
    private void rollbackQuietly(
            Connection con) {
        if (con == null) {
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
    // BALANCE SNAPSHOT
    // =========================================================
    private static class BalanceSnapshot {
        int before;
        int after;
        BalanceSnapshot(
                int before,
                int after) {
            this.before =
                before;
            this.after =
                after;
        }
    }
}