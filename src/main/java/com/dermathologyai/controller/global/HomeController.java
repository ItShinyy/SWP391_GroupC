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
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("ADMIN".equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            } else if ("DOCTOR".equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                return;
            }
        }
        // Will be expanded later, for now just forward to JSP
        req.getRequestDispatcher("/WEB-INF/views/global/home.jsp").forward(req, resp);
    }
}
