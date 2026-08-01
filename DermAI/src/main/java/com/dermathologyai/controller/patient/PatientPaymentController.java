package com.dermathologyai.controller.patient;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.Payment;
import com.dermathologyai.model.User;
import com.dermathologyai.service.BillingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

/**
 * Patient invoice page. VNPay transaction creation and callbacks are owned by
 * the private Node payment service; this controller performs authorization and
 * renders persisted invoice/payment state only.
 */
public class PatientPaymentController extends HttpServlet {
    private static final Set<String> BLOCKED_APPT_STATUS = Set.of("CANCELLED", "NO_SHOW");

    private PatientDAO patientDAO;
    private AppointmentDAO appointmentDAO;
    private BillingService billingService;

    @Override
    public void init() throws ServletException {
        patientDAO = new PatientDAO();
        appointmentDAO = new AppointmentDAO();
        billingService = new BillingService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Patient patient = requirePatient(req, resp);
        if (patient == null) return;

        String action = req.getParameter("action");
        if ("create".equals(action) || req.getParameter("appointmentId") != null) {
            showPaymentForAppointment(req, resp, patient, req.getParameter("appointmentId"), true);
            return;
        }
        if ("view".equals(action)) {
            showPaymentByInvoiceId(req, resp, patient, req.getParameter("invoiceId"), true);
            return;
        }
        showPaymentFromSession(req, resp, patient);
    }

    private void showPaymentForAppointment(HttpServletRequest req, HttpServletResponse resp,
                                           Patient patient, String appointmentId,
                                           boolean paymentRequired) throws ServletException, IOException {
        if (appointmentId == null || appointmentId.isBlank()) {
            req.setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ.");
            forwardPaymentPage(req, resp, null, null, null, paymentRequired, false);
            return;
        }

        Appointment appointment = appointmentDAO.findByIdFull(appointmentId.trim());
        if (appointment == null || !patient.getId().equals(appointment.getPatientId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không tìm thấy lịch hẹn.");
            return;
        }
        if (BLOCKED_APPT_STATUS.contains(appointment.getStatus())) {
            req.setAttribute("errorMessage", "Lịch hẹn đã hủy hoặc không thể thanh toán.");
            forwardPaymentPage(req, resp, appointment, null, null, paymentRequired, false);
            return;
        }

        Invoice invoice = billingService.ensureUnpaidInvoiceForAppointment(appointment.getId());
        Payment payment = invoice == null ? null : billingService.findLatestPayment(invoice.getId());
        stashSession(req, appointment.getId(), invoice == null ? null : invoice.getId());
        forwardPaymentPage(req, resp, appointment, invoice, payment, paymentRequired, false);
    }

    private void showPaymentByInvoiceId(HttpServletRequest req, HttpServletResponse resp,
                                        Patient patient, String invoiceId, boolean viewOnly)
        throws ServletException, IOException {
        if (invoiceId == null || invoiceId.isBlank()) {
            req.setAttribute("errorMessage", "Mã hóa đơn không hợp lệ.");
            forwardPaymentPage(req, resp, null, null, null, false, viewOnly);
            return;
        }

        Invoice invoice = billingService.findById(invoiceId.trim());
        if (invoice == null) {
            req.setAttribute("errorMessage", "Hóa đơn không tồn tại.");
            forwardPaymentPage(req, resp, null, null, null, false, viewOnly);
            return;
        }

        Appointment appointment = appointmentDAO.findByIdFull(invoice.getAppointmentId());
        if (appointment == null || !patient.getId().equals(appointment.getPatientId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Không có quyền xem hóa đơn này.");
            return;
        }

        Payment payment = billingService.findLatestPayment(invoice.getId());
        stashSession(req, appointment.getId(), invoice.getId());
        forwardPaymentPage(req, resp, appointment, invoice, payment, false, viewOnly);
    }

    private void showPaymentFromSession(HttpServletRequest req, HttpServletResponse resp, Patient patient)
        throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String invoiceId = session == null ? null : (String) session.getAttribute("paymentInvoiceId");
        if (invoiceId != null && !invoiceId.isBlank()) {
            showPaymentByInvoiceId(req, resp, patient, invoiceId, false);
            return;
        }

        String appointmentId = session == null ? null : (String) session.getAttribute("paymentAppointmentId");
        if (appointmentId != null && !appointmentId.isBlank()) {
            showPaymentForAppointment(req, resp, patient, appointmentId, true);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/patient/appointments");
    }

    private void forwardPaymentPage(HttpServletRequest req, HttpServletResponse resp,
                                    Appointment appointment, Invoice invoice, Payment payment,
                                    boolean paymentRequired, boolean viewOnly)
        throws ServletException, IOException {
        String apiBaseUrl = AppConfig.get("payment.api.base.url", "http://localhost:3000").trim();
        apiBaseUrl = apiBaseUrl.replaceAll("/+$", "");

        req.setAttribute("appointment", appointment);
        req.setAttribute("invoice", invoice);
        req.setAttribute("payment", payment);
        req.setAttribute("paymentRequired", paymentRequired);
        req.setAttribute("paymentViewOnly", viewOnly);
        req.setAttribute("paymentApiBaseUrl", apiBaseUrl);
        req.setAttribute("paymentApiAvailable", !apiBaseUrl.isBlank());
        req.setAttribute("paymentExpireMinutes", AppConfig.getInt("payment.expire.minutes", 4));
        req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
    }

    private static void stashSession(HttpServletRequest req, String appointmentId, String invoiceId) {
        HttpSession session = req.getSession(true);
        if (appointmentId != null) session.setAttribute("paymentAppointmentId", appointmentId);
        if (invoiceId != null) session.setAttribute("paymentInvoiceId", invoiceId);
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
