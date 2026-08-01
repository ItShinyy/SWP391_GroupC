package com.dermathologyai.controller;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.security.Permission;
import com.dermathologyai.security.PermissionService;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.CloudinarySignHelper;
import com.dermathologyai.service.ScreeningAuthorizationService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/** After authorization, redirects to a short-lived signed Cloudinary CDN URL. */
public class ReportMediaController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ReportMediaController.class);
    private final DiagnosisReportDAO reportDAO = new DiagnosisReportDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final ScreeningAuthorizationService authorizationService = new ScreeningAuthorizationService();
    private final AuditService auditService = new AuditService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = user(request);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        Route route = Route.parse(request.getPathInfo());
        if (route == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        DiagnosisReport report = reportDAO.findById(route.reportId());
        if (report == null || !canRead(user, report)) {
            auditService.log(user.getId(), "AI_MEDIA_ACCESS_DENIED", "diagnosis_reports", route.reportId(), null, null, null,
                RequestUtil.getClientIp(request), request.getHeader("User-Agent"));
            logger.warn("AI media denied user={} reportId={} role={}", user.getId(), route.reportId(), user.getRole());
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String objectKey = route.input() ? report.getInputImageObjectKey() : report.getEigencamObjectKey();
        if (objectKey == null || objectKey.isBlank()) {
            logger.info("AI media missing object key reportId={} input={}", report.getId(), route.input());
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        try {
            String deliveryUrl = CloudinarySignHelper.signedOptimizedUrl(objectKey);
            response.setHeader("Cache-Control", "private, no-store");
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.sendRedirect(deliveryUrl);
            auditService.log(user.getId(), "AI_MEDIA_ACCESSED", "diagnosis_reports", report.getId(), null, null, null,
                RequestUtil.getClientIp(request), request.getHeader("User-Agent"));
        } catch (RuntimeException e) {
            logger.error("AI media delivery failed reportId={} key={}", report.getId(), objectKey, e);
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private boolean canRead(User user, DiagnosisReport report) {
        if ("DOCTOR".equals(user.getRole()) && PermissionService.has(user, Permission.AI_SCREENING_MEDIA_READ)) {
            var doctor = authorizationService.requireAuthorizedDoctor(user, report.getPatientId(), Permission.AI_SCREENING_MEDIA_READ);
            if (doctor == null) return false;
            return appointmentDAO.hasDoctorAcceptedAppointmentForReport(doctor.getId(), report.getId());
        }
        if ("ADMIN".equals(user.getRole()) && PermissionService.has(user, Permission.AI_AUDIT_READ)) {
            return true;
        }
        Patient patient = authorizationService.findPatientForUser(user);
        return patient != null && patient.getId().equals(report.getPatientId()) && "VISIBLE".equals(report.getPatientVisibilityStatus()) &&
            report.getDoctorReviewStatus() != null && !"PENDING_DOCTOR_REVIEW".equals(report.getDoctorReviewStatus());
    }

    private static User user(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    private record Route(String reportId, boolean input) {
        static Route parse(String path) {
            if (path == null) return null;
            String[] values = path.split("/");
            if (values.length != 4 || values[1].isBlank() || !"media".equals(values[2])) return null;
            if ("input".equals(values[3])) return new Route(values[1], true);
            if ("eigencam".equals(values[3])) return new Route(values[1], false);
            return null;
        }
    }
}
