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

    public User loginWithGoogle(String googleId, String email, String fullName, String avatarUrl) {
        // Try to find user by Google ID
        User user = userDAO.findByGoogleId(googleId);
        
        if (user == null) {
            // Try to find by email (if they registered differently before)
            user = userDAO.findByEmail(email);
            if (user != null) {
                // Link Google account
                user.setGoogleId(googleId);
                user.setAvatarUrl(avatarUrl);
                if (user.getFullName() == null || user.getFullName().isEmpty()) {
                    user.setFullName(fullName);
                }
                userDAO.update(user);
            } else {
                // Create new user (default role is PATIENT, status ACTIVE)
                user = new User();
                user.setGoogleId(googleId);
                user.setEmail(email);
                user.setFullName(fullName);
                user.setAvatarUrl(avatarUrl);
                user.setRole("PATIENT");
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
            // Update avatar and name if changed
            boolean needsUpdate = false;
            if (avatarUrl != null && !avatarUrl.equals(user.getAvatarUrl())) {
                user.setAvatarUrl(avatarUrl);
                needsUpdate = true;
            }
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

    public User registerLocal(String email, String fullName, String rawPassword) {
        if (userDAO.findByEmail(email) != null) {
            // Email already exists
            return null;
        }

        User user = new User();
        user.setEmail(email);
        user.setFullName(fullName);
        user.setRole("PATIENT");
        user.setStatus("ACTIVE");
        user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

        String newId = userDAO.create(user);
        if (newId != null) {
            user.setId(newId);
            return user;
        }
        return null;
    }

    public User loginLocal(String email, String rawPassword) {
        User user = userDAO.findByEmail(email);
        if (user != null) {
            // Prevent NPE for users who registered via Google and don't have a password
            if (user.getPasswordHash() != null && BCrypt.checkpw(rawPassword, user.getPasswordHash())) {
                return user;
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
}
