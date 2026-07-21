package com.dermathologyai.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Lớp đại diện cho lịch làm việc/ca khám của Bác sĩ (DoctorSchedule).
 */
public class DoctorSchedule {
    private String id;               // ID lịch làm việc
    private String doctorId;         // ID của bác sĩ
    private LocalDate scheduleDate;  // Ngày làm việc (yyyy-MM-dd)
    private String slot;             // Khung giờ khám (MORNING, AFTERNOON, EVENING)
    private boolean isAvailable;     // Bác sĩ có nhận đặt lịch vào ca này không
    private int maxPatients;         // Số lượng bệnh nhân tối đa nhận trong ca này (mặc định: 5)
    private int bookedCount;         // Số lượng bệnh nhân đã đặt khám thành công trong ca này
    private LocalDateTime createdAt; // Ngày tạo lịch làm việc

    public DoctorSchedule() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getDoctorId() { return doctorId; }
    public void setDoctorId(String doctorId) { this.doctorId = doctorId; }

    public LocalDate getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(LocalDate scheduleDate) { this.scheduleDate = scheduleDate; }

    public String getSlot() { return slot; }
    public void setSlot(String slot) { this.slot = slot; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }

    public int getMaxPatients() { return maxPatients; }
    public void setMaxPatients(int maxPatients) { this.maxPatients = maxPatients; }

    public int getBookedCount() { return bookedCount; }
    public void setBookedCount(int bookedCount) { this.bookedCount = bookedCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getSlotDisplayName() {
        return switch (slot) {
            case "MORNING" -> "Sáng (8:00 - 12:00)";
            case "AFTERNOON" -> "Chiều (13:00 - 17:00)";
            case "EVENING" -> "Tối (18:00 - 21:00)";
            default -> slot;
        };
    }

    public boolean isFull() {
        return bookedCount >= maxPatients;
    }
}
