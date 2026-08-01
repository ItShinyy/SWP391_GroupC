package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.AiModelDAO;
import com.dermathologyai.dao.AiScreeningAttemptDAO;
import com.dermathologyai.dao.ClinicalPolicyDAO;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.DiseaseDAO;
import com.dermathologyai.model.AiModel;
import com.dermathologyai.model.AiScreeningAttempt;
import com.dermathologyai.model.ClinicalPolicyEntry;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Disease;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.security.Permission;
import com.dermathologyai.util.FormatUtil;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Base64;
import java.util.Deque;
import java.util.HexFormat;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/** Coordinates authorization, private media, active model inference, and doctor-review reports. */
public class AiScreeningService {
    private static final Logger logger = LoggerFactory.getLogger(AiScreeningService.class);
    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private final ScreeningAuthorizationService authorizationService = new ScreeningAuthorizationService();
    private final ImageValidationService imageValidationService = new ImageValidationService();
    private final AiInferenceClient inferenceClient = new AiInferenceClient();
    private final AiModelDAO modelDAO = new AiModelDAO();
    private final AiScreeningAttemptDAO attemptDAO = new AiScreeningAttemptDAO();
    private final ClinicalPolicyDAO policyDAO = new ClinicalPolicyDAO();
    private final DiseaseDAO diseaseDAO = new DiseaseDAO();
    private final DiagnosisReportDAO reportDAO = new DiagnosisReportDAO();
    private final AuditService auditService = new AuditService();
    private final CloudinaryDiagnosisMediaStorage mediaStorage = new CloudinaryDiagnosisMediaStorage();
    private final ConcurrentHashMap<String, Deque<Long>> rateAttempts = new ConcurrentHashMap<>();
    private final int rateMax = AppConfig.getInt("ai.screening.max.requests.per.window", 3);
    private final long rateWindowMs = AppConfig.getInt("ai.screening.rate.window.seconds", 60) * 1000L;

    public ScreeningOutcome createForPatient(User requestingUser, String idempotencyKey, Part imagePart,
                                              String clientIp, String userAgent) throws ScreeningException {
        if (!validIdempotencyKey(idempotencyKey)) {
            throw new ScreeningException("A valid idempotency key is required.");
        }
        Patient patient = authorizationService.requireAuthorizedPatient(requestingUser, Permission.AI_SCREENING_CREATE);
        if (patient == null) {
            throw new ScreeningException("Complete your patient profile before starting a screening.");
        }
        return createAuthorized(requestingUser, patient.getId(), idempotencyKey, imagePart, clientIp, userAgent);
    }

