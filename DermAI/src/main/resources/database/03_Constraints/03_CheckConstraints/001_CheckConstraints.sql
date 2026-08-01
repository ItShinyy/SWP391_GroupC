/*
Purpose: CheckConstraints.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER TABLE [dbo].[account_appeals]  WITH CHECK ADD  CONSTRAINT [CHK_account_appeals_status] CHECK  (([status]='REJECTED' OR [status]='APPROVED' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[account_appeals] CHECK CONSTRAINT [CHK_account_appeals_status]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CHK_appointments_attendance_status] CHECK  (([attendance_status]='CANCELLED' OR [attendance_status]='NO_SHOW' OR [attendance_status]='NOT_VISITED' OR [attendance_status]='VISITED'))
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CHK_appointments_attendance_status]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CHK_appointments_status] CHECK  (([status]='NO_SHOW' OR [status]='CANCELLED' OR [status]='COMPLETED' OR [status]='CHECKED_IN' OR [status]='CONFIRMED' OR [status]='CREATED'))
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CHK_appointments_status]
GO
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CHK_doctor_status] CHECK  (([doctor_status]='REJECTED' OR [doctor_status]='ACCEPTED' OR [doctor_status]='PENDING'))
GO
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CHK_doctor_status]
GO
ALTER TABLE [dbo].[clinics]  WITH CHECK ADD  CONSTRAINT [CHK_clinics_facility_type] CHECK  (([facility_type]='CLINIC' OR [facility_type]='HOSPITAL'))
GO
ALTER TABLE [dbo].[clinics] CHECK CONSTRAINT [CHK_clinics_facility_type]
GO
ALTER TABLE [dbo].[clinics]  WITH CHECK ADD  CONSTRAINT [CHK_clinics_latitude] CHECK  (([latitude] IS NULL OR [latitude]>=(-90) AND [latitude]<=(90)))
GO
ALTER TABLE [dbo].[clinics] CHECK CONSTRAINT [CHK_clinics_latitude]
GO
ALTER TABLE [dbo].[clinics]  WITH CHECK ADD  CONSTRAINT [CHK_clinics_longitude] CHECK  (([longitude] IS NULL OR [longitude]>=(-180) AND [longitude]<=(180)))
GO
ALTER TABLE [dbo].[clinics] CHECK CONSTRAINT [CHK_clinics_longitude]
GO
ALTER TABLE [dbo].[diagnosis_reports]  WITH CHECK ADD  CONSTRAINT [CHK_reports_confidence] CHECK  (([confidence_score] IS NULL OR [confidence_score]>=(0) AND [confidence_score]<=(100)))
GO
ALTER TABLE [dbo].[diagnosis_reports] CHECK CONSTRAINT [CHK_reports_confidence]
GO
ALTER TABLE [dbo].[diagnosis_reports]  WITH CHECK ADD  CONSTRAINT [CHK_reports_risk] CHECK  (([risk_level] IS NULL OR ([risk_level]='HIGH' OR [risk_level]='MEDIUM' OR [risk_level]='LOW')))
GO
ALTER TABLE [dbo].[diagnosis_reports] CHECK CONSTRAINT [CHK_reports_risk]
GO
ALTER TABLE [dbo].[doctor_schedules]  WITH CHECK ADD  CONSTRAINT [CHK_schedule_slot] CHECK  (([slot]='EVENING' OR [slot]='AFTERNOON' OR [slot]='MORNING'))
GO
ALTER TABLE [dbo].[doctor_schedules] CHECK CONSTRAINT [CHK_schedule_slot]
GO
ALTER TABLE [dbo].[family_members]  WITH CHECK ADD  CONSTRAINT [CHK_family_members_gender] CHECK  (([gender]='OTHER' OR [gender]='FEMALE' OR [gender]='MALE'))
GO
ALTER TABLE [dbo].[family_members] CHECK CONSTRAINT [CHK_family_members_gender]
GO
ALTER TABLE [dbo].[family_members]  WITH CHECK ADD  CONSTRAINT [CHK_family_members_relationship] CHECK  (([relationship]='OTHER' OR [relationship]='GRANDPARENT' OR [relationship]='YOUNGER_SISTER' OR [relationship]='YOUNGER_BROTHER' OR [relationship]='OLDER_SISTER' OR [relationship]='OLDER_BROTHER' OR [relationship]='CHILD' OR [relationship]='SPOUSE' OR [relationship]='MOTHER' OR [relationship]='FATHER'))
GO
ALTER TABLE [dbo].[family_members] CHECK CONSTRAINT [CHK_family_members_relationship]
GO
ALTER TABLE [dbo].[feedbacks] WITH CHECK ADD CONSTRAINT [CK_feedbacks_category]
CHECK
(
    [category] IN
    (
        N'Khi' + NCHAR(7871) + N'u n' + NCHAR(7841) + N'i',
        N'G' + NCHAR(243) + N'p ' + NCHAR(253),
        N'Khen'
    )
)
GO
ALTER TABLE [dbo].[feedbacks] WITH CHECK ADD CONSTRAINT [CK_feedbacks_rating] CHECK (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[feedbacks] WITH CHECK ADD CONSTRAINT [CK_feedbacks_status]
CHECK
(
    [status] IN
    (
        NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253),
        N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253),
        NCHAR(272) + N'ang x' + NCHAR(7917) + N' l' + NCHAR(253)
    )
)
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [CHK_invoices_paid_at] CHECK  (([status]='PAID' AND [paid_at] IS NOT NULL OR [status]<>'PAID'))
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [CHK_invoices_paid_at]
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [CHK_invoices_status] CHECK  (([status]='REFUNDED' OR [status]='CANCELLED' OR [status]='PAID' OR [status]='UNPAID'))
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [CHK_invoices_status]
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [CHK_invoices_total_amount] CHECK  (([total_amount]>=(0)))
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [CHK_invoices_total_amount]
GO
ALTER TABLE [dbo].[issue_reports]  WITH CHECK ADD  CONSTRAINT [CHK_issue_reports_category] CHECK  (([category]='OTHER' OR [category]='SYSTEM' OR [category]='ACCOUNT' OR [category]='PAYMENT' OR [category]='APPOINTMENT'))
GO
ALTER TABLE [dbo].[issue_reports] CHECK CONSTRAINT [CHK_issue_reports_category]
GO
ALTER TABLE [dbo].[issue_reports]  WITH CHECK ADD  CONSTRAINT [CHK_issue_reports_status] CHECK  (([status]='REJECTED' OR [status]='RESOLVED' OR [status]='IN_PROGRESS' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[issue_reports] CHECK CONSTRAINT [CHK_issue_reports_status]
GO
ALTER TABLE [dbo].[medical_reports]  WITH CHECK ADD  CONSTRAINT [CHK_medical_reports_status] CHECK  (([status]='AMENDED' OR [status]='COMPLETED' OR [status]='DRAFT'))
GO
ALTER TABLE [dbo].[medical_reports] CHECK CONSTRAINT [CHK_medical_reports_status]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [CHK_notifications_email_status] CHECK  (([email_status]='FAILED' OR [email_status]='SENT' OR [email_status]='SENDING' OR [email_status]='PENDING'))
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [CHK_notifications_email_status]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [CHK_notifications_type] CHECK  (([type]='APPOINTMENT_REMINDER' OR [type]='APPOINTMENT_RESCHEDULED' OR [type]='DOCTOR_CHANGED' OR [type]='APPOINTMENT_CANCELLED' OR [type]='PAYMENT_EXPIRED' OR [type]='PAYMENT_FAILED' OR [type]='PAYMENT_SUCCESS' OR [type]='PAYMENT_PENDING'))
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [CHK_notifications_type]
GO
ALTER TABLE [dbo].[password_reset_tokens]  WITH CHECK ADD  CONSTRAINT [CHK_password_tokens_attempts] CHECK  (([attempts]>=(0)))
GO
ALTER TABLE [dbo].[password_reset_tokens] CHECK CONSTRAINT [CHK_password_tokens_attempts]
GO
ALTER TABLE [dbo].[password_reset_tokens]  WITH CHECK ADD  CONSTRAINT [CHK_password_tokens_purpose] CHECK  (([purpose]='VERIFY_EMAIL' OR [purpose]='UNLOCK_APPEAL' OR [purpose]='RESET_PASSWORD'))
GO
ALTER TABLE [dbo].[password_reset_tokens] CHECK CONSTRAINT [CHK_password_tokens_purpose]
GO
ALTER TABLE [dbo].[patients]  WITH CHECK ADD  CONSTRAINT [CHK_patients_gender] CHECK  (([gender]='OTHER' OR [gender]='FEMALE' OR [gender]='MALE'))
GO
ALTER TABLE [dbo].[patients] CHECK CONSTRAINT [CHK_patients_gender]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [CHK_payments_amount] CHECK  (([amount]>(0)))
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [CHK_payments_amount]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [CHK_payments_method] CHECK  (([payment_method]='BANK_TRANSFER' OR [payment_method]='VNPAY' OR [payment_method]='CASH'))
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [CHK_payments_method]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [CHK_payments_status] CHECK  (([status]='REFUNDED' OR [status]='EXPIRED' OR [status]='FAILED' OR [status]='SUCCESS' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [CHK_payments_status]
GO
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [CHK_payments_success] CHECK  (([status]<>'SUCCESS' OR [signature_verified]=(1) AND [vnp_response_code]='00' AND [vnp_transaction_status]='00' AND [processed_at] IS NOT NULL OR [payment_method]<>'VNPAY'))
GO
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [CHK_payments_success]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CHK_users_identity] CHECK  (([email] IS NOT NULL OR [google_id] IS NOT NULL))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CHK_users_identity]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CHK_users_role] CHECK  (([role]='DOCTOR' OR [role]='ADMIN' OR [role]='PATIENT' OR [role]='USER'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CHK_users_role]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CHK_users_status] CHECK  (([status]='LOCKED' OR [status]='INACTIVE' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CHK_users_status]
GO
