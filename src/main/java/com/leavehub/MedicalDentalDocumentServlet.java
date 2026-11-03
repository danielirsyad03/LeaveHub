package com.leavehub;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

@WebServlet("/medical-dental-document")
public class MedicalDentalDocumentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DOCUMENT_PREFIX = "uploads/medical-dental/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        final int currentUserId;
        final long claimId;
        try {
            currentUserId = Integer.parseInt(String.valueOf(session.getAttribute("userId")));
            claimId = Long.parseLong(request.getParameter("id"));
            if (currentUserId <= 0 || claimId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        } catch (NumberFormatException | NullPointerException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));
        boolean admin = "HR".equalsIgnoreCase(role) || "MANAGEMENT".equalsIgnoreCase(role);

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT user_id, document_path FROM medical_dental_claims WHERE id = ?")) {
            statement.setLong(1, claimId);

            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                if (!admin && result.getInt("user_id") != currentUserId) {
                    // Do not disclose whether another user's claim exists.
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                String relativePath = result.getString("document_path");
                if (relativePath == null || !relativePath.startsWith(DOCUMENT_PREFIX)) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                Path webRoot = resolveWebRoot();
                if (webRoot == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                Path documentPath = webRoot.resolve(relativePath).normalize();
                if (!documentPath.startsWith(webRoot) || !Files.isRegularFile(documentPath)) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                String fileName = documentPath.getFileName().toString();
                String contentType = determineContentType(fileName);
                if (contentType == null) {
                    response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
                    return;
                }

                response.setContentType(contentType);
                response.setHeader("X-Content-Type-Options", "nosniff");
                response.setHeader("Cache-Control", "private, no-store");
                response.setHeader("Content-Disposition", "inline; filename=\"" + safeHeaderFileName(fileName) + "\"");
                response.setContentLengthLong(Files.size(documentPath));
                Files.copy(documentPath, response.getOutputStream());
            }
        } catch (SQLException ex) {
            throw new ServletException("Tidak dapat membuka dokumen tuntutan.", ex);
        }
    }

    private Path resolveWebRoot() throws IOException {
        String realPath = getServletContext().getRealPath("/");
        if (realPath == null) {
            return null;
        }
        Path root = Paths.get(realPath).toRealPath();
        return root;
    }

    private String determineContentType(String fileName) {
        String lower = fileName.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".pdf")) return "application/pdf";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        return null;
    }

    private String safeHeaderFileName(String fileName) {
        // Keep only a plain filename and remove characters unsafe for response headers.
        String name = Paths.get(fileName).getFileName().toString();
        return name.replaceAll("[\\r\\n\\\"]", "_");
    }
}
