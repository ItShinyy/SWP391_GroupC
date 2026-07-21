package com.dermathologyai.model;

import java.time.LocalDateTime;

/**
 * Lớp đại diện cho đối tượng Bác sĩ (Doctor).
 */
public class Doctor {
    private String id;               // ID bác sĩ
    private String userId;           // ID liên kết với tài khoản User
    private String clinicId;         // ID liên kết với Phòng khám (Clinic)
    private String specialization;   // Chuyên môn (ví dụ: Da liễu, Trị mụn...)
    private String licenseNumber;    // Số giấy phép hành nghề
    private String bio;              // Giới thiệu bản thân / Tiểu sử
    private boolean isActive;        // Trạng thái hoạt động
    private LocalDateTime createdAt; // Thời gian tạo hồ sơ
    private LocalDateTime updatedAt; // Thời gian cập nhật hồ sơ

    // Các trường thông tin bổ sung để hiển thị (không lưu trực tiếp trong bảng doctors)
    private String fullName;         // Họ tên bác sĩ (lấy từ bảng users)
    private String email;            // Email bác sĩ (lấy từ bảng users)
    private String phone;            // Số điện thoại bác sĩ (lấy từ bảng users)
    private String clinicName;       // Tên phòng khám bác sĩ làm việc (lấy từ bảng clinics)
    private String clinicAddress;    // Địa chỉ phòng khám (lấy từ bảng clinics)

    public Doctor() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getClinicId() { return clinicId; }
    public void setClinicId(String clinicId) { this.clinicId = clinicId; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }

    public String getClinicAddress() { return clinicAddress; }
    public void setClinicAddress(String clinicAddress) { this.clinicAddress = clinicAddress; }
}
