package com.dermathologyai.service;

import com.dermathologyai.dao.MedicalReportDAO;
import com.dermathologyai.dao.PrescriptionDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.MedicalReport;
import com.dermathologyai.model.Prescription;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/** Medical report owner for completed visits. */
public class MedicalRecordService {
    /**
     * Business rule: doctors may only add/delete prescriptions while the visit is in progress.
     * CONFIRMED, COMPLETED, CANCELLED (and NO_SHOW/CREATED) are rejected by the backend.
     */
    private static final Set<String> ACTIVE_VISIT_STATUSES =
        Set.of("CHECKED_IN", "IN_PROGRESS");

    /** Appointment statuses that are locked (read-only) — COMPLETED, CANCELLED, NO_SHOW. */
    private static final Set<String> LOCKED_STATUSES =
        Set.of("COMPLETED", "CANCELLED", "NO_SHOW");

    private final MedicalReportDAO medicalReportDAO = new MedicalReportDAO();
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

    /** 
     * Single source of truth: Lock the page ONLY when status is COMPLETED, CANCELLED, or NO_SHOW. 
     */
    public boolean isLocked(Appointment appointment) {
        if (appointment == null || appointment.getStatus() == null) {
            return false;
        }
        String status = appointment.getStatus();
        return "COMPLETED".equals(status) || "CANCELLED".equals(status) || "NO_SHOW".equals(status);
    }

    public boolean isActiveVisit(Appointment appointment) {
        return appointment != null && !isLocked(appointment);
    }

    /** 
     * Prescriptions can be edited only after CHECKED_IN or during IN_PROGRESS, and before COMPLETED.
     */
    public boolean canEditPrescriptions(Appointment appointment) {
        if (appointment == null || appointment.getStatus() == null) {
            return false;
        }
        String status = appointment.getStatus();
        return "CHECKED_IN".equals(status) || "IN_PROGRESS".equals(status);
    }

    /** Treatment notes can be edited when NOT locked. */
    public boolean canEditTreatmentNotes(Appointment appointment) {
        return appointment != null && !isLocked(appointment);
    }

    /** Medical report can be edited and saved when NOT locked. */
    public boolean canFinalizeMedicalReport(Appointment appointment) {
        return appointment != null && !isLocked(appointment);
    }

    /** Appointment can be completed when NOT locked. */
    public boolean canCompleteAppointment(Appointment appointment) {
        return appointment != null && !isLocked(appointment);
    }

    /**
     * Adds a prescription only if the appointment is in an editable status.
     * Rejects when status is CONFIRMED, COMPLETED, CANCELLED, or any other non-editable state.
     *
     * @return true if created; false if the appointment status forbids editing or DAO failed
     */
    public boolean addPrescription(Appointment appointment, Prescription prescription) {
        if (!canEditPrescriptions(appointment) || prescription == null) {
            return false;
        }
        return prescriptionDAO.create(prescription);
    }

    /**
     * Deletes a prescription only if the appointment is in an editable status AND the
     * prescription actually belongs to that appointment (ownership check).
     *
     * @return true if deleted; false if status forbids editing, prescription is not found,
     *         does not belong to the appointment, or DAO failed
     */
    public boolean deletePrescription(Appointment appointment, String prescriptionId) {
        if (!canEditPrescriptions(appointment) || prescriptionId == null) {
            return false;
        }
        Prescription existing = prescriptionDAO.findById(prescriptionId);
        if (existing == null || !appointment.getId().equals(existing.getAppointmentId())) {
            return false;
        }
        return prescriptionDAO.delete(prescriptionId);
    }

    /** Read-only listing used by the UI (always allowed). */
    public List<Prescription> findPrescriptionsByAppointmentId(String appointmentId) {
        return prescriptionDAO.findByAppointmentId(appointmentId);
    }

    public MedicalReport ensureDraftFromAppointment(Appointment appointment) {
        if (appointment == null || appointment.getId() == null) return null;
        MedicalReport existing = medicalReportDAO.findByAppointmentId(appointment.getId());
        if (existing != null) return existing;

        String chief = blankTo(appointment.getNotes(), "Khám da liễu");
        String diagnosis = blankTo(appointment.getDoctorNotes(),
            blankTo(appointment.getDiseaseName(), "Chẩn đoán lâm sàng đang cập nhật"));
        String plan = "Theo hướng dẫn và đơn thuốc của bác sĩ.";
        String rxNote = buildPrescriptionNote(appointment.getId());

        String id = medicalReportDAO.createDraft(
            appointment.getId(),
            appointment.getDoctorId(),
            appointment.getDiagnosisReportId(),
            truncate(chief, 1000),
            truncate(diagnosis, 2000),
            truncate(plan, 2000),
            truncate(rxNote, 2000)
        );
        if (id == null) {
            return medicalReportDAO.findByAppointmentId(appointment.getId());
        }
        return medicalReportDAO.findByAppointmentId(appointment.getId());
    }

    public MedicalReport findByAppointmentId(String appointmentId) {
        return medicalReportDAO.findByAppointmentId(appointmentId);
    }

    /**
     * Finalizes a medical report only if the appointment is an active visit (CHECKED_IN / IN_PROGRESS).
     * COMPLETED, CANCELLED, CONFIRMED, etc. are rejected by the backend.
     */
    public boolean finalizeReport(Appointment appointment, String appointmentId, String chiefComplaint,
                                  String doctorDiagnosis, String treatmentPlan, String prescriptionNote,
                                  LocalDate followUpDate) {
        if (!canFinalizeMedicalReport(appointment) || appointmentId == null) return false;
        MedicalReport report = medicalReportDAO.findByAppointmentId(appointmentId);
        if (report == null) return false;
        return medicalReportDAO.finalizeReport(
            report.getId(),
            truncate(blankTo(chiefComplaint, blankTo(report.getChiefComplaint(), "Khám da liễu")), 1000),
            truncate(blankTo(doctorDiagnosis, blankTo(report.getDoctorDiagnosis(), "Chẩn đoán lâm sàng đang cập nhật")), 2000),
            truncate(blankTo(treatmentPlan, blankTo(report.getTreatmentPlan(), "Theo hướng dẫn và đơn thuốc của bác sĩ.")), 2000),
            truncate(prescriptionNote, 2000),
            followUpDate
        );
    }

    public int countByStatus(String status) {
        return medicalReportDAO.countByStatus(status);
    }

    private String buildPrescriptionNote(String appointmentId) {
        List<Prescription> list = prescriptionDAO.findByAppointmentId(appointmentId);
        if (list == null || list.isEmpty()) return null;
        return list.stream()
            .map(p -> p.getDrugName() + " x" + p.getQuantity() + " (" + p.getDosage() + ")")
            .collect(Collectors.joining("; "));
    }

    private static String blankTo(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private static String truncate(String value, int max) {
        if (value == null) return null;
        return value.length() <= max ? value : value.substring(0, max);
    }
}
