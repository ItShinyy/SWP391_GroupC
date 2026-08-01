ALTER TABLE [dbo].[clinics]
    ADD CONSTRAINT [CK_clinics_rating] CHECK ([rating] IS NULL OR [rating] BETWEEN 0 AND 5);
GO

ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [CK_user_tokens_purpose]
    CHECK ([purpose] IN (
        'RESET_PASSWORD', 'UNLOCK_ACCOUNT', 'VERIFY_EMAIL',
        'EMAIL_CHANGE_OLD', 'EMAIL_CHANGE_NEW'
    ));
GO

ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [CK_user_tokens_attempts] CHECK ([attempts] >= 0);
GO
