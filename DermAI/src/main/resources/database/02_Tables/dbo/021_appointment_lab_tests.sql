/*
Purpose: Legacy appointment lab-test results retained from schema.sql.
Dependencies: dbo.appointments.
*/

CREATE TABLE [dbo].[appointment_lab_tests]
(
    [id] [uniqueidentifier] NOT NULL,
    [appointment_id] [uniqueidentifier] NOT NULL,
    [test_type] [nvarchar](255) NULL,
    [result_file_url] [varchar](1000) NULL,
    [created_at] [datetime2](7) NOT NULL,
    [test_name] [nvarchar](255) NULL,
    [status] [varchar](20) NOT NULL,
    [result_summary] [nvarchar](max) NULL,
    [result_image_url] [varchar](1000) NULL,
    [updated_at] [datetime2](7) NOT NULL
) ON [PRIMARY];
GO
