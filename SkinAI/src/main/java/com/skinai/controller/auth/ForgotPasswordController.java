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
import org.mindrot.jbcrypt.BCrypt;

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
        String identifier = req.getParameter("identifier");
        if (identifier == null || identifier.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập Email hoặc Số điện thoại.");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        identifier = identifier.trim();
        User user = userDAO.findByUsernameOrEmail(identifier);
        
        if (user != null) {
            // Generate 6 digit OTP
            SecureRandom random = new SecureRandom();
            int num = random.nextInt(1000000);
            String otp = String.format("%06d", num);

            // Hash OTP for storage
            String hashedOtp = BCrypt.hashpw(otp, BCrypt.gensalt());

            // Delete old reset tokens for this user
            tokenDAO.deleteByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");

            PasswordResetToken token = new PasswordResetToken();
            token.setUserId(user.getId());
            token.setToken(hashedOtp);
            token.setPurpose("RESET_PASSWORD");
            token.setExpiresAt(LocalDateTime.now().plusMinutes(5)); // TTL 5 mins

            if (tokenDAO.create(token)) {
                // Send OTP based on available contact
                if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                    emailService.sendPasswordResetEmail(user.getEmail(), otp);
                } else if (user.getPhone() != null && !user.getPhone().isEmpty()) {
                    emailService.sendSmsOTP(user.getPhone(), otp);
                }
                resp.sendRedirect(req.getContextPath() + "/auth/reset-password?identifier=" + identifier);
                return;
            } else {
                req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
                req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
                return;
            }
        }

        // Zero-Knowledge response
        resp.sendRedirect(req.getContextPath() + "/auth/reset-password?identifier=" + identifier);
    }
}
