package com.leavehub;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;


public final class ActivityLogUtil {

    private ActivityLogUtil() {
    }


    // =========================================================
    // LOG USING EXISTING CONNECTION
    //
    // Gunakan method ini apabila servlet sudah mempunyai
    // database transaction sendiri.
    //
    // Activity Log akan commit / rollback bersama-sama
    // dengan transaction utama.
    // =========================================================

    public static void log(
            Connection con,
            HttpServletRequest request,
            String action,
            String description,
            String referenceType,
            Object referenceId)
            throws SQLException {


        if (con == null) {

            throw new SQLException(
                "Database connection untuk Activity Log tidak tersedia."
            );
        }


        HttpSession session =
                request == null
                    ? null
                    : request.getSession(false);


        Integer userId =
                getSessionUserId(session);


        String userName =
                getSessionString(
                    session,
                    "userName",
                    "Pengguna"
                );


        String userRole =
                getSessionString(
                    session,
                    "userRole",
                    "UNKNOWN"
                );


        String ipAddress =
                getClientIpAddress(request);


        insert(
            con,
            userId,
            userName,
            userRole,
            action,
            description,
            referenceType,
            referenceId,
            ipAddress
        );
    }


    // =========================================================
    // LOG WITH ACTOR INFORMATION
    //
    // Digunakan sekiranya maklumat pengguna perlu dihantar
    // secara manual.
    // =========================================================

    public static void log(
            Connection con,
            Integer userId,
            String userName,
            String userRole,
            String action,
            String description,
            String referenceType,
            Object referenceId,
            String ipAddress)
            throws SQLException {


        insert(
            con,
            userId,
            userName,
            userRole,
            action,
            description,
            referenceType,
            referenceId,
            normalizeIpAddress(ipAddress)
        );
    }


    // =========================================================
    // LOG USING OWN CONNECTION
    //
    // Digunakan apabila servlet tidak mempunyai transaction
    // database sendiri.
    //
    // Contoh:
    // - Login
    // - Cetak dokumen
    // - Buka dokumen tertentu
    // =========================================================

    public static void log(
            HttpServletRequest request,
            String action,
            String description,
            String referenceType,
            Object referenceId)
            throws SQLException {


        try (
            Connection con =
                    DBConnection.getConnection()
        ) {

            log(
                con,
                request,
                action,
                description,
                referenceType,
                referenceId
            );
        }
    }


    // =========================================================
    // INSERT ACTIVITY LOG
    // =========================================================

    private static void insert(
            Connection con,
            Integer userId,
            String userName,
            String userRole,
            String action,
            String description,
            String referenceType,
            Object referenceId,
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
                ip_address
            )

            VALUES
            (
                ?, ?, ?, ?, ?, ?, ?, ?
            )

