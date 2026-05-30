package com.skinai.controller.admin;

import com.skinai.dal.PatientDAO;
import com.skinai.dal.UserDAO;
import com.skinai.model.Patient;
import com.skinai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class AdminUserStatusChangeController extends HttpServlet {
    private UserDAO userDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        patientDAO = new PatientDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        String action = req.getParameter("action"); // "lock" or "unlock"
        
        if (id == null || id.trim().isEmpty() || action == null || action.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        User user = userDAO.findById(id);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        Patient patient = patientDAO.findByUserId(user.getId());

        req.setAttribute("targetUser", user);
        req.setAttribute("patient", patient);
        req.setAttribute("action", action);
        
        req.getRequestDispatcher("/WEB-INF/views/admin/users/status-change.jsp").forward(req, resp);
    }
}
