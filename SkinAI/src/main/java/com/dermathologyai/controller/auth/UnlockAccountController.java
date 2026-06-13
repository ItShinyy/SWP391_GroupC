package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.model.UserToken;
import com.dermathologyai.model.User;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

public class UnlockAccountController extends HttpServlet {
    private UserDAO userDAO;
    private UserTokenDAO tokenDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new UserTokenDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            req.setAttribute("email", req.getParameter("email"));
            forwardToVerify(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verifyOtp(req, resp);
        } else {
            sendOtp(req, resp);
        }
    }

    private void sendOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            email = (String) req.getSession().getAttribute("pendingOtpEmail");
        }
        
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập email.");
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
            return;
        }
        email = email.trim();

        // Cooldown check is now handled automatically inside generateAndSendOtp

        User user = userDAO.findByEmail(email);
        if (user != null && "LOCKED".equals(user.getStatus()) && user.getLockReason() == null) {
            // Only temporary-locked accounts can use OTP unlock
            boolean isPhone = (user.getEmail() == null || user.getEmail().trim().isEmpty());
            String otp;
            try {
                otp = OtpService.generateAndSendOtp(user.getEmail(), user.getPhone(), isPhone, 5);
            } catch (com.dermathologyai.service.CooldownException e) {
                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
                return;
            }
            String hashedOtp = OtpService.hashOtp(otp);

            tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");

            UserToken token = new UserToken(
                user.getId(), hashedOtp, "UNLOCK_ACCOUNT", LocalDateTime.now().plusMinutes(5)
            );

            if (tokenDAO.create(token)) {
                // Record sent is now handled inside generateAndSendOtp
                req.getSession().removeAttribute("pendingOtpEmail");
                resp.sendRedirect(req.getContextPath() + "/auth/unlock-account?action=verify&email=" + email);
                return;
            } else {
                req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            }
        } else {
            // Zero-Knowledge: don't reveal whether account exists
            OtpService.recordSent(email); // still record to prevent enumeration timing attacks
            req.setAttribute("infoMessage", "Nếu tài khoản tồn tại và bị khóa tạm thời, mã OTP đã được gửi.");
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
    }

    private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tokenStr = req.getParameter("token");
        String email    = req.getParameter("email");

        if (tokenStr == null || tokenStr.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập mã OTP.");
            req.setAttribute("email", email);
            forwardToVerify(req, resp);
            return;
        }

        User user = (email != null) ? userDAO.findByEmail(email.trim()) : null;
        if (user == null) {
            req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            forwardToVerify(req, resp);
            return;
        }

        UserToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
        if (token != null) {
            if (token.getAttempts() >= 3) {
                req.setAttribute("errorMessage", "Nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
            } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                req.setAttribute("errorMessage", "Mã OTP đã hết hạn (Quá 5 phút). Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
            } else if (OtpService.verifyOtp(tokenStr.trim(), token.getToken())) {
                // OTP matches → unlock account
                userDAO.updateStatus(user.getId(), "ACTIVE");
                userDAO.updateLastLogin(user.getId());
                // Success: Unlock the account
                user.setStatus("ACTIVE");
                user.setLockReason(null);
                userDAO.update(user);
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                
                auditLogDAO.createLog(user.getId(), "ACCOUNT_UNLOCKED", "users", user.getId(), null, "Mở khóa tài khoản thành công qua OTP", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));

                req.setAttribute("successMessage", "Mở khóa tài khoản thành công! Vui lòng đăng nhập.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                return;
            } else {
               if (tokenDAO.updateAttempts(token.getId(), token.getAttempts() + 1)) {
                if (token.getAttempts() + 1 >= 5) {
                    req.setAttribute("errorMessage", "Đã quá số lần nhập sai. Vui lòng gửi lại OTP.");
                } else {
                    req.setAttribute("errorMessage", "Mã OTP không chính xác.");
                }
            } else {
                req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            }
            req.setAttribute("email", email);
            forwardToVerify(req, resp);
            }
        } else {
            req.setAttribute("errorMessage", "Mã OTP không chính xác hoặc đã hết hạn.");
            req.setAttribute("email", email);
            forwardToVerify(req, resp);
        }
    }

    private void forwardToVerify(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Xác nhận Mở Khóa");
        req.setAttribute("pageDescription", "Nhập mã 6 số chúng tôi vừa gửi đến");
        req.setAttribute("maskedTarget", req.getAttribute("email"));
        req.setAttribute("formAction", req.getContextPath() + "/auth/unlock-account");
        
        java.util.Map<String, String> hiddenInputs = new java.util.HashMap<>();
        hiddenInputs.put("action", "verify");
        hiddenInputs.put("email", (String) req.getAttribute("email"));
        req.setAttribute("hiddenInputs", hiddenInputs);
        
        java.util.Map<String, String> resendHiddenInputs = new java.util.HashMap<>();
        resendHiddenInputs.put("action", "resend");
        resendHiddenInputs.put("email", (String) req.getAttribute("email"));
        req.setAttribute("resendHiddenInputs", resendHiddenInputs);
        
        req.setAttribute("otpInputName", "token");
        req.setAttribute("backLink", req.getContextPath() + "/auth/unlock-account");

        req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
    }
}
