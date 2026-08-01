/*
Purpose: diagnosis reports.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[diagnosis_reports](
	[id] [uniqueidentifier] NOT NULL,
	[patient_id] [uniqueidentifier] NOT NULL,
	[disease_id] [uniqueidentifier] NULL,
	[clinic_id] [uniqueidentifier] NULL,
	[image_url] [varchar](255) NULL,
	[heatmap_url] [varchar](255) NULL,
	[confidence_score] [decimal](5, 2) NULL,
	[risk_level] [varchar](20) NULL,
	[recommendation] [nvarchar](2000) NULL,
	[model_version] [varchar](50) NULL,
	[created_at] [datetime2](7) NOT NULL
	,[ai_screening_attempt_id] [uniqueidentifier] NULL
	,[input_image_object_key] [varchar](512) NULL
	,[eigencam_object_key] [varchar](512) NULL
	,[ai_suggested_disease_id] [uniqueidentifier] NULL
	,[doctor_review_status] [varchar](30) NOT NULL
	,[reviewed_by_doctor_id] [uniqueidentifier] NULL
	,[reviewed_at] [datetime2](7) NULL
	,[doctor_selected_disease_id] [uniqueidentifier] NULL
	,[override_reason] [nvarchar](1000) NULL
	,[doctor_note] [nvarchar](2000) NULL
	,[patient_guidance] [nvarchar](2000) NULL
	,[patient_visibility_status] [varchar](30) NOT NULL
) ON [PRIMARY]
GO
