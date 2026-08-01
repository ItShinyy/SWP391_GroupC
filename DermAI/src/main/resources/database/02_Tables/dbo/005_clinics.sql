/*
Purpose: clinics.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clinics](
	[id] [uniqueidentifier] NOT NULL,
	[google_place_id] [varchar](100) NULL,
	[clinic_name] [nvarchar](150) NOT NULL,
	[address] [nvarchar](500) NOT NULL,
	[phone] [varchar](20) NULL,
	[latitude] [decimal](9, 6) NULL,
	[longitude] [decimal](9, 6) NULL,
	[specialty] [nvarchar](100) NULL,
	[rating] [decimal](2, 1) NULL,
	[website] [varchar](255) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[facility_type] [varchar](20) NOT NULL,
	[province] [nvarchar](100) NULL
) ON [PRIMARY]
GO
