/*
Purpose: UQ appointments request id.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [UQ_appointments_request_id] UNIQUE NONCLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

