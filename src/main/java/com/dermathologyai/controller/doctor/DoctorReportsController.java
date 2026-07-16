package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller điều hướng bác sĩ đến trang giao diện Báo cáo năng suất cá nhân.
 * Thực hiện kiểm tra quyền truy cập hợp lệ của hồ sơ bác sĩ trước khi chuyển tiếp.
 */
public class DoctorReportsController extends HttpServlet {
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo đối tượng truy xuất thông tin bác sĩ từ CSDL
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Kiểm tra phiên đăng nhập của người dùng hiện tại
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Tìm hồ sơ bác sĩ tương ứng với thông tin tài khoản đăng nhập
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        // Chuyển tiếp yêu cầu hiển thị trang JSP vẽ biểu đồ thống kê
        req.getRequestDispatcher("/WEB-INF/views/doctor/reports.jsp").forward(req, resp);
    }
}
