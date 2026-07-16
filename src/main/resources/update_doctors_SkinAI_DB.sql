SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. Modify users check constraint
ALTER TABLE users DROP CONSTRAINT IF EXISTS CHK_users_role;
ALTER TABLE users ADD CONSTRAINT CHK_users_role CHECK (role IN ('USER', 'PATIENT', 'ADMIN', 'DOCTOR'));
GO

-- 2. Create doctors table
IF OBJECT_ID('doctors', 'U') IS NULL
BEGIN
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
END
GO

-- 3. Create doctor_schedules table
IF OBJECT_ID('doctor_schedules', 'U') IS NULL
BEGIN
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
END
GO

-- 4. Add columns to appointments table
IF COL_LENGTH('appointments', 'doctor_id') IS NULL
BEGIN
    ALTER TABLE appointments ADD doctor_id UNIQUEIDENTIFIER NULL;
END
IF COL_LENGTH('appointments', 'doctor_status') IS NULL
BEGIN
    ALTER TABLE appointments ADD doctor_status VARCHAR(20) NOT NULL DEFAULT 'PENDING';
END
IF COL_LENGTH('appointments', 'doctor_notes') IS NULL
BEGIN
    ALTER TABLE appointments ADD doctor_notes NVARCHAR(2000) NULL;
END
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_appointments_doctors')
BEGIN
    ALTER TABLE appointments ADD CONSTRAINT FK_appointments_doctors FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE NO ACTION;
END
GO

-- 5. Create appointment_lab_tests table
IF OBJECT_ID('appointment_lab_tests', 'U') IS NULL
BEGIN
    CREATE TABLE appointment_lab_tests (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        appointment_id UNIQUEIDENTIFIER NOT NULL,
        test_name NVARCHAR(150) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        result_summary NVARCHAR(1000) NULL,
        result_image_url VARCHAR(255) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT PK_appointment_lab_tests PRIMARY KEY (id),
        CONSTRAINT CHK_appointment_lab_tests_status CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELLED')),
        CONSTRAINT FK_appointment_lab_tests_appointments FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
    );
END
GO

-- 6. Insert seed users for doctors
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'bs.nguyenvana')
BEGIN
    DECLARE @Doctor1UserId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Doctor2UserId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Doctor3UserId UNIQUEIDENTIFIER = NEWID();

    DECLARE @Doctor1Id UNIQUEIDENTIFIER = NEWID();
    DECLARE @Doctor2Id UNIQUEIDENTIFIER = NEWID();
    DECLARE @Doctor3Id UNIQUEIDENTIFIER = NEWID();

    -- Lấy ID của các clinic hiện có trong SkinAI_DB
    DECLARE @Clinic1Id UNIQUEIDENTIFIER = (SELECT TOP 1 id FROM clinics ORDER BY created_at);
    DECLARE @Clinic2Id UNIQUEIDENTIFIER = (SELECT TOP 1 id FROM clinics WHERE id NOT IN (SELECT TOP 1 id FROM clinics ORDER BY created_at) ORDER BY created_at);

    IF @Clinic1Id IS NULL
    BEGIN
        SET @Clinic1Id = NEWID();
        INSERT INTO clinics (id, clinic_name, address, phone, is_active)
        VALUES (@Clinic1Id, N'Phòng khám Da liễu Trung Ương', N'15A Phương Mai, Đống Đa, Hà Nội', '0241111222', 1);
    END

    IF @Clinic2Id IS NULL
    BEGIN
        SET @Clinic2Id = NEWID();
        INSERT INTO clinics (id, clinic_name, address, phone, is_active)
        VALUES (@Clinic2Id, N'O2 Skin Clinic', N'343/5F Tô Hiến Thành, Quận 10, TP.HCM', '0283333444', 1);
    END

    INSERT INTO users (id, google_id, username, email, phone, full_name, password_hash, role, status, last_login_at)
    VALUES
    (@Doctor1UserId, NULL, 'bs.nguyenvana', 'nguyenvana@skinai.com', '0911222333', N'BS. Nguyễn Văn A', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME()),
    (@Doctor2UserId, NULL, 'bs.tranthib', 'tranthib@skinai.com', '0922333444', N'BS. Trần Thị B', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME()),
    (@Doctor3UserId, NULL, 'bs.levanc', 'levanc@skinai.com', '0933444555', N'BS. Lê Văn C', '$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK', 'DOCTOR', 'ACTIVE', SYSDATETIME());

    -- Insert Doctors
    INSERT INTO doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active)
    VALUES
    (@Doctor1Id, @Doctor1UserId, @Clinic1Id, N'Da liễu tổng quát', '12345/BYT-CCHN', N'Bác sĩ chuyên khoa I Da liễu với hơn 10 năm kinh nghiệm tại Bệnh viện Da liễu Trung Ương.', 1),
    (@Doctor2Id, @Doctor2UserId, @Clinic2Id, N'Trị mụn & Thẩm mỹ', '67890/BYT-CCHN', N'Chuyên gia điều trị các loại mụn trứng cá nặng, sẹo rỗ và trẻ hóa da thẩm mỹ.', 1),
    (@Doctor3Id, @Doctor3UserId, @Clinic1Id, N'Ung thư da & Phẫu thuật', '11223/BYT-CCHN', N'Phó trưởng khoa Phẫu thuật thẩm mỹ, chuyên môn sâu về ung thư hắc tố da.', 1);

    -- Insert Doctor Schedules
    INSERT INTO doctor_schedules (id, doctor_id, schedule_date, slot, is_available, max_patients, booked_count)
    VALUES
    (NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'MORNING', 1, 10, 1),
    (NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'AFTERNOON', 1, 10, 0),
    (NEWID(), @Doctor1Id, CAST(GETDATE() AS DATE), 'EVENING', 1, 5, 0),
    (NEWID(), @Doctor2Id, CAST(GETDATE() AS DATE), 'AFTERNOON', 1, 8, 1);
END
GO
