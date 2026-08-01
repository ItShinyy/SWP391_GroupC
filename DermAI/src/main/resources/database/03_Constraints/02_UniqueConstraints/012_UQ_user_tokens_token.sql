ALTER TABLE [dbo].[user_tokens]
    ADD CONSTRAINT [UQ_user_tokens_token] UNIQUE NONCLUSTERED ([token]);
GO
