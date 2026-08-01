/*
Purpose: UQ invoices appointment id.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [UQ_invoices_appointment_id] UNIQUE NONCLUSTERED 
(
	[appointment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

