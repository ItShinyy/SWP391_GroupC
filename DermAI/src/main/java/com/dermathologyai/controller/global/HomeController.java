package com.dermathologyai.controller.global;

import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user != null && "DOCTOR".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        if (user != null && "ADMIN".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/global/home.jsp").forward(req, resp);
    }
}
