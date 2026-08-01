/*
Purpose: CreateDatabase.
Source: Refactored from Scriptos.sql (schema export).
*/

IF DB_ID(N'$(DatabaseName)') IS NULL
BEGIN
    DECLARE @createDatabaseSql NVARCHAR(MAX) = N'CREATE DATABASE ' + QUOTENAME(N'$(DatabaseName)') + N';';
    EXEC sys.sp_executesql @createDatabaseSql;
END;
GO

USE [$(DatabaseName)];
GO

