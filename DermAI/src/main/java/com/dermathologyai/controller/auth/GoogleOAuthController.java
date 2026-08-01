package com.dermathologyai.controller.auth;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.util.GoogleAuthUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

public class GoogleOAuthController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clientId = AppConfig.get("google.client.id");
        String redirectUri = AppConfig.get("google.redirect.uri");
        String scope = AppConfig.get("google.scope", "openid email profile");
        HttpSession session = req.getSession(true);
        String state = UUID.randomUUID().toString();
        session.setAttribute("googleOAuthState", state);

        String authUrl = GoogleAuthUtil.buildAuthUrl(clientId, redirectUri, scope, state);
        resp.sendRedirect(authUrl);
    }
}
