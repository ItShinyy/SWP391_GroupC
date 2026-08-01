/* Installed AI model packages (directory under AI_MODELS_ROOT). */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ai_models](
    [id] [uniqueidentifier] NOT NULL,
    [name] [nvarchar](150) NOT NULL,
    [version] [varchar](100) NOT NULL,
    [storage_path] [varchar](512) NOT NULL,
    [is_active] [bit] NOT NULL,
    [created_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
