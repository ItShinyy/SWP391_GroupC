package com.dermathologyai.controller.auth;

import com.dermathologyai.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Shared post-login redirect for local and Google login. */
final class AuthRedirect {
    private AuthRedirect() {}

    static void afterLogin(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        HttpSession session = req.getSession(false);
        if ("ADMIN".equals(user.getRole())) {
            if (session != null) session.removeAttribute("redirectAfterLogin");
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }
        if ("DOCTOR".equals(user.getRole())) {
            if (session != null) session.removeAttribute("redirectAfterLogin");
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        String redirect = session == null ? null : (String) session.getAttribute("redirectAfterLogin");
        if (redirect != null) {
            session.removeAttribute("redirectAfterLogin");
            resp.sendRedirect(redirect);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
