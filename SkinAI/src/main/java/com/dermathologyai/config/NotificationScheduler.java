package com.dermathologyai.config;

import com.dermathologyai.notification.PaymentNotificationJob;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/** Runs notification discovery and delivery inside the existing Tomcat process. */
@WebListener
public class NotificationScheduler implements ServletContextListener {
    private static final Logger logger = LoggerFactory.getLogger(NotificationScheduler.class);
    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        executor = Executors.newSingleThreadScheduledExecutor();
        PaymentNotificationJob job = new PaymentNotificationJob();
        executor.scheduleWithFixedDelay(() -> {
            try {
                job.processCompletedPayments();
            } catch (Exception exception) {
                logger.error("Notification job failed", exception);
            }
        }, 10, 30, TimeUnit.SECONDS);
        logger.info("Payment notification scheduler started.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (executor != null) executor.shutdownNow();
    }
}
