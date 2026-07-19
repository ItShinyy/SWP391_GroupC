package com.dermathologyai.dao;

import com.dermathologyai.model.DoctorSchedule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class DoctorScheduleDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DoctorScheduleDAO.class);

    /**
     * Tìm kiếm lịch làm việc của bác sĩ trong một khoảng ngày cụ thể.
     * Kết quả được sắp xếp tăng dần theo ngày và thứ tự khung giờ MORNING -> AFTERNOON -> EVENING.
     *
     * @param doctorId ID của bác sĩ
     * @param from Ngày bắt đầu
     * @param to Ngày kết thúc
     * @return Danh sách các lịch khám (DoctorSchedule) được tạo cho bác sĩ trong khoảng ngày đó
     */
    public List<DoctorSchedule> findByDoctorAndDateRange(String doctorId, LocalDate from, LocalDate to) {
        List<DoctorSchedule> list = new ArrayList<>();
        String sql = "SELECT id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count, created_at " +
                     "FROM doctor_schedules WHERE doctor_id = ? AND schedule_date >= ? AND schedule_date <= ? " +
                     "ORDER BY schedule_date, CASE slot WHEN 'MORNING' THEN 1 WHEN 'AFTERNOON' THEN 2 WHEN 'EVENING' THEN 3 END";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tìm lịch làm việc của bác sĩ {} từ {} đến {}", doctorId, from, to, e);
        }
        return list;
    }

    /**
     * Lấy các ca làm việc của bác sĩ còn trống chỗ và có nhận đặt lịch trong một ngày cụ thể.
     * (Điều kiện: is_available = 1 và booked_count < max_patients).
     *
     * @param doctorId ID của bác sĩ
     * @param date Ngày muốn đặt lịch
     * @return Danh sách lịch làm việc sẵn sàng tiếp nhận bệnh nhân
     */
    public List<DoctorSchedule> findAvailableByDoctorAndDate(String doctorId, LocalDate date) {
        List<DoctorSchedule> list = new ArrayList<>();
        String sql = "SELECT id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count, created_at " +
                     "FROM doctor_schedules WHERE doctor_id = ? AND schedule_date = ? AND is_available = 1 AND booked_count < max_patients " +
                     "ORDER BY CASE slot WHEN 'MORNING' THEN 1 WHEN 'AFTERNOON' THEN 2 WHEN 'EVENING' THEN 3 END";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy lịch trống của bác sĩ {} ngày {}", doctorId, date, e);
        }
        return list;
    }

    /**
     * Thêm mới hoặc Cập nhật lịch làm việc của bác sĩ.
     * Sử dụng lệnh MERGE trong SQL Server: Nếu đã có lịch cho bác sĩ vào ngày và khung giờ đó thì UPDATE, nếu chưa thì INSERT.
     *
     * @param schedule Đối tượng chứa thông tin lịch khám
     * @return true nếu ghi vào database thành công, ngược lại là false
     */
    public boolean upsertSchedule(DoctorSchedule schedule) {
        String sql = "MERGE doctor_schedules AS target " +
                     "USING (SELECT ? AS doctor_id, ? AS schedule_date, ? AS slot) AS source " +
                     "ON target.doctor_id = source.doctor_id AND target.schedule_date = source.schedule_date AND target.slot = source.slot " +
                     "WHEN MATCHED THEN UPDATE SET is_available = ?, max_patients = ? " +
                     "WHEN NOT MATCHED THEN INSERT (doctor_id, schedule_date, slot, is_available, max_patients) VALUES (source.doctor_id, source.schedule_date, source.slot, ?, ?);";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, schedule.getDoctorId());
            ps.setDate(2, Date.valueOf(schedule.getScheduleDate()));
            ps.setString(3, schedule.getSlot());
            ps.setBoolean(4, schedule.isAvailable());
            ps.setInt(5, schedule.getMaxPatients());
            ps.setBoolean(6, schedule.isAvailable());
            ps.setInt(7, schedule.getMaxPatients());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi lưu/cập nhật lịch của bác sĩ {}", schedule.getDoctorId(), e);
        }
        return false;
    }

    /**
     * Tăng số lượng bệnh nhân đã đặt khám thành công lên 1 cho một ca làm việc cụ thể.
     * Kiểm tra điều kiện booked_count phải nhỏ hơn max_patients để tránh vượt tải.
     *
     * @param scheduleId ID của lịch khám
     * @return true nếu cập nhật thành công, ngược lại là false
     */
    public boolean incrementBookedCount(String scheduleId) {
        String sql = "UPDATE doctor_schedules SET booked_count = booked_count + 1 WHERE id = ? AND booked_count < max_patients";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi tăng số ca đã đặt cho lịch: {}", scheduleId, e);
        }
        return false;
    }

    public DoctorSchedule findByDoctorDateAndSlot(String doctorId, LocalDate date, String slot) {
        String sql = "SELECT id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count, created_at " +
                     "FROM doctor_schedules WHERE doctor_id = ? AND schedule_date = ? AND slot = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            ps.setDate(2, Date.valueOf(date));
            ps.setString(3, slot);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding schedule by doctor, date, and slot", e);
        }
        return null;
    }

    /**
     * Ánh xạ (map) một hàng kết quả từ ResultSet thành đối tượng DoctorSchedule.
     */
    private DoctorSchedule mapRow(ResultSet rs) throws SQLException {
        DoctorSchedule s = new DoctorSchedule();
        s.setId(rs.getString("id"));
        s.setDoctorId(rs.getString("doctor_id"));
        if (rs.getDate("schedule_date") != null) {
            s.setScheduleDate(rs.getDate("schedule_date").toLocalDate());
        }
        s.setSlot(rs.getString("slot"));
        s.setAvailable(rs.getBoolean("is_available"));
        s.setMaxPatients(rs.getInt("max_patients"));
        s.setBookedCount(rs.getInt("booked_count"));
        if (rs.getTimestamp("created_at") != null) {
            s.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return s;
    }
}
