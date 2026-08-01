package com.dermathologyai.service;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.User;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.util.InputValidator;
import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.model.UserToken;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.time.LocalDateTime;

public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final UserDAO userDAO;
    private final PatientDAO patientDAO;
    private final DoctorDAO doctorDAO;
    private final UserTokenDAO tokenDAO;
    private final AuditService auditService;
    private final NotificationService notificationService;

    public AuthService() {
        this.userDAO = new UserDAO();
        this.patientDAO = new PatientDAO();
        this.doctorDAO = new DoctorDAO();
        this.tokenDAO = new UserTokenDAO();
        this.auditService = new AuditService();
        this.notificationService = new NotificationService();
    }

    public User loginWithGoogle(String googleId, String email, String fullName, String pictureUrl) {
        String normEmail = (email == null || email.isBlank()) ? null : email.trim().toLowerCase();
        
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
            user = userDAO.findByEmail(normEmail);
            if (user != null) {
                throw new IllegalStateException("Tài khoản có email này đã tồn tại và cần được xác nhận trước khi liên kết với Google.");
            } else {
                // Create new user directly from Google
                user = new User();
                user.setGoogleId(googleId);
                user.setEmail(normEmail);
                // Generate a unique username if not provided
                user.setUsername(normEmail.split("@")[0] + "_" + (System.currentTimeMillis() % 10000)); 
                user.setFullName(fullName);
                user.setAvatar(normalizeAvatarUrl(pictureUrl));
                user.assignRegisteredPatientRole();
                user.setStatus("ACTIVE");
                
                String newId = userDAO.create(user);
                if (newId != null) {
                    user.setId(newId);
                    ensurePatientProfile(newId);
                } else {
                    logger.error("Failed to create new user from Google Login");
                    return null;
                }
            }
        } else if (user != null) {
            // Refresh name/avatar from Google on each login
            boolean needsUpdate = false;
            if (fullName != null && !fullName.isBlank()
                    && (user.getFullName() == null || !fullName.equals(user.getFullName()))) {
                user.setFullName(fullName);
                needsUpdate = true;
            }
            String avatar = normalizeAvatarUrl(pictureUrl);
            if (avatar != null && (user.getAvatar() == null || !avatar.equals(user.getAvatar()))) {
                user.setAvatar(avatar);
                needsUpdate = true;
            }
            if (needsUpdate) {
                userDAO.update(user);
            }
        }

        if (user != null) {
            ensurePatientProfile(user.getId());
        }
        
        return user;
    }

    public User findByGoogleId(String googleId) {
        return googleId == null || googleId.isBlank() ? null : userDAO.findByGoogleId(googleId);
    }

    public User findByEmail(String email) {
        return email == null || email.isBlank() ? null : userDAO.findByEmail(email.trim().toLowerCase());
    }

    public User linkGoogleAccount(String userId, String googleId, String email, String fullName, String pictureUrl) {
        if (userId == null || userId.isBlank() || googleId == null || googleId.isBlank()) {
            throw new IllegalArgumentException("Không thể xác minh tài khoản Google.");
        }
        User user = userDAO.findById(userId);
        if (user == null || email == null || !email.trim().equalsIgnoreCase(user.getEmail())) {
            throw new IllegalArgumentException("Không thể xác minh tài khoản để liên kết Google.");
        }

        User linkedUser = userDAO.findByGoogleId(googleId);
        if (linkedUser != null && !linkedUser.getId().equals(user.getId())) {
            throw new IllegalStateException("Tài khoản Google này đã được liên kết với một tài khoản khác.");
        }
        if (user.getGoogleId() != null && !user.getGoogleId().equals(googleId)) {
            throw new IllegalStateException("Tài khoản này đã được liên kết với một tài khoản Google khác.");
        }

        user.setGoogleId(googleId);
        if (user.getFullName() == null || user.getFullName().isBlank()) {
            user.setFullName(fullName);
        }
        String avatar = normalizeAvatarUrl(pictureUrl);
        if (avatar != null) {
            user.setAvatar(avatar);
        }
        if (!userDAO.update(user)) {
            throw new IllegalStateException("Không thể liên kết tài khoản Google. Vui lòng thử lại.");
        }
        ensurePatientProfile(user.getId());
        return user;
    }

    /**
     * Ensures PATIENT/USER accounts have a {@code patients} row (required for screening/booking).
     * Google signup historically skipped this; call to heal orphans too.
     */
    public Patient ensurePatientProfile(String userId) {
        if (userId == null || userId.isBlank()) return null;
        Patient existing = patientDAO.findByUserId(userId);
        if (existing != null) return existing;
        User user = userDAO.findById(userId);
        if (user == null) return null;
        if (!user.isPatient()) {
            return null;
        }
        Patient patient = new Patient();
        patient.setUserId(userId);
        String id = patientDAO.create(patient);
        if (id == null) {
            // Race on unique user_id
            return patientDAO.findByUserId(userId);
        }
        return patientDAO.findById(id);
    }

    /**
     * Prepares a registration by validating and normalizing inputs.
     * DOES NOT SAVE to database yet (Verification-led validation).
     * @return User object to be stored in session pending OTP/Email verification.
     */
    public User prepareRegistration(String username, String email, String phone, String fullName, String rawPassword) {
        String normEmail = (email == null || email.isBlank()) ? null : email.trim().toLowerCase();
        String normPhone = (phone == null || phone.isBlank()) ? null : phone.trim();
        String normUsername = InputValidator.normalizeUsername(username);
        InputValidator.requireValidPassword(rawPassword);

        if (fullName == null || fullName.isBlank()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }
        if (normEmail == null) {
            throw new IllegalArgumentException("Email is required for registration.");
        }
        InputValidator.requireValidEmail(normEmail);
        if (normPhone != null) {
            InputValidator.requireValidPhone(normPhone);
        }
        if (userDAO.isEmailTaken(normEmail)) {
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
        user.setFullName(fullName.trim());
        user.setAvatar("/assets/images/default-seedling.png");
        user.assignRegisteredPatientRole();
        user.setStatus("ACTIVE");
        user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));

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

        pendingUser.assignRegisteredPatientRole();
        String newId = userDAO.create(pendingUser);
        if (newId != null) {
            pendingUser.setId(newId);
            // Create corresponding Patient record
            Patient patient = new Patient();
            patient.setUserId(newId);
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

    public boolean lockAccount(String userId, String reason, String adminId, String ipAddress, String userAgent) {
        boolean success = userDAO.lockWithReason(userId, reason != null ? reason.trim() : "Vi phạm chính sách");
        if (success) {
            doctorDAO.setActiveByUserId(userId, false);
            String newValues = "LOCKED (Reason: " + (reason != null ? reason.trim() : "Vi phạm chính sách") + ")";
            auditService.log(adminId, "LOCK_USER", "User", userId, "ACTIVE", newValues, null, ipAddress, userAgent);
            User u = userDAO.findById(userId);
            if (u != null) notificationService.sendAccountLockStatusAlert(u.getEmail(), "LOCKED");
        }
        return success;
    }

    public boolean unlockAccount(String userId, String adminId, String ipAddress, String userAgent) {
        boolean success = userDAO.unlock(userId);
        if (success) {
            doctorDAO.setActiveByUserId(userId, true);
            auditService.log(adminId, "UNLOCK_USER", "User", userId, "LOCKED", "ACTIVE", null, ipAddress, userAgent);
            User u = userDAO.findById(userId);
            if (u != null) notificationService.sendAccountLockStatusAlert(u.getEmail(), "UNLOCKED");
        }
        return success;
    }

    public void resetPassword(String identifier, String tokenStr, String newPassword, String ipAddress, String userAgent) {
        InputValidator.requireValidPassword(newPassword);
        User user = userDAO.findByUsernameOrEmail(identifier);
        if (user == null) {
            throw new IllegalArgumentException("Mã OTP không chính xác hoặc đã hết hạn.");
        }

        UserToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
        if (token != null) {
            if (token.getAttempts() >= 3) {
                tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
                throw new IllegalStateException("Bạn đã nhập sai quá 3 lần. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
            }

            if (token.getExpiresAt().isBefore(LocalDateTime.now()) || token.getUsedAt() != null) {
                tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
                throw new IllegalArgumentException("Mã OTP đã hết hạn hoặc đã được sử dụng. Vui lòng yêu cầu lại.");
            } else if (BCrypt.checkpw(tokenStr, token.getToken())) {
                persistPassword(user, newPassword);
                tokenDAO.markUsed(token.getId());
                
                auditService.log(user.getId(), "PASSWORD_RESET", "users", user.getId(), null, null, "{\"method\":\"otp\"}", ipAddress, userAgent);
                notificationService.sendPasswordChangedAlert(user.getEmail());
            } else {
                int newAttempts = tokenDAO.incrementAttempts(token.getId());
                if (newAttempts >= 3) {
                    tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
                    throw new IllegalStateException("Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                } else {
                    throw new IllegalArgumentException("Mã OTP không chính xác. Bạn còn " + (3 - newAttempts) + " lần thử.");
                }
            }
        } else {
            throw new IllegalArgumentException("Mã OTP không chính xác hoặc không tồn tại.");
        }
    }

    public void unlockAccountWithOtp(String email, String tokenStr, String ipAddress, String userAgent) {
        User user = (email != null) ? userDAO.findByEmail(email.trim()) : null;
        if (user == null) {
            throw new IllegalArgumentException("Mã OTP không chính xác.");
        }

        UserToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
        if (token != null) {
            if (token.getAttempts() >= 3) {
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                throw new IllegalStateException("Bạn đã nhập sai quá 3 lần. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
            } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                throw new IllegalArgumentException("Mã OTP đã hết hạn (Quá 5 phút). Vui lòng yêu cầu gửi lại.");
            } else if (OtpService.verifyOtp(tokenStr.trim(), token.getToken())) {
                // OTP matches -> unlock account
                userDAO.updateStatus(user.getId(), "ACTIVE");
                userDAO.updateLastLogin(user.getId());
                
                user.setStatus("ACTIVE");
                user.setLockReason(null);
                userDAO.update(user);
                doctorDAO.setActiveByUserId(user.getId(), true);
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                
                auditService.log(user.getId(), "ACCOUNT_UNLOCKED", "users", user.getId(), null, null, "Mở khóa tài khoản thành công qua OTP", ipAddress, userAgent);
                notificationService.sendAccountLockStatusAlert(user.getEmail(), "UNLOCKED");
            } else {
                int newAttempts = tokenDAO.incrementAttempts(token.getId());
                if (newAttempts >= 3) {
                    tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                    throw new IllegalStateException("Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                } else {
                    throw new IllegalArgumentException("Mã OTP không chính xác. Bạn còn " + (3 - newAttempts) + " lần thử.");
                }
            }
        } else {
            throw new IllegalArgumentException("Mã OTP không chính xác hoặc đã hết hạn.");
        }
    }
    
    public void sendUnlockOtp(String email) throws com.dermathologyai.service.CooldownException {
        User user = userDAO.findByEmail(email);
        if (user != null && "LOCKED".equals(user.getStatus()) && user.getLockReason() == null) {
            if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
                throw new IllegalStateException("Tài khoản không có email để gửi OTP.");
            }
            String otp = OtpService.generateAndSendOtp(user.getEmail(), 5);
            issueHashedOtpToken(user.getId(), "UNLOCK_ACCOUNT", otp, 5, true);
        } else {
            OtpService.recordSent(email);
        }
    }

    /** Issue RESET_PASSWORD OTP (hashed). Caller must ensure user has email. */
    public boolean sendResetPasswordOtp(User user) throws CooldownException {
        String otp = OtpService.generateAndSendOtp(user.getEmail(), 5);
        return issueHashedOtpToken(user.getId(), "RESET_PASSWORD", otp, 5, false);
    }

    /** Store hashed OTP for reset/unlock-style purposes. */
    private boolean issueHashedOtpToken(String userId, String purpose, String plainOtp, int minutes, boolean hardDeletePrevious) {
        if (hardDeletePrevious) {
            tokenDAO.deleteByUserIdAndPurpose(userId, purpose);
        } else {
            tokenDAO.invalidateAllByUserAndPurpose(userId, purpose);
        }
        UserToken token = new UserToken(userId, OtpService.hashOtp(plainOtp), purpose, LocalDateTime.now().plusMinutes(minutes));
        return tokenDAO.create(token);
    }

    /**
     * Identity step before changing EMAIL or PASSWORD — OTP always sent to the user's current email.
     */
    public String requestOldTargetOtp(User currentUser, String targetType) throws CooldownException {
        if (!"EMAIL".equals(targetType) && !"PASSWORD".equals(targetType)) {
            throw new IllegalArgumentException("Only email or password can be changed via OTP.");
        }
        if (currentUser.getEmail() == null || currentUser.getEmail().trim().isEmpty()) {
            throw new IllegalStateException("Tài khoản chưa có email để xác thực.");
        }

        String purpose = "EMAIL_CHANGE_OLD";
        tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
        String otp = OtpService.generateAndSendOtp(currentUser.getEmail(), 5);
        UserToken token = new UserToken(currentUser.getId(), otp, purpose, LocalDateTime.now().plusMinutes(5));
        tokenDAO.create(token);
        return purpose;
    }

    public void verifyOtpTokenOnly(User currentUser, String otpStr, String purpose) {
        UserToken activeToken = tokenDAO.findByUserIdAndPurpose(currentUser.getId(), purpose);
        if (activeToken == null) throw new IllegalArgumentException("Không tìm thấy mã OTP.");
        if (activeToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
            throw new IllegalArgumentException("Mã OTP đã hết hạn.");
        }
        if (activeToken.getAttempts() >= 3) {
            tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
            throw new IllegalStateException("Bạn đã nhập sai quá 3 lần. Mã OTP đã bị vô hiệu hóa.");
        }
        if (!otpStr.equals(activeToken.getToken())) {
            int newAttempts = tokenDAO.incrementAttempts(activeToken.getId());
            if (newAttempts >= 3) {
                tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
                throw new IllegalStateException("Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa.");
            }
            throw new IllegalArgumentException("Mã OTP không chính xác. Bạn còn " + (3 - newAttempts) + " lần thử.");
        }
        tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
    }

    /** Confirm a new email address — OTP sent to the new email only. */
    public String requestNewTargetOtp(User currentUser, String targetType, String newValue) throws CooldownException {
        if (!"EMAIL".equals(targetType)) {
            throw new IllegalArgumentException("Only a new email address is confirmed via OTP.");
        }
        if (newValue == null || newValue.isBlank()) {
            throw new IllegalArgumentException("Email mới không hợp lệ.");
        }
        String email = newValue.trim().toLowerCase();
        if (userDAO.isEmailTaken(email)) throw new IllegalArgumentException("Email đã được sử dụng.");

        String purpose = "EMAIL_CHANGE_NEW";
        tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
        String otp = OtpService.generateAndSendOtp(email, 5);
        UserToken token = new UserToken(currentUser.getId(), otp, purpose, LocalDateTime.now().plusMinutes(5));
        tokenDAO.create(token);
        return purpose;
    }

    public void verifyNewTargetOtpAndUpdate(User currentUser, String otpStr, String targetType, String newValue) {
        if (!"EMAIL".equals(targetType)) {
            throw new IllegalArgumentException("Only email can be updated via OTP confirmation.");
        }
        verifyOtpTokenOnly(currentUser, otpStr, "EMAIL_CHANGE_NEW");

        String email = newValue.trim().toLowerCase();
        String oldEmail = currentUser.getEmail();
        currentUser.setEmail(email);
        userDAO.update(currentUser);

        if (oldEmail != null && !oldEmail.trim().isEmpty()) {
            notificationService.sendEmailChangedAlert(oldEmail);
        }
    }

    /** Contact phone only — no OTP / verification state. */
    public void updateContactPhone(User currentUser, String phone) {
        String norm = (phone == null || phone.isBlank()) ? null : phone.trim();
        if (norm != null) {
            if (norm.length() < 8 || norm.length() > 20) {
                throw new IllegalArgumentException("Số điện thoại không hợp lệ.");
            }
            if (userDAO.isPhoneTakenByOther(norm, currentUser.getId())) {
                throw new IllegalArgumentException("Số điện thoại đã được sử dụng.");
            }
        }
        currentUser.setPhone(norm);
        userDAO.update(currentUser);
    }

    public void changePassword(User currentUser, String newPassword) {
        persistPassword(currentUser, newPassword);
        if (currentUser.getEmail() != null && !currentUser.getEmail().trim().isEmpty()) {
            notificationService.sendPasswordChangedAlert(currentUser.getEmail());
        }
    }

    /**
     * Admin-only: create a normal ACTIVE DOCTOR login + doctors profile row.
     * Password rules match normal registration. Returns created doctor id.
     */
    public String createDoctorAccount(String fullName, String email, String username, String phone,
                                      String password, String clinicId, String specialization,
                                      String licenseNumber, String bio) {
        String normEmail = email == null || email.isBlank() ? null : email.trim().toLowerCase();
        String normUsername = InputValidator.normalizeUsername(username);
        InputValidator.requireValidPassword(password);
        if (fullName == null || fullName.isBlank()) throw new IllegalArgumentException("Full name is required.");
        if (normEmail == null) throw new IllegalArgumentException("Email is required.");
        if (phone == null || phone.isBlank()) throw new IllegalArgumentException("Phone is required.");
        if (clinicId == null || clinicId.isBlank()) throw new IllegalArgumentException("Clinic is required.");
        if (specialization == null || specialization.isBlank()) {
            throw new IllegalArgumentException("Specialization is required.");
        }
        if (licenseNumber == null || licenseNumber.isBlank()) {
            throw new IllegalArgumentException("License number is required.");
        }
        if (userDAO.isEmailTaken(normEmail)) throw new IllegalArgumentException("Email already in use.");
        if (userDAO.isUsernameTaken(normUsername)) throw new IllegalArgumentException("Username already in use.");
        if (userDAO.isPhoneTaken(phone.trim())) {
            throw new IllegalArgumentException("Phone already in use.");
        }

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(normEmail);
        user.setUsername(normUsername);
        user.setPhone(phone.trim());
        user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setRole("DOCTOR");
        user.setStatus("ACTIVE");
        String userId = userDAO.create(user);
        if (userId == null) throw new IllegalStateException("Could not create doctor user.");

        Doctor doctor = new Doctor();
        doctor.setUserId(userId);
        doctor.setClinicId(clinicId.trim());
        doctor.setSpecialization(specialization.trim());
        doctor.setLicenseNumber(licenseNumber.trim());
        doctor.setBio(blankToNull(bio));
        doctor.setActive(true);
        String doctorId = doctorDAO.create(doctor);
        if (doctorId == null) {
            userDAO.updateStatus(userId, "INACTIVE");
            throw new IllegalStateException("Doctor profile insert failed; user left inactive.");
        }
        return doctorId;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    /** Keep Google picture URLs within DB column length; prefer https. */
    private static String normalizeAvatarUrl(String pictureUrl) {
        if (pictureUrl == null || pictureUrl.isBlank()) {
            return null;
        }
        String url = pictureUrl.trim();
        if (url.length() > 1000) {
            url = url.substring(0, 1000);
        }
        return url;
    }

    private void persistPassword(User user, String rawPassword) {
        String passwordHash = BCrypt.hashpw(rawPassword, BCrypt.gensalt());
        if (!userDAO.updatePassword(user.getId(), passwordHash)) {
            throw new IllegalStateException("Không thể cập nhật mật khẩu. Vui lòng thử lại.");
        }
        user.setPasswordHash(passwordHash);
    }
}
