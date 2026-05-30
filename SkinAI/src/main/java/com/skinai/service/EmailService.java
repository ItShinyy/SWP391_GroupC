package com.skinai.service;

public interface EmailService {
    void sendPasswordResetEmail(String toEmail, String resetToken);
}
