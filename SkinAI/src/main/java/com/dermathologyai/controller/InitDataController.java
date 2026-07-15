package com.dermathologyai.controller;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.Clinic;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Controller để tự động tạo dữ liệu doctor records cho các user có role DOCTOR
 */
public class InitDataController extends HttpServlet {
    private UserDAO userDAO;
    private ClinicDAO clinicDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        clinicDAO = new ClinicDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Initialize Doctor Data</title></head><body>");
        out.println("<h2>Khởi tạo dữ liệu Doctor</h2>");
        
        try {
            // 1. Tạo clinic mẫu nếu chưa có
            List<Clinic> clinics = clinicDAO.findAll();
            String clinicId;
            if (clinics.isEmpty()) {
                out.println("<h3>🏥 Tạo clinic mẫu...</h3>");
                clinicId = createSampleClinic();
                out.println("✅ Đã tạo clinic với ID: " + clinicId + "<br>");
            } else {
                clinicId = clinics.get(0).getId();
                out.println("<h3>🏥 Sử dụng clinic hiện có: " + clinics.get(0).getClinicName() + "</h3>");
            }
            
            // 2. Lấy danh sách users có role DOCTOR
            List<User> doctorUsers = userDAO.findByRole("DOCTOR");
            out.println("<h3>👨‍⚕️ Tạo doctor records...</h3>");
            
            int created = 0;
            for (User user : doctorUsers) {
                if (createDoctorRecord(user, clinicId)) {
                    created++;
                    out.println("✅ Tạo doctor record cho: " + user.getFullName() + " (" + user.getUsername() + ")<br>");
                } else {
                    out.println("⚠️ Đã có doctor record cho: " + user.getFullName() + "<br>");
                }
            }
            
            out.println("<h3>📊 Kết quả:</h3>");
            out.println("- Số doctor records đã tạo: " + created + "<br>");
            out.println("- Tổng số users có role DOCTOR: " + doctorUsers.size() + "<br>");
            
            if (created > 0) {
                out.println("<br><div style='background: #d4edda; padding: 15px; border: 1px solid #c3e6cb; border-radius: 5px;'>");
                out.println("🎉 <strong>Hoàn thành!</strong> Bây giờ bạn có thể đăng nhập với tài khoản doctor và truy cập:");
                out.println("<br><a href='" + req.getContextPath() + "/doctor/dashboard'>Doctor Dashboard</a>");
                out.println("</div>");
            }
            
        } catch (Exception e) {
            out.println("<h3>❌ Lỗi: " + e.getMessage() + "</h3>");
            e.printStackTrace(out);
        }
        
        out.println("<br><hr>");
        out.println("<a href='" + req.getContextPath() + "/test'>🔍 Xem thông tin debug</a>");
        out.println("</body></html>");
    }

    private String createSampleClinic() throws Exception {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO clinics (id, clinic_name, address, phone, email, created_at, updated_at) " +
                        "OUTPUT INSERTED.id VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String id = UUID.randomUUID().toString();
                ps.setString(1, id);
                ps.setString(2, "Phòng Khám Chuyên Khoa Da Liễu SkinAI");
                ps.setString(3, "123 Đường Nguyễn Trãi, Quận 1, TP.HCM");
                ps.setString(4, "028-1234-5678");
                ps.setString(5, "skinai@clinic.com");
                ps.setObject(6, LocalDateTime.now());
                ps.setObject(7, LocalDateTime.now());
                
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? rs.getString(1) : null;
                }
            }
        }
    }

    private boolean createDoctorRecord(User user, String clinicId) throws Exception {
        // Kiểm tra xem đã có doctor record chưa
        try (Connection conn = getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM doctors WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, user.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false; // Đã có record
                    }
                }
            }
            
            // Tạo doctor record mới
            String insertSql = "INSERT INTO doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active, created_at, updated_at) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                String specialization, licenseNumber, bio;
                
                switch (user.getUsername()) {
                    case "bs.levanc":
                        specialization = "Da Liễu Thẩm Mỹ";
                        licenseNumber = "12345/BYT";
                        bio = "Bác sĩ chuyên khoa Da Liễu với hơn 10 năm kinh nghiệm trong lĩnh vực thẩm mỹ da và điều trị các bệnh da liễu.";
                        break;
                    case "bs.nguyenvana":
                        specialization = "Da Liễu Lâm Sàng";
                        licenseNumber = "12346/BYT";
                        bio = "Bác sĩ Da Liễu giàu kinh nghiệm trong chẩn đoán và điều trị các bệnh da liễu phức tạp.";
                        break;
                    case "bs.tranthib":
                        specialization = "Da Liễu Nhi Khoa";
                        licenseNumber = "12347/BYT";
                        bio = "Bác sĩ chuyên về Da Liễu Nhi Khoa, có kinh nghiệm điều trị các bệnh da ở trẻ em.";
                        break;
                    default:
                        specialization = "Da Liễu Tổng Quát";
                        licenseNumber = "12348/BYT";
                        bio = "Bác sĩ Da Liễu với nhiều năm kinh nghiệm lâm sàng.";
                }
                
                ps.setString(1, UUID.randomUUID().toString());
                ps.setString(2, user.getId());
                ps.setString(3, clinicId);
                ps.setString(4, specialization);
                ps.setString(5, licenseNumber);
                ps.setString(6, bio);
                ps.setBoolean(7, true);
                ps.setObject(8, LocalDateTime.now());
                ps.setObject(9, LocalDateTime.now());
                
                return ps.executeUpdate() > 0;
            }
        }
    }

    private Connection getConnection() throws Exception {
        // Sử dụng same connection logic như DBContext
        String url = "jdbc:sqlserver://localhost:1433;databaseName=SWP391;encrypt=true;trustServerCertificate=true;";
        String username = "sa";
        String password = "123";
        return java.sql.DriverManager.getConnection(url, username, password);
    }
}