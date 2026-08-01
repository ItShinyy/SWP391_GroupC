# Legacy schema merge

`V1.1.0__Merge_Legacy_Schema.sql` incorporates the legacy `resources/schema.sql` model into this project.

- Added user account fields: avatar, failed-login tracking, lock type, and password-change timestamp.
- Added clinic Google Place/rating support and an index for Google Place identity.
- Added appointment patient snapshot fields.
- Broadened prescription and doctor columns to preserve legacy-compatible values.
- Added `appointment_lab_tests` and `user_tokens` with their keys, defaults, checks, foreign keys, and indexes.

`user_tokens` is retained for legacy compatibility. New flows should prefer `password_reset_tokens`; do not merge their data without an explicit mapping of the differing purpose values.
