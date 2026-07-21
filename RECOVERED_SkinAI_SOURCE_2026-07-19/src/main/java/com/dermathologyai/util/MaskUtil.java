package com.dermathologyai.util;

/**
 * Utility for masking sensitive user data (PII) before sending to frontend.
 * Spec:
 *   Email: if name.length > 3  -> first 3 chars + "***" + @domain
 *          if name.length <= 3 -> first 1 char  + "***" + @domain
 *   Phone: first 3 digits + "*****" + last 2 digits
 */
public final class MaskUtil {

    private MaskUtil() {}

    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "***";
        int atIdx = email.indexOf('@');
        String name   = email.substring(0, atIdx);
        String domain = email.substring(atIdx);          // includes '@'
        String visible = name.length() > 3
                ? name.substring(0, 3)
                : name.substring(0, 1);
        return visible + "***" + domain;
    }

    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 5) return "***";
        // Strip non-digits for counting, but keep original chars for prefix/suffix
        String digits = phone.replaceAll("\\D", "");
        if (digits.length() < 5) return "***";
        String prefix = phone.substring(0, 3);
        String suffix = phone.substring(phone.length() - 2);
        return prefix + "*****" + suffix;
    }
}
