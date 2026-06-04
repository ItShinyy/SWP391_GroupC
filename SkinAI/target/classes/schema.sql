USE master;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- RECREATE DATABASE
-- =========================================================
IF DB_ID('SWP391') IS NOT NULL
BEGIN
    ALTER DATABASE SWP391
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE SWP391;
END
GO

CREATE DATABASE SWP391;
GO

USE SWP391;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- DROP TABLES (If exist)
-- =========================================================
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS articles;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS diagnosis_reports;
DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS diseases;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS users;

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
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    last_login_at DATETIME2 NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_users PRIMARY KEY (id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT CHK_users_role CHECK (role IN ('USER', 'PATIENT', 'ADMIN')),
    CONSTRAINT CHK_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    CONSTRAINT CHK_users_identity CHECK (
        email IS NOT NULL OR 
        phone IS NOT NULL OR 
        google_id IS NOT NULL
    )
);

CREATE UNIQUE NONCLUSTERED INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;

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

    CONSTRAINT PK_clinics PRIMARY KEY (id)
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
    CONSTRAINT FK_diagnosis_reports_clinics FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE SET NULL
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
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_appointments PRIMARY KEY (id),
    CONSTRAINT UQ_appointments_request_id UNIQUE (request_id),
    CONSTRAINT UQ_appointments_patient_time UNIQUE (patient_id, appointment_time),
    CONSTRAINT CHK_appointments_status CHECK (status IN ('CREATED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    CONSTRAINT FK_appointments_patients FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE NO ACTION,
    CONSTRAINT FK_appointments_clinics FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE NO ACTION,
    CONSTRAINT FK_appointments_reports FOREIGN KEY (diagnosis_report_id) REFERENCES diagnosis_reports(id) ON DELETE NO ACTION
);

-- =========================================================
-- 7. ARTICLES
-- =========================================================
CREATE TABLE articles (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    title NVARCHAR(200) NOT NULL,
    slug VARCHAR(220) NOT NULL,
    thumbnail_url VARCHAR(255) NULL,
    content NVARCHAR(MAX) NOT NULL,
    author_user_id UNIQUEIDENTIFIER NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_articles PRIMARY KEY (id),
    CONSTRAINT UQ_articles_slug UNIQUE (slug),
    CONSTRAINT FK_articles_users FOREIGN KEY (author_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- =========================================================
-- 8. AUDIT LOGS
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
-- 9. PASSWORD RESET TOKENS
-- =========================================================
CREATE TABLE password_reset_tokens (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    token VARCHAR(100) NOT NULL UNIQUE,
    purpose VARCHAR(50) NOT NULL DEFAULT 'RESET_PASSWORD',
    attempts INT NOT NULL DEFAULT 0,
    expires_at DATETIME NOT NULL,
    CONSTRAINT FK_password_tokens_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_clinic_id ON appointments(clinic_id);
CREATE INDEX idx_articles_status ON articles(status);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_perf ON audit_logs(created_at DESC, status);
CREATE INDEX idx_pwd_tokens_user_id ON password_reset_tokens(user_id);
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

DECLARE @DiseaseAcneId UNIQUEIDENTIFIER = NEWID();
DECLARE @DiseaseEczemaId UNIQUEIDENTIFIER = NEWID();
DECLARE @DiseaseMelanomaId UNIQUEIDENTIFIER = NEWID();

DECLARE @Clinic1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Clinic2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Clinic3Id UNIQUEIDENTIFIER = NEWID();

DECLARE @Report1Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Report2Id UNIQUEIDENTIFIER = NEWID();
DECLARE @Report3Id UNIQUEIDENTIFIER = NEWID();

-- Insert Users
INSERT INTO users (id, google_id, username, email, phone, full_name, password_hash, role, status, last_login_at)
VALUES
(@AdminId, NULL, 'admin', 'admin@skinai.com', '0909999888', N'Super Admin', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'ADMIN', 'ACTIVE', SYSDATETIME()),
(@User1Id, NULL, 'patient1', 'patient.local@gmail.com', '0901000001', N'Nguyễn Văn Local', '$2a$10$samplehashlocal', 'PATIENT', 'ACTIVE', SYSDATETIME()),
(@User2Id, 'google-id-12345', 'patient2', 'patient.google@gmail.com', '0902000002', N'Trần Thị Google', NULL, 'PATIENT', 'ACTIVE', SYSDATETIME()),
(@User3Id, NULL, 'patient3', 'patient.locked@gmail.com', '0903000003', N'Lê Văn Locked', '$2a$10$samplehashlocked', 'PATIENT', 'LOCKED', DATEADD(MONTH, -4, SYSDATETIME())),
(@User4Id, NULL, 'patient4', 'patient.inactive@gmail.com', '0904000004', N'Phạm Thị Inactive', '$2a$10$samplehashinactive', 'PATIENT', 'INACTIVE', SYSDATETIME());

-- Insert Patients (phone is now on users table, not here)
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

-- Insert Diagnosis Reports
INSERT INTO diagnosis_reports (id, patient_id, disease_id, clinic_id, image_url, heatmap_url, confidence_score, risk_level, recommendation)
VALUES
(@Report1Id, @Patient1Id, @DiseaseAcneId, @Clinic2Id, 'uploads/acne_test.jpg', 'uploads/acne_heat.jpg', 95.50, 'LOW', N'Vệ sinh da sạch sẽ, hạn chế đồ cay nóng và sử dụng gel trị mụn.'),
(@Report2Id, @Patient2Id, @DiseaseMelanomaId, NULL, 'uploads/melanoma_test.jpg', 'uploads/melanoma_heat.jpg', 88.00, 'HIGH', N'CẢNH BÁO: Phát hiện bất thường mức độ cao. Vui lòng đến ngay bệnh viện chuyên khoa để làm sinh thiết!'),
(@Report3Id, @Patient3Id, @DiseaseEczemaId, @Clinic1Id, 'uploads/eczema_test.jpg', NULL, 45.00, 'MEDIUM', N'Mô hình phát hiện mật độ tổn thương trung bình. Khuyến nghị bôi kem dưỡng ẩm và khám chuyên khoa.');

-- Insert Appointments
INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes)
VALUES
(NEWID(), 'req-seed-01', @Patient1Id, @Clinic2Id, @Report1Id, DATEADD(DAY, 2, SYSDATETIME()), 'CREATED', N'Bệnh nhân đặt khám sau khi có kết quả chẩn đoán AI.'),
(NEWID(), 'req-seed-02', @Patient2Id, @Clinic1Id, @Report2Id, DATEADD(DAY, 1, SYSDATETIME()), 'CONFIRMED', N'Đã liên hệ xác nhận lịch hẹn khẩn cấp cho ca rủi ro cao.'),
(NEWID(), 'req-seed-03', @Patient1Id, @Clinic1Id, NULL, DATEADD(DAY, -10, SYSDATETIME()), 'COMPLETED', N'Lịch hẹn hoàn thành trong quá khứ.');

-- Insert Articles
INSERT INTO articles (id, title, slug, thumbnail_url, content, author_user_id, status)
VALUES
(NEWID(), N'Cách chăm sóc da mụn chuẩn y khoa', 'cach-cham-soc-da-mun', 'img/thumb1.jpg', N'Bài viết chi tiết về các bước chăm sóc da mụn hiệu quả...', @AdminId, 'PUBLISHED'),
(NEWID(), N'Dấu hiệu nhận biết ung thư hắc tố da', 'dau-hieu-ung-thu-da', 'img/thumb2.jpg', N'Bản thảo phân tích cấu trúc nốt ruồi bất thường...', @AdminId, 'DRAFT'),
(NEWID(), N'Bài viết lưu trữ nội bộ', 'article-archived', NULL, N'Tài liệu lưu trữ không công khai ra ngoài.', @AdminId, 'ARCHIVED');

-- Insert Audit Logs
INSERT INTO audit_logs (id, user_id, action, entity_type, record_id, old_values, new_values, ip_address, user_agent)
VALUES
(NEWID(), @AdminId, 'USER_LOGIN', 'users', @AdminId, NULL, N'{"status":"success"}', '127.0.0.1', 'Chrome/120.0'),
(NEWID(), @User1Id, 'CREATE_DIAGNOSIS_REPORT', 'diagnosis_reports', @Report1Id, NULL, N'{"disease_id":"Acne","score":95.5}', '192.168.1.5', 'iPhone/Safari');

-- Insert Password Reset Tokens
INSERT INTO password_reset_tokens (user_id, token, purpose, attempts, expires_at)
VALUES
(@User1Id, 'valid_token_123456_local_user', 'RESET_PASSWORD', 0, DATEADD(HOUR, 2, SYSDATETIME())),
(@User4Id, 'expired_token_789101_inactive', 'RESET_PASSWORD', 0, DATEADD(HOUR, -2, SYSDATETIME()));
GO