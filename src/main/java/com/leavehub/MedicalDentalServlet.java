package com.leavehub;



import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.MultipartConfig;

import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;

import jakarta.servlet.http.HttpServletRequest;

import jakarta.servlet.http.HttpServletResponse;

import jakarta.servlet.http.HttpSession;

import jakarta.servlet.http.Part;



import java.io.File;

import java.io.IOException;

import java.math.BigDecimal;

import java.math.RoundingMode;

import java.nio.file.Paths;

import java.sql.Connection;

import java.sql.PreparedStatement;

import java.sql.ResultSet;

import java.sql.SQLException;

import java.sql.Statement;

import java.sql.Types;

import java.time.LocalDate;

import java.util.ArrayList;

import java.util.HashMap;

import java.util.List;

import java.util.Map;

import java.util.UUID;



@WebServlet(urlPatterns = {"/medical-dental", "/medical-dental-management"})

@MultipartConfig(

       maxFileSize = 10L * 1024 * 1024,

       maxRequestSize = 12L * 1024 * 1024

)

public class MedicalDentalServlet extends HttpServlet {



       private static final long serialVersionUID = 1L;



       private static final BigDecimal DEFAULT_MEDICAL =

               new BigDecimal("1500.00");



       private static final BigDecimal DEFAULT_DENTAL =

               new BigDecimal("200.00");



       // =====================================================

       // ROLE

       // =====================================================



       private boolean isAdmin(String role) {

           return "HR".equalsIgnoreCase(role)

                   || "MANAGEMENT".equalsIgnoreCase(role);

       }



       // =====================================================

       // DATABASE SCHEMA

       // =====================================================



