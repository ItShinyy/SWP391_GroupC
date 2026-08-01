package com.dermathologyai.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class MedicalReport {
    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private String id;
    private String appointmentId;
    private String patientId;
    private String familyMemberId;
    private String doctorId;
    private String diagnosisReportId;
    private String chiefComplaint;
    private String doctorDiagnosis;
    private String treatmentPlan;
    private String prescriptionNote;
    private LocalDate followUpDate;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime appointmentTime;
    private String doctorName;
    private String clinicName;
    private String examinedPersonName;
    private String relationship;
    private int prescriptionCount;
    private List<AppointmentPrescription> prescriptions = new ArrayList<>();

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }
    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }
    public String getFamilyMemberId() { return familyMemberId; }
    public void setFamilyMemberId(String familyMemberId) { this.familyMemberId = familyMemberId; }
    public String getDoctorId() { return doctorId; }
    public void setDoctorId(String doctorId) { this.doctorId = doctorId; }
    public String getDiagnosisReportId() { return diagnosisReportId; }
    public void setDiagnosisReportId(String diagnosisReportId) { this.diagnosisReportId = diagnosisReportId; }
    public String getChiefComplaint() { return chiefComplaint; }
    public void setChiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; }
    public String getDoctorDiagnosis() { return doctorDiagnosis; }
    public void setDoctorDiagnosis(String doctorDiagnosis) { this.doctorDiagnosis = doctorDiagnosis; }
    public String getTreatmentPlan() { return treatmentPlan; }
    public void setTreatmentPlan(String treatmentPlan) { this.treatmentPlan = treatmentPlan; }
    public String getPrescriptionNote() { return prescriptionNote; }
    public void setPrescriptionNote(String prescriptionNote) { this.prescriptionNote = prescriptionNote; }
    public LocalDate getFollowUpDate() { return followUpDate; }
    public void setFollowUpDate(LocalDate followUpDate) { this.followUpDate = followUpDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public LocalDateTime getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(LocalDateTime appointmentTime) { this.appointmentTime = appointmentTime; }
    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }
    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }
    public String getExaminedPersonName() { return examinedPersonName; }
    public void setExaminedPersonName(String examinedPersonName) { this.examinedPersonName = examinedPersonName; }
    public String getRelationship() { return relationship; }
    public void setRelationship(String relationship) { this.relationship = relationship; }
    public int getPrescriptionCount() { return prescriptionCount; }
    public void setPrescriptionCount(int prescriptionCount) { this.prescriptionCount = prescriptionCount; }
    public List<AppointmentPrescription> getPrescriptions() { return prescriptions; }
    public void setPrescriptions(List<AppointmentPrescription> prescriptions) {
        this.prescriptions = prescriptions != null ? prescriptions : new ArrayList<>();
    }

    public String getShortId() {
        return id == null ? "" : id.substring(0, Math.min(8, id.length())).toUpperCase();
    }

    public String getAppointmentTimeDisplay() {
        return appointmentTime == null ? "—" : appointmentTime.format(DATE_TIME_FORMAT);
    }

    public String getFollowUpDateDisplay() {
        return followUpDate == null ? "Không yêu cầu" : followUpDate.format(DATE_FORMAT);
    }

    /** Empty when unset — for form input value (never "Không yêu cầu"). */
    public String getFollowUpDateDisplayForInput() {
        return followUpDate == null ? "" : followUpDate.format(DATE_FORMAT);
    }

    public String getCreatedAtDisplay() {
        return createdAt == null ? "—" : createdAt.format(DATE_TIME_FORMAT);
    }
}