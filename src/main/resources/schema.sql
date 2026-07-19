USE master;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- RECREATE DATABASE
-- =========================================================
IF DB_ID('SkinAI_DB') IS NOT NULL
BEGIN
    ALTER DATABASE SkinAI_DB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE SkinAI_DB;
END
GO

CREATE DATABASE SkinAI_DB;
GO

USE SkinAI_DB;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- DROP TABLES (Sắp xếp theo thứ tự giải phóng khóa ngoại an toàn)
-- =========================================================
DROP TABLE IF EXISTS appointment_prescriptions; -- Chứa FK tới appointments
DROP TABLE IF EXISTS bug_reports;               -- Chứa FK tới users
DROP TABLE IF EXISTS appointment_lab_tests;     -- Chứa FK tới appointments
DROP TABLE IF EXISTS appointments;              -- Chứa FK tới patients, clinics, diagnosis_reports, doctors
DROP TABLE IF EXISTS doctor_schedules;          -- Chứa FK tới doctors
DROP TABLE IF EXISTS doctors;               -- Chứa FK tới users, clinics
DROP TABLE IF EXISTS user_tokens; -- Chứa FK tới users
DROP TABLE IF EXISTS audit_logs;            -- Chứa FK tới users
DROP TABLE IF EXISTS diagnosis_reports;     -- Chứa FK tới patients, diseases, clinics
DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS diseases;
DROP TABLE IF EXISTS patients;              -- Chứa FK tới users
DROP TABLE IF EXISTS users;                 -- Bảng cha cốt lõi (Xóa cuối cùng)

