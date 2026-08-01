"""Sole configuration source for the private screening service."""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


def load_dotenv_local() -> None:
    """Load ai-service/.env.local into os.environ without adding a dotenv dependency."""
    path = Path(__file__).resolve().parent.parent / ".env.local"
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        if key and key not in os.environ:
            os.environ[key] = value.strip()


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"missing required environment variable: {name}")
    return value


def resolve_models_root() -> Path:
    env_val = os.getenv("AI_MODELS_ROOT")
    if env_val:
        p = Path(env_val).resolve()
        if p.is_dir() and ((p / "active").exists() or (p / "models").exists()):
            return p

    base_dir = Path(__file__).resolve().parent.parent
    home = Path.home()
    candidates = [
        Path("D:/DemAI-private-artifacts/DemAI-private-artifacts"),
        Path("D:/DemAI-private-artifacts"),
        Path("D:/DermAI-private-artifacts/DermAI-private-artifacts"),
        Path("D:/DermAI-private-artifacts"),
        Path("C:/DemAI-private-artifacts/DemAI-private-artifacts"),
        Path("C:/DemAI-private-artifacts"),
        Path("C:/DermAI-private-artifacts/DermAI-private-artifacts"),
        Path("C:/DermAI-private-artifacts"),
        base_dir / "private-artifacts",
        base_dir.parent / "private-artifacts",
        home / "Downloads" / "DemAI-private-artifacts" / "DemAI-private-artifacts",
        home / "Downloads" / "DemAI-private-artifacts",
        home / "Downloads" / "DermAI-private-artifacts" / "DermAI-private-artifacts",
        home / "Downloads" / "DermAI-private-artifacts",
    ]

    for candidate in candidates:
        if candidate.is_dir() and ((candidate / "active").exists() or (candidate / "models").exists() or (candidate / "release-registry.json").exists()):
            return candidate.resolve()

    if env_val:
        return Path(env_val).resolve()
    raise RuntimeError("Missing or unlocatable AI_MODELS_ROOT. Please specify valid directory.")


@dataclass(frozen=True)
class Settings:
    api_key: str
    models_root: Path
    max_input_bytes: int
    max_ai_concurrency: int


def load_settings() -> Settings:
    load_dotenv_local()
    max_concurrency = int(require_env("HARD_MAX_AI_CONCURRENCY"))
    if max_concurrency < 1:
        raise RuntimeError("HARD_MAX_AI_CONCURRENCY must be at least one")
    max_bytes = int(require_env("AI_MAX_INPUT_BYTES"))
    if max_bytes < 1:
        raise RuntimeError("AI_MAX_INPUT_BYTES must be at least one")
    return Settings(
        api_key=require_env("AI_SERVICE_API_KEY"),
        models_root=resolve_models_root(),
        max_input_bytes=max_bytes,
        max_ai_concurrency=max_concurrency,
    )
