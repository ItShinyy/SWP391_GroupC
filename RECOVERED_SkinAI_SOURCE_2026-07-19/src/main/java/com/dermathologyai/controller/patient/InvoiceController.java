package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.PaymentDAO;
import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.PaymentHistory;
import com.dermathologyai.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class InvoiceController extends HttpServlet {
    private PaymentDAO paymentDAO;
    private InvoiceDAO invoiceDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        paymentDAO = new PaymentDAO();
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
        
        try {
            // Get patient information
            Patient patient = patientDAO.findByUserId(user.getId());
            if (patient == null) {
                if (!resp.isCommitted()) {
                    req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ bệnh nhân trước khi xem danh sách hóa đơn.");
                    resp.sendRedirect(req.getContextPath() + "/patient/profile");
                }
                return;
            }

            // Pagination parameters
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

            // Get payment history with error handling
            List<PaymentHistory> invoiceHistory = null;
            int totalInvoices = 0;
            
            try {
                invoiceHistory = paymentDAO.findPaymentHistoryByPatientId(patient.getId(), page, pageSize);
                totalInvoices = invoiceDAO.countByPatientId(patient.getId());
            } catch (Exception dbException) {
                // Handle database exceptions specifically
                if (!resp.isCommitted()) {
                    req.setAttribute("errorMessage", "Không thể tải danh sách hóa đơn từ database: " + dbException.getMessage());
                    req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
                }
                return;
            }
            
            int totalPages = (int) Math.ceil((double) totalInvoices / pageSize);

            // Set attributes for JSP
            req.setAttribute("invoiceHistory", invoiceHistory);
            req.setAttribute("totalInvoices", totalInvoices);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("pageSize", pageSize);

            // Forward to JSP - only if response not committed
            if (!resp.isCommitted()) {
                req.getRequestDispatcher("/WEB-INF/views/patient/invoice.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            // Only forward to error page if response hasn't been committed yet
            if (!resp.isCommitted()) {
                req.setAttribute("errorMessage", "Lỗi khi tải danh sách hóa đơn: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
            }
        }
    }
}