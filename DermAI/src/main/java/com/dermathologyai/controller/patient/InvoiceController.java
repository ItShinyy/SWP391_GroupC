package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.PaymentDAO;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.PaymentHistory;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

public class InvoiceController extends HttpServlet {
    private PaymentDAO paymentDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        paymentDAO = new PaymentDAO();
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
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            session.setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân trước khi xem danh sách hóa đơn.");
            resp.sendRedirect(req.getContextPath() + "/account/profile");
            return;
        }

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

        List<PaymentHistory> invoiceHistory = Collections.emptyList();
        int totalInvoices = 0;
        try {
            invoiceHistory = paymentDAO.findPaymentHistoryByPatientId(patient.getId(), page, pageSize);
            totalInvoices = paymentDAO.countPaymentHistoryByPatientId(patient.getId());
        } catch (Exception dbException) {
            req.setAttribute("errorMessage", "Không thể tải danh sách hóa đơn: " + dbException.getMessage());
        }

        int totalPages = pageSize > 0 ? (int) Math.ceil((double) totalInvoices / pageSize) : 0;
        req.setAttribute("invoiceHistory", invoiceHistory);
        req.setAttribute("totalInvoices", totalInvoices);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        req.getRequestDispatcher("/WEB-INF/views/patient/invoice.jsp").forward(req, resp);
    }
}
