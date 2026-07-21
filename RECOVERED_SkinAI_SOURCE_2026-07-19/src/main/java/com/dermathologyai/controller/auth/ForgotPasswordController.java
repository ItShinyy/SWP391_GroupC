package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.PasswordResetTokenDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.PasswordResetToken;
import com.dermathologyai.model.User;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.MaskUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

public class ForgotPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new PasswordResetTokenDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identifier = req.getParameter("identifier");
        if (identifier == null || identifier.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập Email hoặc Số điện thoại.");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        identifier = identifier.trim();



        User user = userDAO.findByUsernameOrEmail(identifier);

        if (user == null) {
            req.setAttribute("errorMessage", "Tài khoản chưa được đăng ký trong hệ thống.");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (user.getGoogleId() != null && !user.getGoogleId().isEmpty()) {
            req.getSession().setAttribute("loginError", "Email này đã được liên kết qua Google. Vui lòng sử dụng nút Đăng nhập bằng Google.");
            resp.sendRedirect(req.getContextPath() + "/auth/login?error=google_logger");
            return;
        }

        // Generate and Send OTP
        // Default to email (isPhone = false), fallback handles if no email
        boolean isPhone = (user.getEmail() == null || user.getEmail().trim().isEmpty());
        String otp;
        try {
            otp = OtpService.generateAndSendOtp(user.getEmail(), user.getPhone(), isPhone, 5);
        } catch (com.dermathologyai.service.CooldownException e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }
        String hashedOtp = OtpService.hashOtp(otp);

        // Invalidate any existing tokens
        tokenDAO.deleteByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");

        PasswordResetToken token = new PasswordResetToken();
        token.setUserId(user.getId());
        token.setToken(hashedOtp);
        token.setPurpose("RESET_PASSWORD");
        token.setExpiresAt(LocalDateTime.now().plusMinutes(5));

        if (tokenDAO.create(token)) {
            // Pass masked identifier back for display
            String maskedIdentifier = isPhone ? MaskUtil.maskPhone(user.getPhone()) : MaskUtil.maskEmail(user.getEmail());
            req.getSession().setAttribute("maskedIdentifier", maskedIdentifier);

            resp.sendRedirect(req.getContextPath() + "/auth/reset-password?identifier=" + identifier);
            return;
        } else {
            req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }
    }
}
