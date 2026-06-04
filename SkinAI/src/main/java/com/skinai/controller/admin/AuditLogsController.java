package com.skinai.controller.admin;

import com.skinai.dal.AuditLogDAO;
import com.skinai.model.AuditLog;
import com.skinai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class AuditLogsController extends HttpServlet {
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // RBAC: Only ADMIN (Super Admin) allowed
        User loggedInUser = (User) req.getSession().getAttribute("user");
        if (loggedInUser == null || !"ADMIN".equals(loggedInUser.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied. Only SUPER_ADMIN can access Audit Logs.");
            return;
        }

        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");
        String action = req.getParameter("action"); // 'export' or null

        if ("export".equals(action)) {
            exportCsv(req, resp, keyword, status, startDate, endDate);
            return;
        }

        int page = 1;
        int pageSize = 20;
        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }

        req.setAttribute("auditLogs", auditLogDAO.findAll(keyword, status, startDate, endDate, page, pageSize));
        
        int total = auditLogDAO.countAll(keyword, status, startDate, endDate);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("currentPage", page);
        
        req.setAttribute("keyword", keyword);
        req.setAttribute("status", status);
        req.setAttribute("startDate", startDate);
        req.setAttribute("endDate", endDate);

        req.getRequestDispatcher("/WEB-INF/views/admin/audit-logs/list.jsp").forward(req, resp);
    }

    private void exportCsv(HttpServletRequest req, HttpServletResponse resp, 
                           String keyword, String status, String startDate, String endDate) throws IOException {
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"audit_logs.csv\"");
        
        // Write BOM for UTF-8 Excel compatibility
        resp.getOutputStream().write(0xEF);
        resp.getOutputStream().write(0xBB);
        resp.getOutputStream().write(0xBF);

        PrintWriter writer = new PrintWriter(resp.getOutputStream(), true, java.nio.charset.StandardCharsets.UTF_8);
        writer.println("Timestamp,Actor,Action,Target,Status,IP,Device,Error Message");

        int page = 1;
        int pageSize = 1000;
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        while (true) {
            List<AuditLog> logs = auditLogDAO.findAll(keyword, status, startDate, endDate, page, pageSize);
            if (logs.isEmpty()) break;

            for (AuditLog log : logs) {
                String timestamp = log.getCreatedAt() != null ? log.getCreatedAt().format(dtf) : "";
                String actor = log.getUserName() != null ? log.getUserName() : "";
                String actionLog = log.getAction() != null ? log.getAction() : "";
                String target = (log.getEntityType() != null ? log.getEntityType() : "") + 
                                (log.getRecordId() != null ? " (" + log.getRecordId() + ")" : "");
                String stat = log.getStatus() != null ? log.getStatus() : "";
                String ip = log.getIpAddress() != null ? log.getIpAddress() : "";
                String device = log.getUserAgent() != null ? log.getUserAgent() : "";
                String error = log.getErrorMessage() != null ? log.getErrorMessage() : "";

                writer.println(
                    escapeCsv(timestamp) + "," +
                    escapeCsv(actor) + "," +
                    escapeCsv(actionLog) + "," +
                    escapeCsv(target) + "," +
                    escapeCsv(stat) + "," +
                    escapeCsv(ip) + "," +
                    escapeCsv(device) + "," +
                    escapeCsv(error)
                );
            }
            writer.flush();
            page++;
        }
    }

    private String escapeCsv(String value) {
        if (value == null || value.isEmpty()) return "\"\"";
        
        // Anti CSV Injection
        if (value.startsWith("=") || value.startsWith("+") || value.startsWith("-") || value.startsWith("@")) {
            value = "'" + value;
        }

        // Escape quotes
        value = value.replace("\"", "\"\"");
        return "\"" + value + "\"";
    }
}