       private void ensureSchema(Connection con) throws SQLException {



           try (Statement st = con.createStatement()) {



               st.executeUpdate("""

                   CREATE TABLE IF NOT EXISTS medical_dental_benefits (

                       id BIGINT AUTO_INCREMENT PRIMARY KEY,

                       user_id INT NOT NULL,

                       benefit_year INT NOT NULL,

                       medical_allocation DECIMAL(10,2) NOT NULL DEFAULT 1500.00,

                       medical_used DECIMAL(10,2) NOT NULL DEFAULT 0.00,

                       dental_allocation DECIMAL(10,2) NOT NULL DEFAULT 200.00,

                       dental_used DECIMAL(10,2) NOT NULL DEFAULT 0.00,

                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

                           ON UPDATE CURRENT_TIMESTAMP,

                       UNIQUE KEY uq_medical_dental_user_year

                           (user_id, benefit_year),

                       CONSTRAINT fk_md_benefit_user

                           FOREIGN KEY (user_id)

                           REFERENCES users(id)

                           ON DELETE CASCADE

                   ) ENGINE=InnoDB

               """);



               st.executeUpdate("""

                   CREATE TABLE IF NOT EXISTS medical_dental_claims (

                       id BIGINT AUTO_INCREMENT PRIMARY KEY,

                       user_id INT NOT NULL,

                       benefit_year INT NOT NULL,

                       claim_type ENUM('MEDICAL','DENTAL') NOT NULL,

                       treatment_date DATE NOT NULL,

                       description VARCHAR(1000) NOT NULL,

                       bill_amount DECIMAL(10,2) NOT NULL,

                       pkb_amount DECIMAL(10,2) NOT NULL,

                       staff_amount DECIMAL(10,2) NOT NULL,

                       document_path VARCHAR(500) NULL,

                       recorded_by INT NOT NULL,

                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

                           ON UPDATE CURRENT_TIMESTAMP,

                       CONSTRAINT fk_md_claim_user

                           FOREIGN KEY (user_id) REFERENCES users(id),

                       CONSTRAINT fk_md_claim_recorder

                           FOREIGN KEY (recorded_by) REFERENCES users(id)

                   ) ENGINE=InnoDB

               """);



               st.executeUpdate("""

                   CREATE TABLE IF NOT EXISTS medical_dental_transactions (

                       id BIGINT AUTO_INCREMENT PRIMARY KEY,

                       user_id INT NOT NULL,

                       benefit_year INT NOT NULL,

                       claim_id BIGINT NULL,

                       benefit_type ENUM('MEDICAL','DENTAL') NOT NULL,

                       transaction_type ENUM(

                           'CLAIM',

                           'ALLOCATION_ADJUSTMENT',

                           'REVERSAL'

                       ) NOT NULL,

                       amount DECIMAL(10,2) NOT NULL,

                       balance_before DECIMAL(10,2) NOT NULL,

                       balance_after DECIMAL(10,2) NOT NULL,

                       remarks VARCHAR(1000) NOT NULL,

                       created_by INT NOT NULL,

                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                       CONSTRAINT fk_md_tx_user

                           FOREIGN KEY (user_id) REFERENCES users(id),

                       CONSTRAINT fk_md_tx_claim

                           FOREIGN KEY (claim_id)

                           REFERENCES medical_dental_claims(id)

                           ON DELETE SET NULL,

                       CONSTRAINT fk_md_tx_creator

                           FOREIGN KEY (created_by) REFERENCES users(id)

                   ) ENGINE=InnoDB

               """);



               // Peruntukan individu yang digunakan untuk tahun semasa

               // dan tahun-tahun berikutnya.



               st.executeUpdate("""

                   CREATE TABLE IF NOT EXISTS medical_dental_allocation_settings (

                       user_id INT PRIMARY KEY,

                       medical_allocation DECIMAL(10,2) NOT NULL DEFAULT 1500.00,

                       dental_allocation DECIMAL(10,2) NOT NULL DEFAULT 200.00,

                       updated_by INT NULL,

                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

                           ON UPDATE CURRENT_TIMESTAMP,

                       CONSTRAINT fk_md_setting_user

                           FOREIGN KEY (user_id)

                           REFERENCES users(id)

                           ON DELETE CASCADE,

                       CONSTRAINT fk_md_setting_admin

                           FOREIGN KEY (updated_by)

                           REFERENCES users(id)

                           ON DELETE SET NULL

                   ) ENGINE=InnoDB

               """);



               // Audit perubahan kadar peruntukan.

               // Ini bukan transaksi pelarasan baki.



               st.executeUpdate("""

                   CREATE TABLE IF NOT EXISTS medical_dental_allocation_audit (

                       id BIGINT AUTO_INCREMENT PRIMARY KEY,

                       user_id INT NOT NULL,

                       old_medical_allocation DECIMAL(10,2) NOT NULL,

                       new_medical_allocation DECIMAL(10,2) NOT NULL,

                       old_dental_allocation DECIMAL(10,2) NOT NULL,

                       new_dental_allocation DECIMAL(10,2) NOT NULL,

                       reason VARCHAR(1000) NOT NULL,

                       changed_by INT NOT NULL,

                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                       CONSTRAINT fk_md_audit_user

                           FOREIGN KEY (user_id) REFERENCES users(id),

                       CONSTRAINT fk_md_audit_admin

                           FOREIGN KEY (changed_by) REFERENCES users(id)

                   ) ENGINE=InnoDB

               """);

           }



           // Migrasi kadar sedia ada.

           // Mengambil peruntukan daripada tahun manfaat terkini.

           // INSERT IGNORE memastikan kadar khas yang telah ditetapkan

           // tidak ditindih semasa halaman dibuka.



           try (PreparedStatement ps = con.prepareStatement("""

               INSERT IGNORE INTO medical_dental_allocation_settings

                   (user_id, medical_allocation, dental_allocation)

               SELECT b.user_id, b.medical_allocation, b.dental_allocation

               FROM medical_dental_benefits b

               INNER JOIN (

                   SELECT user_id, MAX(benefit_year) AS latest_year

                   FROM medical_dental_benefits

                   GROUP BY user_id

               ) latest

                   ON latest.user_id = b.user_id

                   AND latest.latest_year = b.benefit_year

           """)) {

               ps.executeUpdate();

           }

       }



       // =====================================================

       // ENSURE BENEFIT

       // =====================================================



       private void ensureBenefit(

               Connection con,

               int userId,

               int year) throws SQLException {



           try (PreparedStatement ps = con.prepareStatement("""

               INSERT IGNORE INTO medical_dental_benefits

                   (

                       user_id,

                       benefit_year,

                       medical_allocation,

                       medical_used,

                       dental_allocation,

                       dental_used

                   )

               SELECT

                   u.id,

                   ?,

                   COALESCE(s.medical_allocation, ?),

                   0.00,

                   COALESCE(s.dental_allocation, ?),

                   0.00

               FROM users u

               LEFT JOIN medical_dental_allocation_settings s

                   ON s.user_id = u.id

               WHERE u.id = ?

           """)) {



               ps.setInt(1, year);

               ps.setBigDecimal(2, DEFAULT_MEDICAL);

               ps.setBigDecimal(3, DEFAULT_DENTAL);

               ps.setInt(4, userId);



               ps.executeUpdate();

           }

       }



       // =====================================================

       // GET

       // =====================================================



       @Override

       protected void doGet(

               HttpServletRequest request,

               HttpServletResponse response)

