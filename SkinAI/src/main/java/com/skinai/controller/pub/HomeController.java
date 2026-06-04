package com.skinai.controller.pub;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Will be expanded later, for now just forward to JSP
        req.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(req, resp);
    }
}
