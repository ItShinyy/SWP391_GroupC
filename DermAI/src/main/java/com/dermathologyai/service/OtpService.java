package com.dermathologyai.service;

import org.mindrot.jbcrypt.BCrypt;
import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import com.dermathologyai.notification.MailTemplate;
import com.dermathologyai.notification.MailService;

/**
 * Generates secure 6-digit OTPs and enforces a short rate-limit per email key.
 * OTP delivery is email-only.
 */
public class OtpService {

    private static final Map<String, Long> RATE_LIMIT_MAP = new ConcurrentHashMap<>();
    private static final long COOLDOWN_MS = 10_000L;
    private static final int OTP_LENGTH = 6;
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String generateOtp() {
        int max = (int) Math.pow(10, OTP_LENGTH);
        int otpNum = RANDOM.nextInt(max);
        return String.format("%0" + OTP_LENGTH + "d", otpNum);
    }

    public static void recordSent(String key) {
        RATE_LIMIT_MAP.put(key, System.currentTimeMillis());
    }

    private static long remainingCooldown(String key) {
        Long last = RATE_LIMIT_MAP.get(key);
        if (last == null) return 0;
        long elapsed = System.currentTimeMillis() - last;
        long remaining = COOLDOWN_MS - elapsed;
        return remaining > 0 ? remaining / 1000 : 0;
    }

    public static String hashOtp(String otp) {
        return BCrypt.hashpw(otp, BCrypt.gensalt());
    }

    public static boolean verifyOtp(String otp, String hash) {
        try {
            return BCrypt.checkpw(otp, hash);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Generates a 6-digit OTP and emails it. Returns the plain OTP for verification storage.
     */
    public static String generateAndSendOtp(String email, int ttlMinutes) throws CooldownException {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required to send OTP.");
        }
        String key = email.trim().toLowerCase();

        long remaining = remainingCooldown(key);
        if (remaining > 0) {
            throw new CooldownException(remaining);
        }

        String otp = generateOtp();
        recordSent(key);

        String text = MailTemplate.buildOtpMail(otp, ttlMinutes);
        MailService.sendAsync(key, "Mã Xác Thực - DermAI", text);
        return otp;
    }
}