               throws ServletException, IOException {



           HttpSession session = request.getSession(false);



           if (session == null || session.getAttribute("userId") == null) {

               response.sendRedirect(request.getContextPath() + "/");

               return;

           }



           int userId = Integer.parseInt(

                   session.getAttribute("userId").toString());



           String role = String.valueOf(session.getAttribute("userRole"));



           boolean adminRole = isAdmin(role);



           boolean managementPage = request.getServletPath()

                   .endsWith("/medical-dental-management");



           if (managementPage && !adminRole) {

               response.sendError(

                       HttpServletResponse.SC_FORBIDDEN,

                       "Akses pentadbiran sahaja.");

               return;

           }



           boolean admin = adminRole && managementPage;



           int year = LocalDate.now().getYear();



           try (Connection con = DBConnection.getConnection()) {



               ensureSchema(con);



               if (admin) {



                   // Pastikan semua staf mempunyai rekod tahun semasa.



                   try (PreparedStatement ps =

                           con.prepareStatement("SELECT id FROM users");

                        ResultSet rs = ps.executeQuery()) {



                       while (rs.next()) {

                           ensureBenefit(con, rs.getInt("id"), year);

                       }

                   }



                   ensureBenefit(con, userId, year);



                   // Ringkasan manfaat admin.



                   loadOwnBenefit(request, con, userId, year);



                   // Senarai manfaat semua staf.



                   List<Map<String, Object>> staff =

                           new ArrayList<>();



                   try (PreparedStatement ps = con.prepareStatement("""

                       SELECT

                           u.id,

                           u.name,

                           u.email,

                           b.medical_allocation,

                           b.medical_used,

                           GREATEST(

                               0,

                               b.medical_allocation - b.medical_used

                           ) AS medical_balance,

                           b.dental_allocation,

                           b.dental_used,

                           GREATEST(

                               0,

                               b.dental_allocation - b.dental_used

                           ) AS dental_balance

                       FROM users u

                       JOIN medical_dental_benefits b

                           ON b.user_id = u.id

                           AND b.benefit_year = ?

                       ORDER BY u.name

                   """)) {



                       ps.setInt(1, year);



                       try (ResultSet rs = ps.executeQuery()) {



                           while (rs.next()) {



                               Map<String, Object> row = new HashMap<>();



                               row.put("id", rs.getInt("id"));

                               row.put("name", rs.getString("name"));

                               row.put("email", rs.getString("email"));



                               row.put("medicalAllocation",

                                       rs.getBigDecimal("medical_allocation"));



                               row.put("medicalUsed",

                                       rs.getBigDecimal("medical_used"));



                               row.put("medicalBalance",

                                       rs.getBigDecimal("medical_balance"));



                               row.put("dentalAllocation",

                                       rs.getBigDecimal("dental_allocation"));



                               row.put("dentalUsed",

                                       rs.getBigDecimal("dental_used"));



                               row.put("dentalBalance",

                                       rs.getBigDecimal("dental_balance"));



                               staff.add(row);

                           }

                       }

                   }



                   boolean showAllClaims =

                           "all".equalsIgnoreCase(request.getParameter("claims"));



                   Integer claimStaffId = null;



                   String claimStaffParam =

                           request.getParameter("claimStaffId");



                   if (claimStaffParam != null

                           && !claimStaffParam.isBlank()) {



                       try {

                           claimStaffId = Integer.valueOf(claimStaffParam);

                       } catch (NumberFormatException ignored) {
                           throw new ServletException("Pilihan staf untuk cetakan tidak sah.");
                       }

                   }



                   List<Map<String, Object>> claims =

                           loadClaims(

                                   con,

                                   claimStaffId,

                                   year,

                                   (!showAllClaims && claimStaffId == null) ? 5 : 0

                           );



                   request.setAttribute("staffBenefits", staff);

                   request.setAttribute("claims", claims);

                   request.setAttribute("showAllClaims", showAllClaims);

                   request.setAttribute("claimStaffId", claimStaffId);
                   request.setAttribute("autoPrintClaims", "1".equals(request.getParameter("autoPrint")));



                   // Audit perubahan kadar peruntukan.



                   List<Map<String, Object>> allocationAudits =

                           loadAllocationAudits(con, year, 5);



                   request.setAttribute(

                           "allocationAudits", allocationAudits);



                   request.setAttribute("printGeneratedBy",

                           session.getAttribute("userName") == null

                                   ? "Pentadbir"

                                   : session.getAttribute("userName").toString());



                   request.setAttribute("printRole", role);



               } else {



                   ensureBenefit(con, userId, year);



                   loadOwnBenefit(request, con, userId, year);



                   request.setAttribute(

                           "claims",

                           loadClaims(con, userId, year));

               }



               request.setAttribute("isMedicalAdmin", admin);

               request.setAttribute("benefitYear", year);



               request.getRequestDispatcher(

                       "/medical-dental.jsp").forward(request, response);



           } catch (SQLException e) {



               throw new ServletException(

                       "Tidak dapat memuatkan maklumat manfaat perubatan dan pergigian.",

                       e);

           }

       }



