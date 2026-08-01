"""Screening request orchestration — business flow only; ML lives in onnx_backend."""

from __future__ import annotations

import base64
import time
from typing import Any

import cv2
import numpy as np
from app.onnx_backend import (
    assess_quality,
    classification_tensor,
    eigencam_png,
    eigencam_tensor,
    ood_cosine,
    probabilities,
)
from app.package_runtime import SUPPORTED_CLASS_CODES, ActivePackageRuntime


def screen(runtime: ActivePackageRuntime, image_bgr: np.ndarray, attempt_id: str, input_sha256: str) -> dict[str, Any]:
    runtime.ensure_loaded()
    assert runtime.metadata and runtime.session and runtime.labels and runtime.ood
    start = time.perf_counter()
    quality = assess_quality(image_bgr, runtime.metadata.quality)
    base: dict[str, Any] = {
        "accepted": False,
        "attemptId": attempt_id,
        "inputSha256": input_sha256,
        "modelReleaseId": runtime.metadata.version,
    }
    if not quality["passed"]:
        return _reject(base, quality["code"], start)

    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    with runtime.lock:
        result = runtime.session.run(classification_tensor(image_rgb))
    class_probabilities = probabilities(result.logits)
    top_index = int(np.argmax(class_probabilities))
    raw_label = runtime.session.class_names[top_index]
    canonical_code = runtime.labels.get(raw_label)
    if canonical_code not in SUPPORTED_CLASS_CODES:
        return _reject(base, "UNKNOWN_CLASS", start)
    confidence = float(class_probabilities[top_index])
    base["canonicalClassCode"] = canonical_code
    base["top1Confidence"] = confidence

    ood_score = ood_cosine(result.embedding, runtime.ood["mean_vector"])
    if ood_score < runtime.ood["threshold"]:
        return _reject(base, "OUT_OF_DISTRIBUTION", start)
    if confidence < runtime.metadata.confidence_threshold:
        return _reject(base, "LOW_CONFIDENCE", start)

    with runtime.lock:
        explanation = runtime.session.run(eigencam_tensor(image_rgb))
    heatmap = eigencam_png(explanation.feature_map, image_rgb)
    base["accepted"] = True
    base["eigencamBase64"] = base64.b64encode(heatmap).decode("ascii")
    base["latencyMs"] = _elapsed_ms(start)
    return base


def _reject(base: dict[str, Any], code: str, started: float) -> dict[str, Any]:
    base.update({"accepted": False, "rejectionCode": code, "latencyMs": _elapsed_ms(started)})
    return base


def _elapsed_ms(started: float) -> int:
    return round((time.perf_counter() - started) * 1000)
