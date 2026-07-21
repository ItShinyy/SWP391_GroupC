package com.dermathologyai.controller.api;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DoctorSchedule;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * API Controller cho việc lấy thông tin bác sĩ theo phòng khám và ngày
 */
public class DoctorApiController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private DoctorScheduleDAO scheduleDAO;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        scheduleDAO = new DoctorScheduleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        String action = req.getParameter("action");
        
        try {
            if ("getByClinic".equals(action)) {
                handleGetByClinic(req, resp);
            } else if ("getAvailableByDate".equals(action)) {
                handleGetAvailableByDate(req, resp);
            } else if ("getDoctorSchedule".equals(action)) {
                handleGetDoctorSchedule(req, resp);
            } else {
                sendErrorResponse(resp, "Invalid action");
            }
        } catch (Exception e) {
            sendErrorResponse(resp, "Error: " + e.getMessage());
        }
    }

    /**
     * Lấy danh sách bác sĩ theo phòng khám
     */
    private void handleGetByClinic(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String clinicId = req.getParameter("clinicId");
        
        // Debug: Log all parameters
        System.out.println("=== DEBUG handleGetByClinic ===");
        System.out.println("Query string: " + req.getQueryString());
        System.out.println("clinicId parameter: '" + clinicId + "'");
        System.out.println("All parameters:");
        req.getParameterMap().forEach((key, values) -> {
            System.out.println("  " + key + " = " + String.join(",", values));
        });
        System.out.println("===============================");
        
        if (clinicId == null || clinicId.trim().isEmpty()) {
            sendErrorResponse(resp, "Missing clinicId parameter");
            return;
        }
        
        List<Doctor> doctors = doctorDAO.findByClinicId(clinicId);
        System.out.println("Found " + doctors.size() + " doctors for clinic: " + clinicId);
        
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"doctors\":[");
        
        for (int i = 0; i < doctors.size(); i++) {
            Doctor doctor = doctors.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"id\":\"").append(escapeJson(doctor.getId())).append("\",")
                .append("\"fullName\":\"").append(escapeJson(doctor.getFullName())).append("\",")
                .append("\"specialization\":\"").append(escapeJson(doctor.getSpecialization())).append("\",")
                .append("\"licenseNumber\":\"").append(escapeJson(doctor.getLicenseNumber())).append("\",")
                .append("\"bio\":\"").append(escapeJson(doctor.getBio())).append("\"")
                .append("}");
        }
        
        json.append("]}");
        resp.getWriter().write(json.toString());
    }

    /**
     * Lấy danh sách bác sĩ có lịch làm việc trong ngày cụ thể
     */
    private void handleGetAvailableByDate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String clinicId = req.getParameter("clinicId");
        String dateStr = req.getParameter("date");
        
        if (clinicId == null || dateStr == null) {
            sendErrorResponse(resp, "Missing clinicId or date parameter");
            return;
        }
        
        try {
            LocalDate date = LocalDate.parse(dateStr);
            
            // Lấy tất cả bác sĩ của phòng khám
            List<Doctor> allDoctors = doctorDAO.findByClinicId(clinicId);
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"doctors\":[");
            
            boolean first = true;
            for (Doctor doctor : allDoctors) {
                // Kiểm tra lịch làm việc của bác sĩ trong ngày này
                List<DoctorSchedule> schedules = scheduleDAO.findAvailableByDoctorAndDate(doctor.getId(), date);
                
                if (!schedules.isEmpty()) {
                    if (!first) json.append(",");
                    first = false;
                    
                    json.append("{")
                        .append("\"id\":\"").append(escapeJson(doctor.getId())).append("\",")
                        .append("\"fullName\":\"").append(escapeJson(doctor.getFullName())).append("\",")
                        .append("\"specialization\":\"").append(escapeJson(doctor.getSpecialization())).append("\",")
                        .append("\"licenseNumber\":\"").append(escapeJson(doctor.getLicenseNumber())).append("\",")
                        .append("\"bio\":\"").append(escapeJson(doctor.getBio())).append("\",")
                        .append("\"availableSlots\":[");
                    
                    for (int i = 0; i < schedules.size(); i++) {
                        DoctorSchedule schedule = schedules.get(i);
                        if (i > 0) json.append(",");
                        
                        String slotName = getSlotDisplayName(schedule.getSlot());
                        int available = schedule.getMaxPatients() - schedule.getBookedCount();
                        
                        json.append("{")
                            .append("\"id\":\"").append(escapeJson(schedule.getId())).append("\",")
                            .append("\"slot\":\"").append(escapeJson(schedule.getSlot())).append("\",")
                            .append("\"slotName\":\"").append(escapeJson(slotName)).append("\",")
                            .append("\"maxPatients\":").append(schedule.getMaxPatients()).append(",")
                            .append("\"bookedCount\":").append(schedule.getBookedCount()).append(",")
                            .append("\"available\":").append(available)
                            .append("}");
                    }
                    
                    json.append("]}");
                }
            }
            
            json.append("],\"date\":\"").append(escapeJson(dateStr)).append("\"}");
            resp.getWriter().write(json.toString());
            
        } catch (Exception e) {
            sendErrorResponse(resp, "Invalid date format or error: " + e.getMessage());
        }
    }

    /**
     * Lấy lịch làm việc của bác sĩ trong vài tuần tới
     */
    private void handleGetDoctorSchedule(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String doctorId = req.getParameter("doctorId");
        
        if (doctorId == null || doctorId.trim().isEmpty()) {
            sendErrorResponse(resp, "Missing doctorId parameter");
            return;
        }
        
        try {
            LocalDate startDate = LocalDate.now();
            LocalDate endDate = startDate.plusWeeks(4); // 4 tuần tới
            
            List<DoctorSchedule> schedules = scheduleDAO.findByDoctorAndDateRange(doctorId, startDate, endDate);
            
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"doctorId\":\"").append(escapeJson(doctorId)).append("\",\"schedules\":[");
            
            for (int i = 0; i < schedules.size(); i++) {
                DoctorSchedule schedule = schedules.get(i);
                if (i > 0) json.append(",");
                
                String slotName = getSlotDisplayName(schedule.getSlot());
                int available = schedule.getMaxPatients() - schedule.getBookedCount();
                
                json.append("{")
                    .append("\"id\":\"").append(escapeJson(schedule.getId())).append("\",")
                    .append("\"date\":\"").append(schedule.getScheduleDate().toString()).append("\",")
                    .append("\"slot\":\"").append(escapeJson(schedule.getSlot())).append("\",")
                    .append("\"slotName\":\"").append(escapeJson(slotName)).append("\",")
                    .append("\"isAvailable\":").append(schedule.isAvailable()).append(",")
                    .append("\"maxPatients\":").append(schedule.getMaxPatients()).append(",")
                    .append("\"bookedCount\":").append(schedule.getBookedCount()).append(",")
                    .append("\"available\":").append(available)
                    .append("}");
            }
            
            json.append("]}");
            resp.getWriter().write(json.toString());
            
        } catch (Exception e) {
            sendErrorResponse(resp, "Error: " + e.getMessage());
        }
    }

    private String getSlotDisplayName(String slot) {
        switch (slot) {
            case "MORNING": return "Sáng (8:00 - 12:00)";
            case "AFTERNOON": return "Chiều (13:00 - 17:00)";
            case "EVENING": return "Tối (18:00 - 21:00)";
            default: return slot;
        }
    }

    private void sendErrorResponse(HttpServletResponse resp, String message) throws IOException {
        String json = "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}";
        resp.getWriter().write(json);
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}