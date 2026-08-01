ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [FK_ai_attempt_patient] FOREIGN KEY ([patient_id]) REFERENCES [dbo].[patients]([id]);
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [FK_ai_attempt_requested_by] FOREIGN KEY ([requested_by_user_id]) REFERENCES [dbo].[users]([id]);
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [FK_ai_attempt_model] FOREIGN KEY ([ai_model_id]) REFERENCES [dbo].[ai_models]([id]);
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [FK_ai_attempt_report] FOREIGN KEY ([diagnosis_report_id]) REFERENCES [dbo].[diagnosis_reports]([id]);
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [FK_reports_ai_attempt] FOREIGN KEY ([ai_screening_attempt_id]) REFERENCES [dbo].[ai_screening_attempts]([id]);
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [FK_reports_ai_suggested_disease] FOREIGN KEY ([ai_suggested_disease_id]) REFERENCES [dbo].[diseases]([id]);
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [FK_reports_reviewed_by_doctor] FOREIGN KEY ([reviewed_by_doctor_id]) REFERENCES [dbo].[doctors]([id]);
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [FK_reports_doctor_selected_disease] FOREIGN KEY ([doctor_selected_disease_id]) REFERENCES [dbo].[diseases]([id]);
GO
