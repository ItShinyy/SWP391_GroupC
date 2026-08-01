/*
Purpose: password reset tokens.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[password_reset_tokens](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[token] [varchar](100) NOT NULL,
	[purpose] [varchar](50) NOT NULL,
	[attempts] [int] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[used_at] [datetime2](7) NULL,
	[expires_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

