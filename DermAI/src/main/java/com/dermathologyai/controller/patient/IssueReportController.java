package com.dermathologyai.controller.patient;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.IssueReportDAO;
import com.dermathologyai.model.IssueReport;
import com.dermathologyai.model.User;
import com.dermathologyai.service.CloudinaryUpload;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/** Patient/doctor endpoint for submitting an issue to the administration team. */
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class IssueReportController extends HttpServlet {
    private static final int MAX_TITLE_LENGTH = 150;
    private static final int MAX_DESCRIPTION_LENGTH = 2000;
    private static final long MAX_IMAGE_SIZE = 5L * 1024 * 1024;
    private static final Set<String> CATEGORIES = Set.of(
            "APPOINTMENT", "PAYMENT", "ACCOUNT", "SYSTEM", "OTHER");
    private static final Set<String> IMAGE_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp");

    private IssueReportDAO issueReportDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() {
        issueReportDAO = new IssueReportDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireReporter(request, response);
        if (user == null) return;

        String category = request.getParameter("category");
        if (category != null && CATEGORIES.contains(category)) {
            request.setAttribute("formCategory", category);
        }
        request.getRequestDispatcher("/WEB-INF/views/patient/issue-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireReporter(request, response);
        if (user == null) return;

        String title = trim(request.getParameter("title"));
        String category = trim(request.getParameter("category"));
        String description = trim(request.getParameter("description"));
        request.setAttribute("formTitle", title);
        request.setAttribute("formCategory", category);
        request.setAttribute("formDescription", description);

        if (title.isEmpty() || title.length() > MAX_TITLE_LENGTH
                || description.isEmpty() || description.length() > MAX_DESCRIPTION_LENGTH
                || !CATEGORIES.contains(category)) {
            showError(request, response,
                    "Vui lòng nhập tiêu đề, loại sự cố và mô tả hợp lệ (mô tả tối đa 2.000 ký tự).");
            return;
        }

        try {
            String imageUrl = saveImage(request);
            if (imageUrl == null && request.getAttribute("uploadError") != null) {
                showError(request, response, (String) request.getAttribute("uploadError"));
                return;
            }

            IssueReport report = new IssueReport();
            report.setReportCode("ISS-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(Locale.ROOT));
            report.setReporterUserId(user.getId());
            report.setTitle(title);
            report.setCategory(category);
            report.setDescription(description);
            report.setImageUrl(imageUrl);
            report.setStatus(IssueReport.STATUS_PENDING);

            String reportId = issueReportDAO.create(report);
            if (reportId == null) {
                showError(request, response, "Không thể gửi báo lỗi lúc này. Vui lòng thử lại sau.");
                return;
            }

            auditLogDAO.createLog(user.getId(), "ISSUE_REPORT_CREATE", "issue_reports", reportId,
                    "Mã báo lỗi: " + report.getReportCode(), null, null, RequestUtil.getClientIp(request), request.getHeader("User-Agent"));
            request.getSession().setAttribute("successMessage",
                    "Đã gửi báo lỗi " + report.getReportCode() + ". Chúng tôi sẽ phản hồi qua email sau khi kiểm tra.");
            response.sendRedirect(request.getContextPath() + issueReportPath(user));
        } catch (IllegalStateException exception) {
            showError(request, response, "Tệp đính kèm vượt quá giới hạn 5 MB.");
        }
    }

    private String saveImage(HttpServletRequest request) throws IOException, ServletException {
        Part imagePart = request.getPart("issueImage");
        if (imagePart == null || imagePart.getSize() == 0) return null;
        if (imagePart.getSize() > MAX_IMAGE_SIZE || !isAcceptedImage(imagePart)) {
            request.setAttribute("uploadError", "Ảnh phải là JPG, PNG hoặc WEBP và không vượt quá 5 MB.");
            return null;
        }

        try {
            byte[] bytes = imagePart.getInputStream().readAllBytes();
            String folder = AppConfig.get("media.issue.prefix", "dermai/issue-reports");
            return CloudinaryUpload.uploadPublicImage(bytes, folder, UUID.randomUUID().toString());
        } catch (IOException e) {
            request.setAttribute("uploadError", "Không thể tải ảnh lên Cloudinary. Vui lòng thử lại.");
            return null;
        }
    }

    private User requireReporter(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }
        if (!user.isPatient() && !"DOCTOR".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private static String issueReportPath(User user) {
        return "DOCTOR".equals(user.getRole()) ? "/doctor/issue-report" : "/patient/issue-report";
    }

    private static boolean isAcceptedImage(Part part) {
        String contentType = part.getContentType();
        if (contentType == null) return false;
        return IMAGE_TYPES.contains(contentType.toLowerCase(Locale.ROOT).split(";", 2)[0].trim());
    }

    private void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/patient/issue-report.jsp").forward(request, response);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
