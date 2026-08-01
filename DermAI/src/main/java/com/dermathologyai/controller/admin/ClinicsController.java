package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.model.Clinic;
import com.dermathologyai.util.PageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

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
            req.getRequestDispatcher("/WEB-INF/views/admin/clinics/form.jsp").forward(req, resp);
            return;
        }
        if ("edit".equals(action)) {
            String id = req.getParameter("id");
            Clinic clinic = id == null || id.isBlank() ? null : clinicDAO.findById(id.trim());
            if (clinic == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("clinic", clinic);
            req.getRequestDispatcher("/WEB-INF/views/admin/clinics/form.jsp").forward(req, resp);
            return;
        }

        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        List<Clinic> allClinics = clinicDAO.findAll();
        if ((keyword != null && !keyword.trim().isEmpty()) || (status != null && !status.isBlank() && !"ALL".equals(status))) {
            allClinics = allClinics.stream().filter(c -> {
                boolean matchKeyword = true;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    String k = keyword.toLowerCase();
                    matchKeyword = (c.getClinicName() != null && c.getClinicName().toLowerCase().contains(k))
                        || (c.getAddress() != null && c.getAddress().toLowerCase().contains(k));
                }
                boolean matchStatus = true;
                if (status != null && !status.isBlank() && !"ALL".equals(status)) {
                    if ("ACTIVE".equals(status)) matchStatus = c.isActive();
                    if ("INACTIVE".equals(status)) matchStatus = !c.isActive();
                }
                return matchKeyword && matchStatus;
            }).collect(java.util.stream.Collectors.toList());
        }

        int page = PageUtil.parsePage(req.getParameter("page"));
        int total = allClinics.size();
        int totalPages = PageUtil.getTotalPages(total, PageUtil.ADMIN_PAGE_SIZE);
        page = PageUtil.normalizePage(page, Math.max(totalPages, 1));
        int from = PageUtil.getOffset(page, PageUtil.ADMIN_PAGE_SIZE);
        int to = Math.min(from + PageUtil.ADMIN_PAGE_SIZE, total);
        List<Clinic> pageClinics = from >= total ? List.of() : allClinics.subList(from, to);

        req.setAttribute("clinics", pageClinics);
        PageUtil.setPagingAttributes(req, page, total);
        req.getRequestDispatcher("/WEB-INF/views/admin/clinics/list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("create".equals(action)) {
            Clinic clinic = new Clinic();
            bindEditableFields(clinic, req);
            clinic.setWebsite(trimToNull(req.getParameter("website")));
            clinic.setActive(true);
            String ratingRaw = req.getParameter("rating");
            if (ratingRaw != null && !ratingRaw.isBlank()) {
                try {
                    clinic.setRating(Double.parseDouble(ratingRaw.trim()));
                } catch (NumberFormatException e) {
                    clinic.setRating(0);
                }
            } else {
                clinic.setRating(0);
            }
            clinicDAO.create(clinic);
            resp.sendRedirect(req.getContextPath() + "/admin/clinics");
            return;
        }
        if ("edit".equals(action)) {
            String id = req.getParameter("id");
            Clinic existing = id == null || id.isBlank() ? null : clinicDAO.findById(id.trim());
            if (existing == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            // Preserve website/rating when form omits them; always apply Active checkbox (unchecked = inactive).
            bindEditableFields(existing, req);
            existing.setActive(req.getParameter("isActive") != null);
            String website = req.getParameter("website");
            if (website != null) {
                existing.setWebsite(website.isBlank() ? null : website.trim());
            }
            String ratingRaw = req.getParameter("rating");
            if (ratingRaw != null && !ratingRaw.isBlank()) {
                try {
                    existing.setRating(Double.parseDouble(ratingRaw.trim()));
                } catch (NumberFormatException ignored) {
                    // keep existing rating
                }
            }
            clinicDAO.update(existing);
            resp.sendRedirect(req.getContextPath() + "/admin/clinics");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/admin/clinics");
    }

    private static void bindEditableFields(Clinic clinic, HttpServletRequest req) {
        clinic.setClinicName(trimToNull(req.getParameter("clinicName")));
        clinic.setAddress(trimToNull(req.getParameter("address")));
        clinic.setPhone(trimToNull(req.getParameter("phone")));
        clinic.setSpecialty(trimToNull(req.getParameter("specialty")));
        clinic.setGooglePlaceId(trimToNull(req.getParameter("googlePlaceId")));
        try {
            String lat = req.getParameter("latitude");
            String lng = req.getParameter("longitude");
            if (lat != null && !lat.isBlank()) clinic.setLatitude(Double.parseDouble(lat.trim()));
            if (lng != null && !lng.isBlank()) clinic.setLongitude(Double.parseDouble(lng.trim()));
        } catch (NumberFormatException ignored) {
            // keep previous coords on edit; create leaves 0,0 which map filters out
        }
    }

    private static String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
