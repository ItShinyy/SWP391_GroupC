# DermAI — API and HTTP Interface Reference

Implementation-driven source of truth for the HTTP surfaces in this repository. This file documents shipped behavior, not a proposed REST redesign.

Companion: [ARCHITECTURE.md](ARCHITECTURE.md) · [DESIGN.md](DESIGN.md) · [PRD.md](PRD.md) · [SCHEMA.md](SCHEMA.md) · [RULES.md](RULES.md)

---

## 1. Scope and source priority

DermAI exposes three independent HTTP surfaces:

| Surface | Runtime | Default local base | Primary consumer |
|---|---|---|---|
| Web application | Java 17 Servlet/JSP on Tomcat | `http://localhost:9999/DermAI` | Browser and page JavaScript |
| Payment API | Node.js/Express | `http://localhost:3000` | DermAI payment page and VNPay |
| AI inference API | Python/FastAPI | `http://127.0.0.1:8000` | Java service and AI model administration |

When documentation conflicts with implementation, use this order:

1. Route registration: `WEB-INF/web.xml`, `payment-service/server.js`, `ai-service/app/routes.py`
2. Controller/service behavior and DTO construction
3. Configuration examples and database constraints
4. This file and the generated API Documentation document

The Java web application is primarily server-rendered Servlet MVC. Do not describe every Java route as a REST API. Only the endpoints explicitly marked JSON, CSV, PDF, media, internal, or callback are machine interfaces.

---

## 2. Versioning and compatibility

- Current document version: `v1.0`.
- Shipped routes do not use URI versions such as `/api/v1`.
- Changes are therefore in-place and must remain compatible with the JSP/JavaScript consumers in the same release.
- Payment and AI request/response fields should be treated as contracts. Additive fields are safer than renaming or removing fields.
- VNPay query parameter names and callback acknowledgement values are provider contracts and must not be renamed.

---

## 3. Authentication, authorization, and CSRF

### 3.1 Java web application

- Authentication uses an `HttpSession` principal stored under session attribute `user`.
- Only `ACTIVE` accounts pass the authentication filter.
- The session timeout is 30 minutes.
- Authorization is path-prefix based: `/admin/*` requires `ADMIN`; `/doctor/*` requires `DOCTOR`; `/patient/*` accepts the implemented patient-side roles (`PATIENT`, `USER`, and the allowed admin path behavior).
- `/reports/*` requires authentication and performs resource-level checks through the permission service.
- Mutating requests under `/auth/*`, `/account/*`, `/patient/*`, `/admin/*`, `/doctor/*`, and `/reports/*` pass the CSRF filter. HTML forms must include the server-generated CSRF token.
- Google OAuth uses `/auth/google`, `/auth/google/callback`, and `/auth/google/link`; it does not provide a bearer token API.

### 3.2 Payment API

- The current Node API has an explicit authentication integration gap.
- With `PAYMENT_DEMO_MODE=true`, requester verification is bypassed for local development.
- Otherwise invoice/payment read and create routes return `501 AUTH_INTEGRATION_REQUIRED` until verified session or JWT integration is implemented.
- VNPay IPN and Return routes authenticate callback data by verifying the VNPay signature rather than an end-user session.

### 3.3 AI inference API

- `POST /internal/packages/validate` and `POST /internal/packages/invalidate` require `X-AI-Service-Key`.
- `POST /internal/screenings` requires `X-AI-Service-Key`, `X-AI-Request-Nonce`, and `X-AI-Request-Timestamp`.
- The nonce/timestamp check rejects replayed or stale requests. The configured replay window is 300 seconds.
- The service has no end-user authentication and must not be exposed as a public patient API.

---

## 4. Common protocol conventions

| Concern | Implemented convention |
|---|---|
| Character set | UTF-8 for JSON, forms, and generated CSV |
| Java pages | `text/html`; full-page forward or redirect |
| Java JSON | `application/json` |
| Payment JSON | `application/json`; request body limit 32 KB |
| AI JSON | `application/json` |
| Form posts | `application/x-www-form-urlencoded` unless multipart upload is required |
| Uploads | `multipart/form-data` for screening images, issue images, and AI package ZIPs |
| IDs | SQL entities use UUID/GUID strings; payment API validates invoice IDs as UUIDs |
| Dates | Java form dates use ISO `YYYY-MM-DD`; service timestamps serialize as runtime JSON dates |
| Money | Numeric VND values sourced from invoice rows; VNPay library handles provider scaling |

