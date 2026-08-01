"""FastAPI entry — wire config, runtime, auth, and routes."""

from __future__ import annotations

from app.auth import InternalAuth
from app.config import load_settings
from app.package_runtime import ActivePackageRuntime
from app.routes import build_router
from fastapi import FastAPI


def create_app() -> FastAPI:
    settings = load_settings()
    runtime = ActivePackageRuntime(settings)
    auth = InternalAuth(settings.api_key)
    app = FastAPI(title="DermAI Private Screening Service", docs_url=None, redoc_url=None)
    app.include_router(build_router(settings, runtime, auth))
    return app


app = create_app()
