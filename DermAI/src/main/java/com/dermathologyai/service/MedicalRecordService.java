package com.dermathologyai.service;

import com.dermathologyai.dao.MedicalReportDAO;
import com.dermathologyai.dao.PrescriptionDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.MedicalReport;
import com.dermathologyai.model.Prescription;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

/** Medical report owner for completed visits. */
public class MedicalRecordService {
    private final MedicalReportDAO medicalReportDAO = new MedicalReportDAO();
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

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

    public boolean finalizeReport(String appointmentId, String chiefComplaint, String doctorDiagnosis,
                                  String treatmentPlan, String prescriptionNote, LocalDate followUpDate) {
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
