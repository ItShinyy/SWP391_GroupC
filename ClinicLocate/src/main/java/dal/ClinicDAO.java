package dal;

import model.Clinic;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ClinicDAO extends DBContext {

    private static final String BASE_SELECT = "SELECT * FROM clinics ";

    public List<Clinic> getAll() {
        return queryList(BASE_SELECT + "ORDER BY clinic_name");
    }

    public List<Clinic> getActiveClinics() {
        return queryList(BASE_SELECT
                + "WHERE is_active = 1 "
                + "ORDER BY province, clinic_name");
    }

    public Clinic getById(UUID id) {
        String sql = BASE_SELECT + "WHERE id = ?";

        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            pre.setObject(1, id);
            try (ResultSet resultSet = pre.executeQuery()) {
                return resultSet.next() ? mapRow(resultSet) : null;
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
            return null;
        }
    }
     //tìm bệnh viện
    public List<Clinic> searchActive(String keyword) {
        String sql = BASE_SELECT
                + "WHERE is_active = 1 "
                + "AND (clinic_name LIKE ? OR address LIKE ? "
                + "OR province LIKE ? OR specialty LIKE ?) "
                + "ORDER BY province, clinic_name";
        String pattern = "%" + (keyword == null ? "" : keyword.trim()) + "%";

        List<Clinic> clinics = new ArrayList<>();
        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            for (int index = 1; index <= 4; index++) {
                pre.setString(index, pattern);
            }

            try (ResultSet resultSet = pre.executeQuery()) {
                while (resultSet.next()) {
                    clinics.add(mapRow(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }
        return clinics;
    }

    public boolean insert(Clinic clinic) {
        String sql = "INSERT INTO clinics "
                + "(clinic_name, address, phone, latitude, longitude, facility_type, "
                + "specialty, province, website, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            setClinicParameters(pre, clinic);
            return pre.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }

    public boolean update(Clinic clinic) {
        if (clinic.getId() == null) {
            return false;
        }

        String sql = "UPDATE clinics SET clinic_name = ?, address = ?, phone = ?, "
                + "latitude = ?, longitude = ?, facility_type = ?, specialty = ?, "
                + "province = ?, website = ?, is_active = ?, "
                + "updated_at = SYSDATETIME() WHERE id = ?";

        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            setClinicParameters(pre, clinic);
            pre.setObject(11, clinic.getId());
            return pre.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }
// cập nhật trạng thái
    public boolean updateActiveStatus(UUID id, boolean active) {
        String sql = "UPDATE clinics SET is_active = ?, "
                + "updated_at = SYSDATETIME() WHERE id = ?";

        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            pre.setBoolean(1, active);
            pre.setObject(2, id);
            return pre.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }
//bay màu bệnh viện
    public boolean delete(UUID id) {
        String sql = "DELETE FROM clinics WHERE id = ?";

        try (PreparedStatement pre = connection.prepareStatement(sql)) {
            pre.setObject(1, id);
            return pre.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }
// xử lý câu lệch cho sql SELECT
    private List<Clinic> queryList(String sql) {
        List<Clinic> clinics = new ArrayList<>();

        try (PreparedStatement pre = connection.prepareStatement(sql);
             ResultSet resultSet = pre.executeQuery()) {
            while (resultSet.next()) {
                clinics.add(mapRow(resultSet));
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }
        return clinics;
    }
    // nhét vào
    private void setClinicParameters(PreparedStatement pre, Clinic clinic)
            throws SQLException {
        pre.setString(1, clinic.getClinicName());
        pre.setString(2, clinic.getAddress());
        pre.setString(3, clinic.getPhone());
        pre.setDouble(4, clinic.getLatitude());
        pre.setDouble(5, clinic.getLongitude());
        pre.setString(6, clinic.getFacilityType());
        pre.setString(7, clinic.getSpecialty());
        pre.setString(8, clinic.getProvince());
        pre.setString(9, clinic.getWebsite());
        pre.setBoolean(10, clinic.isActive());
    }
    //gọi dữ liệu từ DTB ra
    private Clinic mapRow(ResultSet resultSet) throws SQLException {
        return new Clinic(
                UUID.fromString(resultSet.getString("id")),
                resultSet.getString("clinic_name"),
                resultSet.getString("address"),
                resultSet.getString("phone"),
                resultSet.getDouble("latitude"),
                resultSet.getDouble("longitude"),
                resultSet.getString("facility_type"),
                resultSet.getString("specialty"),
                resultSet.getString("province"),
                resultSet.getString("website"),
                resultSet.getBoolean("is_active"),
                resultSet.getTimestamp("created_at"),
                resultSet.getTimestamp("updated_at")
        );
    }
}
