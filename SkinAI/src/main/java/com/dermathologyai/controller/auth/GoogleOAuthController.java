package com.dermathologyai.controller.auth;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.util.GoogleAuthUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class GoogleOAuthController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clientId = AppConfig.get("google.client.id");
        String redirectUri = AppConfig.get("google.redirect.uri");
        String scope = AppConfig.get("google.scope", "openid email profile");

        String authUrl = GoogleAuthUtil.buildAuthUrl(clientId, redirectUri, scope);
        resp.sendRedirect(authUrl);
    }
}
