package com.dermathologyai.model;

import java.time.LocalDateTime;

public class AppointmentLabTest {
    private String id;
    private String appointmentId;
    private String testName;
    private String status; // PENDING, COMPLETED
    private String resultSummary;
    private String resultImageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public AppointmentLabTest() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }

    public String getTestName() { return testName; }
    public void setTestName(String testName) { this.testName = testName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getResultSummary() { return resultSummary; }
    public void setResultSummary(String resultSummary) { this.resultSummary = resultSummary; }

    public String getResultImageUrl() { return resultImageUrl; }
    public void setResultImageUrl(String resultImageUrl) { this.resultImageUrl = resultImageUrl; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getStatusDisplayName() {
        return "PENDING".equals(status) ? "Chờ kết quả" : "Đã có kết quả";
    }

    public boolean isPdf() {
        return resultImageUrl != null && resultImageUrl.toLowerCase().endsWith(".pdf");
    }
}
