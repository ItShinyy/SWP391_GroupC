package com.skinai.controller.patient;

import com.skinai.dal.DiagnosisReportDAO;
import com.skinai.model.DiagnosisReport;
import com.skinai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class PatientReportsController extends HttpServlet {
    private DiagnosisReportDAO reportDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        int page = 1;
        int pageSize = 10;
        
        String pageParam = req.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                // Ignore invalid page numbers
            }
        }
        
        List<DiagnosisReport> reports = reportDAO.findByPatientId(user.getId(), page, pageSize);
        int totalReports = reportDAO.countByPatientId(user.getId());
        int totalPages = (int) Math.ceil((double) totalReports / pageSize);
        
        req.setAttribute("reports", reports);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        
        req.getRequestDispatcher("/WEB-INF/views/patient/reports.jsp").forward(req, resp);
    }
}
