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





@WebServlet(

    name = "ApprovalServlet",

    urlPatterns = {"/approval"}

)

public class ApprovalServlet extends HttpServlet {



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





    // =========================================================

    // GET

    // =========================================================



    @Override

    protected void doGet(

            HttpServletRequest request,

            HttpServletResponse response)

            throws ServletException, IOException {



        response.sendRedirect(

            request.getContextPath()

            + "/admin"

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

                request.getContextPath()

                + "/"

            );



            return;

        }





        Integer currentUserId =

            getUserId(session);



        if (currentUserId == null) {



            session.invalidate();



            response.sendRedirect(

                request.getContextPath()

                + "/"

            );



            return;

        }





        String currentRole =

            session.getAttribute("userRole") == null

                ? ""

                : session

                    .getAttribute("userRole")

                    .toString()

                    .trim()

                    .toUpperCase();





        boolean isHOD =

            "HOD".equals(currentRole);



        boolean isManagement =

            "MANAGEMENT".equals(

                currentRole

            );





        if (

            !isHOD

            &&

            !isManagement

        ) {



            response.sendError(

                HttpServletResponse.SC_FORBIDDEN

            );



            return;

        }





        Integer applicationId =

            parsePositiveInteger(

                request.getParameter("id")

            );





        String action =

            trim(

                request.getParameter(

                    "action"

                )

            );





        String remarks =

            trim(

                request.getParameter(

                    "remarks"

                )

            );





        if (

            applicationId == null

            ||

            action == null

        ) {



            redirectError(

                request,

                response,

                "invalid"

            );



            return;

        }





        action =

            action.toUpperCase();





        // =====================================================

        // ROLE ACTIONS

        // =====================================================



        if (

            isHOD

            &&

            !(

                "SUPPORT".equals(action)

                ||

                "NOT_SUPPORT".equals(action)

            )

        ) {



            redirectError(

                request,

                response,

                "unauthorized"

            );



            return;

        }





        if (

            isManagement

            &&

            !(

                "APPROVE".equals(action)

                ||

                "REJECT".equals(action)

            )

        ) {



            redirectError(

                request,

                response,

                "unauthorized"

            );



            return;

        }





        if (

            (

                "NOT_SUPPORT".equals(action)

                ||

                "REJECT".equals(action)

            )

            &&

            remarks == null

        ) {



            redirectError(

                request,

                response,

                "remarksRequired"

            );



            return;

        }





        Connection con =

            null;





        try {



            con =

                DBConnection.getConnection();



            con.setAutoCommit(false);





            // =================================================

            // LOCK APPLICATION

            //

            // application_no ditambah untuk Audit Trail.

            // =================================================



            String applicationSql = """



                SELECT



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



                    u.hod_id



                FROM leave_applications la



                JOIN users u

                    ON u.id = la.user_id



                LEFT JOIN leave_types lt

                    ON lt.leave_type_id =

                       la.leave_type_id



                WHERE la.id = ?



                FOR UPDATE



            """;





            String applicationNo;



            int leaveUserId;



            Integer leaveTypeId;



            String leaveTypeName;



            int duration;



            LocalDate startDate;



            String oldStatus;



            Integer assignedHodId;





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





                try (

                    ResultSet rs =

                        ps.executeQuery()

                ) {



                    if (!rs.next()) {



                        con.rollback();



                        redirectError(

                            request,

                            response,

                            "notFound"

                        );



                        return;

                    }





                    applicationNo =

                        rs.getString(

                            "application_no"

                        );





                    leaveUserId =

                        rs.getInt(

                            "user_id"

                        );





                    int leaveTypeValue =

                        rs.getInt(

                            "leave_type_id"

                        );





                    leaveTypeId =

                        rs.wasNull()

                            ? null

                            : leaveTypeValue;





                    leaveTypeName =

                        rs.getString(

                            "leave_type_name"

                        );





                    duration =

                        rs.getInt(

                            "duration"

                        );





                    java.sql.Date sqlStart =

                        rs.getDate(

                            "start_date"

                        );





                    if (sqlStart == null) {



                        throw new SQLException(

                            "Tarikh mula tidak ditemui."

                        );

                    }





                    startDate =

                        sqlStart.toLocalDate();





                    oldStatus =

                        rs.getString(

                            "status"

                        );





                    int hodValue =

                        rs.getInt(

                            "hod_id"

                        );





                    assignedHodId =

                        rs.wasNull()

                            ? null

                            : hodValue;

                }

            }





