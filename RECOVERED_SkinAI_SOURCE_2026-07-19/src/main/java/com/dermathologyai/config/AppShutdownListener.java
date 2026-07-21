package com.dermathologyai.config;

import com.dermathologyai.dao.DBContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebListener
public class AppShutdownListener implements ServletContextListener {
    private static final Logger logger = LoggerFactory.getLogger(AppShutdownListener.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("Application starting up...");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("Application shutting down. Closing HikariCP...");
        try {
            DBContext.shutdown();
            logger.info("HikariCP closed successfully.");
        } catch (Exception e) {
            logger.error("Error closing HikariCP during shutdown", e);
        }
    }
}
