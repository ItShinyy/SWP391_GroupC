/*
Purpose: DefaultConstraints.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[account_appeals] ADD CONSTRAINT [DF_account_appeals_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[account_appeals] ADD CONSTRAINT [DF_account_appeals_status] DEFAULT ('PENDING') FOR [status];
GO

ALTER TABLE [dbo].[account_appeals] ADD CONSTRAINT [DF_account_appeals_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[account_appeals] ADD CONSTRAINT [DF_account_appeals_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[appointment_prescriptions] ADD CONSTRAINT [DF_appointment_prescriptions_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[appointment_prescriptions] ADD CONSTRAINT [DF_appointment_prescriptions_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[appointment_prescriptions] ADD CONSTRAINT [DF_appointment_prescriptions_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_status] DEFAULT ('CREATED') FOR [status];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_doctor_status] DEFAULT ('PENDING') FOR [doctor_status];
GO

ALTER TABLE [dbo].[appointments] ADD CONSTRAINT [DF_appointments_attendance_status] DEFAULT ('NOT_VISITED') FOR [attendance_status];
GO

ALTER TABLE [dbo].[audit_logs] ADD CONSTRAINT [DF_audit_logs_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[audit_logs] ADD CONSTRAINT [DF_audit_logs_status] DEFAULT ('SUCCESS') FOR [status];
GO

ALTER TABLE [dbo].[audit_logs] ADD CONSTRAINT [DF_audit_logs_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[clinics] ADD CONSTRAINT [DF_clinics_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[clinics] ADD CONSTRAINT [DF_clinics_is_active] DEFAULT ((1)) FOR [is_active];
GO

ALTER TABLE [dbo].[clinics] ADD CONSTRAINT [DF_clinics_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[clinics] ADD CONSTRAINT [DF_clinics_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [DF_diagnosis_reports_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[diagnosis_reports] ADD CONSTRAINT [DF_diagnosis_reports_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[diseases] ADD CONSTRAINT [DF_diseases_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[diseases] ADD CONSTRAINT [DF_diseases_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [DF_doctor_schedules_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [DF_doctor_schedules_is_available] DEFAULT ((1)) FOR [is_available];
GO

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [DF_doctor_schedules_max_patients] DEFAULT ((5)) FOR [max_patients];
GO

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [DF_doctor_schedules_booked_count] DEFAULT ((0)) FOR [booked_count];
GO

ALTER TABLE [dbo].[doctor_schedules] ADD CONSTRAINT [DF_doctor_schedules_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[doctors] ADD CONSTRAINT [DF_doctors_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[doctors] ADD CONSTRAINT [DF_doctors_is_active] DEFAULT ((1)) FOR [is_active];
GO

ALTER TABLE [dbo].[doctors] ADD CONSTRAINT [DF_doctors_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[doctors] ADD CONSTRAINT [DF_doctors_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[family_members] ADD CONSTRAINT [DF_family_members_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[family_members] ADD CONSTRAINT [DF_family_members_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[family_members] ADD CONSTRAINT [DF_family_members_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[feedbacks] ADD CONSTRAINT [DF_feedbacks_id] DEFAULT (newid()) FOR [id];
GO

ALTER TABLE [dbo].[feedbacks] ADD CONSTRAINT [DF_feedbacks_created_at] DEFAULT (getdate()) FOR [created_at];
GO

ALTER TABLE [dbo].[feedbacks] ADD CONSTRAINT [DF_feedbacks_status]
DEFAULT (N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253)) FOR [status];
GO

ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [DF_invoices_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [DF_invoices_status] DEFAULT ('UNPAID') FOR [status];
GO

ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [DF_invoices_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[invoices] ADD CONSTRAINT [DF_invoices_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[issue_reports] ADD CONSTRAINT [DF_issue_reports_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[issue_reports] ADD CONSTRAINT [DF_issue_reports_status] DEFAULT ('PENDING') FOR [status];
GO

ALTER TABLE [dbo].[issue_reports] ADD CONSTRAINT [DF_issue_reports_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[issue_reports] ADD CONSTRAINT [DF_issue_reports_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[medical_reports] ADD CONSTRAINT [DF_medical_reports_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[medical_reports] ADD CONSTRAINT [DF_medical_reports_status] DEFAULT ('DRAFT') FOR [status];
GO

ALTER TABLE [dbo].[medical_reports] ADD CONSTRAINT [DF_medical_reports_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[medical_reports] ADD CONSTRAINT [DF_medical_reports_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[notification_job_settings] ADD CONSTRAINT [DF_notification_job_settings_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[notifications] ADD CONSTRAINT [DF_notifications_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[notifications] ADD CONSTRAINT [DF_notifications_is_read] DEFAULT ((0)) FOR [is_read];
GO

ALTER TABLE [dbo].[notifications] ADD CONSTRAINT [DF_notifications_email_status] DEFAULT ('PENDING') FOR [email_status];
GO

ALTER TABLE [dbo].[notifications] ADD CONSTRAINT [DF_notifications_email_attempts] DEFAULT ((0)) FOR [email_attempts];
GO

ALTER TABLE [dbo].[notifications] ADD CONSTRAINT [DF_notifications_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[password_reset_tokens] ADD CONSTRAINT [DF_password_reset_tokens_purpose] DEFAULT ('RESET_PASSWORD') FOR [purpose];
GO

ALTER TABLE [dbo].[password_reset_tokens] ADD CONSTRAINT [DF_password_reset_tokens_attempts] DEFAULT ((0)) FOR [attempts];
GO

ALTER TABLE [dbo].[password_reset_tokens] ADD CONSTRAINT [DF_password_reset_tokens_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[patients] ADD CONSTRAINT [DF_patients_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[patients] ADD CONSTRAINT [DF_patients_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[patients] ADD CONSTRAINT [DF_patients_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_payment_method] DEFAULT ('VNPAY') FOR [payment_method];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_status] DEFAULT ('PENDING') FOR [status];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_signature_verified] DEFAULT ((0)) FOR [signature_verified];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[payments] ADD CONSTRAINT [DF_payments_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[users] ADD CONSTRAINT [DF_users_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[users] ADD CONSTRAINT [DF_users_role] DEFAULT ('PATIENT') FOR [role];
GO

ALTER TABLE [dbo].[users] ADD CONSTRAINT [DF_users_status] DEFAULT ('ACTIVE') FOR [status];
GO

ALTER TABLE [dbo].[users] ADD CONSTRAINT [DF_users_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[users] ADD CONSTRAINT [DF_users_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO
