package com.skinai.controller.admin;

import com.skinai.dal.UserDAO;
import com.skinai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class AdminUserListController extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int pageSize = 10;
        
        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {}
        }

        List<User> users = userDAO.findAll(page, pageSize);
        int totalUsers = userDAO.countAll();
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        req.setAttribute("users", users);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/WEB-INF/views/admin/users/list.jsp").forward(req, resp);
    }
}
