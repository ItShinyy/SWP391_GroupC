package com.dermathologyai.dao;

import com.dermathologyai.model.ClinicalPolicyEntry;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ClinicalPolicyDAO extends DBContext {
    private static final String SELECT =
        "SELECT id, disease_code, display_name, risk_level, recommendation, disclaimer FROM clinical_policy_entries";

    public ClinicalPolicyEntry findByDiseaseCode(String diseaseCode) {
        return queryOne(SELECT + " WHERE disease_code = ?", ClinicalPolicyDAO::map, diseaseCode);
    }

    public List<ClinicalPolicyEntry> findAll() {
        return queryList(SELECT + " ORDER BY disease_code", ClinicalPolicyDAO::map);
    }

    public boolean upsert(ClinicalPolicyEntry entry) {
        ClinicalPolicyEntry existing = findByDiseaseCode(entry.getDiseaseCode());
        if (existing == null) {
            return executeUpdate(
                "INSERT INTO clinical_policy_entries (id, disease_code, display_name, risk_level, recommendation, disclaimer)" +
                " VALUES (NEWID(), ?, ?, ?, ?, ?)",
                entry.getDiseaseCode(), entry.getDisplayName(), entry.getRiskLevel(),
                entry.getRecommendation(), entry.getDisclaimer()
            );
        }
        return executeUpdate(
            "UPDATE clinical_policy_entries SET display_name = ?, risk_level = ?, recommendation = ?, disclaimer = ?," +
            " updated_at = SYSUTCDATETIME() WHERE disease_code = ?",
            entry.getDisplayName(), entry.getRiskLevel(), entry.getRecommendation(), entry.getDisclaimer(),
            entry.getDiseaseCode()
        );
    }

    private static ClinicalPolicyEntry map(ResultSet rs) throws SQLException {
        ClinicalPolicyEntry entry = new ClinicalPolicyEntry();
        entry.setId(rs.getString("id"));
        entry.setDiseaseCode(rs.getString("disease_code"));
        entry.setDisplayName(rs.getString("display_name"));
        entry.setRiskLevel(rs.getString("risk_level"));
        entry.setRecommendation(rs.getString("recommendation"));
        entry.setDisclaimer(rs.getString("disclaimer"));
        return entry;
    }
}
