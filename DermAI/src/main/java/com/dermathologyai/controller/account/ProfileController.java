package com.dermathologyai.controller.account;

import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.FamilyMemberDAO;
import com.dermathologyai.util.FormatUtil;
import com.dermathologyai.util.InputValidator;
import com.dermathologyai.util.MaskUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

public class ProfileController extends HttpServlet {
    private AuthService authService;
    private FamilyMemberDAO familyMemberDAO;
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        authService = new AuthService();
        familyMemberDAO = new FamilyMemberDAO();
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        User freshUser = authService.findById(user.getId());
        if (freshUser != null) {
            session.setAttribute("user", freshUser);
        }

        String success = req.getParameter("success");
        if ("security_updated".equals(success)) {
            req.setAttribute("successMessage", "Thông tin bảo mật đã được cập nhật thành công.");
        } else if ("phone_updated".equals(success)) {
            req.setAttribute("successMessage", "Số điện thoại liên hệ đã được cập nhật.");
        }

        String path = req.getRequestURI();
        if (path.endsWith("/verify-old")) {
            forwardToVerifyOtp(req, resp, "old");
        } else if (path.endsWith("/input-new")) {
            if (session.getAttribute("authOldVerified") == null) {
                resp.sendRedirect(req.getContextPath() + "/account/profile");
                return;
            }
            req.setAttribute("target", session.getAttribute("securityTarget"));
            InputValidator.applyPasswordPolicy(req);
            req.getRequestDispatcher("/WEB-INF/views/account/input-new-target.jsp").forward(req, resp);
        } else if (path.endsWith("/verify-new")) {
            if (session.getAttribute("pendingNewValue") == null) {
                resp.sendRedirect(req.getContextPath() + "/account/profile");
                return;
            }
            forwardToVerifyOtp(req, resp, "new");
        } else {
            setMaskedProfileContacts(req, freshUser != null ? freshUser : user);
            if (user.isPatient()) {
                req.setAttribute("familyMembers", familyMemberDAO.findByOwnerUserId(user.getId()));
            }
            if ("DOCTOR".equals(user.getRole())) {
                req.setAttribute("doctorProfile", doctorDAO.findByUserId(user.getId()));
            }
            req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        String target = (String) session.getAttribute("securityTarget");

        try {
            if ("update_contact_phone".equals(action)) {
                authService.updateContactPhone(currentUser, req.getParameter("phone"));
                session.setAttribute("user", authService.findById(currentUser.getId()));
                resp.sendRedirect(req.getContextPath() + "/account/profile?success=phone_updated");
                return;

            } else if ("init_security_change".equals(action)) {
                target = req.getParameter("target"); // EMAIL or PASSWORD only
                if (!"EMAIL".equals(target) && !"PASSWORD".equals(target)) {
                    throw new IllegalArgumentException("Chỉ email hoặc mật khẩu được xác thực bằng OTP email.");
                }
                session.setAttribute("securityTarget", target);
                authService.requestOldTargetOtp(currentUser, target);
                resp.sendRedirect(req.getContextPath() + "/account/verify-old");
                return;

            } else if ("verify_old_otp".equals(action)) {
                String otpStr = req.getParameter("otp");
                authService.verifyOtpTokenOnly(currentUser, otpStr, "EMAIL_CHANGE_OLD");
                session.setAttribute("authOldVerified", true);
                resp.sendRedirect(req.getContextPath() + "/account/input-new");
                return;

            } else if ("submit_new_target".equals(action)) {
                if (session.getAttribute("authOldVerified") == null) throw new IllegalStateException("Hành động không hợp lệ.");

                String newValue = req.getParameter("newValue");
                if ("PASSWORD".equals(target)) {
                    String confirmValue = req.getParameter("confirmValue");
                    InputValidator.requireMatchingPasswords(newValue, confirmValue);
                    authService.changePassword(currentUser, newValue);
                    cleanSession(session);
                    session.setAttribute("user", authService.findById(currentUser.getId()));
                    resp.sendRedirect(req.getContextPath() + "/account/profile?success=security_updated");
                    return;
                }
                authService.requestNewTargetOtp(currentUser, target, newValue);
                session.setAttribute("pendingNewValue", newValue);
                resp.sendRedirect(req.getContextPath() + "/account/verify-new");
                return;

            } else if ("verify_new_otp".equals(action)) {
                String otpStr = req.getParameter("otp");
                String newValue = (String) session.getAttribute("pendingNewValue");
                authService.verifyNewTargetOtpAndUpdate(currentUser, otpStr, target, newValue);

                cleanSession(session);
                session.setAttribute("user", authService.findById(currentUser.getId()));
                resp.sendRedirect(req.getContextPath() + "/account/profile?success=security_updated");
                return;

            } else if ("resend_old_otp".equals(action)) {
                authService.requestOldTargetOtp(currentUser, target);
                req.setAttribute("successMessage", "OTP xác thực đã được gửi lại.");
                forwardToVerifyOtp(req, resp, "old");
                return;

            } else if ("resend_new_otp".equals(action)) {
                String newValue = (String) session.getAttribute("pendingNewValue");
                authService.requestNewTargetOtp(currentUser, target, newValue);
                req.setAttribute("successMessage", "OTP xác thực thông tin mới đã được gửi lại.");
                forwardToVerifyOtp(req, resp, "new");
                return;
            }
        } catch (IllegalArgumentException | IllegalStateException | com.dermathologyai.service.CooldownException e) {
            req.setAttribute("errorMessage", e.getMessage());

            if ("submit_new_target".equals(action)) {
                req.setAttribute("target", target);
                InputValidator.applyPasswordPolicy(req);
                req.getRequestDispatcher("/WEB-INF/views/account/input-new-target.jsp").forward(req, resp);
                return;
            } else if ("init_security_change".equals(action) || "update_contact_phone".equals(action)) {
                setMaskedProfileContacts(req, currentUser);
                if ("DOCTOR".equals(currentUser.getRole())) {
                    req.setAttribute("doctorProfile", doctorDAO.findByUserId(currentUser.getId()));
                }
                req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
                return;
            }

            String step = action != null && action.contains("old") ? "old" : "new";
            forwardToVerifyOtp(req, resp, step);
            return;
        } catch (RuntimeException e) {
            req.setAttribute("errorMessage", e.getMessage());
        }

        setMaskedProfileContacts(req, currentUser);
        if (currentUser != null && "DOCTOR".equals(currentUser.getRole())) {
            req.setAttribute("doctorProfile", doctorDAO.findByUserId(currentUser.getId()));
        }
        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
    }

