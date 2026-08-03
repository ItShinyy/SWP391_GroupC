package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.MedicineDto;
import com.dermathologyai.model.User;
import com.dermathologyai.service.MedicineService;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;

/**
 * Controller endpoint handling asynchronous AJAX medicine lookup requests for Doctors.
 * Endpoint: GET /doctor/medicine/search?q=keyword
 */
public class MedicineController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(MedicineController.class);
    private static final Gson GSON = new Gson();

    private DoctorDAO doctorDAO;
    private MedicineService medicineService;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        medicineService = new MedicineService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Doctor doctor = user == null ? null : doctorDAO.findByUserId(user.getId());

        if (doctor == null) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            writeJsonError(resp, "Access denied. Doctor authentication required.");
            return;
        }

        String query = req.getParameter("q");
        if (query == null || query.trim().length() < 2) {
            writeJsonSuccess(resp, Collections.emptyList());
            return;
        }

        try {
            List<MedicineDto> medicines = medicineService.searchMedicines(query.trim());
            writeJsonSuccess(resp, medicines);
        } catch (MedicineService.MedicineException e) {
            logger.error("Medicine search failed for query '{}': {}", query, e.getMessage());
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            writeJsonError(resp, "Unable to retrieve medicine data.");
        } catch (Exception e) {
            logger.error("Unexpected error during medicine search", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJsonError(resp, "Unable to retrieve medicine data.");
        }
    }

    private void writeJsonSuccess(HttpServletResponse resp, List<MedicineDto> items) throws IOException {
        JsonObject root = new JsonObject();
        root.addProperty("success", true);
        root.add("items", GSON.toJsonTree(items));
        
        try (PrintWriter out = resp.getWriter()) {
            out.print(GSON.toJson(root));
            out.flush();
        }
    }

    private void writeJsonError(HttpServletResponse resp, String errorMessage) throws IOException {
        JsonObject root = new JsonObject();
        root.addProperty("success", false);
        root.addProperty("error", errorMessage);
        root.add("items", GSON.toJsonTree(Collections.emptyList()));

        try (PrintWriter out = resp.getWriter()) {
            out.print(GSON.toJson(root));
            out.flush();
        }
    }
}