            // =================================================

            // FINAL STATUS

            // =================================================



            if (

                "APPROVED".equalsIgnoreCase(

                    oldStatus

                )

                ||

                "REJECTED".equalsIgnoreCase(

                    oldStatus

                )

                ||

                "CANCELLED".equalsIgnoreCase(

                    oldStatus

                )

            ) {



                con.rollback();



                redirectError(

                    request,

                    response,

                    "final"

                );



                return;

            }





            if (

                !isPendingStatus(

                    oldStatus

                )

            ) {



                con.rollback();



                redirectError(

                    request,

                    response,

                    "invalidStatus"

                );



                return;

            }





         // =========================================================

         // HOD

         //

         // Sokongan Ketua Unit adalah OPTIONAL.

         //

         // IMPORTANT:

         // - HOD boleh Sokong / Tidak Sokong.

         // - Keputusan HOD disimpan dalam leave_approvals.

         // - Keputusan HOD TIDAK menentukan status utama permohonan.

         // - Pengurusan boleh membuat keputusan walaupun HOD

         //   belum memberi sokongan.

         // =========================================================



         if (isHOD) {



             // =====================================================

             // PASTIKAN PERMOHONAN ADALAH STAF BAWAH SELIAAN HOD

             // =====================================================



             if (

                 assignedHodId == null

                 ||

                 assignedHodId.intValue()

                     != currentUserId.intValue()

             ) {



                 con.rollback();



                 response.sendError(

                     HttpServletResponse.SC_FORBIDDEN,

                     "Anda tidak dibenarkan menyemak permohonan ini."

                 );



                 return;

             }





             // =====================================================

             // HOD HANYA BOLEH BERI KEPUTUSAN SEKALI

             // =====================================================



             if (

                 hasCompletedApproval(

                     con,

                     applicationId,

                     "HEAD_OF_UNIT"

                 )

             ) {



                 con.rollback();



                 redirectError(

                     request,

                     response,

                     "alreadyReviewed"

                 );



                 return;

             }





             // =====================================================

             // SUPPORT

             // =====================================================



             if ("SUPPORT".equals(action)) {



                 saveApproval(

                     con,

                     applicationId,

                     currentUserId,

                     "HEAD_OF_UNIT",

                     "SUPPORTED",

                     remarks

                 );





                 // Tutup notifikasi tindakan HOD sahaja.

                 NotificationUtil.markReferenceTypeRead(

                     con,

                     "LEAVE",

                     applicationId,

                     "LEAVE_HOD_REVIEW"

                 );





                 // =================================================

                 // NOTIFY MANAGEMENT

                 // =================================================



                 NotificationUtil.createForRole(

                     con,

                     "MANAGEMENT",

                     currentUserId,

                     "LEAVE_HOD_SUPPORTED",

                     "Permohonan Cuti Disokong Ketua Unit",

                     "Permohonan "

                         + applicationNo

                         + " telah disokong oleh Ketua Unit.",

                     "LEAVE",

                     applicationId

                 );





                 // =================================================

                 // NOTIFY APPLICANT

                 // =================================================



                 NotificationUtil.create(

                     con,

                     leaveUserId,

                     "LEAVE_HOD_SUPPORTED",

                     "Permohonan Cuti Disokong",

                     "Permohonan "

                         + leaveTypeName

                         + " anda telah disokong oleh Ketua Unit "

                         + "dan sedang menunggu keputusan Pengurusan.",

                     "LEAVE",

                     applicationId

                 );





                 // =================================================

                 // AUDIT TRAIL

                 // =================================================



                 ActivityLogUtil.log(

                     con,

                     request,

                     "HOD_SUPPORT_LEAVE",

                     "Menyokong permohonan cuti "

                         + applicationNo,

                     "LEAVE_APPLICATION",

                     applicationId

                 );





                 /*

                  * PENTING:

                  *

                  * JANGAN panggil:

                  *

                  * moveLegacyApplicationToManagement(...)

                  *

                  * Sokongan HOD tidak mengawal workflow.

                  * Status permohonan kekal seperti sedia ada.

                  */





                 con.commit();





                 response.sendRedirect(

                     request.getContextPath()

                     + "/admin?success=supported"

                 );



                 return;

             }





             // =====================================================

             // NOT SUPPORT

             // =====================================================



             if ("NOT_SUPPORT".equals(action)) {



                 saveApproval(

                     con,

                     applicationId,

                     currentUserId,

                     "HEAD_OF_UNIT",

                     "NOT_SUPPORTED",

                     remarks

                 );





                 // Tutup notifikasi tindakan HOD.

                 NotificationUtil.markReferenceTypeRead(

                     con,

                     "LEAVE",

                     applicationId,

                     "LEAVE_HOD_REVIEW"

                 );





                 // =================================================

                 // NOTIFY MANAGEMENT

                 // =================================================



                 NotificationUtil.createForRole(

                     con,

                     "MANAGEMENT",

                     currentUserId,

                     "LEAVE_HOD_NOT_SUPPORTED",

                     "Permohonan Cuti Tidak Disokong Ketua Unit",

                     "Permohonan "

                         + applicationNo

                         + " tidak disokong oleh Ketua Unit."

                         + (

                             remarks != null

                             && !remarks.isBlank()

                                 ? " Catatan: " + remarks.trim()

                                 : ""

                         ),

                     "LEAVE",

                     applicationId

                 );





                 // =================================================

                 // NOTIFY APPLICANT

                 // =================================================



                 String hodNotSupportMessage =

                     "Permohonan "

                     + leaveTypeName

                     + " anda tidak disokong oleh Ketua Unit."

                     + " Permohonan masih menunggu keputusan Pengurusan.";





                 if (

                     remarks != null

                     &&

                     !remarks.isBlank()

                 ) {



                     hodNotSupportMessage +=

                         " Catatan: "

                         + remarks.trim();

                 }





                 NotificationUtil.create(

                     con,

                     leaveUserId,

                     "LEAVE_HOD_NOT_SUPPORTED",

                     "Permohonan Cuti Tidak Disokong Ketua Unit",

                     hodNotSupportMessage,

                     "LEAVE",

                     applicationId

                 );





                 // =================================================

                 // AUDIT TRAIL

                 // =================================================



                 ActivityLogUtil.log(

                     con,

                     request,

                     "HOD_NOT_SUPPORT_LEAVE",

                     "Tidak menyokong permohonan cuti "

                         + applicationNo,

                     "LEAVE_APPLICATION",

                     applicationId

                 );





                 /*

                  * PENTING:

                  *

                  * NOT_SUPPORTED bukan REJECTED.

                  *

                  * Permohonan TIDAK dibatalkan.

                  * Permohonan TIDAK ditolak.

                  * Pengurusan masih boleh meluluskan permohonan.

                  *

                  * Oleh itu jangan ubah leave_applications.status.

                  */





                 con.commit();





                 response.sendRedirect(

                     request.getContextPath()

                     + "/admin?success=notSupported"

                 );



                 return;

             }

         }





