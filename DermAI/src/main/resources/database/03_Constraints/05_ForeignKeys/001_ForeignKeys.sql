/*
Purpose: ForeignKeys.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[account_appeals]  WITH CHECK ADD  CONSTRAINT [FK_account_appeals_reviewed_by] FOREIGN KEY([reviewed_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[account_appeals] CHECK CONSTRAINT [FK_account_appeals_reviewed_by]
GO
ALTER TABLE [dbo].[account_appeals]  WITH CHECK ADD  CONSTRAINT [FK_account_appeals_token] FOREIGN KEY([token_id])
REFERENCES [dbo].[password_reset_tokens] ([id])
GO
ALTER TABLE [dbo].[account_appeals] CHECK CONSTRAINT [FK_account_appeals_token]
GO
ALTER TABLE [dbo].[account_appeals]  WITH CHECK ADD  CONSTRAINT [FK_account_appeals_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[account_appeals] CHECK CONSTRAINT [FK_account_appeals_users]
GO
ALTER TABLE [dbo].[appointment_prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_appointment_prescriptions_appointments] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[appointment_prescriptions] CHECK CONSTRAINT [FK_appointment_prescriptions_appointments]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_clinics] FOREIGN KEY([clinic_id])
REFERENCES [dbo].[clinics] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_clinics]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_doctors] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_doctors]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_family_member] FOREIGN KEY([family_member_id])
REFERENCES [dbo].[family_members] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_family_member]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_patients] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_patients]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_reports] FOREIGN KEY([diagnosis_report_id])
REFERENCES [dbo].[diagnosis_reports] ([id])
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_reports]
GO
ALTER TABLE [dbo].[audit_logs]  WITH CHECK ADD  CONSTRAINT [FK_audit_logs_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[audit_logs] CHECK CONSTRAINT [FK_audit_logs_users]
GO
ALTER TABLE [dbo].[diagnosis_reports]  WITH CHECK ADD  CONSTRAINT [FK_diagnosis_reports_clinics] FOREIGN KEY([clinic_id])
REFERENCES [dbo].[clinics] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[diagnosis_reports] CHECK CONSTRAINT [FK_diagnosis_reports_clinics]
GO
ALTER TABLE [dbo].[diagnosis_reports]  WITH CHECK ADD  CONSTRAINT [FK_diagnosis_reports_diseases] FOREIGN KEY([disease_id])
REFERENCES [dbo].[diseases] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[diagnosis_reports] CHECK CONSTRAINT [FK_diagnosis_reports_diseases]
GO
ALTER TABLE [dbo].[diagnosis_reports]  WITH CHECK ADD  CONSTRAINT [FK_diagnosis_reports_patients] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[diagnosis_reports] CHECK CONSTRAINT [FK_diagnosis_reports_patients]
GO
ALTER TABLE [dbo].[doctor_schedules]  WITH CHECK ADD  CONSTRAINT [FK_schedules_doctors] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[doctor_schedules] CHECK CONSTRAINT [FK_schedules_doctors]
GO
ALTER TABLE [dbo].[doctors]  WITH CHECK ADD  CONSTRAINT [FK_doctors_clinics] FOREIGN KEY([clinic_id])
REFERENCES [dbo].[clinics] ([id])
GO
ALTER TABLE [dbo].[doctors] CHECK CONSTRAINT [FK_doctors_clinics]
GO
ALTER TABLE [dbo].[doctors]  WITH CHECK ADD  CONSTRAINT [FK_doctors_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[doctors] CHECK CONSTRAINT [FK_doctors_users]
GO
ALTER TABLE [dbo].[family_members]  WITH CHECK ADD  CONSTRAINT [FK_family_members_owner] FOREIGN KEY([owner_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[family_members] CHECK CONSTRAINT [FK_family_members_owner]
GO
ALTER TABLE [dbo].[feedbacks]  WITH CHECK ADD  CONSTRAINT [FK_Feedback_Appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[feedbacks] CHECK CONSTRAINT [FK_Feedback_Appointment]
GO
ALTER TABLE [dbo].[feedbacks]  WITH CHECK ADD  CONSTRAINT [FK_Feedback_Patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([id])
GO
ALTER TABLE [dbo].[feedbacks] CHECK CONSTRAINT [FK_Feedback_Patient]
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [FK_invoices_appointments] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [FK_invoices_appointments]
GO
ALTER TABLE [dbo].[issue_reports]  WITH CHECK ADD  CONSTRAINT [FK_issue_reports_admin] FOREIGN KEY([handled_by_admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[issue_reports] CHECK CONSTRAINT [FK_issue_reports_admin]
GO
ALTER TABLE [dbo].[issue_reports]  WITH CHECK ADD  CONSTRAINT [FK_issue_reports_reporter] FOREIGN KEY([reporter_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[issue_reports] CHECK CONSTRAINT [FK_issue_reports_reporter]
GO
ALTER TABLE [dbo].[medical_reports]  WITH CHECK ADD  CONSTRAINT [FK_medical_reports_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([id])
GO
ALTER TABLE [dbo].[medical_reports] CHECK CONSTRAINT [FK_medical_reports_appointment]
GO
ALTER TABLE [dbo].[medical_reports]  WITH CHECK ADD  CONSTRAINT [FK_medical_reports_diagnosis_report] FOREIGN KEY([diagnosis_report_id])
REFERENCES [dbo].[diagnosis_reports] ([id])
GO
ALTER TABLE [dbo].[medical_reports] CHECK CONSTRAINT [FK_medical_reports_diagnosis_report]
GO
ALTER TABLE [dbo].[medical_reports]  WITH CHECK ADD  CONSTRAINT [FK_medical_reports_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([id])
GO
ALTER TABLE [dbo].[medical_reports] CHECK CONSTRAINT [FK_medical_reports_doctor]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [FK_notifications_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [FK_notifications_users]
GO
ALTER TABLE [dbo].[password_reset_tokens]  WITH CHECK ADD  CONSTRAINT [FK_password_tokens_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[password_reset_tokens] CHECK CONSTRAINT [FK_password_tokens_users]
GO
ALTER TABLE [dbo].[patients]  WITH CHECK ADD  CONSTRAINT [FK_patients_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[patients] CHECK CONSTRAINT [FK_patients_users]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payments_invoices] FOREIGN KEY([invoice_id])
REFERENCES [dbo].[invoices] ([id])
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payments_invoices]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_locked_by] FOREIGN KEY([locked_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_locked_by]
GO

