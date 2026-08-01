package com.dermathologyai.util;

import java.util.regex.Pattern;

public class InputValidator {
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[^\\s]+$"); // No spaces allowed
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?[0-9]{9,15}$");
    private static final int PASSWORD_MIN_LENGTH = 8;
    private static final String PASSWORD_PATTERN_TEXT = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{" + PASSWORD_MIN_LENGTH + ",}$";
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(PASSWORD_PATTERN_TEXT);
    private static final String PASSWORD_REQUIREMENTS = "Tối thiểu 8 ký tự, có chữ hoa, chữ thường, số và một ký tự đặc biệt (@$!%*?&).";
    private static final String INVALID_PASSWORD_MESSAGE = "Mật khẩu không hợp lệ. " + PASSWORD_REQUIREMENTS;
    private static final String PASSWORD_MISMATCH_MESSAGE = "Mật khẩu xác nhận không khớp.";

    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    public static void requireValidPassword(String password) {
        if (!isValidPassword(password)) {
            throw new IllegalArgumentException(INVALID_PASSWORD_MESSAGE);
        }
    }

    public static void requireMatchingPasswords(String password, String confirmation) {
        if (password == null || !password.equals(confirmation)) {
            throw new IllegalArgumentException(PASSWORD_MISMATCH_MESSAGE);
        }
    }

    public static int getPasswordMinLength() {
        return PASSWORD_MIN_LENGTH;
    }

    public static String getPasswordPattern() {
        return PASSWORD_PATTERN_TEXT;
    }

    public static String getPasswordRequirements() {
        return PASSWORD_REQUIREMENTS;
    }

    public static String getInvalidPasswordMessage() {
        return INVALID_PASSWORD_MESSAGE;
    }

    public static String getPasswordMismatchMessage() {
        return PASSWORD_MISMATCH_MESSAGE;
    }

    /** Attach password policy attrs for register/reset/profile JSPs. */
    public static void applyPasswordPolicy(jakarta.servlet.http.HttpServletRequest req) {
        req.setAttribute("passwordMinLength", getPasswordMinLength());
        req.setAttribute("passwordPattern", getPasswordPattern());
        req.setAttribute("passwordRequirements", getPasswordRequirements());
        req.setAttribute("passwordMessage", getInvalidPasswordMessage());
        req.setAttribute("passwordMismatchMessage", getPasswordMismatchMessage());
    }

    public static void requireValidEmail(String email) {
        if (email == null || email.isBlank() || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
    }

    public static void requireValidPhone(String phone) {
        if (phone == null || phone.isBlank() || !PHONE_PATTERN.matcher(phone.trim()).matches()) {
            throw new IllegalArgumentException("Số điện thoại không hợp lệ.");
        }
    }

    public static void requireValidScheduleSlot(String slot) {
        if (slot == null) {
            throw new IllegalArgumentException("Khung giờ không hợp lệ.");
        }
        String normalized = slot.trim().toUpperCase();
        if (!normalized.equals("MORNING") && !normalized.equals("AFTERNOON") && !normalized.equals("EVENING")) {
            throw new IllegalArgumentException("Khung giờ không hợp lệ.");
        }
    }

    /**
     * Normalizes username: checks if it contains spaces.
     * Throws IllegalArgumentException if invalid.
     */
    public static String normalizeUsername(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username không được để trống.");
        }
        String u = username.trim();
        if (!USERNAME_PATTERN.matcher(u).matches()) {
            throw new IllegalArgumentException("Username không được chứa khoảng trắng.");
        }
        return u;
    }
}
