CREATE INDEX [IX_ai_attempts_patient_created] ON [dbo].[ai_screening_attempts] ([patient_id], [created_at] DESC);
GO
