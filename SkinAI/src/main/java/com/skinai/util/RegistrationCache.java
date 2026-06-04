package com.skinai.util;

import com.skinai.model.User;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class RegistrationCache {

    public static class PendingRegistration {
        private String token; // The OTP (Phone) or UUID (Email)
        private User user;
        private boolean isPhone; // true if OTP flow, false if Email link flow
        private long createdAt;
        private long lastSentAt;

        public PendingRegistration(String token, User user, boolean isPhone) {
            this.token = token;
            this.user = user;
            this.isPhone = isPhone;
            long now = System.currentTimeMillis();
            this.createdAt = now;
            this.lastSentAt = now;
        }

        public String getToken() { return token; }
        public void setToken(String token) { this.token = token; }
        public User getUser() { return user; }
        public boolean isPhone() { return isPhone; }
        public long getCreatedAt() { return createdAt; }
        public long getLastSentAt() { return lastSentAt; }
        public void setLastSentAt(long lastSentAt) { this.lastSentAt = lastSentAt; }
        
        public boolean isExpired(long ttlMillis) {
            return (System.currentTimeMillis() - createdAt) > ttlMillis;
        }

        public boolean canResend(long cooldownMillis) {
            return (System.currentTimeMillis() - lastSentAt) >= cooldownMillis;
        }
    }

    // Key: token (UUID or 6-digit OTP)
    // Value: PendingRegistration object
    private static final Map<String, PendingRegistration> cache = new ConcurrentHashMap<>();

    private static final long TTL_MILLIS = 15 * 60 * 1000; // 15 minutes
    private static final long COOLDOWN_MILLIS = 60 * 1000; // 60 seconds

    /**
     * Stores a pending registration in the cache.
     */
    public static void put(String token, User user, boolean isPhone) {
        cleanUp(); // Optionally clean up expired entries periodically
        cache.put(token, new PendingRegistration(token, user, isPhone));
    }

    /**
     * Retrieves a pending registration by token.
     */
    public static PendingRegistration get(String token) {
        PendingRegistration pending = cache.get(token);
        if (pending != null && pending.isExpired(TTL_MILLIS)) {
            cache.remove(token);
            return null;
        }
        return pending;
    }

    /**
     * Updates the last sent time to reset the cooldown.
     * Throws exception if cooldown hasn't passed.
     */
    public static void updateLastSent(String token) {
        PendingRegistration pending = get(token);
        if (pending != null) {
            if (!pending.canResend(COOLDOWN_MILLIS)) {
                long waitTime = (COOLDOWN_MILLIS - (System.currentTimeMillis() - pending.getLastSentAt())) / 1000;
                throw new IllegalStateException("Vui lòng đợi " + waitTime + " giây trước khi gửi lại.");
            }
            pending.setLastSentAt(System.currentTimeMillis());
        }
    }

    /**
     * Removes a registration from the cache (used after successful verification).
     */
    public static void remove(String token) {
        cache.remove(token);
    }

    /**
     * Basic cleanup of expired entries to prevent memory leaks.
     */
    private static void cleanUp() {
        long now = System.currentTimeMillis();
        cache.entrySet().removeIf(entry -> (now - entry.getValue().getCreatedAt()) > TTL_MILLIS);
    }
}
