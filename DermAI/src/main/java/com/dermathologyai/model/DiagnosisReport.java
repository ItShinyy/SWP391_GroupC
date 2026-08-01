package com.dermathologyai.model;

import java.time.LocalDateTime;

/**
 * Represents an AI diagnosis report.
 */
public class DiagnosisReport {
    private String id;
    private String patientId;
    private String diseaseId;
    private String clinicId;
    private String imageUrl;
    private String heatmapUrl;
    private double confidenceScore;
    private String riskLevel; // LOW, MEDIUM, HIGH
    private String recommendation;
    private String modelVersion;
    private LocalDateTime createdAt;
    private String aiScreeningAttemptId;
    private String inputImageObjectKey;
    private String eigencamObjectKey;
    private String aiSuggestedDiseaseId;
    private String doctorReviewStatus;
    private String reviewedByDoctorId;
    private LocalDateTime reviewedAt;
    private String doctorSelectedDiseaseId;
    private String overrideReason;
    private String doctorNote;
    private String patientGuidance;
    private String patientVisibilityStatus;

    // Transient fields for display
    private String diseaseName;
    private String patientName;
    private String patientEmail;
    private String patientPhone;

    public DiagnosisReport() {
    }

    public DiagnosisReport(String id, String patientId, String diseaseId, String clinicId, String imageUrl, String heatmapUrl, double confidenceScore, String riskLevel, String recommendation, String modelVersion, LocalDateTime createdAt) {
        this.id = id;
        this.patientId = patientId;
        this.diseaseId = diseaseId;
        this.clinicId = clinicId;
        this.imageUrl = imageUrl;
        this.heatmapUrl = heatmapUrl;
        this.confidenceScore = confidenceScore;
        this.riskLevel = riskLevel;
        this.recommendation = recommendation;
        this.modelVersion = modelVersion;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getDiseaseId() { return diseaseId; }
    public void setDiseaseId(String diseaseId) { this.diseaseId = diseaseId; }

    public String getClinicId() { return clinicId; }
    public void setClinicId(String clinicId) { this.clinicId = clinicId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getHeatmapUrl() { return heatmapUrl; }
    public void setHeatmapUrl(String heatmapUrl) { this.heatmapUrl = heatmapUrl; }

    public double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }

    public String getModelVersion() { return modelVersion; }
    public void setModelVersion(String modelVersion) { this.modelVersion = modelVersion; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getAiScreeningAttemptId() { return aiScreeningAttemptId; }
    public void setAiScreeningAttemptId(String aiScreeningAttemptId) { this.aiScreeningAttemptId = aiScreeningAttemptId; }
    public String getInputImageObjectKey() { return inputImageObjectKey; }
    public void setInputImageObjectKey(String inputImageObjectKey) { this.inputImageObjectKey = inputImageObjectKey; }
    public String getEigencamObjectKey() { return eigencamObjectKey; }
    public void setEigencamObjectKey(String eigencamObjectKey) { this.eigencamObjectKey = eigencamObjectKey; }
    public String getAiSuggestedDiseaseId() { return aiSuggestedDiseaseId; }
    public void setAiSuggestedDiseaseId(String aiSuggestedDiseaseId) { this.aiSuggestedDiseaseId = aiSuggestedDiseaseId; }
    public String getDoctorReviewStatus() { return doctorReviewStatus; }
    public void setDoctorReviewStatus(String doctorReviewStatus) { this.doctorReviewStatus = doctorReviewStatus; }
    public String getReviewedByDoctorId() { return reviewedByDoctorId; }
    public void setReviewedByDoctorId(String reviewedByDoctorId) { this.reviewedByDoctorId = reviewedByDoctorId; }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }
    public String getDoctorSelectedDiseaseId() { return doctorSelectedDiseaseId; }
    public void setDoctorSelectedDiseaseId(String doctorSelectedDiseaseId) { this.doctorSelectedDiseaseId = doctorSelectedDiseaseId; }
    public String getOverrideReason() { return overrideReason; }
    public void setOverrideReason(String overrideReason) { this.overrideReason = overrideReason; }
    public String getDoctorNote() { return doctorNote; }
    public void setDoctorNote(String doctorNote) { this.doctorNote = doctorNote; }
    public String getPatientGuidance() { return patientGuidance; }
    public void setPatientGuidance(String patientGuidance) { this.patientGuidance = patientGuidance; }
    public String getPatientVisibilityStatus() { return patientVisibilityStatus; }
    public void setPatientVisibilityStatus(String patientVisibilityStatus) { this.patientVisibilityStatus = patientVisibilityStatus; }

    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientEmail() { return patientEmail; }
    public void setPatientEmail(String patientEmail) { this.patientEmail = patientEmail; }

    public String getPatientPhone() { return patientPhone; }
    public void setPatientPhone(String patientPhone) { this.patientPhone = patientPhone; }

    public String getCreatedAtDisplay() {
        return createdAt == null ? "" : createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getReviewedAtDisplay() {
        return reviewedAt == null ? "" : reviewedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    @Override
    public String toString() {
        return "DiagnosisReport{" +
                "id='" + id + '\'' +
                ", patientId='" + patientId + '\'' +
                ", diseaseId='" + diseaseId + '\'' +
                ", riskLevel='" + riskLevel + '\'' +
                '}';
    }
}
