:ON ERROR EXIT
:setvar DatabaseName "SWP391"

/* Destructive: removes only the configured database and all of its data. */
USE [master];
GO

IF DB_ID(N'$(DatabaseName)') IS NOT NULL
BEGIN
    DECLARE @alterDatabaseSql NVARCHAR(MAX) =
        N'ALTER DATABASE ' + QUOTENAME(N'$(DatabaseName)') +
        N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
    EXEC sys.sp_executesql @alterDatabaseSql;

    DECLARE @dropDatabaseSql NVARCHAR(MAX) =
        N'DROP DATABASE ' + QUOTENAME(N'$(DatabaseName)') + N';';
    EXEC sys.sp_executesql @dropDatabaseSql;
END;
GO
