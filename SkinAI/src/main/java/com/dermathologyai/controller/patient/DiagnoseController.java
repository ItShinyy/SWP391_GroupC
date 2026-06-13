package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AIService;
import com.dermathologyai.util.FileStorageUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,      // 5 MB limit per file
    maxRequestSize = 1024 * 1024 * 10   // 10 MB limit overall
)
public class DiagnoseController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(DiagnoseController.class);
    private AIService aiService;
    private DiagnosisReportDAO reportDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        // AI Service provides mock predictions for now
        aiService = new AIService();
        reportDAO = new DiagnosisReportDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        try {
            Part filePart = req.getPart("skinImage");
            
            if (filePart == null || filePart.getSize() == 0) {
                req.setAttribute("errorMessage", "Vui lòng chọn ảnh hợp lệ.");
                req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
                return;
            }

            if (filePart.getSize() > 5 * 1024 * 1024) {
                req.setAttribute("errorMessage", "Kích thước tệp vượt quá giới hạn 5MB.");
                req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
                return;
            }

            // Define upload dir relative to webapp root
            String uploadPath = getServletContext().getRealPath("") + "uploads";
            
            // Save file
            String relativeUrl = FileStorageUtil.saveFile(filePart, uploadPath);
            if (relativeUrl == null) {
                req.setAttribute("errorMessage", "Lỗi khi lưu ảnh. Vui lòng thử lại.");
                req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
                return;
            }

            // Simulate AI Processing time (3 seconds) to show loading screen
            try {
                Thread.sleep(3000);
            } catch (InterruptedException ignored) {}

            // Mock AI Predict
            AIService.AIResult result = aiService.predict(relativeUrl);

            // Create report
            DiagnosisReport report = new DiagnosisReport();
            report.setPatientId(user.getId()); // Using UserId as PatientId for MVP simplicity
            report.setImageUrl(relativeUrl);
            report.setHeatmapUrl(result.getHeatmapUrl());
            report.setConfidenceScore(result.getConfidence());
            report.setRiskLevel(result.getRiskLevel());
            report.setRecommendation(result.getRecommendation());
            report.setModelVersion("v1.0-mock");
            // diseaseId should be set based on result.getDiseaseCode(), skipped for now
            
            String reportId = reportDAO.create(report);
            
            auditLogDAO.createLog(user.getId(), "REPORT_CREATE", "diagnosis_reports", reportId, null, null, "Độ tin cậy: " + result.getConfidence(), RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            
            // Redirect to report view
            resp.sendRedirect(req.getContextPath() + "/patient/reports/view?id=" + reportId);

        } catch (IllegalStateException e) {
            // This happens if the file exceeds maxFileSize defined in @MultipartConfig
            req.setAttribute("errorMessage", "Kích thước tệp vượt quá giới hạn 5MB của hệ thống.");
            req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
        } catch (Exception e) {
            logger.error("Error processing diagnosis", e);
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống khi xử lý. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(req, resp);
        }
    }
}