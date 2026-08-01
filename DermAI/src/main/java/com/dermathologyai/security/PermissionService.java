package com.dermathologyai.security;

import com.dermathologyai.model.User;

import java.util.EnumSet;
import java.util.Set;

/**
 * Keeps AI privileges separate from the legacy role column. Object-level checks,
 * such as the doctor-patient relationship, are performed by the caller.
 */
public final class PermissionService {
    private static final Set<Permission> DOCTOR_PERMISSIONS = EnumSet.of(
        Permission.AI_SCREENING_REVIEW,
        Permission.AI_SCREENING_OVERRIDE,
        Permission.AI_SCREENING_MEDIA_READ
    );
    private static final Set<Permission> ADMIN_PERMISSIONS = EnumSet.of(
        Permission.AI_CONFIG_MANAGE,
        Permission.AI_CLINICAL_POLICY_MANAGE,
        Permission.AI_AUDIT_READ
    );
    private static final Set<Permission> PATIENT_PERMISSIONS = EnumSet.of(
        Permission.AI_SCREENING_CREATE
    );

    private PermissionService() {
    }

    public static boolean has(User user, Permission permission) {
        if (user == null || !"ACTIVE".equals(user.getStatus()) || permission == null) {
            return false;
        }
        if (user.isDoctor()) return DOCTOR_PERMISSIONS.contains(permission);
        if (user.isAdmin()) return ADMIN_PERMISSIONS.contains(permission);
        if (user.isPatient()) return PATIENT_PERMISSIONS.contains(permission);
        return false;
    }
}
