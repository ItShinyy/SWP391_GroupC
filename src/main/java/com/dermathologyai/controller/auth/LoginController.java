package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.UserToken;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.CsrfUtil;
import com.dermathologyai.util.MaskUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class LoginController extends HttpServlet {
    private AuthService authService;
    private UserTokenDAO tokenDAO;
    private AuditLogDAO auditLogDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        userDAO = new UserDAO();
        tokenDAO    = new UserTokenDAO();
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

        // Generate CSRF token for the login form
        req.setAttribute("csrfToken", CsrfUtil.getToken(req.getSession(true)));

        // Handle flash messages
        if (session != null && session.getAttribute("loginError") != null) {
            req.setAttribute("errorMessage", session.getAttribute("loginError"));
            session.removeAttribute("loginError");
        }
        if (session != null && session.getAttribute("loginSuccess") != null) {
            req.setAttribute("successMessage", session.getAttribute("loginSuccess"));
            session.removeAttribute("loginSuccess");
        }

        if (session != null && session.getAttribute("login_keyword") != null) {
            req.setAttribute("login_keyword", session.getAttribute("login_keyword"));
            session.removeAttribute("login_keyword");
        }

        // Handle locked account display from flash
        if (session != null && session.getAttribute("lockedUser") != null) {
            User lockedUser = (User) session.getAttribute("lockedUser");
            session.removeAttribute("lockedUser");
            handleLockedAccountDisplay(req, lockedUser);
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword  = req.getParameter("usernameOrEmail");
        String password = req.getParameter("password");
        HttpSession session = req.getSession(true);

        if (keyword == null || password == null || keyword.trim().isEmpty() || password.trim().isEmpty()) {
            if (keyword != null) {
                session.setAttribute("login_keyword", keyword);
            }
            session.setAttribute("loginError", "Vui lòng nhập đầy đủ thông tin đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        session.setAttribute("login_keyword", keyword);

        AuthService.LoginResult result = authService.loginLocal(keyword, password);
        User user = result.user;

        if (result.status == AuthService.LoginResultStatus.SUCCESS) {
            // Check manual INACTIVE state (e.g. from registration before verify)
            if (!authService.isAccountActive(user)) {
                session.setAttribute("loginError", "Tài khoản của bạn chưa được kích hoạt.");
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            }

            auditLogDAO.createLog(user.getId(), "LOGIN_SUCCESS", "users", user.getId(), null, "{\"method\":\"local\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            
            // Session fixation protection
            req.changeSessionId();
            session = req.getSession(true);
            session.setAttribute("user", user);
            session.removeAttribute("login_keyword");

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

        } else if (result.status == AuthService.LoginResultStatus.ACCOUNT_LOCKED) {
            String reason = "Tài khoản bị khóa";
            if ("BRUTE_FORCE".equals(user.getLockType())) {
                reason = "Khóa tự động do nhập sai mật khẩu 5 lần";
            } else if (user.getLockReason() != null) {
                reason = "Khóa bởi Admin: " + user.getLockReason();
            }
            
            auditLogDAO.createLog(user.getId(), "LOGIN_LOCKED", "users", user.getId(), null, "{\"reason\":\"" + reason + "\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            session.setAttribute("lockedUser", user);
            resp.sendRedirect(req.getContextPath() + "/auth/login");

        } else {
            // INVALID_CREDENTIALS
            auditLogDAO.createLog(user != null ? user.getId() : null, "LOGIN_FAILED", "users", null, null, "{\"keyword\":\"" + keyword + "\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            session.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu không chính xác.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    /**
     * Prepares request attributes for displaying locked account state (OTP unlock)
     */
    private void handleLockedAccountDisplay(HttpServletRequest req, User user) {
        // If BRUTE_FORCE or lockReason is null, it's considered temporary
        boolean isTemporaryLocked = "BRUTE_FORCE".equals(user.getLockType()) || user.getLockType() == null;

        req.setAttribute("isLocked", true);
        req.setAttribute("isTemporaryLocked", isTemporaryLocked);
        req.setAttribute("lockReason", user.getLockReason());
        if (user.getEmail() != null) {
            req.setAttribute("maskedEmail", MaskUtil.maskEmail(user.getEmail()));
        }
        if (user.getPhone() != null) {
            req.setAttribute("maskedPhone", MaskUtil.maskPhone(user.getPhone()));
        }
        
        // Store email securely in session for OTP send without exposing to UI
        if (isTemporaryLocked) {
            req.getSession().setAttribute("pendingOtpEmail", user.getEmail());
        }

        req.setAttribute("errorMessage",
            isTemporaryLocked
                ? "Tài khoản của bạn đã bị khóa tạm thời. Vui lòng xác minh để mở khóa."
                : "Tài khoản của bạn đã bị khóa vĩnh viễn."
        );
    }
}
