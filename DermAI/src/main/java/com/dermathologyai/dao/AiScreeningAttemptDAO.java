package com.dermathologyai.dao;

import com.dermathologyai.model.AiScreeningAttempt;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

public class AiScreeningAttemptDAO extends DBContext {
    private static final String SELECT_COLS =
        "SELECT id, idempotency_key, patient_id, requested_by_user_id, status," +
        " failure_code, ai_model_id, input_sha256, input_image_object_key, diagnosis_report_id, created_at FROM ai_screening_attempts";

    public AiScreeningAttempt findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", AiScreeningAttemptDAO::mapRow, id);
    }

    public AiScreeningAttempt findByIdempotencyKey(String key) {
        return queryOne(SELECT_COLS + " WHERE idempotency_key = ?", AiScreeningAttemptDAO::mapRow, key);
    }

    public String createPending(AiScreeningAttempt attempt) {
        String id = UUID.randomUUID().toString();
        boolean inserted = executeUpdate(
            "INSERT INTO ai_screening_attempts (id, idempotency_key, patient_id, requested_by_user_id," +
            " status, ai_model_id, input_sha256) VALUES (?, ?, ?, ?, 'PENDING', ?, ?)",
            id, attempt.getIdempotencyKey(), attempt.getPatientId(), attempt.getRequestedByUserId(),
            attempt.getAiModelId(), attempt.getInputSha256()
        );
        return inserted ? id : null;
    }

    public boolean markProcessing(String id) {
        return executeUpdate(
            "UPDATE ai_screening_attempts SET status = 'PROCESSING', processing_started_at = SYSUTCDATETIME()," +
            " heartbeat_at = SYSUTCDATETIME() WHERE id = ? AND status = 'PENDING'", id
        );
    }

    public boolean recordInput(String id, String inputSha256, String inputImageObjectKey) {
        return executeUpdate(
            "UPDATE ai_screening_attempts SET input_sha256 = ?, input_image_object_key = ?, heartbeat_at = SYSUTCDATETIME()" +
            " WHERE id = ? AND status = 'PENDING'", inputSha256, inputImageObjectKey, id
        );
    }

    public boolean clearInputObjectKey(String id, String inputImageObjectKey) {
        return executeUpdate(
            "UPDATE ai_screening_attempts SET input_image_object_key = NULL" +
            " WHERE id = ? AND input_image_object_key = ?", id, inputImageObjectKey
        );
    }

    public List<MediaCleanupCandidate> findMediaCleanupCandidates(int minimumAgeHours) {
        return queryList(
            "SELECT id, input_image_object_key FROM ai_screening_attempts" +
            " WHERE status IN ('FAILED', 'REJECTED') AND input_image_object_key IS NOT NULL" +
            " AND completed_at < DATEADD(hour, -?, SYSUTCDATETIME())",
            rs -> new MediaCleanupCandidate(rs.getString("id"), rs.getString("input_image_object_key")),
            minimumAgeHours
        );
    }

    public List<String> failStuckProcessing(int timeoutMinutes) {
        return queryList(
            "UPDATE ai_screening_attempts SET status = 'FAILED', failure_code = 'PROCESSING_TIMEOUT'," +
            " completed_at = SYSUTCDATETIME()" +
            " OUTPUT INSERTED.id" +
            " WHERE status = 'PROCESSING' AND heartbeat_at < DATEADD(minute, -?, SYSUTCDATETIME())",
            rs -> rs.getString(1),
            timeoutMinutes
        );
    }

    public boolean failPending(String id, String failureCode) {
        return executeUpdate(
            "UPDATE ai_screening_attempts SET status = 'FAILED', failure_code = ?, completed_at = SYSUTCDATETIME()" +
            " WHERE id = ? AND status = 'PENDING'", failureCode, id
        );
    }

    public boolean complete(String id, String status, String failureCode, String reportId) {
        return executeUpdate(
            "UPDATE ai_screening_attempts SET status = ?, failure_code = ?, diagnosis_report_id = ?," +
            " completed_at = SYSUTCDATETIME(), heartbeat_at = SYSUTCDATETIME()" +
            " WHERE id = ? AND status = 'PROCESSING'", status, failureCode, reportId, id
        );
    }

    private static AiScreeningAttempt mapRow(ResultSet rs) throws SQLException {
        AiScreeningAttempt attempt = new AiScreeningAttempt();
        attempt.setId(rs.getString("id"));
        attempt.setIdempotencyKey(rs.getString("idempotency_key"));
        attempt.setPatientId(rs.getString("patient_id"));
        attempt.setRequestedByUserId(rs.getString("requested_by_user_id"));
        attempt.setStatus(rs.getString("status"));
        attempt.setFailureCode(rs.getString("failure_code"));
        attempt.setAiModelId(rs.getString("ai_model_id"));
        attempt.setInputSha256(rs.getString("input_sha256"));
        attempt.setInputImageObjectKey(rs.getString("input_image_object_key"));
        attempt.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) attempt.setCreatedAt(created.toLocalDateTime());
        return attempt;
    }

    public record MediaCleanupCandidate(String attemptId, String inputImageObjectKey) { }
}
