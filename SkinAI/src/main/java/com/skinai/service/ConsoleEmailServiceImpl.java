package com.skinai.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ConsoleEmailServiceImpl implements EmailService {
    private static final Logger logger = LoggerFactory.getLogger(ConsoleEmailServiceImpl.class);

    @Override
    public void sendPasswordResetEmail(String toEmail, String resetToken) {
        logger.info("\n=======================================================");
        logger.info("MOCK EMAIL SENT TO: {}", toEmail);
        logger.info("SUBJECT: SkinAI - Reset Your Password");
        logger.info("BODY: Your password reset token is: {}", resetToken);
        logger.info("Please enter this token on the reset password page.");
        logger.info("=======================================================\n");
        
        // Also print to System.out just in case logger is not configured properly in dev
        System.out.println(">>> [MOCK EMAIL] Password Reset Token for " + toEmail + ": " + resetToken);
    }
}
