package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.text.SimpleDateFormat;


@WebServlet("/notification-count")
public class NotificationCountServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;


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
            session.getAttribute(
                "userId"
            ) == null
        ) {

            response.setStatus(
                HttpServletResponse.SC_UNAUTHORIZED
            );

            return;
        }


        Integer userId =
            getUserId(
                session
            );


        if (
            userId == null
        ) {

            response.setStatus(
                HttpServletResponse.SC_UNAUTHORIZED
            );

            return;
        }


        response.setContentType(
            "application/json;charset=UTF-8"
        );


        response.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate"
        );


        int unreadCount =
            0;


        String countSql = """

            SELECT COUNT(*)

            FROM notifications

            WHERE user_id = ?
              AND is_read = 0

        """;


        String recentSql = """

            SELECT

                id,
                notification_type,
                title,
                message,
                reference_type,
                reference_id,
                is_read,
                created_at

            FROM notifications

            WHERE user_id = ?

            ORDER BY
                created_at DESC,
                id DESC

            LIMIT 5

        """;


        try (
            Connection con =
                DBConnection.getConnection()
        ) {


            // =================================================
            // UNREAD COUNT
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        countSql
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


                    if (
                        rs.next()
                    ) {

                        unreadCount =
                            rs.getInt(1);
                    }
                }
            }


            StringBuilder json =
                new StringBuilder();


            json.append(
                "{"
            );


            json.append(
                "\"count\":"
            );


            json.append(
                unreadCount
            );


            json.append(
                ",\"items\":["
            );


            boolean first =
                true;


            SimpleDateFormat dateFormat =
                new SimpleDateFormat(
                    "dd/MM/yyyy HH:mm"
                );


            // =================================================
            // RECENT ITEMS
            // =================================================

            try (
                PreparedStatement ps =
                    con.prepareStatement(
                        recentSql
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


                    while (
                        rs.next()
                    ) {


                        if (
                            !first
                        ) {

                            json.append(
                                ","
                            );
                        }


                        first =
                            false;


                        json.append(
                            "{"
                        );


                        json.append(
                            "\"id\":"
                        );


                        json.append(
                            rs.getInt(
                                "id"
                            )
                        );


                        json.append(
                            ",\"type\":\""
                        );


                        json.append(
                            jsonEscape(
                                rs.getString(
                                    "notification_type"
                                )
                            )
                        );


                        json.append(
                            "\""
                        );


                        json.append(
                            ",\"title\":\""
                        );


                        json.append(
                            jsonEscape(
                                rs.getString(
                                    "title"
                                )
                            )
                        );


                        json.append(
                            "\""
                        );


                        json.append(
                            ",\"message\":\""
                        );


                        json.append(
                            jsonEscape(
                                rs.getString(
                                    "message"
                                )
                            )
                        );


                        json.append(
                            "\""
                        );


                        json.append(
                            ",\"read\":"
                        );


                        json.append(
                            rs.getBoolean(
                                "is_read"
                            )
                        );


                        json.append(
                            ",\"createdAt\":\""
                        );


                        java.sql.Timestamp timestamp =
                            rs.getTimestamp(
                                "created_at"
                            );


                        if (
                            timestamp != null
                        ) {

                            json.append(
                                jsonEscape(
                                    dateFormat.format(
                                        timestamp
                                    )
                                )
                            );
                        }


                        json.append(
                            "\""
                        );


                        json.append(
                            "}"
                        );
                    }
                }
            }


            json.append(
                "]"
            );


            json.append(
                "}"
            );


            try (
                PrintWriter out =
                    response.getWriter()
            ) {

                out.print(
                    json.toString()
                );
            }


        } catch (
            SQLException e
        ) {


            throw new ServletException(
                "Tidak dapat memuatkan notifikasi.",
                e
            );
        }
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
    // JSON ESCAPE
    // =========================================================

    private String jsonEscape(
            String value) {


        if (
            value == null
        ) {

            return "";
        }


        StringBuilder result =
            new StringBuilder();


        for (
            int i = 0;
            i < value.length();
            i++
        ) {


            char c =
                value.charAt(i);


            switch (c) {


                case '\\':

                    result.append(
                        "\\\\"
                    );

                    break;


                case '"':

                    result.append(
                        "\\\""
                    );

                    break;


                case '\n':

                    result.append(
                        "\\n"
                    );

                    break;


                case '\r':

                    result.append(
                        "\\r"
                    );

                    break;


                case '\t':

                    result.append(
                        "\\t"
                    );

                    break;


                default:

                    if (
                        c < 32
                    ) {

                        result.append(
                            String.format(
                                "\\u%04x",
                                (int)c
                            )
                        );

                    } else {

                        result.append(c);
                    }

                    break;
            }
        }


        return result.toString();
    }
}