package com.skinai.controller.auth;

import com.skinai.model.User;
import com.skinai.service.AuthService;
import com.skinai.util.ConfigUtil;
import com.skinai.util.GoogleOAuthUtil;
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

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String error = req.getParameter("error");

        if (error != null) {
            logger.warn("Google OAuth error: {}", error);
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }

        if (code == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String clientId = ConfigUtil.get("google.client.id");
        String clientSecret = ConfigUtil.get("google.client.secret");
        String redirectUri = ConfigUtil.get("google.redirect.uri");

        Map<String, String> tokens = GoogleOAuthUtil.exchangeCodeForTokens(code, clientId, clientSecret, redirectUri);
        if (tokens != null && tokens.containsKey("access_token")) {
            String accessToken = tokens.get("access_token");
            Map<String, String> userInfo = GoogleOAuthUtil.getUserInfo(accessToken);

            if (userInfo != null) {
                String googleId = userInfo.get("id");
                String email = userInfo.get("email");
                String name = userInfo.get("name");
                String picture = userInfo.get("picture");

                User user = authService.loginWithGoogle(googleId, email, name, picture);

                if (user != null) {
                    if (!authService.isAccountActive(user)) {
                        resp.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked");
                        return;
                    }

                    // Set user in session
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", user);
                    
                    // Audit log could go here...

                    // Check if redirect was requested
                    String redirectAfterLogin = (String) session.getAttribute("redirectAfterLogin");
                    if (redirectAfterLogin != null) {
                        session.removeAttribute("redirectAfterLogin");
                        resp.sendRedirect(redirectAfterLogin);
                        return;
                    }

                    if ("ADMIN".equals(user.getRole())) {
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/home");
                    }
                    return;
                }
            }
        }

        logger.error("Failed to authenticate with Google");
        resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
    }
}
