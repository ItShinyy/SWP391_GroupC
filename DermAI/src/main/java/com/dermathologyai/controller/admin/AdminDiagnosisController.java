package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.util.PageUtil;
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
        int page = PageUtil.parsePage(req.getParameter("page"));
        int pageSize = PageUtil.ADMIN_PAGE_SIZE;

        String search = req.getParameter("search");
        String risk = req.getParameter("risk");
        String sort = req.getParameter("sort");

        int totalReports = diagnosisReportDAO.countAll(search, risk);
        int totalPages = PageUtil.getTotalPages(totalReports, pageSize);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));
        List<DiagnosisReport> reports = diagnosisReportDAO.findAll(search, risk, sort, page, pageSize);

        req.setAttribute("reports", reports);
        PageUtil.setPagingAttributes(req, page, totalReports);

        req.getRequestDispatcher("/WEB-INF/views/admin/reports/ai-results.jsp").forward(req, resp);
    }
}