            // =================================================

            // MANAGEMENT

            // =================================================



            if (isManagement) {





                if (

                    !"PENDING_MANAGEMENT"

                        .equalsIgnoreCase(

                            oldStatus

                        )

                ) {



                    moveLegacyApplicationToManagement(

                        con,

                        applicationId

                    );

                }





                // =============================================

                // APPROVE

                // =============================================



                if (

                    "APPROVE".equals(

                        action

                    )

                ) {





                    if (

                        leaveTypeId == null

                        ||

                        leaveTypeName == null

                    ) {



                        con.rollback();



                        redirectError(

                            request,

                            response,

                            "missingLeaveType"

                        );



                        return;

                    }





                    if (duration <= 0) {



                        con.rollback();



                        redirectError(

                            request,

                            response,

                            "invalidDuration"

                        );



                        return;

                    }





                    int leaveYear =

                        startDate.getYear();





                    // =========================================

                    // DEDUCT / RECORD LEAVE

                    // =========================================



                    if (

                        isSharedLeave(

                            leaveTypeName

                        )

                    ) {



                        // Pastikan baki shared untuk tahun permohonan wujud.

                        // Entitlement diambil daripada konfigurasi staff, bukan hardcode 30.

                        ensureSharedBalanceForYear(

                            con,

                            leaveUserId,

                            leaveYear

                        );



                        deductSharedLeaveBalance(

                            con,

                            applicationId,

                            leaveUserId,

                            leaveTypeId,

                            leaveYear,

                            duration

                        );



                    } else if (

                        isNoBalanceRestrictionLeave(

                            leaveTypeName

                        )

                    ) {



                        recordUnrestrictedLeaveUsage(

                            con,

                            leaveUserId,

                            leaveTypeId,

                            leaveYear,

                            duration

                        );



                    } else {



                        deductNormalLeaveBalance(

                            con,

                            leaveUserId,

                            leaveTypeId,

                            leaveYear,

                            duration

                        );

                    }





                    updateFinalApplication(

                        con,

                        applicationId,

                        "APPROVED",

                        null,

                        currentUserId

                    );





                    saveApproval(

                        con,

                        applicationId,

                        currentUserId,

                        "MANAGEMENT",

                        "APPROVED",

                        remarks

                    );





                    // =========================================

                    // CLOSE ACTION NOTIFICATIONS

                    // =========================================



                    NotificationUtil

                        .markReferenceTypeRead(

                            con,

                            "LEAVE",

                            applicationId,

                            "LEAVE_HOD_REVIEW"

                        );





                    NotificationUtil

                        .markReferenceTypeRead(

                            con,

                            "LEAVE",

                            applicationId,

                            "LEAVE_MANAGEMENT_REVIEW"

                        );





                    // =========================================

                    // NOTIFY APPLICANT

                    // =========================================



                    NotificationUtil.create(

                        con,

                        leaveUserId,

                        "LEAVE_APPROVED",

                        "Permohonan Cuti Diluluskan",

                        "Permohonan "

                        + leaveTypeName

                        + " anda telah diluluskan oleh Pengurusan.",

                        "LEAVE",

                        applicationId

                    );





                    // =========================================

                    // AUDIT TRAIL - MANAGEMENT APPROVE

                    // =========================================



                    ActivityLogUtil.log(

                        con,

                        request,

                        "MANAGEMENT_APPROVE_LEAVE",

                        "Meluluskan permohonan cuti "

                            + applicationNo

                            + " ("

                            + leaveTypeName

                            + ", "

                            + duration

                            + " hari)",

                        "LEAVE_APPLICATION",

                        applicationId

                    );





                    con.commit();





                    response.sendRedirect(

                        request.getContextPath()

                        + "/admin?success=approved"

                    );



                    return;

                }





                // =============================================

                // REJECT

                // =============================================



                if (

                    "REJECT".equals(action)

                ) {



                    updateFinalApplication(

                        con,

                        applicationId,

                        "REJECTED",

                        remarks,

                        currentUserId

                    );





                    saveApproval(

                        con,

                        applicationId,

                        currentUserId,

                        "MANAGEMENT",

                        "REJECTED",

                        remarks

                    );





                    NotificationUtil

                        .markReferenceTypeRead(

                            con,

                            "LEAVE",

                            applicationId,

                            "LEAVE_HOD_REVIEW"

                        );





                    NotificationUtil

                        .markReferenceTypeRead(

                            con,

                            "LEAVE",

                            applicationId,

                            "LEAVE_MANAGEMENT_REVIEW"

                        );





                    String message =

                        "Permohonan "

                        + leaveTypeName

                        + " anda tidak diluluskan oleh Pengurusan.";





                    if (

                        remarks != null

                        &&

                        !remarks.isBlank()

                    ) {



                        message +=

                            " Alasan: "

                            + remarks.trim();

                    }





                    NotificationUtil.create(

                        con,

                        leaveUserId,

                        "LEAVE_REJECTED",

                        "Permohonan Cuti Tidak Diluluskan",

                        message,

                        "LEAVE",

                        applicationId

                    );





                    // =========================================

                    // AUDIT TRAIL - MANAGEMENT REJECT

                    //

                    // Remarks tidak dimasukkan ke audit untuk

                    // elakkan teks bebas/sensitif memenuhi log.

                    // =========================================



                    ActivityLogUtil.log(

                        con,

                        request,

                        "MANAGEMENT_REJECT_LEAVE",

                        "Menolak permohonan cuti "

                            + applicationNo,

                        "LEAVE_APPLICATION",

                        applicationId

                    );





                    con.commit();





                    response.sendRedirect(

                        request.getContextPath()

                        + "/admin?success=rejected"

                    );



                    return;

                }

            }





