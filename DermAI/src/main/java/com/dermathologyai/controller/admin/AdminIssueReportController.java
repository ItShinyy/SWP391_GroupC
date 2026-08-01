package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.IssueReportDAO;
import com.dermathologyai.model.IssueReport;
import com.dermathologyai.model.User;
import com.dermathologyai.notification.MailService;
import com.dermathologyai.util.PageUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Set;

public class AdminIssueReportController extends HttpServlet {
    private static final Set<String> STATUSES = Set.of(
            "PENDING", "IN_PROGRESS", "RESOLVED", "REJECTED");

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
        String status = normalize(request.getParameter("status"));
        if (status == null || (!"ALL".equals(status) && !STATUSES.contains(status))) status = "ALL";
        String search = normalize(request.getParameter("search"));

        List<IssueReport> allReports = issueReportDAO.findAll(status, search);
        int page = PageUtil.parsePage(request.getParameter("page"));
        int total = allReports.size();
        int totalPages = PageUtil.getTotalPages(total, PageUtil.ADMIN_PAGE_SIZE);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));
        int from = PageUtil.getOffset(page, PageUtil.ADMIN_PAGE_SIZE);
        int to = Math.min(from + PageUtil.ADMIN_PAGE_SIZE, total);
        List<IssueReport> reports = from >= total ? List.of() : allReports.subList(from, to);

        request.setAttribute("reports", reports);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("search", search == null ? "" : search);
        PageUtil.setPagingAttributes(request, page, total);
        request.getRequestDispatcher("/WEB-INF/views/admin/issue-reports/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");

        String reportId = normalize(request.getParameter("id"));
        String action = normalize(request.getParameter("action"));
        IssueReport report = reportId == null ? null : issueReportDAO.findById(reportId);
        if (report == null) {
            session.setAttribute("errorMessage", "Không tìm thấy báo cáo sự cố.");
            redirect(request, response);
            return;
        }

        StatusUpdate update = statusFor(action, report.getStatus());
        if (update == null) {
            session.setAttribute("errorMessage", "Thao tác không phù hợp với trạng thái hiện tại.");
            redirect(request, response);
            return;
        }

        if (!issueReportDAO.updateStatus(reportId, update.status(), update.message(), admin.getId())) {
            session.setAttribute("errorMessage", "Không thể cập nhật báo cáo sự cố.");
            redirect(request, response);
            return;
        }

        boolean emailSent = report.getReporterEmail() != null && !report.getReporterEmail().isBlank()
                && MailService.sendMail(
                        report.getReporterEmail(),
                        "DermAI - Cập nhật báo cáo sự cố " + report.getReportCode(),
                        buildEmail(report, update));

        auditLogDAO.createLog(admin.getId(), "ISSUE_REPORT_" + update.status(), "issue_reports", reportId,
                "Trạng thái cũ: " + report.getStatus(), "Trạng thái mới: " + update.status(), null, RequestUtil.getClientIp(request), request.getHeader("User-Agent"));

        if (emailSent) {
            session.setAttribute("successMessage",
                    "Đã cập nhật " + report.getReportCode() + " và gửi email cho " + report.getReporterEmail() + ".");
        } else {
            session.setAttribute("warningMessage",
                    "Đã cập nhật " + report.getReportCode() + " nhưng email chưa gửi được. Hãy kiểm tra cấu hình SMTP/email người dùng.");
        }
        redirect(request, response);
    }

    private static StatusUpdate statusFor(String action, String currentStatus) {
        if ("acknowledge".equals(action) && "PENDING".equals(currentStatus)) {
            return new StatusUpdate("IN_PROGRESS", "Đã xác nhận sự cố và đang trong quá trình xử lý.",
                    "Báo cáo của bạn đã được xác nhận");
        }
        if ("resolve".equals(action) && "IN_PROGRESS".equals(currentStatus)) {
            return new StatusUpdate("RESOLVED", "Sự cố đã được xử lý hoàn tất.",
                    "Sự cố đã được xử lý");
        }
        if ("reject".equals(action) && ("PENDING".equals(currentStatus) || "IN_PROGRESS".equals(currentStatus))) {
            return new StatusUpdate("REJECTED",
                    "Sau quá trình kiểm tra, chúng tôi chưa thể xác nhận sự cố theo thông tin được cung cấp. " +
                            "Nếu vấn đề vẫn tiếp diễn, vui lòng gửi thêm thông tin hoặc hình ảnh để chúng tôi tiếp tục hỗ trợ.",
                    "Kết quả kiểm tra báo cáo sự cố");
        }
        return null;
    }

    private static String buildEmail(IssueReport report, StatusUpdate update) {
        return "<div style=\"font-family:Arial,sans-serif;max-width:680px;margin:auto;color:#1f2937\">" +
                "<h2 style=\"color:#198754\">" + escapeHtml(update.heading()) + "</h2>" +
                "<p>Xin chào " + escapeHtml(report.getReporterName()) + ",</p>" +
                "<p>" + escapeHtml(update.message()) + "</p>" +
                "<div style=\"background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;padding:16px\">" +
                "<p><strong>Mã báo cáo:</strong> " + escapeHtml(report.getReportCode()) + "</p>" +
                "<p><strong>Tiêu đề:</strong> " + escapeHtml(report.getTitle()) + "</p>" +
                "<p><strong>Trạng thái:</strong> " + statusLabel(update.status()) + "</p>" +
                "</div><p style=\"margin-top:20px\">Trân trọng,<br>Đội ngũ DermAI</p></div>";
    }

    private static String statusLabel(String status) {
        return switch (status) {
            case "IN_PROGRESS" -> "Đã xác nhận - Đang xử lý";
            case "RESOLVED" -> "Đã xử lý xong";
            case "REJECTED" -> "Chưa thể xác nhận sự cố";
            default -> status;
        };
    }

    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private static String normalize(String value) {
        if (value == null) return null;
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private static void redirect(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/issue-reports");
    }

    private record StatusUpdate(String status, String message, String heading) {}
}
