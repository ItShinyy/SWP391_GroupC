"""API authentication for internal DermAI screening endpoints."""

from __future__ import annotations

import hmac
import time

from fastapi import HTTPException


class InternalAuth:
    def __init__(self, api_key: str) -> None:
        self._api_key = api_key
        self._nonce_cache: dict[str, float] = {}

    def authorize_key_only(self, provided_key: str | None) -> None:
        if not provided_key or not hmac.compare_digest(provided_key, self._api_key):
            raise HTTPException(status_code=401, detail="invalid internal authentication")

    def authorize(self, provided_key: str | None, nonce: str | None, timestamp: str | None) -> None:
        self.authorize_key_only(provided_key)
        if not nonce or not timestamp:
            raise HTTPException(status_code=400, detail="missing request replay protection")
        now = time.time()
        try:
            request_time = float(timestamp)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail="invalid request timestamp") from exc
        if abs(now - request_time) > 300 or nonce in self._nonce_cache:
            raise HTTPException(status_code=401, detail="expired or replayed request")
        self._nonce_cache[nonce] = now
        for cached_nonce, created_at in list(self._nonce_cache.items()):
            if now - created_at > 300:
                del self._nonce_cache[cached_nonce]