The platform does not expose `X-RateLimit-*` headers. AI screening has application-level permission/rate controls, but no repository-wide HTTP rate-limit header contract exists.

---

## 5. Machine-readable Java endpoints

### 5.1 Booking lookup JSON

`GET /DermAI/patient/booking?ajax=doctors&clinicId={uuid}`

- Auth: authenticated patient-side session.
- Response: JSON array of `{id, fullName, specialization}`.
- Missing/blank `clinicId`: empty array.

`GET /DermAI/patient/booking?ajax=slots&doctorId={uuid}&date={YYYY-MM-DD}`

- Auth: authenticated patient-side session.
- Response: JSON array with `slot`, `label`, `state`, `remaining`, `bookedCount`, and `maxPatients`.
- `state`: `available`, `booked`, or `disabled`.
- Invalid/missing inputs: empty array.

### 5.2 Notification unread count

`GET /DermAI/patient/notifications?format=count`

- Auth: patient session.
- Success: `{"unread": 3}`.
- Unauthenticated requests redirect to login; a non-patient principal receives `403`.

### 5.3 Admin dashboard JSON

`GET /DermAI/admin/api/dashboard`

- Auth: `ADMIN` session.
- Success fields: `activePatients`, `totalScans`, `avgConfidence`, `highRiskRatio`, `topDiseases`, `scansTrend`, `recentScans`, `unpaidInvoices`, `paidInvoices`, `successPayments`, `medicalReportsCompleted`.
- Each `recentScans` item contains `id`, `patientName`, `diseaseName`, `riskLevel`, `confidenceScore`, and `createdAt`.
- Current failure behavior: HTTP 200 with `error: "Failed to fetch dashboard data"`; consumers must check the `error` field.

### 5.4 Doctor report JSON

`GET /DermAI/doctor/api/reports-data`

- Auth: `DOCTOR` session.
- Success fields: `totalPatients`, `totalCompleted`, `avgConfidence`, `highRiskRatio`, `riskLevelDistribution`, `topDiseases`, and `appointmentsTrend`.
- Missing doctor profile: `404`.
- Current data-load failure behavior: HTTP 200 with an `error` field.

### 5.5 Medicine lookup JSON

`GET /DermAI/doctor/medicine/search?q={text}`

- Auth: verified doctor profile.
- A query shorter than two trimmed characters returns `{success:true, items:[]}`.
- Success: `{success:true, items:[...]}` using `MedicineDto` fields.
- No doctor profile: `403` with `{success:false,error:"Access denied. Doctor authentication required.",items:[]}`.
- Upstream medicine failure: `503`; unexpected failure: `500`.

### 5.6 Downloads and protected media

| Endpoint | Format | Notes |
|---|---|---|
| `GET /DermAI/admin/export/csv` | `text/csv` | Admin statistics; UTF-8 BOM; filename `DermAI_Report.csv` |
| `GET /DermAI/doctor/appointments/detail?id={uuid}&action=exportPdf` | PDF | Doctor appointment/medical report export |
| `GET /DermAI/reports/*` | Redirect/media | Authenticated, permission-checked signed diagnosis media delivery |

---

## 6. Java Servlet MVC route catalog

These routes normally return HTML or redirects. Their request parameters are form/view contracts, not a public REST schema.

| Area | Routes | Main behavior |
|---|---|---|
| Authentication | `/auth/login`, `/auth/register`, `/auth/verify`, `/auth/logout`, `/auth/forgot-password`, `/auth/reset-password`, `/auth/unlock-account` | Login, OTP, password recovery, lock recovery |
| Google OAuth | `/auth/google`, `/auth/google/callback`, `/auth/google/link` | OAuth start, callback, account link |
| Public | `/home`, `/global/clinics`, `/global/clinics/detail`, `/global/clinics/map` | Home and clinic discovery |
| Account | `/account/profile`, `/account/verify-old`, `/account/input-new`, `/account/verify-new` | Profile and OTP-protected credential changes |
| Patient screening | `/patient/diagnose`, `/patient/reports`, `/patient/reports/view` | Upload screening, list and view allowed results |
| Patient care | `/patient/booking`, `/patient/appointments`, `/patient/medical-records`, `/patient/family-members` | Booking and health-record workflows |
| Patient communication | `/patient/notifications`, `/patient/feedback`, `/patient/issue-report` | Notifications, ratings, support issues |
| Patient billing | `/patient/payment`, `/patient/invoice` | Java invoice/payment UI shell; Node owns VNPay processing |
| Doctor | `/doctor/dashboard`, `/doctor/appointments/detail`, `/doctor/appointments/history`, `/doctor/schedule`, `/doctor/reports`, `/doctor/guidelines`, `/doctor/issue-report` | Clinical queue, history, schedule, records, guidance, issues |
| Admin | `/admin/dashboard`, `/admin/audit-logs`, `/admin/audit-logs/detail`, `/admin/users`, `/admin/users/status`, `/admin/clinics`, `/admin/doctors`, `/admin/bookings/*`, `/admin/feedback`, `/admin/issue-reports`, `/admin/ai-results`, `/admin/ai-results/detail`, `/admin/ai-models` | Operations and governance |

