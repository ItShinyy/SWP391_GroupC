USE master;
GO

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
-- =========================================================
-- DROP TABLES
-- =========================================================
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
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    google_id VARCHAR(100) NULL,
    email VARCHAR(100) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    avatar_url VARCHAR(255) NULL,
    password_hash VARCHAR(255) NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'PATIENT',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_users PRIMARY KEY (id),
    CONSTRAINT UQ_users_google_id UNIQUE (google_id),
    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('PATIENT', 'ADMIN')),
    CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
);

-- =========================================================
-- 2. PATIENTS
-- =========================================================
CREATE TABLE patients (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER UNIQUE NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    gender VARCHAR(10) NULL
        CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    dob DATE NULL,
    address NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_patients_users
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================================================
-- 3. DISEASES
-- =========================================================
CREATE TABLE diseases (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    disease_name NVARCHAR(150) UNIQUE NOT NULL,
    disease_code VARCHAR(50) NULL,
    description NVARCHAR(MAX) NULL,
    symptoms NVARCHAR(MAX) NULL,
    severity_level VARCHAR(20) NULL
        CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH')),
    recommended_specialty NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

-- =========================================================
-- 4. CLINICS
-- =========================================================
CREATE TABLE clinics (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    google_place_id VARCHAR(100) UNIQUE NULL,
    clinic_name NVARCHAR(150) NOT NULL,
    address NVARCHAR(MAX) NOT NULL,
    phone VARCHAR(20) NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    specialty NVARCHAR(100) NULL,
    rating DECIMAL(2,1) NULL
        CHECK (rating >= 0 AND rating <= 5),
    website VARCHAR(255) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

-- =========================================================
-- 5. DIAGNOSIS REPORTS
-- =========================================================
CREATE TABLE diagnosis_reports (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    patient_id UNIQUEIDENTIFIER NOT NULL,
    disease_id UNIQUEIDENTIFIER NULL,
    clinic_id UNIQUEIDENTIFIER NULL,
    image_url VARCHAR(255) NOT NULL,
    heatmap_url VARCHAR(255) NULL,
    confidence_score DECIMAL(5,2) NULL
        CHECK (confidence_score >= 0 AND confidence_score <= 100),
    risk_level VARCHAR(20) NULL
        CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    recommendation NVARCHAR(MAX) NULL,
    model_version VARCHAR(50) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_diagnosis_reports_patients
        FOREIGN KEY (patient_id) REFERENCES patients(id),
    CONSTRAINT FK_diagnosis_reports_diseases
        FOREIGN KEY (disease_id) REFERENCES diseases(id),
    CONSTRAINT FK_diagnosis_reports_clinics
        FOREIGN KEY (clinic_id) REFERENCES clinics(id)
);

-- =========================================================
-- 6. APPOINTMENTS
-- =========================================================
CREATE TABLE appointments (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    patient_id UNIQUEIDENTIFIER NOT NULL,
    clinic_id UNIQUEIDENTIFIER NOT NULL,
    diagnosis_report_id UNIQUEIDENTIFIER NULL,
    appointment_time DATETIME2 NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED'
        CHECK (status IN ('CREATED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED', 'NO_SHOW')),
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_appointments_patients
        FOREIGN KEY (patient_id) REFERENCES patients(id),
    CONSTRAINT FK_appointments_clinics
        FOREIGN KEY (clinic_id) REFERENCES clinics(id),
    CONSTRAINT FK_appointments_reports
        FOREIGN KEY (diagnosis_report_id) REFERENCES diagnosis_reports(id)
);

-- =========================================================
-- 7. ARTICLES
-- =========================================================
CREATE TABLE articles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    title NVARCHAR(200) NOT NULL,
    slug VARCHAR(220) UNIQUE NOT NULL,
    thumbnail_url VARCHAR(255) NULL,
    content NVARCHAR(MAX) NOT NULL,
    author_user_id UNIQUEIDENTIFIER NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_articles_users
        FOREIGN KEY (author_user_id) REFERENCES users(id)
);

-- =========================================================
-- 8. AUDIT LOGS
-- =========================================================
CREATE TABLE audit_logs (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL,
    record_id UNIQUEIDENTIFIER NULL,
    old_values NVARCHAR(MAX) NULL,
    new_values NVARCHAR(MAX) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_audit_logs_users
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT INTO users
(
    google_id,
    email,
    full_name,
    avatar_url,
    password_hash,
    role,
    status
)
VALUES
(
    'google-1001',
    'john@example.com',
    N'John Doe',
    'https://example.com/avatar1.jpg',
    '$2a$10$johnsamplehashxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'PATIENT',
    'ACTIVE'
),
(
    'google-1002',
    'mary@example.com',
    N'Mary Nguyen',
    'https://example.com/avatar2.jpg',
    '$2a$10$marysamplehashxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'PATIENT',
    'ACTIVE'
),
(
    NULL,
    'admin@skinai.com',
    N'Admin User',
    'https://example.com/admin.jpg',
    '$2a$10$adminsamplehashxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'ADMIN',
    'ACTIVE'
);

INSERT INTO patients (user_id, phone, gender, dob, address)
SELECT id, '0912345678', 'MALE', '2001-05-12', N'Hanoi, Vietnam'
FROM users
WHERE email = 'john@example.com';

INSERT INTO diseases
(disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
VALUES
(N'Acne Vulgaris', 'L70.0', N'Common acne condition', N'Pimples, inflammation, blackheads', 'MEDIUM', N'Dermatology'),
(N'Atopic Dermatitis', 'L20', N'Chronic inflammatory skin disease', N'Itching, redness, dry skin', 'HIGH', N'Dermatology');

INSERT INTO clinics
(google_place_id, clinic_name, address, phone, latitude, longitude, specialty, rating, website)
VALUES
('place_001', N'SkinCare Clinic', N'123 Nguyen Trai, Hanoi', '0241234567', 21.028511, 105.804817, N'Dermatology', 4.8, 'https://skincareclinic.vn'),
('place_002', N'Derma Health Center', N'456 Le Loi, Ho Chi Minh City', '0287654321', 10.776889, 106.700806, N'Dermatology', 4.6, 'https://dermahealth.vn');

INSERT INTO diagnosis_reports
(patient_id, disease_id, clinic_id, image_url, heatmap_url, confidence_score, risk_level, recommendation, model_version)
SELECT
    p.id,
    d.id,
    c.id,
    'uploads/acne_01.jpg',
    'uploads/acne_01_heatmap.jpg',
    92.50,
    'MEDIUM',
    N'Visit a nearby dermatology clinic for further consultation.',
    'v1.0'
FROM patients p
JOIN diseases d ON d.disease_name = N'Acne Vulgaris'
JOIN clinics c ON c.clinic_name = N'SkinCare Clinic'
WHERE p.phone = '0912345678';

INSERT INTO appointments
(patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes)
SELECT
    p.id,
    c.id,
    r.id,
    DATEADD(DAY, 2, SYSDATETIME()),
    'CONFIRMED',
    N'Appointment created after AI diagnosis.'
FROM patients p
JOIN clinics c ON c.clinic_name = N'SkinCare Clinic'
JOIN diagnosis_reports r ON r.patient_id = p.id
WHERE p.phone = '0912345678';

INSERT INTO articles
(title, slug, thumbnail_url, content, author_user_id, status)
SELECT
    N'5 Signs You Should Visit a Dermatologist',
    '5-signs-visit-dermatologist',
    'https://example.com/article1.jpg',
    N'Article about early warning signs of skin diseases.',
    u.id,
    'PUBLISHED'
FROM users u
WHERE u.email = 'admin@skinai.com';

INSERT INTO audit_logs
(user_id, action, entity_type, record_id, new_values, ip_address, user_agent)
SELECT
    u.id,
    'CREATE_DIAGNOSIS_REPORT',
    'diagnosis_reports',
    r.id,
    N'{"status":"created"}',
    '127.0.0.1',
    N'Chrome Browser'
FROM users u
JOIN diagnosis_reports r ON 1 = 1
WHERE u.email = 'john@example.com';