/* The baseline rollback is intentionally not automated because dropping a database is destructive. */
THROW 50001, 'Baseline rollback is intentionally not automated.', 1;
GO

