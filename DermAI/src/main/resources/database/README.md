# SWP391 database

## Local
1. `WipeDatabase.bat` (optional)
2. `Deploy.bat`
3. `Seed.bat`
4. Admin `/admin/ai-models` → upload zip → Activate
5. Start FastAPI with shared models root

Schema lives in baseline (`02_Tables` + Deploy). No upgrade migration — wipe + redeploy locally.

### Payment expire SP
`usp_ExpirePendingPayments` is baseline-edited (`04_Programmability/.../001_usp_expire_pending_payments.sql`).
After pull: redeploy SP (or full `Deploy.bat`). Optional `@Cascade` (default 1) cancels UNPAID invoices with no live SUCCESS/PENDING and linked pre-visit appointments. Java passes cascade from `billing.expire.cancel.appointment`. Do **not** add `08_Migrations/V*.sql` for this.

## Config (only two secret files)
| File | Process |
|---|---|
| `DermAI/local.properties` | Tomcat / Java |
| `DermAI/ai-service/.env.local` | FastAPI container |

Share `AI_SERVICE_API_KEY`. Share models path (`AI_MODELS_ROOT` / `ai.models.root`).

Auth uses **email OTP only** (no SMS / phone OTP). `users.phone` / `clinics.phone` are contact fields.
