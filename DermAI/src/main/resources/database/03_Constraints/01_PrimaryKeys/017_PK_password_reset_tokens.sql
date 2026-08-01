/*
Purpose: PK password reset tokens.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[password_reset_tokens] ADD CONSTRAINT [PK_password_reset_tokens] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

