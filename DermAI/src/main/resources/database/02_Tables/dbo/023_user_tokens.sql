/*
Purpose: Legacy token workflow retained for backward compatibility.
Dependencies: dbo.users. New code should prefer dbo.password_reset_tokens.
*/

CREATE TABLE [dbo].[user_tokens]
(
    [id] [int] IDENTITY(1, 1) NOT NULL,
    [user_id] [uniqueidentifier] NOT NULL,
    [token] [varchar](100) NOT NULL,
    [purpose] [varchar](50) NOT NULL,
    [attempts] [int] NOT NULL,
    [created_at] [datetime2](7) NOT NULL,
    [used_at] [datetime2](7) NULL,
    [expires_at] [datetime2](7) NOT NULL
) ON [PRIMARY];
GO
