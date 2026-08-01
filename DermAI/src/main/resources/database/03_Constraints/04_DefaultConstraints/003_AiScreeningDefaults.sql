ALTER TABLE [dbo].[ai_models] ADD CONSTRAINT [DF_ai_models_is_active] DEFAULT ((0)) FOR [is_active];
GO
ALTER TABLE [dbo].[ai_models] ADD CONSTRAINT [DF_ai_models_created_at] DEFAULT (SYSUTCDATETIME()) FOR [created_at];
GO
ALTER TABLE [dbo].[clinical_policy_entries] ADD CONSTRAINT [DF_clinical_policy_updated_at] DEFAULT (SYSUTCDATETIME()) FOR [updated_at];
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [DF_ai_attempt_retry_count] DEFAULT ((0)) FOR [retry_count];
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [DF_ai_attempt_created_at] DEFAULT (SYSUTCDATETIME()) FOR [created_at];
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [DF_reports_doctor_review_status] DEFAULT ('PENDING_DOCTOR_REVIEW') FOR [doctor_review_status];
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [DF_reports_patient_visibility] DEFAULT ('HIDDEN') FOR [patient_visibility_status];
GO
