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

public class UnlockAccountController extends HttpServlet {
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
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            req.setAttribute("email", req.getParameter("email"));
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
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
            req.setAttribute("errorMessage", "Vui lòng nhập email.");
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmail(email.trim());
        if (user != null && "LOCKED".equals(user.getStatus())) {
            SecureRandom random = new SecureRandom();
            int num = random.nextInt(1000000);
            String otp = String.format("%06d", num);
            String hashedOtp = BCrypt.hashpw(otp, BCrypt.gensalt());

            // Delete old unlock tokens for this user
            tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");

            PasswordResetToken token = new PasswordResetToken(user.getId(), hashedOtp, "UNLOCK_ACCOUNT", LocalDateTime.now().plusMinutes(5));

            if (tokenDAO.create(token)) {
                // Mock email
                System.out.println(">>> [UNLOCK ACCOUNT OTP] " + email + " : " + otp);
                resp.sendRedirect(req.getContextPath() + "/auth/unlock-account?action=verify&email=" + email);
                return;
            } else {
                req.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            }
        } else {
            // Zero-Knowledge: don't reveal whether account exists or is locked
            req.setAttribute("errorMessage", "Nếu tài khoản tồn tại và bị khóa, mã OTP đã được gửi.");
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/unlock-account.jsp").forward(req, resp);
    }

    private void verifyOtp(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tokenStr = req.getParameter("token");
        String email = req.getParameter("email");

        if (tokenStr == null || tokenStr.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập mã OTP.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
            return;
        }

        User user = (email != null) ? userDAO.findByEmail(email.trim()) : null;
        if (user == null) {
            req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
            return;
        }

        PasswordResetToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
        if (token != null) {
            if (token.getAttempts() >= 3) {
                req.setAttribute("errorMessage", "Nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
            } else if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                req.setAttribute("errorMessage", "Mã OTP đã hết hạn (Quá 5 phút). Vui lòng yêu cầu mã mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
            } else if (BCrypt.checkpw(tokenStr, token.getToken())) {
                // OTP matches
                userDAO.updateStatus(user.getId(), "ACTIVE");
                userDAO.updateLastLogin(user.getId());
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "UNLOCK_ACCOUNT");
                
                req.setAttribute("successMessage", "Mở khóa tài khoản thành công! Vui lòng đăng nhập.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                return;
            } else {
                tokenDAO.updateAttempts(token.getId(), token.getAttempts() + 1);
                req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            }
        } else {
            req.setAttribute("errorMessage", "Mã OTP không chính xác.");
        }
        req.setAttribute("email", email);
        req.getRequestDispatcher("/WEB-INF/views/auth/unlock-verify.jsp").forward(req, resp);
    }
}
