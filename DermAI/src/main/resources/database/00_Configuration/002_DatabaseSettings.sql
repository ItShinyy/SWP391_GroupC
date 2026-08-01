/*
Purpose: DatabaseSettings.
Source: Refactored from Scriptos.sql (schema export).
*/

ALTER DATABASE [$(DatabaseName)] SET COMPATIBILITY_LEVEL = 150;
GO

ALTER DATABASE [$(DatabaseName)] SET RECOVERY SIMPLE;
GO

