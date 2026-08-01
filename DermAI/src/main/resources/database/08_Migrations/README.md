# Migrations (historical only)

**Do not create new `V*.sql` files.** Derma is under active development — change the baseline directly (`02_Tables`, `03_Constraints`, SPs, `Master_Deploy.sql`, `WipeData.sql`, seeds), then rebuild locally:

`WipeDatabase.bat` → `Deploy.bat` → `Seed.bat`

Files in this folder are leftovers from an earlier approach. Do not extend them; do not use them as the primary schema-change path.

## Local AI screening note

If diagnose shows `The screening attempt could not be created.` after the first try, the fix belongs in **baseline** unique-index scripts (not a new migration). Pending AI attempts need a filtered unique index on `diagnosis_report_id` (SQL Server unique constraints allow only one `NULL` otherwise).

## Auth note

Phone is contact-only. Baseline `CK_user_tokens_purpose` allows email OTP purposes only (`RESET_PASSWORD`, `UNLOCK_ACCOUNT`, `VERIFY_EMAIL`, `EMAIL_CHANGE_*`). Identity requires `email OR google_id`.
