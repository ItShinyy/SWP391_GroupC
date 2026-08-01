/*
Purpose: family members.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[family_members](
	[id] [uniqueidentifier] NOT NULL,
	[owner_user_id] [uniqueidentifier] NOT NULL,
	[full_name] [nvarchar](100) NOT NULL,
	[date_of_birth] [date] NOT NULL,
	[gender] [varchar](10) NOT NULL,
	[relationship] [varchar](20) NOT NULL,
	[phone] [varchar](20) NOT NULL,
	[email] [varchar](100) NULL,
	[province] [nvarchar](100) NOT NULL,
	[ward] [nvarchar](100) NOT NULL,
	[address_detail] [nvarchar](255) NOT NULL,
	[country] [nvarchar](100) NOT NULL,
	[ethnicity] [nvarchar](100) NOT NULL,
	[occupation] [nvarchar](100) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

