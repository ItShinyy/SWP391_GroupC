"""Offline Torch → ONNX export for DermAI packages (host Python + requirements-export.txt)."""

from __future__ import annotations

import argparse
import hashlib
import json
import platform
from pathlib import Path
from typing import Any

import numpy as np
import onnx
import onnxruntime as ort
import torch
import ultralytics
from app.onnx_backend import EIGENCAM_VERSION, PREPROCESSING_VERSION
from ultralytics import YOLO


OUTPUT_NAMES = ("logits", "embedding", "feature_map")
EIGENCAM_LAYER_TYPES = {"Conv", "C2f", "SPPF", "C3"}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


class ScreeningExportWrapper(torch.nn.Module):
    """Returns the exact classifier tensors captured by the legacy hooks."""

    def __init__(self, network: torch.nn.Module) -> None:
        super().__init__()
        self.network = network.eval()
        self.embedding: torch.Tensor | None = None
        self.logits: torch.Tensor | None = None
        self.feature_map: torch.Tensor | None = None

        linears = [(name, module) for name, module in network.named_modules() if isinstance(module, torch.nn.Linear)]
        if not linears:
            raise RuntimeError("classifier has no Linear layer for OOD/logit export")
        self.linear_name, linear = linears[0]

        spatial = [
            (name, module)
            for name, module in network.named_modules()
            if type(module).__name__ in EIGENCAM_LAYER_TYPES
        ]
        if not spatial:
            raise RuntimeError("classifier has no supported EigenCAM feature layer")
        self.feature_map_name, feature_layer = spatial[-1]

        self._linear_handle = linear.register_forward_hook(self._capture_linear)
        self._feature_handle = feature_layer.register_forward_hook(self._capture_feature_map)

    def _capture_linear(self, _module: torch.nn.Module, inputs: tuple[Any, ...], output: Any) -> None:
        if not inputs or not isinstance(inputs[0], torch.Tensor) or not isinstance(output, torch.Tensor):
            raise RuntimeError("classifier Linear layer did not expose tensor inputs and output")
        self.embedding = inputs[0].flatten(start_dim=1)
        self.logits = output

    def _capture_feature_map(self, _module: torch.nn.Module, _inputs: tuple[Any, ...], output: Any) -> None:
        if not isinstance(output, torch.Tensor):
            raise RuntimeError("EigenCAM layer did not expose a tensor output")
        self.feature_map = output

    def forward(self, tensor: torch.Tensor) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        self.embedding = None
        self.logits = None
        self.feature_map = None
        _ = self.network(tensor)
        if self.logits is None or self.embedding is None or self.feature_map is None:
            raise RuntimeError("classifier did not emit all required screening tensors")
        return self.logits, self.embedding, self.feature_map

    def close(self) -> None:
        self._linear_handle.remove()
        self._feature_handle.remove()


def ordered_class_names(names: dict[int, str] | list[str]) -> list[str]:
    if isinstance(names, dict):
        return [str(names[index]) for index in sorted(names)]
    return [str(value) for value in names]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--weights", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--opset", type=int, default=17)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.weights.is_file():
        raise FileNotFoundError(f"weights not found: {args.weights}")
    image_size = 224

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.parent.mkdir(parents=True, exist_ok=True)

    classifier = YOLO(str(args.weights))
    class_names = ordered_class_names(classifier.names)
    source_model_sha256 = sha256_file(args.weights)
    wrapper = ScreeningExportWrapper(classifier.model.cpu().eval())
    dummy = torch.zeros((1, 3, image_size, image_size), dtype=torch.float32)
    try:
        with torch.no_grad():
            torch_outputs = wrapper(dummy)
        torch.onnx.export(
            wrapper,
            dummy,
            str(args.output),
            export_params=True,
            opset_version=args.opset,
            do_constant_folding=True,
            input_names=["images"],
            output_names=list(OUTPUT_NAMES),
            dynamic_axes=None,
        )
    finally:
        wrapper.close()

    graph = onnx.load(str(args.output))
    onnx.helper.set_model_props(
        graph,
        {
            "runtime": "ONNX_RUNTIME",
            "class_names": json.dumps(class_names, separators=(",", ":")),
            "source_model_sha256": source_model_sha256,
            "ood_embedding_layer": wrapper.linear_name,
            "eigencam_feature_layer": wrapper.feature_map_name,
            "preprocessing_version": PREPROCESSING_VERSION,
            "eigencam_version": EIGENCAM_VERSION,
        },
    )
    onnx.save(graph, str(args.output))
    onnx.checker.check_model(graph)
    session = ort.InferenceSession(str(args.output), providers=["CPUExecutionProvider"])
    actual_output_names = tuple(value.name for value in session.get_outputs())
    if actual_output_names != OUTPUT_NAMES:
        raise RuntimeError(f"unexpected ONNX outputs: {actual_output_names}")
    onnx_outputs = session.run(list(OUTPUT_NAMES), {"images": dummy.numpy()})
    for name, value in zip(OUTPUT_NAMES, onnx_outputs):
        if not np.isfinite(value).all():
            raise RuntimeError(f"ONNX output contains NaN or Inf: {name}")

    maximum_differences = {
        name: float(np.max(np.abs(reference.detach().cpu().numpy() - candidate)))
        for name, reference, candidate in zip(OUTPUT_NAMES, torch_outputs, onnx_outputs)
    }
    manifest = {
        "schemaVersion": "1",
        "runtime": "ONNX_RUNTIME",
        "sourceModelSha256": source_model_sha256,
        "onnxSha256": sha256_file(args.output),
        "opset": args.opset,
        "input": {"name": "images", "shape": [1, 3, image_size, image_size], "dtype": "float32"},
        "outputs": [
            {"name": metadata.name, "shape": metadata.shape, "type": metadata.type}
            for metadata in session.get_outputs()
        ],
        "classNames": class_names,
        "oodEmbeddingLayer": wrapper.linear_name,
        "eigencamFeatureLayer": wrapper.feature_map_name,
        "preprocessingVersion": PREPROCESSING_VERSION,
        "eigencamVersion": EIGENCAM_VERSION,
        "onnx": {
            "irVersion": graph.ir_version,
            "producerName": graph.producer_name,
            "producerVersion": graph.producer_version,
            "domain": graph.domain,
            "modelVersion": graph.model_version,
            "opsetImports": [
                {"domain": value.domain, "version": value.version}
                for value in graph.opset_import
            ],
        },
        "maximumTorchOnnxAbsoluteDifference": maximum_differences,
        "versions": {
            "python": platform.python_version(),
            "torch": torch.__version__,
            "ultralytics": ultralytics.__version__,
            "onnx": onnx.__version__,
            "onnxruntime": ort.__version__,
        },
    }
    args.manifest.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
