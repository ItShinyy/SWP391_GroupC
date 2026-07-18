package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.*;
import com.dermathologyai.model.*;
import com.dermathologyai.util.RequestUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class AdminFeedbackController extends HttpServlet {
    private FeedbackDAO feedbackDAO;
    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private UserDAO userDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        appointmentDAO = new AppointmentDAO();
        patientDAO = new PatientDAO();
        userDAO = new UserDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ admin mới có quyền truy cập");
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("detail".equals(action)) {
                handleShowFeedbackDetail(req, resp, user);
            } else {
                // Default: show feedback list
                handleShowFeedbackList(req, resp, user);
            }
        } catch (Exception e) {
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ admin mới có quyền truy cập");
            return;
        }

        String action = req.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "reply":
                    handleReplyFeedback(req, resp, user);
                    break;
                case "updateStatus":
                    handleUpdateStatus(req, resp, user);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }

    private void handleShowFeedbackList(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        // Debug database first
        feedbackDAO.debugDatabase();
        
        // Get filter parameters
        String statusFilter = req.getParameter("status");
        String categoryFilter = req.getParameter("category");
        String searchTerm = req.getParameter("search");
        
        System.out.println("DEBUG Filters - Status: " + statusFilter + ", Category: " + categoryFilter + ", Search: " + searchTerm);
        
        // Pagination
        int page = 1;
        int pageSize = 15;
        
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        // Get feedbacks with filters
        List<Feedback> feedbacks = feedbackDAO.findAllWithFilters(
            statusFilter, categoryFilter, searchTerm, page, pageSize
        );
        
        // Get patient names for each feedback
        Map<String, String> patientNames = new HashMap<>();
        for (Feedback feedback : feedbacks) {
            Patient patient = patientDAO.findById(feedback.getPatientId());
            if (patient != null) {
                User patientUser = userDAO.findById(patient.getUserId());
                if (patientUser != null) {
                    patientNames.put(feedback.getId(), patientUser.getFullName());
                }
            }
        }
        
        int totalFeedbacks = feedbackDAO.countAllWithFilters(statusFilter, categoryFilter, searchTerm);
        int totalPages = (int) Math.ceil((double) totalFeedbacks / pageSize);

        // Get statistics
        int pendingCount = feedbackDAO.countByStatus("Chưa xử lý");
        int processingCount = feedbackDAO.countByStatus("Đang xử lý");
        int completedCount = feedbackDAO.countByStatus("Đã xử lý");

        req.setAttribute("feedbacks", feedbacks);
        req.setAttribute("patientNames", patientNames);
        req.setAttribute("totalFeedbacks", totalFeedbacks);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("processingCount", processingCount);
        req.setAttribute("completedCount", completedCount);
        
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("categoryFilter", categoryFilter);
        req.setAttribute("searchTerm", searchTerm);

        req.getRequestDispatcher("/WEB-INF/views/admin/feedback-management.jsp").forward(req, resp);
    }

    private void handleShowFeedbackDetail(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String feedbackId = req.getParameter("id");
        if (feedbackId == null || feedbackId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã đánh giá không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback");
            return;
        }

        // Get feedback details
        Feedback feedback = feedbackDAO.findById(feedbackId);
        if (feedback == null) {
            req.getSession().setAttribute("errorMessage", "Đánh giá không tồn tại");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback");
            return;
        }

        // Get related info
        Appointment appointment = appointmentDAO.findById(feedback.getAppointmentId());
        Patient patient = patientDAO.findById(feedback.getPatientId());
        User patientUser = null;
        if (patient != null && patient.getUserId() != null) {
            patientUser = userDAO.findById(patient.getUserId());
        }

        req.setAttribute("feedback", feedback);
        req.setAttribute("appointment", appointment);
        req.setAttribute("patient", patient);
        req.setAttribute("patientUser", patientUser);

        req.getRequestDispatcher("/WEB-INF/views/admin/feedback-detail.jsp").forward(req, resp);
    }

    private void handleReplyFeedback(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String feedbackId = req.getParameter("feedbackId");
        String adminReply = req.getParameter("adminReply");
        
        if (feedbackId == null || feedbackId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã đánh giá không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback");
            return;
        }

        if (adminReply == null || adminReply.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Vui lòng nhập nội dung phản hồi");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=detail&id=" + feedbackId);
            return;
        }

        // Get feedback and update
        Feedback feedback = feedbackDAO.findById(feedbackId);
        if (feedback == null) {
            req.getSession().setAttribute("errorMessage", "Đánh giá không tồn tại");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback");
            return;
        }

        // Update feedback with admin reply
        feedback.setAdminReply(adminReply.trim());
        feedback.setStatus("Đã xử lý"); // Auto set to completed when replied

        boolean updated = feedbackDAO.updateReply(feedback);
        if (updated) {
            // Log audit
            String clientIp = RequestUtil.getClientIp(req);
            String userAgent = req.getHeader("User-Agent");
            auditLogDAO.createLog(user.getId(), "FEEDBACK_REPLY", "feedbacks", feedbackId,
                                null, "Admin phản hồi feedback", clientIp, userAgent);

            req.getSession().setAttribute("successMessage", "Đã gửi phản hồi thành công");
        } else {
            req.getSession().setAttribute("errorMessage", "Không thể gửi phản hồi. Vui lòng thử lại");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=detail&id=" + feedbackId);
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String feedbackId = req.getParameter("feedbackId");
        String newStatus = req.getParameter("status");
        
        if (feedbackId == null || feedbackId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã đánh giá không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback");
            return;
        }

        // Validate status
        if (!isValidStatus(newStatus)) {
            req.getSession().setAttribute("errorMessage", "Trạng thái không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=detail&id=" + feedbackId);
            return;
        }

        // Update status
        boolean updated = feedbackDAO.updateStatus(feedbackId, newStatus);
        if (updated) {
            // Log audit
            String clientIp = RequestUtil.getClientIp(req);
            String userAgent = req.getHeader("User-Agent");
            auditLogDAO.createLog(user.getId(), "FEEDBACK_STATUS_UPDATE", "feedbacks", feedbackId,
                                null, "Cập nhật trạng thái: " + newStatus, clientIp, userAgent);

            req.getSession().setAttribute("successMessage", "Đã cập nhật trạng thái thành công");
        } else {
            req.getSession().setAttribute("errorMessage", "Không thể cập nhật trạng thái. Vui lòng thử lại");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=detail&id=" + feedbackId);
    }

    private boolean isValidStatus(String status) {
        return "Chưa xử lý".equals(status) || 
               "Đang xử lý".equals(status) || 
               "Đã xử lý".equals(status);
    }
}