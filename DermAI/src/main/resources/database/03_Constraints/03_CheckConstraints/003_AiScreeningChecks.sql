ALTER TABLE [dbo].[clinical_policy_entries] ADD CONSTRAINT [CHK_clinical_policy_risk] CHECK ([risk_level] IN ('LOW', 'MEDIUM', 'HIGH'));
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [CHK_ai_attempt_status] CHECK ([status] IN ('PENDING', 'PROCESSING', 'ACCEPTED', 'REJECTED', 'FAILED'));
GO
ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [CHK_ai_attempt_retries] CHECK ([retry_count] >= 0);
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [CHK_reports_doctor_review_status] CHECK ([doctor_review_status] IN ('PENDING_DOCTOR_REVIEW', 'CONFIRMED', 'OVERRIDDEN', 'DISMISSED', 'REQUIRES_IN_PERSON_REVIEW'));
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [CHK_reports_patient_visibility] CHECK ([patient_visibility_status] IN ('HIDDEN', 'VISIBLE'));
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [CHK_reports_override_details] CHECK ([doctor_review_status] <> 'OVERRIDDEN' OR ([doctor_selected_disease_id] IS NOT NULL AND [override_reason] IS NOT NULL));
GO
ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [CHK_reports_visible_after_review] CHECK ([patient_visibility_status] = 'HIDDEN' OR [doctor_review_status] <> 'PENDING_DOCTOR_REVIEW');
GO
