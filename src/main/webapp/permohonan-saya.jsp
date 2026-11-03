<%@ page contentType="text/html;charset=UTF-8" %>

<%
    /*
     * =========================================================
     * LEGACY PAGE
     * =========================================================
     *
     * Halaman "Permohonan Saya" sekarang menggunakan:
     *
     *     /applications
     *
     * melalui ApplicationsServlet.
     *
     * Fail ini dikekalkan sementara supaya pautan lama
     * yang menuju ke permohonan-saya.jsp masih berfungsi.
     */


    // =========================================================
    // SEMAK LOGIN
    // =========================================================

    if (session.getAttribute("userId") == null) {

        response.sendRedirect(
            request.getContextPath() + "/"
        );

        return;
    }


    // =========================================================
    // REDIRECT KE HALAMAN BAHARU
    // =========================================================

    response.sendRedirect(
        request.getContextPath() + "/leaveApplication"
    );

    return;
%>