            con.rollback();





            redirectError(

                request,

                response,

                "invalid"

            );





        } catch (

            InsufficientLeaveException e

        ) {



            rollbackQuietly(con);





            response.sendRedirect(

                request.getContextPath()

                + "/admin?error=insufficientLeave"

            );





        } catch (

            BalanceNotFoundException e

        ) {



            rollbackQuietly(con);





            response.sendRedirect(

                request.getContextPath()

                + "/admin?error=balanceNotFound"

            );





        } catch (Exception e) {



            rollbackQuietly(con);





            throw new ServletException(

                "Ralat semasa memproses permohonan cuti.",

                e

            );





        } finally {



            if (con != null) {



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

        }

    }





    // =========================================================

    // SHARED TYPE

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



    private boolean isNoBalanceRestrictionLeave(

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



        // Jika staff belum pernah mempunyai konfigurasi Cuti Tahunan,

        // jangan cipta entitlement secara andaian.

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

    // SHARED DEDUCTION

    // =========================================================



    private void deductSharedLeaveBalance(

            Connection con,

            int applicationId,

            int userId,

            int selectedLeaveTypeId,

            int leaveYear,

            int duration)

            throws SQLException,

                   InsufficientLeaveException,

                   BalanceNotFoundException {



        // =====================================================

        // SHARED BALANCE CONFIGURATION

        // =====================================================

        //

        // Cuti Tahunan (ID = 1) ialah SATU-SATUNYA row

        // yang menyimpan baki bersama untuk:

        //

        // - Cuti Tahunan

        // - Cuti Kecemasan

        //

        // selectedLeaveTypeId masih diterima kerana method ini

        // dipanggil oleh kedua-dua jenis permohonan.

        // =====================================================



        final int ANNUAL_LEAVE_ID = 1;

        final int EMERGENCY_LEAVE_ID = 2;





        // =====================================================

        // VALIDATE SELECTED LEAVE TYPE

        // =====================================================



        if (selectedLeaveTypeId != ANNUAL_LEAVE_ID

                && selectedLeaveTypeId != EMERGENCY_LEAVE_ID) {



            throw new SQLException(

                "Jenis cuti tidak sah untuk baki cuti bersama."

            );

        }





        if (duration <= 0) {



            throw new SQLException(

                "Tempoh cuti tidak sah."

            );

        }





        // =====================================================

        // LOCK ANNUAL LEAVE BALANCE

        // =====================================================

        //

        // Walaupun permohonan ialah Cuti Kecemasan,

        // baki tetap diambil daripada row Cuti Tahunan.

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





        try (PreparedStatement ps =

                con.prepareStatement(selectSql)) {



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

        // VALIDATE CURRENT BALANCE

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

        // CALCULATE EXISTING USAGE

        // =====================================================

        //

        // used_days =

        // jumlah penggunaan CF + entitlement semasa.

        //

        // carry_forward_used =

        // bahagian daripada used_days yang datang daripada CF.

        // =====================================================



        int currentYearUsed =

            usedDays - carryForwardUsed;





        if (currentYearUsed < 0

                || currentYearUsed > entitlement) {



            throw new SQLException(

                "Penggunaan peruntukan tahun semasa tidak sah."

            );

        }





        // =====================================================

        // CURRENT AVAILABLE BALANCE

        // =====================================================



        int carryForwardRemaining =

            carryForwardDays - carryForwardUsed;





        int currentYearRemaining =

            entitlement - currentYearUsed;





        int totalRemaining =

            carryForwardRemaining

            + currentYearRemaining;





        // =====================================================

        // CHECK SUFFICIENT BALANCE

        // =====================================================



        if (totalRemaining < duration) {



            throw new InsufficientLeaveException();

        }





        // =====================================================

        // USE CARRY FORWARD FIRST

        // =====================================================

        //

        // Contoh:

        //

        // CF remaining = 5

        // Permohonan   = 3

        //

        // CF used      = 3

        // Current used = 0

        //

        //

        // CF remaining = 5

        // Permohonan   = 8

        //

        // CF used      = 5

        // Current used = 3

        // =====================================================



        int carryForwardUsedForApplication =

            Math.min(

                duration,

                carryForwardRemaining

            );





        int currentYearUsedForApplication =

            duration

            - carryForwardUsedForApplication;





        // =====================================================

        // FINAL SAFETY CHECK

        // =====================================================



        if (currentYearUsedForApplication

                > currentYearRemaining) {



            throw new InsufficientLeaveException();

        }





        // =====================================================

        // CALCULATE NEW VALUES

        // =====================================================



        int newCarryForwardUsed =

            carryForwardUsed

            + carryForwardUsedForApplication;





        int newUsedDays =

            usedDays

            + duration;





        int newCarryForwardRemaining =

            carryForwardDays

            - newCarryForwardUsed;





        int newCurrentYearUsed =

            currentYearUsed

            + currentYearUsedForApplication;





        int newCurrentYearRemaining =

            entitlement

            - newCurrentYearUsed;





        int newRemainingDays =

            newCarryForwardRemaining

            + newCurrentYearRemaining;





        // =====================================================

        // FINAL VALIDATION

        // =====================================================



        if (newCarryForwardUsed < 0

                || newCarryForwardUsed > carryForwardDays

                || newCurrentYearUsed < 0

                || newCurrentYearUsed > entitlement

                || newRemainingDays < 0) {



            throw new SQLException(

                "Pengiraan baki cuti selepas kelulusan tidak sah."

            );

        }





        // =====================================================

        // UPDATE ANNUAL SHARED BALANCE

        // =====================================================

        //

        // HANYA Cuti Tahunan (ID = 1) dikemas kini.

        // =====================================================



        String updateAnnualSql = """

            UPDATE leave_balances

            SET

                carry_forward_used = ?,

                used_days = ?,

                remaining_days = ?

            WHERE user_id = ?

              AND leave_type_id = ?

              AND leave_year = ?

            """;





        try (PreparedStatement ps =

                con.prepareStatement(updateAnnualSql)) {



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





            if (ps.executeUpdate() != 1) {



                throw new BalanceNotFoundException();

            }

        }





        // =====================================================

        // KEEP EMERGENCY BALANCE AT ZERO

        // =====================================================

        //

        // Cuti Kecemasan hanya jenis permohonan.

        // Ia TIDAK menyimpan baki sendiri.

        //

        // Row Emergency boleh kekal dalam database untuk

        // compatibility dengan bahagian sistem yang lain.

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

              AND leave_type_id = ?

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

                EMERGENCY_LEAVE_ID

            );



            ps.setInt(

                3,

                leaveYear

            );



            ps.executeUpdate();

        }





        // =====================================================

        // SAVE APPLICATION USAGE BREAKDOWN

        // =====================================================

        //

        // Ini sangat penting untuk:

        //

        // - pembatalan cuti

        // - restore balance

        // - audit penggunaan CF

        //

        // Contoh permohonan 8 hari:

        //

        // carry_forward_days_used = 5

        // current_year_days_used   = 3

        // =====================================================



        String updateApplicationUsageSql = """

            UPDATE leave_applications

            SET

                carry_forward_days_used = ?,

                current_year_days_used = ?

            WHERE id = ?

            """;





        try (PreparedStatement ps =

                con.prepareStatement(

                    updateApplicationUsageSql

                )) {



            ps.setInt(

                1,

                carryForwardUsedForApplication

            );



            ps.setInt(

                2,

                currentYearUsedForApplication

            );



            ps.setInt(

                3,

                applicationId

            );





            if (ps.executeUpdate() != 1) {



                throw new SQLException(

                    "Pecahan penggunaan cuti tidak dapat disimpan."

                );

            }

        }

    }





    // =========================================================

    // NORMAL DEDUCTION

    // =========================================================



    private void deductNormalLeaveBalance(

            Connection con,

            int userId,

            int leaveTypeId,

            int leaveYear,

            int duration)

            throws SQLException,

                   InsufficientLeaveException,

                   BalanceNotFoundException {





        String selectSql = """



            SELECT

                used_days,

                remaining_days



            FROM leave_balances



            WHERE user_id = ?

              AND leave_type_id = ?

              AND leave_year = ?



            FOR UPDATE



        """;





        int usedDays;



        int remainingDays;





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



                if (!rs.next()) {



                    throw new BalanceNotFoundException();

                }





                usedDays =

                    rs.getInt(

                        "used_days"

                    );





                remainingDays =

                    rs.getInt(

                        "remaining_days"

                    );

            }

        }





        if (

            remainingDays < duration

        ) {



            throw new InsufficientLeaveException();

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

                usedDays + duration

            );





            ps.setInt(

                2,

                remainingDays - duration

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





            if (

                ps.executeUpdate() != 1

            ) {



                throw new BalanceNotFoundException();

            }

        }

    }





    // =========================================================

    // UNRESTRICTED LEAVE

    // =========================================================



    private void recordUnrestrictedLeaveUsage(

            Connection con,

            int userId,

            int leaveTypeId,

            int leaveYear,

            int duration)

            throws SQLException {





        String selectSql = """



            SELECT

                used_days,

                remaining_days



            FROM leave_balances



            WHERE user_id = ?

              AND leave_type_id = ?

              AND leave_year = ?



            FOR UPDATE



        """;





        Integer usedDays =

            null;





        Integer remainingDays =

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



                if (rs.next()) {



                    usedDays =

                        rs.getInt(

                            "used_days"

                        );





                    remainingDays =

                        rs.getInt(

                            "remaining_days"

                        );

                }

            }

        }





        // No quota row is valid.

        if (usedDays == null) {



            return;

        }





        int newRemaining =

            Math.max(

                0,

                remainingDays - duration

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

                usedDays + duration

            );





            ps.setInt(

                2,

                newRemaining

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





            ps.executeUpdate();

        }

    }





    // =========================================================

    // HAS HOD REVIEWED?

    // =========================================================



    private boolean hasCompletedApproval(

            Connection con,

            int applicationId,

            String level)

            throws SQLException {





        String sql = """



            SELECT COUNT(*)



            FROM leave_approvals



            WHERE leave_id = ?

              AND approval_level = ?



              AND decision IN

              (

                  'SUPPORTED',

                  'NOT_SUPPORTED',

                  'APPROVED',

                  'REJECTED'

              )



        """;





        try (

            PreparedStatement ps =

                con.prepareStatement(sql)

        ) {



            ps.setInt(

                1,

                applicationId

            );





            ps.setString(

                2,

                level

            );





            try (

                ResultSet rs =

                    ps.executeQuery()

            ) {



                return

                    rs.next()

                    &&

                    rs.getInt(1) > 0;

            }

        }

    }





    // =========================================================

    // SAVE APPROVAL

    // =========================================================



    private void saveApproval(

            Connection con,

            int applicationId,

            int approverId,

            String level,

            String decision,

            String remarks)

            throws SQLException {





        String updateSql = """



            UPDATE leave_approvals



            SET

                approver_id = ?,

                decision = ?,

                remarks = ?,

                decision_date =

                    CURRENT_TIMESTAMP



            WHERE approval_id =

            (

                SELECT approval_id



                FROM

                (

                    SELECT approval_id



                    FROM leave_approvals



                    WHERE leave_id = ?

                      AND approval_level = ?



                    ORDER BY approval_id DESC



                    LIMIT 1

                ) x

            )



        """;





        int affected;





        try (

            PreparedStatement ps =

                con.prepareStatement(

                    updateSql

                )

        ) {



            ps.setInt(

                1,

                approverId

            );





            ps.setString(

                2,

                decision

            );





            if (remarks == null) {



                ps.setNull(

                    3,

                    java.sql.Types.VARCHAR

                );



            } else {



                ps.setString(

                    3,

                    remarks

                );

            }





            ps.setInt(

                4,

                applicationId

            );





            ps.setString(

                5,

                level

            );





            affected =

                ps.executeUpdate();

        }





        // =====================================================

        // MISSING ROW

        // =====================================================



        if (affected == 0) {





            String insertSql = """



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

                    ?,

                    ?,

                    ?,

                    CURRENT_TIMESTAMP

                )



            """;





            try (

                PreparedStatement ps =

                    con.prepareStatement(

                        insertSql

                    )

            ) {



                ps.setInt(

                    1,

                    applicationId

                );





                ps.setInt(

                    2,

                    approverId

                );





                ps.setString(

                    3,

                    level

                );





                ps.setString(

                    4,

                    decision

                );





                if (remarks == null) {



                    ps.setNull(

                        5,

                        java.sql.Types.VARCHAR

                    );



                } else {



                    ps.setString(

                        5,

                        remarks

                    );

                }





                ps.executeUpdate();

            }

        }

    }





    // =========================================================

    // FINAL APPLICATION

    // =========================================================



    private void updateFinalApplication(

            Connection con,

            int applicationId,

            String status,

            String remarks,

            int reviewerId)

            throws SQLException {





        String sql = """



            UPDATE leave_applications



            SET

                status = ?,

                remarks = ?,

                reviewed_at =

                    CURRENT_TIMESTAMP,

                reviewed_by = ?



            WHERE id = ?



        """;





        try (

            PreparedStatement ps =

                con.prepareStatement(sql)

        ) {



            ps.setString(

                1,

                status

            );





            if (remarks == null) {



                ps.setNull(

                    2,

                    java.sql.Types.VARCHAR

                );



            } else {



                ps.setString(

                    2,

                    remarks

                );

            }





            ps.setInt(

                3,

                reviewerId

            );





            ps.setInt(

                4,

                applicationId

            );





            if (

                ps.executeUpdate() != 1

            ) {



                throw new SQLException(

                    "Status permohonan gagal dikemas kini."

                );

            }

        }

    }





    // =========================================================

    // LEGACY PENDING -> MANAGEMENT

    // =========================================================



    private void moveLegacyApplicationToManagement(

            Connection con,

            int applicationId)

            throws SQLException {





        String sql = """



            UPDATE leave_applications



            SET status =

                'PENDING_MANAGEMENT'



            WHERE id = ?



              AND status IN

              (

                  'PENDING',

                  'PENDING_HEAD',

                  'PENDING_ADMIN'

              )



        """;





        try (

            PreparedStatement ps =

                con.prepareStatement(sql)

        ) {



            ps.setInt(

                1,

                applicationId

            );





            ps.executeUpdate();

        }

    }





    // =========================================================

    // PENDING STATUS

    // =========================================================



    private boolean isPendingStatus(

            String status) {



        if (status == null) {



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



            int id =

                Integer.parseInt(

                    session

                        .getAttribute("userId")

                        .toString()

                );





            return id > 0

                ? id

                : null;



        } catch (Exception e) {



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



            int id =

                Integer.parseInt(

                    value.trim()

                );





            return id > 0

                ? id

                : null;



        } catch (Exception e) {



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

    // REDIRECT ERROR

    // =========================================================



    private void redirectError(

            HttpServletRequest request,

            HttpServletResponse response,

            String error)

            throws IOException {



        response.sendRedirect(

            request.getContextPath()

            + "/admin?error="

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

    // EXCEPTIONS

    // =========================================================



    private static class

            InsufficientLeaveException

            extends Exception {



        private static final long serialVersionUID =

            1L;

    }





    private static class

            BalanceNotFoundException

            extends Exception {



        private static final long serialVersionUID =

            1L;

    }

}