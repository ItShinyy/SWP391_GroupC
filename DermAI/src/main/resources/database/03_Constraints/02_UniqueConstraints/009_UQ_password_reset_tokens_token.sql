/*
Purpose: UQ password reset tokens token.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[password_reset_tokens] ADD CONSTRAINT [UQ_password_reset_tokens_token] UNIQUE NONCLUSTERED 
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

