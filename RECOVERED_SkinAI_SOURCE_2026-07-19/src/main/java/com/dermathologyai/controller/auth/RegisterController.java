package com.dermathologyai.controller.auth;

import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.InputValidator;
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
        
        HttpSession sessionObj = req.getSession(false);
        if (sessionObj != null && sessionObj.getAttribute("registerError") != null) {
            req.setAttribute("errorMessage", sessionObj.getAttribute("registerError"));
            sessionObj.removeAttribute("registerError");
        } else if ("email_exists".equals(error)) {
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
            phone = phone.trim();
        } else {
            phone = null;
        }
        
        // Must provide at least email or phone
        if (email == null && phone == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        try {
            username = InputValidator.normalizeUsername(username);
        } catch (IllegalArgumentException e) {
            req.getSession().setAttribute("registerError", "Username không hợp lệ (không được chứa khoảng trắng).");
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        if (!InputValidator.isValidPassword(password)) {
            req.getSession().setAttribute("registerError", "Mật khẩu phải chứa ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.");
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        User user = null;
        try {
            user = authService.prepareRegistration(username, email, phone, fullName, password);
        } catch (IllegalArgumentException e) {
            req.getSession().setAttribute("registerError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        if (user != null) {
            boolean isPhone = (email == null);
            String sessionToken = java.util.UUID.randomUUID().toString();
            
            // Generate and send OTP (Fallback handled inside OtpService)
            String otp;
            try {
                otp = com.dermathologyai.service.OtpService.generateAndSendOtp(email, phone, isPhone, 15);
            } catch (com.dermathologyai.service.CooldownException e) {
                req.setAttribute("errorMessage", e.getMessage());
                req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
                return;
            }
            
            com.dermathologyai.util.RegistrationCache.put(sessionToken, otp, user, isPhone);

            // Store the token in session just so we can identify the user for RESEND
            HttpSession session = req.getSession(true);
            session.setAttribute("pending_verify_token", sessionToken);
            
            resp.sendRedirect(req.getContextPath() + "/auth/verify");
        } else {
            // Registration failed
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
        }
    }
}
