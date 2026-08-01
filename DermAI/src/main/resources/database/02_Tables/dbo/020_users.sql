/*
Purpose: users.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [uniqueidentifier] NOT NULL,
	[google_id] [varchar](100) NULL,
	[email] [varchar](100) NULL,
	[pending_email] [varchar](100) NULL,
	[phone] [varchar](20) NULL,
	[username] [varchar](100) NOT NULL,
	[avatar] [varchar](255) NULL,
	[full_name] [nvarchar](100) NOT NULL,
	[password_hash] [varchar](255) NULL,
	[role] [varchar](20) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[failed_login_attempts] [int] NOT NULL,
	[last_failed_login_at] [datetime2](7) NULL,
	[lock_type] [varchar](20) NULL,
	[lock_reason] [nvarchar](500) NULL,
	[locked_at] [datetime2](7) NULL,
	[locked_by] [uniqueidentifier] NULL,
	[password_changed_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[last_login_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
