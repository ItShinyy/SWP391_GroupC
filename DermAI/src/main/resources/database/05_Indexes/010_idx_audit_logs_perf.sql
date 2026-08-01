/*
Purpose: idx audit logs perf.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_PADDING ON;
GO

CREATE NONCLUSTERED INDEX [idx_audit_logs_perf] ON [dbo].[audit_logs]
(
	[created_at] DESC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

