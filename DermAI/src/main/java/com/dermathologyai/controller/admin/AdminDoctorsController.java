package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.AuthService;
import com.dermathologyai.util.InputValidator;
import com.dermathologyai.util.RequestUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Admin doctor profile create/edit only. Account lock lives under /admin/users. */
public class AdminDoctorsController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private ClinicDAO clinicDAO;
    private UserDAO userDAO;
    private AuthService authService;
    private AuditService auditService;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        clinicDAO = new ClinicDAO();
        userDAO = new UserDAO();
        authService = new AuthService();
        auditService = new AuditService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("adminDoctorError") != null) {
            req.setAttribute("errorMessage", session.getAttribute("adminDoctorError"));
            session.removeAttribute("adminDoctorError");
        }

        String action = req.getParameter("action");
        req.setAttribute("clinics", clinicDAO.findAll());
        req.setAttribute("passwordRequirements", InputValidator.getPasswordRequirements());
        if ("create".equals(action)) {
            req.getRequestDispatcher("/WEB-INF/views/admin/doctors/form.jsp").forward(req, resp);
            return;
        }
        if ("edit".equals(action)) {
            String id = req.getParameter("id");
            Doctor doctor = (id == null || id.isBlank()) ? null : doctorDAO.findById(id.trim());
            if (doctor == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("doctor", doctor);
            req.getRequestDispatcher("/WEB-INF/views/admin/doctors/form.jsp").forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users?segment=employee");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User admin = (User) session.getAttribute("user");
        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                String password = req.getParameter("password");
                InputValidator.requireMatchingPasswords(password, req.getParameter("confirmPassword"));
                String doctorId = authService.createDoctorAccount(
                    req.getParameter("fullName"),
                    req.getParameter("email"),
                    req.getParameter("username"),
                    req.getParameter("phone"),
                    password,
                    req.getParameter("clinicId"),
                    req.getParameter("specialization"),
                    req.getParameter("licenseNumber"),
                    req.getParameter("bio")
                );
                if (admin != null) {
                    auditService.log(admin.getId(), "ADMIN_CREATE_DOCTOR", "doctors", doctorId, null, null, null,
                        RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                session.setAttribute("adminDoctorFlash",
                    "Doctor account created. They can log in normally. Publish schedule blocks before patients can book.");
                resp.sendRedirect(req.getContextPath() + "/admin/users?segment=employee");
                return;
            }
            if ("update".equals(action)) {
                String id = req.getParameter("id");
                if (id == null || id.isBlank()) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                Doctor doctor = doctorDAO.findById(id.trim());
                if (doctor == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                String fullName = req.getParameter("fullName");
                String phone = req.getParameter("phone");
                String clinicId = req.getParameter("clinicId");
                String specialization = req.getParameter("specialization");
                String licenseNumber = req.getParameter("licenseNumber");
                if (fullName == null || fullName.isBlank()) {
                    throw new IllegalArgumentException("Full name is required.");
                }
                if (phone == null || phone.isBlank()) {
                    throw new IllegalArgumentException("Phone is required.");
                }
                if (clinicId == null || clinicId.isBlank()) {
                    throw new IllegalArgumentException("Clinic is required.");
                }
                if (specialization == null || specialization.isBlank()) {
                    throw new IllegalArgumentException("Specialization is required.");
                }
                if (licenseNumber == null || licenseNumber.isBlank()) {
                    throw new IllegalArgumentException("License number is required.");
                }
                doctor.setClinicId(clinicId.trim());
                doctor.setSpecialization(specialization.trim());
                doctor.setLicenseNumber(licenseNumber.trim());
                doctor.setBio(blankToNull(req.getParameter("bio")));
                doctorDAO.updateProfile(doctor);

                User linked = userDAO.findById(doctor.getUserId());
                if (linked != null) {
                    linked.setFullName(fullName.trim());
                    linked.setPhone(phone.trim());
                    userDAO.update(linked);
                }
                if (admin != null) {
                    auditService.log(admin.getId(), "ADMIN_UPDATE_DOCTOR", "doctors", id, null, null, null,
                        RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/admin/users?segment=employee&updated=1");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?segment=employee");
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("adminDoctorError", e.getMessage());
            String back = "create".equals(action)
                ? "/admin/doctors?action=create"
                : "/admin/doctors?action=edit&id=" + req.getParameter("id");
            resp.sendRedirect(req.getContextPath() + back);
        }
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
