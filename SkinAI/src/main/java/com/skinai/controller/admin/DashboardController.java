package com.skinai.controller.admin;

import com.skinai.dal.ArticleDAO;
import com.skinai.dal.DiagnosisReportDAO;
import com.skinai.dal.DiseaseDAO;
import com.skinai.dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class DashboardController extends HttpServlet {
    private UserDAO userDAO;
    private DiagnosisReportDAO reportDAO;
    private ArticleDAO articleDAO;
    private DiseaseDAO diseaseDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        reportDAO = new DiagnosisReportDAO();
        articleDAO = new ArticleDAO();
        diseaseDAO = new DiseaseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Get stats
        req.setAttribute("totalUsers", userDAO.countAll());
        req.setAttribute("totalReports", reportDAO.countAll());
        req.setAttribute("totalArticles", articleDAO.countAll());
        req.setAttribute("totalDiseases", diseaseDAO.countAll());

        // Get recent reports
        req.setAttribute("recentReports", reportDAO.findAll(1, 10));

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
