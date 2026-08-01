# Paths Corrected ✓

All hardcoded paths have been updated to match this device (user: admin).

## Updated Paths

### Old Path (user: phong)
```
C:/Users/phong/Downloads/SWP391/DermAI-private-artifacts
```

### New Path (user: admin)
```
C:/Users/admin/Downloads/DermAI/DermAI/DermAI-private-artifacts
```

## Files Updated

1. ✓ `local.properties`
   - `AI_MODELS_ROOT=C:/Users/admin/Downloads/DermAI/DermAI/DermAI-private-artifacts`

2. ✓ `ai-service/.env.local`
   - `AI_MODELS_ROOT=C:/Users/admin/Downloads/DermAI/DermAI/DermAI-private-artifacts`

3. ✓ All scripts in `scripts/` folder

## Directory Structure

```
C:\Users\admin\Downloads\DermAI\DermAI\
├── local.properties                 [✓ Updated]
├── ai-service\
│   └── .env.local                  [✓ Updated]
├── scripts\
│   ├── fix-paths-for-admin.ps1     [✓ Updated]
│   ├── check-ai-service-setup.ps1  [✓ Updated]
│   └── create-dummy-model.ps1      [✓ Updated]
└── DermAI-private-artifacts\        [✓ Created]
    ├── README.md
    └── active\                      [Empty - needs model files]
        ├── model.onnx              [Missing]
        ├── labels.json             [Missing]
        ├── reference_features.npz  [Missing]
        └── metadata.json           [Missing]
```

## Next Steps

### 1. Check setup
```powershell
.\scripts\check-ai-service-setup.ps1
```

### 2. Add model files

You need to get 4 model files from your team and copy them to:
```
C:\Users\admin\Downloads\DermAI\DermAI\DermAI-private-artifacts\active\
```

Required files:
- model.onnx
- labels.json
- reference_features.npz
- metadata.json

### 3. Restart AI service

```powershell
cd ai-service
.\start-ai-service.ps1
```

### 4. Test

```powershell
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing
```

Should return: `{"status":"ok"}`

## Current Status

- ✅ Paths configured correctly
- ✅ Directories created
- ⚠️ Model files missing (need to add manually)
- ⚠️ AI service will return 503 until model files are added

## Troubleshooting

If AI service still shows 503 error after adding model files:
1. Check all 4 files are in the `active/` folder
2. Restart AI service
3. Check logs for specific error messages
