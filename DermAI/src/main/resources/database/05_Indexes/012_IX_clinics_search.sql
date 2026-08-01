/*
Purpose: IX clinics search.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_PADDING ON;
GO

CREATE NONCLUSTERED INDEX [IX_clinics_search] ON [dbo].[clinics]
(
	[is_active] ASC,
	[province] ASC,
	[facility_type] ASC,
	[clinic_name] ASC
)
INCLUDE([address],[latitude],[longitude],[specialty]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

