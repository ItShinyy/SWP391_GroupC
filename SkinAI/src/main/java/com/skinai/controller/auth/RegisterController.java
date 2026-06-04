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

        User user = null;
        try {
            user = authService.prepareRegistration(username, email, phone, fullName, password);
        } catch (IllegalArgumentException e) {
            String errorMsg = e.getMessage();
            if (errorMsg.contains("Username")) {
                resp.sendRedirect(req.getContextPath() + "/auth/register?error=email_exists"); // Mapped to email_exists for now to reuse UI
                return;
            } else if (errorMsg.contains("Email") || errorMsg.contains("điện thoại")) {
                resp.sendRedirect(req.getContextPath() + "/auth/register?error=email_exists");
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
                return;
            }
        }

        if (user != null) {
            boolean isPhone = (email == null);
            String token;
            if (isPhone) {
                // Generate 6 digit OTP
                token = String.format("%06d", new java.util.Random().nextInt(999999));
                System.out.println("DEBUG - Phone OTP: " + token);
            } else {
                // Generate UUID link
                token = java.util.UUID.randomUUID().toString();
                String link = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/auth/verify?token=" + token;
                
                System.out.println("====================================================");
                System.out.println("DEBUG - EMAIL VERIFICATION LINK:");
                System.out.println(link);
                System.out.println("====================================================");

                String emailHtml = com.skinai.mail.MailTemplate.buildVerifyLinkMail(link, 15);
                com.skinai.mail.AsyncMailService.sendAsync(email, "Kích hoạt tài khoản - SkinAI", emailHtml);
            }
            
            com.skinai.util.RegistrationCache.put(token, user, isPhone);

            // Store the token in session just so we can identify the user for RESEND
            HttpSession session = req.getSession(true);
            session.setAttribute("pending_verify_token", token);
            
            resp.sendRedirect(req.getContextPath() + "/auth/verify");
        } else {
            // Registration failed
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
        }
    }
}
