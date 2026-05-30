package com.skinai.controller.auth;

import com.skinai.model.User;
import com.skinai.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class LoginController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // Already logged in
            String role = ((com.skinai.model.User) session.getAttribute("user")).getRole();
            if ("ADMIN".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/home");
            }
            return;
        }

        // Pass error message to JSP if any
        String error = req.getParameter("error");
        if ("account_locked".equals(error)) {
            req.setAttribute("errorMessage", "Your account has been locked. Please contact support.");
        } else if ("auth_failed".equals(error)) {
            req.setAttribute("errorMessage", "Authentication failed. Please try again.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }

        User user = authService.loginLocal(email, password);

        if (user != null) {
            if (!authService.isAccountActive(user)) {
                resp.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked");
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);

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
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
        }
    }
}
