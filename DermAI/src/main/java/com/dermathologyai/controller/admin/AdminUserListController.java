package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import com.dermathologyai.util.PageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminUserListController extends HttpServlet {
    private UserDAO userDAO;
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("adminDoctorFlash") != null) {
            req.setAttribute("successMessage", session.getAttribute("adminDoctorFlash"));
            session.removeAttribute("adminDoctorFlash");
        }

        int page = PageUtil.parsePage(req.getParameter("page"));
        int pageSize = PageUtil.ADMIN_PAGE_SIZE;

        String search = req.getParameter("search");
        String role = req.getParameter("role");
        String status = req.getParameter("status");
        String segment = req.getParameter("segment");
        if (segment == null || segment.isBlank()) {
            segment = "regular";
        } else {
            segment = segment.trim().toLowerCase();
            if (!"regular".equals(segment) && !"employee".equals(segment)) {
                segment = "regular";
            }
        }

        int totalUsers = userDAO.countAll(search, role, status, segment);
        int totalPages = PageUtil.getTotalPages(totalUsers, pageSize);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));
        List<User> users = userDAO.findAll(search, role, status, segment, page, pageSize);
        PageUtil.setPagingAttributes(req, page, totalUsers);

        Map<String, String> doctorIdsByUserId = new HashMap<>();
        if ("employee".equals(segment)) {
            for (User u : users) {
                if ("DOCTOR".equals(u.getRole())) {
                    Doctor d = doctorDAO.findByUserId(u.getId());
                    if (d != null) {
                        doctorIdsByUserId.put(u.getId(), d.getId());
                    }
                }
            }
        }

        req.setAttribute("users", users);
        req.setAttribute("segment", segment);
        req.setAttribute("doctorIdsByUserId", doctorIdsByUserId);

        req.getRequestDispatcher("/WEB-INF/views/admin/users/list.jsp").forward(req, resp);
    }
}
