/*
Purpose: UQ schedule doctor date slot.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [UQ_schedule_doctor_date_slot] UNIQUE NONCLUSTERED 
(
	[doctor_id] ASC,
	[schedule_date] ASC,
	[slot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];
GO

