/* Flat clinical guidance keyed by disease_code. No versioning. */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clinical_policy_entries](
    [id] [uniqueidentifier] NOT NULL,
    [disease_code] [varchar](50) NOT NULL,
    [display_name] [nvarchar](150) NOT NULL,
    [risk_level] [varchar](20) NOT NULL,
    [recommendation] [nvarchar](2000) NOT NULL,
    [disclaimer] [nvarchar](2000) NOT NULL,
    [updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
