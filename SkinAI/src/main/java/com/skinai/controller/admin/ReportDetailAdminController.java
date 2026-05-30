package com.skinai.controller.admin;

import com.skinai.dal.DiagnosisReportDAO;
import com.skinai.model.DiagnosisReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class ReportDetailAdminController extends HttpServlet {
    private DiagnosisReportDAO diagnosisReportDAO;

    @Override
    public void init() throws ServletException {
        diagnosisReportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/ai-results");
            return;
        }

        DiagnosisReport report = diagnosisReportDAO.findById(id);
        if (report == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/ai-results");
            return;
        }

        req.setAttribute("report", report);
        req.getRequestDispatcher("/WEB-INF/views/admin/reports/ai-results-detail.jsp").forward(req, resp);
    }
}
