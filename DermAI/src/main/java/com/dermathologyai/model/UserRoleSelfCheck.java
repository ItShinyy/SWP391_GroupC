package com.dermathologyai.model;

/**
 * ponytail: tiny self-check for User role helpers (run: java …UserRoleSelfCheck).
 * Ceiling: not a full unit suite — upgrade to JUnit if role matrix grows.
 */
public final class UserRoleSelfCheck {
    public static void main(String[] args) {
        User registered = new User();
        registered.assignRegisteredPatientRole();
        assertEq("PATIENT", registered.getRole());
        assertTrue(registered.isPatient());
        assertTrue(!registered.isDoctor());
        assertTrue(!registered.isAdmin());

        User legacy = new User();
        legacy.setRole("USER");
        assertTrue(legacy.isPatient());

        User doctor = new User();
        doctor.setRole("DOCTOR");
        assertTrue(doctor.isDoctor());
        assertTrue(!doctor.isPatient());

        System.out.println("UserRoleSelfCheck OK");
    }

    private static void assertEq(String expected, String actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("expected " + expected + " got " + actual);
        }
    }

    private static void assertTrue(boolean ok) {
        if (!ok) throw new AssertionError("assertion failed");
    }

    private UserRoleSelfCheck() {}
}
