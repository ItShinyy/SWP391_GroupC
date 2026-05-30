package com.skinai.model;

import java.time.LocalDateTime;

public class PasswordResetToken {
    private int id;
    private String userId;
    private String token;
    private LocalDateTime expiresAt;

    public PasswordResetToken() {}

    public PasswordResetToken(String userId, String token, LocalDateTime expiresAt) {
        this.userId = userId;
        this.token = token;
        this.expiresAt = expiresAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
}