    private void cleanSession(HttpSession session) {
        session.removeAttribute("securityTarget");
        session.removeAttribute("authOldVerified");
        session.removeAttribute("pendingNewValue");
    }

    private void setMaskedProfileContacts(HttpServletRequest req, User user) {
        req.setAttribute("maskedProfileEmail", user.getEmail() == null ? null : MaskUtil.maskEmail(user.getEmail()));
        req.setAttribute("profilePhone", user.getPhone());
        req.setAttribute("profileCreatedAt", FormatUtil.formatDateTime(user.getCreatedAt()));
    }

    private void forwardToVerifyOtp(HttpServletRequest req, HttpServletResponse resp, String step) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        String target = (String) session.getAttribute("securityTarget");

        boolean isOld = "old".equals(step);

        String maskedTarget = "";
        if (isOld) {
            maskedTarget = MaskUtil.maskEmail(currentUser.getEmail());
            req.setAttribute("pageTitle", "Xác minh danh tính");
            req.setAttribute("pageDescription", "Nhập mã OTP chúng tôi vừa gửi đến email");
        } else {
            String pendingValue = (String) session.getAttribute("pendingNewValue");
            maskedTarget = MaskUtil.maskEmail(pendingValue);
            req.setAttribute("pageTitle", "Xác thực Email mới");
            req.setAttribute("pageDescription", "Nhập mã OTP chúng tôi vừa gửi đến email");
        }

        req.setAttribute("maskedTarget", maskedTarget);
        req.setAttribute("formAction", req.getContextPath() + (isOld ? "/account/verify-old" : "/account/verify-new"));

        req.setAttribute("hiddenInputs", Map.of("action", isOld ? "verify_old_otp" : "verify_new_otp"));
        req.setAttribute("resendHiddenInputs", Map.of("action", isOld ? "resend_old_otp" : "resend_new_otp"));

        req.setAttribute("otpInputName", "otp");
        req.setAttribute("backLink", req.getContextPath() + "/account/profile");
        req.setAttribute("securityTarget", target);

        req.getRequestDispatcher("/WEB-INF/views/global/global-verify-otp.jsp").forward(req, resp);
    }
}
