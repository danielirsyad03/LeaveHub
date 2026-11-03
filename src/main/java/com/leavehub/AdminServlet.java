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





@WebServlet("/admin")

public class AdminServlet extends HttpServlet {



    private static final long serialVersionUID = 1L;





    @Override

    protected void doGet(

            HttpServletRequest req,

            HttpServletResponse resp)

            throws ServletException, IOException {





        // =====================================================

        // SESSION

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





        int currentUserId;





        try {



            currentUserId =

                Integer.parseInt(

                    session

                        .getAttribute("userId")

                        .toString()

                );



        } catch (Exception e) {



            session.invalidate();



            resp.sendRedirect(

                req.getContextPath() + "/"

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





        // =====================================================

        // ROLE

        // =====================================================



        boolean isHR =

            "HR".equals(currentRole);





        boolean isHOD =

            "HOD".equals(currentRole);





        boolean isManagement =

            "MANAGEMENT".equals(currentRole);





        if (

            !isHR

            &&

            !isHOD

            &&

            !isManagement

        ) {



            resp.sendError(

                HttpServletResponse.SC_FORBIDDEN

            );



            return;

        }

        // =====================================================
        // PRINT APPLICATION LIST
        // =====================================================

        String action = req.getParameter("action");

        if (
            action != null
            &&
            "print".equalsIgnoreCase(action.trim())
        ) {

            printApplicationList(
                req,
                resp,
                currentUserId,
                isHR,
                isHOD,
                isManagement
            );

            return;
        }







        // =====================================================

        // BASE SQL

        // =====================================================



        String baseSql = """



            SELECT



                l.id,

                l.application_no,

                l.user_id,

                l.leave_type_id,



                COALESCE(

                    lt.leave_type_name,

                    l.leave_type

                ) AS leave_type_name,



                l.other_leave_type,

                l.start_date,

                l.end_date,

                l.duration,

                l.reason,

                l.contact_phone,

                l.contact_address,

                l.handover_staff_name,

                l.status,

                l.attachment,

                l.remarks,

                l.submitted_at,

                l.reviewed_at,

                l.reviewed_by,



                l.balance_before,

                l.balance_after,



                u.name,

                u.position,

                u.email,

                u.role AS staff_role,

                u.department,

                u.hod_id,



                h.name AS hod_name,



                ha.approver_id AS hod_approver_id,

                ha.decision AS hod_decision,

                ha.remarks AS hod_remarks,

                ha.decision_date AS hod_decision_date,



                ma.approver_id AS management_approver_id,

                ma.decision AS management_decision,

                ma.remarks AS management_remarks,

                ma.decision_date AS management_decision_date,



                mu.name AS management_name



            FROM leave_applications l



            JOIN users u

                ON l.user_id = u.id



            LEFT JOIN leave_types lt

                ON l.leave_type_id =

                   lt.leave_type_id



            LEFT JOIN users h

                ON u.hod_id =

                   h.id



            LEFT JOIN leave_approvals ha

                ON ha.approval_id = (



                    SELECT MAX(

                        ha2.approval_id

                    )



                    FROM leave_approvals ha2



                    WHERE ha2.leave_id =

                          l.id



                      AND ha2.approval_level =

                          'HEAD_OF_UNIT'

                )



            LEFT JOIN leave_approvals ma

                ON ma.approval_id = (



                    SELECT MAX(

                        ma2.approval_id

                    )



                    FROM leave_approvals ma2



                    WHERE ma2.leave_id =

                          l.id



                      AND ma2.approval_level =

                          'MANAGEMENT'

                )



            LEFT JOIN users mu

                ON ma.approver_id =

                   mu.id



        """;





        // =====================================================

        // ORDER

        // =====================================================



        String orderSql = """



            ORDER BY



                CASE l.status



                    WHEN 'PENDING_MANAGEMENT'

                        THEN 1



                    WHEN 'PENDING_HEAD'

                        THEN 2



                    WHEN 'PENDING_ADMIN'

                        THEN 3



                    WHEN 'PENDING'

                        THEN 4



                    WHEN 'APPROVED'

                        THEN 5



                    WHEN 'REJECTED'

                        THEN 6



                    WHEN 'CANCELLED'

                        THEN 7



                    ELSE 8



                END,



                l.submitted_at DESC



        """;





        String sql;





        // =====================================================

        // HOD

        // Hanya staf di bawah seliaan HOD semasa

        // =====================================================



        if (isHOD) {



            sql =

                baseSql

                +

                """



                WHERE u.hod_id = ?



                """

                +

                orderSql;



        } else {



            // HR + MANAGEMENT boleh lihat semua rekod.



            sql =

                baseSql

                +

                orderSql;

        }





        // =====================================================

        // DATABASE

        // =====================================================



        try (

            Connection con =

                DBConnection.getConnection();



            PreparedStatement ps =

                con.prepareStatement(sql)

        ) {





            if (isHOD) {



                ps.setInt(

                    1,

                    currentUserId

                );

            }





            try (

                ResultSet rs =

                    ps.executeQuery()

            ) {





                // =================================================

                // GENERAL COUNTERS

                // =================================================



                int totalApplications = 0;



                int pendingApplications = 0;



                int approvedApplications = 0;



                int rejectedApplications = 0;



                int cancelledApplications = 0;



                // APPROVED + REJECTED

                int completedApplications = 0;





                // =================================================

                // HOD COUNTERS

                // =================================================



                int supportedApplications = 0;



                int notSupportedApplications = 0;



                int notReviewedByHodApplications = 0;



                int completedHodApplications = 0;





                List<Map<String, Object>> rows =

                    new ArrayList<>();





                while (rs.next()) {





                    Map<String, Object> row =

                        new HashMap<>();





                    // =================================================

                    // APPLICATION

                    // =================================================



                    int leaveId =

                        rs.getInt("id");





                    int applicantUserId =

                        rs.getInt("user_id");





                    String status =

                        normalize(

                            rs.getString("status")

                        );





                    int duration =

                        rs.getInt("duration");





                    row.put(

                        "id",

                        leaveId

                    );





                    row.put(

                        "applicationNo",

                        rs.getString(

                            "application_no"

                        )

                    );





                    row.put(

                        "userId",

                        applicantUserId

                    );





                    int leaveTypeId =

                        rs.getInt(

                            "leave_type_id"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "leaveTypeId",

                            null

                        );



                    } else {



                        row.put(

                            "leaveTypeId",

                            leaveTypeId

                        );

                    }





                    row.put(

                        "type",

                        rs.getString(

                            "leave_type_name"

                        )

                    );





                    row.put(

                        "otherLeaveType",

                        rs.getString(

                            "other_leave_type"

                        )

                    );





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





                    row.put(

                        "duration",

                        duration

                    );





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

                        "status",

                        status

                    );





                    row.put(

                        "statusLabel",

                        getStatusLabel(

                            status

                        )

                    );





                    row.put(

                        "attachment",

                        rs.getString(

                            "attachment"

                        )

                    );





                    row.put(

                        "remarks",

                        rs.getString(

                            "remarks"

                        )

                    );





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





                    int reviewedBy =

                        rs.getInt(

                            "reviewed_by"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "reviewedBy",

                            null

                        );



                    } else {



                        row.put(

                            "reviewedBy",

                            reviewedBy

                        );

                    }





                    // =================================================

                    // BALANCE

                    // =================================================



                    int balanceBefore =

                        rs.getInt(

                            "balance_before"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "balanceBefore",

                            null

                        );



                    } else {



                        row.put(

                            "balanceBefore",

                            balanceBefore

                        );

                    }





                    int balanceAfter =

                        rs.getInt(

                            "balance_after"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "balanceAfter",

                            null

                        );



                    } else {



                        row.put(

                            "balanceAfter",

                            balanceAfter

                        );

                    }





                    // =================================================

                    // APPLICANT

                    // =================================================



                    row.put(

                        "name",

                        rs.getString(

                            "name"

                        )

                    );





                    row.put(

                        "position",

                        rs.getString(

                            "position"

                        )

                    );





                    row.put(

                        "email",

                        rs.getString(

                            "email"

                        )

                    );





                    String staffRole =

                        normalize(

                            rs.getString(

                                "staff_role"

                            )

                        );





                    row.put(

                        "staffRole",

                        staffRole

                    );





                    row.put(

                        "department",

                        rs.getString(

                            "department"

                        )

                    );





                    // =================================================

                    // ASSIGNED HOD

                    // =================================================



                    int assignedHodId =

                        rs.getInt(

                            "hod_id"

                        );





                    boolean hasAssignedHod =

                        !rs.wasNull();





                    if (hasAssignedHod) {



                        row.put(

                            "hodId",

                            assignedHodId

                        );



                    } else {



                        row.put(

                            "hodId",

                            null

                        );

                    }





                    row.put(

                        "hodName",

                        rs.getString(

                            "hod_name"

                        )

                    );





                    // =================================================

                    // HOD DECISION

                    // =================================================



                    String hodDecision =

                        normalize(

                            rs.getString(

                                "hod_decision"

                            )

                        );





                    row.put(

                        "hodDecision",

                        hodDecision

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





                    int hodApproverId =

                        rs.getInt(

                            "hod_approver_id"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "hodApproverId",

                            null

                        );



                    } else {



                        row.put(

                            "hodApproverId",

                            hodApproverId

                        );

                    }





                    // =================================================

                    // MANAGEMENT DECISION

                    // =================================================



                    String managementDecision =

                        normalize(

                            rs.getString(

                                "management_decision"

                            )

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





                    int managementApproverId =

                        rs.getInt(

                            "management_approver_id"

                        );





                    if (rs.wasNull()) {



                        row.put(

                            "managementApproverId",

                            null

                        );



                    } else {



                        row.put(

                            "managementApproverId",

                            managementApproverId

                        );

                    }





                    row.put(

                        "managementName",

                        rs.getString(

                            "management_name"

                        )

                    );





                    // =================================================

                    // FINAL MANAGEMENT STATE

                    // =================================================



                    boolean managementApproved =

                        "APPROVED".equals(

                            managementDecision

                        )

                        ||

                        "APPROVED".equals(

                            status

                        );





                    boolean managementRejected =

                        "REJECTED".equals(

                            managementDecision

                        )

                        ||

                        "REJECTED".equals(

                            status

                        );





                    boolean managementFinished =

                        managementApproved

                        ||

                        managementRejected;





                    boolean cancelled =

                        "CANCELLED".equals(

                            status

                        );





                    // =================================================

                    // HOD STATE

                    // =================================================



                    boolean hodNotReviewed =

                        hodDecision.isBlank()

                        ||

                        "PENDING".equals(

                            hodDecision

                        );





                    boolean hodSupported =

                        "SUPPORTED".equals(

                            hodDecision

                        );





                    boolean hodNotSupported =

                        "NOT_SUPPORTED".equals(

                            hodDecision

                        );





                    row.put(

                        "managementFinished",

                        managementFinished

                    );





                    row.put(

                        "managementApproved",

                        managementApproved

                    );





                    row.put(

                        "managementRejected",

                        managementRejected

                    );





                    row.put(

                        "hodNotReviewed",

                        hodNotReviewed

                    );





                    // =================================================

                    // HOD DISPLAY STATUS

                    //

                    // Sokongan HOD adalah OPTIONAL.

                    //

                    // Jika Pengurusan sudah membuat keputusan sebelum

                    // HOD menyemak, tindakan HOD dianggap selesai dan

                    // HOD tidak perlu lagi memberi sokongan.

                    // =================================================



                    String hodDisplayStatus;



                    String hodDisplayLabel;





                    if (cancelled) {



                        hodDisplayStatus =

                            "CANCELLED";



                        hodDisplayLabel =

                            "Dibatalkan";





                    } else if (

                        managementApproved

                    ) {





                        if (hodSupported) {



                            hodDisplayStatus =

                                "SUPPORTED";



                            hodDisplayLabel =

                                "Disokong";



                        } else if (

                            hodNotSupported

                        ) {



                            hodDisplayStatus =

                                "NOT_SUPPORTED";



                            hodDisplayLabel =

                                "Tidak Disokong";



                        } else {



                            hodDisplayStatus =

                                "COMPLETED";



                            hodDisplayLabel =

                                "Selesai - Diluluskan";

                        }





                    } else if (

                        managementRejected

                    ) {





                        if (hodSupported) {



                            hodDisplayStatus =

                                "SUPPORTED";



                            hodDisplayLabel =

                                "Disokong";



                        } else if (

                            hodNotSupported

                        ) {



                            hodDisplayStatus =

                                "NOT_SUPPORTED";



                            hodDisplayLabel =

                                "Tidak Disokong";



                        } else {



                            hodDisplayStatus =

                                "COMPLETED";



                            hodDisplayLabel =

                                "Selesai - Tidak Diluluskan";

                        }





                    } else if (

                        hodSupported

                    ) {



                        hodDisplayStatus =

                            "SUPPORTED";



                        hodDisplayLabel =

                            "Disokong";





                    } else if (

                        hodNotSupported

                    ) {



                        hodDisplayStatus =

                            "NOT_SUPPORTED";



                        hodDisplayLabel =

                            "Tidak Disokong";





                    } else {



                        hodDisplayStatus =

                            "PENDING";



                        hodDisplayLabel =

                            "Belum Disemak";

                    }





                    row.put(

                        "hodDisplayStatus",

                        hodDisplayStatus

                    );





                    row.put(

                        "hodDisplayLabel",

                        hodDisplayLabel

                    );





                    row.put(

                        "hodDecisionLabel",

                        hodDisplayLabel

                    );





                    // =================================================

                    // REJECTION REASON

                    // =================================================



                    String rejectionReason =

                        "";





                    if (

                        managementRejected

                    ) {





                        if (

                            managementRemarks != null

                            &&

                            !managementRemarks.isBlank()

                        ) {



                            rejectionReason =

                                managementRemarks.trim();



                        } else {





                            String applicationRemarks =

                                rs.getString(

                                    "remarks"

                                );





                            if (

                                applicationRemarks != null

                                &&

                                !applicationRemarks.isBlank()

                            ) {



                                rejectionReason =

                                    applicationRemarks.trim();

                            }

                        }

                    }





                    row.put(

                        "rejectionReason",

                        rejectionReason

                    );





                    // =================================================

                    // PENDING

                    // =================================================



                    boolean isPending =

                        isPendingStatus(

                            status

                        );





                    // =================================================

                    // CURRENT HOD ASSIGNMENT

                    // =================================================



                    boolean assignedToCurrentHod =

                        hasAssignedHod

                        &&

                        assignedHodId ==

                            currentUserId;





                    // =================================================

                    // CAN HOD REVIEW

                    // =================================================



                    boolean canHodReview =

                        isHOD

                        &&

                        isPending

                        &&

                        assignedToCurrentHod

                        &&

                        hodNotReviewed

                        &&

                        !managementFinished

                        &&

                        !cancelled;





                    row.put(

                        "canHodReview",

                        canHodReview

                    );





                    // =================================================

                    // CAN MANAGEMENT REVIEW

                    //

                    // PENTING:

                    // Pengurusan TIDAK perlu menunggu HOD.

                    // =================================================



                    boolean managementNotReviewed =

                        managementDecision.isBlank()

                        ||

                        "PENDING".equals(

                            managementDecision

                        );





                    boolean canManagementReview =

                        isManagement

                        &&

                        isPending

                        &&

                        managementNotReviewed

                        &&

                        !cancelled;





                    row.put(

                        "canManagementReview",

                        canManagementReview

                    );





                    // =================================================

                    // ADD ROW

                    // =================================================



                    rows.add(

                        row

                    );





                    // =================================================

                    // GENERAL COUNTERS

                    // =================================================



                    totalApplications++;





                    if (isPending) {



                        pendingApplications++;



                    } else if (

                        "APPROVED".equals(

                            status

                        )

                    ) {



                        approvedApplications++;



                        completedApplications++;





                    } else if (

                        "REJECTED".equals(

                            status

                        )

                    ) {



                        rejectedApplications++;



                        completedApplications++;





                    } else if (

                        "CANCELLED".equals(

                            status

                        )

                    ) {



                        cancelledApplications++;

                    }





                    // =================================================

                    // HOD WORKFLOW COUNTERS

                    // =================================================



                    if (cancelled) {



                        // Permohonan dibatalkan.

                        // Tidak termasuk dalam tindakan HOD.



                    } else if (

                        hodNotReviewed

                        &&

                        managementFinished

                    ) {



                        /*

                         * Pengurusan telah selesai membuat keputusan

                         * sebelum HOD bertindak.

                         */



                        completedHodApplications++;





                    } else if (

                        hodSupported

                    ) {



                        supportedApplications++;





                    } else if (

                        hodNotSupported

                    ) {



                        notSupportedApplications++;





                    } else {



                        notReviewedByHodApplications++;

                    }

                }





                // =================================================

                // REQUEST ATTRIBUTES

                // =================================================



                req.setAttribute(

                    "rows",

                    rows

                );





                req.setAttribute(

                    "totalApplications",

                    totalApplications

                );





                req.setAttribute(

                    "pendingApplications",

                    pendingApplications

                );





                req.setAttribute(

                    "approvedApplications",

                    approvedApplications

                );





                req.setAttribute(

                    "rejectedApplications",

                    rejectedApplications

                );





                req.setAttribute(

                    "cancelledApplications",

                    cancelledApplications

                );





                req.setAttribute(

                    "completedApplications",

                    completedApplications

                );





                req.setAttribute(

                    "supportedApplications",

                    supportedApplications

                );





                req.setAttribute(

                    "notSupportedApplications",

                    notSupportedApplications

                );





                req.setAttribute(

                    "notReviewedByHodApplications",

                    notReviewedByHodApplications

                );





                req.setAttribute(

                    "completedHodApplications",

                    completedHodApplications

                );





                req.setAttribute(

                    "isHR",

                    isHR

                );





                req.setAttribute(

                    "isHOD",

                    isHOD

                );





                req.setAttribute(

                    "isManagement",

                    isManagement

                );





                // =================================================

                // PAGE INFO

                // =================================================



                if (isManagement) {



                    req.setAttribute(

                        "pageTitle",

                        "Kelulusan Permohonan Cuti"

                    );





                    req.setAttribute(

                        "pageDescription",

                        "Semak dan buat keputusan akhir permohonan cuti staf"

                    );





                } else if (isHOD) {



                    req.setAttribute(

                        "pageTitle",

                        "Sokongan Permohonan Cuti"

                    );





                    req.setAttribute(

                        "pageDescription",

                        "Semak dan beri sokongan kepada permohonan cuti staf di bawah seliaan anda"

                    );





                } else {



                    req.setAttribute(

                        "pageTitle",

                        "Rekod Permohonan Cuti"

                    );





                    req.setAttribute(

                        "pageDescription",

                        "Lihat rekod dan status permohonan cuti staf"

                    );

                }





                // =================================================

                // FORWARD

                // =================================================



                req.getRequestDispatcher(

                    "/admin.jsp"

                ).forward(

                    req,

                    resp

                );

            }





        } catch (

            SQLException e

        ) {



            throw new ServletException(

                "Tidak dapat memuatkan pengurusan permohonan cuti.",

                e

            );

        }

    }





    // =========================================================

    // NORMALIZE

    // =========================================================

    // =========================================================
    // PRINT APPLICATION LIST
    // =========================================================

    private void printApplicationList(
            HttpServletRequest req,
            HttpServletResponse resp,
            int currentUserId,
            boolean isHR,
            boolean isHOD,
            boolean isManagement)
            throws ServletException, IOException {

        String sql = """

            SELECT
                l.id,
                l.application_no,
                COALESCE(lt.leave_type_name, l.leave_type) AS leave_type_name,
                l.other_leave_type,
                l.start_date,
                l.end_date,
                l.duration,
                l.status,
                l.submitted_at,
                u.name,
                u.position,
                u.department

            FROM leave_applications l

            JOIN users u
                ON l.user_id = u.id

            LEFT JOIN leave_types lt
                ON l.leave_type_id = lt.leave_type_id

        """;

        if (isHOD) {
            sql += """
                WHERE u.hod_id = ?
            """;
        }

        sql += """
            ORDER BY l.submitted_at DESC, l.id DESC
        """;

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            if (isHOD) {
                ps.setInt(1, currentUserId);
            }

            try (ResultSet rs = ps.executeQuery()) {

                List<Map<String, Object>> printRows =
                    new ArrayList<>();

                while (rs.next()) {

                    Map<String, Object> row =
                        new HashMap<>();

                    String leaveType =
                        rs.getString("leave_type_name");

                    String otherLeaveType =
                        rs.getString("other_leave_type");

                    if (
                        otherLeaveType != null
                        &&
                        !otherLeaveType.isBlank()
                        &&
                        (
                            leaveType == null
                            ||
                            leaveType.isBlank()
                            ||
                            "LAIN-LAIN".equalsIgnoreCase(leaveType.trim())
                        )
                    ) {
                        leaveType = otherLeaveType.trim();
                    }

                    String status =
                        normalize(rs.getString("status"));

                    row.put("id", rs.getInt("id"));
                    row.put("applicationNo", rs.getString("application_no"));
                    row.put("name", rs.getString("name"));
                    row.put("position", rs.getString("position"));
                    row.put("department", rs.getString("department"));
                    row.put("type", leaveType);
                    row.put("start", rs.getDate("start_date"));
                    row.put("end", rs.getDate("end_date"));
                    row.put("duration", rs.getInt("duration"));
                    row.put("status", status);
                    row.put("statusLabel", getStatusLabel(status));
                    row.put("submittedAt", rs.getTimestamp("submitted_at"));

                    printRows.add(row);
                }

                req.setAttribute("rows", printRows);
                req.setAttribute("printRows", printRows);
                req.setAttribute("totalApplications", printRows.size());
                req.setAttribute("isHR", isHR);
                req.setAttribute("isHOD", isHOD);
                req.setAttribute("isManagement", isManagement);
                req.setAttribute("printMode", true);
                req.setAttribute("pageTitle", "Senarai Permohonan Cuti");

                req.setAttribute(
                    "pageDescription",
                    isHOD
                        ? "Senarai permohonan cuti staf di bawah seliaan"
                        : "Senarai permohonan cuti semua staf"
                );

                /*
                 * Server-side forward: kekal pada browser tab yang sama.
                 */
                req.getRequestDispatcher(
                    "/print-admin-applications.jsp"
                ).forward(
                    req,
                    resp
                );
            }

        } catch (SQLException e) {

            throw new ServletException(
                "Tidak dapat menyediakan senarai permohonan cuti untuk cetakan.",
                e
            );
        }
    }





    private String normalize(

            String value) {





        if (value == null) {



            return "";

        }





        return value

            .trim()

            .toUpperCase();

    }





    // =========================================================

    // PENDING STATUS

    // =========================================================



    private boolean isPendingStatus(

            String status) {





        return

            "PENDING_MANAGEMENT".equals(status)

            ||

            "PENDING_HEAD".equals(status)

            ||

            "PENDING_ADMIN".equals(status)

            ||

            "PENDING".equals(status);

    }





    // =========================================================

    // STATUS LABEL

    // =========================================================



    private String getStatusLabel(

            String status) {





        switch (status) {





            case "PENDING_MANAGEMENT":



            case "PENDING_HEAD":



            case "PENDING_ADMIN":



            case "PENDING":



                return

                    "Menunggu Pengurusan";





            case "APPROVED":



                return

                    "Diluluskan";





            case "REJECTED":



                return

                    "Tidak Diluluskan";





            case "CANCELLED":



                return

                    "Dibatalkan";





            default:



                return status;

        }

    }





    // =========================================================

    // MANAGEMENT DECISION LABEL

    // =========================================================



    private String getManagementDecisionLabel(

            String decision) {





        switch (decision) {





            case "APPROVED":



                return

                    "Diluluskan";





            case "REJECTED":



                return

                    "Tidak Diluluskan";





            case "PENDING":



            case "":



                return

                    "Menunggu Keputusan";





            case "CANCELLED":



                return

                    "Dibatalkan";





            default:



                return decision;

        }

    }

}