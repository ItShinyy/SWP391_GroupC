package com.dermathologyai.model;

import java.io.Serializable;

/** One HttpSession → one pending registration (replaces previous). */
public class PendingRegistration implements Serializable {
    private static final long serialVersionUID = 1L;
    public static final String SESSION_KEY = "pending_registration";
    public static final long TTL_MILLIS = 15 * 60 * 1000L;

    private String email;
    private String username;
    private String fullName;
    private String phone;
    private String passwordHash;
    private String otp;
    private int attempts;
    private long expiresAt;
    private long lastSentAt;

    public PendingRegistration(String email, String username, String fullName, String phone,
                               String passwordHash, String otp) {
        this.email = email;
        this.username = username;
        this.fullName = fullName;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.otp = otp;
        this.attempts = 0;
        long now = System.currentTimeMillis();
        this.expiresAt = now + TTL_MILLIS;
        this.lastSentAt = now;
    }

    public boolean isExpired() {
        return System.currentTimeMillis() > expiresAt;
    }

    public void incrementAttempts() {
        attempts++;
    }

    /** Resend: new OTP, attempts=0, TTL reset (no cooldown). */
    public void resetForResend(String newOtp) {
        this.otp = newOtp;
        this.attempts = 0;
        long now = System.currentTimeMillis();
        this.expiresAt = now + TTL_MILLIS;
        this.lastSentAt = now;
    }

    public String getEmail() { return email; }
    public String getUsername() { return username; }
    public String getFullName() { return fullName; }
    public String getPhone() { return phone; }
    public String getPasswordHash() { return passwordHash; }
    public String getOtp() { return otp; }
    public int getAttempts() { return attempts; }
    public long getExpiresAt() { return expiresAt; }
    public long getLastSentAt() { return lastSentAt; }
}
