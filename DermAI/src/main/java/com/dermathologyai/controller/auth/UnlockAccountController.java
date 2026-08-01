package com.dermathologyai.controller.auth;

import com.dermathologyai.service.AuthService;
import com.dermathologyai.service.CooldownException;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

public class UnlockAccountController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            req.setAttribute("email", req.getParameter("email"));
            forwardToVerify(req, resp);
        } else {
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verifyOtp(req, resp);
        } else {
            sendOtp(req, resp);
        }
    }

    private void sendOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            email = (String) req.getSession().getAttribute("pendingOtpEmail");
        }
        
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập email.");
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
            return;
        }
        email = email.trim();

        // Cooldown check is now handled automatically inside generateAndSendOtp

        try {
            authService.sendUnlockOtp(email);
            req.getSession().removeAttribute("pendingOtpEmail");
            resp.sendRedirect(req.getContextPath() + "/auth/unlock-account?action=verify&email=" + email);
            return;
        } catch (CooldownException e) {
            req.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
    }

    private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tokenStr = req.getParameter("token");
        String email    = req.getParameter("email");

        if (tokenStr == null || tokenStr.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập mã OTP.");
            req.setAttribute("email", email);
            forwardToVerify(req, resp);
            return;
        }

        try {
            authService.unlockAccountWithOtp(email, tokenStr, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            req.setAttribute("successMessage", "Mở khóa tài khoản thành công! Vui lòng đăng nhập.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        } catch (IllegalStateException e) {
            req.setAttribute("errorMessage", e.getMessage());
        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMessage", e.getMessage());
        }
        
        req.setAttribute("email", email);
        forwardToVerify(req, resp);
    }

    private void forwardToVerify(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("pageTitle", "Xác nhận Mở Khóa");
        req.setAttribute("pageDescription", "Nhập mã 6 số chúng tôi vừa gửi đến");
        req.setAttribute("maskedTarget", req.getAttribute("email"));
        req.setAttribute("formAction", req.getContextPath() + "/auth/unlock-account");
        
        java.util.Map<String, String> hiddenInputs = new java.util.HashMap<>();
        hiddenInputs.put("action", "verify");
        hiddenInputs.put("email", (String) req.getAttribute("email"));
        req.setAttribute("hiddenInputs", hiddenInputs);
        
        java.util.Map<String, String> resendHiddenInputs = new java.util.HashMap<>();
        resendHiddenInputs.put("action", "resend");
        resendHiddenInputs.put("email", (String) req.getAttribute("email"));
        req.setAttribute("resendHiddenInputs", resendHiddenInputs);
        
        req.setAttribute("otpInputName", "token");
        req.setAttribute("backLink", req.getContextPath() + "/auth/unlock-account");

        req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
    }
}
