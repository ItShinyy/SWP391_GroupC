package com.dermathologyai.controller;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Test controller để debug vấn đề doctor login
 */
public class TestController extends HttpServlet {
    private UserDAO userDAO;
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Debug Doctor Info</title></head><body>");
        out.println("<h2>Debug Doctor Login</h2>");
        
        try {
            // Kiểm tra user từ session
            User sessionUser = (User) req.getSession().getAttribute("user");
            if (sessionUser != null) {
                out.println("<h3>Session User Info:</h3>");
                out.println("ID: " + sessionUser.getId() + "<br>");
                out.println("Username: " + sessionUser.getUsername() + "<br>");
                out.println("Full Name: " + sessionUser.getFullName() + "<br>");
                out.println("Role: " + sessionUser.getRole() + "<br>");
                out.println("Status: " + sessionUser.getStatus() + "<br>");
                
                // Kiểm tra doctor record
                Doctor doctor = doctorDAO.findByUserId(sessionUser.getId());
                if (doctor != null) {
                    out.println("<h3>Doctor Info:</h3>");
                    out.println("Doctor ID: " + doctor.getId() + "<br>");
                    out.println("User ID: " + doctor.getUserId() + "<br>");
                    out.println("Full Name: " + doctor.getFullName() + "<br>");
                    out.println("Clinic ID: " + doctor.getClinicId() + "<br>");
                    out.println("Clinic Name: " + doctor.getClinicName() + "<br>");
                    out.println("Specialization: " + doctor.getSpecialization() + "<br>");
                    out.println("Is Active: " + doctor.isActive() + "<br>");
                } else {
                    out.println("<h3>❌ Không tìm thấy doctor record với user_id: " + sessionUser.getId() + "</h3>");
                }
            } else {
                out.println("<h3>❌ Không có user trong session</h3>");
            }
            
            // Kiểm tra tất cả users có role DOCTOR
            out.println("<hr><h3>Tất cả users có role DOCTOR:</h3>");
            var doctorUsers = userDAO.findByRole("DOCTOR");
            if (doctorUsers.isEmpty()) {
                out.println("❌ Không có user nào có role DOCTOR trong database");
            } else {
                for (User user : doctorUsers) {
                    out.println("User ID: " + user.getId() + " - " + user.getUsername() + " - " + user.getFullName() + "<br>");
                }
            }
            
            // Kiểm tra tất cả doctor records
            out.println("<hr><h3>Tất cả doctor records:</h3>");
            var allDoctors = doctorDAO.findAll();
            if (allDoctors.isEmpty()) {
                out.println("❌ Không có doctor record nào trong database");
            } else {
                for (Doctor doc : allDoctors) {
                    out.println("Doctor ID: " + doc.getId() + " - User ID: " + doc.getUserId() + " - " + doc.getFullName() + "<br>");
                }
            }

            // Kiểm tra bảng doctor_schedules 
            out.println("<hr><h3>Kiểm tra bảng doctor_schedules:</h3>");
            try {
                var stmt = java.sql.DriverManager.getConnection(
                    "jdbc:sqlserver://localhost:1433;databaseName=SkinAI_DB;trustServerCertificate=true;", 
                    "sa", "123"
                ).createStatement();
                var rs = stmt.executeQuery("SELECT COUNT(*) FROM doctor_schedules");
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("Số records trong doctor_schedules: " + count + "<br>");
                    if (count == 0) {
                        out.println("⚠️ Bảng doctor_schedules trống - bác sĩ chưa có lịch làm việc<br>");
                    }
                }
                rs.close();
                
                // Kiểm tra appointments có doctor_id
                rs = stmt.executeQuery("SELECT COUNT(*) FROM appointments WHERE doctor_id IS NOT NULL");
                if (rs.next()) {
                    int countAppts = rs.getInt(1);
                    out.println("Số appointments có doctor_id: " + countAppts + "<br>");
                }
                rs.close();
                stmt.close();
            } catch (Exception ex) {
                out.println("Lỗi khi kiểm tra database: " + ex.getMessage() + "<br>");
            }
            
        } catch (Exception e) {
            out.println("<h3>❌ Lỗi: " + e.getMessage() + "</h3>");
            e.printStackTrace(out);
        }
        
        out.println("</body></html>");
    }
}