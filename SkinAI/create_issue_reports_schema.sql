/* Run once on the existing SWP391 database before using /patient/issue-report. */
IF OBJECT_ID(N'dbo.issue_reports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.issue_reports (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        report_code VARCHAR(20) NOT NULL,
        reporter_user_id UNIQUEIDENTIFIER NOT NULL,
        title NVARCHAR(150) NOT NULL,
        category VARCHAR(20) NOT NULL,
        description NVARCHAR(2000) NOT NULL,
        image_url NVARCHAR(500) NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        admin_response NVARCHAR(2000) NULL,
        handled_by_admin_id UNIQUEIDENTIFIER NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        resolved_at DATETIME2 NULL,

        CONSTRAINT PK_issue_reports PRIMARY KEY (id),
        CONSTRAINT UQ_issue_reports_code UNIQUE (report_code),
        CONSTRAINT FK_issue_reports_reporter FOREIGN KEY (reporter_user_id) REFERENCES dbo.users(id),
        CONSTRAINT FK_issue_reports_admin FOREIGN KEY (handled_by_admin_id) REFERENCES dbo.users(id),
        CONSTRAINT CHK_issue_reports_category CHECK (category IN ('APPOINTMENT', 'PAYMENT', 'ACCOUNT', 'SYSTEM', 'OTHER')),
        CONSTRAINT CHK_issue_reports_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_issue_reports_status_created' AND object_id = OBJECT_ID(N'dbo.issue_reports'))
    CREATE INDEX IX_issue_reports_status_created ON dbo.issue_reports(status, created_at DESC);
GO
