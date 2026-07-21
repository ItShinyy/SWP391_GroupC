package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller xử lý trang tổng quan (Dashboard) dành riêng cho Bác sĩ.
 * Hiển thị các chỉ số thống kê lịch hẹn và danh sách hồ sơ đặt khám của bệnh nhân.
 */
public class DoctorDashboardController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo các đối tượng truy cập cơ sở dữ liệu (DAO)
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy session hiện tại, không tạo mới nếu không tồn tại
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        
        // Truy vấn thông tin chi tiết của bác sĩ dựa trên ID người dùng đăng nhập
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            // Nếu không tìm thấy hồ sơ bác sĩ, trả về lỗi 404
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Doctor profile not found.");
            return;
        }
        
        // Đọc bộ lọc trạng thái duyệt (PENDING, ACCEPTED, REJECTED) từ URL
        String statusFilter = req.getParameter("status");
        
        // Phân trang dữ liệu: Mặc định trang 1, mỗi trang 10 dòng
        int page = 1;
        int pageSize = 10;
        try {
            String pageParam = req.getParameter("page");
            if (pageParam != null) page = Integer.parseInt(pageParam);
        } catch (NumberFormatException ignored) {} // Bỏ qua nếu tham số trang lỗi định dạng
        
        // Lấy danh sách lịch khám của bác sĩ theo bộ lọc và phân trang
        List<Appointment> appointments = appointmentDAO.findByDoctorId(doctor.getId(), statusFilter, page, pageSize);
        
        // Thống kê số lượng hồ sơ cho các thẻ chỉ số (Stat Cards)
        int totalCount = appointmentDAO.countByDoctorId(doctor.getId(), null);          // Tổng số lịch khám
        int pendingCount = appointmentDAO.countByDoctorId(doctor.getId(), "PENDING");    // Số ca đang chờ duyệt
        int acceptedCount = appointmentDAO.countByDoctorId(doctor.getId(), "ACCEPTED");  // Số ca đã đồng ý
        int rejectedCount = appointmentDAO.countByDoctorId(doctor.getId(), "REJECTED");  // Số ca đã từ chối
        
        // Tính toán tổng số trang dựa trên số lượng lịch khám sau khi lọc
        int filteredCount = appointmentDAO.countByDoctorId(doctor.getId(), statusFilter);
        int totalPages = (int) Math.ceil((double) filteredCount / pageSize);
        
        // Đẩy toàn bộ dữ liệu thống kê và danh sách lịch hẹn sang trang giao diện JSP
        req.setAttribute("doctor", doctor);
        req.setAttribute("appointments", appointments);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("acceptedCount", acceptedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.setAttribute("statusFilter", statusFilter);
        
        // Chuyển tiếp yêu cầu (forward) tới trang hiển thị Dashboard của bác sĩ
        req.getRequestDispatcher("/WEB-INF/views/doctor/dashboard.jsp").forward(req, resp);
    }
}