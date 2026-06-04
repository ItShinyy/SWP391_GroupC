package com.skinai.utils;

import java.util.Properties;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class SendMail {
    // Sử dụng máy chủ SMTP của Gmail
    private static final String SMTP_SERVER = "smtp.gmail.com";
    
    // ĐIỀN ĐỊA CHỈ GMAIL CỦA BẠN VÀO ĐÂY
    private static final String USERNAME = "phongtd2006@gmail.com"; 
    
    // ĐIỀN MẬT KHẨU ỨNG DỤNG (APP PASSWORD) CỦA GMAIL VÀO ĐÂY
    // Lưu ý: KHÔNG dùng mật khẩu đăng nhập bình thường. Bạn phải vào tài khoản Google -> Bảo mật -> Xác minh 2 bước -> Tạo Mật khẩu ứng dụng (App passwords).
    private static final String PASSWORD = "dokg sdxw rkbf aayf";

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
            Message message = new MimeMessage(session);
            // Email người gửi sẽ tự động lấy theo USERNAME
            message.setFrom(new InternetAddress(USERNAME)); 
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(text, "text/html; charset=UTF-8"); // Gửi HTML thay vì plain text

            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}
