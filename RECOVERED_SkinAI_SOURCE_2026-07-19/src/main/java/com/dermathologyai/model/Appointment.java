package com.dermathologyai.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

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
    private String attendanceStatus; // VISITED, NOT_VISITED, NO_SHOW, CANCELLED
    private String doctorStatus; // PENDING, ACCEPTED, REJECTED
    private String doctorNotes; // Doctor's notes
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Transient fields for display
    private String clinicName;
    private String doctorId;
    private String slotId;

    // Transient fields cho hiển thị bệnh nhân và kết quả chẩn đoán (join từ bảng khác)
    private String patientName;
    private String patientPhone;
    private String diseaseName;
    private double confidenceScore;
    private String riskLevel;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    public Appointment() {
    }

    public Appointment(String id, String requestId, String patientId, String clinicId, String diagnosisReportId,
                       LocalDateTime appointmentTime, String status, String notes,
                       LocalDateTime createdAt, LocalDateTime updatedAt) {
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

    // ─── Core getters/setters ─────────────────────────────────────────────────

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

    public String getAttendanceStatus() { return attendanceStatus; }
    public void setAttendanceStatus(String attendanceStatus) { this.attendanceStatus = attendanceStatus; }

    public String getDoctorStatus() { return doctorStatus; }
    public void setDoctorStatus(String doctorStatus) { this.doctorStatus = doctorStatus; }

    public String getDoctorNotes() { return doctorNotes; }
    public void setDoctorNotes(String doctorNotes) { this.doctorNotes = doctorNotes; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getDoctorId() { return doctorId; }
    public void setDoctorId(String doctorId) { this.doctorId = doctorId; }

    public String getSlotId() { return slotId; }
    public void setSlotId(String slotId) { this.slotId = slotId; }

    // ─── Transient display fields (patient info & diagnosis) ──────────────────

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientPhone() { return patientPhone; }
    public void setPatientPhone(String patientPhone) { this.patientPhone = patientPhone; }

    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }

    public double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    // ─── Formatted date helpers dùng trong JSP ────────────────────────────────

    /** Trả về ngày đặt lịch theo định dạng dd/MM/yyyy */
    public String getCreatedDateFormatted() {
        if (createdAt == null) return "N/A";
        return createdAt.format(DATE_FORMATTER);
    }

    /** Trả về giờ đặt lịch theo định dạng HH:mm */
    public String getCreatedTimeOnlyFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(TIME_FORMATTER);
    }

    /** Trả về ngày hẹn khám theo định dạng dd/MM/yyyy */
    public String getAppointmentDateFormatted() {
        if (appointmentTime == null) return "N/A";
        return appointmentTime.format(DATE_FORMATTER);
    }

    /** Trả về giờ hẹn khám theo định dạng HH:mm */
    public String getAppointmentTimeOnlyFormatted() {
        if (appointmentTime == null) return "";
        return appointmentTime.format(TIME_FORMATTER);
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
