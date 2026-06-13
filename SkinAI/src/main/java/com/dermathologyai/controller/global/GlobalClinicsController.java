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
    private ClinicDAO clinicDAO;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int pageSize = 10;
        
        String pageStr = req.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }
        
        // Fetch active clinics from database
        List<Clinic> clinics = clinicDAO.findActive();
        
        // TODO: Update ClinicDAO to support pagination in findActive(), but for now just pass all
        
        req.setAttribute("clinics", clinics);
        
        req.getRequestDispatcher("/WEB-INF/views/global/clinics.jsp").forward(req, resp);
    }
}
