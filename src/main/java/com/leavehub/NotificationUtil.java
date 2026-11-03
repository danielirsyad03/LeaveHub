package com.leavehub;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;


public final class NotificationUtil {

    private NotificationUtil() {
    }


    // =========================================================
    // CREATE ONE NOTIFICATION
    // =========================================================

    public static void create(
            Connection con,
            int userId,
            String notificationType,
            String title,
            String message,
            String referenceType,
            Integer referenceId)
            throws SQLException {


        String sql = """

            INSERT INTO notifications
            (
                user_id,
                notification_type,
                title,
                message,
                reference_type,
                reference_id,
                is_read
            )

            VALUES
            (
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                0
            )

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setInt(
                1,
                userId
            );


            ps.setString(
                2,
                clean(notificationType)
            );


            ps.setString(
                3,
                clean(title)
            );


            ps.setString(
                4,
                clean(message)
            );


            if (
                referenceType == null
                ||
                referenceType.isBlank()
            ) {

                ps.setNull(
                    5,
                    Types.VARCHAR
                );

            } else {

                ps.setString(
                    5,
                    referenceType
                        .trim()
                        .toUpperCase()
                );
            }


            if (referenceId == null) {

                ps.setNull(
                    6,
                    Types.INTEGER
                );

            } else {

                ps.setInt(
                    6,
                    referenceId
                );
            }


            ps.executeUpdate();
        }
    }


    // =========================================================
    // CREATE FOR ALL USERS WITH ROLE
    // =========================================================

    public static void createForRole(
            Connection con,
            String role,
            Integer excludeUserId,
            String notificationType,
            String title,
            String message,
            String referenceType,
            Integer referenceId)
            throws SQLException {


        if (
            role == null
            ||
            role.isBlank()
        ) {
            return;
        }


        String sql = """

            SELECT id

            FROM users

            WHERE UPPER(TRIM(role)) = ?

            ORDER BY id ASC

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                role.trim().toUpperCase()
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {

                while (rs.next()) {


                    int userId =
                        rs.getInt("id");


                    if (
                        excludeUserId != null
                        &&
                        userId == excludeUserId
                    ) {
                        continue;
                    }


                    create(
                        con,
                        userId,
                        notificationType,
                        title,
                        message,
                        referenceType,
                        referenceId
                    );
                }
            }
        }
    }


    // =========================================================
    // FIND HOD
    // =========================================================

    public static Integer findHodId(
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

                if (rs.next()) {

                    int hodId =
                        rs.getInt("hod_id");


                    if (!rs.wasNull()) {
                        return hodId;
                    }
                }
            }
        }


        return null;
    }


    // =========================================================
    // MARK ONE NOTIFICATION TYPE FOR REFERENCE AS READ
    // =========================================================

    public static void markReferenceTypeRead(
            Connection con,
            String referenceType,
            int referenceId,
            String notificationType)
            throws SQLException {


        String sql = """

            UPDATE notifications

            SET is_read = 1

            WHERE reference_type = ?
              AND reference_id = ?
              AND notification_type = ?
              AND is_read = 0

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                clean(referenceType)
                    .toUpperCase()
            );


            ps.setInt(
                2,
                referenceId
            );


            ps.setString(
                3,
                clean(notificationType)
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // MARK ALL FOR REFERENCE READ
    // =========================================================

    public static void markReferenceRead(
            Connection con,
            String referenceType,
            int referenceId)
            throws SQLException {


        String sql = """

            UPDATE notifications

            SET is_read = 1

            WHERE reference_type = ?
              AND reference_id = ?
              AND is_read = 0

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(sql)
        ) {

            ps.setString(
                1,
                clean(referenceType)
                    .toUpperCase()
            );


            ps.setInt(
                2,
                referenceId
            );


            ps.executeUpdate();
        }
    }


    // =========================================================
    // CLEAN
    // =========================================================

    private static String clean(
            String value) {

        return value == null
            ? ""
            : value.trim();
    }
}