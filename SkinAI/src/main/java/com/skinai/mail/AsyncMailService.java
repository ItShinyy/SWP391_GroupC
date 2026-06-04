package com.skinai.mail;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class AsyncMailService {
    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(2);

    public static void sendAsync(String to, String subject, String html) {
        EXECUTOR.submit(() -> {
            try {
                boolean success = com.skinai.utils.SendMail.sendMail(to, subject, html);
                if (!success) {
                    System.err.println("Failed to send email to " + to);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}
