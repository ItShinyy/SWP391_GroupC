/* SkinAI - Patient feedback module. Run once on the active SWP391 database. */

IF OBJECT_ID(N'dbo.feedbacks', N'U') IS NOT NULL
   AND (
       COL_LENGTH(N'dbo.feedbacks', N'category') IS NULL
       OR COL_LENGTH(N'dbo.feedbacks', N'content') IS NULL
       OR COL_LENGTH(N'dbo.feedbacks', N'admin_reply') IS NULL
       OR COL_LENGTH(N'dbo.feedbacks', N'replied_at') IS NULL
   )
BEGIN
    THROW 50001, 'The existing feedbacks table uses an incompatible schema. Back it up and remove it before running feedback.sql.', 1;
END;
GO

IF OBJECT_ID(N'dbo.feedbacks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.feedbacks (
        id UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_feedbacks PRIMARY KEY
            DEFAULT NEWSEQUENTIALID(),
        appointment_id UNIQUEIDENTIFIER NOT NULL,
        patient_id UNIQUEIDENTIFIER NOT NULL,
        rating INT NOT NULL,
        category NVARCHAR(30) NOT NULL,
        content NVARCHAR(1000) NOT NULL,
        status NVARCHAR(20) NOT NULL
            CONSTRAINT DF_feedbacks_status DEFAULT N'Chưa xử lý',
        admin_reply NVARCHAR(1000) NULL,
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_feedbacks_created_at DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL
            CONSTRAINT DF_feedbacks_updated_at DEFAULT SYSDATETIME(),
        replied_at DATETIME2 NULL,

        CONSTRAINT UQ_feedbacks_appointment UNIQUE (appointment_id),
        CONSTRAINT FK_feedbacks_appointment
            FOREIGN KEY (appointment_id) REFERENCES dbo.appointments(id),
        CONSTRAINT FK_feedbacks_patient
            FOREIGN KEY (patient_id) REFERENCES dbo.patients(id),
        CONSTRAINT CHK_feedbacks_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT CHK_feedbacks_category
            CHECK (category IN (N'Khen', N'Góp ý', N'Khiếu nại')),
        CONSTRAINT CHK_feedbacks_status
            CHECK (status IN (N'Chưa xử lý', N'Đang xử lý', N'Đã xử lý'))
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_feedbacks_patient_created'
      AND object_id = OBJECT_ID(N'dbo.feedbacks')
)
BEGIN
    CREATE INDEX IX_feedbacks_patient_created
        ON dbo.feedbacks(patient_id, created_at DESC);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_feedbacks_status_created'
      AND object_id = OBJECT_ID(N'dbo.feedbacks')
)
BEGIN
    CREATE INDEX IX_feedbacks_status_created
        ON dbo.feedbacks(status, created_at DESC);
END;
GO
