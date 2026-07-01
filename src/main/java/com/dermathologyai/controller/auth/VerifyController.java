package com.dermathologyai.controller.auth;

import com.dermathologyai.model.User;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.RegistrationCache;
import com.dermathologyai.util.MaskUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class VerifyController extends HttpServlet {

    private AuthService authService;
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        auditLogDAO = new AuditLogDAO();
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

        // No longer processing ?token= link directly here as we moved entirely to OTP.

        HttpSession session = req.getSession(false);
        // Case 2: User is redirected here after registration (to wait for email or enter OTP)
        if (session != null) {
            String pendingToken = (String) session.getAttribute("pending_verify_token");
            if (pendingToken != null) {
                RegistrationCache.PendingRegistration pending = RegistrationCache.get(pendingToken);
                if (pending != null) {
                    req.setAttribute("isPhone", pending.isPhone());
                    req.setAttribute("userEmail", pending.getUser().getEmail() != null ? MaskUtil.maskEmail(pending.getUser().getEmail()) : "");
                    req.setAttribute("userPhone", pending.getUser().getPhone() != null ? MaskUtil.maskPhone(pending.getUser().getPhone()) : "");
                    
                    String errorMsg = (String) session.getAttribute("verifyError");
                    if (errorMsg != null) {
                        req.setAttribute("errorMessage", errorMsg);
                        session.removeAttribute("verifyError");
                    }
                    
                    String successMsg = (String) session.getAttribute("verifySuccess");
                    if (successMsg != null) {
                        req.setAttribute("successMessage", successMsg);
                        session.removeAttribute("verifySuccess");
                    }

                    req.setAttribute("pageTitle", "Xác thực tài khoản");
                    req.setAttribute("pageDescription", "Chúng tôi đã gửi mã OTP 6 số đến");
                    req.setAttribute("maskedTarget", pending.isPhone() ? req.getAttribute("userPhone") : req.getAttribute("userEmail"));
                    req.setAttribute("formAction", req.getContextPath() + "/auth/verify");
                    
                    java.util.Map<String, String> hiddenInputs = new java.util.HashMap<>();
                    hiddenInputs.put("action", "verify_otp");
                    req.setAttribute("hiddenInputs", hiddenInputs);
                    
                    java.util.Map<String, String> resendHiddenInputs = new java.util.HashMap<>();
                    resendHiddenInputs.put("action", "resend");
                    req.setAttribute("resendHiddenInputs", resendHiddenInputs);
                    
                    req.setAttribute("backLink", req.getContextPath() + "/auth/login");

                    req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
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
            
            if (pending.getAttempts() >= 3) {
                session.setAttribute("verifyError", "Bạn đã nhập sai quá 3 lần. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                RegistrationCache.remove(pendingToken);
                resp.sendRedirect(req.getContextPath() + "/auth/verify");
                return;
            }
            
            if (otpInput != null && otpInput.trim().equals(pending.getExpectedOtp())) {
                try {
                    User savedUser = authService.finalizeRegistration(pending.getUser());
                    
                    req.changeSessionId();
                    session.setAttribute("user", savedUser);
                    session.removeAttribute("pending_verify_token");
                    
                    auditLogDAO.createLog(savedUser.getId(), "REGISTER", "users", savedUser.getId(), null, null, "Đăng ký tài khoản thành công", RequestUtil.getClientIp(req), req.getHeader("User-Agent"));

                    resp.sendRedirect(req.getContextPath() + "/home");
                    return;
                } catch (IllegalArgumentException e) {
                    session.setAttribute("registerError", "Email hoặc SĐT đã được sử dụng.");
                    resp.sendRedirect(req.getContextPath() + "/auth/register");
                    return;
                }
            } else {
                pending.incrementAttempts();
                int newAttempts = pending.getAttempts();
                if (newAttempts >= 3) {
                    session.setAttribute("verifyError", "Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
                } else {
                    session.setAttribute("verifyError", "Mã OTP không chính xác. Bạn còn " + (3 - newAttempts) + " lần thử.");
                }
                resp.sendRedirect(req.getContextPath() + "/auth/verify");
                return;
            }
        }  
        // Handle Resend
        else if ("resend".equals(action)) {
            try {
                String newOtp = com.dermathologyai.service.OtpService.generateAndSendOtp(
                    pending.getUser().getEmail(), 
                    pending.getUser().getPhone(), 
                    pending.isPhone(), 
                    15
                );
                // Reset expected OTP and attempts
                pending.setExpectedOtp(newOtp);
                // Resetting attempts internally
                RegistrationCache.put(pendingToken, newOtp, pending.getUser(), pending.isPhone());
                
                session.setAttribute("verifySuccess", "Mã xác thực đã được gửi lại thành công.");
                resp.sendRedirect(req.getContextPath() + "/auth/verify");
            } catch (com.dermathologyai.service.CooldownException e) {
                session.setAttribute("verifyError", e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/auth/verify");
            }
        }
    }
}
