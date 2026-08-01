/*
Purpose: dbo.
Source: Refactored from Scriptos.sql (schema export).
*/

IF SCHEMA_ID(N'dbo') IS NULL
    EXEC(N'CREATE SCHEMA dbo AUTHORIZATION dbo;');
GO