       // =====================================================

       // LOAD OWN BENEFIT

       // =====================================================



       private void loadOwnBenefit(

               HttpServletRequest request,

               Connection con,

               int userId,

               int year) throws SQLException {



           try (PreparedStatement ps = con.prepareStatement("""

               SELECT *

               FROM medical_dental_benefits

               WHERE user_id = ? AND benefit_year = ?

           """)) {



               ps.setInt(1, userId);

               ps.setInt(2, year);



               try (ResultSet rs = ps.executeQuery()) {



                   if (rs.next()) {



                       BigDecimal medicalAllocation =

                               rs.getBigDecimal("medical_allocation");



                       BigDecimal medicalUsed =

                               rs.getBigDecimal("medical_used");



                       BigDecimal dentalAllocation =

                               rs.getBigDecimal("dental_allocation");



                       BigDecimal dentalUsed =

                               rs.getBigDecimal("dental_used");



                       request.setAttribute(

                               "medicalAllocation", medicalAllocation);



                       request.setAttribute(

                               "medicalUsed", medicalUsed);



                       request.setAttribute(

                               "medicalBalance",

                               medicalAllocation.subtract(medicalUsed)

                                       .max(BigDecimal.ZERO));



                       request.setAttribute(

                               "dentalAllocation", dentalAllocation);



                       request.setAttribute(

                               "dentalUsed", dentalUsed);



                       request.setAttribute(

                               "dentalBalance",

                               dentalAllocation.subtract(dentalUsed)

                                       .max(BigDecimal.ZERO));

                   }

               }

           }

       }



       // =====================================================

       // LOAD CLAIMS

       // =====================================================



       private List<Map<String, Object>> loadClaims(

               Connection con,

               Integer userId,

               int year) throws SQLException {



           return loadClaims(con, userId, year, 0);

       }



       private List<Map<String, Object>> loadClaims(

               Connection con,

               Integer userId,

               int year,

               int limit) throws SQLException {



           List<Map<String, Object>> claims =

                   new ArrayList<>();



           String sql = """

               SELECT

                   c.*,

                   u.name AS staff_name,

                   r.name AS recorder_name

               FROM medical_dental_claims c

               JOIN users u ON u.id = c.user_id

               JOIN users r ON r.id = c.recorded_by

               WHERE c.benefit_year = ?

                 AND (? IS NULL OR c.user_id = ?)

               ORDER BY c.created_at DESC, c.id DESC

           """ + (limit > 0 ? " LIMIT ?" : "");



           try (PreparedStatement ps = con.prepareStatement(sql)) {



               ps.setInt(1, year);



               if (userId == null) {

                   ps.setNull(2, Types.INTEGER);

                   ps.setNull(3, Types.INTEGER);

               } else {

                   ps.setInt(2, userId);

                   ps.setInt(3, userId);

               }



               if (limit > 0) {

                   ps.setInt(4, limit);

               }



               try (ResultSet rs = ps.executeQuery()) {



                   while (rs.next()) {



                       Map<String, Object> row = new HashMap<>();



                       row.put("id", rs.getLong("id"));

                       row.put("staffName", rs.getString("staff_name"));

                       row.put("claimType", rs.getString("claim_type"));

                       row.put("treatmentDate", rs.getDate("treatment_date"));

                       row.put("description", rs.getString("description"));

                       row.put("billAmount", rs.getBigDecimal("bill_amount"));

                       row.put("pkbAmount", rs.getBigDecimal("pkb_amount"));

                       row.put("staffAmount", rs.getBigDecimal("staff_amount"));

                       row.put("documentPath", rs.getString("document_path"));

                       row.put("recorderName", rs.getString("recorder_name"));

                       row.put("createdAt", rs.getTimestamp("created_at"));



                       claims.add(row);

                   }

               }

           }



           return claims;

       }



       // =====================================================

       // LOAD ALLOCATION AUDIT

       // =====================================================



