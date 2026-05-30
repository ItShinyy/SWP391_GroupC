package com.skinai.model;

import java.time.LocalDateTime;

/**
 * Represents a skin disease.
 */
public class Disease {
    private String id;
    private String diseaseName;
    private String diseaseCode;
    private String description;
    private String symptoms;
    private String severityLevel; // LOW, MEDIUM, HIGH
    private String recommendedSpecialty;
    private LocalDateTime createdAt;

    public Disease() {
    }

    public Disease(String id, String diseaseName, String diseaseCode, String description, String symptoms, String severityLevel, String recommendedSpecialty, LocalDateTime createdAt) {
        this.id = id;
        this.diseaseName = diseaseName;
        this.diseaseCode = diseaseCode;
        this.description = description;
        this.symptoms = symptoms;
        this.severityLevel = severityLevel;
        this.recommendedSpecialty = recommendedSpecialty;
        this.createdAt = createdAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }

    public String getDiseaseCode() { return diseaseCode; }
    public void setDiseaseCode(String diseaseCode) { this.diseaseCode = diseaseCode; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getSeverityLevel() { return severityLevel; }
    public void setSeverityLevel(String severityLevel) { this.severityLevel = severityLevel; }

    public String getRecommendedSpecialty() { return recommendedSpecialty; }
    public void setRecommendedSpecialty(String recommendedSpecialty) { this.recommendedSpecialty = recommendedSpecialty; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Disease{" +
                "id='" + id + '\'' +
                ", diseaseName='" + diseaseName + '\'' +
                ", diseaseCode='" + diseaseCode + '\'' +
                '}';
    }
}
