/*
Purpose: feedbacks.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[feedbacks](
	[id] [uniqueidentifier] NOT NULL,
	[patient_id] [uniqueidentifier] NOT NULL,
	[appointment_id] [uniqueidentifier] NULL,
	[rating] [int] NOT NULL,
	[category] [nvarchar](20) NOT NULL,
	[content] [nvarchar](max) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[admin_reply] [nvarchar](max) NULL,
	[replied_at] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

