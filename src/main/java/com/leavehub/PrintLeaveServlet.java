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

import java.util.HashMap;
import java.util.Map;


@WebServlet("/print-leave")
public class PrintLeaveServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    // =========================================================
    // GET
    // =========================================================

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


        Integer currentUserId =
            getUserId(
                session
            );


        if (
            currentUserId == null
        ) {

            session.invalidate();

            response.sendRedirect(
                request.getContextPath() + "/"
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
        // APPLICATION ID
        // =====================================================

        Integer applicationId =
            parsePositiveInteger(
                request.getParameter(
                    "id"
                )
            );


        if (
            applicationId == null
        ) {

            redirectBack(
                request,
                response,
                currentRole,
                "invalid"
            );

            return;
        }


        // =====================================================
        // QUERY
        // =====================================================

        String sql = """

            SELECT

                la.id,
                la.application_no,
                la.user_id,
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

                u.name AS staff_name,
                u.position AS staff_position,
                u.email AS staff_email,
                u.role AS applicant_role,
                u.department AS staff_department,
                u.hod_id,

                assignedHod.name
                    AS assigned_hod_name,

                hodApproval.decision
                    AS hod_decision,

                hodApproval.remarks
                    AS hod_remarks,

                hodApproval.decision_date
                    AS hod_decision_date,

                hodApprover.name
                    AS hod_approver_name,

                managementApproval.decision
                    AS management_decision,

                managementApproval.remarks
                    AS management_remarks,

                managementApproval.decision_date
                    AS management_decision_date,

                managementApprover.name
                    AS management_approver_name

            FROM leave_applications la


            JOIN users u
                ON u.id = la.user_id


            LEFT JOIN leave_types lt
                ON lt.leave_type_id =
                   la.leave_type_id


            LEFT JOIN users assignedHod
                ON assignedHod.id =
                   u.hod_id


            LEFT JOIN leave_approvals hodApproval
                ON hodApproval.approval_id =
                (
                    SELECT MAX(
                        ha.approval_id
                    )

                    FROM leave_approvals ha

                    WHERE ha.leave_id =
                          la.id

                      AND ha.approval_level =
                          'HEAD_OF_UNIT'
                )


            LEFT JOIN users hodApprover
                ON hodApprover.id =
                   hodApproval.approver_id


            LEFT JOIN leave_approvals managementApproval
                ON managementApproval.approval_id =
                (
                    SELECT MAX(
                        ma.approval_id
                    )

                    FROM leave_approvals ma

                    WHERE ma.leave_id =
                          la.id

                      AND ma.approval_level =
                          'MANAGEMENT'
                )


            LEFT JOIN users managementApprover
                ON managementApprover.id =
                   managementApproval.approver_id


            WHERE la.id = ?

            LIMIT 1

        """;


        Map<String, Object> leave =
            new HashMap<>();


        // =====================================================
        // DATABASE
        // =====================================================

        try (
            Connection con =
                DBConnection.getConnection();

            PreparedStatement ps =
                con.prepareStatement(
                    sql
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
                ) {

                    redirectBack(
                        request,
                        response,
                        currentRole,
                        "notFound"
                    );

                    return;
                }


                // =================================================
                // ACCESS CONTROL
                // =================================================

                int ownerUserId =
                    rs.getInt(
                        "user_id"
                    );


                Integer staffHodId =
                    null;


                int hodValue =
                    rs.getInt(
                        "hod_id"
                    );


                if (
                    !rs.wasNull()
                ) {

                    staffHodId =
                        hodValue;
                }


                boolean allowed =
                    canPrintApplication(
                        currentUserId,
                        currentRole,
                        ownerUserId,
                        staffHodId
                    );


                if (
                    !allowed
                ) {

                    response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Anda tidak mempunyai kebenaran untuk mencetak permohonan ini."
                    );

                    return;
                }


                // =================================================
                // APPLICATION ID
                // =================================================

                leave.put(
                    "id",
                    rs.getInt(
                        "id"
                    )
                );


                // =================================================
                // APPLICATION NUMBER
                // =================================================

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
                        "PKB-CUTI-"
                        +
                        rs.getInt(
                            "id"
                        );
                }


                leave.put(
                    "applicationNo",
                    applicationNo
                );


                // =================================================
                // LEAVE TYPE
                // =================================================

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


                leave.put(
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


                leave.put(
                    "leaveType",
                    leaveTypeName
                );


                leave.put(
                    "otherLeaveType",
                    rs.getString(
                        "other_leave_type"
                    )
                );


                // =================================================
                // DATE / DURATION
                // =================================================

                leave.put(
                    "startDate",
                    rs.getDate(
                        "start_date"
                    )
                );


                leave.put(
                    "endDate",
                    rs.getDate(
                        "end_date"
                    )
                );


                leave.put(
                    "duration",
                    rs.getObject(
                        "duration"
                    )
                );


                // =================================================
                // BALANCE SNAPSHOT
                // =================================================

                leave.put(
                    "balanceBefore",
                    rs.getObject(
                        "balance_before"
                    )
                );


                leave.put(
                    "balanceAfter",
                    rs.getObject(
                        "balance_after"
                    )
                );


                leave.put(
                    "balanceVerifiedBy",
                    rs.getString(
                        "balance_verified_by"
                    )
                );


                leave.put(
                    "balanceVerifiedDate",
                    rs.getDate(
                        "balance_verified_date"
                    )
                );


                // =================================================
                // APPLICATION DETAILS
                // =================================================

                leave.put(
                    "reason",
                    rs.getString(
                        "reason"
                    )
                );


                leave.put(
                    "contactPhone",
                    rs.getString(
                        "contact_phone"
                    )
                );


                leave.put(
                    "contactAddress",
                    rs.getString(
                        "contact_address"
                    )
                );


                leave.put(
                    "handoverStaffName",
                    rs.getString(
                        "handover_staff_name"
                    )
                );


                leave.put(
                    "attachment",
                    rs.getString(
                        "attachment"
                    )
                );


                // =================================================
                // STATUS
                // =================================================

                String status =
                    normalize(
                        rs.getString(
                            "status"
                        )
                    );


                leave.put(
                    "status",
                    status
                );


                leave.put(
                    "statusLabel",
                    getStatusLabel(
                        status
                    )
                );


                leave.put(
                    "pending",
                    isPendingStatus(
                        status
                    )
                );


                leave.put(
                    "approved",
                    "APPROVED".equals(
                        status
                    )
                );


                leave.put(
                    "rejected",
                    "REJECTED".equals(
                        status
                    )
                );


                leave.put(
                    "cancelled",
                    "CANCELLED".equals(
                        status
                    )
                );


                leave.put(
                    "remarks",
                    rs.getString(
                        "remarks"
                    )
                );


                leave.put(
                    "submittedAt",
                    rs.getTimestamp(
                        "submitted_at"
                    )
                );


                leave.put(
                    "reviewedAt",
                    rs.getTimestamp(
                        "reviewed_at"
                    )
                );


                // =================================================
                // APPLICANT INFORMATION
                // =================================================

                String applicantRole =
                    normalize(
                        rs.getString(
                            "applicant_role"
                        )
                    );


                leave.put(
                    "staffName",
                    rs.getString(
                        "staff_name"
                    )
                );


                leave.put(
                    "staffPosition",
                    rs.getString(
                        "staff_position"
                    )
                );


                leave.put(
                    "staffEmail",
                    rs.getString(
                        "staff_email"
                    )
                );


                leave.put(
                    "staffDepartment",
                    rs.getString(
                        "staff_department"
                    )
                );


                leave.put(
                    "applicantRole",
                    applicantRole
                );


                // =================================================
                // HOD NOT APPLICABLE
                // =================================================

                boolean hodNotApplicable =
                    "HOD".equals(
                        applicantRole
                    )
                    ||
                    "HR".equals(
                        applicantRole
                    )
                    ||
                    "MANAGEMENT".equals(
                        applicantRole
                    );


                leave.put(
                    "hodNotApplicable",
                    hodNotApplicable
                );


                leave.put(
                    "applicantIsHod",
                    "HOD".equals(
                        applicantRole
                    )
                );


                // =================================================
                // ASSIGNED HOD
                // =================================================

                leave.put(
                    "assignedHodName",
                    rs.getString(
                        "assigned_hod_name"
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


                leave.put(
                    "hodDecision",
                    hodDecision
                );


                if (
                    hodNotApplicable
                ) {

                    leave.put(
                        "hodDecisionLabel",
                        "Tidak Berkenaan"
                    );

                } else {

                    leave.put(
                        "hodDecisionLabel",
                        getHodDecisionLabel(
                            hodDecision
                        )
                    );
                }


                leave.put(
                    "hodRemarks",
                    rs.getString(
                        "hod_remarks"
                    )
                );


                leave.put(
                    "hodDecisionDate",
                    rs.getTimestamp(
                        "hod_decision_date"
                    )
                );


                leave.put(
                    "hodApproverName",
                    rs.getString(
                        "hod_approver_name"
                    )
                );


                // =================================================
                // MANAGEMENT
                // =================================================

                String managementDecision =
                    normalize(
                        rs.getString(
                            "management_decision"
                        )
                    );


                leave.put(
                    "managementDecision",
                    managementDecision
                );


                leave.put(
                    "managementDecisionLabel",
                    getManagementDecisionLabel(
                        managementDecision
                    )
                );


                String managementRemarks =
                    rs.getString(
                        "management_remarks"
                    );


                leave.put(
                    "managementRemarks",
                    managementRemarks
                );


                leave.put(
                    "managementDecisionDate",
                    rs.getTimestamp(
                        "management_decision_date"
                    )
                );


                leave.put(
                    "managementApproverName",
                    rs.getString(
                        "management_approver_name"
                    )
                );


                // =================================================
                // REJECTION REASON
                // =================================================

                String rejectionReason =
                    "";


                if (
                    "REJECTED".equals(
                        status
                    )
                ) {


                    if (
                        managementRemarks != null
                        &&
                        !managementRemarks.isBlank()
                    ) {

                        rejectionReason =
                            managementRemarks
                                .trim();


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
                                applicationRemarks
                                    .trim();
                        }
                    }
                }


                leave.put(
                    "rejectionReason",
                    rejectionReason
                );


                // =================================================
                // AUDIT TRAIL
                //
                // Only record after:
                // 1. Application exists
                // 2. User is authorised to print it
                //
                // Failure to save the audit must NOT prevent
                // the printable page from opening.
                // =================================================

                try {

                    ActivityLogUtil.log(
                        con,
                        request,
                        "PRINT_LEAVE",
                        "Mencetak permohonan cuti "
                            + applicationNo,
                        "LEAVE_APPLICATION",
                        applicationId
                    );

                } catch (SQLException auditException) {

                    auditException.printStackTrace();
                }
            }


        } catch (
            SQLException e
        ) {


            throw new ServletException(
                "Tidak dapat memuatkan borang permohonan cuti.",
                e
            );
        }


        // =====================================================
        // FORWARD
        // =====================================================

        request.setAttribute(
            "leave",
            leave
        );


        request
            .getRequestDispatcher(
                "/print-leave.jsp"
            )
            .forward(
                request,
                response
            );
    }


    // =========================================================
    // ACCESS CONTROL
    // =========================================================

    private boolean canPrintApplication(
            int currentUserId,
            String currentRole,
            int ownerUserId,
            Integer staffHodId) {


        // =====================================================
        // STAFF
        // Own application only
        // =====================================================

        if (
            "STAFF".equalsIgnoreCase(
                currentRole
            )
        ) {

            return
                currentUserId ==
                ownerUserId;
        }


        // =====================================================
        // HOD
        // Own application OR assigned staff application
        // =====================================================

        if (
            "HOD".equalsIgnoreCase(
                currentRole
            )
        ) {


            if (
                currentUserId ==
                ownerUserId
            ) {

                return true;
            }


            return
                staffHodId != null
                &&
                staffHodId.intValue()
                ==
                currentUserId;
        }


        // =====================================================
        // HR
        // =====================================================

        if (
            "HR".equalsIgnoreCase(
                currentRole
            )
        ) {

            return true;
        }


        // =====================================================
        // MANAGEMENT
        // =====================================================

        if (
            "MANAGEMENT".equalsIgnoreCase(
                currentRole
            )
        ) {

            return true;
        }


        return false;
    }


    // =========================================================
    // NORMALIZE
    // =========================================================

    private String normalize(
            String value) {


        if (
            value == null
        ) {

            return "";
        }


        return value
            .trim()
            .toUpperCase();
    }


    // =========================================================
    // STATUS LABEL
    // =========================================================

    private String getStatusLabel(
            String status) {


        status =
            normalize(
                status
            );


        switch (
            status
        ) {


            case "PENDING_MANAGEMENT":

                return
                    "Menunggu Pengurusan";


            case "PENDING_HEAD":

                return
                    "Menunggu Ketua Unit";


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

                return
                    status.isBlank()
                        ? "—"
                        : status;
        }
    }


    // =========================================================
    // HOD DECISION LABEL
    // =========================================================

    private String getHodDecisionLabel(
            String decision) {


        decision =
            normalize(
                decision
            );


        switch (
            decision
        ) {


            case "SUPPORTED":

                return
                    "Disokong";


            case "NOT_SUPPORTED":

                return
                    "Tidak Disokong";


            case "CANCELLED":

                return
                    "Dibatalkan";


            case "PENDING":

            case "":

                return
                    "Belum Disemak";


            default:

                return decision;
        }
    }


    // =========================================================
    // MANAGEMENT DECISION LABEL
    // =========================================================

    private String getManagementDecisionLabel(
            String decision) {


        decision =
            normalize(
                decision
            );


        switch (
            decision
        ) {


            case "APPROVED":

                return
                    "Diluluskan";


            case "REJECTED":

                return
                    "Tidak Diluluskan";


            case "CANCELLED":

                return
                    "Dibatalkan";


            case "PENDING":

            case "":

                return
                    "Menunggu Keputusan";


            default:

                return decision;
        }
    }


    // =========================================================
    // PENDING STATUS
    // =========================================================

    private boolean isPendingStatus(
            String status) {


        status =
            normalize(
                status
            );


        return
            "PENDING_MANAGEMENT".equals(
                status
            )
            ||
            "PENDING_HEAD".equals(
                status
            )
            ||
            "PENDING_ADMIN".equals(
                status
            )
            ||
            "PENDING".equals(
                status
            );
    }


    // =========================================================
    // GET SESSION USER ID
    // =========================================================

    private Integer getUserId(
            HttpSession session) {


        try {


            Object value =
                session.getAttribute(
                    "userId"
                );


            if (
                value == null
            ) {

                return null;
            }


            if (
                value instanceof Number
            ) {


                int id =
                    ((Number) value)
                        .intValue();


                return
                    id > 0
                        ? id
                        : null;
            }


            int id =
                Integer.parseInt(
                    value
                        .toString()
                        .trim()
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


    // =========================================================
    // PARSE POSITIVE INTEGER
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
    // REDIRECT BACK
    // =========================================================

    private void redirectBack(
            HttpServletRequest request,
            HttpServletResponse response,
            String role,
            String error)
            throws IOException {


        if (
            "HR".equalsIgnoreCase(
                role
            )
            ||
            "HOD".equalsIgnoreCase(
                role
            )
            ||
            "MANAGEMENT".equalsIgnoreCase(
                role
            )
        ) {


            response.sendRedirect(
                request.getContextPath()
                + "/admin?error="
                + error
            );


        } else {


            response.sendRedirect(
                request.getContextPath()
                + "/applications?error="
                + error
            );
        }
    }
}