package com.dermathologyai.controller;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.Appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller để tạo test data - cập nhật một số appointments thành COMPLETED
 */
public class TestDataController extends HttpServlet {
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Tạo Test Data</title></head><body>");
            out.println("<h2>Đang cập nhật trạng thái appointments...</h2>");

            // Lấy tất cả appointments có trạng thái CREATED để update thành CONFIRMED
            List<Appointment> appointments = appointmentDAO.findAll(1, 50, null);
            
            out.println("<p>Tìm thấy " + appointments.size() + " appointments</p>");

            int updated = 0;
            for (Appointment apt : appointments) {
                if ("CREATED".equals(apt.getStatus())) {
                    boolean success = appointmentDAO.updateStatus(apt.getId(), "CONFIRMED");
                    if (success) {
                        updated++;
                        out.println("<p>✓ Cập nhật appointment " + apt.getId().substring(0, 8) + "... thành CONFIRMED (có thể thanh toán)</p>");
                    }
                    
                    // Chỉ update 5 appointments để test
                    if (updated >= 5) break;
                }
            }

            out.println("<h3>Hoàn thành!</h3>");
            out.println("<p><strong>Đã cập nhật " + updated + " appointments thành CONFIRMED</strong></p>");
            out.println("<p>Giờ bệnh nhân có thể thanh toán trước khi khám!</p>");
            out.println("<p><a href='" + req.getContextPath() + "/patient/appointments'>Xem danh sách appointments</a></p>");
            out.println("<p><a href='" + req.getContextPath() + "/admin/init-invoices'>Tạo invoices cho appointments CONFIRMED</a></p>");
            out.println("</body></html>");

        } catch (Exception e) {
            out.println("<h3>Lỗi: " + e.getMessage() + "</h3>");
            e.printStackTrace();
        } finally {
            out.close();
        }
    }
}