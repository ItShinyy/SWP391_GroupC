/*
Purpose: PK account appeals.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[account_appeals] ADD CONSTRAINT [PK_account_appeals] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

