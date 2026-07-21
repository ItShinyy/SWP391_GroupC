package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.*;
import com.dermathologyai.service.PaymentService;
import com.dermathologyai.util.RequestUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class PaymentController extends HttpServlet {
    private PaymentService paymentService;
    private AppointmentDAO appointmentDAO;
    private InvoiceDAO invoiceDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        paymentService = new PaymentService();
        appointmentDAO = new AppointmentDAO();
        invoiceDAO = new InvoiceDAO();
        patientDAO = new PatientDAO();
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
            if ("vnpay-mock".equals(action)) {
                // Handle mock VNPay return
                handleVnpayMockReturn(req, resp, user);
            } else if (req.getRequestURI().contains("/vnpay/mock")) {
                // Show mock VNPay payment page
                handleVnpayMockPage(req, resp, user);
            } else if ("view".equals(action)) {
                // Allow GET request for viewing invoice (for page reload)
                handleViewInvoice(req, resp, user, req.getParameter("invoiceId"));
            } else {
                // Default: show payment page from session data (for clean URL reload)
                handleShowPaymentFromSession(req, resp, user);
            }
        } catch (Exception e) {
            // Only forward to error page if response hasn't been committed yet
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
        String action = req.getParameter("action");
        
        try {
            switch (action != null ? action : "") {
                case "create":
                    handleCreateInvoiceAndRedirect(req, resp, user, req.getParameter("appointmentId"));
                    break;
                case "view":
                    handleViewInvoice(req, resp, user, req.getParameter("invoiceId"));
                    break;
                case "pay-offline":
                    handleOfflinePayment(req, resp, user, req.getParameter("invoiceId"));
                    break;
                case "pay-online":
                    handleOnlinePayment(req, resp, user, req.getParameter("invoiceId"));
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

    private void handleCreateInvoice(HttpServletRequest req, HttpServletResponse resp, User user, String appointmentId) 
            throws ServletException, IOException {
        
        try {
            if (appointmentId == null || appointmentId.trim().isEmpty()) {
                req.setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ");
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                return;
            }

            // Quick validation: get patient first to reduce queries
            Patient patient = patientDAO.findByUserId(user.getId());
            if (patient == null) {
                req.setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                return;
            }

            // Check if invoice already exists to avoid duplicate work
            Invoice existingInvoice = invoiceDAO.findByAppointmentId(appointmentId);
            if (existingInvoice != null) {
                // Reuse existing invoice
                req.setAttribute("invoice", existingInvoice);
                req.setAttribute("appointment", appointmentDAO.findById(appointmentId));
                req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
                return;
            }

            // Create new invoice using service
            String clientIp = RequestUtil.getClientIp(req);
            String userAgent = req.getHeader("User-Agent");

            Invoice invoice = paymentService.createOrGetInvoice(appointmentId, user.getId(), clientIp, userAgent);
            
            // Forward directly to view
            req.setAttribute("invoice", invoice);
            req.setAttribute("appointment", appointmentDAO.findById(appointmentId));
            req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
        } catch (Exception e) {
            // Handle exception within this method to avoid response commitment issues
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi tạo hóa đơn: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }

    private void handleViewInvoice(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        try {
            if (invoiceId == null || invoiceId.trim().isEmpty()) {
                req.setAttribute("errorMessage", "Mã hóa đơn không hợp lệ");
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                return;
            }

            // Use direct DAO calls instead of service to reduce overhead
            Invoice invoice = invoiceDAO.findById(invoiceId);
            if (invoice == null) {
                req.setAttribute("errorMessage", "Hóa đơn không tồn tại");
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                return;
            }

            // Get appointment info
            Appointment appointment = null;
            if (invoice.getAppointmentId() != null) {
                appointment = appointmentDAO.findById(invoice.getAppointmentId());
            }

            req.setAttribute("invoice", invoice);
            req.setAttribute("appointment", appointment);
            req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
        } catch (Exception e) {
            // Handle exception within this method to avoid response commitment issues
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi xem hóa đơn: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }

    private void handleOfflinePayment(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        if (invoiceId == null || invoiceId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã hóa đơn không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        try {
            Payment payment = paymentService.processOfflinePayment(invoiceId, user.getId(), clientIp, userAgent);
            req.getSession().setAttribute("successMessage", 
                "Thanh toán tại quầy đã được ghi nhận! Vui lòng đến quầy lễ tân để hoàn tất thanh toán.");
            
            // Clear payment session data
            req.getSession().removeAttribute("currentInvoice");
            req.getSession().removeAttribute("currentAppointment");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Lỗi xử lý thanh toán: " + e.getMessage());
        }
        
        resp.sendRedirect(req.getContextPath() + "/patient/appointments");
    }

    private void handleOnlinePayment(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        if (invoiceId == null || invoiceId.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Mã hóa đơn không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
            return;
        }

        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        try {
            Payment payment = paymentService.prepareOnlinePayment(invoiceId, user.getId(), clientIp, userAgent);
            // Don't clear session here - will clear after successful payment
            // Redirect to mock VNPay payment page
            resp.sendRedirect(req.getContextPath() + payment.getPaymentUrl());
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Lỗi khởi tạo thanh toán: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
        }
    }

    private void handleVnpayMockReturn(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String txnRef = req.getParameter("txnRef");
        String resultCode = req.getParameter("result"); // "success" or "failed"
        
        if (txnRef == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing transaction reference");
            return;
        }

        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        boolean success;
        if ("success".equals(resultCode)) {
            success = paymentService.processOnlinePaymentSuccess(txnRef, user.getId(), clientIp, userAgent);
            if (success) {
                req.getSession().setAttribute("successMessage", "Thanh toán online thành công!");
                // Clear payment session data on successful payment
                req.getSession().removeAttribute("currentInvoice");
                req.getSession().removeAttribute("currentAppointment");
            } else {
                req.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi xử lý thanh toán.");
            }
        } else {
            success = paymentService.processOnlinePaymentFailure(txnRef, user.getId(), clientIp, userAgent);
            req.getSession().setAttribute("errorMessage", "Thanh toán bị hủy hoặc thất bại.");
        }
        
        // Redirect back to appointments page
        resp.sendRedirect(req.getContextPath() + "/patient/appointments");
    }

    private void handleVnpayMockPage(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        String txnRef = req.getParameter("txnRef");
        if (txnRef == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing transaction reference");
            return;
        }

        req.setAttribute("txnRef", txnRef);
        req.getRequestDispatcher("/WEB-INF/views/patient/vnpay-mock.jsp").forward(req, resp);
    }

    private void handleCreateInvoiceAndRedirect(HttpServletRequest req, HttpServletResponse resp, User user, String appointmentId) 
            throws ServletException, IOException {
        
        try {
            if (appointmentId == null || appointmentId.trim().isEmpty()) {
                req.getSession().setAttribute("errorMessage", "Mã lịch hẹn không hợp lệ");
                resp.sendRedirect(req.getContextPath() + "/patient/appointments");
                return;
            }

            // Quick validation: get patient first to reduce queries
            Patient patient = patientDAO.findByUserId(user.getId());
            if (patient == null) {
                req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân");
                resp.sendRedirect(req.getContextPath() + "/patient/appointments");
                return;
            }

            // Check if invoice already exists to avoid duplicate work
            Invoice existingInvoice = invoiceDAO.findByAppointmentId(appointmentId);
            Invoice invoice;
            Appointment appointment = appointmentDAO.findById(appointmentId);
            
            if (existingInvoice != null) {
                invoice = existingInvoice;
            } else {
                // Create new invoice using service
                String clientIp = RequestUtil.getClientIp(req);
                String userAgent = req.getHeader("User-Agent");
                invoice = paymentService.createOrGetInvoice(appointmentId, user.getId(), clientIp, userAgent);
            }
            
            // Store invoice and appointment in session for clean URL reload
            req.getSession().setAttribute("currentInvoice", invoice);
            req.getSession().setAttribute("currentAppointment", appointment);
            
            // Redirect to clean URL
            resp.sendRedirect(req.getContextPath() + "/patient/payment");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Lỗi tạo hóa đơn: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/patient/appointments");
        }
    }

    private void handleShowPaymentFromSession(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        try {
            HttpSession session = req.getSession();
            Invoice invoice = (Invoice) session.getAttribute("currentInvoice");
            Appointment appointment = (Appointment) session.getAttribute("currentAppointment");
            
            if (invoice == null) {
                // No payment session data, redirect to appointments
                resp.sendRedirect(req.getContextPath() + "/patient/appointments");
                return;
            }
            
            // Refresh invoice data from database in case status changed
            Invoice refreshedInvoice = invoiceDAO.findById(invoice.getId());
            if (refreshedInvoice != null) {
                invoice = refreshedInvoice;
                session.setAttribute("currentInvoice", invoice); // Update session
            }
            
            req.setAttribute("invoice", invoice);
            req.setAttribute("appointment", appointment);
            req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
        } catch (Exception e) {
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi hiển thị trang thanh toán: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }
}