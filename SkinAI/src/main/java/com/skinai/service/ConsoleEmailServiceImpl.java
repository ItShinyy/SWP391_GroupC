package com.skinai.service;

import com.skinai.util.ConfigUtil;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

public class ConsoleEmailServiceImpl implements EmailService {
    private static final Logger logger = LoggerFactory.getLogger(ConsoleEmailServiceImpl.class);

    private Session getMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", ConfigUtil.get("mail.smtp.host"));
        props.put("mail.smtp.port", ConfigUtil.get("mail.smtp.port"));
        props.put("mail.smtp.auth", ConfigUtil.get("mail.smtp.auth"));
        props.put("mail.smtp.starttls.enable", ConfigUtil.get("mail.smtp.starttls"));

        String username = ConfigUtil.get("mail.smtp.username");
        String password = ConfigUtil.get("mail.smtp.password");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    @Override
    public void sendPasswordResetEmail(String toEmail, String otp) {
        try {
            Session session = getMailSession();
            String fromAddress = ConfigUtil.get("mail.from.address");
            String fromName = ConfigUtil.get("mail.from.name");

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromAddress, fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("SkinAI - Your Verification Code");
            message.setContent(
                "<div style='font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:24px;border:1px solid #e0e0e0;border-radius:12px'>"
                + "<h2 style='color:#2d7a4f;margin-bottom:8px'>SkinAI</h2>"
                + "<p style='color:#555'>Your verification code is:</p>"
                + "<div style='font-size:32px;font-weight:bold;letter-spacing:8px;text-align:center;padding:16px;background:#f5f5f5;border-radius:8px;margin:16px 0'>" + otp + "</div>"
                + "<p style='color:#888;font-size:13px'>This code expires in 5 minutes. If you did not request this, please ignore this email.</p>"
                + "</div>",
                "text/html; charset=UTF-8"
            );

            Transport.send(message);
            logger.info("OTP email sent successfully to {}", toEmail);
        } catch (Exception e) {
            logger.error("Failed to send OTP email to {}: {}", toEmail, e.getMessage(), e);
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
