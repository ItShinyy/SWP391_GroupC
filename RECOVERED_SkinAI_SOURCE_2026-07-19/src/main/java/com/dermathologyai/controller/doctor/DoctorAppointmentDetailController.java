package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.User;
import com.dermathologyai.service.InvoiceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller xử lý xem chi tiết hồ sơ bệnh nhân và phê duyệt lịch hẹn dành cho Bác sĩ.
 */
public class DoctorAppointmentDetailController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;
    private InvoiceService invoiceService;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
        invoiceService = new InvoiceService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Doctor profile not found.");
            return;
        }
        
        // Lấy ID lịch hẹn từ tham số yêu cầu
        String appointmentId = req.getParameter("id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        // Tìm appointment trực tiếp bằng ID
        Appointment appointment = appointmentDAO.findById(appointmentId);
        
        // Kiểm tra appointment có tồn tại và thuộc về doctor này không
        if (appointment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found.");
            return;
        }
        
        // Gắn dữ liệu bác sĩ và lịch hẹn vào request attributes để hiển thị lên JSP
        req.setAttribute("doctor", doctor);
        req.setAttribute("appointment", appointment);
        
        // Forward tới trang chi tiết lịch hẹn của bác sĩ
        req.getRequestDispatcher("/WEB-INF/views/doctor/appointment-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        // Đọc dữ liệu từ form xử lý (ID lịch hẹn, hành động duyệt, và ghi chú)
        String appointmentId = req.getParameter("appointmentId");
        String action = req.getParameter("action"); // "accept", "reject", hoặc "complete"
        String doctorNotes = req.getParameter("doctorNotes");
        String completionNotes = req.getParameter("completionNotes");
        
        if (appointmentId == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        boolean success = false;
        
        if ("complete".equals(action)) {
            // Xử lý hoàn thành appointment
            success = appointmentDAO.updateStatus(appointmentId, "COMPLETED");
            
            if (success && completionNotes != null && !completionNotes.trim().isEmpty()) {
                // Cập nhật ghi chú kết luận nếu có
                appointmentDAO.updateDoctorStatus(appointmentId, "ACCEPTED", completionNotes);
            }
            
            if (success) {
                // Tự động tạo invoice cho appointment đã hoàn thành
                invoiceService.createInvoiceForCompletedAppointment(appointmentId);
            }
        } else {
            // Xử lý accept/reject như cũ
            String doctorStatus = "accept".equals(action) ? "ACCEPTED" : "REJECTED";
            success = appointmentDAO.updateDoctorStatus(appointmentId, doctorStatus, doctorNotes);
            
            if (success && "ACCEPTED".equals(doctorStatus)) {
                // Nếu bác sĩ đồng ý tiếp nhận, cũng cập nhật trạng thái lịch hẹn chung thành CONFIRMED
                appointmentDAO.updateStatus(appointmentId, "CONFIRMED");
            }
        }
        
        if (success) {
            // Redirect về lại trang chi tiết kèm theo cờ thông báo thành công
            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=true");
        } else {
            // Redirect về kèm theo cờ báo lỗi nếu cập nhật DB thất bại
            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=true");
        }
    }
}
