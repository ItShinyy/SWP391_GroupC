/*
Purpose: UQ issue reports code.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[issue_reports] ADD CONSTRAINT [UQ_issue_reports_code] UNIQUE NONCLUSTERED 
(
	[report_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

