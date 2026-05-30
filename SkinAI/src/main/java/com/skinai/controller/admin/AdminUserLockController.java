package com.skinai.controller.admin;

import com.skinai.dal.UserDAO;
import com.skinai.model.User;
import com.skinai.service.AuditService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AdminUserLockController extends HttpServlet {
    private UserDAO userDAO;
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        auditService = new AuditService();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        String reason = req.getParameter("reason");
        
        if (id != null && !id.trim().isEmpty()) {
            boolean success = userDAO.updateStatus(id, "LOCKED");
            if (success) {
                HttpSession session = req.getSession(false);
                User admin = (session != null) ? (User) session.getAttribute("user") : null;
                String adminId = (admin != null) ? admin.getId() : "system";
                
                String ip = (String) req.getAttribute("clientIp");
                String ua = (String) req.getAttribute("userAgent");
                
                String newValues = "LOCKED";
                if (reason != null && !reason.trim().isEmpty()) {
                    newValues += " (Reason: " + reason.trim() + ")";
                }
                
                auditService.log(adminId, "LOCK_USER", "User", id, "ACTIVE", newValues, ip, ua);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
