CREATE NONCLUSTERED INDEX [IX_user_tokens_token_expires_at]
    ON [dbo].[user_tokens] ([token], [expires_at]);
GO
