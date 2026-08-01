package com.dermathologyai.model;

/** Patient-facing guidance keyed by disease_code (no versioning). */
public class ClinicalPolicyEntry {
    private String id;
    private String diseaseCode;
    private String displayName;
    private String riskLevel;
    private String recommendation;
    private String disclaimer;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getDiseaseCode() { return diseaseCode; }
    public void setDiseaseCode(String diseaseCode) { this.diseaseCode = diseaseCode; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }
    public String getDisclaimer() { return disclaimer; }
    public void setDisclaimer(String disclaimer) { this.disclaimer = disclaimer; }
}
