package com.dermathologyai.notification;

import java.util.Properties;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MailService {
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(2);

    // Sử dụng máy chủ SMTP của Gmail
    private static final String SMTP_SERVER = "smtp.gmail.com";
    
    // Đọc thông tin từ properties
    private static String USERNAME = com.dermathologyai.config.AppConfig.get("mail.username"); 
    private static String PASSWORD = com.dermathologyai.config.AppConfig.get("mail.password");


    public static boolean sendMail(String to, String subject, String text) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_SERVER);
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props,
            new jakarta.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });

        try {
            MimeMessage message = new MimeMessage(session);
            // Email người gửi sẽ tự động lấy theo USERNAME
            message.setFrom(new InternetAddress(USERNAME)); 
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setContent(text, "text/html; charset=UTF-8"); // Gửi HTML thay vì plain text

            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void sendAsync(String to, String subject, String html) {
        EXECUTOR.submit(() -> {
            try {
                boolean success = sendMail(to, subject, html);
                if (!success) {
                    System.err.println("Failed to send email to " + to);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}
