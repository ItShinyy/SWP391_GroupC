package com.dermathologyai.dao;

import com.dermathologyai.model.AiModel;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

public class AiModelDAO extends DBContext {
    private static final String SELECT =
        "SELECT id, name, version, storage_path, is_active, created_at FROM ai_models";

    public AiModel findById(String id) {
        return queryOne(SELECT + " WHERE id = ?", AiModelDAO::map, id);
    }

    public AiModel findActive() {
        return queryOne(SELECT + " WHERE is_active = 1", AiModelDAO::map);
    }

    public List<AiModel> findAll() {
        return queryList(SELECT + " ORDER BY created_at DESC", AiModelDAO::map);
    }

    public boolean insert(AiModel model) {
        return executeUpdate(
            "INSERT INTO ai_models (id, name, version, storage_path, is_active) VALUES (?, ?, ?, ?, 0)",
            model.getId(), model.getName(), model.getVersion(), model.getStoragePath()
        );
    }

    public boolean activate(String id) {
        executeUpdate("UPDATE ai_models SET is_active = 0 WHERE is_active = 1");
        return executeUpdate("UPDATE ai_models SET is_active = 1 WHERE id = ?", id);
    }

    public boolean deactivate(String id) {
        return executeUpdate("UPDATE ai_models SET is_active = 0 WHERE id = ?", id);
    }

    public boolean deleteIfUnused(String id) {
        Integer refs = queryOne(
            "SELECT COUNT(*) AS n FROM ai_screening_attempts WHERE ai_model_id = ?",
            rs -> rs.getInt("n"),
            id
        );
        if (refs != null && refs > 0) return false;
        return executeUpdate("DELETE FROM ai_models WHERE id = ? AND is_active = 0", id);
    }

    public boolean isReferenced(String id) {
        Integer refs = queryOne(
            "SELECT COUNT(*) AS n FROM ai_screening_attempts WHERE ai_model_id = ?",
            rs -> rs.getInt("n"),
            id
        );
        return refs != null && refs > 0;
    }

    private static AiModel map(ResultSet rs) throws SQLException {
        AiModel model = new AiModel();
        model.setId(rs.getString("id"));
        model.setName(rs.getString("name"));
        model.setVersion(rs.getString("version"));
        model.setStoragePath(rs.getString("storage_path"));
        model.setActive(rs.getBoolean("is_active"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) model.setCreatedAt(created.toLocalDateTime());
        return model;
    }

    public static String newId() {
        return UUID.randomUUID().toString();
    }
}
