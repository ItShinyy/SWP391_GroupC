# SkinAI (Derma)

AI-assisted dermatology screening web app: patients screen and book care; doctors review AI results and document visits; admins operate users, clinics, and models.

## Technologies

| Layer | Stack |
|-------|--------|
| Web | Java 17, Jakarta Servlet/JSP, Tomcat 10+, Maven WAR |
| Data | SQL Server (`SWP391`), HikariCP |
| AI | FastAPI + ONNX (`SkinAI/ai-service`) |
| Payments | Node Express + VNPay (`SkinAI/payment-service`) |
| Media | Cloudinary |
| Edge (optional) | Nginx (`SkinAI/nginx`) |

## Architecture (summary)

```text
Browser → (Nginx) → Tomcat/SkinAI → SQL Server
                  ↘ FastAPI (screenings)
                  ↘ Cloudinary (media)
                  ↘ Node payment-service → VNPay → SQL Server
```

Java owns invoices and product UI. Node owns VNPay create/Return/IPN/expiry. FastAPI owns inference only.  
Details: [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md).

## Quick start

1. JDK 17, Maven, Tomcat 10.1+, SQL Server, Python 3.11+ (AI), Node 18+ (payments).  
2. Copy `SkinAI/local.properties.example` → `SkinAI/local.properties` (gitignored). Set DB, `APP_BASE_URL`, Google, mail, Cloudinary, AI keys.  
3. Deploy DB: wipe → deploy → seed scripts under `SkinAI/src/main/resources/database/`.  
4. `mvn -f SkinAI/pom.xml package` → deploy WAR to Tomcat (often `http://localhost:9999/SkinAI`).  
5. Optional: `ai-service` uvicorn `:8000` with matching `.env.local`; `payment-service` `:3000` + Nginx for `/api` payment routes.  
6. Disable AI with `AI_SERVICE_ENABLED=false` if inference is not running.

Never commit secrets (`.env.local`, `local.properties`).

## Project structure

```text
Derma/
├── Docs/                 ARCHITECTURE, DESIGN, PRD, RULES, SCHEMA
├── SkinAI/               Java WAR + webapp
│   ├── ai-service/       FastAPI ONNX
│   ├── payment-service/  VNPay Node API
│   ├── nginx/            Sample reverse proxy
│   └── src/main/
│       ├── java/…        Controllers, services, DAOs, filters
│       ├── resources/    application.properties, database/
│       └── webapp/       JSP, assets
└── .specify/             Spec Kit + constitution
```

## Documentation

| Doc | Contents |
|-----|----------|
| [ARCHITECTURE.md](Docs/ARCHITECTURE.md) | Components, MVC, auth, AI, payments, config |
| [DESIGN.md](Docs/DESIGN.md) | UI/UX, workflows, validation, security design |
| [PRD.md](Docs/PRD.md) | Product requirements reverse-engineered from code |
| [RULES.md](Docs/RULES.md) | Engineering conventions + ADR digest |
| [SCHEMA.md](Docs/SCHEMA.md) | Database ER, tables, enums, lifecycles |

Engineering constitution: [`.specify/memory/constitution.md`](.specify/memory/constitution.md).

## License

Proprietary / course project — all rights reserved unless otherwise stated by the project owners.
