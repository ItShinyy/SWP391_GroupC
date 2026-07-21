/* Run this only if family_members was already created from an earlier migration. */
IF OBJECT_ID(N'dbo.family_members', N'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_family_members_relationship' AND parent_object_id = OBJECT_ID(N'dbo.family_members'))
        ALTER TABLE dbo.family_members DROP CONSTRAINT CHK_family_members_relationship;

    ALTER TABLE dbo.family_members ADD CONSTRAINT CHK_family_members_relationship
        CHECK (relationship IN ('FATHER', 'MOTHER', 'SPOUSE', 'CHILD', 'OLDER_BROTHER', 'OLDER_SISTER', 'YOUNGER_BROTHER', 'YOUNGER_SISTER', 'GRANDPARENT', 'OTHER'));
END;
GO
