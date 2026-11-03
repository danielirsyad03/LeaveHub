
package com.leavehub;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        System.getenv().getOrDefault(
            "LEAVEHUB_DB_URL",
            "jdbc:mysql://localhost:3306/leavehub"
            + "?useSSL=false"
            + "&serverTimezone=Asia/Kuala_Lumpur"
            + "&allowPublicKeyRetrieval=true"
            + "&useUnicode=true"
            + "&characterEncoding=UTF-8"
        );

    private static final String USER =
        System.getenv().getOrDefault(
            "LEAVEHUB_DB_USER",
            "root"
        );

    private static final String PASSWORD =
        System.getenv().getOrDefault(
            "LEAVEHUB_DB_PASSWORD",
            ""
        );

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "MySQL JDBC Driver not found."
            );
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection()
            throws SQLException {

        return DriverManager.getConnection(
            URL,
            USER,
            PASSWORD
        );
    }
}
