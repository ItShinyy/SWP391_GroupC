package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.AuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class AuditLogDetailController extends HttpServlet {
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/audit-logs");
            return;
        }

        AuditLog log = auditLogDAO.findById(id);
        if (log == null) {
            req.setAttribute("error", "Audit Log entry not found.");
            req.getRequestDispatcher("/WEB-INF/views/admin/audit-logs/detail.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("log", log);
        req.getRequestDispatcher("/WEB-INF/views/admin/audit-logs/detail.jsp").forward(req, resp);
    }
}
