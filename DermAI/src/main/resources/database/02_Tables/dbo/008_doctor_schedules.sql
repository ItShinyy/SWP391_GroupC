/*
Purpose: doctor schedules.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doctor_schedules](
	[id] [uniqueidentifier] NOT NULL,
	[doctor_id] [uniqueidentifier] NOT NULL,
	[schedule_date] [date] NOT NULL,
	[slot] [varchar](10) NOT NULL,
	[is_available] [bit] NOT NULL,
	[max_patients] [int] NOT NULL,
	[booked_count] [int] NOT NULL,
	[created_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

