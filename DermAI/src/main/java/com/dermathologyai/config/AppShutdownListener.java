package com.dermathologyai.config;

import com.dermathologyai.dao.DBContext;
import com.dermathologyai.service.AiScreeningRecoveryService;
import com.dermathologyai.service.NotificationService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class AppShutdownListener implements ServletContextListener {
    private static final Logger logger = LoggerFactory.getLogger(AppShutdownListener.class);
    private ScheduledExecutorService recoveryScheduler;
    private ScheduledExecutorService maintenanceScheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            DBContext.verifyInitialized();
            if (AppConfig.getBoolean("ai.service.enabled", false)) {
                AppConfig.require("ai.service.base.url");
                AppConfig.require("ai.service.api.key");
                AppConfig.require("cloudinary.cloud.name");
                AppConfig.require("cloudinary.api.key");
                AppConfig.require("cloudinary.api.secret");
                AppConfig.require("media.object.key.secret");
                int intervalMinutes = AppConfig.getInt("ai.recovery.interval.minutes", 5);
                recoveryScheduler = Executors.newSingleThreadScheduledExecutor();
                recoveryScheduler.scheduleWithFixedDelay(() -> {
                    try {
                        new AiScreeningRecoveryService().recoverStuckAttempts();
                    } catch (RuntimeException e) {
                        logger.error("AI screening recovery job failed without exposing attempt details.");
                    }
                }, intervalMinutes, intervalMinutes, TimeUnit.MINUTES);
            }

            int notifyMinutes = AppConfig.getInt("notification.drain.interval.minutes", 1);
            maintenanceScheduler = Executors.newSingleThreadScheduledExecutor();
            maintenanceScheduler.scheduleWithFixedDelay(() -> {
                try {
                    new NotificationService().drainPendingEmails(20);
                } catch (RuntimeException e) {
                    logger.error("Notification outbox drain failed.");
                }
            }, notifyMinutes, notifyMinutes, TimeUnit.MINUTES);

            String deployUrl = AppConfig.get("app.base.url", "http://localhost:9999/DermAI");
            String contextPath = sce.getServletContext().getContextPath();
            System.out.println();
            System.out.println("========================================");
            System.out.println("  DermAI deploy: " + deployUrl);
            System.out.println("  context-path:  " + (contextPath == null || contextPath.isEmpty() ? "/" : contextPath));
            System.out.println("========================================");
            System.out.println();
            logger.info("DermAI deploy: {} (context-path={})", deployUrl,
                contextPath == null || contextPath.isEmpty() ? "/" : contextPath);
        } catch (Throwable t) {
            // Without this, Tomcat fails the context and browsers only see HTTP 404.
            System.err.println("========================================");
            System.err.println("  DermAI FAILED TO START: " + t.getMessage());
            System.err.println("  Check local.properties / DB / AI config.");
            System.err.println("========================================");
            logger.error("DermAI context failed to start", t);
            throw t;
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Application shutting down. Closing HikariCP...");
        try {
            if (recoveryScheduler != null) recoveryScheduler.shutdownNow();
            if (maintenanceScheduler != null) maintenanceScheduler.shutdownNow();
            DBContext.shutdown();
            logger.info("HikariCP closed successfully.");
        } catch (Exception e) {
            logger.error("Error closing HikariCP during shutdown", e);
        }
    }
}
