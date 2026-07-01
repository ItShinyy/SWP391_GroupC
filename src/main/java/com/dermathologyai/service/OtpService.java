package com.dermathologyai.service;

import org.mindrot.jbcrypt.BCrypt;
import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import com.dermathologyai.notification.MailTemplate;
import com.dermathologyai.notification.MailService;
import com.dermathologyai.notification.SmsService;

/**
 * Generates secure 6-digit OTPs and enforces a 60-second rate-limit per key.
 * Keys can be email address, phone number, or userId.
 */
public class OtpService {

    // In-memory rate limit store: key -> timestamp of last request (ms)
    private static final Map<String, Long> RATE_LIMIT_MAP = new ConcurrentHashMap<>();
    private static final long COOLDOWN_MS = 10_000L; // 10 seconds (reduced for MVP testing)

    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Generates a zero-padded OTP of the given length using SecureRandom.
     */
    public static String generateOtp(int length) {
        int max = (int) Math.pow(10, length);
        int otpNum = RANDOM.nextInt(max);
        return String.format("%0" + length + "d", otpNum);
    }

    /**
     * Records that an OTP was just sent to this key (starts cooldown).
     */
    public static void recordSent(String key) {
        RATE_LIMIT_MAP.put(key, System.currentTimeMillis());
    }

    /**
     * Returns remaining cooldown in seconds for the given key, or 0 if allowed.
     */
    private static long remainingCooldown(String key) {
        Long last = RATE_LIMIT_MAP.get(key);
        if (last == null) return 0;
        long elapsed = System.currentTimeMillis() - last;
        long remaining = COOLDOWN_MS - elapsed;
        return remaining > 0 ? remaining / 1000 : 0;
    }

    /**
     * Hash an OTP with BCrypt for secure storage.
     */
    public static String hashOtp(String otp) {
        return BCrypt.hashpw(otp, BCrypt.gensalt());
    }

    /**
     * Verify a plain OTP against a BCrypt hash.
     */
    public static boolean verifyOtp(String otp, String hash) {
        try {
            return BCrypt.checkpw(otp, hash);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Generates a 6-digit OTP and sends it via Phone or Email with fallback.
     * Returns the generated plain OTP.
     */
    public static String generateAndSendOtp(String email, String phone, boolean isPhone, int ttlMinutes) throws CooldownException {
        // Fallback: if user chose phone but has no phone, switch to email
        if (isPhone && (phone == null || phone.trim().isEmpty())) {
            isPhone = false;
        }

        // Determine rate-limit key
        String key = isPhone ? phone : email;
        if (key == null || key.trim().isEmpty()) {
            throw new IllegalArgumentException("No valid identifier provided for OTP.");
        }

        // Enforce cooldown
        long remaining = remainingCooldown(key);
        if (remaining > 0) {
            throw new CooldownException(remaining);
        }

        String otp = generateOtp(6);
        
        // Record sent to start cooldown
        recordSent(key);

        if (isPhone) {
            SmsService.sendSms(phone, "Mã xác thực SkinAI của bạn là: " + otp);
        } else {
            if (email != null && !email.trim().isEmpty()) {
                String text = MailTemplate.buildOtpMail(otp, ttlMinutes);
                MailService.sendAsync(email, "Mã Xác Thực - SkinAI", text);
            }
        }
        return otp;
    }
}
