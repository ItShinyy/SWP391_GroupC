package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.Payment;
import com.dermathologyai.service.BillingService;
import com.dermathologyai.util.PageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class AdminBookingController extends HttpServlet {
    private AppointmentDAO appointmentDAO;
    private BillingService billingService;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
        billingService = new BillingService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path != null && path.startsWith("/detail/")) {
            String id = path.substring(8);
            Appointment appt = appointmentDAO.findById(id);
            if (appt == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch hẹn.");
                return;
            }
            Invoice invoice = billingService.findByAppointmentId(id);
            Payment payment = invoice == null ? null : billingService.findLatestPayment(invoice.getId());
            req.setAttribute("appointment", appt);
            req.setAttribute("invoice", invoice);
            req.setAttribute("payment", payment);
            req.getRequestDispatcher("/WEB-INF/views/admin/bookings/detail.jsp").forward(req, resp);
            return;
        }

        int page = PageUtil.parsePage(req.getParameter("page"));
        int pageSize = PageUtil.ADMIN_PAGE_SIZE;

        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");

        com.dermathologyai.model.AppointmentFilter filter = new com.dermathologyai.model.AppointmentFilter();
        if (keyword != null && !keyword.trim().isEmpty()) {
            filter.setKeyword(keyword.trim());
        }
        if (status != null && !status.isEmpty()) {
            filter.setStatus(status);
        }
        try {
            if (startDateStr != null && !startDateStr.isEmpty()) {
                filter.setStartDate(java.time.LocalDate.parse(startDateStr));
            }
            if (endDateStr != null && !endDateStr.isEmpty()) {
                filter.setEndDate(java.time.LocalDate.parse(endDateStr));
            }
        } catch (Exception e) {
            // Ignore parse errors for dates
        }

        int total = appointmentDAO.countAll(filter);
        int totalPages = PageUtil.getTotalPages(total, pageSize);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));
        List<Appointment> bookings = appointmentDAO.findAll(page, pageSize, filter);

        req.setAttribute("bookings", bookings);
        PageUtil.setPagingAttributes(req, page, total);

        req.getRequestDispatcher("/WEB-INF/views/admin/bookings/list.jsp").forward(req, resp);
    }
}
