package com.skinai.controller.auth;

import com.skinai.dal.PasswordResetTokenDAO;
import com.skinai.dal.UserDAO;
import com.skinai.model.PasswordResetToken;
import com.skinai.model.User;
import org.mindrot.jbcrypt.BCrypt;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

public class ResetPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private PasswordResetTokenDAO tokenDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new PasswordResetTokenDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identifier = req.getParameter("identifier");
        req.setAttribute("identifier", identifier);
        req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identifier = req.getParameter("identifier");
        String tokenStr = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (tokenStr == null || newPassword == null || !newPassword.equals(confirmPassword) || newPassword.length() < 6 || identifier == null) {
            req.setAttribute("errorMessage", "Mã OTP hoặc mật khẩu không hợp lệ (Mật khẩu phải từ 6 ký tự và khớp nhau).");
            req.setAttribute("identifier", identifier);
            req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByUsernameOrEmail(identifier);
        if (user == null) {
            req.setAttribute("errorMessage", "Mã OTP không chính xác hoặc đã hết hạn.");
            req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        PasswordResetToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
        
        if (token != null) {
            if (token.getAttempts() >= 3) {
                req.setAttribute("errorMessage", "Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã OTP mới.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
                req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
                return;
            }

            if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                req.setAttribute("errorMessage", "Mã OTP đã hết hạn. Vui lòng yêu cầu lại.");
                tokenDAO.deleteByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
            } else {
                // Verify hash
                if (BCrypt.checkpw(tokenStr, token.getToken())) {
                    user.setPasswordHash(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                    userDAO.update(user);
                    tokenDAO.deleteByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
                    req.setAttribute("successMessage", "Đổi mật khẩu thành công! Vui lòng đăng nhập.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                    return;
                } else {
                    tokenDAO.updateAttempts(token.getId(), token.getAttempts() + 1);
                    req.setAttribute("errorMessage", "Mã OTP không chính xác.");
                }
            }
        } else {
            req.setAttribute("errorMessage", "Mã OTP không chính xác hoặc không tồn tại.");
        }

        req.setAttribute("identifier", identifier);
        req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
    }
}
