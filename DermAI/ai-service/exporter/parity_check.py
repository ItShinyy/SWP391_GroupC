"""Compare the frozen Torch classifier with the ONNX candidate on real images."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import cv2
import numpy as np
import torch
from ultralytics import YOLO

from app.onnx_backend import (
    OnnxClassifierSession,
    classification_tensor,
    eigencam_heatmap,
    eigencam_tensor,
    probabilities,
)
from exporter.export_model import ScreeningExportWrapper


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--weights", required=True, type=Path)
    parser.add_argument("--onnx", required=True, type=Path)
    parser.add_argument("--ood", required=True, type=Path)
    parser.add_argument("--images", required=True, type=Path)
    parser.add_argument("--per-class", type=int, default=5)
    return parser.parse_args()


def selected_images(root: Path, per_class: int) -> list[Path]:
    images: list[Path] = []
    for class_directory in sorted(path for path in root.iterdir() if path.is_dir()):
        candidates = sorted(
            path for path in class_directory.rglob("*") if path.suffix.lower() in {".jpg", ".jpeg", ".png"}
        )
        images.extend(candidates[:per_class])
    if not images:
        raise RuntimeError("no parity images were found")
    return images


def main() -> None:
    args = parse_args()
    classifier = YOLO(str(args.weights))
    linear = next(module for module in classifier.model.modules() if isinstance(module, torch.nn.Linear))
    legacy_embedding: list[np.ndarray] = []

    def capture_embedding(_module, inputs, _output) -> None:
        legacy_embedding[:] = [inputs[0].detach().reshape(inputs[0].shape[0], -1).cpu().numpy()[0]]

    hook = linear.register_forward_hook(capture_embedding)
    wrapper = ScreeningExportWrapper(classifier.model.cpu().eval())
    onnx_session = OnnxClassifierSession(args.onnx)
    ood = np.load(args.ood)
    mean_vector = np.asarray(ood["mean_vector"], dtype=np.float32)
    ood_threshold = float(ood["threshold"])

    top1_matches = 0
    ood_decision_matches = 0
    maximum_confidence_difference = 0.0
    maximum_ood_difference = 0.0
    minimum_embedding_cosine = 1.0
    minimum_heatmap_correlation = 1.0
    cases = []
    try:
        for image_path in selected_images(args.images, args.per_class):
            image_bgr = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
            if image_bgr is None:
                raise RuntimeError(f"unable to decode parity image: {image_path}")
            image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)

            torch_result = classifier(image_rgb, imgsz=224, verbose=False)[0]
            torch_scores = torch_result.probs.data.detach().cpu().numpy().astype(np.float32)
            torch_embedding = legacy_embedding[0]

            onnx_result = onnx_session.run(classification_tensor(image_rgb))
            onnx_scores = probabilities(onnx_result.logits)
            torch_top1, onnx_top1 = int(np.argmax(torch_scores)), int(np.argmax(onnx_scores))
            top1_matches += int(torch_top1 == onnx_top1)
            confidence_difference = abs(float(torch_scores[torch_top1]) - float(onnx_scores[onnx_top1]))
            maximum_confidence_difference = max(maximum_confidence_difference, confidence_difference)

            embedding_cosine = float(
                np.dot(torch_embedding, onnx_result.embedding)
                / ((np.linalg.norm(torch_embedding) * np.linalg.norm(onnx_result.embedding)) + 1e-8)
            )
            minimum_embedding_cosine = min(minimum_embedding_cosine, embedding_cosine)
            torch_ood = float(np.dot(torch_embedding / (np.linalg.norm(torch_embedding) + 1e-8), mean_vector))
            onnx_ood = float(np.dot(onnx_result.embedding / (np.linalg.norm(onnx_result.embedding) + 1e-8), mean_vector))
            maximum_ood_difference = max(maximum_ood_difference, abs(torch_ood - onnx_ood))
            ood_decision_matches += int((torch_ood >= ood_threshold) == (onnx_ood >= ood_threshold))

            explanation_input = eigencam_tensor(image_rgb)
            with torch.no_grad():
                torch_explanation = wrapper(torch.from_numpy(explanation_input))[2]
            onnx_explanation = onnx_session.run(explanation_input).feature_map
            torch_cam = eigencam_heatmap(torch_explanation[0].detach().cpu().numpy())
            onnx_cam = eigencam_heatmap(onnx_explanation)
            correlation = float(np.corrcoef(torch_cam.reshape(-1), onnx_cam.reshape(-1))[0, 1])
            if not np.isfinite(correlation):
                correlation = 1.0 if np.allclose(torch_cam, onnx_cam) else 0.0
            minimum_heatmap_correlation = min(minimum_heatmap_correlation, correlation)
            cases.append({
                "image": image_path.name,
                "torchTop1": torch_top1,
                "onnxTop1": onnx_top1,
                "confidenceDifference": confidence_difference,
                "embeddingCosine": embedding_cosine,
                "oodDifference": abs(torch_ood - onnx_ood),
                "heatmapCorrelation": correlation,
            })
    finally:
        hook.remove()
        wrapper.close()

    count = len(cases)
    summary = {
        "images": count,
        "top1Matches": top1_matches,
        "oodDecisionMatches": ood_decision_matches,
        "maximumConfidenceDifference": maximum_confidence_difference,
        "maximumOodDifference": maximum_ood_difference,
        "minimumEmbeddingCosine": minimum_embedding_cosine,
        "minimumHeatmapCorrelation": minimum_heatmap_correlation,
        "passed": (
            top1_matches == count
            and ood_decision_matches == count
            and maximum_confidence_difference <= 1e-3
            and maximum_ood_difference <= 1e-4
            and minimum_embedding_cosine >= 0.999
            and minimum_heatmap_correlation >= 0.95
        ),
        "cases": cases,
    }
    print(json.dumps(summary, indent=2))
    if not summary["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
