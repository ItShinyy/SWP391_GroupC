/*
Purpose: notifications.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notifications](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[event_key] [varchar](180) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[message] [nvarchar](1000) NOT NULL,
	[target_url] [nvarchar](500) NULL,
	[is_read] [bit] NOT NULL,
	[email_status] [varchar](20) NOT NULL,
	[email_attempts] [int] NOT NULL,
	[next_attempt_at] [datetime2](7) NULL,
	[email_sent_at] [datetime2](7) NULL,
	[last_error] [nvarchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

