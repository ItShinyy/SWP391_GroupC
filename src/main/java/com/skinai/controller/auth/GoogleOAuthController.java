package com.skinai.controller.auth;

import com.skinai.util.ConfigUtil;
import com.skinai.util.GoogleOAuthUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class GoogleOAuthController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clientId = ConfigUtil.get("google.client.id");
        String redirectUri = ConfigUtil.get("google.redirect.uri");
        String scope = ConfigUtil.get("google.scope", "openid email profile");

        String authUrl = GoogleOAuthUtil.buildAuthUrl(clientId, redirectUri, scope);
        resp.sendRedirect(authUrl);
    }
}
