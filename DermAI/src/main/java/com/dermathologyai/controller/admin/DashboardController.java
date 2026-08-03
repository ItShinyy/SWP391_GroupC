package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.util.PageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Admin dashboard shell; KPIs load from /admin/api/dashboard. */
public class DashboardController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pageStr = req.getParameter("page");
        String sizeStr = req.getParameter("size");
        
        int page = 1;
        int size = 10; // Default size 10
        
        if (pageStr != null && !pageStr.isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (NumberFormatException ignored) {}
        }
        if (sizeStr != null && !sizeStr.isEmpty()) {
            try { size = Integer.parseInt(sizeStr); } catch (NumberFormatException ignored) {}
        }

        DiagnosisReportDAO reportDAO = new DiagnosisReportDAO();
        int totalItems = reportDAO.countAll();
        int totalPages = PageUtil.getTotalPages(totalItems, size);
        
        // Handle out of bounds
        if (page > totalPages && totalPages > 0) page = totalPages;
        if (page < 1) page = 1;

        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("pageSize", size);
        
        // Preserve pageQuery for pagination links
        String pageQuery = "";
        if (size != 10) {
            pageQuery += "&size=" + size;
        }
        req.setAttribute("pageQuery", pageQuery);

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
