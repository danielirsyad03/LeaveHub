<%@ page contentType="text/html;charset=UTF-8" %>

<%
    /*
     * =========================================================
     * LEGACY PAGE - PERMOHONAN CUTI
     * =========================================================
     *
     * Halaman ini dikekalkan untuk menyokong pautan lama
     * yang masih menuju ke:
     *
     *     /permohonan-cuti.jsp
     *
     * Halaman permohonan cuti utama sekarang menggunakan:
     *
     *     /apply
     *
     * melalui LeaveApplicationServlet.
     * =========================================================
     */

    // =========================================================
    // SEMAK SESSION
    // =========================================================

    if (session.getAttribute("userId") == null) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    // =========================================================
    // REDIRECT KE HALAMAN PERMOHONAN CUTI UTAMA
    // =========================================================

    response.sendRedirect(
        request.getContextPath() + "/apply"
    );

    return;
%>