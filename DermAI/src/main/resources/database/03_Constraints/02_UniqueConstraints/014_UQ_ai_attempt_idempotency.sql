ALTER TABLE [dbo].[ai_screening_attempts] ADD CONSTRAINT [UQ_ai_attempt_idempotency] UNIQUE ([idempotency_key]);
GO