       private List<Map<String, Object>> loadAllocationAudits(

               Connection con,

               int year,

               int limit) throws SQLException {



           List<Map<String, Object>> rows =

                   new ArrayList<>();



           String sql = """

               SELECT

                   a.*,

                   u.name AS staff_name,

                   admin.name AS admin_name

               FROM medical_dental_allocation_audit a

               JOIN users u ON u.id = a.user_id

               JOIN users admin ON admin.id = a.changed_by

               WHERE YEAR(a.created_at) = ?

               ORDER BY a.created_at DESC, a.id DESC

           """ + (limit > 0 ? " LIMIT ?" : "");



           try (PreparedStatement ps = con.prepareStatement(sql)) {



               ps.setInt(1, year);



               if (limit > 0) {

                   ps.setInt(2, limit);

               }



               try (ResultSet rs = ps.executeQuery()) {



                   while (rs.next()) {



                       Map<String, Object> row = new HashMap<>();



                       row.put("id", rs.getLong("id"));

                       row.put("staffName", rs.getString("staff_name"));



                       row.put("oldMedical",

                               rs.getBigDecimal("old_medical_allocation"));



                       row.put("newMedical",

                               rs.getBigDecimal("new_medical_allocation"));



                       row.put("oldDental",

                               rs.getBigDecimal("old_dental_allocation"));



                       row.put("newDental",

                               rs.getBigDecimal("new_dental_allocation"));



                       row.put("reason", rs.getString("reason"));

                       row.put("adminName", rs.getString("admin_name"));

                       row.put("createdAt", rs.getTimestamp("created_at"));



                       rows.add(row);

                   }

               }

           }



           return rows;

       }



       // =====================================================

       // POST

       // =====================================================



       @Override

       protected void doPost(

               HttpServletRequest request,

               HttpServletResponse response)

               throws ServletException, IOException {



           HttpSession session = request.getSession(false);



           if (session == null

                   || session.getAttribute("userId") == null) {



               response.sendRedirect(request.getContextPath() + "/");

               return;

           }



           String role = String.valueOf(

                   session.getAttribute("userRole"));



           if (!isAdmin(role)

                   || !request.getServletPath()

                           .endsWith("/medical-dental-management")) {



               response.sendError(

                       HttpServletResponse.SC_FORBIDDEN,

                       "Akses pentadbiran sahaja.");



               return;

           }



           int adminId = Integer.parseInt(

                   session.getAttribute("userId").toString());



           /*
            * Baca parameter action dengan betul untuk kedua-dua jenis borang:
            * - multipart/form-data (rekod tuntutan dengan dokumen sokongan)
            * - application/x-www-form-urlencoded (kemas kini peruntukan)
            */
           String action = null;
           String contentType = request.getContentType();

           if (contentType != null
                   && contentType.toLowerCase(java.util.Locale.ROOT)
                           .startsWith("multipart/form-data")) {

               Part actionPart = request.getPart("action");

               if (actionPart != null) {
                   try (java.io.InputStream input =
                           actionPart.getInputStream()) {

                       action = new String(
                               input.readAllBytes(),
                               java.nio.charset.StandardCharsets.UTF_8
                       ).trim();
                   }
               }

           } else {
               action = request.getParameter("action");
           }

           if (action == null || action.isBlank()) {
               response.sendError(
                       HttpServletResponse.SC_BAD_REQUEST,
                       "Tindakan borang tidak diterima. Sila muat semula halaman dan cuba lagi."
               );
               return;
           }

           int year = LocalDate.now().getYear();



           try (Connection con = DBConnection.getConnection()) {



               ensureSchema(con);



               if ("recordClaim".equals(action)) {



                   recordClaim(request, con, adminId, year);



                   session.setAttribute(

                           "medicalDentalFlash",

                           "Tuntutan berjaya direkodkan dan baki dikemas kini.");



               } else if ("updateAllocation".equals(action)) {



                   updateAllocation(request, con, adminId, year);



                   session.setAttribute(

                           "medicalDentalFlash",

                           "Peruntukan staf berjaya dikemas kini.");



               } else {



                   response.sendError(

                           HttpServletResponse.SC_BAD_REQUEST,

                           "Tindakan tidak sah.");



                   return;

               }



               response.sendRedirect(

                       request.getContextPath()

                               + "/medical-dental-management");



           } catch (IllegalArgumentException e) {



               session.setAttribute(

                       "medicalDentalError",

                       e.getMessage());



               response.sendRedirect(

                       request.getContextPath()

                               + "/medical-dental-management");



           } catch (SQLException e) {



               throw new ServletException(

                       "Operasi pengurusan manfaat gagal.", e);

           }

       }



       // =====================================================

       // RECORD CLAIM

       // =====================================================



       private void recordClaim(

               HttpServletRequest request,

               Connection con,

               int adminId,

               int year)

