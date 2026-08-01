"""Active model package lifecycle under AI_MODELS_ROOT."""

from __future__ import annotations

import json
import logging
import threading
from pathlib import Path
from typing import Any

import numpy as np
from app.config import Settings
from app.onnx_backend import (
    IMAGE_SIZE,
    OnnxClassifierSession,
    classification_tensor,
)
from pydantic import BaseModel, Field, field_validator

SUPPORTED_PACKAGE_VERSION = "1"
SUPPORTED_CLASS_CODES = {"ACNE", "CHICKENPOX", "ECZEMA", "RINGWORM"}
REQUIRED_FILES = ("model.onnx", "labels.json", "reference_features.npz", "metadata.json")
logger = logging.getLogger("dermai.operations")


class QualityConfig(BaseModel):
    model_config = {"extra": "forbid"}
    minWidth: int = Field(ge=1, le=8192)
    minHeight: int = Field(ge=1, le=8192)
    minBlurVariance: float = Field(ge=0.0)
    minBrightness: float = Field(ge=0.0, le=255.0)
    maxBrightness: float = Field(ge=0.0, le=255.0)
    minSkinRatio: float = Field(ge=0.0, le=1.0)

    @field_validator("maxBrightness")
    @classmethod
    def brightness_range_is_valid(cls, value: float, info) -> float:
        minimum = info.data.get("minBrightness")
        if minimum is not None and value < minimum:
            raise ValueError("maximum brightness cannot be below minimum brightness")
        return value


class PackageMetadata(BaseModel):
    """Package-specific knobs only. Engineering constants live in onnx_backend."""

    model_config = {"extra": "ignore"}
    package_version: str
    name: str = "DermAI"
    version: str
    confidence_threshold: float = Field(ge=0.90, le=1.0)
    quality: QualityConfig


def assert_package_files(root: Path) -> dict[str, Path]:
    paths = {name: root / name for name in REQUIRED_FILES}
    missing = [name for name, path in paths.items() if not path.is_file()]
    if missing:
        raise ValueError(f"package missing required files: {', '.join(missing)}")
    return paths


def load_label_map(path: Path, class_names: tuple[str, ...]) -> dict[str, str]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("labels.json must be an object mapping class name to disease code")
    if set(value.keys()) != set(class_names):
        raise ValueError("labels.json keys must match ONNX class_names exactly")
    codes = set(value.values())
    if codes != SUPPORTED_CLASS_CODES or len(value) != len(SUPPORTED_CLASS_CODES):
        raise ValueError("labels.json must map to exactly ACNE, CHICKENPOX, ECZEMA, RINGWORM")
    return {str(k): str(v) for k, v in value.items()}


def load_ood(path: Path, embedding_dim: int) -> dict[str, Any]:
    with np.load(path) as data:
        if "mean_vector" not in data or "threshold" not in data:
            raise ValueError("reference_features.npz must contain mean_vector and threshold")
        mean = np.asarray(data["mean_vector"], dtype=np.float32)
        if mean.ndim != 1 or mean.shape[0] != embedding_dim:
            raise ValueError("reference_features.npz mean_vector is incompatible with the ONNX embedding")
        return {"mean_vector": mean, "threshold": float(data["threshold"])}


def load_package(root: Path) -> tuple[PackageMetadata, OnnxClassifierSession, dict[str, str], dict[str, Any]]:
    paths = assert_package_files(root)
    raw = json.loads(paths["metadata.json"].read_text(encoding="utf-8"))
    metadata = PackageMetadata.model_validate(raw)
    if metadata.package_version != SUPPORTED_PACKAGE_VERSION:
        raise ValueError(f"unsupported package_version: {metadata.package_version}")
    session = OnnxClassifierSession(paths["model.onnx"])
    labels = load_label_map(paths["labels.json"], session.class_names)
    zero = classification_tensor(np.zeros((IMAGE_SIZE, IMAGE_SIZE, 3), dtype=np.uint8))
    outputs = session.run(zero)
    ood = load_ood(paths["reference_features.npz"], outputs.embedding.shape[0])
    return metadata, session, labels, ood


class ActivePackageRuntime:
    def __init__(self, settings: Settings) -> None:
        self.models_root = settings.models_root
        self.active_dir = self.models_root / "active"
        self.lock = threading.Semaphore(settings.max_ai_concurrency)
        self._reload_lock = threading.Lock()
        self._stale = True
        self.metadata: PackageMetadata | None = None
        self.session: OnnxClassifierSession | None = None
        self.labels: dict[str, str] | None = None
        self.ood: dict[str, Any] | None = None
        try:
            self.ensure_loaded()
        except Exception as exc:
            logger.warning("active package not loaded at startup: %s", exc)

    def invalidate(self) -> None:
        with self._reload_lock:
            self._stale = True

    def ensure_loaded(self) -> None:
        with self._reload_lock:
            if not self._stale and self.session is not None and self.metadata is not None:
                return
            metadata, session, labels, ood = load_package(self.active_dir)
            self.metadata = metadata
            self.session = session
            self.labels = labels
            self.ood = ood
            self._stale = False

    def healthy(self) -> bool:
        try:
            self.ensure_loaded()
            return True
        except Exception:
            return False
