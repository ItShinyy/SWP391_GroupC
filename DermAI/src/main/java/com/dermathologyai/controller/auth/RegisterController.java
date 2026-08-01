package com.dermathologyai.controller.auth;

import com.dermathologyai.model.PendingRegistration;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.service.OtpService;
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
        if (sessionObj != null) {
            if (sessionObj.getAttribute("registerError") != null) {
                req.setAttribute("errorMessage", sessionObj.getAttribute("registerError"));
                sessionObj.removeAttribute("registerError");
            }
            String[] fields = {"reg_username", "reg_fullName", "reg_email", "reg_phone"};
            for (String field : fields) {
                if (sessionObj.getAttribute(field) != null) {
                    req.setAttribute(field, sessionObj.getAttribute(field));
                    sessionObj.removeAttribute(field);
                }
            }
        }

        if ("email_exists".equals(error) && req.getAttribute("errorMessage") == null) {
            req.setAttribute("errorMessage", "Email or Username is already registered. Please login.");
        } else if ("invalid_input".equals(error) && req.getAttribute("errorMessage") == null) {
            req.setAttribute("errorMessage", "Invalid input data. Please check your information.");
        }

        InputValidator.applyPasswordPolicy(req);
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");

        HttpSession formSession = req.getSession(true);
        formSession.setAttribute("reg_username", username);
        formSession.setAttribute("reg_fullName", fullName);
        formSession.setAttribute("reg_email", email);
        formSession.setAttribute("reg_phone", phone);

        if (username == null || fullName == null || password == null
            || username.trim().isEmpty() || fullName.trim().isEmpty() || password.trim().isEmpty()) {
            formSession.setAttribute("registerError", "Vui lòng nhập đầy đủ thông tin.");
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        username = username.trim();
        fullName = fullName.trim();
        email = (email != null && !email.trim().isEmpty()) ? email.trim().toLowerCase() : null;
        phone = (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null;

        if (email == null) {
            formSession.setAttribute("registerError", "Email là bắt buộc để đăng ký và nhận mã OTP.");
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        try {
            username = InputValidator.normalizeUsername(username);
        } catch (IllegalArgumentException e) {
            formSession.setAttribute("registerError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        User prepared;
        try {
            prepared = authService.prepareRegistration(username, email, phone, fullName, password);
        } catch (IllegalArgumentException e) {
            formSession.setAttribute("registerError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/register?error=invalid_input");
            return;
        }

        String otp;
        try {
            otp = OtpService.generateAndSendOtp(email, 15);
        } catch (com.dermathologyai.service.CooldownException e) {
            req.setAttribute("errorMessage", e.getMessage());
            InputValidator.applyPasswordPolicy(req);
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        formSession.removeAttribute("reg_username");
        formSession.removeAttribute("reg_fullName");
        formSession.removeAttribute("reg_email");
        formSession.removeAttribute("reg_phone");

        // One session → one pending; replaces any previous pending registration
        formSession.setAttribute(PendingRegistration.SESSION_KEY,
            new PendingRegistration(
                prepared.getEmail(), prepared.getUsername(), prepared.getFullName(),
                prepared.getPhone(), prepared.getPasswordHash(), otp));

        resp.sendRedirect(req.getContextPath() + "/auth/verify");
    }
}
