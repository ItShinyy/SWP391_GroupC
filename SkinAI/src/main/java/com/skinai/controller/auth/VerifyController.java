package com.skinai.controller.auth;

import com.skinai.model.User;
import com.skinai.service.AuthService;
import com.skinai.util.RegistrationCache;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class VerifyController extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("check".equals(action)) {
            HttpSession session = req.getSession(false);
            boolean isVerified = (session != null && session.getAttribute("user") != null);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"verified\": " + isVerified + "}");
            return;
        }

        String tokenParam = req.getParameter("token");
        HttpSession session = req.getSession(false);

        // Case 1: User clicked the link from their email
        if (tokenParam != null && !tokenParam.trim().isEmpty()) {
            RegistrationCache.PendingRegistration pending = RegistrationCache.get(tokenParam);
            if (pending != null) {
                // Verified! Finalize registration
                try {
                    User savedUser = authService.finalizeRegistration(pending.getUser());
                    RegistrationCache.remove(tokenParam);
                    
                    if (savedUser != null) {
                        // Auto login
                        HttpSession newSession = req.getSession(true);
                        newSession.setAttribute("user", savedUser);
                        newSession.removeAttribute("pending_verify_token");
                        resp.sendRedirect(req.getContextPath() + "/home");
                        return;
                    }
                } catch (IllegalArgumentException e) {
                    req.setAttribute("errorMessage", e.getMessage());
                }
            } else {
                req.setAttribute("errorMessage", "Đường dẫn xác thực không hợp lệ hoặc đã hết hạn.");
            }
            req.getRequestDispatcher("/WEB-INF/views/auth/verify_error.jsp").forward(req, resp);
            return;
        }

        // Case 2: User is redirected here after registration (to wait for email or enter OTP)
        if (session != null) {
            String pendingToken = (String) session.getAttribute("pending_verify_token");
            if (pendingToken != null) {
                RegistrationCache.PendingRegistration pending = RegistrationCache.get(pendingToken);
                if (pending != null) {
                    req.setAttribute("isPhone", pending.isPhone());
                    req.setAttribute("userEmail", pending.getUser().getEmail());
                    req.setAttribute("userPhone", pending.getUser().getPhone());
                    
                    String error = req.getParameter("error");
                    if ("invalid_otp".equals(error)) {
                        req.setAttribute("errorMessage", "Mã OTP không chính xác.");
                    } else if ("cooldown".equals(error)) {
                        req.setAttribute("errorMessage", "Vui lòng đợi 60 giây trước khi yêu cầu gửi lại mã.");
                    }
                    
                    String success = req.getParameter("success");
                    if ("resent".equals(success)) {
                        req.setAttribute("successMessage", "Mã xác thực đã được gửi lại thành công.");
                    }

                    req.getRequestDispatcher("/WEB-INF/views/auth/verify.jsp").forward(req, resp);
                    return;
                }
            }
        }
        
        // No pending registration found
        resp.sendRedirect(req.getContextPath() + "/auth/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String pendingToken = (String) session.getAttribute("pending_verify_token");
        if (pendingToken == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        RegistrationCache.PendingRegistration pending = RegistrationCache.get(pendingToken);
        if (pending == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Handle OTP Submit
        if ("verify_otp".equals(action)) {
            String otpInput = req.getParameter("otp");
            if (pendingToken.equals(otpInput)) {
                try {
                    User savedUser = authService.finalizeRegistration(pending.getUser());
                    RegistrationCache.remove(pendingToken);
                    
                    req.changeSessionId();
                    session.setAttribute("user", savedUser);
                    session.removeAttribute("pending_verify_token");
                    resp.sendRedirect(req.getContextPath() + "/home");
                    return;
                } catch (IllegalArgumentException e) {
                    // E.g. email was taken while waiting
                    resp.sendRedirect(req.getContextPath() + "/auth/register?error=email_exists");
                    return;
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/verify?error=invalid_otp");
                return;
            }
        } 
        // Handle Resend
        else if ("resend".equals(action)) {
            try {
                RegistrationCache.updateLastSent(pendingToken);
                
                // Resend Logic
                if (pending.isPhone()) {
                    System.out.println("DEBUG - RESEND Phone OTP: " + pendingToken);
                } else {
                    String link = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort() + req.getContextPath() + "/auth/verify?token=" + pendingToken;
                    String emailHtml = com.skinai.mail.MailTemplate.buildVerifyLinkMail(link, 15);
                    com.skinai.mail.AsyncMailService.sendAsync(pending.getUser().getEmail(), "Kích hoạt tài khoản - SkinAI", emailHtml);
                }
                
                resp.sendRedirect(req.getContextPath() + "/auth/verify?success=resent");
            } catch (IllegalStateException e) {
                // Cooldown exception
                resp.sendRedirect(req.getContextPath() + "/auth/verify?error=cooldown");
            }
        }
    }
}
