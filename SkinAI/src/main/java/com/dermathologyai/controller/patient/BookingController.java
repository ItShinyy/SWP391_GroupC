package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.User;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.service.BookingService;
import com.dermathologyai.util.RequestUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class BookingController extends HttpServlet {
    private ClinicDAO clinicDAO;
    private BookingService bookingService;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
        bookingService = new BookingService();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clinicId = req.getParameter("clinicId");
        if (clinicId != null && !clinicId.trim().isEmpty()) {
            req.setAttribute("selectedClinic", clinicDAO.findById(clinicId));
        }
        
        req.setAttribute("clinics", clinicDAO.findActive());
        
        // Generate a request ID for idempotency token
        String requestId = UUID.randomUUID().toString();
        req.setAttribute("requestId", requestId);
        
        req.getRequestDispatcher("/WEB-INF/views/patient/booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        String clinicId = req.getParameter("clinicId");
        String appointmentTimeStr = req.getParameter("appointmentTime");
        String notes = req.getParameter("notes");
        String requestId = req.getParameter("requestId");
        
        if (clinicId == null || appointmentTimeStr == null || requestId == null) {
            req.setAttribute("errorMessage", "Missing required fields.");
            doGet(req, resp);
            return;
        }

        try {
            LocalDateTime appointmentTime = LocalDateTime.parse(appointmentTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            
            Appointment appointment = new Appointment();
            appointment.setClinicId(clinicId);
            appointment.setAppointmentTime(appointmentTime);
            appointment.setNotes(notes);
            appointment.setRequestId(requestId);
            appointment.setStatus("CREATED");
            
            String appointmentId = bookingService.bookAppointment(user.getId(), appointment);
            
            if (appointmentId != null) {
                auditLogDAO.createLog(user.getId(), "APPOINTMENT_CREATE", "appointments", appointmentId, null, "Clinic ID: " + clinicId, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                resp.sendRedirect(req.getContextPath() + "/patient/reports?success=booking_created");
            } else {
                req.setAttribute("errorMessage", "Could not book appointment.");
                doGet(req, resp);
            }
        } catch (IllegalStateException e) {
            // Probably no patient profile
            if (e.getMessage().contains("profile")) {
                req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ cá nhân trước khi đặt lịch.");
                resp.sendRedirect(req.getContextPath() + "/patient/profile");
            } else {
                req.setAttribute("errorMessage", e.getMessage());
                doGet(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
