package com.dermathologyai.model;

import java.time.LocalDateTime;

/**
 * Represents an appointment.
 */
public class Appointment {
    private String id;
    private String requestId;
    private String patientId;
    private String clinicId;
    private String diagnosisReportId;
    private String familyMemberId;
    private String slotId;
    private LocalDateTime appointmentTime;
    private String status; // CREATED, CONFIRMED, CHECKED_IN, COMPLETED, CANCELLED, NO_SHOW
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Doctor-related fields
    private String doctorId;
    private String doctorStatus;
    private String doctorNotes;

    // Transient fields for display
    private String doctorName;
    private String clinicName;
    private String patientName;
    private String patientEmail;
    private String patientPhone;
    private String patientGender;
    private String patientDob;
    private String patientAddress;
    private String diseaseName;
    private double confidenceScore;
    private String riskLevel;
    private String imageUrl;
    private String heatmapUrl;
    private String recommendation;

    public Appointment() {
    }

    public Appointment(String id, String requestId, String patientId, String clinicId, String diagnosisReportId, LocalDateTime appointmentTime, String status, String notes, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.requestId = requestId;
        this.patientId = patientId;
        this.clinicId = clinicId;
        this.diagnosisReportId = diagnosisReportId;
        this.appointmentTime = appointmentTime;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }

    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getClinicId() { return clinicId; }
    public void setClinicId(String clinicId) { this.clinicId = clinicId; }

    public String getDiagnosisReportId() { return diagnosisReportId; }
    public void setDiagnosisReportId(String diagnosisReportId) { this.diagnosisReportId = diagnosisReportId; }

    public String getFamilyMemberId() { return familyMemberId; }
    public void setFamilyMemberId(String familyMemberId) { this.familyMemberId = familyMemberId; }

    public String getSlotId() { return slotId; }
    public void setSlotId(String slotId) { this.slotId = slotId; }

    public LocalDateTime getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(LocalDateTime appointmentTime) { this.appointmentTime = appointmentTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getDoctorId() { return doctorId; }
    public void setDoctorId(String doctorId) { this.doctorId = doctorId; }

    public String getDoctorStatus() { return doctorStatus; }
    public void setDoctorStatus(String doctorStatus) { this.doctorStatus = doctorStatus; }

    public String getDoctorNotes() { return doctorNotes; }
    public void setDoctorNotes(String doctorNotes) { this.doctorNotes = doctorNotes; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientEmail() { return patientEmail; }
    public void setPatientEmail(String patientEmail) { this.patientEmail = patientEmail; }

    public String getPatientPhone() { return patientPhone; }
    public void setPatientPhone(String patientPhone) { this.patientPhone = patientPhone; }

    public String getPatientGender() { return patientGender; }
    public void setPatientGender(String patientGender) { this.patientGender = patientGender; }

    public String getPatientDob() { return patientDob; }
    public void setPatientDob(String patientDob) { this.patientDob = patientDob; }

    public String getPatientDobFormatted() {
        if (patientDob == null || patientDob.isBlank()) return "N/A";
        java.time.LocalDate parsed = com.dermathologyai.util.FormatUtil.parseDate(patientDob.trim());
        return parsed != null ? com.dermathologyai.util.FormatUtil.formatDate(parsed) : patientDob;
    }

    public String getPatientAddress() { return patientAddress; }
    public void setPatientAddress(String patientAddress) { this.patientAddress = patientAddress; }

    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }

    public double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getHeatmapUrl() { return heatmapUrl; }
    public void setHeatmapUrl(String heatmapUrl) { this.heatmapUrl = heatmapUrl; }

    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }

    public String getAppointmentTimeFormatted() {
        if (appointmentTime == null) return "";
        return appointmentTime.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getAppointmentDateFormatted() {
        if (appointmentTime == null) return "";
        return appointmentTime.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public String getAppointmentTimeOnlyFormatted() {
        if (appointmentTime == null) return "";
        return appointmentTime.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
    }

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getCreatedDateFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public String getCreatedTimeOnlyFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
    }

    @Override
    public String toString() {
        return "Appointment{" +
                "id='" + id + '\'' +
                ", patientId='" + patientId + '\'' +
                ", clinicId='" + clinicId + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
