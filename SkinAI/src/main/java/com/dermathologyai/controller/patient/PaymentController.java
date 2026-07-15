package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.AppointmentDAO;
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

    @Override
    public void init() throws ServletException {
        paymentService = new PaymentService();
        appointmentDAO = new AppointmentDAO();
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
        String appointmentId = req.getParameter("appointmentId");
        String invoiceId = req.getParameter("invoiceId");

        try {
            if ("create".equals(action) && appointmentId != null) {
                // Create invoice for appointment
                handleCreateInvoice(req, resp, user, appointmentId);
            } else if ("view".equals(action) && invoiceId != null) {
                // View invoice details
                handleViewInvoice(req, resp, user, invoiceId);
            } else if ("vnpay-mock".equals(action)) {
                // Handle mock VNPay return
                handleVnpayMockReturn(req, resp, user);
            } else if (req.getRequestURI().contains("/vnpay/mock")) {
                // Show mock VNPay payment page
                handleVnpayMockPage(req, resp, user);
            } else if ("info".equals(action) || (action == null && appointmentId == null && invoiceId == null)) {
                // Show payment information page
                handlePaymentInfo(req, resp, user);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action or missing parameters");
            }
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
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
        String invoiceId = req.getParameter("invoiceId");

        try {
            if ("pay-offline".equals(action) && invoiceId != null) {
                // Process offline payment
                handleOfflinePayment(req, resp, user, invoiceId);
            } else if ("pay-online".equals(action) && invoiceId != null) {
                // Initiate online payment
                handleOnlinePayment(req, resp, user, invoiceId);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action or missing parameters");
            }
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
        }
    }

    private void handleCreateInvoice(HttpServletRequest req, HttpServletResponse resp, User user, String appointmentId) 
            throws ServletException, IOException {
        
        // Verify user owns this appointment
        Appointment appointment = appointmentDAO.findById(appointmentId);
        if (appointment == null) {
            req.setAttribute("errorMessage", "Lịch hẹn không tồn tại");
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            return;
        }

        // Check if user has access to this appointment (through patient record)
        // This should be implemented based on your patient-user relationship

        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        Invoice invoice = paymentService.createOrGetInvoice(appointmentId, user.getId(), clientIp, userAgent);
        
        // Redirect to payment view
        resp.sendRedirect(req.getContextPath() + "/patient/payment?action=view&invoiceId=" + invoice.getId());
    }

    private void handleViewInvoice(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        PaymentService.InvoiceWithDetails invoiceDetails = paymentService.getInvoiceWithDetails(invoiceId);
        if (invoiceDetails == null) {
            req.setAttribute("errorMessage", "Hóa đơn không tồn tại");
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            return;
        }

        // TODO: Add security check to ensure user owns this invoice

        req.setAttribute("invoice", invoiceDetails.getInvoice());
        req.setAttribute("appointment", invoiceDetails.getAppointment());
        req.getRequestDispatcher("/WEB-INF/views/patient/payment.jsp").forward(req, resp);
    }

    private void handleOfflinePayment(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        Payment payment = paymentService.processOfflinePayment(invoiceId, user.getId(), clientIp, userAgent);
        
        req.getSession().setAttribute("successMessage", 
            "Thanh toán tại quầy đã được ghi nhận! Vui lòng đến quầy lễ tân để hoàn tất thanh toán.");
        resp.sendRedirect(req.getContextPath() + "/patient/payment?action=view&invoiceId=" + invoiceId);
    }

    private void handleOnlinePayment(HttpServletRequest req, HttpServletResponse resp, User user, String invoiceId) 
            throws ServletException, IOException {
        
        String clientIp = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");

        Payment payment = paymentService.prepareOnlinePayment(invoiceId, user.getId(), clientIp, userAgent);
        
        // Redirect to mock VNPay payment page
        resp.sendRedirect(req.getContextPath() + payment.getPaymentUrl());
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

    private void handlePaymentInfo(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        
        // Show general payment information page
        req.getRequestDispatcher("/WEB-INF/views/patient/payment-info.jsp").forward(req, resp);
    }
}