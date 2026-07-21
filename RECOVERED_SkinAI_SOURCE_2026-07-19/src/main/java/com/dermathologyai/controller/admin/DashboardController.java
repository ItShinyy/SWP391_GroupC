package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.DiseaseDAO;
import com.dermathologyai.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class DashboardController extends HttpServlet {
    private UserDAO userDAO;
    private DiagnosisReportDAO reportDAO;
    private DiseaseDAO diseaseDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        reportDAO = new DiagnosisReportDAO();
        diseaseDAO = new DiseaseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Get stats
        req.setAttribute("totalUsers", userDAO.countAll());
        req.setAttribute("totalReports", reportDAO.countAll());
        req.setAttribute("totalDiseases", diseaseDAO.countAll());

        // Get recent reports
        req.setAttribute("recentReports", reportDAO.findAll(1, 10));

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
