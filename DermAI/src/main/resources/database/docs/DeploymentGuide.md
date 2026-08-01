# Deployment guide

1. Open `Master_Deploy.sql` in SSMS.
2. Enable **Query > SQLCMD Mode**.
3. Update `DatabaseName` if a name other than `SWP391` is required.
4. Execute against an account permitted to create a database.

The script creates an empty database, then applies tables, constraints, programmable objects, and indexes in dependency order. It must not be run against a database with existing application data.

For an anonymized local development dataset, run `Seed.bat` after deployment. Seed data is intentionally not part of `Master_Deploy.sql`.

`WipeDatabase.bat` permanently removes `SWP391` after a confirmation prompt. Use it only to reset a local development instance, then run `Deploy.bat` and `Seed.bat`.

`WipeData.bat` removes application rows but preserves the deployed schema. Use it before `Seed.bat` when only fixture data needs to be reset.

