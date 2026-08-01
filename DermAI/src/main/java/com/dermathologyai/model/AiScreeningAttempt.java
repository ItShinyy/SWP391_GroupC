package com.dermathologyai.model;

import java.time.LocalDateTime;

public class AiScreeningAttempt {
    private String id;
    private String idempotencyKey;
    private String patientId;
    private String requestedByUserId;
    private String status;
    private String failureCode;
    private String aiModelId;
    private String inputSha256;
    private String inputImageObjectKey;
    private String diagnosisReportId;
    private LocalDateTime createdAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdempotencyKey() { return idempotencyKey; }
    public void setIdempotencyKey(String idempotencyKey) { this.idempotencyKey = idempotencyKey; }
    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }
    public String getRequestedByUserId() { return requestedByUserId; }
    public void setRequestedByUserId(String requestedByUserId) { this.requestedByUserId = requestedByUserId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getFailureCode() { return failureCode; }
    public void setFailureCode(String failureCode) { this.failureCode = failureCode; }
    public String getAiModelId() { return aiModelId; }
    public void setAiModelId(String aiModelId) { this.aiModelId = aiModelId; }
    public String getInputSha256() { return inputSha256; }
    public void setInputSha256(String inputSha256) { this.inputSha256 = inputSha256; }
    public String getInputImageObjectKey() { return inputImageObjectKey; }
    public void setInputImageObjectKey(String inputImageObjectKey) { this.inputImageObjectKey = inputImageObjectKey; }
    public String getDiagnosisReportId() { return diagnosisReportId; }
    public void setDiagnosisReportId(String diagnosisReportId) { this.diagnosisReportId = diagnosisReportId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
