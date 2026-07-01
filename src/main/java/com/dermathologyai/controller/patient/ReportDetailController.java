package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class ReportDetailController extends HttpServlet {
    private DiagnosisReportDAO reportDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Report ID is required");
            return;
        }

        DiagnosisReport report = reportDAO.findById(id);
        if (report == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Report not found");
            return;
        }

        // IDOR Prevention: Ensure the report belongs to the logged-in user
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null || (!"ADMIN".equals(user.getRole()) && !user.getId().equals(report.getPatientId()))) {
            // Log security incident?
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied. You do not have permission to view this report.");
            return;
        }

        req.setAttribute("report", report);
        req.getRequestDispatcher("/WEB-INF/views/patient/report-detail.jsp").forward(req, resp);
    }
}
