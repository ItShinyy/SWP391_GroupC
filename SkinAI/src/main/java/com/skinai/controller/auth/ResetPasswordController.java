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
        String email = req.getParameter("email");
        req.setAttribute("email", email);
        req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tokenStr = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (tokenStr == null || newPassword == null || !newPassword.equals(confirmPassword) || newPassword.length() < 6) {
            req.setAttribute("errorMessage", "Mã OTP hoặc mật khẩu không hợp lệ (Mật khẩu phải từ 6 ký tự và khớp nhau).");
            req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        PasswordResetToken token = tokenDAO.findByToken(tokenStr);
        if (token != null) {
            if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                req.setAttribute("errorMessage", "Mã OTP đã hết hạn. Vui lòng yêu cầu lại.");
                tokenDAO.deleteByToken(tokenStr);
            } else {
                User user = userDAO.findById(token.getUserId());
                if (user != null) {
                    user.setPasswordHash(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                    userDAO.update(user);
                    tokenDAO.deleteByToken(tokenStr);
                    req.setAttribute("successMessage", "Đổi mật khẩu thành công! Vui lòng đăng nhập.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                    return;
                }
            }
        } else {
            req.setAttribute("errorMessage", "Mã OTP không chính xác.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(req, resp);
    }
}
