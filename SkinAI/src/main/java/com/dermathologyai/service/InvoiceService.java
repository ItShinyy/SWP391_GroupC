package com.dermathologyai.service;

import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Invoice;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class InvoiceService {
    private static final Logger logger = LoggerFactory.getLogger(InvoiceService.class);
    private final InvoiceDAO invoiceDAO;
    private final AppointmentDAO appointmentDAO;

    public InvoiceService() {
        this.invoiceDAO = new InvoiceDAO();
        this.appointmentDAO = new AppointmentDAO();
    }

    /**
     * Tạo invoice tự động khi appointment hoàn thành
     */
    public String createInvoiceForCompletedAppointment(String appointmentId) {
        try {
            // Kiểm tra xem đã có invoice chưa
            Invoice existingInvoice = invoiceDAO.findByAppointmentId(appointmentId);
            if (existingInvoice != null) {
                logger.info("Invoice already exists for appointment: {}", appointmentId);
                return existingInvoice.getId();
            }

            // Lấy thông tin appointment
            Appointment appointment = appointmentDAO.findById(appointmentId);
            if (appointment == null) {
                logger.error("Appointment not found: {}", appointmentId);
                return null;
            }

            // Tạo invoice
            BigDecimal amount = calculateAppointmentFee(appointment);
            String description = generateInvoiceDescription(appointment);
            
            return invoiceDAO.createInvoiceForAppointment(appointmentId, amount, description);

        } catch (Exception e) {
            logger.error("Error creating invoice for appointment: {}", appointmentId, e);
            return null;
        }
    }

    /**
     * Tính phí khám bệnh
     */
    private BigDecimal calculateAppointmentFee(Appointment appointment) {
        // Mặc định 500,000 VND cho tất cả các loại khám
        // Có thể customize theo chuyên khoa, thời gian, v.v.
        return new BigDecimal("500000");
    }

    /**
     * Tạo mô tả cho invoice
     */
    private String generateInvoiceDescription(Appointment appointment) {
        StringBuilder description = new StringBuilder();
        description.append("Phí khám bệnh");
        
        if (appointment.getClinicName() != null) {
            description.append(" - ").append(appointment.getClinicName());
        }
        
        if (appointment.getAppointmentTime() != null) {
            description.append(" (").append(appointment.getAppointmentTime().toLocalDate()).append(")");
        }
        
        return description.toString();
    }

    /**
     * Cập nhật trạng thái thanh toán của invoice
     */
    public boolean markInvoiceAsPaid(String invoiceId) {
        try {
            return invoiceDAO.updateStatus(invoiceId, "PAID", LocalDateTime.now());
        } catch (Exception e) {
            logger.error("Error marking invoice as paid: {}", invoiceId, e);
            return false;
        }
    }
}