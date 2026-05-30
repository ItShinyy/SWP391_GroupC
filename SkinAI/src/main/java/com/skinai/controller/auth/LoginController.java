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
        if ("account_locked_inactive".equals(error)) {
            req.setAttribute("errorMessage", "Tài khoản bị khóa do không hoạt động trên 3 tháng. Vui lòng mở khóa để tiếp tục.");
        } else if ("account_locked".equals(error)) {
            req.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
        } else if ("auth_failed".equals(error)) {
            req.setAttribute("errorMessage", "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("usernameOrEmail");
        String password = req.getParameter("password");

        if (keyword == null || password == null || keyword.trim().isEmpty() || password.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
            return;
        }

        User user = authService.loginLocal(keyword, password);

        if (user != null) {
            // Auto-lock PATIENT accounts inactive for > 3 months
            if ("PATIENT".equals(user.getRole())) {
                java.time.LocalDateTime lastActivity = user.getLastLoginAt() != null ? user.getLastLoginAt() : user.getCreatedAt();
                if (lastActivity != null && lastActivity.isBefore(java.time.LocalDateTime.now().minusMonths(3))) {
                    authService.lockAccount(user.getId());
                    user.setStatus("LOCKED");
                }
            }

            if (!authService.isAccountActive(user)) {
                if ("LOCKED".equals(user.getStatus())) {
                    resp.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked_inactive");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked");
                }
                return;
            }

            // Update last_login_at
            authService.updateLastLogin(user.getId());

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);

            if ("ADMIN".equals(user.getRole())) {
                session.removeAttribute("redirectAfterLogin");
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            }

            String redirectAfterLogin = (String) session.getAttribute("redirectAfterLogin");
            if (redirectAfterLogin != null) {
                session.removeAttribute("redirectAfterLogin");
                resp.sendRedirect(redirectAfterLogin);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/home");
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=auth_failed");
        }
    }
}
