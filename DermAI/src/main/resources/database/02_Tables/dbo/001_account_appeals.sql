/*
Purpose: account appeals.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[account_appeals](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NOT NULL,
	[token_id] [int] NULL,
	[appeal_text] [nvarchar](1000) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[admin_note] [nvarchar](1000) NULL,
	[reviewed_by] [uniqueidentifier] NULL,
	[reviewed_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

