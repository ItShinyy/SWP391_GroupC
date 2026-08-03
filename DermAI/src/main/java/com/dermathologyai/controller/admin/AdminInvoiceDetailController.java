package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.dao.PaymentDAO;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Admin invoice detail — bypasses the patient-profile guard in InvoiceController.
 * Routes to /admin/invoices/detail?appointmentId=...
 */
public class AdminInvoiceDetailController extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String appointmentId = req.getParameter("appointmentId");
        if (appointmentId == null || appointmentId.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing appointmentId");
            return;
        }

        Invoice invoice = invoiceDAO.findByAppointmentId(appointmentId.trim());
        if (invoice == null) {
            req.setAttribute("errorMessage", "Không tìm thấy hóa đơn cho lịch hẹn này.");
            req.getRequestDispatcher("/WEB-INF/views/admin/invoices/detail.jsp").forward(req, resp);
            return;
        }

        Payment latestPayment = paymentDAO.findLatestByInvoiceId(invoice.getId());

        req.setAttribute("invoice", invoice);
        req.setAttribute("latestPayment", latestPayment);
        req.getRequestDispatcher("/WEB-INF/views/admin/invoices/detail.jsp").forward(req, resp);
    }
}