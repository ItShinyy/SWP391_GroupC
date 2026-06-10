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
    private LocalDateTime appointmentTime;
    private String status; // CREATED, CONFIRMED, CHECKED_IN, COMPLETED, CANCELLED, NO_SHOW
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Transient fields for display
    private String clinicName;

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

    public LocalDateTime getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(LocalDateTime appointmentTime) { this.appointmentTime = appointmentTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

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
