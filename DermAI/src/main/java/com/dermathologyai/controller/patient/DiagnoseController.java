package com.dermathologyai.controller.patient;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AiScreeningService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.UUID;

/**
 * Patient AI screening intake. Accepted results are shown immediately as preliminary
 * (with disclaimer); official reports list stays HIDDEN until doctor review.
 */
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 12 * 1024 * 1024
)
public class DiagnoseController extends HttpServlet {
    private AiScreeningService screeningService;
    private DiagnosisReportDAO diagnosisReportDAO;

    @Override
    public void init() throws ServletException {
        screeningService = new AiScreeningService();
        diagnosisReportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        render(request, response, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        try {
            Part image = request.getPart("skinImage");
            AiScreeningService.ScreeningOutcome outcome = screeningService.createForPatient(
                user,
                request.getParameter("idempotencyKey"),
                image,
                RequestUtil.getClientIp(request),
                request.getHeader("User-Agent")
            );

            if ("ACCEPTED".equals(outcome.status()) && outcome.reportId() != null) {
                request.setAttribute("screeningResultStatus", "SUCCESS");
                request.setAttribute("bookingReportId", outcome.reportId());
                attachPreliminaryResult(request, outcome.reportId());
                render(request, response, null);
                return;
            }

            if ("REJECTED".equals(outcome.status())) {
                request.setAttribute("screeningResultStatus", "REJECTED");
                render(request, response,
                    "The image did not pass the screening quality checks. Please take a clear, well-lit photo and try again, or book a consultation without a screening image.");
                return;
            }

            render(request, response,
                "This screening request is still being processed. Please wait a moment before trying again.");
        } catch (AiScreeningService.ScreeningException | IllegalStateException e) {
            render(request, response, e.getMessage());
        }
    }

    private void render(HttpServletRequest request, HttpServletResponse response, String errorMessage)
        throws ServletException, IOException {
        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
        }
        // Always mint a fresh key when showing the form. Reusing a terminal REJECTED/FAILED
        // key would short-circuit retries to the old outcome (same message, no new inference).
        // In-flight double-submit still shares the key that was in the HTML at click time.
        request.setAttribute("idempotencyKey", UUID.randomUUID().toString().replace("-", ""));
        boolean aiEnabled = AppConfig.getBoolean("ai.service.enabled", false);
        request.setAttribute("screeningAvailable", aiEnabled);
        request.setAttribute("maxUploadBytes", AppConfig.getInt("hard.max.upload.bytes", 10 * 1024 * 1024));
        if (errorMessage == null) {
            String mapped = switch (String.valueOf(request.getParameter("error"))) {
                case "ai_paused" -> "AI screening is paused in this environment.";
                case "unauthorized" -> "Complete your patient profile before starting a screening.";
                default -> null;
            };
            if (mapped != null) request.setAttribute("errorMessage", mapped);
        }
        request.getRequestDispatcher("/WEB-INF/views/patient/diagnose.jsp").forward(request, response);
    }

    /** Loads persisted report fields for the success panel — never re-runs inference. */
    private void attachPreliminaryResult(HttpServletRequest request, String reportId) {
        DiagnosisReport report = diagnosisReportDAO.findById(reportId);
        if (report == null) return;
        request.setAttribute("preliminaryDiseaseName", report.getDiseaseName());
        double confidence = report.getConfidenceScore();
        if (confidence > 0 && confidence <= 1.0) confidence = confidence * 100.0;
        request.setAttribute("preliminaryConfidencePercent", Math.round(confidence * 10.0) / 10.0);
        request.setAttribute("preliminaryRiskLevel", report.getRiskLevel());
        request.setAttribute("preliminaryScreenedAt", report.getCreatedAt());
    }
}
