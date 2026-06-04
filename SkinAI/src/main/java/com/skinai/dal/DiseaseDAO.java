package com.skinai.dal;

import com.skinai.model.Disease;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;

/**
 * DAO for the diseases table.
 */
public class DiseaseDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DiseaseDAO.class);

    private static final String SELECT_COLS =
        "SELECT id, disease_name, disease_code, description, symptoms," +
        " severity_level, recommended_specialty, created_at FROM diseases";

    public Disease findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", DiseaseDAO::mapRow, id);
    }

    public Disease findByCode(String code) {
        return queryOne(SELECT_COLS + " WHERE disease_code = ?", DiseaseDAO::mapRow, code);
    }

    public List<Disease> findAll() {
        return queryList(SELECT_COLS + " ORDER BY disease_name ASC", DiseaseDAO::mapRow);
    }

    public List<Disease> findAll(int page, int pageSize) {
        return queryList(
            SELECT_COLS + " ORDER BY disease_name ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
            DiseaseDAO::mapRow, (page - 1) * pageSize, pageSize
        );
    }

    public int countAll() {
        return queryScalar("SELECT COUNT(*) FROM diseases");
    }

    public String create(Disease d) {
        String sql = "INSERT INTO diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?)";
        return insertReturningId(sql,
            d.getDiseaseName(), d.getDiseaseCode(), d.getDescription(),
            d.getSymptoms(),
            d.getSeverityLevel() != null ? d.getSeverityLevel() : "LOW",
            d.getRecommendedSpecialty()
        );
    }

    public boolean update(Disease d) {
        String sql = "UPDATE diseases SET disease_name = ?, disease_code = ?, description = ?," +
                     " symptoms = ?, severity_level = ?, recommended_specialty = ? WHERE id = ?";
        return executeUpdate(sql,
            d.getDiseaseName(), d.getDiseaseCode(), d.getDescription(),
            d.getSymptoms(), d.getSeverityLevel(), d.getRecommendedSpecialty(), d.getId()
        );
    }

    public boolean delete(String id) {
        return executeUpdate("DELETE FROM diseases WHERE id = ?", id);
    }

    private static Disease mapRow(ResultSet rs) throws SQLException {
        Disease d = new Disease();
        d.setId(rs.getString("id"));
        d.setDiseaseName(rs.getString("disease_name"));
        d.setDiseaseCode(rs.getString("disease_code"));
        d.setDescription(rs.getString("description"));
        d.setSymptoms(rs.getString("symptoms"));
        d.setSeverityLevel(rs.getString("severity_level"));
        d.setRecommendedSpecialty(rs.getString("recommended_specialty"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) d.setCreatedAt(ca.toLocalDateTime());
        return d;
    }
}

