package com.skinai.controller.admin;

import com.skinai.dal.AuditLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class AuditLogsController extends HttpServlet {
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int pageSize = 20;

        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        String search = req.getParameter("search");
        String action = req.getParameter("action");

        req.setAttribute("auditLogs", auditLogDAO.findAll(search, action, page, pageSize));
        
        int total = auditLogDAO.countAll(search, action);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("currentPage", page);

        req.getRequestDispatcher("/WEB-INF/views/admin/audit-logs.jsp").forward(req, resp);
    }
}