               throws SQLException, IOException, ServletException {



           int userId = parsePositiveInt(

                   request.getParameter("userId"),

                   "Sila pilih staf.");



           String type = request.getParameter("claimType");



           if (!"MEDICAL".equals(type)

                   && !"DENTAL".equals(type)) {



               throw new IllegalArgumentException(

                       "Jenis tuntutan tidak sah.");

           }



           LocalDate treatmentDate;



           try {

               treatmentDate = LocalDate.parse(

                       request.getParameter("treatmentDate"));

           } catch (Exception e) {

               throw new IllegalArgumentException(

                       "Sila masukkan tarikh rawatan yang sah.");

           }



           // Tahun rawatan mesti sama dengan tahun manfaat semasa.



           if (treatmentDate.getYear() != year) {

               throw new IllegalArgumentException(

                       "Tarikh rawatan mestilah dalam tahun manfaat "

                               + year + ".");

           }



           String description =

                   request.getParameter("description") == null

                           ? ""

                           : request.getParameter("description").trim();



           if (description.isEmpty()

                   || description.length() > 1000) {



               throw new IllegalArgumentException(

                       "Sila masukkan keterangan (maksimum 1,000 aksara).");

           }



           BigDecimal bill;



           try {

               bill = new BigDecimal(

                       request.getParameter("billAmount"))

                       .setScale(2, RoundingMode.HALF_UP);



           } catch (Exception e) {

               throw new IllegalArgumentException(

                       "Jumlah bil tidak sah.");

           }



           if (bill.compareTo(BigDecimal.ZERO) <= 0) {

               throw new IllegalArgumentException(

                       "Jumlah bil mesti lebih daripada RM0.00.");

           }



           String documentPath = saveOptionalDocument(request);



           boolean oldAutoCommit = con.getAutoCommit();



           con.setAutoCommit(false);



           try {



               ensureBenefit(con, userId, year);



               String lockSql = """

                   SELECT

                       medical_allocation,

                       medical_used,

                       dental_allocation,

                       dental_used

                   FROM medical_dental_benefits

                   WHERE user_id = ? AND benefit_year = ?

                   FOR UPDATE

               """;



               BigDecimal allocation;

               BigDecimal used;



               try (PreparedStatement ps =

                       con.prepareStatement(lockSql)) {



                   ps.setInt(1, userId);

                   ps.setInt(2, year);



                   try (ResultSet rs = ps.executeQuery()) {



                       if (!rs.next()) {

                           throw new IllegalArgumentException(

                                   "Rekod manfaat staf tidak dijumpai.");

                       }



                       allocation = rs.getBigDecimal(

                               "MEDICAL".equals(type)

                                       ? "medical_allocation"

                                       : "dental_allocation");



                       used = rs.getBigDecimal(

                               "MEDICAL".equals(type)

                                       ? "medical_used"

                                       : "dental_used");

                   }

               }



               BigDecimal before =

                       allocation.subtract(used)

                               .max(BigDecimal.ZERO);



               BigDecimal pkb = bill.min(before);



               BigDecimal personal = bill.subtract(pkb);



               long claimId;



               try (PreparedStatement ps = con.prepareStatement("""

                   INSERT INTO medical_dental_claims

                       (

                           user_id,

                           benefit_year,

                           claim_type,

                           treatment_date,

                           description,

                           bill_amount,

                           pkb_amount,

                           staff_amount,

                           document_path,

                           recorded_by

                       )

                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

               """, Statement.RETURN_GENERATED_KEYS)) {



                   ps.setInt(1, userId);

                   ps.setInt(2, year);

                   ps.setString(3, type);

                   ps.setDate(4,

                           java.sql.Date.valueOf(treatmentDate));

                   ps.setString(5, description);

                   ps.setBigDecimal(6, bill);

                   ps.setBigDecimal(7, pkb);

                   ps.setBigDecimal(8, personal);

                   ps.setString(9, documentPath);

                   ps.setInt(10, adminId);



                   ps.executeUpdate();



                   try (ResultSet keys = ps.getGeneratedKeys()) {



                       if (!keys.next()) {

                           throw new SQLException(

                                   "ID tuntutan tidak dijana.");

                       }



                       claimId = keys.getLong(1);

                   }

               }



               String usedColumn =

                       "MEDICAL".equals(type)

                               ? "medical_used"

                               : "dental_used";



               try (PreparedStatement ps = con.prepareStatement(

                       "UPDATE medical_dental_benefits SET "

                               + usedColumn + " = "

                               + usedColumn

                               + " + ? WHERE user_id = ? AND benefit_year = ?")) {



                   ps.setBigDecimal(1, pkb);

                   ps.setInt(2, userId);

                   ps.setInt(3, year);



                   ps.executeUpdate();

               }



               try (PreparedStatement ps = con.prepareStatement("""

                   INSERT INTO medical_dental_transactions

                       (

                           user_id,

                           benefit_year,

                           claim_id,

                           benefit_type,

                           transaction_type,

                           amount,

                           balance_before,

                           balance_after,

                           remarks,

                           created_by

                       )

                   VALUES (?, ?, ?, ?, 'CLAIM', ?, ?, ?, ?, ?)

               """)) {



                   ps.setInt(1, userId);

                   ps.setInt(2, year);

                   ps.setLong(3, claimId);

                   ps.setString(4, type);

                   ps.setBigDecimal(5, pkb);

                   ps.setBigDecimal(6, before);

                   ps.setBigDecimal(7, before.subtract(pkb));



                   ps.setString(

                           8,

                           "Bil RM" + bill

                                   + "; ditanggung PKB RM" + pkb

                                   + "; dibayar staf RM" + personal);



                   ps.setInt(9, adminId);



                   ps.executeUpdate();

               }



               con.commit();



           } catch (Exception e) {



               con.rollback();



               if (documentPath != null) {

                   deleteDocument(request, documentPath);

               }



               if (e instanceof SQLException se) {

                   throw se;

               }



               if (e instanceof IllegalArgumentException iae) {

                   throw iae;

               }



               if (e instanceof ServletException se) {

                   throw se;

               }



               if (e instanceof IOException ioe) {

                   throw ioe;

               }



               throw new SQLException(e);



           } finally {

               con.setAutoCommit(oldAutoCommit);

           }

       }



