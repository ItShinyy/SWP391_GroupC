package dal;

import model.Patient;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO extends DBContext {

    // Lấy tất cả patients
    public List<Patient> getAll() {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT * FROM patients";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy patient theo id
    public Patient getById(int id) {
        String sql = "SELECT * FROM patients WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy patient theo user_id
    public Patient getByUserId(int userId) {
        String sql = "SELECT * FROM patients WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm patient mới
    public boolean insert(Patient p) {
        String sql = "INSERT INTO patients (user_id, gender, dob, address, created_at, updated_at) VALUES (?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setString(2, p.getGender());
            ps.setDate(3, p.getDob());
            ps.setString(4, p.getAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật patient
    public boolean update(Patient p) {
        String sql = "UPDATE patients SET gender = ?, dob = ?, address = ?, updated_at = GETDATE() WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, p.getGender());
            ps.setDate(2, p.getDob());
            ps.setString(3, p.getAddress());
            ps.setInt(4, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa patient
    public boolean delete(int id) {
        String sql = "DELETE FROM patients WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Map 1 dòng ResultSet → Patient object
    private Patient mapRow(ResultSet rs) throws SQLException {
        return new Patient(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("gender"),
                rs.getDate("dob"),
                rs.getString("address"),
                rs.getTimestamp("created_at"),
                rs.getTimestamp("updated_at")
        );
    }
}
