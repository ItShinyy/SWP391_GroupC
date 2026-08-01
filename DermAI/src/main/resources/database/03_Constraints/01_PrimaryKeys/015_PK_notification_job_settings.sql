/*
Purpose: PK notification job settings.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[notification_job_settings] ADD CONSTRAINT [PK_notification_job_settings] PRIMARY KEY CLUSTERED 
(
	[job_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

