package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.User;
import org.mindrot.jbcrypt.BCrypt;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.regex.Pattern;
import com.dermathologyai.dao.PasswordResetTokenDAO;
import com.dermathologyai.model.PasswordResetToken;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.MaskUtil;

public class ProfileController extends HttpServlet {
    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;
    

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new PasswordResetTokenDAO();
        
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Refresh user data from DB to get latest info
        User freshUser = userDAO.findById(user.getId());
        session.setAttribute("user", freshUser);
        
        String success = req.getParameter("success");
        if ("security_updated".equals(success)) {
            req.setAttribute("successMessage", "Thông tin bảo mật đã được cập nhật thành công.");
        }
        
        if (req.getRequestURI().endsWith("/verify-otp")) {
            req.getRequestDispatcher("/WEB-INF/views/patient/verify-otp.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        if ("update_info".equals(action)) {
            String fullName = req.getParameter("fullName");
            String username = req.getParameter("username");
            
            if (fullName != null && !fullName.trim().isEmpty() && username != null && !username.trim().isEmpty()) {
                // Check if username is taken by someone else
                User existing = userDAO.findByUsernameOrEmail(username);
                if (existing != null && !existing.getId().equals(currentUser.getId())) {
                    req.setAttribute("errorMessage", "Username is already taken!");
                } else {
                    currentUser.setFullName(fullName.trim());
                    currentUser.setUsername(username.trim());
                    if (userDAO.update(currentUser)) {
                        req.setAttribute("successMessage", "Profile updated successfully!");
                    } else {
                        req.setAttribute("errorMessage", "Error updating profile.");
                    }
                }
            } else {
                req.setAttribute("errorMessage", "Please provide all required information.");
            }
        } else if ("request_change_security".equals(action)) {
            String oldPassword = req.getParameter("oldPassword");
            String newEmail = req.getParameter("newEmail");
            String newPhone = req.getParameter("newPhone");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");
            String otpMethod = req.getParameter("otpMethod");

            // Verify old password — only if user has a local password set
            boolean hasLocalPassword = currentUser.getPasswordHash() != null && !currentUser.getPasswordHash().isEmpty();
            if (hasLocalPassword) {
                if (oldPassword == null || oldPassword.isEmpty() || !BCrypt.checkpw(oldPassword, currentUser.getPasswordHash())) {
                    req.setAttribute("errorMessage", "Incorrect old password.");
                    req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
                    return;
                }
            }
            // Google users (no password) proceed directly — OTP will still protect the change
            {
                boolean hasChanges = false;
                
                // Validate new email
                if (newEmail != null && !newEmail.trim().isEmpty() && !newEmail.trim().equals(currentUser.getEmail())) {
                    User existing = userDAO.findByEmail(newEmail.trim());
                    if (existing != null && !existing.getId().equals(currentUser.getId())) {
                        req.setAttribute("errorMessage", "This email is already in use.");
                        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
                        return;
                    }
                    session.setAttribute("pendingNewEmail", newEmail.trim());
                    hasChanges = true;
                }

                // Validate new phone
                if (newPhone != null && !newPhone.trim().isEmpty() && !newPhone.trim().equals(currentUser.getPhone())) {
                    session.setAttribute("pendingNewPhone", newPhone.trim());
                    hasChanges = true;
                }

                // Validate new password
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    if (newPassword.length() < 8 || !Pattern.compile("(?=.*[a-zA-Z])(?=.*[0-9])").matcher(newPassword).find()) {
                        req.setAttribute("errorMessage", "New password must be at least 8 characters, including letters and numbers.");
                        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
                        return;
                    } else if (!newPassword.equals(confirmPassword)) {
                        req.setAttribute("errorMessage", "Password confirmation does not match.");
                        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
                        return;
                    }
                    session.setAttribute("pendingNewPassword", newPassword);
                    hasChanges = true;
                }

                if (!hasChanges) {
                    req.setAttribute("errorMessage", "No changes were requested.");
                } else {
                    String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : newPhone;
                    boolean isPhone = "phone".equals(otpMethod);
                    
                    // Generate and Send OTP with Fallback logic
                    String otp;
                    try {
                        otp = com.dermathologyai.service.OtpService.generateAndSendOtp(currentUser.getEmail(), phoneToSend, isPhone, 5);
                    } catch (com.dermathologyai.service.CooldownException e) {
                        req.setAttribute("errorMessage", e.getMessage());
                        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
                        return;
                    }
                    String hashedOtp = org.mindrot.jbcrypt.BCrypt.hashpw(otp, org.mindrot.jbcrypt.BCrypt.gensalt());
                    
                    // Delete any previous security-change OTP for this user
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
                    
                    PasswordResetToken token = new PasswordResetToken(currentUser.getId(), hashedOtp, "VERIFY_EMAIL", LocalDateTime.now().plusMinutes(5));
                    
                    if (tokenDAO.create(token)) {
                        session.setAttribute("otpMethod", otpMethod);
                        
                        resp.sendRedirect(req.getContextPath() + "/patient/verify-otp");
                        return;
                    } else {
                        req.setAttribute("errorMessage", "Error generating OTP.");
                    }
                }
            }
        } else if ("verify_security_otp".equals(action)) {
            String otpStr = req.getParameter("otp");
            
            PasswordResetToken token = tokenDAO.findByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
            if (token != null) {
                if (token.getAttempts() >= 3) {
                    req.setAttribute("errorMessage", "Too many failed attempts. Please request a new OTP.");
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
                } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                    req.setAttribute("errorMessage", "OTP has expired.");
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
                } else if (BCrypt.checkpw(otpStr, token.getToken())) {
                    // OTP matches — apply pending changes
                    boolean updated = false;
                    String pendingNewEmail = (String) session.getAttribute("pendingNewEmail");
                    if (pendingNewEmail != null) {
                        currentUser.setEmail(pendingNewEmail);
                        updated = true;
                    }
                    
                    String pendingNewPhone = (String) session.getAttribute("pendingNewPhone");
                    if (pendingNewPhone != null) {
                        currentUser.setPhone(pendingNewPhone);
                        updated = true;
                    }
                    
                    String pendingNewPassword = (String) session.getAttribute("pendingNewPassword");
                    if (pendingNewPassword != null) {
                        currentUser.setPasswordHash(BCrypt.hashpw(pendingNewPassword, BCrypt.gensalt()));
                        updated = true;
                    }
                    
                    if (updated && userDAO.update(currentUser)) {
                        session.setAttribute("user", currentUser);
                        session.removeAttribute("pendingNewEmail");
                        session.removeAttribute("pendingNewPhone");
                        session.removeAttribute("pendingNewPassword");
                        tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
                        
                        resp.sendRedirect(req.getContextPath() + "/patient/profile?success=security_updated");
                        return;
                    } else {
                        req.setAttribute("errorMessage", "Cập nhật hồ sơ thất bại.");
                    }
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
                } else {
                    // Wrong OTP — increment attempts
                    tokenDAO.updateAttempts(token.getId(), token.getAttempts() + 1);
                    req.setAttribute("errorMessage", "Invalid OTP.");
                }
            } else {
                req.setAttribute("errorMessage", "No OTP found. Please request a new one.");
            }
        } else if ("resend_otp".equals(action)) {
            String otpMethod = (String) session.getAttribute("otpMethod");
            String pendingNewPhone = (String) session.getAttribute("pendingNewPhone");
            String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : pendingNewPhone;
            boolean isPhone = "phone".equals(otpMethod);
            
            String otp;
            try {
                otp = com.dermathologyai.service.OtpService.generateAndSendOtp(currentUser.getEmail(), phoneToSend, isPhone, 5);
            } catch (com.dermathologyai.service.CooldownException e) {
                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/patient/verify-otp.jsp").forward(req, resp);
                return;
            }
            String hashedOtp = org.mindrot.jbcrypt.BCrypt.hashpw(otp, org.mindrot.jbcrypt.BCrypt.gensalt());
            
            tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), "VERIFY_EMAIL");
            PasswordResetToken token = new PasswordResetToken(currentUser.getId(), hashedOtp, "VERIFY_EMAIL", LocalDateTime.now().plusMinutes(5));
            if (tokenDAO.create(token)) {
                
                req.setAttribute("successMessage", "A new OTP has been sent.");
                req.getRequestDispatcher("/WEB-INF/views/patient/verify-otp.jsp").forward(req, resp);
                return;
            } else {
                req.setAttribute("errorMessage", "Error generating OTP.");
                req.getRequestDispatcher("/WEB-INF/views/patient/verify-otp.jsp").forward(req, resp);
                return;
            }
        }

        // Refresh session
        session.setAttribute("user", currentUser);
        
        String forwardPath = "/WEB-INF/views/patient/profile.jsp";
        if ("verify_security_otp".equals(action) || "resend_otp".equals(action) || 
            (req.getRequestURI().endsWith("/patient/verify-otp"))) {
            
            String otpMethod = (String) session.getAttribute("otpMethod");
            String pendingNewPhone = (String) session.getAttribute("pendingNewPhone");
            String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : pendingNewPhone;
            
            if ("phone".equals(otpMethod)) {
                req.setAttribute("maskedTarget", MaskUtil.maskPhone(phoneToSend));
            } else {
                req.setAttribute("maskedTarget", MaskUtil.maskEmail(currentUser.getEmail()));
            }
            forwardPath = "/WEB-INF/views/patient/verify-otp.jsp";
        }
        
        req.getRequestDispatcher(forwardPath).forward(req, resp);
    }
}
