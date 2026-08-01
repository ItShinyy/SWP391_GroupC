"""HTTP endpoints — orchestrate only; no ML or package I/O logic."""

from __future__ import annotations

import base64
import hashlib
import hmac
import logging
from pathlib import Path

import cv2
import numpy as np
from app.auth import InternalAuth
from app.config import Settings
from app.package_runtime import ActivePackageRuntime, load_package
from app import screening_service
from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel, ValidationError

logger = logging.getLogger("dermai.operations")


class ValidateRequest(BaseModel):
    packageDirectory: str


class ScreeningRequest(BaseModel):
    attemptId: str
    inputSha256: str
    imageBase64: str


def build_router(settings: Settings, runtime: ActivePackageRuntime, auth: InternalAuth) -> APIRouter:
    router = APIRouter()

    @router.get("/health")
    async def health() -> dict[str, str]:
        if not runtime.healthy():
            raise HTTPException(status_code=503, detail="inference service unavailable")
        return {"status": "ready", "service": "skin-screening"}

    @router.post("/internal/packages/validate")
    async def validate_package(
        payload: ValidateRequest,
        x_ai_service_key: str | None = Header(default=None),
    ) -> dict[str, str]:
        auth.authorize_key_only(x_ai_service_key)
        package_dir = Path(payload.packageDirectory).resolve()
        if settings.models_root not in package_dir.parents and package_dir != settings.models_root:
            raise HTTPException(status_code=400, detail="package directory escapes AI_MODELS_ROOT")
        try:
            metadata, *_ = load_package(package_dir)
        except (OSError, ValueError, ValidationError, RuntimeError) as exc:
            raise HTTPException(status_code=422, detail=str(exc)) from exc
        return {"status": "valid", "version": metadata.version, "package_version": metadata.package_version}

    @router.post("/internal/packages/invalidate")
    async def invalidate_active(x_ai_service_key: str | None = Header(default=None)) -> dict[str, str]:
        auth.authorize_key_only(x_ai_service_key)
        runtime.invalidate()
        return {"status": "invalidated"}

    @router.post("/internal/screenings")
    async def screening(
        payload: ScreeningRequest,
        x_ai_service_key: str | None = Header(default=None),
        x_ai_request_nonce: str | None = Header(default=None),
        x_ai_request_timestamp: str | None = Header(default=None),
    ) -> dict:
        auth.authorize(x_ai_service_key, x_ai_request_nonce, x_ai_request_timestamp)
        try:
            raw = base64.b64decode(payload.imageBase64, validate=True)
        except (ValueError, TypeError) as exc:
            raise HTTPException(status_code=400, detail="invalid imageBase64") from exc
        if not raw or len(raw) > settings.max_input_bytes or not hmac.compare_digest(
            hashlib.sha256(raw).hexdigest(), payload.inputSha256
        ):
            raise HTTPException(status_code=400, detail="input content hash mismatch")
        decoded = cv2.imdecode(np.frombuffer(raw, dtype=np.uint8), cv2.IMREAD_COLOR)
        if decoded is None:
            raise HTTPException(status_code=422, detail="invalid normalized image")
        try:
            result = screening_service.screen(runtime, decoded, payload.attemptId, payload.inputSha256)
        except (RuntimeError, ValueError, OSError) as exc:
            raise HTTPException(status_code=503, detail="inference service unavailable") from exc
        logger.info(
            "metric=dermai_screening latency_ms=%s outcome=%s rejection=%s",
            result.get("latencyMs"),
            "accepted" if result.get("accepted") else "rejected",
            result.get("rejectionCode") or "none",
        )
        return result

    return router
