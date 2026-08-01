/*
Purpose: IX medical reports diagnosis report.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_PADDING ON;
GO

CREATE NONCLUSTERED INDEX [IX_medical_reports_diagnosis_report] ON [dbo].[medical_reports]
(
	[diagnosis_report_id] ASC
)
WHERE ([diagnosis_report_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

