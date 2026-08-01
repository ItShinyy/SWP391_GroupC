# Seed data

`Seed.bat` runs `001_DevelopmentSeed.sql` (users, clinics, AI disease codes, clinical policy, and one active `ai_models` row).

The seeded model id is `00000000-0000-0000-0000-000000000901` with
`storage_path = models/00000000-0000-0000-0000-000000000901`.

That directory (plus `active/`) must already exist under `AI_MODELS_ROOT` with:

- `model.onnx`
- `labels.json`
- `reference_features.npz`
- `metadata.json`

Local default: `C:/Users/phong/Downloads/SWP391/DermAI-private-artifacts`.
