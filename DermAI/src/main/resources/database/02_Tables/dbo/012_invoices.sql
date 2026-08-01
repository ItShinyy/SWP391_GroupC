/*
Purpose: invoices.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoices](
	[id] [uniqueidentifier] NOT NULL,
	[appointment_id] [uniqueidentifier] NOT NULL,
	[total_amount] [decimal](18, 2) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[description] [nvarchar](500) NULL,
	[paid_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

