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
 * Controller xử lý tính năng "Lịch sử các ca khám cũ" dành cho Bác sĩ.
 * Hỗ trợ bác sĩ tra cứu, lọc và phân trang các hồ sơ bệnh án đã hoàn thành (COMPLETED) hoặc bị hủy (CANCELLED).
 */
public class DoctorAppointmentHistoryController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo các đối tượng truy xuất cơ sở dữ liệu (DAO)
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy thông tin tài khoản người dùng đang đăng nhập từ Session
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Truy vấn hồ sơ bác sĩ tương ứng với tài khoản người dùng
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        // Đọc bộ lọc trạng thái từ tham số URL (Mặc định hiển thị ca đã khám xong 'COMPLETED')
        String statusFilter = req.getParameter("status");
        if (statusFilter == null || (!"COMPLETED".equals(statusFilter) && !"CANCELLED".equals(statusFilter) && !"NO_SHOW".equals(statusFilter))) {
            statusFilter = "COMPLETED";
        }

        // Đọc các tham số tìm kiếm, lọc và sắp xếp mới
        String keyword = req.getParameter("keyword");
        if (keyword != null && keyword.trim().isEmpty()) keyword = null;
        String riskFilter = req.getParameter("riskFilter");
        if (riskFilter != null && riskFilter.trim().isEmpty()) riskFilter = null;
        String sortBy = req.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "time_desc"; // Mặc định lịch sử khám sắp xếp theo thời gian mới nhất (gần đây nhất)
        }

        // Phân trang dữ liệu: Mặc định trang 1, kích thước trang là 10 dòng
        int page = 1;
        int pageSize = 10;
        try {
            String pageParam = req.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {
            // Bỏ qua lỗi chuyển đổi định dạng trang, giữ mặc định trang 1
        }

        // Lấy danh sách lịch sử ca khám đã được phân trang từ CSDL
        List<Appointment> historyList = appointmentDAO.findByDoctorId(doctor.getId(), statusFilter, keyword, riskFilter, sortBy, page, pageSize);
        
        // Tính toán tổng số trang dựa trên tổng số bản ghi thỏa mãn bộ lọc
        int totalRecords = appointmentDAO.countByDoctorId(doctor.getId(), statusFilter, keyword, riskFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        // Gửi dữ liệu ra tầng hiển thị (JSP)
        req.setAttribute("historyList", historyList);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);

        // Forward yêu cầu đến trang hiển thị giao diện JSP tương ứng
        req.getRequestDispatcher("/WEB-INF/views/doctor/history.jsp").forward(req, resp);
    }
}
