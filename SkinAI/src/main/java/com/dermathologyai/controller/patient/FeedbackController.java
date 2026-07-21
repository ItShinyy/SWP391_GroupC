package com.dermathologyai.controller.patient;

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

public class FeedbackController extends HttpServlet {
    private FeedbackDAO feedbackDAO;
    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        appointmentDAO = new AppointmentDAO();
        patientDAO = new PatientDAO();
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
        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                handleShowCreateFeedback(req, resp, user);
            } else if ("edit".equals(action)) {
                handleShowEditFeedback(req, resp, user);
            } else {
                // Default: show feedback list
                handleShowFeedbackList(req, resp, user);
            }
        } catch (Exception e) {
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải chức năng đánh giá");
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
        String action = req.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "create":
                    handleCreateFeedback(req, resp, user);
                    break;
                case "update":
                    handleUpdateFeedback(req, resp, user);
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

    private void handleShowCreateFeedback(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String appointmentId = req.getParameter("appointmentId");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Get patient info
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
            resp.sendRedirect(req.getContextPath() + "/patient/profile");
            return;
        }

        // Get appointment details
        Appointment appointment = appointmentDAO.findById(appointmentId);
        if (appointment == null) {
            req.getSession().setAttribute("errorMessage", "Lịch hẹn không tồn tại");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Check if appointment belongs to this patient
        if (!appointment.getPatientId().equals(patient.getId())) {
            req.getSession().setAttribute("errorMessage", "Bạn không có quyền đánh giá lịch hẹn này");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Check if appointment is completed
        if (!"COMPLETED".equals(appointment.getStatus())
                || !"VISITED".equals(appointment.getAttendanceStatus())) {
            req.getSession().setAttribute("errorMessage", "Chỉ có thể đánh giá sau khi hoàn thành lịch hẹn");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Check if feedback already exists
        Feedback existingFeedback = feedbackDAO.findByAppointmentId(appointmentId);
        if (existingFeedback != null) {
            req.getSession().setAttribute("errorMessage", "Bạn đã đánh giá lịch hẹn này rồi");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Get doctor info from appointment
        Doctor doctor = null;
        if (appointment.getDoctorId() != null) {
            DoctorDAO doctorDAO = new DoctorDAO();
            doctor = doctorDAO.findById(appointment.getDoctorId());
        }

        req.setAttribute("appointment", appointment);
        req.setAttribute("doctor", doctor);
        req.getRequestDispatcher("/WEB-INF/views/patient/feedback-create.jsp").forward(req, resp);
    }

    private void handleShowEditFeedback(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String feedbackId = req.getParameter("id");
        if (feedbackId == null || feedbackId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã đánh giá không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Get patient info
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
            resp.sendRedirect(req.getContextPath() + "/patient/profile");
            return;
        }

        // Get feedback
        Feedback feedback = feedbackDAO.findById(feedbackId);
        if (feedback == null) {
            req.getSession().setAttribute("errorMessage", "Đánh giá không tồn tại");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Check ownership
        if (!feedback.getPatientId().equals(patient.getId())) {
            req.getSession().setAttribute("errorMessage", "Bạn không có quyền sửa đánh giá này");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Get related info
        Appointment appointment = appointmentDAO.findById(feedback.getAppointmentId());
        Doctor doctor = null;
        if (appointment != null && appointment.getDoctorId() != null) {
            DoctorDAO doctorDAO = new DoctorDAO();
            doctor = doctorDAO.findById(appointment.getDoctorId());
        }

        req.setAttribute("feedback", feedback);
        req.setAttribute("appointment", appointment);
        req.setAttribute("doctor", doctor);
        req.getRequestDispatcher("/WEB-INF/views/patient/feedback-edit.jsp").forward(req, resp);
    }

    private void handleShowFeedbackList(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        // Get patient info
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
            resp.sendRedirect(req.getContextPath() + "/patient/profile");
            return;
        }

        System.out.println("DEBUG Patient Info:");
        System.out.println("  User ID: " + user.getId());
        System.out.println("  Patient ID: " + patient.getId());

        // Pagination
        int page = 1;
        int pageSize = 10;
        
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        // Get feedbacks
        List<Feedback> feedbacks = feedbackDAO.findByPatientId(patient.getId(), page, pageSize);
        int totalFeedbacks = feedbackDAO.countByPatientId(patient.getId());
        int totalPages = (int) Math.ceil((double) totalFeedbacks / pageSize);

        // DEBUG: Check if feedbacks have admin replies
        System.out.println("DEBUG Patient Feedbacks:");
        for (Feedback feedback : feedbacks) {
            System.out.println("  ID: " + feedback.getId());
            System.out.println("  AdminReply: " + feedback.getAdminReply());
            System.out.println("  HasAdminReply: " + feedback.hasAdminReply());
            System.out.println("  Status: " + feedback.getStatus());
        }

        req.setAttribute("feedbacks", feedbacks);
        req.setAttribute("totalFeedbacks", totalFeedbacks);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);

        req.getRequestDispatcher("/WEB-INF/views/patient/feedback-list.jsp").forward(req, resp);
    }

    private void handleCreateFeedback(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String appointmentId = req.getParameter("appointmentId");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Get patient info
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
            resp.sendRedirect(req.getContextPath() + "/patient/profile");
            return;
        }

        // Get appointment and validate
        Appointment appointment = appointmentDAO.findById(appointmentId);
        if (appointment == null || !appointment.getPatientId().equals(patient.getId())) {
            req.getSession().setAttribute("errorMessage", "Lịch hẹn không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        if (!"COMPLETED".equals(appointment.getStatus())
                || !"VISITED".equals(appointment.getAttendanceStatus())) {
            req.getSession().setAttribute("errorMessage", "Chỉ có thể đánh giá sau khi đã hoàn thành buổi khám");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        // Check if feedback already exists
        if (feedbackDAO.findByAppointmentId(appointmentId) != null) {
            req.getSession().setAttribute("errorMessage", "Bạn đã đánh giá lịch hẹn này rồi");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Get form data
        try {
            int rating = Integer.parseInt(req.getParameter("rating"));
            String category = normalizeCategory(req.getParameter("category"));
            String content = req.getParameter("content");
            content = content == null ? "" : content.trim();

            // Validate rating
            if (rating < 1 || rating > 5) {
                req.getSession().setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                resp.sendRedirect(req.getContextPath() + "/patient/feedback?action=create&appointmentId=" + appointmentId);
                return;
            }

            if (category == null || content.isEmpty() || content.length() > 1000) {
                req.getSession().setAttribute("errorMessage", "Loại hoặc nội dung đánh giá không hợp lệ");
                resp.sendRedirect(req.getContextPath() + "/patient/feedback?action=create&appointmentId=" + appointmentId);
                return;
            }

            // Create feedback
            Feedback feedback = new Feedback();
            feedback.setPatientId(patient.getId());
            feedback.setAppointmentId(appointmentId);
            feedback.setRating(rating);
            feedback.setCategory(category);
            feedback.setContent(content);
            feedback.setStatus(Feedback.STATUS_PENDING);

            String feedbackId = feedbackDAO.create(feedback);
            if (feedbackId != null) {
                // Log audit
                String clientIp = RequestUtil.getClientIp(req);
                String userAgent = req.getHeader("User-Agent");
                auditLogDAO.createLog(user.getId(), "FEEDBACK_CREATE", "feedbacks", feedbackId,
                                    null, "Tạo đánh giá cho lịch hẹn: " + appointmentId, clientIp, userAgent);

                req.getSession().setAttribute("successMessage", "Cảm ơn bạn đã đánh giá! Phản hồi của bạn rất có giá trị.");
            } else {
                req.getSession().setAttribute("errorMessage", "Không thể tạo đánh giá. Vui lòng thử lại.");
            }

        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "Dữ liệu đánh giá không hợp lệ");
        }

        resp.sendRedirect(req.getContextPath() + "/patient/feedback");
    }

    private void handleUpdateFeedback(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String feedbackId = req.getParameter("id");
        if (feedbackId == null || feedbackId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã đánh giá không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Get patient info and validate ownership
        Patient patient = patientDAO.findByUserId(user.getId());
        Feedback existingFeedback = feedbackDAO.findById(feedbackId);
        
        if (patient == null || existingFeedback == null || 
            !existingFeedback.getPatientId().equals(patient.getId())) {
            req.getSession().setAttribute("errorMessage", "Bạn không có quyền sửa đánh giá này");
            resp.sendRedirect(req.getContextPath() + "/patient/feedback");
            return;
        }

        // Update feedback data
        try {
            int rating = Integer.parseInt(req.getParameter("rating"));
            String category = normalizeCategory(req.getParameter("category"));
            String content = req.getParameter("content");
            content = content == null ? "" : content.trim();

            if (rating < 1 || rating > 5) {
                req.getSession().setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                resp.sendRedirect(req.getContextPath() + "/patient/feedback?action=edit&id=" + feedbackId);
                return;
            }


            if (category == null || content.isEmpty() || content.length() > 1000) {
                req.getSession().setAttribute("errorMessage", "Loại hoặc nội dung đánh giá không hợp lệ");
                resp.sendRedirect(req.getContextPath() + "/patient/feedback?action=edit&id=" + feedbackId);
                return;
            }

            existingFeedback.setRating(rating);
            existingFeedback.setCategory(category);
            existingFeedback.setContent(content);

            boolean updated = feedbackDAO.update(existingFeedback);
            if (updated) {
                // Log audit
                String clientIp = RequestUtil.getClientIp(req);
                String userAgent = req.getHeader("User-Agent");
                auditLogDAO.createLog(user.getId(), "FEEDBACK_UPDATE", "feedbacks", feedbackId,
                                    null, "Cập nhật đánh giá", clientIp, userAgent);

                req.getSession().setAttribute("successMessage", "Đánh giá đã được cập nhật thành công.");
            } else {
                req.getSession().setAttribute("errorMessage", "Không thể cập nhật đánh giá. Vui lòng thử lại.");
            }

        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "Dữ liệu đánh giá không hợp lệ");
        }

        resp.sendRedirect(req.getContextPath() + "/patient/feedback");
    }

    private static String normalizeCategory(String category) {
        if ("Khen".equals(category) || "Góp ý".equals(category) || "Khiếu nại".equals(category)) {
            return category;
        }
        return null;
    }
}
