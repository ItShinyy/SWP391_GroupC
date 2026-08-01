package com.dermathologyai.dao;

import com.dermathologyai.config.AppConfig;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    private static HikariDataSource dataSource;

    static {
        try {
            String user = AppConfig.require("db.username");
            String pass = AppConfig.require("db.password");
            String url = AppConfig.require("db.url");
            
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(url);
            config.setUsername(user);
            config.setPassword(pass);
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setIdleTimeout(300000);
            config.setConnectionTimeout(20000);
            
            dataSource = new HikariDataSource(config);
        } catch (IllegalStateException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE,
                "Database startup configuration is incomplete; refusing to start persistence. " + ex.getMessage());
            throw new ExceptionInInitializerError("Database runtime configuration is missing or invalid.");
        } catch (Exception ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE,
                "Database pool initialization failed; refusing to start persistence. Check database reachability and non-secret runtime settings.");
            throw new ExceptionInInitializerError("Database runtime configuration is missing or invalid.");
        }
    }
    public Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /** Forces the datasource initializer during application startup. */
    public static void verifyInitialized() {
        if (dataSource == null || dataSource.isClosed()) {
            throw new IllegalStateException("Database datasource is unavailable.");
        }
    }
    
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    // ─── Query Helpers for Subclasses ────────────────────────────────────────

    @FunctionalInterface
    public interface RowMapper<T> {
        T map(ResultSet rs) throws SQLException;
    }

    protected <T> T queryOne(String sql, RowMapper<T> mapper, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapper.map(rs);
            }
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "queryOne failed: " + sql, e);
        }
        return null;
    }

    protected <T> List<T> queryList(String sql, RowMapper<T> mapper, Object... params) {
        List<T> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapper.map(rs));
            }
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "queryList failed: " + sql, e);
        }
        return list;
    }

    protected boolean executeUpdate(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "executeUpdate failed: " + sql, e);
            return false;
        }
    }

    protected String insertReturningId(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "insertReturningId failed: " + sql, e);
        }
        return null;
    }

    protected int queryScalar(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "queryScalar failed: " + sql, e);
        }
        return 0;
    }

    protected void setParams(PreparedStatement ps, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }
}
