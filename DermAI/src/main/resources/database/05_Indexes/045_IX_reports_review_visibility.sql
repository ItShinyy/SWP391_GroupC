CREATE INDEX [IX_reports_review_visibility] ON [dbo].[diagnosis_reports] ([patient_id], [patient_visibility_status], [doctor_review_status], [created_at] DESC);
GO
