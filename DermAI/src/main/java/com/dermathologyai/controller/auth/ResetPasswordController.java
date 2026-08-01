package com.dermathologyai.controller.auth;

import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.CsrfUtil;
import com.dermathologyai.util.InputValidator;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;

public class ResetPasswordController extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        req.setAttribute("csrfToken", CsrfUtil.getToken(session));
        
        String identifier = (String) session.getAttribute("resetIdentifier");
        if (identifier == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        if (session.getAttribute("resetError") != null) {
            req.setAttribute("errorMessage", session.getAttribute("resetError"));
            session.removeAttribute("resetError");
        }
        
        if (session.getAttribute("resetSuccess") != null) {
            req.setAttribute("successMessage", "Nếu thông tin hợp lệ, bạn sẽ nhận được mã OTP.");
            session.removeAttribute("resetSuccess");
        }

        req.setAttribute("identifier", identifier);
        InputValidator.applyPasswordPolicy(req);
        req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        String identifier = (String) session.getAttribute("resetIdentifier");
        
        if (identifier == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        String tokenStr = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        try {
            if (tokenStr == null || tokenStr.isBlank()) {
                throw new IllegalArgumentException("Mã OTP không hợp lệ.");
            }
            InputValidator.requireMatchingPasswords(newPassword, confirmPassword);
            authService.resetPassword(identifier, tokenStr, newPassword, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            session.removeAttribute("resetIdentifier");
            session.setAttribute("loginSuccess", "Đổi mật khẩu thành công! Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        } catch (IllegalStateException e) {
            session.setAttribute("forgotError", e.getMessage());
            session.removeAttribute("resetIdentifier");
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
        } catch (IllegalArgumentException e) {
            session.setAttribute("resetError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
        }
    }
}
