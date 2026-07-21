package com.dermathologyai.controller.auth;

import com.dermathologyai.model.User;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.config.AppConfig;
import com.dermathologyai.util.GoogleAuthUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Map;

public class GoogleCallbackController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(GoogleCallbackController.class);
    private AuthService authService;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String error = req.getParameter("error");

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User existingUser = (User) session.getAttribute("user");
            if ("ADMIN".equals(existingUser.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home");
            }
            return;
        }

        if (error != null) {
            logger.warn("Google OAuth error: {}", error);
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }

        if (code == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String clientId = AppConfig.get("google.client.id");
        String clientSecret = AppConfig.get("google.client.secret");
        String redirectUri = AppConfig.get("google.redirect.uri");

        Map<String, String> tokens = GoogleAuthUtil.exchangeCodeForTokens(code, clientId, clientSecret, redirectUri);
        if (tokens != null && tokens.containsKey("access_token")) {
            String accessToken = tokens.get("access_token");
            Map<String, String> userInfo = GoogleAuthUtil.getUserInfo(accessToken);

            if (userInfo != null) {
                String googleId = userInfo.get("id");
                String email = userInfo.get("email");
                String name = userInfo.get("name");
                String picture = userInfo.get("picture");

                User user = authService.loginWithGoogle(googleId, email, name);

                if (user != null) {
                    if (!authService.isAccountActive(user)) {
                        req.getSession(true).setAttribute("lockedUsername", user.getUsername());
                        resp.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked");
                        return;
                    }

                    // Zero-Trust: Prevent session fixation
                    req.changeSessionId();
                    
                    // Set user in session
                    session = req.getSession(true);
                    session.setAttribute("user", user);
                    
                    // Audit log
                    auditLogDAO.createLog(user.getId(), "LOGIN_SUCCESS", "users", user.getId(), null, "Đăng nhập bằng Google", RequestUtil.getClientIp(req), req.getHeader("User-Agent"));

                    if ("ADMIN".equals(user.getRole())) {
                        session.removeAttribute("redirectAfterLogin");
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                        return;
                    }

                    // Check if redirect was requested
                    String redirectAfterLogin = (String) session.getAttribute("redirectAfterLogin");
                    if (redirectAfterLogin != null) {
                        session.removeAttribute("redirectAfterLogin");
                        resp.sendRedirect(redirectAfterLogin);
                        return;
                    }

                    // Default redirect based on role
                    resp.sendRedirect(req.getContextPath() + "/home");
                    return;
                }
            }
        }

        logger.error("Failed to authenticate with Google");
        resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
    }
}
