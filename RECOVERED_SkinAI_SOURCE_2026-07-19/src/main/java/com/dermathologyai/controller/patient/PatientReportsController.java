package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

public class PatientReportsController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(PatientReportsController.class);
    private DiagnosisReportDAO reportDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new DiagnosisReportDAO();
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
        
        // Get patient ID from user ID (CRITICAL FIX)
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            logger.error("No patient profile found for user: {}", user.getId());
            req.setAttribute("error", "Patient profile not found. Please contact support.");
            req.setAttribute("reports", List.of()); // Empty list to prevent JSP errors
            req.setAttribute("currentPage", 1);
            req.setAttribute("totalPages", 0);
            req.setAttribute("totalRecords", 0);
            req.getRequestDispatcher("/WEB-INF/views/patient/reports.jsp").forward(req, resp);
            return;
        }
        
        // Pagination
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
        
        // Filter parameters
        String search = req.getParameter("search");
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");
        String riskLevel = req.getParameter("risk");
        String sort = req.getParameter("sort");
        
        logger.info("PatientReportsController - User: {}, Patient: {}, Page: {}, Filters - search: {}, fromDate: {}, toDate: {}, risk: {}, sort: {}", 
                    user.getId(), patient.getId(), page, search, fromDate, toDate, riskLevel, sort);
        
        // Use filtered method (handles null parameters gracefully)
        List<DiagnosisReport> reports = reportDAO.findByPatientIdFiltered(
            patient.getId(), search, fromDate, toDate, riskLevel, sort, page, pageSize
        );
        int totalReports = reportDAO.countByPatientIdFiltered(
            patient.getId(), search, fromDate, toDate, riskLevel
        );
        
        logger.info("PatientReportsController - Found {} reports, total pages: {}", totalReports, (int) Math.ceil((double) totalReports / pageSize));
        
        int totalPages = (int) Math.ceil((double) totalReports / pageSize);
        
        req.setAttribute("reports", reports);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalReports);
        
        req.getRequestDispatcher("/WEB-INF/views/patient/reports.jsp").forward(req, resp);
    }
}
