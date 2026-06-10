package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.dao.AccountAppealDAO;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.PasswordResetTokenDAO;
import com.dermathologyai.model.PasswordResetToken;
import com.dermathologyai.model.User;
import com.dermathologyai.model.AccountAppeal;
import com.dermathologyai.model.AuditLog;
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
    private PasswordResetTokenDAO tokenDAO;
    private AccountAppealDAO appealDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new PasswordResetTokenDAO();
        appealDAO = new AccountAppealDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            req.setAttribute("email", req.getParameter("email"));
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verifyOtp(req, resp);
        } else if ("appeal".equals(action)) {
            handleAppeal(req, resp);
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

            tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");

            PasswordResetToken token = new PasswordResetToken(
                user.getId(), hashedOtp, "UNLOCK_APPEAL", LocalDateTime.now().plusMinutes(5)
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
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
            return;
        }

        User user = (email != null) ? userDAO.findByEmail(email.trim()) : null;
        if (user == null) {
            req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
            return;
        }

        PasswordResetToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");
        if (token != null) {
            if (token.getAttempts() >= 3) {
                req.setAttribute("errorMessage", "Nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");
            } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                req.setAttribute("errorMessage", "Mã OTP đã hết hạn (Quá 5 phút). Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");
            } else if (OtpService.verifyOtp(tokenStr.trim(), token.getToken())) {
                // OTP matches → unlock account
                userDAO.updateStatus(user.getId(), "ACTIVE");
                userDAO.updateLastLogin(user.getId());
                // Success: Unlock the account
                user.setStatus("ACTIVE");
                user.setLockReason(null);
                userDAO.update(user);
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");
                
                auditLogDAO.createLog(user.getId(), "ACCOUNT_UNLOCKED", "users", user.getId(), null, "Mở khóa tài khoản thành công qua OTP", RequestUtil.getClientIp(req), req.getHeader("User-Agent"));

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
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
            }
        } else {
            req.setAttribute("errorMessage", "Mã OTP không chính xác hoặc đã hết hạn.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
        }
    }

    private void handleAppeal(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String appealTokenStr = req.getParameter("appeal_token");
        String appealText     = req.getParameter("appeal_text");

        if (appealTokenStr == null || appealTokenStr.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Thiếu appeal_token.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }
        if (appealText == null || appealText.trim().length() < 20 || appealText.trim().length() > 1000) {
            req.setAttribute("errorMessage", "Nội dung kháng cáo phải từ 20 đến 1000 ký tự.");
            req.setAttribute("isLocked", true);
            req.setAttribute("isTemporaryLocked", false);
            req.setAttribute("appealToken", appealTokenStr);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        PasswordResetToken token = tokenDAO.findByToken(appealTokenStr.trim());

        if (token == null || !"UNLOCK_APPEAL".equals(token.getPurpose()) || token.getUsedAt() != null) {
            req.setAttribute("errorMessage", "Token không hợp lệ hoặc đã được sử dụng.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (token.getExpiresAt() != null && token.getExpiresAt().isBefore(LocalDateTime.now())) {
            req.setAttribute("errorMessage", "Token đã hết hạn. Vui lòng đăng nhập lại để nhận token mới.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        String userId = token.getUserId();

        AccountAppeal appeal = new AccountAppeal();
        appeal.setUserId(userId);
        appeal.setTokenId(token.getId());
        appeal.setAppealText(appealText.trim());

        String result = appealDAO.create(appeal);

        if ("DUPLICATE".equals(result)) {
            req.setAttribute("errorMessage", "Bạn đã có yêu cầu đang được xử lý. Vui lòng chờ Admin xem xét.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }
        if ("ERROR".equals(result)) {
            req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        tokenDAO.markUsed(token.getId());

        AuditLog log = new AuditLog();
        log.setUserId(userId);
        log.setAction("SUBMIT_APPEAL");
        log.setEntityType("account_appeals");
        log.setNewValues("{\"status\":\"PENDING\"}");
        log.setIpAddress(req.getRemoteAddr());
        log.setUserAgent(req.getHeader("User-Agent"));
        auditLogDAO.create(log);

        req.setAttribute("successMessage", "Yêu cầu kháng cáo đã được gửi thành công. Admin sẽ xem xét sớm nhất.");
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}
