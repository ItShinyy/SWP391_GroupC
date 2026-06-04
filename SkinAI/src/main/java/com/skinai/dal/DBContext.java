package com.skinai.dal;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    protected Connection connection;

    public DBContext() {
        try {
            Properties properties = new Properties();
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("../ConnectDB.properties");
            // Fallback to application.properties if ConnectDB.properties is missing
            if (inputStream == null) {
                inputStream = getClass().getClassLoader().getResourceAsStream("application.properties");
            }
            try {
                if (inputStream != null) {
                    properties.load(inputStream);
                }
            } catch (IOException ex) {
                Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            }
            // Read from either the old properties names or the new ones
            String user = properties.getProperty("userID", properties.getProperty("db.username"));
            String pass = properties.getProperty("password", properties.getProperty("db.password"));
            String url = properties.getProperty("url", properties.getProperty("db.url"));
            
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public Connection getConnection() {
        return connection;
    }

    // ─── Query Helpers for Subclasses ────────────────────────────────────────

    @FunctionalInterface
    public interface RowMapper<T> {
        T map(ResultSet rs) throws SQLException;
    }

    protected <T> T queryOne(String sql, RowMapper<T> mapper, Object... params) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setParams(ps, params);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "executeUpdate failed: " + sql, e);
            return false;
        }
    }

    protected String insertReturningId(String sql, Object... params) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
