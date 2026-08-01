/*
Purpose: audit logs.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[audit_logs](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[action] [varchar](100) NOT NULL,
	[entity_type] [varchar](50) NULL,
	[record_id] [uniqueidentifier] NULL,
	[old_values] [nvarchar](max) NULL,
	[new_values] [nvarchar](max) NULL,
	[ip_address] [varchar](45) NULL,
	[user_agent] [nvarchar](500) NULL,
	[status] [varchar](20) NOT NULL,
	[error_message] [nvarchar](1000) NULL,
	[created_at] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

