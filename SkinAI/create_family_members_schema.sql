/* Run once on the current SWP391 database. This is a migration; schema.sql is unchanged. */
IF OBJECT_ID(N'dbo.family_members', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.family_members (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        owner_user_id UNIQUEIDENTIFIER NOT NULL,
        full_name NVARCHAR(100) NOT NULL,
        date_of_birth DATE NOT NULL,
        gender VARCHAR(10) NOT NULL,
        relationship VARCHAR(20) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        email VARCHAR(100) NULL,
        province NVARCHAR(100) NOT NULL,
        ward NVARCHAR(100) NOT NULL,
        address_detail NVARCHAR(255) NOT NULL,
        country NVARCHAR(100) NOT NULL,
        ethnicity NVARCHAR(100) NOT NULL,
        occupation NVARCHAR(100) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT PK_family_members PRIMARY KEY (id),
        CONSTRAINT FK_family_members_owner FOREIGN KEY (owner_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CHK_family_members_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
        CONSTRAINT CHK_family_members_relationship CHECK (relationship IN ('FATHER', 'MOTHER', 'SPOUSE', 'CHILD', 'OLDER_BROTHER', 'OLDER_SISTER', 'YOUNGER_BROTHER', 'YOUNGER_SISTER', 'GRANDPARENT', 'OTHER'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_family_members_owner_created' AND object_id = OBJECT_ID(N'dbo.family_members'))
    CREATE INDEX IX_family_members_owner_created ON dbo.family_members(owner_user_id, created_at DESC);
GO
