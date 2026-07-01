package com.dermathologyai.controller.auth;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.AuditLog;
import com.dermathologyai.model.User;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class LogoutController extends HttpServlet {
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }
    
    // Accept both GET and POST for logout simplicity
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                auditLogDAO.createLog(user.getId(), "LOGOUT", "users", user.getId(), null, null, null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
