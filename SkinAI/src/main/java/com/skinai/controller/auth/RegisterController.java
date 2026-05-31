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
            req.setAttribute("errorMessage", "Email or Username is already registered. Please login.");
        } else if ("invalid_input".equals(error)) {
            req.setAttribute("errorMessage", "Invalid input data. Please check your information.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");

        // Validate basic requirements
        if (username == null || fullName == null || password == null ||
            username.trim().isEmpty() || fullName.trim().isEmpty() || password.trim().isEmpty() || password.length() < 6) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }
        
        // Normalize
        username = username.trim();
        fullName = fullName.trim();
        if (email != null && !email.trim().isEmpty()) {
            email = email.trim().toLowerCase();
        } else {
            email = null;
        }
        
        if (phone != null && !phone.trim().isEmpty()) {
            phone = phone.replaceAll("\\s+", "");
        } else {
            phone = null;
        }
        
        // Must provide at least email or phone
        if (email == null && phone == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        User user = authService.registerLocal(username, email, phone, fullName, password);

        if (user != null) {
            // Auto login after registration and prevent session fixation
            req.changeSessionId(); // Zero-Trust: Regenerate Session ID
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            // Registration failed (email or phone exists)
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=email_exists");
        }
    }
}
