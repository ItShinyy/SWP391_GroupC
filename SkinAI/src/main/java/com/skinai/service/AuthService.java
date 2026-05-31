package com.skinai.service;

import com.skinai.dal.UserDAO;
import com.skinai.model.User;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public User loginWithGoogle(String googleId, String email, String fullName) {
        // Try to find user by Google ID
        User user = userDAO.findByGoogleId(googleId);
        
        if (user == null) {
            // Try to find by email (if they registered differently before)
            user = userDAO.findByEmail(email);
            if (user != null) {
                // Link Google account
                user.setGoogleId(googleId);
                if (user.getFullName() == null || user.getFullName().isEmpty()) {
                    user.setFullName(fullName);
                }
                userDAO.update(user);
            } else {
                // Create new user (default role is PATIENT, status ACTIVE)
                user = new User();
                user.setGoogleId(googleId);
                user.setEmail(email);
                // For Google login, username might not be available, we can auto-generate or leave null if allowed
                user.setUsername(email.split("@")[0] + "_" + System.currentTimeMillis() % 1000); 
                user.setFullName(fullName);
                user.setRole("USER"); // Zero-Trust: Default to USER
                user.setStatus("ACTIVE");
                
                String newId = userDAO.create(user);
                if (newId != null) {
                    user.setId(newId);
                } else {
                    logger.error("Failed to create new user from Google Login");
                    return null;
                }
            }
        } else {
            // Update name if changed
            boolean needsUpdate = false;
            if (fullName != null && (user.getFullName() == null || !fullName.equals(user.getFullName()))) {
                user.setFullName(fullName);
                needsUpdate = true;
            }
            if (needsUpdate) {
                userDAO.update(user);
            }
        }
        
        return user;
    }

    public User registerLocal(String username, String email, String phone, String fullName, String rawPassword) {
        if (email != null && userDAO.findByUsernameOrEmail(email) != null) {
            return null;
        }
        if (phone != null && userDAO.findByUsernameOrEmail(phone) != null) {
            return null;
        }
        if (username != null && userDAO.findByUsernameOrEmail(username) != null) {
            return null;
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPhone(phone);
        user.setFullName(fullName);
        user.setRole("USER"); // Zero-Trust: Default to USER
        user.setStatus("ACTIVE");
        user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

        String newId = userDAO.create(user);
        if (newId != null) {
            user.setId(newId);
            return user;
        }
        return null;
    }

    public User loginLocal(String keyword, String rawPassword) {
        User user = userDAO.findByUsernameOrEmail(keyword);
        if (user != null && user.getPasswordHash() != null) {
            String dbHash = user.getPasswordHash();
            // Prevent crash if dbHash is plain text (not BCrypt)
            if (dbHash.startsWith("$2a$") || dbHash.startsWith("$2b$") || dbHash.startsWith("$2y$")) {
                try {
                    if (BCrypt.checkpw(rawPassword, dbHash)) {
                        return user;
                    }
                } catch (Exception e) {
                    // Fallback in case of parsing error
                }
            } else {
                // DB contains plain text password
                if (dbHash.equals(rawPassword)) {
                    // Optionally update to hash here, but for now just allow login
                    return user;
                }
            }
        }
        return null;
    }

    public User findById(String userId) {
        return userDAO.findById(userId);
    }

    public boolean isAccountActive(User user) {
        return user != null && "ACTIVE".equals(user.getStatus());
    }

    public boolean updateLastLogin(String userId) {
        return userDAO.updateLastLogin(userId);
    }

    public boolean lockAccount(String userId) {
        return userDAO.updateStatus(userId, "LOCKED");
    }

    public boolean unlockAccount(String userId) {
        return userDAO.updateStatus(userId, "ACTIVE");
    }
}
