# DermAI — Engineering Rules

Conventions enforced by constitution, code review, and this repo’s history.  
Companion: [ARCHITECTURE.md](ARCHITECTURE.md) · [PRD.md](PRD.md) · [SCHEMA.md](SCHEMA.md) · [API_REFERENCE.md](API_REFERENCE.md)  
Formal Spec Kit SoT: [`.specify/memory/constitution.md`](../.specify/memory/constitution.md)

---

## 1. Architecture

| Rule | Practice |
|------|----------|
| MVC | Controllers thin; JSP render; no business logic in views |
| Service layer | Rules, transactions, external calls live in `service` |
| DAO | JDBC/`DBContext` only; return entities/DTOs; no KPI math |
| DTO / model | Prefer typed `model` classes over `Map`/`Object` bags |
| One SoT per concern | Java owns invoices; Node owns VNPay; FastAPI owns ONNX |
| No parallel stacks | Do not reintroduce Java VNPay helpers or Firebase diagnosis media |

Package/URL boundaries: [ARCHITECTURE.md](ARCHITECTURE.md) §3–4.

---

## 2. Coding (Ponytail Ultra)

| Rule | Meaning |
|------|---------|
| YAGNI | Don’t build unrequested features or speculative abstractions |
| KISS | Boring, readable, shortest working path |
| DRY | Fix shared helpers once; don’t copy-paste guards |
| Fail closed | Missing config / auth / CSRF → deny |
| Least privilege | Role + permission gates; private media by default |
| Single responsibility | One class/one job; split only when needed |
| Reuse over rewrite | Prefer existing `AppConfig`, `DBContext`, booking/billing patterns |
| Delete over abstraction | Remove dead code; don’t wrap it |
| Small diffs | Minimal files touched; no drive-by refactors |
| No parallel implementations | One payment path, one AI media path, one auth session model |

Mark deliberate shortcuts with `ponytail:` comments (ceiling + upgrade path).

**Lombok:** IDE “cannot resolve” noise is ignored; do not “fix” Lombok recognition.

---

## 3. Security

| Area | Rule |
|------|------|
| Authentication | Session `user`; ACTIVE only; password change awareness via `passwordChangedAt` |
| Authorization | Path prefix by role; AI/media via `PermissionService` |
| Input validation | Server-side at controllers/services; never trust client JS alone |
| Secret management | Never commit `local.properties`, `.env.local`, API keys, VNPay hash |
| Session | 30 min timeout; invalidate on logout; CSRF token in session |
| CSRF | Required on mutating methods for protected prefixes |
| OTP | Hashed storage; purpose-scoped (`RESET_PASSWORD`, unlock, email verify, profile change); TTL + attempt limits |
| AI trust boundary | FastAPI key + nonce/timestamp; Java persists results; AI service has no DB/Cloudinary |
| Media | Diagnosis: authenticated Cloudinary + signed `/reports/*`; issue images may be public URLs |

---

## 4. Database

| Rule | Practice |
|------|----------|
| Naming | `snake_case` tables/columns; `CHK_` / `UQ_` / `PK_` / `FK_` prefixes |
| Transactions | Service/DAO patterns already used in booking/billing; keep consistent |
| Foreign keys | Prefer FKs; note intentional gaps (e.g. `appointments.slot_id` indexed, **no FK**) |
| Soft delete | **None** product-wide; use status/`is_active` flags where present |
| Baseline-first | Edit `02_Tables` / constraints / SPs / seeds in place; **never** add new `08_Migrations/V*.sql` for day-to-day work |
| Rebuild | Wipe → Deploy → Seed for local schema changes |
| Wipe retention | Wipe scripts may **keep** `ai_models`, `clinical_policy_entries`, `ai_screening_attempts` — verify `WipeData.sql` before assuming wipe clears AI history |

Details: [SCHEMA.md](SCHEMA.md).

---

## 5. Documentation

1. Docs must match **implementation**; if they conflict, fix the docs (or note discrepancy).  
2. Do not document unused/dead code as if live.  
3. Cross-link; don’t duplicate long explanations across `ARCHITECTURE` / `DESIGN` / `PRD` / `SCHEMA`.  
4. Record durable decisions below (ADR digest). Spec Kit features live under `.specify/`.  
5. When uncertain: write **Implementation not found** — never invent APIs.

---

## 6. ADR digest (accepted decisions)

Former `Docs/DECISIONS.md` content folded here. Status reflects current code.

| ADR | Status | Decision |
|-----|--------|----------|
| ADR-001 | Accepted | Hybrid coverage + cleanup-first |
| ADR-002 | Accepted | Cloudinary over Firebase for diagnosis media |
| ADR-003 | Accepted | Flat `ai_models` (no versioned config table sprawl) |
| ADR-004 | Accepted | Inventory out of scope |
| ADR-005 | Superseded | “AI_CONTEXT is SoT” → replaced by this Docs set + constitution |
| ADR-006 | Planned / partial | Appointment lifecycle centralization — not fully centralized |
| ADR-007 | Accepted | Notification DB outbox + drain job |
| ADR-008 | Accepted | Clinic fees via config for billing amounts |
| ADR-009 | Accepted | Preserve appointment/doctor/patient coding patterns |
| ADR-010 | Accepted | Medical report finalize additive; drives completion/rating |
| ADR-011 | Superseded | Java was VNPay SoT — **do not restore** |
| **ADR-012** | **Accepted** | **Node `payment-service` owns VNPay create/Return/IPN/expire; Java owns invoice create/read/cancel** |

---

## 7. Spec Kit workflow

Non-trivial features: constitution → specify → plan → tasks → implement (clarify/analyze as needed). Chat plans are temporary.

---

## 8. Contributor checklist

- [ ] Change fits YAGNI / existing pattern  
- [ ] Secrets stay gitignored  
- [ ] AuthZ fail closed  
- [ ] Schema change is baseline edit (not new migration file)  
- [ ] Touched Docs updated if behavior changed  
- [ ] No second payment or AI media implementation  
