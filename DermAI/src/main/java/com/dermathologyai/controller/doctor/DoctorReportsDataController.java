package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

/**
 * Controller API cung cấp dữ liệu thống kê cá nhân (định dạng JSON) cho riêng bác sĩ đăng nhập.
 * Được gọi bất đồng bộ (AJAX) từ trang giao diện báo cáo để vẽ biểu đồ và hiển thị KPI.
 */
public class DoctorReportsDataController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo các đối tượng truy xuất CSDL
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Cấu hình phản hồi HTTP Header trả về kiểu dữ liệu JSON và mã hóa UTF-8
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // Lấy thông tin phiên đăng nhập bác sĩ hiện tại
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        StringBuilder json = new StringBuilder("{");
        try {
            // 1. Thu thập các chỉ số KPI hiệu năng
            int totalPatients = appointmentDAO.countUniquePatientsByDoctor(doctor.getId());
            int totalCompleted = appointmentDAO.countByDoctorId(doctor.getId(), "COMPLETED");
            double avgConfidence = appointmentDAO.getAverageConfidenceByDoctor(doctor.getId());
            
            // 2. Tính toán tỷ lệ ca bệnh có rủi ro cao (HIGH) đã hoàn thành khám
            Map<String, Integer> riskData = appointmentDAO.getRiskDistributionByDoctor(doctor.getId());
            int highRiskCount = riskData.getOrDefault("HIGH", 0);
            double highRiskRatio = 0;
            if (totalCompleted > 0) {
                highRiskRatio = (highRiskCount * 100.0) / totalCompleted;
            }

            // Ghi nhận các giá trị KPI vào chuỗi JSON
            json.append("\"totalPatients\":").append(totalPatients).append(",");
            json.append("\"totalCompleted\":").append(totalCompleted).append(",");
            json.append("\"avgConfidence\":").append(Math.round(avgConfidence)).append(",");
            json.append("\"highRiskRatio\":").append(Math.round(highRiskRatio)).append(",");

            // 3. Đọc dữ liệu phân bố và xu hướng để phục vụ vẽ biểu đồ (Chart.js)
            json.append("\"riskLevelDistribution\":").append(mapToJsonString(riskData)).append(",");
            json.append("\"topDiseases\":").append(mapToJsonString(appointmentDAO.getTopDiseasesByDoctor(doctor.getId(), 5))).append(",");
            json.append("\"appointmentsTrend\":").append(mapToJsonString(appointmentDAO.getAppointmentsTrendByDoctor(doctor.getId())));

        } catch (Exception e) {
            e.printStackTrace();
            json = new StringBuilder("{\"error\":\"Không thể tải dữ liệu báo cáo bác sĩ\"");
        }
        json.append("}");

        // Ghi dữ liệu JSON ra luồng phản hồi HTTP response
        try (PrintWriter out = resp.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }

    /**
     * Hàm hỗ trợ chuyển đổi một Map<String, Integer> thành chuỗi JSON dạng {"key": value, ...}
     */
    private String mapToJsonString(Map<String, Integer> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!first) sb.append(",");
            sb.append("\"").append(escapeJson(entry.getKey())).append("\":").append(entry.getValue());
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }

    /**
     * Hàm hỗ trợ xử lý tránh lỗi cú pháp JSON đối với các ký tự đặc biệt
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
