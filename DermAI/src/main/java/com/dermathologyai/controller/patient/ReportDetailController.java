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

import java.io.IOException;

public class ReportDetailController extends HttpServlet {
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
        if (id == null || id.isBlank()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Report not found");
            return;
        }

        DiagnosisReport report = reportDAO.findById(id.trim());
        if (report == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Report not found");
            return;
        }

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Patient patient = user == null ? null : patientDAO.findByUserId(user.getId());
        if (patient == null || !patient.getId().equals(report.getPatientId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied. You do not have permission to view this report.");
            return;
        }

        boolean pending = "PENDING_DOCTOR_REVIEW".equals(report.getDoctorReviewStatus());
        if (!pending && !"VISIBLE".equals(report.getPatientVisibilityStatus())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied. This screening result has not been shared with you.");
            return;
        }
        req.setAttribute("report", report);
        req.setAttribute("limitedView", pending);
        req.getRequestDispatcher("/WEB-INF/views/patient/report-detail.jsp").forward(req, resp);
    }
}
