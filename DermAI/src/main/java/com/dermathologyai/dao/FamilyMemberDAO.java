package com.dermathologyai.dao;

import com.dermathologyai.model.FamilyMember;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

public class FamilyMemberDAO extends DBContext {
    private static final String SELECT_COLUMNS = "SELECT id, owner_user_id, full_name, date_of_birth, gender, relationship, "
            + "phone, email, province, ward, address_detail, country, ethnicity, occupation FROM family_members";

    public List<FamilyMember> findByOwnerUserId(String ownerUserId) {
        return queryList(SELECT_COLUMNS + " WHERE owner_user_id = ? ORDER BY created_at DESC",
                FamilyMemberDAO::mapRow, ownerUserId);
    }

    public FamilyMember findByIdAndOwnerUserId(String id, String ownerUserId) {
        return queryOne(SELECT_COLUMNS + " WHERE id = ? AND owner_user_id = ?",
                FamilyMemberDAO::mapRow, id, ownerUserId);
    }

    public String create(FamilyMember member) {
        String id = UUID.randomUUID().toString();
        String sql = "INSERT INTO family_members (id, owner_user_id, full_name, date_of_birth, gender, relationship, "
                + "phone, email, province, ward, address_detail, country, ethnicity, occupation, created_at, updated_at) "
                + "OUTPUT INSERTED.id VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        return insertReturningId(sql, id, member.getOwnerUserId(), member.getFullName(),
                Date.valueOf(member.getDateOfBirth()), member.getGender(), member.getRelationship(),
                member.getPhone(), member.getEmail(), member.getProvince(), member.getWard(),
                member.getAddressDetail(), member.getCountry(), member.getEthnicity(), member.getOccupation());
    }

    private static FamilyMember mapRow(ResultSet resultSet) throws SQLException {
        FamilyMember member = new FamilyMember();
        member.setId(resultSet.getString("id"));
        member.setOwnerUserId(resultSet.getString("owner_user_id"));
        member.setFullName(resultSet.getString("full_name"));
        Date dateOfBirth = resultSet.getDate("date_of_birth");
        if (dateOfBirth != null) member.setDateOfBirth(dateOfBirth.toLocalDate());
        member.setGender(resultSet.getString("gender"));
        member.setRelationship(resultSet.getString("relationship"));
        member.setPhone(resultSet.getString("phone"));
        member.setEmail(resultSet.getString("email"));
        member.setProvince(resultSet.getString("province"));
        member.setWard(resultSet.getString("ward"));
        member.setAddressDetail(resultSet.getString("address_detail"));
        member.setCountry(resultSet.getString("country"));
        member.setEthnicity(resultSet.getString("ethnicity"));
        member.setOccupation(resultSet.getString("occupation"));
        return member;
    }
}
