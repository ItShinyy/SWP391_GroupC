package com.dermathologyai.service;

import com.dermathologyai.dao.NotificationDAO;
import com.dermathologyai.dao.PaymentDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Notification;
import com.dermathologyai.model.PaymentNotificationData;
import com.dermathologyai.notification.MailService;
import com.dermathologyai.notification.MailTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

/** Coordinates persistent in-app notifications and email delivery. */
public class NotificationService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    /** Java polls committed PAID invoices; the Node/VNPay service remains untouched. */
    public void processCompletedPayments() {
        List<PaymentNotificationData> paidInvoices = paymentDAO.findPaidInvoicesWithoutSuccessNotification();
        for (PaymentNotificationData invoice : paidInvoices) {
            queuePaymentSuccess(invoice);
        }
        dispatchPendingEmails();
    }

    public void queuePaymentSuccess(PaymentNotificationData invoice) {
        String appointmentTime = invoice.getAppointmentTime() == null
            ? "Theo lịch đã đặt"
            : DATE_TIME.format(invoice.getAppointmentTime());
        String paidAt = invoice.getPaidAt() == null
            ? "Đã xác nhận"
            : DATE_TIME.format(invoice.getPaidAt());
        String paymentMethod = invoice.getPaymentMethod() == null || invoice.getPaymentMethod().isBlank()
            ? "Không xác định"
            : invoice.getPaymentMethod();
        String description = invoice.getDescription() == null || invoice.getDescription().isBlank()
            ? "Phí khám bệnh"
            : invoice.getDescription();

        StringBuilder message = new StringBuilder("Hệ thống đã ghi nhận thanh toán thành công.\n\n")
            .append("Mã hóa đơn: #").append(invoice.getInvoiceId()).append("\n")
            .append("Trạng thái: Đã thanh toán\n")
            .append("Số tiền: ").append(formatAmount(invoice.getAmount())).append("đ\n")
            .append("Phương thức thanh toán: ").append(paymentMethod).append("\n")
            .append("Thời điểm thanh toán: ").append(paidAt).append("\n")
            .append("Nội dung hóa đơn: ").append(description).append("\n\n")
            .append("Phòng khám: ").append(invoice.getClinicName()).append("\n")
            .append("Bác sĩ: ").append(invoice.getDoctorName()).append("\n")
            .append("Thời gian hẹn: ").append(appointmentTime);
        if (invoice.getTransactionReference() != null && !invoice.getTransactionReference().isBlank()) {
            message.append("\nMã giao dịch: ").append(invoice.getTransactionReference());
        }

        notificationDAO.createIfAbsent(
            invoice.getUserId(),
            "payment:" + invoice.getInvoiceId() + ":success",
            "PAYMENT_SUCCESS",
            "Thanh toán thành công",
            message.toString(),
            "/patient/appointments?appointmentId=" + invoice.getAppointmentId()
        );
    }

    public void queueAppointmentCancelled(String userId, Appointment appointment) {
        String appointmentTime = appointment.getAppointmentTime() == null
            ? "lịch hẹn của bạn"
            : DATE_TIME.format(appointment.getAppointmentTime());
        String clinicName = appointment.getClinicName() == null ? "phòng khám" : appointment.getClinicName();
        notificationDAO.createIfAbsent(
            userId,
            "appointment:" + appointment.getId() + ":cancelled",
            "APPOINTMENT_CANCELLED",
            "Lịch hẹn đã được hủy",
            "Lịch khám tại " + clinicName + " vào " + appointmentTime + " đã được hủy. " +
                "Nếu đã thanh toán online, số tiền đã trả sẽ không được hoàn lại.",
            "/patient/appointments?appointmentId=" + appointment.getId()
        );
    }

    /** Ready to call from the future clinic/admin doctor-change transaction. */
    public void queueDoctorChanged(String userId, String appointmentId, String oldDoctorName,
                                   String newDoctorName, String changeEventId) {
        notificationDAO.createIfAbsent(
            userId,
            "appointment:" + appointmentId + ":doctor-changed:" + changeEventId,
            "DOCTOR_CHANGED",
            "Bác sĩ khám đã được thay đổi",
            "Bác sĩ " + oldDoctorName + " đã được đổi thành bác sĩ " + newDoctorName + ". " +
                "Vui lòng xem lại thông tin lịch hẹn của bạn.",
            "/patient/appointments?appointmentId=" + appointmentId
        );
    }

    public void dispatchPendingEmails() {
        for (Notification notification : notificationDAO.findEmailCandidates(10)) {
            if (!notificationDAO.claimForEmail(notification.getId())) continue;
            try {
                if (notification.getRecipientEmail() == null || notification.getRecipientEmail().isBlank()) {
                    notificationDAO.markEmailFailed(notification.getId(), "Recipient email is missing");
                    continue;
                }
                boolean sent = MailService.sendMail(
                    notification.getRecipientEmail(),
                    "SkinAI - " + notification.getTitle(),
                    MailTemplate.buildNotificationMail(
                        notification.getRecipientName(), notification.getTitle(), notification.getMessage()
                    )
                );
                if (sent) {
                    notificationDAO.markEmailSent(notification.getId());
                } else {
                    notificationDAO.markEmailFailed(notification.getId(), "SMTP rejected the message");
                }
            } catch (Exception exception) {
                logger.warn("Could not deliver notification {}", notification.getId(), exception);
                notificationDAO.markEmailFailed(notification.getId(), exception.getMessage());
            }
        }
    }

    private static String formatAmount(BigDecimal amount) {
        NumberFormat vnd = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
        return vnd.format(amount == null ? BigDecimal.ZERO : amount);
    }
}
