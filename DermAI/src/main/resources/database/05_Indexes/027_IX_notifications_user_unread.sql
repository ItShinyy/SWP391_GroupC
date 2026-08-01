/*
Purpose: IX notifications user unread.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_PADDING ON;
GO

CREATE NONCLUSTERED INDEX [IX_notifications_user_unread] ON [dbo].[notifications]
(
	[user_id] ASC,
	[is_read] ASC,
	[created_at] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

