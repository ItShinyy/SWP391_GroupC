package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.dao.FamilyMemberDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.FamilyMember;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.util.InputValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Owns patient appointment creation with schedule validation. */
public class BookingService {
    private static final Logger logger = LoggerFactory.getLogger(BookingService.class);

    private final AppointmentDAO appointmentDAO;
    private final PatientDAO patientDAO;
    private final DiagnosisReportDAO diagnosisReportDAO;
    private final DoctorDAO doctorDAO;
    private final DoctorScheduleDAO scheduleDAO;
    private final UserDAO userDAO;
    private final FamilyMemberDAO familyMemberDAO;
    private final AuditService auditService;

    public BookingService() {
        this.appointmentDAO = new AppointmentDAO();
        this.patientDAO = new PatientDAO();
        this.diagnosisReportDAO = new DiagnosisReportDAO();
        this.doctorDAO = new DoctorDAO();
        this.scheduleDAO = new DoctorScheduleDAO();
        this.userDAO = new UserDAO();
        this.familyMemberDAO = new FamilyMemberDAO();
        this.auditService = new AuditService();
    }

    public String bookAppointment(String userId, Appointment appointment, String doctorId, String slot,
                                  String ipAddress, String userAgent) {
        if (appointment.getRequestId() == null || appointment.getRequestId().trim().isEmpty()) {
            throw new IllegalArgumentException("Idempotency key (request_id) is required.");
        }
        if (doctorId == null || doctorId.isBlank() || slot == null || slot.isBlank()) {
            throw new IllegalArgumentException("Doctor and schedule slot are required.");
        }
        String normalizedSlot = slot.trim().toUpperCase();
        InputValidator.requireValidScheduleSlot(normalizedSlot);

        Patient patient = patientDAO.findByUserId(userId);
        if (patient == null) {
            patient = new AuthService().ensurePatientProfile(userId);
        }
        if (patient == null) {
            throw new IllegalStateException("User does not have a complete patient profile. Cannot book.");
        }
        appointment.setPatientId(patient.getId());

        Doctor doctor = doctorDAO.findById(doctorId.trim());
        if (doctor == null || !doctor.isActive()) {
            throw new IllegalArgumentException("Selected doctor is unavailable.");
        }
        if (doctor.getClinicId() == null || !doctor.getClinicId().equals(appointment.getClinicId())) {
            throw new IllegalArgumentException("Selected doctor does not belong to this clinic.");
        }

        if (appointment.getNotes() != null && appointment.getNotes().length() > 1000) {
            appointment.setNotes(appointment.getNotes().substring(0, 1000));
        }

        if (appointment.getAppointmentTime() == null) {
            throw new IllegalArgumentException("Appointment date is required.");
        }
        LocalDate scheduleDate = appointment.getAppointmentTime().toLocalDate();
        if (scheduleDate.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("Cannot book a past date.");
        }

        DoctorSchedule schedule = scheduleDAO.findByDoctorDateAndSlot(doctor.getId(), scheduleDate, normalizedSlot);
        if (schedule == null || !schedule.isAvailable() || schedule.getBookedCount() >= schedule.getMaxPatients()) {
            throw new IllegalStateException("Selected slot is not available. Choose another time.");
        }

        appointment.setAppointmentTime(LocalDateTime.of(scheduleDate, slotStartTime(normalizedSlot)));
        if (appointmentDAO.existsActiveForPatientAtTime(patient.getId(), appointment.getAppointmentTime())) {
            throw new IllegalStateException(
                "You already have an appointment at this date and time. Choose another day or time slot.");
        }
        appointment.setDoctorId(doctor.getId());
        appointment.setSlotId(schedule.getId());
        appointment.setDoctorStatus("PENDING");
        appointment.setStatus("CONFIRMED");

        User account = userDAO.findById(userId);
        FamilyMember familyMember = null;
        if (appointment.getFamilyMemberId() != null && !appointment.getFamilyMemberId().isBlank()) {
            familyMember = familyMemberDAO.findByIdAndOwnerUserId(appointment.getFamilyMemberId(), userId);
            if (familyMember == null) {
                throw new IllegalArgumentException("Selected family member is invalid.");
            }
            appointment.setPatientName(familyMember.getFullName());
            if (familyMember.getDateOfBirth() != null) {
                appointment.setPatientDob(familyMember.getDateOfBirth().toString());
            }
            appointment.setPatientGender(familyMember.getGender());
        } else {
            appointment.setFamilyMemberId(null);
            if (account != null) {
                appointment.setPatientName(account.getFullName());
            }
            if (patient.getDob() != null) {
                appointment.setPatientDob(patient.getDob().toString());
            }
            appointment.setPatientGender(patient.getGender());
        }
        if (appointment.getDiagnosisReportId() != null && !appointment.getDiagnosisReportId().isBlank()) {
            DiagnosisReport report = diagnosisReportDAO.findById(appointment.getDiagnosisReportId());
            if (report == null || !patient.getId().equals(report.getPatientId()) ||
                report.getAiScreeningAttemptId() == null ||
                !"PENDING_DOCTOR_REVIEW".equals(report.getDoctorReviewStatus())) {
                throw new IllegalArgumentException("The selected screening is not available for this appointment.");
            }
        }

        Connection conn = null;
        try {
            conn = appointmentDAO.getConnection();
            conn.setAutoCommit(false);

            if (!scheduleDAO.incrementBookedCountWithConnection(conn, schedule.getId())) {
                throw new IllegalStateException("Selected slot was just filled. Choose another time.");
            }

            String appointmentId = appointmentDAO.createWithConnection(conn, appointment);
            if (appointmentId == null) {
                throw new SQLException("Failed to insert appointment.");
            }

            conn.commit();
            auditService.log(userId, "PATIENT_BOOK_APPOINTMENT", "appointments", appointmentId,
                null, "{\"doctorId\":\"" + doctor.getId() + "\",\"slot\":\"" + normalizedSlot + "\"}",
                null, ipAddress, userAgent);
            return appointmentId;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {
                    logger.error("Error rolling back booking transaction", ex);
                }
            }
            String sqlMessage = e.getMessage() == null ? "" : e.getMessage();
            if (sqlMessage.contains("UQ_appointments_request_id")) {
                throw new IllegalStateException("Duplicate booking request. Please check your appointments list.");
            }
            if (sqlMessage.contains("UQ_appointments_patient_time")) {
                throw new IllegalStateException(
                    "You already have an appointment at this date and time. Choose another day or time slot.");
            }
            logger.error("Database error during booking", e);
            throw new IllegalStateException("Could not complete booking. Please try again or choose another slot.", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public static LocalTime slotStartTime(String slot) {
        String key = switch (slot) {
            case "MORNING" -> "booking.slot.morning";
            case "AFTERNOON" -> "booking.slot.afternoon";
            case "EVENING" -> "booking.slot.evening";
            default -> throw new IllegalArgumentException("Invalid slot");
        };
        String raw = AppConfig.get(key, switch (slot) {
            case "MORNING" -> "09:00";
            case "AFTERNOON" -> "14:00";
            default -> "18:00";
        });
        return LocalTime.parse(raw.trim());
    }
}
