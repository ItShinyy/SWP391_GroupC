package com.dermathologyai.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.SecureRandom;
import java.util.Base64;

public class CsrfUtil {

    private static final String CSRF_TOKEN_ATTR = "csrfToken";

    /**
     * Retrieves the CSRF token from the session, creating a new one if it doesn't exist.
     */
    public static String getToken(HttpSession session) {
        String token = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (token == null) {
            byte[] bytes = new byte[32];
            new SecureRandom().nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(CSRF_TOKEN_ATTR, token);
        }
        return token;
    }

    /**
     * Validates that the token passed in the request matches the session token.
     */
    public static boolean validateToken(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (sessionToken == null) return false;

        String requestToken = req.getParameter("csrf_token");
        if (requestToken == null) return false;

        // Use constant-time comparison to prevent timing attacks
        return java.security.MessageDigest.isEqual(sessionToken.getBytes(), requestToken.getBytes());
    }
}
