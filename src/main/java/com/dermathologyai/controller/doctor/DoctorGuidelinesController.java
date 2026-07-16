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
 * Controller điều hướng bác sĩ đến trang tài liệu "Phác đồ & Hướng dẫn y khoa".
 * Giúp bác sĩ tra cứu quy trình điều trị da liễu và hướng dẫn sinh thiết lâm sàng chuẩn.
 */
public class DoctorGuidelinesController extends HttpServlet {
    private DoctorDAO doctorDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo đối tượng truy xuất thông tin bác sĩ
        doctorDAO = new DoctorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Kiểm tra quyền và phiên đăng nhập hiện hành của bác sĩ
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }

        // Chuyển tiếp yêu cầu đến trang hiển thị tài liệu phác đồ JSP
        req.getRequestDispatcher("/WEB-INF/views/doctor/guidelines.jsp").forward(req, resp);
    }
}
