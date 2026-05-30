package com.skinai.controller.auth;

import com.skinai.model.User;
import com.skinai.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class RegisterController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String error = req.getParameter("error");
        if ("email_exists".equals(error)) {
            req.setAttribute("errorMessage", "Email is already registered. Please login.");
        } else if ("invalid_input".equals(error)) {
            req.setAttribute("errorMessage", "Invalid input data. Please check your information.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (fullName == null || email == null || password == null ||
            fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || password.length() < 6) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        User user = authService.registerLocal(email.trim(), fullName.trim(), password);

        if (user != null) {
            // Auto login after registration
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            // Registration failed (email exists)
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=email_exists");
        }
    }
}
