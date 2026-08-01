/*
Purpose: Drop users.must_change_password (feature removed — YAGNI).
Safe if column never existed or was added by a prior local apply of the old Add script.
*/
IF COL_LENGTH('dbo.users', 'must_change_password') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1 FROM sys.default_constraints
        WHERE parent_object_id = OBJECT_ID('dbo.users')
          AND name = 'DF_users_must_change_password'
    )
        ALTER TABLE dbo.users DROP CONSTRAINT DF_users_must_change_password;

    ALTER TABLE dbo.users DROP COLUMN must_change_password;
END
GO
