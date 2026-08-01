package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.AiScreeningAttemptDAO;
import com.dermathologyai.dao.AuditLogDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.io.IOException;

/** Marks stale processing attempts as failed without exposing a partial result. */
public class AiScreeningRecoveryService {
    private static final Logger logger = LoggerFactory.getLogger(AiScreeningRecoveryService.class);
    private final AiScreeningAttemptDAO attemptDAO = new AiScreeningAttemptDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public void recoverStuckAttempts() {
        int timeoutMinutes = AppConfig.getInt("ai.processing.timeout.minutes", 10);
        List<String> recovered = attemptDAO.failStuckProcessing(timeoutMinutes);
        for (String attemptId : recovered) {
            auditLogDAO.createLog(null, "AI_SCREENING_ATTEMPT_RECOVERED", "ai_screening_attempts", attemptId,
                null, null, null, null, null);
        }
        cleanupOrphanedInputs();
    }

    private void cleanupOrphanedInputs() {
        int minimumAgeHours = AppConfig.getInt("orphan.minimum.age.hours", 24);
        List<AiScreeningAttemptDAO.MediaCleanupCandidate> candidates =
            attemptDAO.findMediaCleanupCandidates(minimumAgeHours);
        if (candidates.isEmpty()) return;

        try {
            CloudinaryDiagnosisMediaStorage storage = new CloudinaryDiagnosisMediaStorage();
            for (AiScreeningAttemptDAO.MediaCleanupCandidate candidate : candidates) {
                try {
                    storage.delete(candidate.inputImageObjectKey());
                    if (attemptDAO.clearInputObjectKey(candidate.attemptId(), candidate.inputImageObjectKey())) {
                        auditLogDAO.createLog(null, "AI_SCREENING_ORPHAN_MEDIA_CLEANED", "ai_screening_attempts",
                            candidate.attemptId(), null, null, null, null, null);
                        logger.info("metric=ai_orphan_cleanup value=1 outcome=completed");
                    } else {
                        logger.warn("metric=ai_orphan_cleanup value=1 outcome=retry_required reason=database");
                    }
                } catch (IOException ignored) {
                    // Leave the object key in SQL so a later scheduled pass can retry safely.
                    logger.warn("metric=ai_orphan_cleanup value=1 outcome=retry_required reason=storage");
                }
            }
        } catch (RuntimeException ignored) {
            // Cloudinary may be transiently unavailable; the next scheduled pass retries.
            logger.warn("metric=ai_orphan_cleanup value={} outcome=retry_required reason=storage_unavailable",
                candidates.size());
        }
    }
}
