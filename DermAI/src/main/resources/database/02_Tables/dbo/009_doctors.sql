/*
Purpose: doctors.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doctors](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[clinic_id] [uniqueidentifier] NULL,
	[specialization] [nvarchar](255) NULL,
	[license_number] [varchar](100) NULL,
	[bio] [nvarchar](2000) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
