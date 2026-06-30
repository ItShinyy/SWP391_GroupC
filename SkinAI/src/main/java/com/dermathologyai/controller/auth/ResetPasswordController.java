package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.UserTokenDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.UserToken;
import com.dermathologyai.model.User;
import com.dermathologyai.util.CsrfUtil;
import com.dermathologyai.util.RequestUtil;
import org.mindrot.jbcrypt.BCrypt;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;

public class ResetPasswordController extends HttpServlet {
    private UserDAO userDAO;
    private UserTokenDAO tokenDAO;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        tokenDAO = new UserTokenDAO();
        auditLogDAO = new AuditLogDAO();
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

        if (tokenStr == null || newPassword == null || !newPassword.equals(confirmPassword) || newPassword.length() < 6) {
            session.setAttribute("resetError", "Mã OTP hoặc mật khẩu không hợp lệ (Mật khẩu phải từ 6 ký tự và khớp nhau).");
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
            return;
        }

        User user = userDAO.findByUsernameOrEmail(identifier);
        if (user == null) {
            session.setAttribute("resetError", "Mã OTP không chính xác hoặc đã hết hạn.");
            resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
            return;
        }

        UserToken token = tokenDAO.findByUserIdAndPurpose(user.getId(), "RESET_PASSWORD");
        
        if (token != null) {
            if (token.getAttempts() >= 3) {
                session.setAttribute("forgotError", "Bạn đã nhập sai quá 3 lần. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
                session.removeAttribute("resetIdentifier");
                resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
                return;
            }

            if (token.getExpiresAt().isBefore(LocalDateTime.now()) || token.getUsedAt() != null) {
                session.setAttribute("resetError", "Mã OTP đã hết hạn hoặc đã được sử dụng. Vui lòng yêu cầu lại.");
                tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
            } else if (BCrypt.checkpw(tokenStr, token.getToken())) {
                userDAO.updatePassword(user.getId(), BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                tokenDAO.markUsed(token.getId());
                
                auditLogDAO.createLog(user.getId(), "PASSWORD_RESET", "users", user.getId(), null, "{\"method\":\"otp\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));

                session.removeAttribute("resetIdentifier");
                session.setAttribute("loginSuccess", "Đổi mật khẩu thành công! Vui lòng đăng nhập.");
                resp.sendRedirect(req.getContextPath() + "/auth/login");
                return;
            } else {
                int newAttempts = tokenDAO.incrementAttempts(token.getId());
                if (newAttempts >= 3) {
                    session.setAttribute("forgotError", "Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                    tokenDAO.invalidateAllByUserAndPurpose(user.getId(), "RESET_PASSWORD");
                    session.removeAttribute("resetIdentifier");
                    resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
                    return;
                } else {
                    session.setAttribute("resetError", "Mã OTP không chính xác. Bạn còn " + (3 - newAttempts) + " lần thử.");
                }
            }
        } else {
            session.setAttribute("resetError", "Mã OTP không chính xác hoặc không tồn tại.");
        }

        resp.sendRedirect(req.getContextPath() + "/auth/reset-password");
    }
}
