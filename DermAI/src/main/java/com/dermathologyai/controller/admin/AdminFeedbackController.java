package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.*;
import com.dermathologyai.model.*;
import com.dermathologyai.service.NotificationService;
import com.dermathologyai.util.PageUtil;
import com.dermathologyai.util.RequestUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
    private NotificationService notificationService;

    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        appointmentDAO = new AppointmentDAO();
        patientDAO = new PatientDAO();
        userDAO = new UserDAO();
        auditLogDAO = new AuditLogDAO();
        notificationService = new NotificationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("detail".equals(action)) {
                handleShowFeedbackDetail(req, resp);
            } else {
                // Default: show feedback list
                handleShowFeedbackList(req, resp);
            }
        } catch (Exception e) {
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải danh sách đánh giá");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");

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
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể xử lý đánh giá");
            }
        }
    }

    private void handleShowFeedbackList(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        // Get filter parameters
        String statusFilter = req.getParameter("status");
        String categoryFilter = req.getParameter("category");
        String searchTerm = req.getParameter("search");
        
        // Pagination — 10 rows per page (all admin tables)
        int page = PageUtil.parsePage(req.getParameter("page"));
        int pageSize = PageUtil.ADMIN_PAGE_SIZE;

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
        PageUtil.setPagingAttributes(req, page, totalFeedbacks);

        // Get statistics
        int pendingCount = feedbackDAO.countByStatus(Feedback.STATUS_PENDING);
        int processingCount = feedbackDAO.countByStatus(Feedback.STATUS_PROCESSING);
        int completedCount = feedbackDAO.countByStatus(Feedback.STATUS_COMPLETED);

        req.setAttribute("feedbacks", feedbacks);
        req.setAttribute("patientNames", patientNames);
        req.setAttribute("totalFeedbacks", totalFeedbacks);
        
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("processingCount", processingCount);
        req.setAttribute("completedCount", completedCount);
        
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("categoryFilter", categoryFilter);
        req.setAttribute("searchTerm", searchTerm);

        req.getRequestDispatcher("/WEB-INF/views/admin/feedback/list.jsp").forward(req, resp);
    }

    private void handleShowFeedbackDetail(HttpServletRequest req, HttpServletResponse resp) 
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

        req.getRequestDispatcher("/WEB-INF/views/admin/feedback/detail.jsp").forward(req, resp);
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

        if (adminReply == null || adminReply.trim().isEmpty() || adminReply.trim().length() > 1000) {
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
        feedback.setStatus(Feedback.STATUS_COMPLETED); // Auto set to completed when replied

        boolean updated = feedbackDAO.updateReply(feedback);
        if (updated) {
            // Log audit
            String clientIp = RequestUtil.getClientIp(req);
            String userAgent = req.getHeader("User-Agent");
            auditLogDAO.createLog(user.getId(), "FEEDBACK_REPLY", "feedbacks", feedbackId,
                                null, "Admin phản hồi feedback", null, clientIp, userAgent);
            // Notify the patient in-app
            Patient patient = patientDAO.findById(feedback.getPatientId());
            if (patient != null) {
                notificationService.enqueueFeedbackReplied(patient.getUserId(), feedbackId);
            }
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
                                null, "Cập nhật trạng thái: " + newStatus, null, clientIp, userAgent);

            req.getSession().setAttribute("successMessage", "Đã cập nhật trạng thái thành công");
        } else {
            req.getSession().setAttribute("errorMessage", "Không thể cập nhật trạng thái. Vui lòng thử lại");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=detail&id=" + feedbackId);
    }

    private boolean isValidStatus(String status) {
        return Feedback.STATUS_PENDING.equals(status)
                || Feedback.STATUS_PROCESSING.equals(status)
                || Feedback.STATUS_COMPLETED.equals(status);
    }
}
