package com.dermathologyai.model;

import java.time.LocalDateTime;

/**
 * Represents a bug/error report submitted by a user.
 */
public class BugReport {
    private String id;
    private String userId;
    private String title;
    private String description;
    private String urlPath;
    private String status; // PENDING, RESOLVED, CLOSED
    private LocalDateTime createdAt;

    // Transient fields for display
    private String reporterName;
    private String reporterEmail;
    private String reporterRole;

    public BugReport() {
    }

    public BugReport(String id, String userId, String title, String description, String urlPath, String status) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.description = description;
        this.urlPath = urlPath;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getUrlPath() {
        return urlPath;
    }

    public void setUrlPath(String urlPath) {
        this.urlPath = urlPath;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getReporterName() {
        return reporterName;
    }

    public void setReporterName(String reporterName) {
        this.reporterName = reporterName;
    }

    public String getReporterEmail() {
        return reporterEmail;
    }

    public void setReporterEmail(String reporterEmail) {
        this.reporterEmail = reporterEmail;
    }

    public String getReporterRole() {
        return reporterRole;
    }

    public void setReporterRole(String reporterRole) {
        this.reporterRole = reporterRole;
    }
}
