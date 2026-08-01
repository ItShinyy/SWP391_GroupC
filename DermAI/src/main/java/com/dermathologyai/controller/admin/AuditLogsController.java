package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.AuditLogDAO;
import com.dermathologyai.model.AuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.List;
import com.dermathologyai.util.PageUtil;
import com.dermathologyai.util.FormatUtil;

public class AuditLogsController extends HttpServlet {
    private AuditLogDAO auditLogDAO;

    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");
        String action = req.getParameter("action"); // 'export' or null

        if ("export".equals(action)) {
            exportCsv(req, resp, keyword, status, startDate, endDate);
            return;
        }

        int page = PageUtil.parsePage(req.getParameter("page"));
        int pageSize = PageUtil.ADMIN_PAGE_SIZE;
        int total = auditLogDAO.countAll(keyword, status, startDate, endDate);
        int totalPages = PageUtil.getTotalPages(total, pageSize);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));

        req.setAttribute("auditLogs", auditLogDAO.findAll(keyword, status, startDate, endDate, page, pageSize));
        PageUtil.setPagingAttributes(req, page, total);
        
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
                    FormatUtil.escapeCsv(timestamp) + "," +
                    FormatUtil.escapeCsv(actor) + "," +
                    FormatUtil.escapeCsv(actionLog) + "," +
                    FormatUtil.escapeCsv(target) + "," +
                    FormatUtil.escapeCsv(stat) + "," +
                    FormatUtil.escapeCsv(ip) + "," +
                    FormatUtil.escapeCsv(device) + "," +
                    FormatUtil.escapeCsv(error)
                );
            }
            writer.flush();
            page++;
        }
    }
}
