# Private DermAI ONNX inference (FastAPI + uvicorn)

Secrets: copy `.env.local.example` → `.env.local`. Java uses `SkinAI/local.properties` — do not put DB/Cloudinary here.

## Run (host Python)

```powershell
cd SkinAI\ai-service
copy .env.local.example .env.local
# Edit AI_SERVICE_API_KEY (match Java) and AI_MODELS_ROOT (host path with active/)

py -3.11 -m pip install -r requirements.txt
py -3.11 -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Required env (all fail-closed at startup): `AI_SERVICE_API_KEY`, `AI_MODELS_ROOT`, `AI_MAX_INPUT_BYTES`, `HARD_MAX_AI_CONCURRENCY`.

Health: `GET http://127.0.0.1:8000/health`

Admin package activate/deactivate calls `POST /internal/packages/invalidate` so the next screening reloads the active package once.

Offline model export (Torch → ONNX package): `exporter/` + `requirements-export.txt`. Zip builder: `scripts/build-model-package.ps1`.

## Module ownership

| Module | Responsibility |
|--------|----------------|
| `main` | FastAPI entry (`uvicorn app.main:app`) |
| `routes` | HTTP endpoints only |
| `config` | Sole configuration source (`.env.local` + required env) |
| `auth` | Internal API key + screening nonce/timestamp |
| `package_runtime` | Active model lifecycle under `AI_MODELS_ROOT` |
| `screening_service` | Request orchestration (business flow) |
| `onnx_backend` | ML implementation (session, preprocess, OOD, EigenCAM, quality metrics) |

## Dependency graph

```text
main
│
├── routes
│
├── config
│
├── auth
│
├── package_runtime
│
└── screening_service
        │
        └── onnx_backend
```

Rules: `routes` orchestrates only; `screening_service` owns flow; `onnx_backend` owns ML; `config` is the only config source; `exporter` depends only on `onnx_backend` (never runtime modules).
