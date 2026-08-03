package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.NotificationDAO;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Admin Notifications — reuses NotificationDAO and the patient notifications JSP.
 * Routes to /admin/notifications.
 * Admins see their own user-id notifications (system alerts, billing events, etc.)
 */
public class AdminNotificationsController extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getAdminUser(req, resp);
        if (user == null) return;

        if ("count".equals(req.getParameter("format"))) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"unread\":" + notificationDAO.countUnreadByUserId(user.getId()) + "}");
            return;
        }

        req.setAttribute("notifications", notificationDAO.findByUserId(user.getId()));
        req.getRequestDispatcher("/WEB-INF/views/admin/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getAdminUser(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        if ("mark-read".equals(action)) {
            notificationDAO.markRead(req.getParameter("notificationId"), user.getId());
        } else if ("mark-all-read".equals(action)) {
            notificationDAO.markAllRead(user.getId());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/notifications");
    }

    private User getAdminUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        if (!user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }
}