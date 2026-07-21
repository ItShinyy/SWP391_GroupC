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

public class ReportDetailController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ReportDetailController.class);
    private DiagnosisReportDAO reportDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new DiagnosisReportDAO();
        patientDAO = new PatientDAO();
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
        
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Get patient ID from user ID (same logic as PatientReportsController)
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            logger.error("No patient profile found for user: {}", user.getId());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Patient profile not found");
            return;
        }
        
        // Check if user is admin OR the report belongs to this patient
        if (!"ADMIN".equals(user.getRole()) && !patient.getId().equals(report.getPatientId())) {
            logger.warn("Access denied for user {} trying to view report {} (belongs to patient {})", 
                       user.getId(), report.getId(), report.getPatientId());
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied. You do not have permission to view this report.");
            return;
        }

        logger.info("User {} (patient {}) viewing report {}", user.getId(), patient.getId(), report.getId());
        req.setAttribute("report", report);
        req.getRequestDispatcher("/WEB-INF/views/patient/report-detail.jsp").forward(req, resp);
    }
}
