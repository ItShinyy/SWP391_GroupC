package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuditService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class UserStatusController extends HttpServlet {
    private UserDAO userDAO;
    private PatientDAO patientDAO;
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        patientDAO = new PatientDAO();
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        String action = req.getParameter("action"); // "lock" or "unlock"
        
        if (id == null || id.trim().isEmpty() || action == null || action.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        User user = userDAO.findById(id);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Patient patient = patientDAO.findByUserId(user.getId());

        req.setAttribute("targetUser", user);
        req.setAttribute("patient", patient);
        req.setAttribute("action", action);
        
        req.getRequestDispatcher("/WEB-INF/views/admin/users/status-change.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        String action = req.getParameter("action"); // "lock" or "unlock"
        String reason = req.getParameter("reason");
        
        if (id != null && !id.trim().isEmpty() && action != null && !action.trim().isEmpty()) {
            String newStatus = action.equals("lock") ? "LOCKED" : "ACTIVE";
            boolean success = userDAO.updateStatus(id, newStatus);
            if (success) {
                jakarta.servlet.http.HttpSession session = req.getSession(false);
                User admin = (session != null) ? (User) session.getAttribute("user") : null;
                String adminId = (admin != null) ? admin.getId() : "system";
                
                String ip = (String) req.getAttribute("clientIp");
                String ua = (String) req.getAttribute("userAgent");
                
                String newValues = newStatus;
                if (reason != null && !reason.trim().isEmpty()) {
                    newValues += " (Reason: " + reason.trim() + ")";
                }
                
                String logAction = action.equals("lock") ? "LOCK_USER" : "UNLOCK_USER";
                String oldStatus = action.equals("lock") ? "ACTIVE" : "LOCKED";
                auditService.log(adminId, logAction, "User", id, oldStatus, newValues, ip, ua);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
