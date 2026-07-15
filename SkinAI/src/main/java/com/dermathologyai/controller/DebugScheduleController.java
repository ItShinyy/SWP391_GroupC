package com.dermathologyai.controller;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;

/**
 * Controller debug để kiểm tra việc update lịch làm việc của bác sĩ
 */
public class DebugScheduleController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private DoctorScheduleDAO scheduleDAO;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        scheduleDAO = new DoctorScheduleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Debug Schedule Update</title></head><body>");
        out.println("<h2>Debug Schedule Update</h2>");
        
        try {
            // Kiểm tra user và doctor
            User sessionUser = (User) req.getSession().getAttribute("user");
            if (sessionUser == null) {
                out.println("❌ Không có user trong session<br>");
                return;
            }
            
            Doctor doctor = doctorDAO.findByUserId(sessionUser.getId());
            if (doctor == null) {
                out.println("❌ Không tìm thấy doctor record<br>");
                return;
            }
            
            out.println("<h3>✅ Thông tin Doctor:</h3>");
            out.println("Doctor ID: " + doctor.getId() + "<br>");
            out.println("User ID: " + doctor.getUserId() + "<br>");
            out.println("Full Name: " + doctor.getFullName() + "<br>");
            
            // Kiểm tra bảng doctor_schedules có tồn tại không
            out.println("<h3>🔍 Kiểm tra database:</h3>");
            try (Connection conn = getConnection()) {
                // Kiểm tra bảng có tồn tại không
                DatabaseMetaData metaData = conn.getMetaData();
                try (ResultSet tables = metaData.getTables(null, null, "doctor_schedules", null)) {
                    if (tables.next()) {
                        out.println("✅ Bảng doctor_schedules tồn tại<br>");
                    } else {
                        out.println("❌ Bảng doctor_schedules KHÔNG tồn tại<br>");
                        out.println("<strong>Cần tạo bảng doctor_schedules!</strong><br>");
                        out.println("<a href='" + req.getContextPath() + "/debug-schedule?action=create-table'>Tạo bảng doctor_schedules</a><br>");
                        return;
                    }
                }
                
                // Đếm số records hiện tại
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM doctor_schedules WHERE doctor_id = ?")) {
                    ps.setString(1, doctor.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            int count = rs.getInt(1);
                            out.println("Số schedules của doctor này: " + count + "<br>");
                        }
                    }
                }
                
                // Test insert một record
                out.println("<h3>🧪 Test insert schedule:</h3>");
                DoctorSchedule testSchedule = new DoctorSchedule();
                testSchedule.setDoctorId(doctor.getId());
                testSchedule.setScheduleDate(LocalDate.now());
                testSchedule.setSlot("MORNING");
                testSchedule.setAvailable(true);
                testSchedule.setMaxPatients(5);
                
                boolean success = scheduleDAO.upsertSchedule(testSchedule);
                if (success) {
                    out.println("✅ Test insert thành công<br>");
                } else {
                    out.println("❌ Test insert thất bại<br>");
                }
                
                // Kiểm tra lại số records
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM doctor_schedules WHERE doctor_id = ?")) {
                    ps.setString(1, doctor.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            int count = rs.getInt(1);
                            out.println("Số schedules sau test: " + count + "<br>");
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            out.println("<h3>❌ Lỗi: " + e.getMessage() + "</h3>");
            e.printStackTrace(out);
        }
        
        out.println("</body></html>");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if ("create-table".equals(action)) {
            resp.setContentType("text/html;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            
            out.println("<html><head><title>Create Table</title></head><body>");
            out.println("<h2>Tạo bảng doctor_schedules</h2>");
            
            try (Connection conn = getConnection()) {
                String createTableSQL = """
                    CREATE TABLE doctor_schedules (
                        id NVARCHAR(50) PRIMARY KEY DEFAULT NEWID(),
                        doctor_id NVARCHAR(50) NOT NULL,
                        schedule_date DATE NOT NULL,
                        slot NVARCHAR(20) NOT NULL,
                        is_available BIT DEFAULT 1,
                        max_patients INT DEFAULT 5,
                        booked_count INT DEFAULT 0,
                        created_at DATETIME2 DEFAULT GETDATE(),
                        FOREIGN KEY (doctor_id) REFERENCES doctors(id),
                        UNIQUE (doctor_id, schedule_date, slot)
                    )
                    """;
                
                try (Statement stmt = conn.createStatement()) {
                    stmt.executeUpdate(createTableSQL);
                    out.println("✅ Đã tạo bảng doctor_schedules thành công!<br>");
                    out.println("<a href='" + req.getContextPath() + "/debug-schedule'>Kiểm tra lại</a>");
                }
                
            } catch (Exception e) {
                out.println("❌ Lỗi tạo bảng: " + e.getMessage() + "<br>");
                e.printStackTrace(out);
            }
            
            out.println("</body></html>");
        }
    }

    private Connection getConnection() throws SQLException {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=SWP391;encrypt=true;trustServerCertificate=true;";
        String username = "sa";
        String password = "123";
        return DriverManager.getConnection(url, username, password);
    }
}