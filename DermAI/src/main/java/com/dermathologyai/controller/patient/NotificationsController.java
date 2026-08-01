package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.NotificationDAO;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class NotificationsController extends HttpServlet {
    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getPatientUser(req, resp);
        if (user == null) return;

        if ("count".equals(req.getParameter("format"))) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"unread\":" + notificationDAO.countUnreadByUserId(user.getId()) + "}");
            return;
        }

        req.setAttribute("notifications", notificationDAO.findByUserId(user.getId()));
        req.getRequestDispatcher("/WEB-INF/views/patient/notifications.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = getPatientUser(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        if ("mark-read".equals(action)) {
            notificationDAO.markRead(req.getParameter("notificationId"), user.getId());
        } else if ("mark-all-read".equals(action)) {
            notificationDAO.markAllRead(user.getId());
        }
        resp.sendRedirect(req.getContextPath() + "/patient/notifications");
    }

    private User getPatientUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        if (!user.isPatient()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }
}
