/*
Purpose: notification job settings.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notification_job_settings](
	[job_name] [varchar](100) NOT NULL,
	[enabled_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

