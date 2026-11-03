# LeaveHub – PKB Staff Management & Corporate Leave Management System

LeaveHub is a web-based staff management and corporate leave management system developed for Permodalan Kedah Berhad (PKB).

The system is designed to centralise employee leave applications, attendance records, medical and dental benefits, inventory management, company announcements, events and other administrative operations.

## 1. Technologies Used

- Java 17
- JSP (JavaServer Pages)
- Java Servlets (Jakarta Servlet 6.0)
- MySQL Database
- MySQL Connector/J 9.0.0
- Apache Tomcat 10.1
- HTML, CSS and JavaScript
- Bootstrap
- Maven
- Eclipse IDE
- XAMPP / phpMyAdmin

## 2. System Modules

### Staff Management
- Staff account management
- Employee information
- Department management
- User authentication and access control

### Leave Management
- Apply for leave
- View leave applications
- Leave approval management
- Leave balance management
- Leave calendar
- Leave history

### Attendance Management
- Staff attendance check-in and check-out
- Attendance records
- Attendance status monitoring
- Administrative attendance management

### Medical & Dental Management
- Medical benefits allocation
- Dental benefits allocation
- Medical and dental claims
- Balance monitoring
- Claims and transaction records

### Inventory Management
- Inventory item management
- Inventory categories
- Inventory requests
- Inventory returns
- Inventory transactions

### Company Management
- Company announcements
- Announcement recipients
- Company events
- Vehicle management

### Administration
- Dashboard
- HR and HOD management
- Notifications
- Activity logs and audit trail

## 3. Project Structure

```text
LeaveHub/
│
├── database/
│   └── schema.sql
│
├── src/
│   └── main/
│       ├── java/
│       │   └── com/leavehub/
│       │
│       └── webapp/
│           ├── WEB-INF/
│           ├── css/
│           ├── js/
│           └── images/
│
├── pom.xml
├── .gitignore
├── README.md
└── README-ECLIPSE.txt
```

## 4. System Requirements

Before running LeaveHub, ensure the following software is installed:

1. JDK 17 or later.
2. Eclipse IDE with Enterprise Java and Web Development support.
3. Apache Tomcat 10.1.
4. MySQL Server or XAMPP.
5. phpMyAdmin (optional, for database management).
6. Maven.

## 5. Database Setup

1. Start Apache and MySQL using XAMPP.
2. Open phpMyAdmin:

   `http://localhost/phpmyadmin`

3. Create a database named:

   `leavehub`

4. Select the `leavehub` database.
5. Open the Import tab.
6. Import the `database/schema.sql` file.
7. Verify that the database tables have been created successfully.

**Note:** The schema file provides the database structure. Actual employee records and application data must be restored separately from an appropriate database backup.

## 6. Database Connection Configuration

The database connection is configured in:

`src/main/java/com/leavehub/DBConnection.java`

Default local development configuration:

- Database: leavehub
- Host: localhost
- Port: 3306
- Username: root
- Password: (empty by default)

Update the database credentials if your MySQL configuration is different.

Do not use development credentials in a production environment.

## 7. Running the Project in Eclipse

1. Open Eclipse IDE.
2. Import the project using:

   File → Import → Maven → Existing Maven Projects.

3. Select the LeaveHub project directory.
4. Finish the import.
5. Right-click the project.
6. Select Maven → Update Project.
7. Configure Apache Tomcat 10.1 in Eclipse.
8. Right-click the project.
9. Select Run As → Run on Server.
10. Open the application in your browser.

Example local URL:

`http://localhost:8080/LeaveHub/`

## 8. GitHub Repository

Source code and development history:

https://github.com/danielirsyad03/LeaveHub

The repository is currently maintained as a private development backup.

## 9. Development Status

Project status: Under Development

This project is continuously updated as new features, improvements and bug fixes are implemented.

## 10. Developer

Developed for:

**Permodalan Kedah Berhad (PKB)**

Project: LeaveHub – Staff Management & Corporate Leave Management System

Technology: Java Web Application

---

© 2026 LeaveHub. All rights reserved.