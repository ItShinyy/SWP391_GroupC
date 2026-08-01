package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.MedicalReport;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.Payment;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.BillingService;
import com.dermathologyai.service.MedicalRecordService;
import com.dermathologyai.service.NotificationService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Patient appointment list and cancel — same fat-controller + DAO style as reports. */
public class PatientAppointmentsController extends HttpServlet {
    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private AuditService auditService;
    private BillingService billingService;
    private MedicalRecordService medicalRecordService;
    private NotificationService notificationService;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
        patientDAO = new PatientDAO();
        auditService = new AuditService();
        billingService = new BillingService();
        medicalRecordService = new MedicalRecordService();
        notificationService = new NotificationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Patient patient = requirePatient(req, resp);
        if (patient == null) return;

        List<Appointment> appointments = appointmentDAO.findByPatientId(patient.getId());
        Map<String, Invoice> invoicesByAppointment = new HashMap<>();
        Map<String, Payment> paymentsByAppointment = new HashMap<>();
        Map<String, MedicalReport> medicalByAppointment = new HashMap<>();
        for (Appointment a : appointments) {
            Invoice invoice = billingService.findByAppointmentId(a.getId());
            if (invoice != null) {
                invoicesByAppointment.put(a.getId(), invoice);
                Payment payment = billingService.findLatestPayment(invoice.getId());
                if (payment != null) paymentsByAppointment.put(a.getId(), payment);
            }
            MedicalReport medical = medicalRecordService.findByAppointmentId(a.getId());
            if (medical != null && "COMPLETED".equals(medical.getStatus())) {
                medicalByAppointment.put(a.getId(), medical);
            }
        }
        req.setAttribute("appointments", appointments);
        req.setAttribute("invoicesByAppointment", invoicesByAppointment);
        req.setAttribute("paymentsByAppointment", paymentsByAppointment);
        req.setAttribute("medicalByAppointment", medicalByAppointment);
        req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Patient patient = requirePatient(req, resp);
        if (patient == null || user == null) return;

        String action = req.getParameter("action");
        String appointmentId = req.getParameter("appointmentId");
        boolean success = false;
        if ("cancel".equals(action) && appointmentId != null && !appointmentId.isBlank()) {
            success = appointmentDAO.cancelForPatient(appointmentId.trim(), patient.getId());
            if (success) {
                billingService.cancelBillingForAppointment(appointmentId.trim());
                notificationService.enqueueAppointmentCancelled(user.getId(), appointmentId.trim(),
                    "Lịch hẹn của bạn đã được hủy thành công.");
                auditService.log(user.getId(), "PATIENT_CANCEL_APPT", "appointments", appointmentId.trim(),
                    null, "{\"status\":\"CANCELLED\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            }
        }
        resp.sendRedirect(req.getContextPath() + "/patient/appointments?success=" + success);
    }

    private Patient requirePatient(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không tìm thấy hồ sơ bệnh nhân.");
            return null;
        }
        return patient;
    }
}
