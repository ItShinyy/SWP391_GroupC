This folder is `AI_MODELS_ROOT` for local SkinAI.

## Runtime layout (required)

```text
active/
  model.onnx
  labels.json
  reference_features.npz
  metadata.json
models/
  00000000-0000-0000-0000-000000000901/   # seeded active package
    model.onnx
    labels.json
    reference_features.npz
    metadata.json
```

FastAPI loads only `active/`. Java seeds `ai_models` with id `...901` and `is_active = 1`.

## Docker mount

```powershell
--mount "type=bind,source=C:\Users\phong\Downloads\SWP391\SkinAI-private-artifacts,target=/artifacts/models"
```

Container env: `AI_MODELS_ROOT=/artifacts/models`  
Java `local.properties`: `AI_MODELS_ROOT=C:/Users/phong/Downloads/SWP391/SkinAI-private-artifacts`
