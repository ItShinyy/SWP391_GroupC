package com.skinai.service;

import com.skinai.mail.AsyncMailService;
import com.skinai.mail.MailTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ConsoleEmailServiceImpl implements EmailService {
    private static final Logger logger = LoggerFactory.getLogger(ConsoleEmailServiceImpl.class);

    @Override
    public void sendPasswordResetEmail(String toEmail, String otp) {
        try {
            String html = MailTemplate.buildOtpMail(otp, 5);
            AsyncMailService.sendAsync(toEmail, "SkinAI - Xác minh OTP", html);
            logger.info("OTP email sent asynchronously to {}", toEmail);
        } catch (Exception e) {
            logger.error("Failed to send OTP email asynchronously to {}: {}", toEmail, e.getMessage(), e);
        }
    }

    @Override
    public void sendSmsOTP(String phone, String otp) {
        // Real SMS integration (Twilio, etc.) would go here.
        // For now, log it clearly so developer can see it in console.
        logger.warn("=== SMS OTP (no SMS provider configured) ===");
        logger.warn("TO: {}  |  CODE: {}", phone, otp);
        logger.warn("=============================================");
        System.out.println(">>> [SMS OTP — no provider] To: " + phone + " | Code: " + otp);
    }
}
