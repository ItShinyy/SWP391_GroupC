/*
Purpose: UX account appeals pending user.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_PADDING ON;
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_account_appeals_pending_user] ON [dbo].[account_appeals]
(
	[user_id] ASC
)
WHERE ([status]='PENDING')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