Selected filters used by collection pages:

- Medical records: `person`, `search`, `sort=oldest|newest`, `fromDate`, `toDate`; detail uses `action=view&id={uuid}`.
- Doctor appointment history: `status`, `keyword`, `riskFilter`, `sortBy`, `page`.
- Admin bookings: `page`, `keyword`, `status`, `startDate`, `endDate`; detail uses `/admin/bookings/{id}`.
- Booking doctor search: `doctorName`, `fromDate`, `toDate`, `specialization`, `timeSlot`.

---

## 7. Payment API

### 7.1 Endpoint summary

| Method | Path | Auth | Success |
|---|---|---|---|
| GET | `/api/health` | None | `200 {"status":"ok"}`; also expires overdue pending payments |
| GET | `/api/invoices/{invoiceId}` | Demo bypass or future verified auth | `200` invoice DTO |
| POST | `/api/invoices/{invoiceId}/payments/vnpay` | Demo bypass or future verified auth | `201` new payment, `200` reused pending payment, or `303` for HTML clients |
| GET | `/api/payments/{txnRef}` | Demo bypass or future verified auth | `200` payment status DTO |
| GET | `/api/payments/vnpay/ipn` | VNPay signature | `200` VNPay acknowledgement |
| GET | `/payments/vnpay/return` | VNPay signature | `302` to the Java UI result page |

### 7.2 Invoice response

```json
{
  "invoiceId": "uuid",
  "appointmentId": "uuid",
  "requestId": "string",
  "patientName": "string",
  "clinicName": "string",
  "appointmentTime": "timestamp",
  "description": "string",
  "amount": 500000,
  "status": "UNPAID",
  "paidAt": null
}
```

### 7.3 Create or reuse VNPay payment

Optional JSON body: `{"locale":"en"}`. Any other value uses Vietnamese locale.

```json
{
  "paymentId": "uuid",
  "txnRef": "PAY-...",
  "status": "PENDING",
  "paymentUrl": "https://...",
  "expiresAt": "timestamp",
  "reused": false
}
```

If `Accept` includes `text/html`, the service returns `303 See Other` to `paymentUrl` instead of JSON.

### 7.4 Payment status response

```json
{
  "paymentId": "uuid",
  "txnRef": "PAY-...",
  "amount": 500000,
  "status": "PENDING",
  "method": "VNPAY",
  "expiresAt": "timestamp",
  "processedAt": null,
  "transactionNo": null,
  "invoiceId": "uuid",
  "invoiceStatus": "UNPAID",
  "paidAt": null
}
```

### 7.5 Payment errors and callback rules

Node errors use:

```json
{"error":"ERROR_CODE","message":"Safe client message"}
```

Known codes include `INVALID_ID`, `INVOICE_NOT_FOUND`, `INVOICE_NOT_PAYABLE`, `INVALID_INVOICE_AMOUNT`, `PAYMENT_NOT_FOUND`, `INVALID_VNPAY_SIGNATURE`, `MISSING_TRANSACTION_REFERENCE`, `PAYMENT_CONFIGURATION_ERROR`, `AUTH_INTEGRATION_REQUIRED`, and `INTERNAL_SERVER_ERROR`.

VNPay IPN acknowledgements use `{RspCode, Message}`. Implemented codes include `00` success, `01` order not found/expired, `02` already confirmed, `04` invalid amount, and `97` invalid checksum.

The IPN path is the production payment-state authority. `VNP_PROCESS_RETURN=true` enables idempotent Return processing only as a local/sandbox fallback.

---

## 8. AI inference API

### 8.1 Health

`GET /health`

- Ready: `200 {"status":"ready","service":"skin-screening"}`.
- Runtime unhealthy: `503` FastAPI error detail.

