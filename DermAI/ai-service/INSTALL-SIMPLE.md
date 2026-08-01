# AI Service - Installation Guide

## Required: Python 3.11

This project officially uses **Python 3.11** (tested and verified).

---

## Quick Install

### Step 1: Check if you have Python 3.11

```powershell
.\check-python311.ps1
```

### Step 2: Install Python 3.11 (if needed)

Download: https://www.python.org/downloads/release/python-3118/

Choose: **Windows installer (64-bit)**

**IMPORTANT during installation:**
- ✅ Add Python to PATH
- ✅ Install launcher for all users (py)

Restart PowerShell after installation.

### Step 3: Install AI Service

```powershell
.\install-py311.ps1
```

This will:
- Create virtual environment
- Install all packages
- Setup .env.local

### Step 4: Configure .env.local

Edit `.env.local`:

```env
AI_SERVICE_API_KEY=gODrVeFSrcQVSLnNeyjVlAU5aSqSmSHMUTUfdGe+2CjkxCO7e51lAaG7lWiUD0Wx
AI_MODELS_ROOT=C:/path/to/models
AI_MAX_INPUT_BYTES=15728640
HARD_MAX_AI_CONCURRENCY=3
```

⚠️ `AI_MODELS_ROOT` must contain an `active/` folder with ONNX model

### Step 5: Run Server

```powershell
.\start-ai-service.ps1
```

Or manually:
```powershell
.\venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## Test

```powershell
# Health check
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing

# API Documentation
Start-Process http://127.0.0.1:8000/docs
```

---

## Troubleshooting

### "Python 3.11 not found"

Install from: https://www.python.org/downloads/release/python-3118/

### "scripts is disabled"

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Failed building wheel for pydantic-core"

This means you're using Python 3.14+. Use Python 3.11 instead (recommended for this project).

### Clean install

```powershell
# Remove venv
Remove-Item -Recurse -Force venv

# Install again
.\install-py311.ps1
```

---

## Files

- `check-python311.ps1` - Check if Python 3.11 is installed
- `install-py311.ps1` - Install AI service with Python 3.11
- `start-ai-service.ps1` - Start the server
- `.env.local` - Configuration (do not commit!)
- `requirements.txt` - Python dependencies

---

## Dependencies (installed automatically)

- fastapi==0.115.6
- pydantic==2.10.4
- uvicorn==0.34.0
- opencv-python-headless==4.10.0.84
- numpy==1.26.4
- onnxruntime==1.27.0
