package com.dermathologyai.controller.auth;

import com.dermathologyai.model.PendingRegistration;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.service.OtpService;
import com.dermathologyai.util.MaskUtil;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

public class VerifyController extends HttpServlet {

    private AuthService authService;
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        PendingRegistration pending = pendingOrClear(session);
        if (pending == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.setAttribute("userEmail", MaskUtil.maskEmail(pending.getEmail()));
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
        req.setAttribute("pageDescription", "Chúng tôi đã gửi mã OTP 6 số đến email");
        req.setAttribute("maskedTarget", req.getAttribute("userEmail"));
        req.setAttribute("formAction", req.getContextPath() + "/auth/verify");

        req.setAttribute("hiddenInputs", Map.of("action", "verify_otp"));
        req.setAttribute("resendHiddenInputs", Map.of("action", "resend"));

        req.setAttribute("backLink", req.getContextPath() + "/auth/login");
        req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        PendingRegistration pending = pendingOrClear(session);
        if (pending == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String action = req.getParameter("action");
        if ("verify_otp".equals(action)) {
            String otpInput = req.getParameter("otp");
            if (pending.getAttempts() >= 3) {
                session.setAttribute("verifyError",
                    "Mã OTP đã bị vô hiệu hóa do nhập sai quá 3 lần. Vui lòng nhấn yêu cầu gửi lại.");
                resp.sendRedirect(req.getContextPath() + "/auth/verify");
                return;
            }
            if (otpInput != null && otpInput.trim().equals(pending.getOtp())) {
                try {
                    User savedUser = authService.finalizeRegistration(toUser(pending));
                    req.changeSessionId();
                    session = req.getSession(true);
                    session.setAttribute("user", savedUser);
                    session.removeAttribute(PendingRegistration.SESSION_KEY);
                    auditService.log(savedUser.getId(), "REGISTER", "users", savedUser.getId(),
                        null, null, "Đăng ký tài khoản thành công",
                        RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                    resp.sendRedirect(req.getContextPath() + "/home");
                    return;
                } catch (IllegalArgumentException e) {
                    session.removeAttribute(PendingRegistration.SESSION_KEY);
                    session.setAttribute("registerError", "Email hoặc tên đăng nhập đã được sử dụng.");
                    resp.sendRedirect(req.getContextPath() + "/auth/register");
                    return;
                }
            }
            pending.incrementAttempts();
            if (pending.getAttempts() >= 3) {
                session.setAttribute("verifyError",
                    "Sai OTP lần thứ 3. Mã OTP đã bị vô hiệu hóa. Vui lòng yêu cầu gửi lại.");
            } else {
                session.setAttribute("verifyError",
                    "Mã OTP không chính xác. Bạn còn " + (3 - pending.getAttempts()) + " lần thử.");
            }
            resp.sendRedirect(req.getContextPath() + "/auth/verify");
            return;
        }

        if ("resend".equals(action)) {
            try {
                String newOtp = OtpService.generateAndSendOtp(pending.getEmail(), 15);
                pending.resetForResend(newOtp);
                session.setAttribute(PendingRegistration.SESSION_KEY, pending);
                session.setAttribute("verifySuccess", "Mã xác thực đã được gửi lại thành công.");
            } catch (com.dermathologyai.service.CooldownException e) {
                session.setAttribute("verifyError", e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/auth/verify");
        }
    }

    private static PendingRegistration pendingOrClear(HttpSession session) {
        if (session == null) return null;
        Object raw = session.getAttribute(PendingRegistration.SESSION_KEY);
        if (!(raw instanceof PendingRegistration pending)) {
            return null;
        }
        if (pending.isExpired()) {
            session.removeAttribute(PendingRegistration.SESSION_KEY);
            return null;
        }
        return pending;
    }

    private static User toUser(PendingRegistration pending) {
        User user = new User();
        user.setEmail(pending.getEmail());
        user.setUsername(pending.getUsername());
        user.setFullName(pending.getFullName());
        user.setPhone(pending.getPhone());
        user.setPasswordHash(pending.getPasswordHash());
        user.setAvatar("/assets/images/default-seedling.png");
        user.assignRegisteredPatientRole();
        user.setStatus("ACTIVE");
        return user;
    }
}
