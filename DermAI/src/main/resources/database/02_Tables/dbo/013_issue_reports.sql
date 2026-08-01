/*
Purpose: issue reports.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[issue_reports](
	[id] [uniqueidentifier] NOT NULL,
	[report_code] [varchar](20) NOT NULL,
	[reporter_user_id] [uniqueidentifier] NOT NULL,
	[title] [nvarchar](150) NOT NULL,
	[category] [varchar](20) NOT NULL,
	[description] [nvarchar](2000) NOT NULL,
	[image_url] [nvarchar](1000) NULL,
	[status] [varchar](20) NOT NULL,
	[admin_response] [nvarchar](2000) NULL,
	[handled_by_admin_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[resolved_at] [datetime2](7) NULL
) ON [PRIMARY]
GO
