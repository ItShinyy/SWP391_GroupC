package com.dermathologyai.controller.auth;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.service.NotificationService;
import com.dermathologyai.util.CsrfUtil;
import com.dermathologyai.util.GoogleAuthUtil;
import com.dermathologyai.util.MaskUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

public class GoogleCallbackController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(GoogleCallbackController.class);
    private AuthService authService;
    private AuditService auditService;
    private NotificationService notificationService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        auditService = new AuditService();
        notificationService = new NotificationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (isLoggedIn(req, resp)) {
            return;
        }

        String code = req.getParameter("code");
        String error = req.getParameter("error");
        HttpSession callbackSession = req.getSession(false);
        String expectedState = callbackSession == null ? null : (String) callbackSession.getAttribute("googleOAuthState");
        if (expectedState == null || !expectedState.equals(req.getParameter("state"))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        callbackSession.removeAttribute("googleOAuthState");
        if (error != null || code == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        GoogleAuthUtil.TokenResponse tokens = GoogleAuthUtil.exchangeCodeForTokens(
                code,
                AppConfig.get("google.client.id"),
                AppConfig.get("google.client.secret"),
                AppConfig.get("google.redirect.uri"));
        if (tokens == null || tokens.access_token == null) {
            logger.error("Failed to exchange Google OAuth code");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }

        GoogleAuthUtil.UserInfoResponse userInfo = GoogleAuthUtil.getUserInfo(tokens.access_token);
        if (userInfo == null) {
            logger.error("Failed to retrieve Google user information");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }
        if (userInfo.email == null || !userInfo.email_verified) {
            req.getSession(true).setAttribute("loginError", "Google chưa xác minh địa chỉ email của bạn.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User linkedGoogleUser = authService.findByGoogleId(userInfo.sub);
        if (linkedGoogleUser == null) {
            User emailAccount = authService.findByEmail(userInfo.email);
            if (emailAccount != null) {
                showLinkConfirmation(req, resp, emailAccount, userInfo);
                return;
            }
        }

        try {
            User user = authService.loginWithGoogle(userInfo.sub, userInfo.email, userInfo.name, userInfo.picture);
            if (userInfo.picture == null || userInfo.picture.isBlank()) {
                logger.warn("Google userinfo returned no picture for sub={}", userInfo.sub);
            }
            completeLogin(req, resp, user);
        } catch (IllegalArgumentException | IllegalStateException e) {
            logger.warn("Google login rejected: {}", e.getMessage());
            req.getSession(true).setAttribute("loginError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        PendingGoogleLink pendingLink = session == null ? null
                : (PendingGoogleLink) session.getAttribute("pendingGoogleLink");
        String action = req.getParameter("action");

        if (pendingLink == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        if ("cancel".equals(action)) {
            clearPendingLink(session);
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        if (!"link".equals(action)) {
            clearPendingLink(session);
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        try {
            User user = authService.linkGoogleAccount(
                    pendingLink.userId, pendingLink.googleId, pendingLink.email,
                    pendingLink.fullName, pendingLink.pictureUrl);
            clearPendingLink(session);
            completeLogin(req, resp, user);
        } catch (IllegalArgumentException | IllegalStateException e) {
            clearPendingLink(session);
            session.setAttribute("loginError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    private boolean isLoggedIn(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return false;
        }
        User user = (User) session.getAttribute("user");
        String destination = "ADMIN".equals(user.getRole()) ? "/admin/dashboard"
                : "DOCTOR".equals(user.getRole()) ? "/doctor/dashboard" : "/home";
        resp.sendRedirect(req.getContextPath() + destination);
        return true;
    }

    private void showLinkConfirmation(HttpServletRequest req, HttpServletResponse resp, User account,
                                      GoogleAuthUtil.UserInfoResponse googleUser) throws ServletException, IOException {
        if (account.getGoogleId() != null && !account.getGoogleId().isBlank()) {
            req.getSession(true).setAttribute("loginError", "Tài khoản này đã được liên kết với Google.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("pendingGoogleLink", new PendingGoogleLink(
                account.getId(), googleUser.sub, googleUser.email, googleUser.name, googleUser.picture));
        req.setAttribute("maskedGoogleEmail", MaskUtil.maskEmail(googleUser.email));
        req.setAttribute("csrfToken", CsrfUtil.getToken(session));
        req.getRequestDispatcher("/WEB-INF/views/auth/link-google-account.jsp").forward(req, resp);
    }

    private void completeLogin(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }
        if (!authService.isAccountActive(user)) {
            HttpSession session = req.getSession(true);
            session.setAttribute("loginError", "Tài khoản của bạn chưa được kích hoạt.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.getSession(true);
        req.changeSessionId();
        HttpSession session = req.getSession(false);
        session.setAttribute("user", user);

        String ip = RequestUtil.getClientIp(req);
        String userAgent = req.getHeader("User-Agent");
        auditService.log(user.getId(), "LOGIN_SUCCESS", "users", user.getId(), null,
                "{\"method\":\"google\"}", null, ip, userAgent);
        notificationService.sendNewLoginAlert(user.getEmail(), ip, userAgent);

        AuthRedirect.afterLogin(req, resp, user);
    }

    private void clearPendingLink(HttpSession session) {
        session.removeAttribute("pendingGoogleLink");
    }

    private static final class PendingGoogleLink {
        private final String userId;
        private final String googleId;
        private final String email;
        private final String fullName;
        private final String pictureUrl;

        private PendingGoogleLink(String userId, String googleId, String email, String fullName, String pictureUrl) {
            this.userId = userId;
            this.googleId = googleId;
            this.email = email;
            this.fullName = fullName;
            this.pictureUrl = pictureUrl;
        }
    }
}
