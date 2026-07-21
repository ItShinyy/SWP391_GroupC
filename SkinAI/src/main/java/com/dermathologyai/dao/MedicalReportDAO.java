package com.dermathologyai.dao;

import com.dermathologyai.model.AppointmentPrescription;
import com.dermathologyai.model.MedicalReport;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class MedicalReportDAO extends DBContext {
    private static final String SELECT_COLUMNS =
            "SELECT mr.id, mr.appointment_id, a.patient_id, a.family_member_id, mr.doctor_id, " +
            "mr.diagnosis_report_id, mr.chief_complaint, mr.doctor_diagnosis, mr.treatment_plan, " +
            "mr.prescription_note, mr.follow_up_date, mr.status, mr.created_at, mr.updated_at, " +
            "a.appointment_time, du.full_name AS doctor_name, c.clinic_name, " +
            "fm.full_name AS family_member_name, fm.relationship, " +
            "(SELECT COUNT(*) FROM dbo.appointment_prescriptions ap " +
            " WHERE ap.appointment_id = mr.appointment_id) AS prescription_count " +
            "FROM dbo.medical_reports mr " +
            "INNER JOIN dbo.appointments a ON a.id = mr.appointment_id " +
            "INNER JOIN dbo.doctors d ON d.id = mr.doctor_id " +
            "INNER JOIN dbo.users du ON du.id = d.user_id " +
            "INNER JOIN dbo.clinics c ON c.id = a.clinic_id " +
            "LEFT JOIN dbo.family_members fm ON fm.id = a.family_member_id ";

    public List<MedicalReport> findForExaminedPerson(String patientId, String familyMemberId,
                                                      String search, LocalDate fromDate,
                                                      LocalDate toDate, String sort) {
        StringBuilder sql = new StringBuilder(SELECT_COLUMNS)
                .append("WHERE a.patient_id = ? ");
        List<Object> parameters = new ArrayList<>();
        parameters.add(patientId);

        if (familyMemberId == null) {
            sql.append("AND a.family_member_id IS NULL ");
        } else {
            sql.append("AND a.family_member_id = ? ");
            parameters.add(familyMemberId);
        }

        if (search != null && !search.isBlank()) {
            sql.append("AND (mr.doctor_diagnosis LIKE ? OR mr.chief_complaint LIKE ?) ");
            String term = "%" + search.trim() + "%";
            parameters.add(term);
            parameters.add(term);
        }
        if (fromDate != null) {
            sql.append("AND CAST(a.appointment_time AS DATE) >= ? ");
            parameters.add(Date.valueOf(fromDate));
        }
        if (toDate != null) {
            sql.append("AND CAST(a.appointment_time AS DATE) <= ? ");
            parameters.add(Date.valueOf(toDate));
        }

        sql.append("ORDER BY a.appointment_time ")
                .append("oldest".equalsIgnoreCase(sort) ? "ASC" : "DESC");
        return queryList(sql.toString(), MedicalReportDAO::mapReport, parameters.toArray());
    }

    public MedicalReport findByIdForPatient(String reportId, String patientId) {
        MedicalReport report = queryOne(SELECT_COLUMNS + "WHERE mr.id = ? AND a.patient_id = ?",
                MedicalReportDAO::mapReport, reportId, patientId);
        if (report != null) {
            report.setPrescriptions(findPrescriptionsByAppointmentId(report.getAppointmentId()));
        }
        return report;
    }

    public List<AppointmentPrescription> findPrescriptionsByAppointmentId(String appointmentId) {
        String sql = "SELECT id, appointment_id, drug_name, quantity, dosage, created_at, updated_at " +
                "FROM dbo.appointment_prescriptions WHERE appointment_id = ? ORDER BY created_at, drug_name";
        return queryList(sql, MedicalReportDAO::mapPrescription, appointmentId);
    }

    private static MedicalReport mapReport(ResultSet resultSet) throws SQLException {
        MedicalReport report = new MedicalReport();
        report.setId(resultSet.getString("id"));
        report.setAppointmentId(resultSet.getString("appointment_id"));
        report.setPatientId(resultSet.getString("patient_id"));
        report.setFamilyMemberId(resultSet.getString("family_member_id"));
        report.setDoctorId(resultSet.getString("doctor_id"));
        report.setDiagnosisReportId(resultSet.getString("diagnosis_report_id"));
        report.setChiefComplaint(resultSet.getString("chief_complaint"));
        report.setDoctorDiagnosis(resultSet.getString("doctor_diagnosis"));
        report.setTreatmentPlan(resultSet.getString("treatment_plan"));
        report.setPrescriptionNote(resultSet.getString("prescription_note"));
        Date followUpDate = resultSet.getDate("follow_up_date");
        if (followUpDate != null) report.setFollowUpDate(followUpDate.toLocalDate());
        report.setStatus(resultSet.getString("status"));
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) report.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) report.setUpdatedAt(updatedAt.toLocalDateTime());
        Timestamp appointmentTime = resultSet.getTimestamp("appointment_time");
        if (appointmentTime != null) report.setAppointmentTime(appointmentTime.toLocalDateTime());
        report.setDoctorName(resultSet.getString("doctor_name"));
        report.setClinicName(resultSet.getString("clinic_name"));
        report.setExaminedPersonName(resultSet.getString("family_member_name"));
        report.setRelationship(resultSet.getString("relationship"));
        report.setPrescriptionCount(resultSet.getInt("prescription_count"));
        return report;
    }

    private static AppointmentPrescription mapPrescription(ResultSet resultSet) throws SQLException {
        AppointmentPrescription prescription = new AppointmentPrescription();
        prescription.setId(resultSet.getString("id"));
        prescription.setAppointmentId(resultSet.getString("appointment_id"));
        prescription.setDrugName(resultSet.getString("drug_name"));
        prescription.setQuantity(resultSet.getInt("quantity"));
        prescription.setDosage(resultSet.getString("dosage"));
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) prescription.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) prescription.setUpdatedAt(updatedAt.toLocalDateTime());
        return prescription;
    }
}
