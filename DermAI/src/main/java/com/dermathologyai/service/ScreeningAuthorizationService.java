package com.dermathologyai.service;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.security.Permission;
import com.dermathologyai.security.PermissionService;

/** Authorizes AI actions without expanding the legacy role column. */
public class ScreeningAuthorizationService {
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final PatientDAO patientDAO = new PatientDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    public Doctor requireAuthorizedDoctor(User user, String patientId, Permission permission) {
        if (!PermissionService.has(user, permission)) {
            return null;
        }
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null || !doctor.isActive() || !appointmentDAO.hasDoctorPatientRelationship(doctor.getId(), patientId)) {
            return null;
        }
        return doctor;
    }

    public Patient findPatientForUser(User user) {
        return user == null ? null : patientDAO.findByUserId(user.getId());
    }

    /** Patients may create an intake screening only for their own patient profile. */
    public Patient requireAuthorizedPatient(User user, Permission permission) {
        if (!PermissionService.has(user, permission)) {
            return null;
        }
        Patient patient = findPatientForUser(user);
        if (patient != null) {
            return patient;
        }
        // Heal Google/local accounts that never received a patients row.
        return new AuthService().ensurePatientProfile(user.getId());
    }
}
