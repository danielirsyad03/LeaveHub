package com.leavehub;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.time.DayOfWeek;
import java.time.LocalDate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


public final class HolidayUtil {


    private HolidayUtil() {
    }


    // =========================================================
    // GET ACTIVE PUBLIC HOLIDAY DATES
    //
    // Expands:
    //
    // start_date = 2027-03-20
    // end_date   = 2027-03-21
    //
    // Into:
    //
    // 2027-03-20
    // 2027-03-21
    //
    // Only dates overlapping requested leave range are returned.
    // =========================================================

    public static Set<LocalDate> getPublicHolidayDates(
            Connection con,
            LocalDate startDate,
            LocalDate endDate)
            throws SQLException {


        Set<LocalDate> holidays =
            new HashSet<>();


        if (
            con == null ||
            startDate == null ||
            endDate == null ||
            endDate.isBefore(startDate)
        ) {

            return holidays;
        }


        String sql = """

            SELECT
                start_date,
                end_date

            FROM public_holidays

            WHERE is_active = 1

              AND start_date <= ?

              AND end_date >= ?

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            /*
             * Holiday starts before or on leave end date.
             */
            ps.setDate(
                1,
                Date.valueOf(
                    endDate
                )
            );


            /*
             * Holiday ends after or on leave start date.
             */
            ps.setDate(
                2,
                Date.valueOf(
                    startDate
                )
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                while (rs.next()) {


                    Date startSql =
                        rs.getDate(
                            "start_date"
                        );


                    Date endSql =
                        rs.getDate(
                            "end_date"
                        );


                    if (
                        startSql == null ||
                        endSql == null
                    ) {
                        continue;
                    }


                    LocalDate holidayStart =
                        startSql.toLocalDate();


                    LocalDate holidayEnd =
                        endSql.toLocalDate();


                    /*
                     * Only expand the part that overlaps
                     * the requested leave range.
                     */
                    LocalDate effectiveStart =
                        holidayStart.isBefore(
                            startDate
                        )
                            ? startDate
                            : holidayStart;


                    LocalDate effectiveEnd =
                        holidayEnd.isAfter(
                            endDate
                        )
                            ? endDate
                            : holidayEnd;


                    LocalDate current =
                        effectiveStart;


                    while (
                        !current.isAfter(
                            effectiveEnd
                        )
                    ) {


                        holidays.add(
                            current
                        );


                        current =
                            current.plusDays(
                                1
                            );
                    }
                }
            }
        }


        return holidays;
    }


    // =========================================================
    // CHECK SINGLE PUBLIC HOLIDAY
    //
    // True if the date falls anywhere within an active
    // public holiday range.
    // =========================================================

    public static boolean isPublicHoliday(
            Connection con,
            LocalDate date)
            throws SQLException {


        if (
            con == null ||
            date == null
        ) {

            return false;
        }


        String sql = """

            SELECT
                1

            FROM public_holidays

            WHERE is_active = 1

              AND ? BETWEEN start_date AND end_date

            LIMIT 1

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                )
        ) {


            ps.setDate(
                1,
                Date.valueOf(
                    date
                )
            );


            try (
                ResultSet rs =
                    ps.executeQuery()
            ) {


                return rs.next();
            }
        }
    }


    // =========================================================
    // COUNT WORKING LEAVE DAYS
    //
    // PKB WORKING DAYS:
    // SUNDAY - THURSDAY
    //
    // EXCLUDED:
    // - FRIDAY
    // - SATURDAY
    // - ACTIVE PUBLIC HOLIDAYS
    //
    // Public holiday ranges are supported.
    // =========================================================

    public static int countWorkingLeaveDays(
            Connection con,
            LocalDate startDate,
            LocalDate endDate)
            throws SQLException {


        if (
            con == null ||
            startDate == null ||
            endDate == null ||
            endDate.isBefore(startDate)
        ) {

            return 0;
        }


        Set<LocalDate> holidays =
            getPublicHolidayDates(
                con,
                startDate,
                endDate
            );


        int workingDays =
            0;


        LocalDate current =
            startDate;


        while (
            !current.isAfter(
                endDate
            )
        ) {


            DayOfWeek day =
                current.getDayOfWeek();


            boolean weekend =
                day == DayOfWeek.FRIDAY
                ||
                day == DayOfWeek.SATURDAY;


            boolean publicHoliday =
                holidays.contains(
                    current
                );


            if (
                !weekend &&
                !publicHoliday
            ) {

                workingDays++;
            }


            current =
                current.plusDays(
                    1
                );
        }


        return workingDays;
    }


    // =========================================================
    // GET ACTIVE PUBLIC HOLIDAYS AS DAILY MAPS
    //
    // IMPORTANT:
    //
    // Database:
    //
    // Hari Raya Aidilfitri
    // start_date = 2027-03-20
    // end_date   = 2027-03-21
    //
    // Returned list:
    //
    // Hari Raya Aidilfitri | 2027-03-20
    // Hari Raya Aidilfitri | 2027-03-21
    //
    // This preserves "holiday_date" so existing JSP / calendar
    // code can continue using the same key.
    // =========================================================

    public static List<Map<String, Object>>
            getActivePublicHolidays(
                    Connection con)
                    throws SQLException {


        List<Map<String, Object>> list =
            new ArrayList<>();


        if (con == null) {
            return list;
        }


        String sql = """

            SELECT
                id,
                holiday_name,
                start_date,
                end_date,
                description

            FROM public_holidays

            WHERE is_active = 1

            ORDER BY
                start_date ASC,
                end_date ASC,
                holiday_name ASC

        """;


        try (
            PreparedStatement ps =
                con.prepareStatement(
                    sql
                );

            ResultSet rs =
                ps.executeQuery()
        ) {


            while (rs.next()) {


                int id =
                    rs.getInt(
                        "id"
                    );


                String holidayName =
                    rs.getString(
                        "holiday_name"
                    );


                Date startSql =
                    rs.getDate(
                        "start_date"
                    );


                Date endSql =
                    rs.getDate(
                        "end_date"
                    );


                String description =
                    rs.getString(
                        "description"
                    );


                if (
                    startSql == null ||
                    endSql == null
                ) {
                    continue;
                }


                LocalDate startDate =
                    startSql.toLocalDate();


                LocalDate endDate =
                    endSql.toLocalDate();


                if (
                    endDate.isBefore(
                        startDate
                    )
                ) {
                    continue;
                }


                LocalDate current =
                    startDate;


                while (
                    !current.isAfter(
                        endDate
                    )
                ) {


                    Map<String, Object> row =
                        new HashMap<>();


                    row.put(
                        "id",
                        id
                    );


                    row.put(
                        "holiday_name",
                        holidayName
                    );


                    /*
                     * Kept for compatibility with existing JSPs.
                     */
                    row.put(
                        "holiday_date",
                        Date.valueOf(
                            current
                        )
                    );


                    /*
                     * Extra data in case calendar/admin page
                     * needs the original range.
                     */
                    row.put(
                        "start_date",
                        startSql
                    );


                    row.put(
                        "end_date",
                        endSql
                    );


                    row.put(
                        "description",
                        description
                    );


                    list.add(
                        row
                    );


                    current =
                        current.plusDays(
                            1
                        );
                }
            }
        }


        return list;
    }
}