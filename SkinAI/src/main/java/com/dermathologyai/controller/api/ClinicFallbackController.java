package com.dermathologyai.controller.api;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.model.Clinic;
import com.google.gson.Gson;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/** Database fallback used when browser geolocation or Geoapify is unavailable. */
public class ClinicFallbackController extends HttpServlet {
    private ClinicDAO clinicDAO;
    private Gson gson;

    @Override
    public void init() {
        clinicDAO = new ClinicDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        List<Map<String, Object>> result = clinicDAO.findActiveWithLocation().stream()
            .map(this::toLocatorItem)
            .collect(Collectors.toList());

        gson.toJson(result, resp.getWriter());
    }

    private Map<String, Object> toLocatorItem(Clinic clinic) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", clinic.getId());
        item.put("name", clinic.getClinicName());
        item.put("address", clinic.getAddress());
        item.put("phone", clinic.getPhone());
        item.put("website", clinic.getWebsite());
        item.put("latitude", clinic.getLatitude());
        item.put("longitude", clinic.getLongitude());

        String name = clinic.getClinicName() == null
            ? ""
            : clinic.getClinicName().toLowerCase(Locale.ROOT);
        item.put("type", name.contains("bệnh viện") ? "HOSPITAL" : "CLINIC");
        return item;
    }
}
