/*
Purpose: appointments.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[appointments](
	[id] [uniqueidentifier] NOT NULL,
	[request_id] [varchar](100) NOT NULL,
	[patient_id] [uniqueidentifier] NOT NULL,
	[clinic_id] [uniqueidentifier] NOT NULL,
	[diagnosis_report_id] [uniqueidentifier] NULL,
	[appointment_time] [datetime2](7) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[notes] [nvarchar](1000) NULL,
	[patient_name] [nvarchar](100) NULL,
	[patient_dob] [date] NULL,
	[patient_gender] [varchar](10) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[doctor_id] [uniqueidentifier] NULL,
	[slot_id] [uniqueidentifier] NULL,
	[doctor_status] [varchar](20) NOT NULL,
	[doctor_notes] [nvarchar](2000) NULL,
	[attendance_status] [varchar](20) NOT NULL,
	[family_member_id] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
