package com.dermathologyai.controller.account;

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
import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.model.UserToken;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.MaskUtil;

public class ProfileController extends HttpServlet {
    private UserDAO userDAO;
    private UserTokenDAO tokenDAO;
    

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new UserTokenDAO();
        
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
            forwardToVerifyOtp(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
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
                    req.setAttribute("errorMessage", "Tên đăng nhập đã tồn tại!");
                } else {
                    currentUser.setFullName(fullName.trim());
                    currentUser.setUsername(username.trim());
                    if (userDAO.update(currentUser)) {
                        req.setAttribute("successMessage", "Cập nhật hồ sơ thành công!");
                    } else {
                        req.setAttribute("errorMessage", "Lỗi cập nhật hồ sơ.");
                    }
                }
            } else {
                req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin.");
            }
        } else if ("request_change_security".equals(action)) {
            String newEmail = req.getParameter("newEmail");
            String newPhone = req.getParameter("newPhone");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");
            String otpMethod = req.getParameter("otpMethod");

            {
                boolean hasChanges = false;
                
                // Validate new email
                if (newEmail != null && !newEmail.trim().isEmpty() && !newEmail.trim().equals(currentUser.getEmail())) {
                    User existing = userDAO.findByEmail(newEmail.trim());
                    if (existing != null && !existing.getId().equals(currentUser.getId())) {
                        req.setAttribute("errorMessage", "Email này đã được sử dụng.");
                        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
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
                        req.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm cả chữ và số.");
                        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
                        return;
                    } else if (!newPassword.equals(confirmPassword)) {
                        req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
                        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
                        return;
                    }
                    session.setAttribute("pendingNewPassword", newPassword);
                    hasChanges = true;
                }

                if (!hasChanges) {
                    req.setAttribute("errorMessage", "Không có thay đổi nào được yêu cầu.");
                } else {
                    String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : newPhone;
                    boolean isPhone = "phone".equals(otpMethod);
                    
                    // Generate and Send OTP with Fallback logic
                    String otp;
                    try {
                        otp = com.dermathologyai.service.OtpService.generateAndSendOtp(currentUser.getEmail(), phoneToSend, isPhone, 5);
                    } catch (com.dermathologyai.service.CooldownException e) {
                        req.setAttribute("errorMessage", e.getMessage());
                        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
                        return;
                    }
                    String hashedOtp = org.mindrot.jbcrypt.BCrypt.hashpw(otp, org.mindrot.jbcrypt.BCrypt.gensalt());
                    
                    String purpose = isPhone ? "VERIFY_PHONE" : "VERIFY_EMAIL";
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
                    
                    UserToken token = new UserToken(currentUser.getId(), otp, purpose, LocalDateTime.now().plusMinutes(5));
                    
                    if (tokenDAO.create(token)) {
                        session.setAttribute("otpMethod", otpMethod);
                        
                        resp.sendRedirect(req.getContextPath() + "/account/verify-otp");
                        return;
                    } else {
                        req.setAttribute("errorMessage", "Lỗi tạo OTP.");
                    }
                }
            }
        } else if ("verify_security_otp".equals(action)) {
            String otpStr = req.getParameter("otp");
            String otpMethod = (String) session.getAttribute("otpMethod");
            String purpose = "phone".equals(otpMethod) ? "VERIFY_PHONE" : "VERIFY_EMAIL";
            
            UserToken token = tokenDAO.findByUserIdTokenAndPurpose(currentUser.getId(), otpStr, purpose);
            if (token != null) {
                if (token.getAttempts() >= 3) {
                    req.setAttribute("errorMessage", "Quá nhiều lần thử thất bại. Vui lòng yêu cầu OTP mới.");
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
                } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                    req.setAttribute("errorMessage", "OTP đã hết hạn.");
                    tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
                } else {
                    // OTP matches apply pending changes
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
                        tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
                        session.removeAttribute("otpMethod");
                        
                        resp.sendRedirect(req.getContextPath() + "/account/profile?success=security_updated");
                        return;
                    } else {
                        req.setAttribute("errorMessage", "Không có thông tin nào cần cập nhật hoặc cập nhật thất bại.");
                    }
                }
            } else {
                // If token by that OTP string doesn't exist, it means wrong OTP (or expired/deleted)
                // We should increment attempts. But since we need the token record to do so, we must look it up by purpose
                UserToken activeToken = tokenDAO.findByUserIdAndPurpose(currentUser.getId(), purpose);
                if (activeToken != null) {
                    tokenDAO.updateAttempts(activeToken.getId(), activeToken.getAttempts() + 1);
                }
                req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            }
        } else if ("resend_otp".equals(action)) {
            String otpMethod = (String) session.getAttribute("otpMethod");
            String pendingNewPhone = (String) session.getAttribute("pendingNewPhone");
            String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : pendingNewPhone;
            boolean isPhone = "phone".equals(otpMethod);
            String purpose = isPhone ? "VERIFY_PHONE" : "VERIFY_EMAIL";
            
            tokenDAO.deleteByUserIdAndPurpose(currentUser.getId(), purpose);
            
            String otp;
            try {
                otp = com.dermathologyai.service.OtpService.generateAndSendOtp(currentUser.getEmail(), phoneToSend, isPhone, 5);
            } catch (com.dermathologyai.service.CooldownException e) {
                req.setAttribute("errorMessage", e.getMessage());
                forwardToVerifyOtp(req, resp);
                return;
            }
            
            UserToken token = new UserToken(currentUser.getId(), otp, purpose, LocalDateTime.now().plusMinutes(5));
            if (tokenDAO.create(token)) {
                
                req.setAttribute("successMessage", "OTP mới đã được gửi.");
                forwardToVerifyOtp(req, resp);
                return;
            } else {
                req.setAttribute("errorMessage", "Lỗi tạo OTP.");
                forwardToVerifyOtp(req, resp);
                return;
            }
        }

        // Refresh session
        session.setAttribute("user", currentUser);
        
        if ("verify_security_otp".equals(action) || "resend_otp".equals(action) || 
            (req.getRequestURI().endsWith("/account/verify-otp"))) {
            forwardToVerifyOtp(req, resp);
            return;
        }
        
        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
    }

    private void forwardToVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        com.dermathologyai.model.User currentUser = (com.dermathologyai.model.User) session.getAttribute("user");
        
        String otpMethod = (String) session.getAttribute("otpMethod");
        String pendingNewPhone = (String) session.getAttribute("pendingNewPhone");
        String phoneToSend = (currentUser.getPhone() != null && !currentUser.getPhone().isEmpty()) ? currentUser.getPhone() : pendingNewPhone;
        
        String maskedTarget = "";
        if ("phone".equals(otpMethod)) {
            maskedTarget = com.dermathologyai.util.MaskUtil.maskPhone(phoneToSend);
        } else {
            maskedTarget = com.dermathologyai.util.MaskUtil.maskEmail(currentUser.getEmail());
        }

        req.setAttribute("pageTitle", "Xác thực bảo mật");
        req.setAttribute("pageDescription", "Nhập mã OTP chúng tôi vừa gửi đến");
        req.setAttribute("maskedTarget", maskedTarget);
        req.setAttribute("formAction", req.getContextPath() + "/account/verify-otp");
        
        java.util.Map<String, String> hiddenInputs = new java.util.HashMap<>();
        hiddenInputs.put("action", "verify_security_otp");
        req.setAttribute("hiddenInputs", hiddenInputs);
        
        java.util.Map<String, String> resendHiddenInputs = new java.util.HashMap<>();
        resendHiddenInputs.put("action", "resend_otp");
        req.setAttribute("resendHiddenInputs", resendHiddenInputs);
        
        req.setAttribute("otpInputName", "otp");
        req.setAttribute("backLink", req.getContextPath() + "/account/profile");

        req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
    }
}
