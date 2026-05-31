package com.skinai.model;

import java.time.LocalDateTime;

public class PasswordResetToken {
    private int id;
    private String userId;
    private String token;
    private String purpose;
    private int attempts;
    private LocalDateTime expiresAt;

    public PasswordResetToken() {}

    public PasswordResetToken(String userId, String token, String purpose, LocalDateTime expiresAt) {
        this.userId = userId;
        this.token = token;
        this.purpose = purpose;
        this.attempts = 0;
        this.expiresAt = expiresAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
}