    private ScreeningOutcome createAuthorized(User requestingUser, String patientId, String idempotencyKey, Part imagePart,
                                              String clientIp, String userAgent) throws ScreeningException {
        if (!AppConfig.getBoolean("ai.service.enabled", false)) {
            throw new ScreeningException("AI-assisted screening is not currently available in this environment.");
        }
        if (!tryAcquire(requestingUser.getId())) throw new ScreeningException("Too many screening requests. Please try again shortly.");

        AiScreeningAttempt existing = attemptDAO.findByIdempotencyKey(idempotencyKey);
        if (existing != null) {
            if (!patientId.equals(existing.getPatientId())) {
                throw new ScreeningException("This idempotency key belongs to a different request.");
            }
            return ScreeningOutcome.fromExisting(existing);
        }

        AiModel model = modelDAO.findActive();
        if (model == null) throw new ScreeningException("No AI model is active. Ask an administrator to activate a package.");
        AiScreeningAttempt attempt = new AiScreeningAttempt();
        attempt.setIdempotencyKey(idempotencyKey);
        attempt.setPatientId(patientId);
        attempt.setRequestedByUserId(requestingUser.getId());
        attempt.setAiModelId(model.getId());
        String attemptId = attemptDAO.createPending(attempt);
        if (attemptId == null) {
            AiScreeningAttempt duplicate = attemptDAO.findByIdempotencyKey(idempotencyKey);
            if (duplicate != null) return ScreeningOutcome.fromExisting(duplicate);
            throw new ScreeningException("The screening attempt could not be created.");
        }
        audit(requestingUser, "AI_SCREENING_ATTEMPT_CREATED", "ai_screening_attempts", attemptId, clientIp, userAgent);

        String inputKey = null;
        boolean inputUploaded = false;
        try {
            NormalizedImage image = imageValidationService.normalize(imagePart);
            inputKey = inputObjectKey(patientId, attemptId);
            inputKey = mediaStorage.upload(inputKey, image.bytes(), "image", image.sha256());
            inputUploaded = true;
            if (!attemptDAO.recordInput(attemptId, image.sha256(), inputKey) || !attemptDAO.markProcessing(attemptId)) {
                throw new ScreeningException("The screening attempt is no longer available for processing.", "FAILED_DATABASE");
            }
            AiInferenceClient.ScreeningResponse response = inferenceClient.screen(attemptId, image);
            if (!response.accepted()) {
                if (!attemptDAO.complete(attemptId, "REJECTED", response.rejectionCode(), null)) {
                    throw new ScreeningException("The screening rejection could not be recorded.", "FAILED_DATABASE");
                }
                compensateInput(attemptId, inputKey);
                audit(requestingUser, "AI_SCREENING_ATTEMPT_REJECTED", "ai_screening_attempts", attemptId, clientIp, userAgent);
                return ScreeningOutcome.rejected(attemptId, response.rejectionCode());
            }
            ClinicalPolicyEntry policy = policyDAO.findByDiseaseCode(response.canonicalClassCode());
            if (policy == null) throw new ScreeningException("No clinical policy exists for this AI class.", "FAILED_AI");
            return persistAcceptedAttempt(requestingUser, patientId, attemptId, model, policy, inputKey, response, clientIp, userAgent);
        } catch (ImageValidationService.ImageValidationException e) {
            abort(attemptId, "INVALID_IMAGE", inputUploaded ? inputKey : null, requestingUser, clientIp, userAgent);
            throw new ScreeningException(e.getMessage());
        } catch (IOException e) {
            logger.error("Private media store failed for attempt {}", attemptId, e);
            abort(attemptId, "FAILED_STORAGE", inputUploaded ? inputKey : null, requestingUser, clientIp, userAgent);
            throw new ScreeningException("The private media store is unavailable. No result was created.");
        } catch (ScreeningException e) {
            abort(attemptId, e.failureCode(), inputUploaded ? inputKey : null, requestingUser, clientIp, userAgent);
            throw e;
        } catch (AiInferenceClient.AiInferenceException e) {
            logger.error("AI inference failed for attempt {}: {}", attemptId, e.toString());
            abort(attemptId, "FAILED_AI", inputUploaded ? inputKey : null, requestingUser, clientIp, userAgent);
            throw new ScreeningException("The screening service is unavailable. No result was created.");
        } catch (RuntimeException e) {
            logger.error("Unexpected screening failure for attempt {}", attemptId, e);
            abort(attemptId, "FAILED_AI", inputUploaded ? inputKey : null, requestingUser, clientIp, userAgent);
            throw new ScreeningException("The screening could not be completed. No result was created.");
        }
    }

    private ScreeningOutcome persistAcceptedAttempt(User user, String patientId, String attemptId, AiModel model,
                                                     ClinicalPolicyEntry policy, String inputKey,
                                                     AiInferenceClient.ScreeningResponse response,
                                                     String clientIp, String userAgent) throws ScreeningException {
        Disease disease = diseaseDAO.findByCode(policy.getDiseaseCode());
        if (disease == null) throw new ScreeningException("Disease catalog is missing this AI class.", "FAILED_AI");
        String reportId = UUID.randomUUID().toString();
        String patientPartition = opaquePatientPartition(patientId);
        String prefix = AppConfig.get("media.diagnosis.prefix", "diagnoses/v1").replaceAll("/+?$", "");
        String eigenCamKey = response.eigenCamPng() == null ? null
            : prefix + "/" + patientPartition + "/" + attemptId + "/eigencam";
        try {
            if (eigenCamKey != null) {
                byte[] heatmap = response.eigenCamPng();
                eigenCamKey = mediaStorage.upload(eigenCamKey, heatmap, "image/png", sha256(heatmap));
            }
        } catch (IOException | RuntimeException e) {
            logger.warn("metric=ai_media_upload_failure value=1 stage=eigencam");
            safeDelete(eigenCamKey);
            throw new ScreeningException("The private media store is unavailable. No result was created.", "FAILED_STORAGE");
        }

        DiagnosisReport report = new DiagnosisReport();
        report.setId(reportId);
        report.setPatientId(patientId);
        report.setDiseaseId(disease.getId());
        report.setClinicId(null);
        report.setConfidenceScore(FormatUtil.confidencePercent(response.top1Confidence()));
        report.setRiskLevel(policy.getRiskLevel());
        report.setRecommendation(policy.getRecommendation());
        report.setModelVersion(response.modelVersion() != null ? response.modelVersion() : model.getVersion());
        report.setAiScreeningAttemptId(attemptId);
        report.setInputImageObjectKey(inputKey);
        report.setEigencamObjectKey(eigenCamKey);
        report.setAiSuggestedDiseaseId(disease.getId());
        String createdReportId = reportDAO.createScreeningReport(report);
        if (createdReportId == null || !attemptDAO.complete(attemptId, "ACCEPTED", null, reportId)) {
            if (createdReportId != null) {
                logger.info("metric=ai_compensation_action value=1 action=report_delete outcome={}",
                    reportDAO.deleteUnreviewedScreeningReport(reportId) ? "completed" : "retry_required");
            }
            safeDelete(eigenCamKey);
            throw new ScreeningException("The screening could not be saved. No result was created.", "FAILED_DATABASE");
        }
        audit(user, "AI_SCREENING_ATTEMPT_ACCEPTED", "diagnosis_reports", reportId, clientIp, userAgent);
        return ScreeningOutcome.accepted(attemptId, reportId);
    }

