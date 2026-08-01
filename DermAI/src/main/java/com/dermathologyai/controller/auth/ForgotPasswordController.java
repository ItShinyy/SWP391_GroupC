package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.service.CooldownException;
import com.dermathologyai.util.CsrfUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class ForgotPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        req.setAttribute("csrfToken", CsrfUtil.getToken(session));

        if (session.getAttribute("forgotError") != null) {
            req.setAttribute("errorMessage", session.getAttribute("forgotError"));
            session.removeAttribute("forgotError");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identifier = req.getParameter("identifier");
        HttpSession session = req.getSession(true);

        if (identifier == null || identifier.trim().isEmpty()) {
            session.setAttribute("forgotError", "Vui lòng nhập Email hoặc Tên đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        identifier = identifier.trim();
        User user = userDAO.findByUsernameOrEmail(identifier);

        // Anti-enumeration: If user not found, we act as if successful
        if (user == null) {
            session.setAttribute("resetSuccess", true);
            session.setAttribute("resetIdentifier", identifier);
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
            return;
        }

        if (user.getGoogleId() != null && !user.getGoogleId().isEmpty()
                && (user.getPasswordHash() == null || user.getPasswordHash().isEmpty())) {
            session.setAttribute("loginError", "Email này đã được liên kết qua Google. Vui lòng sử dụng Đăng nhập bằng Google.");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=google_logger");
            return;
        }

        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            session.setAttribute("forgotError", "Tài khoản không có email để nhận mã OTP.");
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        try {
            if (authService.sendResetPasswordOtp(user)) {
                session.setAttribute("resetIdentifier", identifier);
                session.setAttribute("resetSuccess", true);
                resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
            } else {
                session.setAttribute("forgotError", "Lỗi hệ thống. Vui lòng thử lại sau.");
                resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            }
        } catch (CooldownException e) {
            session.setAttribute("forgotError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("forgotError", "Lỗi gửi email: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
        }
    }
}