        """;


        try (
            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {


            // =================================================
            // USER ID
            // =================================================

            if (
                userId == null
                ||
                userId <= 0
            ) {

                ps.setNull(
                    1,
                    java.sql.Types.INTEGER
                );

            } else {

                ps.setInt(
                    1,
                    userId
                );
            }


            // =================================================
            // USER NAME
            // =================================================

            ps.setString(
                2,
                normalizeText(
                    userName,
                    "Pengguna"
                )
            );


            // =================================================
            // USER ROLE
            // =================================================

            ps.setString(
                3,
                normalizeText(
                    userRole,
                    "UNKNOWN"
                ).toUpperCase()
            );


            // =================================================
            // ACTION
            // =================================================

            ps.setString(
                4,
                normalizeText(
                    action,
                    "UNKNOWN_ACTION"
                ).toUpperCase()
            );


            // =================================================
            // DESCRIPTION
            // =================================================

            ps.setString(
                5,
                normalizeText(
                    description,
                    "Aktiviti sistem"
                )
            );


            // =================================================
            // REFERENCE TYPE
            // =================================================

            setNullableString(
                ps,
                6,
                referenceType
            );


            // =================================================
            // REFERENCE ID
            // =================================================

            setNullableString(
                ps,
                7,
                referenceId == null
                    ? null
                    : String.valueOf(referenceId)
            );


            // =================================================
            // IP ADDRESS
            // =================================================

            setNullableString(
                ps,
                8,
                normalizeIpAddress(ipAddress)
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // GET USER ID FROM SESSION
    // =========================================================

    private static Integer getSessionUserId(
            HttpSession session) {


        if (session == null) {

            return null;
        }


        Object value =
                session.getAttribute(
                    "userId"
                );


        if (value == null) {

            return null;
        }


        try {


            if (value instanceof Number) {

                int id =
                        ((Number) value)
                            .intValue();


                return id > 0
                        ? id
                        : null;
            }


            int id =
                    Integer.parseInt(
                        value
                            .toString()
                            .trim()
                    );


            return id > 0
                    ? id
                    : null;


        } catch (Exception e) {

            return null;
        }
    }


    // =========================================================
    // GET STRING FROM SESSION
    // =========================================================

    private static String getSessionString(
            HttpSession session,
            String key,
            String defaultValue) {


        if (session == null) {

            return defaultValue;
        }


        Object value =
                session.getAttribute(key);


        if (value == null) {

            return defaultValue;
        }


        String text =
                value
                    .toString()
                    .trim();


        return text.isBlank()
                ? defaultValue
                : text;
    }


    // =========================================================
    // GET CLIENT IP ADDRESS
    //
    // Priority:
    //
    // 1. X-Forwarded-For
    // 2. X-Real-IP
    // 3. request.getRemoteAddr()
    //
    // Localhost IPv6 akan ditukar kepada:
    //
    // 127.0.0.1
    // =========================================================

    private static String getClientIpAddress(
            HttpServletRequest request) {


        if (request == null) {

            return null;
        }


        // =====================================================
        // X-FORWARDED-FOR
        // =====================================================

        String forwardedFor =
                request.getHeader(
                    "X-Forwarded-For"
                );


        if (
            forwardedFor != null
            &&
            !forwardedFor.isBlank()
        ) {


            String[] values =
                    forwardedFor.split(",");


            if (values.length > 0) {


                String ip =
                        values[0].trim();


                if (!ip.isBlank()) {

                    return normalizeIpAddress(ip);
                }
            }
        }


        // =====================================================
        // X-REAL-IP
        // =====================================================

        String realIp =
                request.getHeader(
                    "X-Real-IP"
                );


        if (
            realIp != null
            &&
            !realIp.isBlank()
        ) {

            return normalizeIpAddress(
                realIp.trim()
            );
        }


        // =====================================================
        // REMOTE ADDRESS
        // =====================================================

        return normalizeIpAddress(
            request.getRemoteAddr()
        );
    }


    // =========================================================
    // NORMALIZE IP ADDRESS
    //
    // Tomcat / Eclipse localhost kadang-kadang memberikan:
    //
    // 0:0:0:0:0:0:0:1
    //
    // atau:
    //
    // ::1
    //
    // Untuk paparan Activity Log, kita jadikan:
    //
    // 127.0.0.1
    // =========================================================

    private static String normalizeIpAddress(
            String ipAddress) {


        if (ipAddress == null) {

            return null;
        }


        String ip =
                ipAddress.trim();


        if (ip.isBlank()) {

            return null;
        }


        // IPv6 localhost
        if (
            "::1".equals(ip)
            ||
            "0:0:0:0:0:0:0:1".equals(ip)
        ) {

            return "127.0.0.1";
        }


        // IPv4 mapped IPv6
        if (
            ip.startsWith(
                "::ffff:"
            )
        ) {

            String ipv4 =
                    ip.substring(
                        "::ffff:".length()
                    );


            if (!ipv4.isBlank()) {

                return ipv4;
            }
        }


        return ip;
    }


    // =========================================================
    // NULLABLE STRING
    // =========================================================

    private static void setNullableString(
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
                java.sql.Types.VARCHAR
            );

        } else {

            ps.setString(
                index,
                value.trim()
            );
        }
    }


    // =========================================================
    // NORMALIZE TEXT
    // =========================================================

    private static String normalizeText(
            String value,
            String defaultValue) {


        if (
            value == null
            ||
            value.isBlank()
        ) {

            return defaultValue;
        }


        return value.trim();
    }
}