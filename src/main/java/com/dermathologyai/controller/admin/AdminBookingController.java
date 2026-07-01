package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.User;
import com.dermathologyai.util.PageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class AdminBookingController extends HttpServlet {
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User loggedInUser = (User) req.getSession().getAttribute("user");
        if (loggedInUser == null || !"ADMIN".equals(loggedInUser.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
            return;
        }

        String path = req.getPathInfo();
        if (path != null && path.startsWith("/detail/")) {
            String id = path.substring(8);
            Appointment appt = appointmentDAO.findById(id);
            if (appt == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch hẹn.");
                return;
            }
            req.setAttribute("appointment", appt);
            req.getRequestDispatcher("/WEB-INF/views/admin/bookings/detail.jsp").forward(req, resp);
            return;
        }

        int page = 1;
        int pageSize = 10;
        String pageStr = req.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (NumberFormatException ignored) {}
        }
        
        // Parse filter parameters
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

        List<Appointment> bookings = appointmentDAO.findAll(page, pageSize, filter);
        int total = appointmentDAO.countAll(filter);

        req.setAttribute("bookings", bookings);
        req.setAttribute("totalPages", PageUtil.getTotalPages(total, pageSize));
        req.setAttribute("currentPage", page);
        
        // Keep filter values in request for JSP
        req.setAttribute("param", req.getParameterMap()); // Not fully necessary as JSP can access ${param.keyword} natively, but good practice if needed

        req.getRequestDispatcher("/WEB-INF/views/admin/bookings/list.jsp").forward(req, resp);
    }
}
