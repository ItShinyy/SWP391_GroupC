/*
Purpose: medical reports.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[medical_reports](
	[id] [uniqueidentifier] NOT NULL,
	[appointment_id] [uniqueidentifier] NOT NULL,
	[doctor_id] [uniqueidentifier] NOT NULL,
	[diagnosis_report_id] [uniqueidentifier] NULL,
	[chief_complaint] [nvarchar](1000) NOT NULL,
	[doctor_diagnosis] [nvarchar](2000) NOT NULL,
	[treatment_plan] [nvarchar](2000) NOT NULL,
	[prescription_note] [nvarchar](2000) NULL,
	[follow_up_date] [date] NULL,
	[status] [varchar](20) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

