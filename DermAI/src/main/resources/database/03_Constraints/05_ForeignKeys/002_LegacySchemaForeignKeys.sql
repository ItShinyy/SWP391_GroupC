ALTER TABLE [dbo].[appointment_lab_tests] WITH CHECK
    ADD CONSTRAINT [FK_appointment_lab_tests_appointments]
    FOREIGN KEY ([appointment_id]) REFERENCES [dbo].[appointments] ([id]) ON DELETE CASCADE;
GO

ALTER TABLE [dbo].[user_tokens] WITH CHECK
    ADD CONSTRAINT [FK_user_tokens_users]
    FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
