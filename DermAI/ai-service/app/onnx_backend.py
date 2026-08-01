"""ONNX-only inference primitives for the private screening service."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import cv2
import numpy as np
import onnxruntime as ort


INPUT_NAME = "images"
OUTPUT_NAMES = ("logits", "embedding", "feature_map")
PREPROCESSING_VERSION = "normalized-jpeg-v1"
EIGENCAM_VERSION = "eigencam-v1"
IMAGE_SIZE = 224  # engineering constant — ONNX contract


@dataclass(frozen=True)
class InferenceOutputs:
    logits: np.ndarray
    embedding: np.ndarray
    feature_map: np.ndarray


class OnnxClassifierSession:
    """CPU-only ONNX session with the frozen three-output contract."""

    def __init__(self, model_path: Path) -> None:
        options = ort.SessionOptions()
        options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        options.log_severity_level = 3
        self._session = ort.InferenceSession(
            str(model_path), sess_options=options, providers=["CPUExecutionProvider"]
        )
        if self._session.get_providers() != ["CPUExecutionProvider"]:
            raise RuntimeError("ONNX release did not initialize with the approved CPU provider")

        inputs = self._session.get_inputs()
        if len(inputs) != 1 or inputs[0].name != INPUT_NAME or inputs[0].type != "tensor(float)":
            raise RuntimeError("ONNX release has an invalid input contract")
        if list(inputs[0].shape) != [1, 3, IMAGE_SIZE, IMAGE_SIZE]:
            raise RuntimeError("ONNX release must use a fixed [1,3,224,224] input")

        outputs = self._session.get_outputs()
        if tuple(output.name for output in outputs) != OUTPUT_NAMES:
            raise RuntimeError("ONNX release has an invalid output contract")
        metadata = self._session.get_modelmeta().custom_metadata_map
        try:
            class_names = json.loads(metadata["class_names"])
        except (KeyError, TypeError, json.JSONDecodeError) as exc:
            raise RuntimeError("ONNX release is missing its immutable class order") from exc
        if not isinstance(class_names, list) or not class_names or any(not isinstance(value, str) for value in class_names):
            raise RuntimeError("ONNX release contains an invalid class order")
        self.class_names = tuple(class_names)

    def run(self, tensor: np.ndarray) -> InferenceOutputs:
        if tensor.shape != (1, 3, IMAGE_SIZE, IMAGE_SIZE) or tensor.dtype != np.float32:
            raise ValueError("model input does not match the approved ONNX contract")
        values = self._session.run(list(OUTPUT_NAMES), {INPUT_NAME: tensor})
        if any(not np.isfinite(value).all() for value in values):
            raise RuntimeError("ONNX release emitted NaN or infinite values")
        logits, embedding, feature_map = (np.asarray(value, dtype=np.float32) for value in values)
        if logits.shape != (1, len(self.class_names)) or embedding.ndim != 2 or embedding.shape[0] != 1:
            raise RuntimeError("ONNX release emitted invalid classification tensors")
        if feature_map.ndim != 4 or feature_map.shape[0] != 1:
            raise RuntimeError("ONNX release emitted an invalid EigenCAM feature map")
        return InferenceOutputs(logits=logits[0], embedding=embedding[0], feature_map=feature_map[0])


def classification_tensor(image_rgb: np.ndarray) -> np.ndarray:
    """Legacy YOLO classify preprocess (double color swap + letterbox crop)."""
    legacy_pixels = cv2.cvtColor(image_rgb, cv2.COLOR_BGR2RGB)
    height, width = legacy_pixels.shape[:2]
    if height < 1 or width < 1:
        raise ValueError("image has invalid dimensions")
    if height < width:
        resized_height = IMAGE_SIZE
        resized_width = int(IMAGE_SIZE * width / height)
    else:
        resized_width = IMAGE_SIZE
        resized_height = int(IMAGE_SIZE * height / width)
    resized = cv2.resize(legacy_pixels, (resized_width, resized_height), interpolation=cv2.INTER_LINEAR)
    top = max(int(round((resized_height - IMAGE_SIZE) / 2.0)), 0)
    left = max(int(round((resized_width - IMAGE_SIZE) / 2.0)), 0)
    cropped = resized[top : top + IMAGE_SIZE, left : left + IMAGE_SIZE]
    if cropped.shape[:2] != (IMAGE_SIZE, IMAGE_SIZE):
        raise RuntimeError("classification preprocessing produced an invalid shape")
    return _to_nchw_float(cropped)


def eigencam_tensor(image_rgb: np.ndarray) -> np.ndarray:
    resized = cv2.resize(image_rgb, (IMAGE_SIZE, IMAGE_SIZE), interpolation=cv2.INTER_LINEAR)
    return _to_nchw_float(resized)


def probabilities(logits: np.ndarray) -> np.ndarray:
    shifted = logits.astype(np.float64) - float(np.max(logits))
    exponentials = np.exp(shifted)
    result = exponentials / np.sum(exponentials)
    return result.astype(np.float32)


def eigencam_png(feature_map: np.ndarray, image_rgb: np.ndarray) -> bytes:
    heatmap = eigencam_heatmap(feature_map)
    resized = cv2.resize(heatmap, (image_rgb.shape[1], image_rgb.shape[0]))
    colors = cv2.applyColorMap(np.uint8(255 * resized), cv2.COLORMAP_JET)
    overlay = cv2.addWeighted(cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR), 0.6, colors, 0.4, 0)
    ok, encoded = cv2.imencode(".png", overlay)
    if not ok:
        raise RuntimeError("unable to encode EigenCAM")
    return encoded.tobytes()


def eigencam_heatmap(feature_map: np.ndarray) -> np.ndarray:
    channels, height, width = feature_map.shape
    flattened = feature_map.reshape(channels, -1).T
    flattened = flattened - flattened.mean(axis=0, keepdims=True)
    _, _, vectors = np.linalg.svd(flattened, full_matrices=False)
    heatmap = np.matmul(flattened, vectors[0, :]).reshape(height, width)
    heatmap = np.maximum(heatmap, 0)
    minimum, maximum = float(heatmap.min()), float(heatmap.max())
    if maximum - minimum > 1e-8:
        heatmap = (heatmap - minimum) / (maximum - minimum)
    else:
        heatmap = np.zeros_like(heatmap)
    return heatmap.astype(np.float32)


def ood_cosine(feature: np.ndarray, mean_vector: np.ndarray) -> float:
    if feature.shape != mean_vector.shape:
        raise RuntimeError("OOD baseline feature shape is incompatible with the deployed model")
    normalized = feature / (np.linalg.norm(feature) + 1e-8)
    return float(np.dot(normalized, mean_vector))


def assess_quality(image_bgr: np.ndarray, quality: Any) -> dict[str, Any]:
    """Image-science quality gates. `quality` is duck-typed (minWidth, minHeight, …)."""
    height, width = image_bgr.shape[:2]
    if width < quality.minWidth or height < quality.minHeight:
        return {"passed": False, "code": "RESOLUTION_TOO_LOW"}
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    if float(cv2.Laplacian(gray, cv2.CV_64F).var()) < quality.minBlurVariance:
        return {"passed": False, "code": "BLUR_DETECTED"}
    brightness = float(np.mean(gray))
    if not quality.minBrightness <= brightness <= quality.maxBrightness:
        return {"passed": False, "code": "BAD_EXPOSURE"}
    ycrcb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2YCrCb)
    skin_mask = cv2.inRange(ycrcb, np.array([0, 133, 77], dtype=np.uint8), np.array([255, 173, 127], dtype=np.uint8))
    if float(cv2.countNonZero(skin_mask) / (width * height)) < quality.minSkinRatio:
        return {"passed": False, "code": "NOT_ENOUGH_SKIN"}
    return {"passed": True, "code": None}


def _to_nchw_float(image: np.ndarray) -> np.ndarray:
    tensor = np.ascontiguousarray(image.transpose(2, 0, 1), dtype=np.float32)
    tensor /= 255.0
    return tensor[np.newaxis, ...]