-- =========================================================
-- 1. USERS
-- =========================================================
CREATE TABLE users (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    google_id VARCHAR(100) NULL,
    email VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    pending_email VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    phone VARCHAR(20) NULL,
    username VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NULL, 
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_login_attempts INT NOT NULL DEFAULT 0,
    last_failed_login_at DATETIME2 NULL,
    lock_type VARCHAR(20) NULL,
    lock_reason NVARCHAR(500) NULL,
    locked_at DATETIME2 NULL,
    locked_by UNIQUEIDENTIFIER NULL,
    password_changed_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    last_login_at DATETIME2 NULL,
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_users PRIMARY KEY (id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT CHK_users_role CHECK (role IN ('USER', 'PATIENT', 'ADMIN', 'DOCTOR')),
    CONSTRAINT CHK_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    CONSTRAINT CHK_users_identity CHECK (
        email IS NOT NULL OR 
        phone IS NOT NULL OR 
        google_id IS NOT NULL
    ),
    CONSTRAINT FK_users_locked_by FOREIGN KEY (locked_by) REFERENCES users(id) ON DELETE NO ACTION
);

CREATE UNIQUE NONCLUSTERED INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;

-- =========================================================
-- 2. PATIENTS
-- =========================================================
CREATE TABLE patients (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    user_id UNIQUEIDENTIFIER UNIQUE NULL,
    gender VARCHAR(10) NULL,
    dob DATE NULL,
    address NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_patients PRIMARY KEY (id),
    CONSTRAINT FK_patients_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT CHK_patients_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER'))
);

-- =========================================================
-- 3. DISEASES
-- =========================================================
CREATE TABLE diseases (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    disease_name NVARCHAR(150) NOT NULL,
    disease_code VARCHAR(50) NULL,
    description NVARCHAR(2000) NULL,
    symptoms NVARCHAR(2000) NULL,
    severity_level VARCHAR(20) NULL,
    recommended_specialty NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_diseases PRIMARY KEY (id),
    CONSTRAINT UQ_diseases_name UNIQUE (disease_name)
);

-- =========================================================
-- 4. CLINICS
-- =========================================================
CREATE TABLE clinics (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    google_place_id VARCHAR(100) NULL,
    clinic_name NVARCHAR(150) NOT NULL,
    address NVARCHAR(500) NOT NULL,
    phone VARCHAR(20) NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    specialty NVARCHAR(100) NULL,
    rating DECIMAL(2,1) NULL,
    website VARCHAR(255) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_clinics PRIMARY KEY (id),
    CONSTRAINT CHK_clinics_rating CHECK (rating IS NULL OR rating BETWEEN 0 AND 5)
);

-- =========================================================
-- 4a. DOCTORS
-- =========================================================
CREATE TABLE doctors (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    user_id UNIQUEIDENTIFIER NOT NULL UNIQUE,
    clinic_id UNIQUEIDENTIFIER NOT NULL,
    specialization NVARCHAR(150) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    bio NVARCHAR(2000) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_doctors PRIMARY KEY (id),
    CONSTRAINT FK_doctors_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT FK_doctors_clinics FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE NO ACTION
);

-- =========================================================
-- 4b. DOCTOR SCHEDULES
-- =========================================================
CREATE TABLE doctor_schedules (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    doctor_id UNIQUEIDENTIFIER NOT NULL,
    schedule_date DATE NOT NULL,
    slot VARCHAR(20) NOT NULL, -- MORNING, AFTERNOON, EVENING
    is_available BIT NOT NULL DEFAULT 1,
    max_patients INT NOT NULL DEFAULT 10,
    booked_count INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_doctor_schedules PRIMARY KEY (id),
    CONSTRAINT UQ_doctor_schedules UNIQUE (doctor_id, schedule_date, slot),
    CONSTRAINT CHK_doctor_schedules_slot CHECK (slot IN ('MORNING', 'AFTERNOON', 'EVENING')),
    CONSTRAINT FK_doctor_schedules_doctors FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

-- =========================================================
-- 5. DIAGNOSIS REPORTS
-- =========================================================
CREATE TABLE diagnosis_reports (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    patient_id UNIQUEIDENTIFIER NOT NULL,
    disease_id UNIQUEIDENTIFIER NULL,
    clinic_id UNIQUEIDENTIFIER NULL,
    image_url VARCHAR(255) NOT NULL,
    heatmap_url VARCHAR(255) NULL,
    confidence_score DECIMAL(5,2) NULL,
    risk_level VARCHAR(20) NULL,
    recommendation NVARCHAR(2000) NULL,
    model_version VARCHAR(50) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_diagnosis_reports PRIMARY KEY (id),
    CONSTRAINT FK_diagnosis_reports_patients FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    CONSTRAINT FK_diagnosis_reports_diseases FOREIGN KEY (disease_id) REFERENCES diseases(id) ON DELETE SET NULL,
    CONSTRAINT FK_diagnosis_reports_clinics FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL,
    CONSTRAINT CHK_reports_confidence CHECK (confidence_score IS NULL OR confidence_score BETWEEN 0 AND 100),
    CONSTRAINT CHK_reports_risk CHECK (risk_level IS NULL OR risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
);

-- =========================================================
-- 6. APPOINTMENTS
-- =========================================================
CREATE TABLE appointments (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    request_id VARCHAR(100) NOT NULL,
    patient_id UNIQUEIDENTIFIER NOT NULL,
    clinic_id UNIQUEIDENTIFIER NOT NULL,
    diagnosis_report_id UNIQUEIDENTIFIER NULL,
    appointment_time DATETIME2 NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    notes NVARCHAR(1000) NULL,
    patient_name NVARCHAR(100) NULL,
    patient_dob DATE NULL,
    patient_gender VARCHAR(10) NULL,
    doctor_id UNIQUEIDENTIFIER NULL,
    doctor_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    doctor_notes NVARCHAR(2000) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_appointments PRIMARY KEY (id),
    CONSTRAINT UQ_appointments_request_id UNIQUE (request_id),
    CONSTRAINT UQ_appointments_patient_time UNIQUE (patient_id, appointment_time),
    CONSTRAINT CHK_appointments_status CHECK (status IN ('CREATED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    CONSTRAINT FK_appointments_patients FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE NO ACTION,
    CONSTRAINT FK_appointments_clinics FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE NO ACTION,
    CONSTRAINT FK_appointments_reports FOREIGN KEY (diagnosis_report_id) REFERENCES diagnosis_reports(id) ON DELETE NO ACTION,
    CONSTRAINT FK_appointments_doctors FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE NO ACTION
);

-- =========================================================
-- 6a. APPOINTMENT PRESCRIPTIONS
-- =========================================================
CREATE TABLE appointment_prescriptions (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    appointment_id UNIQUEIDENTIFIER NOT NULL,
    drug_name NVARCHAR(150) NOT NULL,
    quantity INT NOT NULL,
    dosage NVARCHAR(500) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_appointment_prescriptions PRIMARY KEY (id),
    CONSTRAINT FK_appointment_prescriptions_appointments FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

-- =========================================================
-- 6b. SYSTEM BUG REPORTS
-- =========================================================
CREATE TABLE bug_reports (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    user_id UNIQUEIDENTIFIER NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(2000) NOT NULL,
    url_path VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_bug_reports PRIMARY KEY (id),
    CONSTRAINT FK_bug_reports_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT CHK_bug_reports_status CHECK (status IN ('PENDING', 'RESOLVED', 'CLOSED'))
);

-- =========================================================
-- 7. AUDIT LOGS
-- =========================================================
CREATE TABLE audit_logs (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    user_id UNIQUEIDENTIFIER NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL,
    record_id UNIQUEIDENTIFIER NULL,
    old_values NVARCHAR(MAX) NULL,
    new_values NVARCHAR(MAX) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent NVARCHAR(500) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    error_message NVARCHAR(1000) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_audit_logs PRIMARY KEY (id),
    CONSTRAINT FK_audit_logs_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- =========================================================
-- 8. USER TOKENS
-- =========================================================
CREATE TABLE user_tokens (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    token VARCHAR(100) NOT NULL UNIQUE,
    purpose VARCHAR(50) NOT NULL DEFAULT 'RESET_PASSWORD',
    attempts INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    used_at DATETIME2 NULL,
    expires_at DATETIME2 NOT NULL,
    CONSTRAINT FK_user_tokens_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT CHK_user_tokens_purpose CHECK (purpose IN ('RESET_PASSWORD', 'UNLOCK_ACCOUNT', 'VERIFY_EMAIL', 'VERIFY_PHONE')),
    CONSTRAINT CHK_user_tokens_attempts CHECK (attempts >= 0)
);
GO

-- =========================================================
-- INDEXES & FILTERED UNIQUE CONSTRAINTS
-- =========================================================
CREATE UNIQUE NONCLUSTERED INDEX UX_users_google_id 
ON users(google_id) 
WHERE google_id IS NOT NULL;

CREATE UNIQUE NONCLUSTERED INDEX UX_clinics_google_place_id 
ON clinics(google_place_id) 
WHERE google_place_id IS NOT NULL;

CREATE INDEX idx_patients_user_id ON patients(user_id);
CREATE INDEX idx_reports_patient_id ON diagnosis_reports(patient_id);
CREATE INDEX idx_reports_disease_id ON diagnosis_reports(disease_id);
CREATE INDEX idx_reports_clinic_id ON diagnosis_reports(clinic_id);
CREATE INDEX idx_reports_created_at ON diagnosis_reports(created_at);
CREATE INDEX idx_reports_patient_created_at ON diagnosis_reports(patient_id, created_at DESC);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_clinic_id ON appointments(clinic_id);
CREATE INDEX idx_appointments_clinic_time_status ON appointments(clinic_id, appointment_time, status);
CREATE INDEX idx_appointments_patient_status_time ON appointments(patient_id, status, appointment_time);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_perf ON audit_logs(created_at DESC, status);
CREATE INDEX idx_user_tokens_user_id ON user_tokens(user_id);
CREATE INDEX idx_user_tokens_token_expiry ON user_tokens(token, expires_at);
CREATE INDEX idx_users_role_status ON users(role, status);
GO

-- =========================================================
-- SEED DATA 
-- =========================================================
DECLARE @AdminId UNIQUEIDENTIFIER = NEWID();
DECLARE @User1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @User2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @User3Id UNIQUEIDENTIFIER = NEWID();
DECLARE @User4Id UNIQUEIDENTIFIER = NEWID();

DECLARE @Patient1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Patient2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Patient3Id UNIQUEIDENTIFIER = NEWID();

DECLARE @Doctor1UserId UNIQUEIDENTIFIER = NEWID();
DECLARE @Doctor2UserId UNIQUEIDENTIFIER = NEWID();
DECLARE @Doctor3UserId UNIQUEIDENTIFIER = NEWID();

DECLARE @Doctor1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Doctor2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Doctor3Id UNIQUEIDENTIFIER = NEWID();

DECLARE @DiseaseAcneId UNIQUEIDENTIFIER = NEWID();
DECLARE @DiseaseEczemaId UNIQUEIDENTIFIER = NEWID();
DECLARE @DiseaseMelanomaId UNIQUEIDENTIFIER = NEWID();

DECLARE @Clinic1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Clinic2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Clinic3Id UNIQUEIDENTIFIER = NEWID();

DECLARE @Report1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Report2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Report3Id UNIQUEIDENTIFIER = NEWID();

DECLARE @ReportD1A UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD1B UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD1C UNIQUEIDENTIFIER = NEWID();

DECLARE @ReportD2A UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD2B UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD2C UNIQUEIDENTIFIER = NEWID();

DECLARE @ReportD3A UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD3B UNIQUEIDENTIFIER = NEWID();
DECLARE @ReportD3C UNIQUEIDENTIFIER = NEWID();

-- Insert Users (Using BCrypt hash for password '123456')
INSERT INTO users (id, google_id, username, email, phone, full_name, password_hash, role, status, last_login_at)
VALUES
(@AdminId, NULL, 'admin', 'admin@skinai.com', '0909999888', N'Super Admin', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'ADMIN', 'ACTIVE', SYSDATETIME()),
(@User1Id, NULL, 'patient1', 'patient.local@gmail.com', '0901000001', N'Nguyễn Văn Local', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'PATIENT', 'ACTIVE', SYSDATETIME()),
(@User2Id, 'google-id-12345', 'patient2', 'patient.google@gmail.com', '0902000002', N'Trần Thị Google', NULL, 'PATIENT', 'ACTIVE', SYSDATETIME()),
(@User3Id, NULL, 'patient3', 'patient.locked@gmail.com', '0903000003', N'Lê Văn Locked', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'PATIENT', 'LOCKED', DATEADD(MONTH, -4, SYSDATETIME())),
(@User4Id, NULL, 'patient4', 'patient.inactive@gmail.com', '0904000004', N'Phạm Thị Inactive', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'PATIENT', 'INACTIVE', SYSDATETIME()),
(@Doctor1UserId, NULL, 'bs.nguyenvana', 'bs.nguyenvana@skinai.com', '0911000001', N'BS. Nguyễn Văn A', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME()),
(@Doctor2UserId, NULL, 'bs.tranthib', 'bs.tranthib@skinai.com', '0911000002', N'BS. Trần Thị B', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME()),
(@Doctor3UserId, NULL, 'bs.levanc', 'bs.levanc@skinai.com', '0911000003', N'BS. Lê Văn C', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME());

-- Insert Patients
INSERT INTO patients (id, user_id, gender, dob, address)
VALUES
(@Patient1Id, @User1Id, 'MALE', '1995-10-20', N'Quận 1, TP.HCM'),
(@Patient2Id, @User2Id, 'FEMALE', '1998-05-15', N'Cầu Giấy, Hà Nội'),
(@Patient3Id, @User3Id, 'OTHER', '2000-01-01', N'Hải Châu, Đà Nẵng');

-- Insert Diseases
INSERT INTO diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
VALUES
(@DiseaseAcneId, N'Mụn trứng cá (Acne)', 'L70', N'Tình trạng da liễu phổ biến gây tổn thương mụn bọc, mụn đỏ.', N'Mụn mủ, sưng đỏ, da nhiều dầu nhờn', 'LOW', N'Da liễu tổng quát'),
(@DiseaseEczemaId, N'Viêm da cơ địa (Eczema)', 'L20', N'Bệnh viêm da mãn tính gây ngứa ngáy và khô rát.', N'Ngứa ngáy, đỏ da, bong tróc vảy', 'MEDIUM', N'Da liễu dị ứng'),
(@DiseaseMelanomaId, N'Ung thư hắc tố (Melanoma)', 'C43', N'Dạng ung thư da nguy hiểm nhất bắt nguồn từ tế bào tạo sắc tố.', N'Nốt ruồi bất thường, loét da, rỉ máu', 'HIGH', N'Ung thư da liễu');

-- Insert Clinics
INSERT INTO clinics (id, google_place_id, clinic_name, address, phone, latitude, longitude, specialty, rating, website, is_active)
VALUES
(@Clinic1Id, 'place_ok_1', N'Phòng khám Da liễu Trung Ương', N'15A Phương Mai, Đống Đa, Hà Nội', '0241111222', 21.0062, 105.8402, N'Da liễu tổng quát', 4.9, 'https://dalieu.vn', 1),
(@Clinic2Id, 'place_ok_2', N'O2 Skin Clinic', N'343/5F Tô Hiến Thành, Quận 10, TP.HCM', '0283333444', 10.7769, 106.6669, N'Trị mụn & Sẹo', 4.5, 'https://o2skin.vn', 1),
(@Clinic3Id, 'place_closed', N'Phòng khám Thẩm mỹ X (Ngừng hoạt động)', N'Khuất Duy Tiến, Hà Nội', NULL, 21.0000, 105.8000, N'Thẩm mỹ ngoại khoa', 2.0, NULL, 0);

-- Insert Doctors
INSERT INTO doctors (id, user_id, clinic_id, specialization, license_number, bio)
VALUES
(@Doctor1Id, @Doctor1UserId, @Clinic1Id, N'Da liễu tổng quát', '12345/BYT-CCHN', N'Bác sĩ chuyên khoa I Da liễu với hơn 10 năm kinh nghiệm tại Bệnh viện Da liễu Trung Ương.'),
(@Doctor2Id, @Doctor2UserId, @Clinic2Id, N'Trị mụn & Thẩm mỹ', '67890/BYT-CCHN', N'Chuyên gia điều trị các loại mụn trứng cá nặng, sẹo rỗ và trẻ hóa da thẩm mỹ.'),
(@Doctor3Id, @Doctor3UserId, @Clinic1Id, N'Ung thư da & Phẫu thuật', '11223/BYT-CCHN', N'Phó trưởng khoa Phẫu thuật thẩm mỹ, chuyên môn sâu về ung thư hắc tố da.');

-- Insert Diagnosis Reports
INSERT INTO diagnosis_reports (id, patient_id, disease_id, clinic_id, image_url, heatmap_url, confidence_score, risk_level, recommendation)
VALUES
(@Report1Id, @Patient1Id, @DiseaseAcneId, @Clinic2Id, 'uploads/acne_test.jpg', 'uploads/acne_heat.jpg', 95.50, 'LOW', N'Vệ sinh da sạch sẽ, hạn chế đồ cay nóng và sử dụng gel trị mụn.'),
(@Report2Id, @Patient2Id, @DiseaseMelanomaId, NULL, 'uploads/melanoma_test.jpg', 'uploads/melanoma_heat.jpg', 88.00, 'HIGH', N'CẢNH BÁO: Phát hiện bất thường mức độ cao. Vui lòng đến ngay bệnh viện chuyên khoa để làm sinh thiết!'),
(@Report3Id, @Patient3Id, @DiseaseEczemaId, @Clinic1Id, 'uploads/eczema_test.jpg', NULL, 45.00, 'MEDIUM', N'Mô hình phát hiện mật độ tổn thương trung bình. Khuyến nghị bôi kem dưỡng ẩm và khám chuyên khoa.'),

-- Reports for Doctor 1 (Eczema)
(@ReportD1A, @Patient2Id, @DiseaseEczemaId, @Clinic1Id, 'uploads/eczema_test.jpg', NULL, 78.40, 'MEDIUM', N'Tổn thương da khô, đỏ và ngứa nhiều ở vùng khuỷu tay. Đề xuất điều trị bôi corticoid nhẹ.'),
(@ReportD1B, @Patient3Id, @DiseaseEczemaId, @Clinic1Id, 'uploads/eczema_test.jpg', NULL, 82.10, 'MEDIUM', N'Viêm da dị ứng tiếp xúc giai đoạn bán cấp. Cần bôi kem làm mềm da và uống thuốc kháng histamin.'),
(@ReportD1C, @Patient1Id, @DiseaseEczemaId, @Clinic1Id, 'uploads/eczema_test.jpg', NULL, 35.20, 'LOW', N'Ngứa da nhẹ, chưa rõ tổn thương viêm. Khuyến nghị bôi kem dưỡng ẩm dịu nhẹ.'),

-- Reports for Doctor 2 (Acne)
(@ReportD2A, @Patient2Id, @DiseaseAcneId, @Clinic2Id, 'uploads/acne_test.jpg', 'uploads/acne_heat.jpg', 92.00, 'LOW', N'Mụn trứng cá mức độ trung bình có viêm. Sử dụng sửa rửa mặt salicylic acid và bôi adapalene.'),
(@ReportD2B, @Patient3Id, @DiseaseAcneId, @Clinic2Id, 'uploads/acne_test.jpg', 'uploads/acne_heat.jpg', 89.50, 'LOW', N'Mụn trứng cá bọc vùng cằm. Cần kết hợp thuốc bôi và kháng sinh uống theo chỉ định.'),
(@ReportD2C, @Patient1Id, @DiseaseAcneId, @Clinic2Id, 'uploads/acne_test.jpg', 'uploads/acne_heat.jpg', 94.10, 'LOW', N'Mụn cám, mụn đầu đen rải rác. Vệ sinh da tốt và tẩy tế bào chết định kỳ.'),

-- Reports for Doctor 3 (Melanoma)
(@ReportD3A, @Patient1Id, @DiseaseMelanomaId, @Clinic1Id, 'uploads/melanoma_test.jpg', 'uploads/melanoma_heat.jpg', 85.00, 'HIGH', N'Nốt ruồi có dấu hiệu biến đổi sắc tố bất đối xứng. Cần sinh thiết gấp để chẩn đoán xác định.'),
(@ReportD3B, @Patient3Id, @DiseaseMelanomaId, @Clinic1Id, 'uploads/melanoma_test.jpg', 'uploads/melanoma_heat.jpg', 91.20, 'HIGH', N'Tổn thương sẫm màu bờ không đều. Nghi ngờ u hắc tố ác tính, đề xuất nhập viện phẫu thuật sớm.'),
(@ReportD3C, @Patient2Id, @DiseaseMelanomaId, @Clinic1Id, 'uploads/melanoma_test.jpg', 'uploads/melanoma_heat.jpg', 76.50, 'HIGH', N'Dermoscopy phát hiện biến dạng mạng lưới sắc tố. Đề xuất khám chuyên khoa ung bướu da.');

-- Insert Doctor Schedules
INSERT INTO doctor_schedules (id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count)
VALUES
(NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'MORNING', 1, 10, 1),
(NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'AFTERNOON', 1, 10, 0),
(NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'EVENING', 1, 5, 0),
(NEWID(), @Doctor2Id, CAST(GETDATE() AS DATE), 'AFTERNOON', 1, 8, 1);

-- Insert Appointments
INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes, doctor_id, doctor_status, doctor_notes)
VALUES
(NEWID(), 'req-seed-01', @Patient1Id, @Clinic2Id, @Report1Id, DATEADD(DAY, 2, SYSDATETIME()), 'CREATED', N'Bệnh nhân đặt khám sau khi có kết quả chẩn đoán AI.', @Doctor2Id, 'PENDING', NULL),
(NEWID(), 'req-seed-02', @Patient2Id, @Clinic1Id, @Report2Id, DATEADD(DAY, 1, SYSDATETIME()), 'CONFIRMED', N'Đã liên hệ xác nhận lịch hẹn khẩn cấp cho ca rủi ro cao.', @Doctor3Id, 'ACCEPTED', N'Ca rủi ro cao, cần khám gấp. Đã xác nhận lịch hẹn.'),
(NEWID(), 'req-seed-03', @Patient1Id, @Clinic1Id, NULL, DATEADD(DAY, -10, SYSDATETIME()), 'COMPLETED', N'Lịch hẹn hoàn thành trong quá khứ.', @Doctor1Id, 'ACCEPTED', N'Bệnh nhân đã khám xong, kê đơn thuốc điều trị viêm da.'),

-- Appointments for Doctor 1 (bs.nguyenvana)
(NEWID(), 'req-d1-01', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 9, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Có vết ngứa đỏ ở tay kéo dài 1 tuần.', @Doctor1Id, 'ACCEPTED', NULL),
(NEWID(), 'req-d1-02', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 14, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Viêm da cơ địa tái phát nặng sau khi tiếp xúc hóa chất.', @Doctor1Id, 'ACCEPTED', N'Đã đồng ý tiếp nhận ca khám, chuẩn bị hồ sơ bệnh án cũ.'),
(NEWID(), 'req-d1-03', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 10, DATEADD(DAY, -1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Hỏi tư vấn ngứa da dị ứng.', @Doctor1Id, 'REJECTED', N'Từ chối do bệnh nhân tự hủy lịch hoặc không phản hồi điện thoại xác nhận.'),

-- More appointments for Doctor 1 to test pagination, reports and history
(NEWID(), 'req-d1-m01', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 8, DATEADD(DAY, -1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Tái khám viêm da dị ứng.', @Doctor1Id, 'ACCEPTED', N'Bệnh đã thuyên giảm nhiều, tiếp tục bôi ẩm.'),
(NEWID(), 'req-d1-m02', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 9, DATEADD(DAY, -2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Ngứa đỏ vùng cổ.', @Doctor1Id, 'ACCEPTED', N'Chẩn đoán chàm tiếp xúc, kê đơn kem bôi.'),
(NEWID(), 'req-d1-m03', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 10, DATEADD(DAY, -3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Viêm da cơ địa.', @Doctor1Id, 'ACCEPTED', N'Đã kê kem bôi ngoài da dưỡng ẩm.'),
(NEWID(), 'req-d1-m04', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 14, DATEADD(DAY, -3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Nổi mề đay dị ứng.', @Doctor1Id, 'ACCEPTED', N'Cho uống kháng histamin 5 ngày.'),
(NEWID(), 'req-d1-m05', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 8, DATEADD(DAY, -4, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Chàm khô bàn tay.', @Doctor1Id, 'ACCEPTED', N'Kê mỡ mupirocin bôi giữ ẩm.'),
(NEWID(), 'req-d1-m06', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 15, DATEADD(DAY, -4, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Viêm da tiết bã vùng mặt.', @Doctor1Id, 'ACCEPTED', N'Hạn chế xà phòng mạnh, kê kem kháng nấm.'),
(NEWID(), 'req-d1-m07', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 9, DATEADD(DAY, -5, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Khám kích ứng mỹ phẩm.', @Doctor1Id, 'ACCEPTED', N'Dừng mỹ phẩm hiện tại, bôi phục hồi da.'),
(NEWID(), 'req-d1-m08', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 10, DATEADD(DAY, -5, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Viêm da dị ứng.', @Doctor1Id, 'ACCEPTED', N'Bệnh nhân đáp ứng tốt với thuốc bôi.'),
(NEWID(), 'req-d1-m09', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 11, DATEADD(DAY, -6, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Ngứa da chưa rõ nguyên nhân.', @Doctor1Id, 'ACCEPTED', N'Cần theo dõi thêm tiến triển dị ứng.'),
(NEWID(), 'req-d1-m10', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 14, DATEADD(DAY, -7, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Tái khám vảy nến nhẹ.', @Doctor1Id, 'ACCEPTED', N'Duy trì bôi mỡ dưỡng ẩm và corticoid.'),
(NEWID(), 'req-d1-m11', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 15, DATEADD(DAY, -7, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Khám chàm dị ứng sữa.', @Doctor1Id, 'ACCEPTED', N'Đổi sữa thủy phân, bôi dịu da.'),
(NEWID(), 'req-d1-m12', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 16, DATEADD(DAY, -8, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Dị ứng thời tiết.', @Doctor1Id, 'ACCEPTED', N'Kê thuốc kháng dị ứng dạng uống.'),
(NEWID(), 'req-d1-m13', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 9, DATEADD(DAY, -9, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Ngứa sẩn đỏ cục bộ.', @Doctor1Id, 'ACCEPTED', N'Kê kem bôi làm dịu da lành tính.'),
(NEWID(), 'req-d1-m14', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 10, DATEADD(DAY, -10, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Viêm da tiếp xúc.', @Doctor1Id, 'ACCEPTED', N'Bệnh nhân tự rửa lá gây nặng thêm, đã rửa sạch sát trùng.'),
(NEWID(), 'req-d1-m15', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 11, DATEADD(DAY, -12, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Ngứa da toàn thân.', @Doctor1Id, 'ACCEPTED', N'Đề xuất xét nghiệm ký sinh trùng.'),
(NEWID(), 'req-d1-m16', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 16, DATEADD(DAY, -2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Hủy lịch hẹn do bận việc riêng.', @Doctor1Id, 'REJECTED', N'Hủy theo yêu cầu của bệnh nhân.'),
(NEWID(), 'req-d1-m17', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 14, DATEADD(DAY, -4, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Đặt nhầm lịch khám.', @Doctor1Id, 'REJECTED', N'Hủy ca khám do đặt nhầm.'),
(NEWID(), 'req-d1-m18', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 15, DATEADD(DAY, -6, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Bệnh nhân bận đi công tác.', @Doctor1Id, 'REJECTED', N'Bàn giao hủy lịch khám.'),
(NEWID(), 'req-d1-m19', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 10, DATEADD(DAY, -8, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Không phản hồi điện thoại xác nhận.', @Doctor1Id, 'REJECTED', N'Tự động hủy do quá hạn.'),
(NEWID(), 'req-d1-m20', @Patient2Id, @Clinic1Id, NULL, DATEADD(HOUR, 10, DATEADD(DAY, 4, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Tái khám định kỳ viêm da.', @Doctor1Id, 'ACCEPTED', NULL),

-- Appointments for Doctor 2 (bs.tranthib)
(NEWID(), 'req-d2-01', @Patient2Id, @Clinic2Id, @ReportD2A, DATEADD(HOUR, 15, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Mụn viêm nhiều ở má và trán, muốn lấy nhân mụn.', @Doctor2Id, 'ACCEPTED', NULL),
(NEWID(), 'req-d2-02', @Patient3Id, @Clinic2Id, @ReportD2B, DATEADD(HOUR, 16, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Mụn bọc sưng đau dữ dội.', @Doctor2Id, 'ACCEPTED', N'Đã liên hệ bệnh nhân hẹn lúc 16h để khám và kê đơn kháng sinh.'),
(NEWID(), 'req-d2-03', @Patient1Id, @Clinic2Id, @ReportD2C, DATEADD(HOUR, 11, DATEADD(DAY, -3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'COMPLETED', N'Khám mụn đầu đen và tư vấn skincare.', @Doctor2Id, 'ACCEPTED', N'Bệnh nhân đã khám, nặn mụn và mua bộ sản phẩm trị mụn tại phòng khám.'),

-- Appointments for Doctor 3 (bs.levanc)
(NEWID(), 'req-d3-01', @Patient1Id, @Clinic1Id, @ReportD3A, DATEADD(HOUR, 19, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Nốt ruồi ở lưng to nhanh và thỉnh thoảng rỉ máu.', @Doctor3Id, 'ACCEPTED', NULL),
(NEWID(), 'req-d3-02', @Patient3Id, @Clinic1Id, @ReportD3B, DATEADD(HOUR, 8, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Nghi ngờ u hắc tố ác tính, xin chỉ định phẫu thuật.', @Doctor3Id, 'ACCEPTED', N'Ca nguy cơ cao, sắp xếp phẫu thuật cắt bỏ rộng vào buổi sáng.'),
(NEWID(), 'req-d3-03', @Patient2Id, @Clinic1Id, @ReportD3C, DATEADD(HOUR, 14, DATEADD(DAY, -2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CANCELLED', N'Khám nốt ruồi lạ ở chân.', @Doctor3Id, 'REJECTED', N'Bệnh nhân không đến đúng giờ hẹn và đã gọi điện xin hủy lịch.');

-- Insert User Tokens
INSERT INTO user_tokens (user_id, token, purpose, attempts, created_at, used_at, expires_at)
VALUES
(@User1Id, 'verify-email-token-001', 'VERIFY_EMAIL', 0, SYSDATETIME(), NULL, DATEADD(HOUR, 24, SYSDATETIME())),
(@User1Id, 'valid_token_123456_local_user', 'RESET_PASSWORD', 0, SYSDATETIME(), NULL, DATEADD(HOUR, 2, SYSDATETIME())),
(@User4Id, 'expired_token_789101_inactive', 'RESET_PASSWORD', 0, SYSDATETIME(), NULL, DATEADD(HOUR, -2, SYSDATETIME()));

-- Insert Audit Logs
INSERT INTO audit_logs (id, user_id, action, entity_type, record_id, old_values, new_values, ip_address, user_agent)
VALUES
(NEWID(), @AdminId, 'USER_LOGIN', 'users', @AdminId, NULL, N'{"status":"success"}', '127.0.0.1', 'Chrome/120.0'),
(NEWID(), @User1Id, 'CREATE_DIAGNOSIS_REPORT', 'diagnosis_reports', @Report1Id, NULL, N'{"disease_id":"Acne","score":95.5}', '192.168.1.5', 'iPhone/Safari');

-- Insert Appointment Prescriptions
INSERT INTO appointment_prescriptions (id, appointment_id, drug_name, quantity, dosage)
VALUES
(NEWID(), (SELECT TOP 1 id FROM appointments WHERE request_id = 'req-seed-03'), N'Thuốc A', 10, N'Uống 2 lần/ngày, mỗi lần 1 viên sau ăn'),
(NEWID(), (SELECT TOP 1 id FROM appointments WHERE request_id = 'req-seed-03'), N'Thuốc B', 1, N'Thoa 1 lần/ngày vào buổi tối trước khi đi ngủ');

-- Seed 15 extra waiting appointments for Doctor 1 (bs.nguyenvana) to test search, filter and pagination
INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes, doctor_id, doctor_status, doctor_notes, patient_name, patient_dob, patient_gender)
VALUES
(NEWID(), 'req-test-d1-01', @Patient1Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 9, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Khám viêm da ở cánh tay', @Doctor1Id, 'ACCEPTED', NULL, N'Nguyễn Văn An', '1990-05-12', 'MALE'),
(NEWID(), 'req-test-d1-02', @Patient2Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 10, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Ngứa đỏ dị ứng sau khi ăn hải sản', @Doctor1Id, 'ACCEPTED', NULL, N'Trần Thị Bình', '1995-08-20', 'FEMALE'),
(NEWID(), 'req-test-d1-03', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 11, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Bong tróc da khô ráp', @Doctor1Id, 'ACCEPTED', NULL, N'Lê Hoàng Châu', '1988-12-05', 'MALE'),
(NEWID(), 'req-test-d1-04', @Patient3Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 14, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Khám da nổi mề đay cục bộ', @Doctor1Id, 'ACCEPTED', NULL, N'Phạm Minh Duy', '2001-03-15', 'MALE'),
(NEWID(), 'req-test-d1-05', @Patient1Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 15, DATEADD(DAY, 1, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Kích ứng mỹ phẩm vùng má', @Doctor1Id, 'ACCEPTED', NULL, N'Hoàng Lan Anh', '1997-11-22', 'FEMALE'),
(NEWID(), 'req-test-d1-06', @Patient2Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 9, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Mẩn ngứa vùng cổ kéo dài', @Doctor1Id, 'ACCEPTED', NULL, N'Ngô Gia Bảo', '2005-07-30', 'MALE'),
(NEWID(), 'req-test-d1-07', @Patient1Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 10, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Vết đỏ tròn như hắc lào', @Doctor1Id, 'ACCEPTED', NULL, N'Vũ Phương Cường', '1992-09-14', 'MALE'),
(NEWID(), 'req-test-d1-08', @Patient3Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 11, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Nhiễm trùng da nhẹ ở ngón tay', @Doctor1Id, 'ACCEPTED', NULL, N'Đặng Thu Hà', '1996-01-25', 'FEMALE'),
(NEWID(), 'req-test-d1-09', @Patient1Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 14, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Vảy nến da đầu bong nhiều', @Doctor1Id, 'ACCEPTED', NULL, N'Đỗ Minh Hải', '1984-04-18', 'MALE'),
(NEWID(), 'req-test-d1-10', @Patient2Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 15, DATEADD(DAY, 2, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Chàm bã nhờn vùng trán', @Doctor1Id, 'ACCEPTED', NULL, N'Bùi Khánh Huyền', '1999-06-08', 'FEMALE'),
(NEWID(), 'req-test-d1-11', @Patient1Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 9, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Ngứa ngáy vùng lưng khó chịu', @Doctor1Id, 'ACCEPTED', NULL, N'Lý Thiên Long', '1991-02-28', 'MALE'),
(NEWID(), 'req-test-d1-12', @Patient3Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 10, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Viêm da cơ địa dị ứng', @Doctor1Id, 'ACCEPTED', NULL, N'Nguyễn Trọng Nghĩa', '1993-10-10', 'MALE'),
(NEWID(), 'req-test-d1-13', @Patient1Id, @Clinic1Id, @ReportD1A, DATEADD(HOUR, 11, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Tổn thương da ngứa rát', @Doctor1Id, 'ACCEPTED', NULL, N'Phan Thanh Oanh', '1994-07-17', 'FEMALE'),
(NEWID(), 'req-test-d1-14', @Patient2Id, @Clinic1Id, @ReportD1B, DATEADD(HOUR, 14, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Dị ứng tiếp xúc xi măng', @Doctor1Id, 'ACCEPTED', NULL, N'Trịnh Xuân Phong', '1987-12-31', 'MALE'),
(NEWID(), 'req-test-d1-15', @Patient3Id, @Clinic1Id, @ReportD1C, DATEADD(HOUR, 15, DATEADD(DAY, 3, DATEDIFF(DAY, 0, SYSDATETIME()))), 'CONFIRMED', N'Ngứa sần đỏ chân tay', @Doctor1Id, 'ACCEPTED', NULL, N'Vương Thảo Quỳnh', '2000-08-09', 'FEMALE');
GO
