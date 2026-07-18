package com.dermathologyai.model;

import java.time.LocalDateTime;

public class Feedback {
    private String id;
    private String patientId;
    private String appointmentId;
    private int rating; // 1-5 stars
    private String category;
    private String content;
    private LocalDateTime createdAt;
    private String status;
    private String adminReply;
    private LocalDateTime repliedAt;

    // Constructors
    public Feedback() {}

    public Feedback(String patientId, String appointmentId, int rating, String category, String content) {
        this.patientId = patientId;
        this.appointmentId = appointmentId;
        this.rating = rating;
        this.category = category;
        this.content = content;
        this.status = STATUS_PENDING;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPatientId() {
        return patientId;
    }

    public void setPatientId(String patientId) {
        this.patientId = patientId;
    }

    public String getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(String appointmentId) {
        this.appointmentId = appointmentId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminReply() {
        return adminReply;
    }

    public void setAdminReply(String adminReply) {
        this.adminReply = adminReply;
    }

    public LocalDateTime getRepliedAt() {
        return repliedAt;
    }

    public void setRepliedAt(LocalDateTime repliedAt) {
        this.repliedAt = repliedAt;
    }

    // Constants for status
    public static final String STATUS_PENDING = "Chưa xử lý";
    public static final String STATUS_PROCESSING = "Đang xử lý"; 
    public static final String STATUS_COMPLETED = "Đã xử lý";

    // Helper methods
    public boolean isPositiveRating() {
        return rating >= 4;
    }

    public boolean isNegativeRating() {
        return rating <= 2;
    }

    public String getRatingDescription() {
        switch (rating) {
            case 1: return "Rất không hài lòng";
            case 2: return "Không hài lòng";
            case 3: return "Bình thường";
            case 4: return "Hài lòng";
            case 5: return "Rất hài lòng";
            default: return "Chưa đánh giá";
        }
    }

    public boolean hasAdminReply() {
        return adminReply != null && !adminReply.trim().isEmpty();
    }

    @Override
    public String toString() {
        return "Feedback{" +
                "id='" + id + '\'' +
                ", patientId='" + patientId + '\'' +
                ", appointmentId='" + appointmentId + '\'' +
                ", rating=" + rating +
                ", category='" + category + '\'' +
                ", content='" + content + '\'' +
                ", createdAt=" + createdAt +
                ", status='" + status + '\'' +
                ", adminReply='" + adminReply + '\'' +
                ", repliedAt=" + repliedAt +
                '}';
    }
}