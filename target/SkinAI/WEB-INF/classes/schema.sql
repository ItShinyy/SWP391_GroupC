-- =============================================
-- SkinAI Database Schema for SQL Server (SSMS)
-- Version: 1.0
-- Description: AI-powered dermatology diagnosis system
-- =============================================

-- Create database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SkinAI')
BEGIN
    CREATE DATABASE SkinAI;
END
GO

USE SkinAI;
GO

-- =============================================
-- Table: users
-- Manages login accounts (Google OAuth, admin, patient)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        google_id           NVARCHAR(255)       NULL,
        email               NVARCHAR(255)       NOT NULL,
        full_name           NVARCHAR(255)       NULL,
        avatar_url          NVARCHAR(500)       NULL,
        role                NVARCHAR(20)        NOT NULL DEFAULT 'PATIENT',
        status              NVARCHAR(20)        NOT NULL DEFAULT 'ACTIVE',
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),
        updated_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_users PRIMARY KEY (id),
        CONSTRAINT UQ_users_google_id UNIQUE (google_id),
        CONSTRAINT UQ_users_email UNIQUE (email),
        CONSTRAINT CK_users_role CHECK (role IN ('PATIENT', 'ADMIN')),
        CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED'))
    );
END
GO

-- =============================================
-- Table: patients
-- Patient profile linked 1-1 with users
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'patients')
BEGIN
    CREATE TABLE patients (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        user_id             UNIQUEIDENTIFIER    NULL,
        phone               NVARCHAR(20)        NOT NULL,
        gender              NVARCHAR(10)        NULL,
        dob                 DATE                NULL,
        address             NVARCHAR(500)       NULL,
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),
        updated_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_patients PRIMARY KEY (id),
        CONSTRAINT FK_patients_user FOREIGN KEY (user_id) REFERENCES users(id),
        CONSTRAINT UQ_patients_user_id UNIQUE (user_id),
        CONSTRAINT UQ_patients_phone UNIQUE (phone),
        CONSTRAINT CK_patients_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER'))
    );
END
GO

-- =============================================
-- Table: diseases
-- Disease catalog that AI can identify
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'diseases')
BEGIN
    CREATE TABLE diseases (
        id                      UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        disease_name            NVARCHAR(255)       NOT NULL,
        disease_code            NVARCHAR(50)        NULL,
        description             NVARCHAR(MAX)       NULL,
        symptoms                NVARCHAR(MAX)       NULL,
        severity_level          NVARCHAR(10)        NOT NULL DEFAULT 'LOW',
        recommended_specialty   NVARCHAR(255)       NULL,
        created_at              DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_diseases PRIMARY KEY (id),
        CONSTRAINT UQ_diseases_name UNIQUE (disease_name),
        CONSTRAINT CK_diseases_severity CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH'))
    );
END
GO

-- =============================================
-- Table: clinics
-- Dermatology clinics for patient referral
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'clinics')
BEGIN
    CREATE TABLE clinics (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        google_place_id     NVARCHAR(255)       NULL,
        clinic_name         NVARCHAR(255)       NOT NULL,
        address             NVARCHAR(500)       NULL,
        phone               NVARCHAR(20)        NULL,
        website             NVARCHAR(500)       NULL,
        latitude            FLOAT               NULL,
        longitude           FLOAT               NULL,
        specialty           NVARCHAR(255)       NULL,
        rating              FLOAT               NULL DEFAULT 0,
        is_active           BIT                 NOT NULL DEFAULT 1,
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),
        updated_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_clinics PRIMARY KEY (id)
    );
END
GO

-- =============================================
-- Table: diagnosis_reports
-- AI diagnosis results from uploaded skin images
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'diagnosis_reports')
BEGIN
    CREATE TABLE diagnosis_reports (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        patient_id          UNIQUEIDENTIFIER    NOT NULL,
        disease_id          UNIQUEIDENTIFIER    NULL,
        clinic_id           UNIQUEIDENTIFIER    NULL,
        image_url           NVARCHAR(500)       NOT NULL,
        heatmap_url         NVARCHAR(500)       NULL,
        confidence_score    FLOAT               NULL DEFAULT 0,
        risk_level          NVARCHAR(10)        NULL DEFAULT 'LOW',
        recommendation      NVARCHAR(MAX)       NULL,
        model_version       NVARCHAR(50)        NULL,
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_diagnosis_reports PRIMARY KEY (id),
        CONSTRAINT FK_diagnosis_reports_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
        CONSTRAINT FK_diagnosis_reports_disease FOREIGN KEY (disease_id) REFERENCES diseases(id),
        CONSTRAINT FK_diagnosis_reports_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
        CONSTRAINT CK_diagnosis_reports_risk CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
    );
END
GO

-- =============================================
-- Table: appointments
-- Patient appointment bookings with clinics
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'appointments')
BEGIN
    CREATE TABLE appointments (
        id                      UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        patient_id              UNIQUEIDENTIFIER    NOT NULL,
        clinic_id               UNIQUEIDENTIFIER    NOT NULL,
        diagnosis_report_id     UNIQUEIDENTIFIER    NULL,
        appointment_time        DATETIME2           NOT NULL,
        status                  NVARCHAR(20)        NOT NULL DEFAULT 'CREATED',
        notes                   NVARCHAR(MAX)       NULL,
        created_at              DATETIME2           NOT NULL DEFAULT GETDATE(),
        updated_at              DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_appointments PRIMARY KEY (id),
        CONSTRAINT FK_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
        CONSTRAINT FK_appointments_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(id),
        CONSTRAINT FK_appointments_report FOREIGN KEY (diagnosis_report_id) REFERENCES diagnosis_reports(id),
        CONSTRAINT CK_appointments_status CHECK (status IN ('CREATED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED', 'NO_SHOW'))
    );
