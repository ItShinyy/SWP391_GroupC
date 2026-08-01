/*
Purpose: appointment prescriptions.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[appointment_prescriptions](
	[id] [uniqueidentifier] NOT NULL,
	[appointment_id] [uniqueidentifier] NOT NULL,
	[drug_name] [nvarchar](255) NOT NULL,
	[quantity] [int] NOT NULL,
	[dosage] [nvarchar](500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL
) ON [PRIMARY]
GO
