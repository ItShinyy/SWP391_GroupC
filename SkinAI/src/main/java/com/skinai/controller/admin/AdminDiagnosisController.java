package com.skinai.controller.admin;

import com.skinai.dal.DiagnosisReportDAO;
import com.skinai.model.DiagnosisReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class AdminDiagnosisController extends HttpServlet {
    private DiagnosisReportDAO diagnosisReportDAO;

    @Override
    public void init() throws ServletException {
        diagnosisReportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int pageSize = 10;
        
        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        String search = req.getParameter("search");
        String risk = req.getParameter("risk");
        String sort = req.getParameter("sort");

        List<DiagnosisReport> reports = diagnosisReportDAO.findAll(search, risk, sort, page, pageSize);
        int totalReports = diagnosisReportDAO.countAll(search, risk);
        int totalPages = (int) Math.ceil((double) totalReports / pageSize);

        req.setAttribute("reports", reports);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/WEB-INF/views/admin/reports/ai-results.jsp").forward(req, resp);
    }
}