    private void abort(String attemptId, String failureCode, String inputKey, User user, String clientIp, String userAgent) {
        failAttempt(attemptId, failureCode);
        if (inputKey != null) compensateInput(attemptId, inputKey);
        audit(user, "AI_SCREENING_ATTEMPT_FAILED", "ai_screening_attempts", attemptId, clientIp, userAgent);
    }

    private boolean tryAcquire(String subjectId) {
        long now = Instant.now().toEpochMilli();
        Deque<Long> subjectAttempts = rateAttempts.computeIfAbsent(subjectId, ignored -> new ArrayDeque<>());
        synchronized (subjectAttempts) {
            while (!subjectAttempts.isEmpty() && now - subjectAttempts.peekFirst() >= rateWindowMs) subjectAttempts.removeFirst();
            if (subjectAttempts.size() >= rateMax) return false;
            subjectAttempts.addLast(now);
            return true;
        }
    }

    private String inputObjectKey(String patientId, String attemptId) throws ScreeningException {
        String patientPartition = opaquePatientPartition(patientId);
        String prefix = AppConfig.get("media.diagnosis.prefix", "diagnoses/v1").replaceAll("/+?$", "");
        return prefix + "/" + patientPartition + "/" + attemptId + "/normalized_input";
    }

    private String opaquePatientPartition(String patientId) throws ScreeningException {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(AppConfig.require("media.object.key.secret").getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(mac.doFinal(patientId.getBytes(StandardCharsets.UTF_8))).substring(0, 32);
        } catch (GeneralSecurityException | IllegalStateException e) {
            throw new ScreeningException("Private media configuration is incomplete.", "FAILED_STORAGE");
        }
    }

    private boolean safeDelete(String objectKey) {
        if (objectKey == null) return true;
        try {
            mediaStorage.delete(objectKey);
            return true;
        } catch (IOException ignored) {
            return false;
        }
    }

    private void compensateInput(String attemptId, String inputKey) {
        if (inputKey == null) return;
        boolean deleted = safeDelete(inputKey);
        boolean cleared = deleted && attemptDAO.clearInputObjectKey(attemptId, inputKey);
        logger.info("metric=ai_compensation_action value=1 action=input_delete outcome={}",
            cleared ? "completed" : "retry_required");
    }

    private void failAttempt(String attemptId, String failureCode) {
        if (!attemptDAO.failPending(attemptId, failureCode)) {
            attemptDAO.complete(attemptId, "FAILED", failureCode, null);
        }
    }

    private static String sha256(byte[] content) throws IOException {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(content));
        } catch (NoSuchAlgorithmException e) {
            throw new IOException("SHA-256 is unavailable.", e);
        }
    }

    private void audit(User user, String action, String entityType, String recordId, String ip, String userAgent) {
        auditService.log(user.getId(), action, entityType, recordId, null, null, null, ip, userAgent);
    }

    private static boolean validIdempotencyKey(String value) {
        return value != null && value.matches("[A-Za-z0-9_-]{16,100}");
    }

    public record ScreeningOutcome(String attemptId, String status, String reportId, String rejectionCode) {
        static ScreeningOutcome accepted(String attemptId, String reportId) { return new ScreeningOutcome(attemptId, "ACCEPTED", reportId, null); }
        static ScreeningOutcome rejected(String attemptId, String rejectionCode) { return new ScreeningOutcome(attemptId, "REJECTED", null, rejectionCode); }
        static ScreeningOutcome fromExisting(AiScreeningAttempt attempt) {
            return new ScreeningOutcome(attempt.getId(), attempt.getStatus(), attempt.getDiagnosisReportId(), attempt.getFailureCode());
        }
    }

    public static class ScreeningException extends Exception {
        private final String failureCode;
        public ScreeningException(String message) { this(message, "FAILED_DATABASE"); }
        public ScreeningException(String message, String failureCode) {
            super(message);
            this.failureCode = failureCode;
        }
        public String failureCode() { return failureCode; }
    }
}