### 8.2 Validate model package

`POST /internal/packages/validate`

Headers: `X-AI-Service-Key`.

```json
{"packageDirectory":"C:\\path\\under\\AI_MODELS_ROOT"}
```

Success: `{"status":"valid","version":"...","package_version":"..."}`.

- `400`: directory escapes `AI_MODELS_ROOT`.
- `401`: invalid/missing service key.
- `422`: package metadata/files fail validation.

### 8.3 Invalidate active runtime

`POST /internal/packages/invalidate`

Headers: `X-AI-Service-Key`.

Success: `{"status":"invalidated"}`.

### 8.4 Run screening

`POST /internal/screenings`

Headers: `X-AI-Service-Key`, `X-AI-Request-Nonce`, `X-AI-Request-Timestamp`.

```json
{
  "attemptId": "uuid-or-ledger-id",
  "inputSha256": "lowercase-sha256-hex",
  "imageBase64": "base64-normalized-image"
}
```

Accepted response:

```json
{
  "accepted": true,
  "attemptId": "...",
  "inputSha256": "...",
  "modelReleaseId": "...",
  "canonicalClassCode": "...",
  "top1Confidence": 0.93,
  "eigencamBase64": "...",
  "latencyMs": 125
}
```

Rejected model result still returns `200` and includes `accepted:false`, `rejectionCode`, and `latencyMs`. Implemented rejection codes include package quality codes plus `UNKNOWN_CLASS`, `OUT_OF_DISTRIBUTION`, and `LOW_CONFIDENCE`.

- `400`: invalid Base64, hash mismatch, missing/invalid auth headers, stale timestamp, or replayed nonce.
- `422`: bytes do not decode as a normalized image.
- `503`: runtime/inference unavailable.

The Java service owns Cloudinary and database persistence. FastAPI returns inference data only.

---

## 9. Upload interfaces

| Route | Media | Key validation |
|---|---|---|
| `POST /DermAI/patient/diagnose` | Skin image | Auth, CSRF, type/size checks, normalization, permission/rate controls |
| `POST /DermAI/patient/issue-report` and `/doctor/issue-report` | Optional issue image | Auth, CSRF, form validation, upload checks |
| `POST /DermAI/admin/ai-models` | AI package ZIP | Admin auth, CSRF, multipart handling, package validation before activation |

Do not send code screenshots or embed public diagnosis-media URLs. Diagnosis media is private and delivered through permission-checked signed access.

---

## 10. Pagination, filtering, and sorting

There is no platform-wide REST pagination envelope. Servlet collection screens use page/query parameters and render HTML. DAO/controller-specific conventions apply:

- Page numbering is generally one-based (`page=1`).
- Filter names are endpoint-specific; see the Java route catalog above.
- Sorting is explicit per page (for example `sort=oldest|newest`), not a global `sort=-createdAt` contract.
- JSON dashboard and lookup endpoints return bounded/full arrays without pagination metadata.

---

## 11. Integration examples

Health checks:

```bash
curl http://localhost:3000/api/health
curl http://127.0.0.1:8000/health
```

Create a payment in local demo mode:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"locale":"en"}' \
  http://localhost:3000/api/invoices/00000000-0000-0000-0000-000000000000/payments/vnpay
```

Invalidate the AI runtime after model activation:

```bash
curl -X POST \
  -H "X-AI-Service-Key: $AI_SERVICE_API_KEY" \
  http://127.0.0.1:8000/internal/packages/invalidate
```

---

## 12. Known gaps and maintenance checklist

### Known gaps

- Payment requester authentication is not integrated outside demo mode; protected payment routes return `501` when demo mode is off.
- No OpenAPI document is published for the Java or Node surfaces. FastAPI interactive docs are disabled.
- No global `/v1` version namespace exists.
- Java JSON error shapes are endpoint-specific; only Node payment errors have a consistent `{error,message}` envelope.
- Dashboard JSON endpoints currently return an `error` field with HTTP 200 for some internal failures.

### Update this file when

- `web.xml`, `payment-service/server.js`, or `ai-service/app/routes.py` changes.
- A controller adds/removes a JSON, file, media, callback, or multipart contract.
- Authentication, CSRF, role mapping, base URLs, headers, or response DTO fields change.
- Payment/AI configuration or ownership boundaries change.

Keep examples free of real secrets, patient data, valid invoice IDs, and production callback payloads.
