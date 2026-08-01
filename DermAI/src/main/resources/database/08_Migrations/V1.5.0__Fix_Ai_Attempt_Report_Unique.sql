/*
Fix: SQL Server UNIQUE on diagnosis_report_id only allows one NULL, which blocks
every screening attempt after the first. Replace with a filtered unique index.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID(N'dbo.ai_screening_attempts')
      AND name = N'UQ_ai_attempt_report'
)
BEGIN
    ALTER TABLE [dbo].[ai_screening_attempts] DROP CONSTRAINT [UQ_ai_attempt_report];
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.ai_screening_attempts')
      AND name = N'UQ_ai_attempt_report'
)
BEGIN
    DROP INDEX [UQ_ai_attempt_report] ON [dbo].[ai_screening_attempts];
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.ai_screening_attempts')
      AND name = N'UQ_ai_attempt_report'
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_ai_attempt_report]
    ON [dbo].[ai_screening_attempts]([diagnosis_report_id])
    WHERE [diagnosis_report_id] IS NOT NULL;
END
GO
