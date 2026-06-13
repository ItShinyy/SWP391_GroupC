package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.UserToken;
import com.dermathologyai.model.User;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.CsrfUtil;
import com.dermathologyai.util.MaskUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;

public class ForgotPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private UserTokenDAO tokenDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new UserTokenDAO();
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
            session.setAttribute("forgotError", "Vui lòng nhập Email hoặc Số điện thoại.");
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        identifier = identifier.trim();
        User user = userDAO.findByUsernameOrEmail(identifier);

        // Anti-enumeration: If user not found, we act as if successful
        if (user == null) {
            // Fake success message
            session.setAttribute("resetSuccess", true);
            session.setAttribute("resetIdentifier", identifier);
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
            return;
        }

        if (user.getGoogleId() != null && !user.getGoogleId().isEmpty()) {
            session.setAttribute("loginError", "Email này đã được liên kết qua Google. Vui lòng sử dụng Đăng nhập bằng Google.");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=google_logger");
            return;
        }

        // Generate and Send OTP
        boolean isPhone = (user.getEmail() == null || user.getEmail().trim().isEmpty());
        String otp;
        try {
            otp = OtpService.generateAndSendOtp(user.getEmail(), user.getPhone(), isPhone, 5);
        } catch (com.dermathologyai.service.CooldownException e) {
            session.setAttribute("forgotError", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("forgotError", "Lỗi gửi email/SMS: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }
        String hashedOtp = OtpService.hashOtp(otp);

        // Invalidate any existing tokens
        tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");

        UserToken token = new UserToken();
        token.setUserId(user.getId());
        token.setToken(hashedOtp);
        token.setPurpose("RESET_PASSWORD");
        token.setExpiresAt(LocalDateTime.now().plusMinutes(5));

        if (tokenDAO.create(token)) {
            // Securely store identifier in session instead of URL
            session.setAttribute("resetIdentifier", identifier);
            session.setAttribute("resetSuccess", true); // Trigger the "Nếu thông tin hợp lệ..." message
            
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
        } else {
            session.setAttribute("forgotError", "Lỗi hệ thống. Vui lòng thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
        }
    }
}