END
GO

-- =============================================
-- Table: articles
-- Health blog articles managed by admin
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'articles')
BEGIN
    CREATE TABLE articles (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        title               NVARCHAR(500)       NOT NULL,
        slug                NVARCHAR(500)       NOT NULL,
        thumbnail_url       NVARCHAR(500)       NULL,
        content             NVARCHAR(MAX)       NULL,
        author_user_id      UNIQUEIDENTIFIER    NULL,
        status              NVARCHAR(20)        NOT NULL DEFAULT 'DRAFT',
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),
        updated_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_articles PRIMARY KEY (id),
        CONSTRAINT UQ_articles_slug UNIQUE (slug),
        CONSTRAINT FK_articles_author FOREIGN KEY (author_user_id) REFERENCES users(id),
        CONSTRAINT CK_articles_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED'))
    );
END
GO

-- =============================================
-- Table: audit_logs
-- System audit trail for security and debugging
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'audit_logs')
BEGIN
    CREATE TABLE audit_logs (
        id                  UNIQUEIDENTIFIER    NOT NULL DEFAULT NEWID(),
        user_id             UNIQUEIDENTIFIER    NULL,
        action              NVARCHAR(100)       NOT NULL,
        entity_type         NVARCHAR(100)       NULL,
        record_id           NVARCHAR(255)       NULL,
        old_values          NVARCHAR(MAX)       NULL,
        new_values          NVARCHAR(MAX)       NULL,
        ip_address          NVARCHAR(45)        NULL,
        user_agent          NVARCHAR(500)       NULL,
        created_at          DATETIME2           NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_audit_logs PRIMARY KEY (id),
        CONSTRAINT FK_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id)
    );
END
GO

-- =============================================
-- Indexes for performance
-- =============================================
CREATE INDEX IX_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX IX_users_email ON users(email);
CREATE INDEX IX_users_role ON users(role);
CREATE INDEX IX_patients_user_id ON patients(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IX_diseases_code ON diseases(disease_code) WHERE disease_code IS NOT NULL;
CREATE INDEX IX_diagnosis_reports_patient ON diagnosis_reports(patient_id);
CREATE INDEX IX_diagnosis_reports_created ON diagnosis_reports(created_at DESC);
CREATE INDEX IX_appointments_patient ON appointments(patient_id);
CREATE INDEX IX_appointments_status ON appointments(status);
CREATE INDEX IX_articles_slug ON articles(slug);
CREATE INDEX IX_articles_status ON articles(status);
CREATE INDEX IX_articles_created ON articles(created_at DESC);
CREATE INDEX IX_audit_logs_user ON audit_logs(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IX_audit_logs_entity ON audit_logs(entity_type, record_id);
CREATE INDEX IX_audit_logs_created ON audit_logs(created_at DESC);
GO

-- =============================================
-- Seed data: Default admin account
-- =============================================
INSERT INTO users (id, email, full_name, role, status)
VALUES (NEWID(), 'admin@skinai.com', 'System Administrator', 'ADMIN', 'ACTIVE');
GO

-- =============================================
-- Seed data: Sample diseases
-- =============================================
INSERT INTO diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty) VALUES
(NEWID(), N'Acne Vulgaris', 'ACNE', N'A common skin condition that occurs when hair follicles become plugged with oil and dead skin cells.', N'Whiteheads, blackheads, pimples, oily skin, scarring', 'LOW', N'Dermatology'),
(NEWID(), N'Eczema (Atopic Dermatitis)', 'ECZEMA', N'A condition that causes dry, itchy and inflamed skin. It is common in young children but can occur at any age.', N'Dry skin, itching, red to brownish-gray patches, small raised bumps', 'MEDIUM', N'Dermatology'),
(NEWID(), N'Psoriasis', 'PSORIASIS', N'A chronic autoimmune condition that causes the rapid buildup of skin cells, resulting in scaling on the surface.', N'Red patches with thick silvery scales, dry cracked skin, itching, burning', 'MEDIUM', N'Dermatology'),
(NEWID(), N'Melanoma', 'MELANOMA', N'The most serious type of skin cancer, develops in the cells that give your skin its color.', N'Unusual mole, change in existing mole, asymmetrical shape, irregular border', 'HIGH', N'Oncology - Dermatology'),
(NEWID(), N'Fungal Infection (Tinea)', 'TINEA', N'Common fungal infections of the skin caused by dermatophytes.', N'Ring-shaped rash, itching, red scaly patches, cracking skin', 'LOW', N'Dermatology'),
(NEWID(), N'Vitiligo', 'VITILIGO', N'A disease that causes loss of skin color in patches. The extent and rate of color loss is unpredictable.', N'Patchy loss of skin color, premature whitening of hair, loss of color in mucous membranes', 'LOW', N'Dermatology'),
(NEWID(), N'Rosacea', 'ROSACEA', N'A common skin condition that causes blushing or flushing and visible blood vessels in your face.', N'Facial blushing, visible veins, swollen bumps, eye problems, enlarged nose', 'MEDIUM', N'Dermatology');
GO

PRINT 'SkinAI database schema created successfully.';
GO
