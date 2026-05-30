package com.skinai.model;

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

    // Transient fields for display
    private String diseaseName;
    private String patientName;

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

    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

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
