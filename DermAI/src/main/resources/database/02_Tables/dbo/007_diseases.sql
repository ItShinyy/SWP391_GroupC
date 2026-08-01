/*
Purpose: diseases.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[diseases](
	[id] [uniqueidentifier] NOT NULL,
	[disease_name] [nvarchar](150) NOT NULL,
	[disease_code] [varchar](50) NULL,
	[description] [nvarchar](2000) NULL,
	[symptoms] [nvarchar](2000) NULL,
	[severity_level] [varchar](20) NULL,
	[recommended_specialty] [nvarchar](100) NULL,
	[created_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

