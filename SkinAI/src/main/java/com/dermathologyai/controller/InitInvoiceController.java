package com.dermathologyai.controller;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.model.Appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

/**
 * Controller để tạo invoices cho các appointments đã hoàn thành nhưng chưa có invoice
 */
public class InitInvoiceController extends HttpServlet {
    private InvoiceDAO invoiceDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        invoiceDAO = new InvoiceDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Tạo Invoices</title></head><body>");
            out.println("<h2>Đang tạo invoices cho các appointments...</h2>");

            // Lấy danh sách appointments chưa có invoice
            List<String> appointmentIds = invoiceDAO.findAppointmentsWithoutInvoice();
            
            out.println("<p>Tìm thấy " + appointmentIds.size() + " appointments chưa có invoice</p>");

            // Nếu không có appointments CONFIRMED/COMPLETED, tạo một số appointments để test
            if (appointmentIds.isEmpty()) {
                out.println("<p>Không có appointments với trạng thái CONFIRMED hoặc COMPLETED. Đang tạo invoices cho tất cả appointments...</p>");
                
                // Lấy tất cả appointments chưa có invoice
                appointmentIds = invoiceDAO.findAllAppointmentsWithoutInvoice();
                
                out.println("<p>Tìm thấy " + appointmentIds.size() + " appointments chưa có invoice (tất cả trạng thái)</p>");
            }

            int created = 0;
            BigDecimal defaultAmount = new BigDecimal("500000"); // 500,000 VND mặc định

            for (String appointmentId : appointmentIds) {
                try {
                    // Lấy thông tin appointment
                    Appointment appointment = appointmentDAO.findById(appointmentId);
                    if (appointment != null) {
                        String description = "Phí khám bệnh - " + 
                                           (appointment.getClinicName() != null ? appointment.getClinicName() : "Phòng khám");
                        
                        String invoiceId = invoiceDAO.createInvoiceForAppointment(
                            appointmentId, 
                            defaultAmount, 
                            description
                        );
                        
                        if (invoiceId != null) {
                            created++;
                            out.println("<p>✓ Tạo invoice cho appointment " + appointmentId.substring(0, 8) + "...</p>");
                        }
                    }
                } catch (Exception e) {
                    out.println("<p>✗ Lỗi tạo invoice cho appointment " + appointmentId + ": " + e.getMessage() + "</p>");
                }
            }

            out.println("<h3>Hoàn thành!</h3>");
            out.println("<p><strong>Đã tạo " + created + " invoices</strong></p>");
            out.println("<p><a href='" + req.getContextPath() + "/patient/invoice'>Xem danh sách hóa đơn</a></p>");
            out.println("<p><a href='" + req.getContextPath() + "/'>Về trang chủ</a></p>");
            out.println("</body></html>");

        } catch (Exception e) {
            out.println("<h3>Lỗi: " + e.getMessage() + "</h3>");
            e.printStackTrace();
        } finally {
            out.close();
        }
    }
}