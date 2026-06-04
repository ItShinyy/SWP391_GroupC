package com.skinai.util;

import java.util.regex.Pattern;

public class IdentityNormalizer {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0)[3|5|7|8|9][0-9]{8}$");
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[^\\s]+$"); // No spaces allowed

    /**
     * Normalizes email: trim and lowercase.
     * Returns null if input is null or blank.
     */
    public static String normalizeEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        return email.trim().toLowerCase();
    }

    /**
     * Normalizes phone: checks if it matches the VN phone pattern.
     * Throws IllegalArgumentException if invalid.
     */
    public static String normalizePhone(String phone) {
        if (phone == null || phone.isBlank()) {
            return null;
        }
        String p = phone.trim();
        if (!PHONE_PATTERN.matcher(p).matches()) {
            throw new IllegalArgumentException("Số điện thoại không hợp lệ. Phải bắt đầu bằng 0 và có 10 chữ số.");
        }
        return p;
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
