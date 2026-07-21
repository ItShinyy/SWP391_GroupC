package com.dermathologyai.notification;

import com.dermathologyai.service.NotificationService;

/** Small background entry point for the notification scheduler. */
public class PaymentNotificationJob {
    private final NotificationService notificationService = new NotificationService();

    public void processCompletedPayments() {
        notificationService.processCompletedPayments();
    }
}
