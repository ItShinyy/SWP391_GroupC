/* Run once after family_members has been created. schema.sql is intentionally unchanged. */
IF COL_LENGTH(N'dbo.appointments', N'family_member_id') IS NULL
BEGIN
    ALTER TABLE dbo.appointments ADD family_member_id UNIQUEIDENTIFIER NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_appointments_family_member')
BEGIN
    ALTER TABLE dbo.appointments ADD CONSTRAINT FK_appointments_family_member
        FOREIGN KEY (family_member_id) REFERENCES dbo.family_members(id);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_appointments_family_member_status' AND object_id = OBJECT_ID(N'dbo.appointments'))
    CREATE INDEX IX_appointments_family_member_status ON dbo.appointments(family_member_id, status, appointment_time DESC);
GO
