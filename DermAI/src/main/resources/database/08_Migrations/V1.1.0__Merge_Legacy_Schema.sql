/*
Purpose: Upgrade a deployed v1.0 structured baseline with schema.sql compatibility.
Precondition: Back up the database and validate application DAO expectations.
This migration is for an existing v1.0 database. Fresh deployments use Master_Deploy.sql.
*/

IF COL_LENGTH(N'dbo.users', N'avatar') IS NULL
    ALTER TABLE [dbo].[users] ADD [avatar] VARCHAR(255) NULL;
IF COL_LENGTH(N'dbo.users', N'failed_login_attempts') IS NULL
    ALTER TABLE [dbo].[users] ADD [failed_login_attempts] INT NOT NULL CONSTRAINT [DF_users_failed_login_attempts] DEFAULT ((0)) WITH VALUES;
IF COL_LENGTH(N'dbo.users', N'last_failed_login_at') IS NULL
    ALTER TABLE [dbo].[users] ADD [last_failed_login_at] DATETIME2(7) NULL;
IF COL_LENGTH(N'dbo.users', N'lock_type') IS NULL
    ALTER TABLE [dbo].[users] ADD [lock_type] VARCHAR(20) NULL;
IF COL_LENGTH(N'dbo.users', N'password_changed_at') IS NULL
    ALTER TABLE [dbo].[users] ADD [password_changed_at] DATETIME2(7) NULL;
GO

IF COL_LENGTH(N'dbo.clinics', N'google_place_id') IS NULL
    ALTER TABLE [dbo].[clinics] ADD [google_place_id] VARCHAR(100) NULL;
IF COL_LENGTH(N'dbo.clinics', N'rating') IS NULL
    ALTER TABLE [dbo].[clinics] ADD [rating] DECIMAL(2, 1) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_clinics_facility_type')
    ALTER TABLE [dbo].[clinics] ADD CONSTRAINT [DF_clinics_facility_type] DEFAULT ('CLINIC') FOR [facility_type];
GO

IF COL_LENGTH(N'dbo.appointments', N'patient_name') IS NULL
    ALTER TABLE [dbo].[appointments] ADD [patient_name] NVARCHAR(100) NULL;
IF COL_LENGTH(N'dbo.appointments', N'patient_dob') IS NULL
    ALTER TABLE [dbo].[appointments] ADD [patient_dob] DATE NULL;
IF COL_LENGTH(N'dbo.appointments', N'patient_gender') IS NULL
    ALTER TABLE [dbo].[appointments] ADD [patient_gender] VARCHAR(10) NULL;
GO

ALTER TABLE [dbo].[appointment_prescriptions] ALTER COLUMN [drug_name] NVARCHAR(255) NOT NULL;
ALTER TABLE [dbo].[appointment_prescriptions] ALTER COLUMN [dosage] NVARCHAR(500) NULL;
ALTER TABLE [dbo].[appointment_prescriptions] ALTER COLUMN [updated_at] DATETIME2(7) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_appointment_prescriptions_quantity')
    ALTER TABLE [dbo].[appointment_prescriptions] ADD CONSTRAINT [DF_appointment_prescriptions_quantity] DEFAULT ((1)) FOR [quantity];
ALTER TABLE [dbo].[doctors] ALTER COLUMN [clinic_id] UNIQUEIDENTIFIER NULL;
ALTER TABLE [dbo].[doctors] ALTER COLUMN [specialization] NVARCHAR(255) NULL;
ALTER TABLE [dbo].[doctors] ALTER COLUMN [license_number] VARCHAR(100) NULL;
GO

IF OBJECT_ID(N'dbo.appointment_lab_tests', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[appointment_lab_tests]
    (
        [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_appointment_lab_tests_id] DEFAULT NEWSEQUENTIALID(),
        [appointment_id] UNIQUEIDENTIFIER NOT NULL,
        [test_type] NVARCHAR(255) NULL,
        [result_file_url] VARCHAR(1000) NULL,
        [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_appointment_lab_tests_created_at] DEFAULT SYSDATETIME(),
        CONSTRAINT [PK_appointment_lab_tests] PRIMARY KEY CLUSTERED ([id]),
        CONSTRAINT [FK_appointment_lab_tests_appointments] FOREIGN KEY ([appointment_id]) REFERENCES [dbo].[appointments] ([id]) ON DELETE CASCADE
    );
END;

IF OBJECT_ID(N'dbo.user_tokens', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[user_tokens]
    (
        [id] INT IDENTITY(1, 1) NOT NULL,
        [user_id] UNIQUEIDENTIFIER NOT NULL,
        [token] VARCHAR(100) NOT NULL,
        [purpose] VARCHAR(50) NOT NULL CONSTRAINT [DF_user_tokens_purpose] DEFAULT ('RESET_PASSWORD'),
        [attempts] INT NOT NULL CONSTRAINT [DF_user_tokens_attempts] DEFAULT ((0)),
        [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_user_tokens_created_at] DEFAULT SYSDATETIME(),
        [used_at] DATETIME2(7) NULL,
        [expires_at] DATETIME2(7) NOT NULL,
        CONSTRAINT [PK_user_tokens] PRIMARY KEY CLUSTERED ([id]),
        CONSTRAINT [UQ_user_tokens_token] UNIQUE ([token]),
        CONSTRAINT [CK_user_tokens_attempts] CHECK ([attempts] >= 0),
        CONSTRAINT [CK_user_tokens_purpose] CHECK ([purpose] IN ('RESET_PASSWORD', 'UNLOCK_ACCOUNT', 'VERIFY_EMAIL', 'EMAIL_CHANGE_OLD', 'EMAIL_CHANGE_NEW')),
        CONSTRAINT [FK_user_tokens_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'UX_clinics_google_place_id')
    CREATE UNIQUE NONCLUSTERED INDEX [UX_clinics_google_place_id] ON [dbo].[clinics] ([google_place_id]) WHERE [google_place_id] IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.user_tokens') AND name = N'IX_user_tokens_user_id')
    CREATE NONCLUSTERED INDEX [IX_user_tokens_user_id] ON [dbo].[user_tokens] ([user_id]);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.user_tokens') AND name = N'IX_user_tokens_token_expires_at')
    CREATE NONCLUSTERED INDEX [IX_user_tokens_token_expires_at] ON [dbo].[user_tokens] ([token], [expires_at]);
GO

IF OBJECT_ID(N'dbo.appointment_lab_tests', N'U') IS NULL
   OR OBJECT_ID(N'dbo.user_tokens', N'U') IS NULL
    THROW 50002, 'Legacy schema merge validation failed.', 1;
GO
