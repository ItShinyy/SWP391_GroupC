SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ai_screening_attempts](
    [id] [uniqueidentifier] NOT NULL,
    [idempotency_key] [varchar](100) NOT NULL,
    [patient_id] [uniqueidentifier] NOT NULL,
    [requested_by_user_id] [uniqueidentifier] NOT NULL,
    [status] [varchar](20) NOT NULL,
    [processing_started_at] [datetime2](7) NULL,
    [heartbeat_at] [datetime2](7) NULL,
    [completed_at] [datetime2](7) NULL,
    [failure_code] [varchar](100) NULL,
    [retry_count] [int] NOT NULL,
    [ai_model_id] [uniqueidentifier] NOT NULL,
    [input_sha256] [char](64) NULL,
    [input_image_object_key] [varchar](512) NULL,
    [diagnosis_report_id] [uniqueidentifier] NULL,
    [created_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
