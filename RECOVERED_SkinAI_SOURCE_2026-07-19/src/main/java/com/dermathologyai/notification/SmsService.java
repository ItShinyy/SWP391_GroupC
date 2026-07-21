package com.dermathologyai.notification;

public class SmsService {
    public static boolean sendSms(String phone, String text) {
        System.out.println("DEBUG - Sending SMS to " + phone + ": " + text);
        return true;
    }
}
