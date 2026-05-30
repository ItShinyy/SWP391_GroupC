package com.skinai.controller.admin;

import com.skinai.dal.ClinicDAO;
import com.skinai.model.Clinic;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class ClinicsController extends HttpServlet {
    private ClinicDAO clinicDAO;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equals(action)) {
            req.getRequestDispatcher("/WEB-INF/views/admin/clinic-form.jsp").forward(req, resp);
        } else if ("edit".equals(action)) {
            String id = req.getParameter("id");
            Clinic clinic = clinicDAO.findById(id);
            req.setAttribute("clinic", clinic);
            req.getRequestDispatcher("/WEB-INF/views/admin/clinic-form.jsp").forward(req, resp);
        } else {
            req.setAttribute("clinics", clinicDAO.findAll());
            req.getRequestDispatcher("/WEB-INF/views/admin/clinics.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        Clinic clinic = new Clinic();
        clinic.setClinicName(req.getParameter("clinicName"));
        clinic.setAddress(req.getParameter("address"));
        clinic.setPhone(req.getParameter("phone"));
        clinic.setSpecialty(req.getParameter("specialty"));
        clinic.setGooglePlaceId(req.getParameter("googlePlaceId"));
        
        try {
            if (req.getParameter("latitude") != null && !req.getParameter("latitude").isEmpty()) {
                clinic.setLatitude(Double.parseDouble(req.getParameter("latitude")));
            }
            if (req.getParameter("longitude") != null && !req.getParameter("longitude").isEmpty()) {
                clinic.setLongitude(Double.parseDouble(req.getParameter("longitude")));
            }
        } catch (NumberFormatException e) {
            // Log error or ignore
        }

        if ("create".equals(action)) {
            clinic.setActive(true);
            clinicDAO.create(clinic);
        } else if ("edit".equals(action)) {
            clinic.setId(req.getParameter("id"));
            clinicDAO.update(clinic);
        }
        
        resp.sendRedirect(req.getContextPath() + "/admin/clinics");
    }
}
