package com.skinai.dal;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database context manager using HikariCP for connection pooling.
 */
public class DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DBContext.class);
    private static HikariDataSource dataSource;

    static {
        try {
            Properties props = new Properties();
            try (InputStream in = DBContext.class.getClassLoader().getResourceAsStream("application.properties")) {
                if (in == null) {
                    throw new RuntimeException("Unable to find application.properties");
                }
                props.load(in);
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setDriverClassName(props.getProperty("db.driver"));
            
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("db.pool.maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("db.pool.minimumIdle", "5")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("db.pool.idleTimeout", "300000")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("db.pool.connectionTimeout", "20000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("db.pool.maxLifetime", "1200000")));

            dataSource = new HikariDataSource(config);
            logger.info("HikariCP DataSource initialized successfully");
        } catch (Exception e) {
            logger.error("Failed to initialize HikariCP DataSource", e);
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBContext() {
        // Prevent instantiation
    }

    /**
     * Gets a connection from the pool.
     * @return Connection
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Closes the connection pool.
     */
    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            logger.info("HikariCP DataSource closed successfully");
        }
    }
}
