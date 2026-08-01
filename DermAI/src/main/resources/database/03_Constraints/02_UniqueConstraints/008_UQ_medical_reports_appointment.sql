/*
Purpose: UQ medical reports appointment.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[medical_reports] ADD CONSTRAINT [UQ_medical_reports_appointment] UNIQUE NONCLUSTERED 
(
	[appointment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

