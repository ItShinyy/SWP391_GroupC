package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class UserStatusController extends HttpServlet {
    private UserDAO userDAO;
    private PatientDAO patientDAO;
    private AuthService authService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        patientDAO = new PatientDAO();
        authService = new AuthService();
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
        String segment = req.getParameter("segment");
        if (segment == null || segment.isBlank()) {
            segment = isEmployeeRole(user.getRole()) ? "employee" : "regular";
        }

        req.setAttribute("targetUser", user);
        req.setAttribute("patient", patient);
        req.setAttribute("action", action);
        req.setAttribute("segment", segment);
        
        req.getRequestDispatcher("/WEB-INF/views/admin/users/status-change.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        String action = req.getParameter("action"); // "lock" or "unlock"
        String reason = req.getParameter("reason");
        String segment = req.getParameter("segment");
        
        if (id != null && !id.trim().isEmpty() && action != null && !action.trim().isEmpty()) {
            jakarta.servlet.http.HttpSession session = req.getSession(false);
            User admin = (session != null) ? (User) session.getAttribute("user") : null;
            String adminId = (admin != null) ? admin.getId() : "system";
            
            String ip = RequestUtil.getClientIp(req);
            String ua = req.getHeader("User-Agent");

            if (action.equals("lock")) {
                authService.lockAccount(id, reason, adminId, ip, ua);
            } else {
                authService.unlockAccount(id, adminId, ip, ua);
            }
            if (segment == null || segment.isBlank()) {
                User target = userDAO.findById(id);
                segment = target != null && isEmployeeRole(target.getRole()) ? "employee" : "regular";
            }
        }
        if (segment == null || segment.isBlank()) {
            segment = "regular";
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users?segment=" + segment);
    }

    private static boolean isEmployeeRole(String role) {
        return "DOCTOR".equals(role) || "ADMIN".equals(role);
    }
}