       // =====================================================

       // UPDATE STAFF ALLOCATION

       // =====================================================



       private void updateAllocation(

               HttpServletRequest request,

               Connection con,

               int adminId,

               int year) throws SQLException {



           int userId = parsePositiveInt(

                   request.getParameter("userId"),

                   "Sila pilih staf.");



           BigDecimal newMedical;

           BigDecimal newDental;



           try {

               newMedical = new BigDecimal(

                       request.getParameter("medicalAllocation"))

                       .setScale(2, RoundingMode.HALF_UP);



               newDental = new BigDecimal(

                       request.getParameter("dentalAllocation"))

                       .setScale(2, RoundingMode.HALF_UP);



           } catch (Exception e) {



               throw new IllegalArgumentException(

                       "Sila masukkan jumlah peruntukan yang sah.");

           }



           if (newMedical.compareTo(BigDecimal.ZERO) < 0

                   || newDental.compareTo(BigDecimal.ZERO) < 0) {



               throw new IllegalArgumentException(

                       "Peruntukan tidak boleh bernilai negatif.");

           }



           if (newMedical.compareTo(new BigDecimal("99999999.99")) > 0

                   || newDental.compareTo(new BigDecimal("99999999.99")) > 0) {



               throw new IllegalArgumentException(

                       "Jumlah peruntukan terlalu tinggi.");

           }



           String reason = request.getParameter("allocationReason");



           if (reason == null

                   || reason.trim().isEmpty()

                   || reason.trim().length() > 1000) {



               throw new IllegalArgumentException(

                       "Sila nyatakan sebab perubahan peruntukan.");

           }



           ensureBenefit(con, userId, year);



           boolean oldAutoCommit = con.getAutoCommit();



           con.setAutoCommit(false);



           try {



               BigDecimal oldMedical;

               BigDecimal oldDental;

               BigDecimal medicalUsed;

               BigDecimal dentalUsed;



               try (PreparedStatement ps = con.prepareStatement("""

                   SELECT

                       medical_allocation,

                       medical_used,

                       dental_allocation,

                       dental_used

                   FROM medical_dental_benefits

                   WHERE user_id = ? AND benefit_year = ?

                   FOR UPDATE

               """)) {



                   ps.setInt(1, userId);

                   ps.setInt(2, year);



                   try (ResultSet rs = ps.executeQuery()) {



                       if (!rs.next()) {

                           throw new SQLException(

                                   "Rekod manfaat staf tidak dijumpai.");

                       }



                       oldMedical = rs.getBigDecimal("medical_allocation");

                       medicalUsed = rs.getBigDecimal("medical_used");



                       oldDental = rs.getBigDecimal("dental_allocation");

                       dentalUsed = rs.getBigDecimal("dental_used");

                   }

               }



               if (newMedical.compareTo(medicalUsed) < 0) {

                   throw new IllegalArgumentException(

                           "Peruntukan perubatan tidak boleh lebih rendah "

                                   + "daripada jumlah yang telah digunakan: RM"

                                   + medicalUsed);

               }



               if (newDental.compareTo(dentalUsed) < 0) {

                   throw new IllegalArgumentException(

                           "Peruntukan pergigian tidak boleh lebih rendah "

                                   + "daripada jumlah yang telah digunakan: RM"

                                   + dentalUsed);

               }



               // Kemaskini tetapan kekal staf.



               try (PreparedStatement ps = con.prepareStatement("""

                   INSERT INTO medical_dental_allocation_settings

                       (

                           user_id,

                           medical_allocation,

                           dental_allocation,

                           updated_by

                       )

                   VALUES (?, ?, ?, ?)

                   ON DUPLICATE KEY UPDATE

                       medical_allocation = VALUES(medical_allocation),

                       dental_allocation = VALUES(dental_allocation),

                       updated_by = VALUES(updated_by)

               """)) {



                   ps.setInt(1, userId);

                   ps.setBigDecimal(2, newMedical);

                   ps.setBigDecimal(3, newDental);

                   ps.setInt(4, adminId);



                   ps.executeUpdate();

               }



               // Kemaskini peruntukan tahun semasa sahaja.

               // Jumlah penggunaan tidak diubah.



               try (PreparedStatement ps = con.prepareStatement("""

                   UPDATE medical_dental_benefits

                   SET

                       medical_allocation = ?,

                       dental_allocation = ?

                   WHERE user_id = ? AND benefit_year = ?

               """)) {



                   ps.setBigDecimal(1, newMedical);

                   ps.setBigDecimal(2, newDental);

                   ps.setInt(3, userId);

                   ps.setInt(4, year);



                   ps.executeUpdate();

               }



               // Simpan audit perubahan kadar.



               if (oldMedical.compareTo(newMedical) != 0

                       || oldDental.compareTo(newDental) != 0) {



                   try (PreparedStatement ps = con.prepareStatement("""

                       INSERT INTO medical_dental_allocation_audit

                           (

                               user_id,

                               old_medical_allocation,

                               new_medical_allocation,

                               old_dental_allocation,

                               new_dental_allocation,

                               reason,

                               changed_by

                           )

                       VALUES (?, ?, ?, ?, ?, ?, ?)

                   """)) {



                       ps.setInt(1, userId);

                       ps.setBigDecimal(2, oldMedical);

                       ps.setBigDecimal(3, newMedical);

                       ps.setBigDecimal(4, oldDental);

                       ps.setBigDecimal(5, newDental);

                       ps.setString(6, reason.trim());

                       ps.setInt(7, adminId);



                       ps.executeUpdate();

                   }

               }



               con.commit();



           } catch (SQLException | RuntimeException e) {



               con.rollback();

               throw e;



           } finally {

               con.setAutoCommit(oldAutoCommit);

           }

       }



