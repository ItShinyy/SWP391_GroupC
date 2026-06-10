package com.dermathologyai.service;

public class AIService {
    public AIResult predict(String imageUrl) {
        AIResult result = new AIResult();
        result.setHeatmapUrl(imageUrl);
        result.setConfidence(95.5);
        result.setRiskLevel("HIGH");
        result.setRecommendation("Cần khám bác sĩ ngay.");
        result.setDiseaseCode("MEL");
        return result;
    }

    public static class AIResult {
        private String heatmapUrl;
        private double confidence;
        private String riskLevel;
        private String recommendation;
        private String diseaseCode;

        public String getHeatmapUrl() { return heatmapUrl; }
        public void setHeatmapUrl(String heatmapUrl) { this.heatmapUrl = heatmapUrl; }
        public double getConfidence() { return confidence; }
        public void setConfidence(double confidence) { this.confidence = confidence; }
        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
        public String getRecommendation() { return recommendation; }
        public void setRecommendation(String recommendation) { this.recommendation = recommendation; }
        public String getDiseaseCode() { return diseaseCode; }
        public void setDiseaseCode(String diseaseCode) { this.diseaseCode = diseaseCode; }
    }
}
