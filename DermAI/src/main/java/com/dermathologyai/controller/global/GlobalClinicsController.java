package com.dermathologyai.controller.global;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.model.Clinic;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class GlobalClinicsController extends HttpServlet {
    private static final String CLINICS_PATH = "/global/clinics";
    private static final String DETAIL_PATH = CLINICS_PATH + "/detail";
    private static final String MAP_PATH = CLINICS_PATH + "/map";

    private ClinicDAO clinicDAO;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath();
        if (DETAIL_PATH.equals(servletPath)) {
            showDetail(req, resp);
            return;
        }

        if (MAP_PATH.equals(servletPath)) {
            showMap(req, resp);
            return;
        }

        List<Clinic> clinics = clinicDAO.findActive();
        req.setAttribute("clinics", clinics);
        req.getRequestDispatcher("/WEB-INF/views/global/clinics.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clinicId = req.getParameter("id");
        if (clinicId == null || clinicId.isBlank()) {
            resp.sendRedirect(req.getContextPath() + CLINICS_PATH);
            return;
        }

        Clinic clinic = clinicDAO.findById(clinicId.trim());
        if (clinic == null || !clinic.isActive()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phòng khám.");
            return;
        }

        req.setAttribute("clinic", clinic);
        req.getRequestDispatcher("/WEB-INF/views/global/clinic-detail.jsp").forward(req, resp);
    }

    private void showMap(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("clinics", clinicDAO.findActiveWithLocation());
        req.setAttribute("selectedClinicId", req.getParameter("id"));
        req.getRequestDispatcher("/WEB-INF/views/global/clinics-map.jsp").forward(req, resp);
    }
}
