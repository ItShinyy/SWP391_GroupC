ALTER TABLE [dbo].[users]
    ADD CONSTRAINT [DF_users_failed_login_attempts] DEFAULT ((0)) FOR [failed_login_attempts];
GO

ALTER TABLE [dbo].[clinics]
    ADD CONSTRAINT [DF_clinics_facility_type] DEFAULT ('CLINIC') FOR [facility_type];
GO

ALTER TABLE [dbo].[appointment_prescriptions]
    ADD CONSTRAINT [DF_appointment_prescriptions_quantity] DEFAULT ((1)) FOR [quantity];
GO

ALTER TABLE [dbo].[appointment_lab_tests]
    ADD CONSTRAINT [DF_appointment_lab_tests_id] DEFAULT (newsequentialid()) FOR [id];
GO

ALTER TABLE [dbo].[appointment_lab_tests]
    ADD CONSTRAINT [DF_appointment_lab_tests_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO

ALTER TABLE [dbo].[appointment_lab_tests]
    ADD CONSTRAINT [DF_appointment_lab_tests_status] DEFAULT ('PENDING') FOR [status];
GO

ALTER TABLE [dbo].[appointment_lab_tests]
    ADD CONSTRAINT [DF_appointment_lab_tests_updated_at] DEFAULT (sysdatetime()) FOR [updated_at];
GO

ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [DF_user_tokens_purpose] DEFAULT ('RESET_PASSWORD') FOR [purpose];
GO

ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [DF_user_tokens_attempts] DEFAULT ((0)) FOR [attempts];
GO

ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [DF_user_tokens_created_at] DEFAULT (sysdatetime()) FOR [created_at];
GO
