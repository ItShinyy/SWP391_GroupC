package com.dermathologyai.dao;

import com.dermathologyai.model.DoctorSchedule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;

public class DoctorScheduleDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DoctorScheduleDAO.class);

    private static final String SELECT_COLS =
        "SELECT id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count, created_at " +
        "FROM doctor_schedules";

    /**
     * Tìm kiếm lịch làm việc của bác sĩ trong một khoảng ngày cụ thể.
     */
    public List<DoctorSchedule> findByDoctorAndDateRange(String doctorId, LocalDate from, LocalDate to) {
        return queryList(
            SELECT_COLS + " WHERE doctor_id = ? AND schedule_date >= ? AND schedule_date <= ? " +
            "ORDER BY schedule_date, CASE slot WHEN 'MORNING' THEN 1 WHEN 'AFTERNOON' THEN 2 WHEN 'EVENING' THEN 3 END",
            DoctorScheduleDAO::mapRow, doctorId, Date.valueOf(from), Date.valueOf(to)
        );
    }

    /**
     * Lấy các ca làm việc của bác sĩ còn trống chỗ và có nhận đặt lịch trong một ngày cụ thể.
     */
    public List<DoctorSchedule> findAvailableByDoctorAndDate(String doctorId, LocalDate date) {
        return queryList(
            SELECT_COLS + " WHERE doctor_id = ? AND schedule_date = ? AND is_available = 1 AND booked_count < max_patients " +
            "ORDER BY CASE slot WHEN 'MORNING' THEN 1 WHEN 'AFTERNOON' THEN 2 WHEN 'EVENING' THEN 3 END",
            DoctorScheduleDAO::mapRow, doctorId, Date.valueOf(date)
        );
    }

    /**
     * Thêm mới hoặc Cập nhật lịch làm việc của bác sĩ.
     */
    public boolean upsertSchedule(DoctorSchedule schedule) {
        String sql = "MERGE doctor_schedules AS target " +
                     "USING (SELECT ? AS doctor_id, ? AS schedule_date, ? AS slot) AS source " +
                     "ON target.doctor_id = source.doctor_id AND target.schedule_date = source.schedule_date AND target.slot = source.slot " +
                     "WHEN MATCHED THEN UPDATE SET is_available = ?, max_patients = ? " +
                     "WHEN NOT MATCHED THEN INSERT (doctor_id, schedule_date, slot, is_available, max_patients) VALUES (source.doctor_id, source.schedule_date, source.slot, ?, ?);";
        return executeUpdate(sql, 
            schedule.getDoctorId(), Date.valueOf(schedule.getScheduleDate()), schedule.getSlot(),
            schedule.isAvailable(), schedule.getMaxPatients(),
            schedule.isAvailable(), schedule.getMaxPatients()
        );
    }

    /**
     * Tăng số lượng bệnh nhân đã đặt khám thành công lên 1 cho một ca làm việc cụ thể.
     */
    public boolean incrementBookedCount(String scheduleId) {
        return executeUpdate(
            "UPDATE doctor_schedules SET booked_count = booked_count + 1 WHERE id = ? AND booked_count < max_patients",
            scheduleId
        );
    }

    /**
     * Ánh xạ (map) một hàng kết quả từ ResultSet thành đối tượng DoctorSchedule.
     */
    private static DoctorSchedule mapRow(ResultSet rs) throws SQLException {
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
