# Change log

## 1.1.0 - 2026-07-22

- Merged the legacy `schema.sql` model into the structured baseline.
- Added three legacy-only tables and legacy-compatible columns, constraints, and indexes.
- Added an upgrade migration for deployed v1.0 structured databases.

## 1.0.0 - 2026-07-22

- Refactored the SSMS schema export into a dependency-ordered SQL Server database project.
- Excluded the separate data export from source-controlled seed data.
- Added explicit names for previously unnamed default constraints and feedback check constraints.
