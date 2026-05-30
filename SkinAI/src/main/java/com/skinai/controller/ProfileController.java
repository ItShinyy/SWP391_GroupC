package com.skinai.controller;

import com.skinai.dal.UserDAO;
import com.skinai.model.User;
import org.mindrot.jbcrypt.BCrypt;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.regex.Pattern;
import com.skinai.dal.PasswordResetTokenDAO;
import com.skinai.model.PasswordResetToken;
import com.skinai.service.ConsoleEmailServiceImpl;
import com.skinai.service.EmailService;

public class ProfileController extends HttpServlet {
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
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Refresh user data from DB to get latest info
        User freshUser = userDAO.findById(user.getId());
        session.setAttribute("user", freshUser);
        
        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        if ("update_info".equals(action)) {
            String fullName = req.getParameter("fullName");
            String username = req.getParameter("username");
            
            if (fullName != null && !fullName.trim().isEmpty() && username != null && !username.trim().isEmpty()) {
                // Check if username is taken by someone else
                User existing = userDAO.findByUsernameOrEmail(username);
                if (existing != null && !existing.getId().equals(currentUser.getId())) {
                    req.setAttribute("errorMessage", "Tên đăng nhập đã tồn tại!");
                } else {
                    currentUser.setFullName(fullName.trim());
                    currentUser.setUsername(username.trim());
                    if (userDAO.update(currentUser)) {
                        req.setAttribute("successMessage", "Cập nhật thông tin thành công!");
                    } else {
                        req.setAttribute("errorMessage", "Lỗi khi cập nhật thông tin.");
                    }
                }
            } else {
                req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin.");
            }
        } else if ("request_change_password".equals(action)) {
            String oldPassword = req.getParameter("oldPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");

            if (newPassword == null || newPassword.length() < 8 || 
                !Pattern.compile("(?=.*[a-zA-Z])(?=.*[0-9])").matcher(newPassword).find()) {
                req.setAttribute("errorMessage", "Mật khẩu mới phải từ 8 kí tự, bao gồm chữ và số.");
            } else if (!newPassword.equals(confirmPassword)) {
                req.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            } else if (oldPassword != null && newPassword.equals(oldPassword)) {
                req.setAttribute("errorMessage", "Mật khẩu mới phải khác mật khẩu cũ.");
            } else {
                if (currentUser.getPasswordHash() != null && BCrypt.checkpw(oldPassword, currentUser.getPasswordHash())) {
                    // Generate OTP
                    String otp = String.format("%06d", new SecureRandom().nextInt(1000000));
                    PasswordResetToken token = new PasswordResetToken(currentUser.getId(), otp, LocalDateTime.now().plusMinutes(5));
                    if (tokenDAO.create(token)) {
                        emailService.sendPasswordResetEmail(currentUser.getEmail(), otp);
                        session.setAttribute("pendingPassword", BCrypt.hashpw(newPassword, BCrypt.gensalt()));
                        req.setAttribute("successMessage", "Mã OTP đã được gửi đến email của bạn.");
                    } else {
                        req.setAttribute("errorMessage", "Lỗi tạo OTP.");
                    }
                } else {
                    req.setAttribute("errorMessage", "Mật khẩu cũ không chính xác.");
                }
            }
        } else if ("verify_password_otp".equals(action)) {
            String otpStr = req.getParameter("otp");
            PasswordResetToken token = tokenDAO.findByToken(otpStr);
            if (token != null && token.getUserId().equals(currentUser.getId())) {
                if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                    req.setAttribute("errorMessage", "Mã OTP đã hết hạn.");
                } else {
                    String pendingPwd = (String) session.getAttribute("pendingPassword");
                    if (pendingPwd != null) {
                        currentUser.setPasswordHash(pendingPwd);
                        if (userDAO.update(currentUser)) {
                            req.setAttribute("successMessage", "Đổi mật khẩu thành công!");
                            session.removeAttribute("pendingPassword");
                        }
                    }
                }
                tokenDAO.deleteByToken(otpStr);
            } else {
                req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            }
        } else if ("request_change_email".equals(action)) {
            String newEmail = req.getParameter("newEmail");
            if (newEmail != null && !newEmail.trim().isEmpty()) {
                User existing = userDAO.findByEmail(newEmail.trim());
                if (existing != null) {
                    req.setAttribute("errorMessage", "Email này đã được sử dụng.");
                } else {
                    String otp = String.format("%06d", new SecureRandom().nextInt(1000000));
                    PasswordResetToken token = new PasswordResetToken(currentUser.getId(), otp, LocalDateTime.now().plusMinutes(5));
                    if (tokenDAO.create(token)) {
                        emailService.sendPasswordResetEmail(newEmail.trim(), otp);
                        session.setAttribute("pendingEmail", newEmail.trim());
                        req.setAttribute("successMessage", "Mã OTP đã được gửi đến email mới của bạn.");
                    } else {
                        req.setAttribute("errorMessage", "Lỗi tạo OTP.");
                    }
                }
            }
        } else if ("verify_email_otp".equals(action)) {
            String otpStr = req.getParameter("otp");
            PasswordResetToken token = tokenDAO.findByToken(otpStr);
            if (token != null && token.getUserId().equals(currentUser.getId())) {
                if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
                    req.setAttribute("errorMessage", "Mã OTP đã hết hạn.");
                } else {
                    String pendingEmail = (String) session.getAttribute("pendingEmail");
                    if (pendingEmail != null) {
                        currentUser.setEmail(pendingEmail);
                        if (userDAO.update(currentUser)) {
                            req.setAttribute("successMessage", "Đổi email thành công!");
                            session.removeAttribute("pendingEmail");
                        }
                    }
                }
                tokenDAO.deleteByToken(otpStr);
            } else {
                req.setAttribute("errorMessage", "Mã OTP không chính xác.");
            }
        }

        // Refresh session
        session.setAttribute("user", currentUser);
        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
    }
}
