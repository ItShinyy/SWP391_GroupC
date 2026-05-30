package com.skinai.controller.auth;

import com.skinai.dal.PasswordResetTokenDAO;
import com.skinai.dal.UserDAO;
import com.skinai.model.PasswordResetToken;
import com.skinai.model.User;
import com.skinai.service.ConsoleEmailServiceImpl;
import com.skinai.service.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.SecureRandom;
import java.time.LocalDateTime;

public class ForgotPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new PasswordResetTokenDAO();
        emailService = new ConsoleEmailServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập email.");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmail(email.trim());
        if (user != null) {
            // Generate 6 digit OTP
            SecureRandom random = new SecureRandom();
            int num = random.nextInt(1000000);
            String otp = String.format("%06d", num);

            PasswordResetToken token = new PasswordResetToken();
            token.setUserId(user.getId());
            token.setToken(otp);
            token.setExpiresAt(LocalDateTime.now().plusMinutes(15)); // Expires in 15 mins

            if (tokenDAO.create(token)) {
                emailService.sendPasswordResetEmail(user.getEmail(), otp);
                resp.sendRedirect(req.getContextPath() + "/auth/reset-password?email=" + email);
                return;
            } else {
                req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            }
        } else {
            // Do not reveal that email does not exist for security reasons, just pretend it was sent or show generic message
            req.setAttribute("errorMessage", "Nếu email tồn tại, mã OTP đã được gửi.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }
}
