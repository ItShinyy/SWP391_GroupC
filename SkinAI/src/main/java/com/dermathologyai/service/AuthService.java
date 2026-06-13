package com.dermathologyai.service;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.User;
import com.dermathologyai.model.Patient;
import com.dermathologyai.util.InputValidator;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final UserDAO userDAO;
    private final PatientDAO patientDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
        this.patientDAO = new PatientDAO();
    }

    public User loginWithGoogle(String googleId, String email, String fullName) {
        String normEmail = InputValidator.normalizeEmail(email);
        
        // Try to find user by Google ID
        User user = userDAO.findByGoogleId(googleId);
        
        if (user != null) {
            if (normEmail != null && !user.getEmail().equalsIgnoreCase(normEmail)) {
                // The user changed their email in the system, so this old Google account is no longer valid.
                user.setGoogleId(null);
                userDAO.update(user);
                throw new IllegalArgumentException("Email Google của bạn (" + normEmail + ") không khớp với Email hiện tại trong hồ sơ. " +
                        "Tài khoản Google cũ này đã được gỡ liên kết để bảo mật. Vui lòng đăng nhập bằng tài khoản Google có email chính xác.");
            }
        }
        
        if (user == null && normEmail != null) {
            // Try to find by email
            user = userDAO.findByEmail(normEmail);
            if (user != null) {
                // Rule: If email exists in DB, it is GUARANTEED to be verified (Verification-led validation).
                // So we Auto-Link the Google account.
                user.setGoogleId(googleId);
                if (user.getFullName() == null || user.getFullName().isEmpty()) {
                    user.setFullName(fullName);
                }
                userDAO.update(user);
            } else {
                // Create new user directly from Google
                user = new User();
                user.setGoogleId(googleId);
                user.setEmail(normEmail);
                // Generate a unique username if not provided
                user.setUsername(normEmail.split("@")[0] + "_" + (System.currentTimeMillis() % 10000)); 
                user.setFullName(fullName);
                user.setRole("USER");
                user.setStatus("ACTIVE");
                
                String newId = userDAO.create(user);
                if (newId != null) {
                    user.setId(newId);
                } else {
                    logger.error("Failed to create new user from Google Login");
                    return null;
                }
            }
        } else if (user != null) {
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

    /**
     * Prepares a registration by validating and normalizing inputs.
     * DOES NOT SAVE to database yet (Verification-led validation).
     * @return User object to be stored in session pending OTP/Email verification.
     */
    public User prepareRegistration(String username, String email, String phone, String fullName, String rawPassword) {
        String normEmail = email != null ? InputValidator.normalizeEmail(email) : null;
        String normPhone = phone != null ? InputValidator.normalizePhone(phone) : null;
        String normUsername = InputValidator.normalizeUsername(username);

        // Service Layer Uniqueness Check
        if (normEmail != null && userDAO.isEmailTaken(normEmail)) {
            throw new IllegalArgumentException("Email này đã được sử dụng.");
        }
        if (normPhone != null && userDAO.isPhoneTaken(normPhone)) {
            throw new IllegalArgumentException("Số điện thoại này đã được sử dụng.");
        }
        if (userDAO.isUsernameTaken(normUsername)) {
            throw new IllegalArgumentException("Username này đã tồn tại.");
        }

        User user = new User();
        user.setUsername(normUsername);
        user.setEmail(normEmail);
        user.setPhone(normPhone);
        user.setFullName(fullName);
        user.setRole("USER"); 
        user.setStatus("ACTIVE");
        user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

        // Do NOT call userDAO.create() yet!
        return user;
    }

    /**
     * Finalizes registration after successful OTP/Email link verification.
     */
    public User finalizeRegistration(User pendingUser) {
        // Double check uniqueness just in case it was taken while waiting for OTP
        if (pendingUser.getEmail() != null && userDAO.isEmailTaken(pendingUser.getEmail())) {
            throw new IllegalArgumentException("Email này đã được sử dụng bởi người khác.");
        }
        if (pendingUser.getPhone() != null && userDAO.isPhoneTaken(pendingUser.getPhone())) {
            throw new IllegalArgumentException("Số điện thoại này đã được sử dụng bởi người khác.");
        }
        if (userDAO.isUsernameTaken(pendingUser.getUsername())) {
            throw new IllegalArgumentException("Username này đã bị lấy bởi người khác.");
        }

        String newId = userDAO.create(pendingUser);
        if (newId != null) {
            pendingUser.setId(newId);
            // Create corresponding Patient record
            Patient patient = new Patient();
            patient.setUserId(newId);
            patient.setPhone(pendingUser.getPhone());
            patientDAO.create(patient);
            
            return pendingUser;
        }
        return null;
    }

    public enum LoginResultStatus {
        SUCCESS,
        INVALID_CREDENTIALS,
        ACCOUNT_LOCKED
    }

    public static class LoginResult {
        public final LoginResultStatus status;
        public final User user;
        public LoginResult(LoginResultStatus status, User user) {
            this.status = status;
            this.user = user;
        }
    }

    public LoginResult loginLocal(String keyword, String rawPassword) {
        User user = userDAO.findByUsernameOrEmail(keyword);
        if (user == null) {
            return new LoginResult(LoginResultStatus.INVALID_CREDENTIALS, null);
        }

        if ("LOCKED".equals(user.getStatus())) {
            return new LoginResult(LoginResultStatus.ACCOUNT_LOCKED, user);
        }

        if (user.getPasswordHash() != null) {
            String dbHash = user.getPasswordHash();
            try {
                if (BCrypt.checkpw(rawPassword, dbHash)) {
                    // Atomically clear failed logins
                    userDAO.recordSuccessfulLogin(user.getId());
                    return new LoginResult(LoginResultStatus.SUCCESS, user);
                }
            } catch (Exception e) {
                logger.error("Error checking BCrypt password", e);
            }
        }

        // Increment failed logins atomically
        userDAO.incrementFailedLogin(user.getId());
        
        // Re-fetch to check if user was locked just now
        User updatedUser = userDAO.findById(user.getId());
        if ("LOCKED".equals(updatedUser.getStatus())) {
            return new LoginResult(LoginResultStatus.ACCOUNT_LOCKED, updatedUser);
        }

        return new LoginResult(LoginResultStatus.INVALID_CREDENTIALS, updatedUser);
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
