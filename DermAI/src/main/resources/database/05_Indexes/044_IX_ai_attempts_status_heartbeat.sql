CREATE INDEX [IX_ai_attempts_status_heartbeat] ON [dbo].[ai_screening_attempts] ([status], [heartbeat_at]) WHERE [status] = 'PROCESSING';
GO
