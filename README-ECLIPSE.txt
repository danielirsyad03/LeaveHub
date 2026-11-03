LEAVEHUB — ECLIPSE / TOMCAT / MYSQL SETUP
=========================================

REQUIREMENTS
------------
1. JDK 17 or newer
2. Eclipse IDE for Enterprise Java and Web Developers
3. Apache Tomcat 10.1+
4. MySQL 8+
5. Maven (Eclipse m2e normally includes Maven support)

DATABASE
--------
1. Start MySQL.
2. Open MySQL Workbench or command line.
3. Run database/leavehub.sql.
4. Open src/main/java/com/leavehub/DBConnection.java.
5. Change:
       USER = "root";
       PASSWORD = "";
   to match your MySQL account.

ECLIPSE IMPORT
--------------
Option A — Maven:
1. File > Import > Maven > Existing Maven Projects.
2. Select this LeaveHub folder.
3. Finish.
4. Eclipse downloads the MySQL and Jakarta Servlet dependencies.

TOMCAT
------
1. Add Tomcat 10.1 to Eclipse:
   Window > Preferences > Server > Runtime Environments.
2. Right-click the project > Run As > Run on Server.
3. Select Tomcat 10.1.
4. Open:
   http://localhost:8080/LeaveHub/

LOGIN
-----
Staff:
Email: daniel@pkb.my
Password: 123456

HR:
Email: admin@pkb.my
Password: admin123

NEW STAFF
---------
HR > Staff Management > Add Staff.
New staff are given the temporary password:
welcome123

FEATURES
--------
- Login/logout
- Staff dashboard
- Annual and medical leave balance
- Apply leave
- Automatic duration
- Balance validation
- Application history
- Calendar
- HR approval/rejection
- HR remarks
- Automatic balance deduction
- Staff management
- MySQL shared database

IMPORTANT
---------
This is a working educational/project implementation.
For production, use HTTPS, CSRF protection, secure session settings,
role-based authorization on every endpoint, server-side file storage,
email notifications, audit logs, and BCrypt/Argon2 password hashing.
