package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.AccountAppealDAO;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.PasswordResetTokenDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.AccountAppeal;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.model.PasswordResetToken;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.MaskUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

public class LoginController extends HttpServlet {
    private AuthService authService;
    private PasswordResetTokenDAO tokenDAO;
    private AccountAppealDAO appealDAO;
    private AuditLogDAO auditLogDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        userDAO = new UserDAO();
        tokenDAO    = new PasswordResetTokenDAO();
        appealDAO   = new AccountAppealDAO();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String role = ((User) session.getAttribute("user")).getRole();
            resp.sendRedirect(req.getContextPath() + ("ADMIN".equals(role) ? "/admin/dashboard" : "/home"));
            return;
        }
        if (session != null && session.getAttribute("loginError") != null) {
            req.setAttribute("errorMessage", session.getAttribute("loginError"));
            session.removeAttribute("loginError");
        }

        String error = req.getParameter("error");
        if ("account_locked".equals(error)) {
            String lockedUsername = (session != null) ? (String) session.getAttribute("lockedUsername") : null;
            if (lockedUsername != null) {
                User lockedUser = userDAO.findByUsernameOrEmail(lockedUsername);
                if (lockedUser != null) {
                    session.removeAttribute("lockedUsername");
                    handleLockedAccount(req, resp, lockedUser);
                    req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                    return;
                }
            }
            req.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa.");
        } else if (error != null) {
            req.setAttribute("errorMessage", "Đăng nhập thất bại. Vui lòng thử lại.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword  = req.getParameter("usernameOrEmail");
        String password = req.getParameter("password");

        if (keyword == null || password == null || keyword.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin đăng nhập.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        User user = authService.loginLocal(keyword, password);

        if (user != null) {
            // Auto-lock non-ADMIN accounts inactive for > 3 months
            if (!"ADMIN".equals(user.getRole())) {
                LocalDateTime lastActivity = user.getLastLoginAt() != null ? user.getLastLoginAt() : user.getCreatedAt();
                if (lastActivity != null && lastActivity.isBefore(LocalDateTime.now().minusMonths(3))) {
                    authService.lockAccount(user.getId());
                    user.setStatus("LOCKED");
                    user.setLockReason(null); // null = temporary auto-lock
                }
            }

            if (!authService.isAccountActive(user)) {
                if ("LOCKED".equals(user.getStatus())) {
                    auditLogDAO.createLog(user.getId(), "LOGIN_LOCKED", "users", user.getId(), null, "Tài khoản bị khóa", RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                    handleLockedAccount(req, resp, user);
                } else {
                    req.setAttribute("errorMessage", "Tài khoản của bạn chưa được kích hoạt.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                }
                return;
            }

            // Successful login
            auditLogDAO.createLog(user.getId(), "LOGIN_SUCCESS", "users", user.getId(), null, "Đăng nhập bằng form", RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            authService.updateLastLogin(user.getId());
            req.changeSessionId();
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);

            if ("ADMIN".equals(user.getRole())) {
                session.removeAttribute("redirectAfterLogin");
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            }

            String redirect = (String) session.getAttribute("redirectAfterLogin");
            if (redirect != null) {
                session.removeAttribute("redirectAfterLogin");
                resp.sendRedirect(redirect);
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/home");

        } else {
            auditLogDAO.createLog(null, "LOGIN_FAILED", "users", null, null, "Sai thông tin đăng nhập: " + keyword, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            req.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không chính xác.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    /**
     * Handles a LOCKED account:
     *   - lockReason == null → temporary lock (show OTP unlock button)
     *   - lockReason != null → permanent ban (show appeal form or "đang chờ duyệt")
     */
    private void handleLockedAccount(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {

        boolean isTemporaryLocked = (user.getLockReason() == null);

        req.setAttribute("isLocked", true);
        req.setAttribute("isTemporaryLocked", isTemporaryLocked);
        req.setAttribute("lockReason", user.getLockReason());
        req.setAttribute("maskedEmail", MaskUtil.maskEmail(user.getEmail()));
        req.setAttribute("maskedPhone", MaskUtil.maskPhone(user.getPhone()));
        
        // Store email securely in session for OTP send without exposing to UI
        if (isTemporaryLocked) {
            req.getSession().setAttribute("pendingOtpEmail", user.getEmail());
        }

        if (!isTemporaryLocked) {
            // Permanent ban: check if already has pending appeal
            AccountAppeal pendingAppeal = appealDAO.findPendingByUserId(user.getId());
            if (pendingAppeal != null) {
                req.setAttribute("hasPendingAppeal", true);
            } else {
                // Generate a one-time UNLOCK_APPEAL token (15 min TTL)
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_APPEAL");
                String rawToken = UUID.randomUUID().toString();
                PasswordResetToken token = new PasswordResetToken();
                token.setUserId(user.getId());
                token.setToken(rawToken); // plain UUID, not hashed (used as opaque reference)
                token.setPurpose("UNLOCK_APPEAL");
                token.setExpiresAt(LocalDateTime.now().plusMinutes(15));
                tokenDAO.create(token);
                req.setAttribute("appealToken", rawToken);
            }
        }

        req.setAttribute("errorMessage",
            isTemporaryLocked
                ? "Tài khoản của bạn đang bị tạm khóa. Vui lòng xác minh để mở khóa."
                : "Tài khoản của bạn đã bị khóa vĩnh viễn."
        );

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}
