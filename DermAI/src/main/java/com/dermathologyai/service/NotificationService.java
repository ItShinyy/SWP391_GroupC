package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.NotificationDAO;
import com.dermathologyai.model.Notification;
import com.dermathologyai.notification.MailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * DB outbox for appointment/payment emails + direct MailService for auth security alerts
 * (auth alert types are outside CHK_notifications_type).
 */
public class NotificationService {
    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
    private static final int MAX_EMAIL_ATTEMPTS = 5;

    private final NotificationDAO notificationDAO = new NotificationDAO();

    public void enqueue(String userId, String eventKey, String type, String title, String message, String targetUrl) {
        if (userId == null || userId.isBlank() || eventKey == null || eventKey.isBlank()) {
            return;
        }
        if (notificationDAO.findByEventKey(eventKey) != null) {
            return;
        }
        String id = notificationDAO.createPending(userId, eventKey, type, title, message, targetUrl);
        if (id == null) {
            logger.warn("Failed to enqueue notification event_key={}", eventKey);
        }
    }

    public void enqueueAppointmentCancelled(String userId, String appointmentId, String message) {
        enqueue(userId,
            "appointment.cancelled." + appointmentId,
            "APPOINTMENT_CANCELLED",
            "Lịch hẹn đã hủy",
            message == null || message.isBlank() ? "Lịch hẹn của bạn đã được hủy." : message,
            "/patient/appointments");
    }

    public void enqueuePaymentPending(String userId, String invoiceId, String message) {
        enqueue(userId,
            "payment.pending." + invoiceId,
            "PAYMENT_PENDING",
            "Hóa đơn chờ thanh toán",
            message == null || message.isBlank() ? "Bạn có hóa đơn chưa thanh toán sau buổi khám." : message,
            "/patient/appointments");
    }

    public void enqueuePaymentSuccess(String userId, String invoiceId) {
        enqueue(userId,
            "payment.success." + invoiceId,
            "PAYMENT_SUCCESS",
            "Thanh toán thành công",
            "Thanh toán hóa đơn đã được xác nhận.",
            "/patient/appointments");
    }

    public void enqueuePaymentFailed(String userId, String invoiceId) {
        enqueue(userId,
            "payment.failed." + invoiceId,
            "PAYMENT_FAILED",
            "Thanh toán thất bại",
            "Thanh toán không thành công. Bạn có thể thử lại.",
            "/patient/appointments");
    }

    public void enqueueAppointmentCompleted(String userId, String appointmentId) {
        enqueue(userId,
            "appointment.completed." + appointmentId,
            "APPOINTMENT_COMPLETED",
            "Buổi khám đã hoàn tất",
            "Buổi khám của bạn đã hoàn tất. Hãy xem hồ sơ bệnh án và đánh giá dịch vụ.",
            "/patient/appointments");
    }

    public void enqueueScreeningResultVisible(String userId, String reportId) {
        enqueue(userId,
            "screening.visible." + reportId,
            "SCREENING_RESULT_VISIBLE",
            "Kết quả sàng lọc đã được chia sẻ",
            "Bác sĩ đã xem xét và chia sẻ kết quả sàng lọc da liễu của bạn.",
            "/patient/reports/view?id=" + reportId);
    }

    public void enqueueFeedbackReplied(String userId, String feedbackId) {
        enqueue(userId,
            "feedback.replied." + feedbackId,
            "FEEDBACK_REPLIED",
            "Đánh giá của bạn đã được phản hồi",
            "Quản trị viên đã phản hồi đánh giá của bạn.",
            "/patient/feedback");
    }

    public void enqueueIssueReportUpdated(String userId, String reportId, String newStatus) {
        enqueue(userId,
            "issue.updated." + reportId + "." + newStatus,
            "ISSUE_REPORT_UPDATED",
            "Báo cáo sự cố đã được cập nhật",
            "Trạng thái báo cáo sự cố của bạn đã được cập nhật.",
            "/patient/issue-report");
    }

    /** Drain PENDING outbox rows; safe to call from a scheduler. */
    public int drainPendingEmails(int batchSize) {
        List<Notification> batch = notificationDAO.findPendingEmailBatch(batchSize);
        int sent = 0;
        for (Notification n : batch) {
            if (n.getEmailAttempts() >= MAX_EMAIL_ATTEMPTS) {
                notificationDAO.markFailedPermanent(n.getId(), "Exceeded max email attempts");
                continue;
            }
            if (!notificationDAO.markSending(n.getId())) {
                continue;
            }
            String email = n.getUserEmail();
            if (email == null || email.isBlank()) {
                notificationDAO.markFailedRetry(n.getId(), "Missing user email");
                continue;
            }
            boolean ok = MailService.sendMail(email, n.getTitle(), htmlBody(n));
            if (ok) {
                notificationDAO.markSent(n.getId());
                sent++;
            } else {
                notificationDAO.markFailedRetry(n.getId(), "SMTP send failed");
            }
        }
        return sent;
    }

    public void sendNewLoginAlert(String email, String ipAddress, String userAgent) {
        sendAuthAlert(email, "Cảnh báo đăng nhập mới — DermAI",
            "<p>Tài khoản của bạn vừa đăng nhập.</p><p>IP: " + escape(ipAddress) +
                "</p><p>Thiết bị: " + escape(userAgent) + "</p>");
    }

    public void sendPasswordChangedAlert(String email) {
        sendAuthAlert(email, "Mật khẩu đã thay đổi — DermAI",
            "<p>Mật khẩu tài khoản DermAI của bạn vừa được thay đổi.</p>");
    }

    public void sendEmailChangedAlert(String oldEmail) {
        sendAuthAlert(oldEmail, "Email tài khoản đã thay đổi — DermAI",
            "<p>Email liên kết với tài khoản DermAI của bạn vừa được thay đổi.</p>");
    }

    public void sendAccountLockStatusAlert(String email, String status) {
        sendAuthAlert(email, "Trạng thái tài khoản — DermAI",
            "<p>Trạng thái tài khoản của bạn: <strong>" + escape(status) + "</strong>.</p>");
    }

    private void sendAuthAlert(String email, String subject, String html) {
        if (email == null || email.isBlank()) return;
        if (AppConfig.get("mail.username", "").isBlank()) {
            logger.info("Auth alert skipped (mail not configured): {}", subject);
            return;
        }
        MailService.sendAsync(email, subject, html);
    }

    private static String htmlBody(Notification n) {
        StringBuilder sb = new StringBuilder();
        sb.append("<p>").append(escape(n.getMessage())).append("</p>");
        if (n.getTargetUrl() != null && !n.getTargetUrl().isBlank()) {
            String base = AppConfig.get("app.base.url", "");
            String href = base.isBlank() ? n.getTargetUrl() : base.replaceAll("/$", "") + n.getTargetUrl();
            sb.append("<p><a href=\"").append(escape(href)).append("\">Mở ứng dụng</a></p>");
        }
        return sb.toString();
    }

    private static String escape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
