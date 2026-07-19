package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.PrescriptionDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.Prescription;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Controller xử lý xem chi tiết hồ sơ bệnh nhân, ghi nhận xét, chuyển ca khám,
 * kê đơn thuốc và xuất báo cáo kết quả PDF dành cho Bác sĩ.
 */
public class DoctorAppointmentDetailController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;
    private PrescriptionDAO prescriptionDAO;
    private DoctorScheduleDAO scheduleDAO;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
        prescriptionDAO = new PrescriptionDAO();
        scheduleDAO = new DoctorScheduleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Doctor profile not found.");
            return;
        }
        
        String appointmentId = req.getParameter("id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        // Handle PDF Export
        String action = req.getParameter("action");
        if ("exportPdf".equalsIgnoreCase(action)) {
            Appointment appt = appointmentDAO.findByIdFull(appointmentId);
            if (appt != null && "COMPLETED".equals(appt.getStatus())) {
                List<Prescription> prescriptions = prescriptionDAO.findByAppointmentId(appointmentId);
                resp.setContentType("application/pdf");
                resp.setHeader("Content-Disposition", "inline; filename=\"phieu-kham-benh-" + appointmentId.substring(0, 8) + ".pdf\"");
                try {
                    com.dermathologyai.util.PdfReportGenerator.generateAppointmentReportPdf(resp.getOutputStream(), appt, prescriptions);
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error exporting PDF: " + e.getMessage());
                    return;
                }
            }
        }
        
        Appointment fullAppointment = appointmentDAO.findByIdFull(appointmentId);
        if (fullAppointment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found.");
            return;
        }
        
        List<Doctor> sameClinicDoctors = doctorDAO.findByClinicId(doctor.getClinicId());
        sameClinicDoctors.removeIf(d -> d.getId().equals(doctor.getId()));
        
        List<Prescription> prescriptions = prescriptionDAO.findByAppointmentId(appointmentId);
        
        req.setAttribute("doctor", doctor);
        req.setAttribute("appointment", fullAppointment);
        req.setAttribute("sameClinicDoctors", sameClinicDoctors);
        req.setAttribute("prescriptions", prescriptions);
        
        req.getRequestDispatcher("/WEB-INF/views/doctor/appointment-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String appointmentId = req.getParameter("appointmentId");
        String action = req.getParameter("action");
        
        if (appointmentId == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        boolean success = false;
        
        switch (action) {
            case "saveNotes":
                String doctorNotes = req.getParameter("doctorNotes");
                success = appointmentDAO.updateDoctorStatus(appointmentId, "ACCEPTED", doctorNotes);
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#notes-card");
                break;
                
            case "completeAppointment":
                success = appointmentDAO.updateStatus(appointmentId, "COMPLETED");
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#notes-card");
                break;
                
            case "transfer":
                String newDoctorId = req.getParameter("newDoctorId");
                String transferNotes = req.getParameter("transferNotes");
                if (newDoctorId != null && !newDoctorId.trim().isEmpty()) {
                    // Overload Check
                    Appointment appt = appointmentDAO.findByIdFull(appointmentId);
                    if (appt != null) {
                        LocalDateTime apptTime = appt.getAppointmentTime();
                        java.time.LocalDate date = apptTime.toLocalDate();
                        int hour = apptTime.getHour();
                        String slot = "MORNING";
                        if (hour >= 12 && hour < 17) {
                            slot = "AFTERNOON";
                        } else if (hour >= 17) {
                            slot = "EVENING";
                        }
                        
                        DoctorSchedule sched = scheduleDAO.findByDoctorDateAndSlot(newDoctorId, date, slot);
                        if (sched != null && sched.getBookedCount() >= sched.getMaxPatients()) {
                            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=overload");
                            return;
                        }
                    }
                    success = appointmentDAO.transferDoctor(appointmentId, newDoctorId, transferNotes);
                }
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/dashboard?transferSuccess=true");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=true");
                }
                break;
                
            case "addPrescription":
                String drugName = req.getParameter("drugName");
                if ("custom".equals(drugName)) {
                    drugName = req.getParameter("customDrugName");
                }
                String qtyStr = req.getParameter("quantity");
                String dosage = req.getParameter("dosage");
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(qtyStr);
                } catch (NumberFormatException ignored) {}
                
                if (drugName != null && !drugName.trim().isEmpty() && dosage != null && !dosage.trim().isEmpty()) {
                    Prescription p = new Prescription();
                    p.setAppointmentId(appointmentId);
                    p.setDrugName(drugName.trim());
                    p.setQuantity(quantity);
                    p.setDosage(dosage.trim());
                    success = prescriptionDAO.create(p);
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#prescription-card");
                break;
                
            case "deletePrescription":
                String prescriptionId = req.getParameter("prescriptionId");
                if (prescriptionId != null) {
                    success = prescriptionDAO.delete(prescriptionId);
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#prescription-card");
                break;
                
            default:
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                break;
        }
    }
}
