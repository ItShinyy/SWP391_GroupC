package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.User;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.Patient;
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
import java.util.List;

public class BookingController extends HttpServlet {
    private ClinicDAO clinicDAO;
    private DoctorDAO doctorDAO;
    private PatientDAO patientDAO;
    private AppointmentDAO appointmentDAO;
    private BookingService bookingService;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
        doctorDAO = new DoctorDAO();
        patientDAO = new PatientDAO();
        appointmentDAO = new AppointmentDAO();
        bookingService = new BookingService();
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
        String clinicId = req.getParameter("clinicId");
        String reportId = req.getParameter("reportId");
        
        // Check if user has incomplete appointments before allowing booking
        try {
            Patient patient = patientDAO.findByUserId(user.getId());
            if (patient != null && appointmentDAO.hasIncompleteAppointment(patient.getId())) {
                Appointment incompleteAppointment = appointmentDAO.findIncompleteAppointmentByPatientId(patient.getId());
                req.setAttribute("hasIncompleteAppointment", true);
                req.setAttribute("incompleteAppointment", incompleteAppointment);
                req.setAttribute("blockBooking", true);
            }
        } catch (Exception e) {
            // Log error but don't block the page
            System.err.println("Error checking incomplete appointments: " + e.getMessage());
        }
        
        // Handle search parameters
        String doctorName = req.getParameter("doctorName");
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");
        String specialization = req.getParameter("specialization");
        String timeSlot = req.getParameter("timeSlot");
        
        if (clinicId != null && !clinicId.trim().isEmpty()) {
            req.setAttribute("selectedClinic", clinicDAO.findById(clinicId));
        }
        
        // If reportId is provided, get the report details for context
        if (reportId != null && !reportId.trim().isEmpty()) {
            req.setAttribute("reportId", reportId);
            // TODO: Load report details if needed for better display
        }
        
        req.setAttribute("clinics", clinicDAO.findActive());
        
        // Load specializations from database
        try {
            List<String> specializations = doctorDAO.findAllSpecializations();
            req.setAttribute("specializations", specializations);
        } catch (Exception e) {
            System.err.println("Error loading specializations: " + e.getMessage());
        }
        
        // Handle search functionality
        if (hasSearchParams(doctorName, fromDate, toDate, specialization, timeSlot)) {
            try {
                List<Doctor> searchResults = doctorDAO.searchDoctors(doctorName, fromDate, toDate, specialization, timeSlot);
                req.setAttribute("searchResults", searchResults);
            } catch (Exception e) {
                req.setAttribute("errorMessage", "Lỗi khi tìm kiếm: " + e.getMessage());
            }
        }
        
        // Generate a request ID for idempotency token
        String requestId = UUID.randomUUID().toString();
        req.setAttribute("requestId", requestId);
        
        req.getRequestDispatcher("/WEB-INF/views/patient/booking.jsp").forward(req, resp);
    }
    
    private boolean hasSearchParams(String doctorName, String fromDate, String toDate, String specialization, String timeSlot) {
        return (doctorName != null && !doctorName.trim().isEmpty()) ||
               (fromDate != null && !fromDate.trim().isEmpty()) ||
               (toDate != null && !toDate.trim().isEmpty()) ||
               (specialization != null && !specialization.trim().isEmpty()) ||
               (timeSlot != null && !timeSlot.trim().isEmpty());
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
        String doctorId = req.getParameter("doctorId");
        String slotId = req.getParameter("slotId");
        String appointmentTimeStr = req.getParameter("appointmentTime");
        String notes = req.getParameter("notes");
        String requestId = req.getParameter("requestId");
        String reportId = req.getParameter("reportId");
        
        if (clinicId == null || doctorId == null || slotId == null || appointmentTimeStr == null || requestId == null) {
            req.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin bắt buộc.");
            doGet(req, resp);
            return;
        }

        try {
            LocalDateTime appointmentTime = LocalDateTime.parse(appointmentTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            
            Appointment appointment = new Appointment();
            appointment.setClinicId(clinicId);
            appointment.setDoctorId(doctorId);
            appointment.setSlotId(slotId);
            appointment.setAppointmentTime(appointmentTime);
            appointment.setNotes(notes);
            appointment.setRequestId(requestId);
            appointment.setStatus("CONFIRMED");
            appointment.setDoctorStatus("APPROVED");
            
            // Set diagnosis report ID if booking from a report
            if (reportId != null && !reportId.trim().isEmpty()) {
                appointment.setDiagnosisReportId(reportId);
            }
            
            String appointmentId = bookingService.bookAppointment(user.getId(), appointment);
            
            if (appointmentId != null) {
                String auditDetails = "Clinic ID: " + clinicId + ", Doctor ID: " + doctorId + " (Auto-approved)";
                if (reportId != null && !reportId.trim().isEmpty()) {
                    auditDetails += ", Report ID: " + reportId;
                }
                auditLogDAO.createLog(user.getId(), "APPOINTMENT_CREATE_APPROVED", "appointments", appointmentId, null, auditDetails, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                req.getSession().setAttribute("successMessage", "Đặt lịch hẹn thành công! Lịch hẹn đã được xác nhận và bạn có thể đến khám theo lịch đã đặt.");
                resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            } else {
                req.setAttribute("errorMessage", "Không thể đặt lịch hẹn. Vui lòng thử lại.");
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