       // =====================================================

       // DOCUMENT UPLOAD

       // =====================================================



       private String saveOptionalDocument(

               HttpServletRequest request)

               throws IOException, ServletException {



           Part part = request.getPart("supportingDocument");



           if (part == null || part.getSize() == 0) {

               return null;

           }



           String submittedName = part.getSubmittedFileName();



           if (submittedName == null

                   || submittedName.trim().isEmpty()) {



               throw new IllegalArgumentException(

                       "Nama fail dokumen tidak sah.");

           }



           String original =

                   Paths.get(submittedName).getFileName().toString();



           String lower = original.toLowerCase(

                   java.util.Locale.ROOT);



           if (!(lower.endsWith(".pdf")

                   || lower.endsWith(".jpg")

                   || lower.endsWith(".jpeg")

                   || lower.endsWith(".png"))) {



               throw new IllegalArgumentException(

                       "Dokumen mesti dalam format PDF, JPG, JPEG atau PNG.");

           }



           String uploadRoot = getServletContext()

                   .getRealPath("/uploads/medical-dental");



           if (uploadRoot == null) {

               throw new IOException(

                       "Folder muat naik tidak tersedia.");

           }



           File dir = new File(uploadRoot);



           if (!dir.exists() && !dir.mkdirs()) {

               throw new IOException(

                       "Folder muat naik tidak dapat dicipta.");

           }



           String extension =

                   original.substring(original.lastIndexOf('.'))

                           .toLowerCase();



           String safeName = UUID.randomUUID() + extension;



           part.write(new File(dir, safeName).getAbsolutePath());



           return "uploads/medical-dental/" + safeName;

       }



       private void deleteDocument(

               HttpServletRequest request,

               String relativePath) {



           try {



               String root = getServletContext().getRealPath("/");



               if (root != null) {

                   new File(root, relativePath).delete();

               }



           } catch (Exception ignored) {

               // Tiada tindakan lanjut.

           }

       }



       // =====================================================

       // VALIDATION

       // =====================================================



       private int parsePositiveInt(

               String value,

               String error) {



           try {



               int result = Integer.parseInt(value);



               if (result > 0) {

                   return result;

               }



           } catch (Exception ignored) {

               // Teruskan kepada mesej ralat.

           }



           throw new IllegalArgumentException(error);

       }

}
