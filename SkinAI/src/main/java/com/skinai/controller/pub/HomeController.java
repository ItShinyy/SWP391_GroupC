package com.skinai.controller.pub;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            com.skinai.model.User user = (com.skinai.model.User) session.getAttribute("user");
            if ("ADMIN".equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            }
        }
        // Will be expanded later, for now just forward to JSP
        req.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(req, resp);
    }
}
