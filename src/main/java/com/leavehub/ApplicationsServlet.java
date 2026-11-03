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



import java.util.ArrayList;

import java.util.HashMap;

import java.util.List;

import java.util.Map;
import java.time.LocalDate;
import java.sql.Date;





@WebServlet("/applications")

public class ApplicationsServlet extends HttpServlet {



    private static final long serialVersionUID = 1L;





    // =========================================================

    // GET

    // LOAD USER LEAVE APPLICATIONS

    // =========================================================



    @Override

    protected void doGet(

            HttpServletRequest req,

            HttpServletResponse resp)

            throws ServletException, IOException {





        // =====================================================

        // CHECK LOGIN

        // =====================================================



        HttpSession session =

                req.getSession(false);





        if (

            session == null

            ||

            session.getAttribute("userId") == null

        ) {



            resp.sendRedirect(

                req.getContextPath() + "/"

            );



            return;

        }





        Integer userId =

                getUserId(session);





        if (userId == null) {



            session.invalidate();



            resp.sendRedirect(

                req.getContextPath() + "/"

            );



            return;

        }





        // =====================================================

        // SQL

        // =====================================================



        String sql = """



            SELECT

                la.id,

                la.application_no,

                la.leave_type_id,



                COALESCE(

                    lt.leave_type_name,

                    la.leave_type

                ) AS leave_type_name,



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

                la.remarks,

                la.submitted_at,

                la.reviewed_at,

                la.reviewed_by,



                hodApproval.decision

                    AS hod_decision,



                hodApproval.remarks

                    AS hod_remarks,



                hodApproval.decision_date

                    AS hod_decision_date,



                hodUser.name

                    AS hod_name,



                managementApproval.decision

                    AS management_decision,



                managementApproval.remarks

                    AS management_remarks,



                managementApproval.decision_date

                    AS management_decision_date,



                managementUser.name

                    AS management_name



            FROM leave_applications la



            LEFT JOIN leave_types lt

                ON lt.leave_type_id =

                   la.leave_type_id



            LEFT JOIN leave_approvals hodApproval

                ON hodApproval.approval_id =

                (

                    SELECT MAX(ha.approval_id)



                    FROM leave_approvals ha



                    WHERE ha.leave_id = la.id

                      AND ha.approval_level =

                          'HEAD_OF_UNIT'

                )



            LEFT JOIN users hodUser

                ON hodUser.id =

                   hodApproval.approver_id



            LEFT JOIN leave_approvals managementApproval

                ON managementApproval.approval_id =

                (

                    SELECT MAX(ma.approval_id)



                    FROM leave_approvals ma



                    WHERE ma.leave_id = la.id

                      AND ma.approval_level =

                          'MANAGEMENT'

                )



            LEFT JOIN users managementUser

                ON managementUser.id =

                   managementApproval.approver_id



            WHERE la.user_id = ?



            ORDER BY

                la.submitted_at DESC,

                la.id DESC



        """;





        List<Map<String, Object>> applications =

                new ArrayList<>();





        try (

            Connection con =

                    DBConnection.getConnection();



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





                while (

                    rs.next()

                ) {





                    Map<String, Object> row =

                            new HashMap<>();





                    // =========================================

                    // BASIC

                    // =========================================



                    int id =

                            rs.getInt(

                                "id"

                            );





                    row.put(

                        "id",

                        id

                    );





                    String applicationNo =

                            rs.getString(

                                "application_no"

                            );





                    if (

                        applicationNo == null

                        ||

                        applicationNo.isBlank()

                    ) {



                        applicationNo =

                                "PKB-CUTI-" + id;

                    }





                    row.put(

                        "applicationNo",

                        applicationNo

                    );





                    // =========================================

                    // LEAVE TYPE

                    // =========================================



                    Integer leaveTypeId =

                            null;





                    int leaveTypeValue =

                            rs.getInt(

                                "leave_type_id"

                            );





                    if (

                        !rs.wasNull()

                    ) {



                        leaveTypeId =

                                leaveTypeValue;

                    }





                    row.put(

                        "leaveTypeId",

                        leaveTypeId

                    );





                    String leaveTypeName =

                            rs.getString(

                                "leave_type_name"

                            );





                    if (

                        leaveTypeName == null

                        ||

                        leaveTypeName.isBlank()

                    ) {



                        leaveTypeName =

                                "—";

                    }





                    row.put(

                        "type",

                        leaveTypeName

                    );





                    row.put(

                        "otherLeaveType",

                        rs.getString(

                            "other_leave_type"

                        )

                    );





                    // =========================================

                    // DATE

                    // =========================================



                    row.put(

                        "start",

                        rs.getDate(

                            "start_date"

                        )

                    );





                    row.put(

                        "end",

                        rs.getDate(

                            "end_date"

                        )

                    );





                    // =========================================

                    // DURATION

                    // =========================================



                    int duration =

                            rs.getInt(

                                "duration"

                            );





                    row.put(

                        "duration",

                        duration

                    );





                    // =========================================

                    // BALANCE SNAPSHOT

                    // =========================================



                    int balanceBefore =

                            rs.getInt(

                                "balance_before"

                            );





                    row.put(

                        "balanceBefore",

                        rs.wasNull()

                            ? null

                            : balanceBefore

                    );





                    int balanceAfter =

                            rs.getInt(

                                "balance_after"

                            );





                    row.put(

                        "balanceAfter",

                        rs.wasNull()

                            ? null

                            : balanceAfter

                    );





                    row.put(

                        "balanceVerifiedBy",

                        rs.getString(

                            "balance_verified_by"

                        )

                    );





                    row.put(

                        "balanceVerifiedDate",

                        rs.getDate(

                            "balance_verified_date"

                        )

                    );





                    // =========================================

                    // APPLICATION INFORMATION

                    // =========================================



                    row.put(

                        "reason",

                        rs.getString(

                            "reason"

                        )

                    );





                    row.put(

                        "contactPhone",

                        rs.getString(

                            "contact_phone"

                        )

                    );





                    row.put(

                        "contactAddress",

                        rs.getString(

                            "contact_address"

                        )

                    );





                    row.put(

                        "handoverStaffName",

                        rs.getString(

                            "handover_staff_name"

                        )

                    );





                    row.put(

                        "attachment",

                        rs.getString(

                            "attachment"

                        )

                    );





                    // =========================================

                    // STATUS

                    // =========================================



                    String status =

                            rs.getString(

                                "status"

                            );





                    row.put(

                        "status",

                        status

                    );





                    row.put(

                        "statusLabel",

                        getStatusLabel(

                            status

                        )

                    );





                    boolean pending =

                            isPendingStatus(

                                status

                            );





                    boolean approved =

                            "APPROVED"

                                .equalsIgnoreCase(

                                    status

                                );





                    boolean rejected =

                            "REJECTED"

                                .equalsIgnoreCase(

                                    status

                                );





                    boolean cancelled =

                            "CANCELLED"

                                .equalsIgnoreCase(

                                    status

                                );





                    row.put(

                        "pending",

                        pending

                    );





                    row.put(

                        "approved",

                        approved

                    );





                    row.put(

                        "rejected",

                        rejected

                    );





                    row.put(

                        "cancelled",

                        cancelled

                    );





                    // =========================================

                    // APPLICATION REMARKS

                    // =========================================



                    row.put(

                        "remarks",

                        rs.getString(

                            "remarks"

                        )

                    );





                    // =========================================

                    // SUBMITTED / REVIEWED

                    // =========================================



                    row.put(

                        "submittedAt",

                        rs.getTimestamp(

                            "submitted_at"

                        )

                    );





                    row.put(

                        "reviewedAt",

                        rs.getTimestamp(

                            "reviewed_at"

                        )

                    );





                    Integer reviewedBy =

                            null;





                    int reviewedByValue =

                            rs.getInt(

                                "reviewed_by"

                            );





                    if (

                        !rs.wasNull()

                    ) {



                        reviewedBy =

                                reviewedByValue;

                    }





                    row.put(

                        "reviewedBy",

                        reviewedBy

                    );





                    // =========================================

                    // HOD

                    // =========================================



                    String hodDecision =

                            rs.getString(

                                "hod_decision"

                            );





                    row.put(

                        "hodDecision",

                        hodDecision

                    );





                    row.put(

                        "hodDecisionLabel",

                        getHodDecisionLabel(

                            hodDecision

                        )

                    );





                    row.put(

                        "hodRemarks",

                        rs.getString(

                            "hod_remarks"

                        )

                    );





                    row.put(

                        "hodDecisionDate",

                        rs.getTimestamp(

                            "hod_decision_date"

                        )

                    );





                    row.put(

                        "hodName",

                        rs.getString(

                            "hod_name"

                        )

                    );





                    // =========================================

                    // MANAGEMENT

                    // =========================================



                    String managementDecision =

                            rs.getString(

                                "management_decision"

                            );





                    row.put(

                        "managementDecision",

                        managementDecision

                    );





                    row.put(

                        "managementDecisionLabel",

                        getManagementDecisionLabel(

                            managementDecision

                        )

                    );





                    String managementRemarks =

                            rs.getString(

                                "management_remarks"

                            );





                    row.put(

                        "managementRemarks",

                        managementRemarks

                    );





                    row.put(

                        "managementDecisionDate",

                        rs.getTimestamp(

                            "management_decision_date"

                        )

                    );





                    row.put(

                        "managementName",

                        rs.getString(

                            "management_name"

                        )

                    );





                    // =========================================

                    // REJECTION REASON

                    // =========================================



                    String rejectionReason =

                            null;





                    if (

                        rejected

                    ) {



                        rejectionReason =

                                managementRemarks;





                        if (

                            rejectionReason == null

                            ||

                            rejectionReason.isBlank()

                        ) {



                            rejectionReason =

                                    rs.getString(

                                        "remarks"

                                    );

                        }

                    }





                    row.put(

                        "rejectionReason",

                        rejectionReason

                    );





                    // =========================================

                    // ACTION PERMISSIONS

                    // =========================================



                    row.put(

                        "canEdit",

                        pending

                    );





                    row.put(

                        "canCancel",

                        pending

                        ||

                        approved

                    );





                    row.put(

                        "canPrint",

                        true

                    );





                    applications.add(

                        row

                    );

                }

            }





            // =================================================

            // SEND TO JSP

            // =================================================



            req.setAttribute(

                "applications",

                applications

            );





            req.setAttribute(

                "pageTitle",

                "Permohonan Saya"

            );





            req

                .getRequestDispatcher(

                    "/applications.jsp"

                )

                .forward(

                    req,

                    resp

                );





        } catch (

            SQLException e

        ) {



            throw new ServletException(

                "Tidak dapat memuatkan senarai permohonan cuti.",

                e

            );

        }

    }





    // =========================================================

    // POST

    // HANDLE ACTION FROM APPLICATIONS PAGE

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

        // CHECK LOGIN

        // =====================================================



        HttpSession session =

                req.getSession(false);





        if (

            session == null

            ||

            session.getAttribute("userId") == null

        ) {



            resp.sendRedirect(

                req.getContextPath() + "/"

            );



            return;

        }





        Integer userId =

                getUserId(session);





        if (userId == null) {



            session.invalidate();



            resp.sendRedirect(

                req.getContextPath() + "/"

            );



            return;

        }





        // =====================================================

        // ACTION

        // =====================================================



        String action =

                clean(

                    req.getParameter(

                        "action"

                    )

                );





        if (

            "cancel".equalsIgnoreCase(

                action

            )

        ) {



            cancelApplication(

                req,

                resp,

                session,

                userId

            );



            return;

        }





        resp.sendRedirect(

            req.getContextPath()

            + "/applications?error=invalid"

        );

    }





 // =========================================================

 // CANCEL APPLICATION

 // =========================================================



 private void cancelApplication(

         HttpServletRequest req,

         HttpServletResponse resp,

         HttpSession session,

         Integer userId)

         throws ServletException, IOException {



     // =====================================================

     // APPLICATION ID

     // =====================================================



     String idText = clean(req.getParameter("id"));



     int applicationId;



     try {



         applicationId = Integer.parseInt(idText);



         if (applicationId <= 0) {

             throw new NumberFormatException();

         }



     } catch (NumberFormatException e) {



         resp.sendRedirect(

             req.getContextPath()

             + "/applications?error=invalid"

         );



         return;

     }





     Connection con = null;





     try {



         con = DBConnection.getConnection();

         con.setAutoCommit(false);





         // =================================================

         // GET APPLICATION INFORMATION

         // =================================================

         //

         // Get application number, current status and

         // leave type before cancelling.

         //

         // FOR UPDATE prevents another transaction from

         // modifying the same application simultaneously.

         // =================================================



         String checkSql = """



             SELECT

                 la.id,

                 la.application_no,

                 la.status,

                 la.start_date,

                 la.leave_type_id,

                 la.duration,

                 la.carry_forward_days_used,

                 la.current_year_days_used,



                 COALESCE(

                     lt.leave_type_name,

                     la.leave_type

                 ) AS leave_type_name,



                 la.other_leave_type



             FROM leave_applications la



             LEFT JOIN leave_types lt

                 ON lt.leave_type_id = la.leave_type_id



             WHERE la.id = ?

               AND la.user_id = ?



             FOR UPDATE



         """;





         String applicationNo = null;

         String currentStatus = null;

         String leaveTypeName = null;

         String otherLeaveType = null;

         Date startDate = null;

         Integer leaveTypeId = null;

         int duration = 0;

         int carryForwardDaysUsed = 0;

         int currentYearDaysUsed = 0;





         try (

             PreparedStatement ps =

                 con.prepareStatement(checkSql)

         ) {



             ps.setInt(1, applicationId);

             ps.setInt(2, userId);





             try (

                 ResultSet rs =

                     ps.executeQuery()

             ) {



                 if (!rs.next()) {



                     con.rollback();



                     resp.sendRedirect(

                         req.getContextPath()

                         + "/applications?error=notfound"

                     );



                     return;

                 }





                 applicationNo =

                     rs.getString("application_no");



                 currentStatus =

                     rs.getString("status");

                 startDate =

                     rs.getDate("start_date");



                 int leaveTypeIdValue =

                     rs.getInt("leave_type_id");



                 if (!rs.wasNull()) {

                     leaveTypeId = leaveTypeIdValue;

                 }



                 duration =

                     rs.getInt("duration");



                 carryForwardDaysUsed =

                     rs.getInt("carry_forward_days_used");



                 currentYearDaysUsed =

                     rs.getInt("current_year_days_used");



                 leaveTypeName =

                     rs.getString("leave_type_name");



                 otherLeaveType =

                     rs.getString("other_leave_type");

             }

         }





         // =================================================

         // FALLBACK APPLICATION NUMBER

         // =================================================



         if (

             applicationNo == null

             ||

             applicationNo.isBlank()

         ) {



             applicationNo =

                 "PKB-CUTI-" + applicationId;

         }





         // =================================================

         // LEAVE TYPE DISPLAY NAME

         // =================================================



         if (

             leaveTypeName == null

             ||

             leaveTypeName.isBlank()

         ) {



             leaveTypeName = "Cuti";

         }





         // Simpan nama jenis cuti asal untuk logik baki.

         // leaveTypeName selepas ini mungkin ditukar kepada nama

         // custom bagi Lain-lain untuk tujuan paparan sahaja.

         String balanceLeaveTypeName = leaveTypeName;



         // If leave type is Lain-lain, use the custom name

         // when available.



         if (

             "LAIN-LAIN".equalsIgnoreCase(

                 leaveTypeName.trim()

             )

             &&

             otherLeaveType != null

             &&

             !otherLeaveType.isBlank()

         ) {



             leaveTypeName =

                 otherLeaveType.trim();

         }





         // =================================================

         // CHECK WHETHER APPLICATION CAN BE CANCELLED

         // =================================================



         boolean statusAllowsCancel =

             isPendingStatus(currentStatus)

             ||

             "APPROVED".equalsIgnoreCase(

                 currentStatus

             );



         boolean leaveHasNotStarted =

             startDate != null

             &&

             startDate.toLocalDate().isAfter(

                 LocalDate.now()

             );



         boolean canCancel =

             statusAllowsCancel

             &&

             leaveHasNotStarted;





         if (!canCancel) {



             con.rollback();



             resp.sendRedirect(

                 req.getContextPath()

                 + "/applications?error=cannotCancel"

             );



             return;

         }





         // =================================================

         // RESTORE BALANCE IF AN APPROVED LEAVE IS CANCELLED

         // =================================================

         // Baki hanya pernah ditolak selepas permohonan diluluskan.

         // Oleh itu, permohonan yang masih pending tidak perlu

         // memulangkan apa-apa baki.

         //

         // Cuti Tahunan + Cuti Kecemasan menggunakan baki bersama

         // Cuti Tahunan (leave_type_id = 1). Pecahan penggunaan

         // carry forward dan peruntukan tahun semasa diambil terus

         // daripada rekod permohonan supaya jumlah yang dipulangkan

         // tepat seperti ketika kelulusan dibuat.

         // =================================================



         if (

             "APPROVED".equalsIgnoreCase(currentStatus)

         ) {



             if (leaveTypeId == null || duration <= 0) {

                 throw new SQLException(

                     "Maklumat permohonan tidak lengkap untuk memulangkan baki cuti."

                 );

             }



             int leaveYear =

                 startDate.toLocalDate().getYear();



             restoreApprovedLeaveBalance(

                 con,

                 userId,

                 leaveTypeId,

                 balanceLeaveTypeName,

                 leaveYear,

                 duration,

                 carryForwardDaysUsed,

                 currentYearDaysUsed

             );

         }





         // =================================================

         // UPDATE LEAVE APPLICATION

         // =================================================



         String updateSql = """



             UPDATE leave_applications



             SET status = 'CANCELLED'



             WHERE id = ?

               AND user_id = ?



         """;





         int updatedRows;





         try (

             PreparedStatement ps =

                 con.prepareStatement(updateSql)

         ) {



             ps.setInt(1, applicationId);

             ps.setInt(2, userId);



             updatedRows =

                 ps.executeUpdate();

         }





         if (updatedRows != 1) {



             con.rollback();



             resp.sendRedirect(

                 req.getContextPath()

                 + "/applications?error=cancel"

             );



             return;

         }





         // =================================================

         // CANCEL PENDING APPROVAL RECORDS

         // =================================================

         //

         // Approval that has already been completed is kept

         // as history.

         // =================================================



         String approvalSql = """



             UPDATE leave_approvals



             SET

                 decision = 'CANCELLED',

                 decision_date = NOW()



             WHERE leave_id = ?



               AND

               (

                   decision IS NULL

                   OR TRIM(decision) = ''

                   OR UPPER(decision) = 'PENDING'

               )



         """;





         try (

             PreparedStatement ps =

                 con.prepareStatement(approvalSql)

         ) {



             ps.setInt(

                 1,

                 applicationId

             );



             ps.executeUpdate();

         }





         // =================================================

         // USER NAME

         // =================================================



         String userName =

             getSessionText(

                 session,

                 "userName"

             );





         if (userName.isBlank()) {



             userName =

                 getSessionText(

                     session,

                     "name"

                 );

         }





         // Fallback: get actual name from database



         if (userName.isBlank()) {



             String userSql = """



                 SELECT name

                 FROM users

                 WHERE id = ?

                 LIMIT 1



             """;





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



                     if (rs.next()) {



                         userName =

                             rs.getString("name");

                     }

                 }

             }

         }





         if (

             userName == null

             ||

             userName.isBlank()

         ) {



             userName = "Pengguna";

         }





         // =================================================

         // USER ROLE

         // =================================================



         String userRole =

             getSessionText(

                 session,

                 "userRole"

             ).toUpperCase();





         if (userRole.isBlank()) {



             userRole =

                 getSessionText(

                     session,

                     "role"

                 ).toUpperCase();

         }





         if (userRole.isBlank()) {



             userRole = "STAFF";

         }





         // =================================================

         // ACTIVITY LOG

         // =================================================



         String description =

             "Membatalkan permohonan cuti "

             + applicationNo;





         insertActivityLog(

             con,

             userId,

             userName,

             userRole,

             "CANCEL_LEAVE",

             description,

             "LEAVE_APPLICATION",

             applicationNo,

             getClientIpAddress(req)

         );





         // =================================================

         // NOTIFICATION INFORMATION

         // =================================================



         String notificationType =

             "LEAVE_CANCELLED";



         String notificationTitle =

             "Permohonan Cuti Dibatalkan";



         String notificationMessage =

             userName

             + " telah membatalkan permohonan "

             + leaveTypeName

             + " ("

             + applicationNo

             + ").";





         // =================================================

         // NOTIFY STAFF'S HOD

         // =================================================

         //

         // Only the HOD assigned to this staff receives

         // this notification.

         // =================================================



         Integer hodId =

             NotificationUtil.findHodId(

                 con,

                 userId

             );





         if (

             hodId != null

             &&

             !hodId.equals(userId)

         ) {



             NotificationUtil.create(

                 con,

                 hodId,

                 notificationType,

                 notificationTitle,

                 notificationMessage,

                 "LEAVE_APPLICATION",

                 applicationId

             );

         }





         // =================================================

         // NOTIFY ALL HR

         // =================================================



         NotificationUtil.createForRole(

             con,

             "HR",

             userId,

             notificationType,

             notificationTitle,

             notificationMessage,

             "LEAVE_APPLICATION",

             applicationId

         );





         // =================================================

         // NOTIFY ALL MANAGEMENT

         // =================================================



         NotificationUtil.createForRole(

             con,

             "MANAGEMENT",

             userId,

             notificationType,

             notificationTitle,

             notificationMessage,

             "LEAVE_APPLICATION",

             applicationId

         );





         // =================================================

         // COMMIT EVERYTHING

         // =================================================

         //

         // Application cancellation + approval cancellation

         // + activity log + notifications are committed

         // together.

         // =================================================



         con.commit();





         // =================================================

         // SUCCESS

         // =================================================



         resp.sendRedirect(

             req.getContextPath()

             + "/applications?success=cancelled"

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

             "Tidak dapat membatalkan permohonan cuti.",

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

    // RESTORE APPROVED LEAVE BALANCE

    // =========================================================

    private void restoreApprovedLeaveBalance(

            Connection con,

            int userId,

            int leaveTypeId,

            String leaveTypeName,

            int leaveYear,

            int duration,

            int carryForwardDaysUsed,

            int currentYearDaysUsed)

            throws SQLException {



        final int ANNUAL_LEAVE_ID = 1;

        final int EMERGENCY_LEAVE_ID = 2;



        boolean sharedAnnualBalance =

            leaveTypeId == ANNUAL_LEAVE_ID

            ||

            leaveTypeId == EMERGENCY_LEAVE_ID;



        if (sharedAnnualBalance) {



            if (

                carryForwardDaysUsed < 0

                ||

                currentYearDaysUsed < 0

                ||

                carryForwardDaysUsed + currentYearDaysUsed != duration

            ) {



                throw new SQLException(

                    "Pecahan penggunaan CF/peruntukan tahun semasa tidak sepadan dengan tempoh cuti."

                );

            }



            String selectSql = """

                SELECT

                    entitlement,

                    carry_forward_days,

                    carry_forward_used,

                    used_days

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



            try (

                PreparedStatement ps =

                    con.prepareStatement(selectSql)

            ) {



                ps.setInt(1, userId);

                ps.setInt(2, ANNUAL_LEAVE_ID);

                ps.setInt(3, leaveYear);



                try (

                    ResultSet rs =

                        ps.executeQuery()

                ) {



                    if (!rs.next()) {

                        throw new SQLException(

                            "Rekod baki Cuti Tahunan tidak ditemui untuk proses pemulangan baki."

                        );

                    }



                    entitlement = rs.getInt("entitlement");

                    carryForwardDays = rs.getInt("carry_forward_days");

                    carryForwardUsed = rs.getInt("carry_forward_used");

                    usedDays = rs.getInt("used_days");

                }

            }



            int newCarryForwardUsed =

                carryForwardUsed - carryForwardDaysUsed;



            int newUsedDays =

                usedDays - duration;



            if (

                newCarryForwardUsed < 0

                ||

                newUsedDays < 0

                ||

                newCarryForwardUsed > carryForwardDays

            ) {



                throw new SQLException(

                    "Baki cuti semasa tidak sepadan dengan rekod permohonan yang hendak dibatalkan."

                );

            }



            int newCurrentYearUsed =

                newUsedDays - newCarryForwardUsed;



            if (

                newCurrentYearUsed < 0

                ||

                newCurrentYearUsed > entitlement

            ) {



                throw new SQLException(

                    "Penggunaan peruntukan tahun semasa selepas pemulangan baki tidak sah."

                );

            }



            int newCarryForwardRemaining =

                carryForwardDays - newCarryForwardUsed;



            int newCurrentYearRemaining =

                entitlement - newCurrentYearUsed;



            int newRemainingDays =

                newCarryForwardRemaining + newCurrentYearRemaining;



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



            try (

                PreparedStatement ps =

                    con.prepareStatement(updateSql)

            ) {



                ps.setInt(1, newCarryForwardUsed);

                ps.setInt(2, newUsedDays);

                ps.setInt(3, newRemainingDays);

                ps.setInt(4, userId);

                ps.setInt(5, ANNUAL_LEAVE_ID);

                ps.setInt(6, leaveYear);



                if (ps.executeUpdate() != 1) {

                    throw new SQLException(

                        "Baki Cuti Tahunan tidak dapat dipulangkan."

                    );

                }

            }



            // Cuti Kecemasan hanya berkongsi baki Cuti Tahunan.

            // Row Cuti Kecemasan, jika wujud, kekal kosong.

            if (leaveTypeId == EMERGENCY_LEAVE_ID) {



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



                try (

                    PreparedStatement ps =

                        con.prepareStatement(resetEmergencySql)

                ) {



                    ps.setInt(1, userId);

                    ps.setInt(2, EMERGENCY_LEAVE_ID);

                    ps.setInt(3, leaveYear);

                    ps.executeUpdate();

                }

            }



            return;

        }



        // =====================================================

        // LEAVE WITHOUT BALANCE RESTRICTION

        // =====================================================

        if (isNoBalanceRestrictionLeave(leaveTypeName)) {



            String updateSql = """

                UPDATE leave_balances

                SET

                    used_days = GREATEST(0, used_days - ?)

                WHERE user_id = ?

                  AND leave_type_id = ?

                  AND leave_year = ?

            """;



            try (

                PreparedStatement ps =

                    con.prepareStatement(updateSql)

            ) {



                ps.setInt(1, duration);

                ps.setInt(2, userId);

                ps.setInt(3, leaveTypeId);

                ps.setInt(4, leaveYear);

                ps.executeUpdate();

            }



            return;

        }



        // =====================================================

        // NORMAL QUOTA LEAVE

        // =====================================================



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

                con.prepareStatement(selectSql)

        ) {



            ps.setInt(1, userId);

            ps.setInt(2, leaveTypeId);

            ps.setInt(3, leaveYear);



            try (

                ResultSet rs =

                    ps.executeQuery()

            ) {



                if (!rs.next()) {

                    throw new SQLException(

                        "Rekod baki cuti tidak ditemui untuk proses pemulangan baki."

                    );

                }



                usedDays = rs.getInt("used_days");

                remainingDays = rs.getInt("remaining_days");

            }

        }



        if (usedDays < duration) {

            throw new SQLException(

                "Jumlah cuti digunakan lebih kecil daripada jumlah yang hendak dipulangkan."

            );

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

                con.prepareStatement(updateSql)

        ) {



            ps.setInt(1, usedDays - duration);

            ps.setInt(2, remainingDays + duration);

            ps.setInt(3, userId);

            ps.setInt(4, leaveTypeId);

            ps.setInt(5, leaveYear);



            if (ps.executeUpdate() != 1) {

                throw new SQLException(

                    "Baki cuti tidak dapat dipulangkan."

                );

            }

        }

    }





    // =========================================================

    // NO BALANCE RESTRICTION LEAVE

    // =========================================================

    private boolean isNoBalanceRestrictionLeave(

            String leaveTypeName) {



        if (leaveTypeName == null) {

            return false;

        }



        String value = leaveTypeName.trim();



        return

            "Cuti Tanpa Rekod".equalsIgnoreCase(value)

            ||

            "Cuti Tanpa Gaji".equalsIgnoreCase(value)

            ||

            "Lain-lain".equalsIgnoreCase(value);

    }





    // =========================================================

    // INSERT ACTIVITY LOG

    // =========================================================



    private void insertActivityLog(

            Connection con,

            Integer userId,

            String userName,

            String userRole,

            String action,

            String description,

            String referenceType,

            String referenceId,

            String ipAddress)

            throws SQLException {





        String sql = """



            INSERT INTO activity_logs

            (

                user_id,

                user_name,

                user_role,

                action,

                description,

                reference_type,

                reference_id,

                ip_address,

                created_at

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

                NOW()

            )



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





            ps.setString(

                2,

                userName

            );





            ps.setString(

                3,

                userRole

            );





            ps.setString(

                4,

                action

            );





            ps.setString(

                5,

                description

            );





            ps.setString(

                6,

                referenceType

            );





            ps.setString(

                7,

                referenceId

            );





            ps.setString(

                8,

                ipAddress

            );





            ps.executeUpdate();

        }

    }





    // =========================================================

    // CLIENT IP ADDRESS

    // =========================================================



    private String getClientIpAddress(

            HttpServletRequest req) {





        String forwarded =

                req.getHeader(

                    "X-Forwarded-For"

                );





        if (

            forwarded != null

            &&

            !forwarded.isBlank()

        ) {



            int comma =

                    forwarded.indexOf(

                        ','

                    );





            if (

                comma >= 0

            ) {



                return forwarded

                        .substring(

                            0,

                            comma

                        )

                        .trim();

            }





            return forwarded.trim();

        }





        String ip =

                req.getRemoteAddr();





        return ip == null

            ? ""

            : ip.trim();

    }





    // =========================================================

    // SESSION TEXT

    // =========================================================



    private String getSessionText(

            HttpSession session,

            String attributeName) {





        if (

            session == null

            ||

            attributeName == null

        ) {



            return "";

        }





        Object value =

                session.getAttribute(

                    attributeName

                );





        return value == null

            ? ""

            : value

                .toString()

                .trim();

    }





    // =========================================================

    // CLEAN

    // =========================================================



    private String clean(

            String value) {





        return value == null

            ? ""

            : value.trim();

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

    // STATUS LABEL

    // =========================================================



    private String getStatusLabel(

            String status) {





        if (

            status == null

        ) {



            return "—";

        }





        switch (

            status.toUpperCase()

        ) {





            case "PENDING":

            case "PENDING_HEAD":

            case "PENDING_ADMIN":

            case "PENDING_MANAGEMENT":



                return "Dalam Proses";





            case "APPROVED":



                return "Diluluskan";





            case "REJECTED":



                return "Tidak Diluluskan";





            case "CANCELLED":



                return "Dibatalkan";





            default:



                return status;

        }

    }





    // =========================================================

    // HOD DECISION LABEL

    // =========================================================



    private String getHodDecisionLabel(

            String decision) {





        if (

            decision == null

            ||

            decision.isBlank()

            ||

            "PENDING"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Menunggu";

        }





        if (

            "SUPPORTED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Disokong";

        }





        if (

            "NOT_SUPPORTED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Tidak Disokong";

        }





        if (

            "CANCELLED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Dibatalkan";

        }





        return decision;

    }





    // =========================================================

    // MANAGEMENT DECISION LABEL

    // =========================================================



    private String getManagementDecisionLabel(

            String decision) {





        if (

            decision == null

            ||

            decision.isBlank()

            ||

            "PENDING"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Menunggu";

        }





        if (

            "APPROVED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Diluluskan";

        }





        if (

            "REJECTED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Tidak Diluluskan";

        }





        if (

            "CANCELLED"

                .equalsIgnoreCase(

                    decision

                )

        ) {



            return "Dibatalkan";

        }





        return decision;

    }

}