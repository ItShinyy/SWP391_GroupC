/*
Purpose: UQ diseases name.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[diseases] ADD CONSTRAINT [UQ_diseases_name] UNIQUE NONCLUSTERED 
(
	[disease_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

