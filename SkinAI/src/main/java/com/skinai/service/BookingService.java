package com.skinai.service;

import com.skinai.dal.AppointmentDAO;
import com.skinai.dal.DBContext;
import com.skinai.dal.PatientDAO;
import com.skinai.model.Appointment;
import com.skinai.model.Patient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;

public class BookingService {
    private static final Logger logger = LoggerFactory.getLogger(BookingService.class);
    private final AppointmentDAO appointmentDAO;
    private final PatientDAO patientDAO;

    public BookingService() {
        this.appointmentDAO = new AppointmentDAO();
        this.patientDAO = new PatientDAO();
    }

    /**
     * Creates an appointment atomically, ensuring that:
     * 1. The user has a valid PATIENT profile (Role = USER is fine, but Profile must exist).
     * 2. The operation is idempotent (blocks duplicate request_id).
     * 3. Wraps the creation in a manual JDBC transaction.
     */
    public String bookAppointment(String userId, Appointment appointment) throws Exception {
        if (appointment.getRequestId() == null || appointment.getRequestId().trim().isEmpty()) {
            throw new IllegalArgumentException("Idempotency key (request_id) is required.");
        }

        // 1. Service Layer Validation: Must have a Patient profile to book
        Patient patient = patientDAO.findByUserId(userId);
        if (patient == null) {
            throw new IllegalStateException("User does not have a complete patient profile. Cannot book.");
        }

        appointment.setPatientId(patient.getId());

        // 2. Atomic Transaction (ACID)
        Connection conn = null;
        try {
            conn = appointmentDAO.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Ensure idempotency constraint applies here.
            // If request_id already exists, this will throw an SQLException (Constraint Violation)
            String appointmentId = appointmentDAO.createWithConnection(conn, appointment);

            if (appointmentId == null) {
                throw new SQLException("Failed to insert appointment.");
            }

            conn.commit(); // Commit transaction
            return appointmentId;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on failure
                } catch (SQLException ex) {
                    logger.error("Error rolling back transaction", ex);
                }
            }
            
            // Check if it's a unique constraint violation for idempotency
            if (e.getMessage() != null && e.getMessage().contains("UQ_appointments_request_id")) {
                logger.warn("Duplicate booking request detected (Idempotency check passed). RequestId: {}", appointment.getRequestId());
                throw new IllegalStateException("Duplicate booking request. Please check your appointments list.");
            }
            
            logger.error("Database error during booking", e);
            throw new Exception("An error occurred while booking the appointment.", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    // Do NOT close the connection because it belongs to the DAO instance
                } catch (SQLException ex) {
                    logger.error("Error resetting auto-commit", ex);
                }
            }
        }
    }
}
