# Fix: "Failed building wheel for pydantic-core" Error

## Problem

You see this error when installing:
```
Failed building wheel for pydantic-core
ERROR: Failed to build installable wheels for some pyproject.toml based projects
```

## Cause

Your virtual environment (venv) was created with **Python 3.14**, which is too new. The `pydantic-core` package doesn't have pre-built binaries for Python 3.14 yet, and trying to compile from source fails.

This project requires **Python 3.11** (tested and stable).

---

## Solution: Clean and Reinstall with Python 3.11

### Step 1: Check your current setup

```powershell
.\check-current-venv.ps1
```

This will show:
- Current venv Python version
- Installed packages
- Available Python versions on your system

### Step 2: Clean and reinstall

```powershell
.\clean-and-install.ps1
```

This script will:
1. Check if Python 3.11 is available
2. Delete the old venv folder
3. Create new venv with Python 3.11
4. Install all packages successfully

### Step 3: Verify

```powershell
.\check-current-venv.ps1
```

Should show: **"OK: Using Python 3.11 (correct)"**

### Step 4: Run server

```powershell
.\start-ai-service.ps1
```

---

## Manual Steps (if scripts fail)

```powershell
# 1. Remove old venv
Remove-Item -Recurse -Force venv

# 2. Check you have Python 3.11
py -3.11 --version

# 3. Create venv with Python 3.11
py -3.11 -m venv venv

# 4. Activate
.\venv\Scripts\Activate.ps1

# 5. Verify venv Python version
python --version
# Should show: Python 3.11.x

# 6. Install packages
python -m pip install --upgrade pip
pip install -r requirements.txt

# 7. Run
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## Don't Have Python 3.11?

### Install Python 3.11:

1. Download: https://www.python.org/downloads/release/python-3118/
2. Choose: **Windows installer (64-bit)**
3. During installation, CHECK:
   - ✅ Add Python to PATH
   - ✅ Install launcher for all users (py)
4. Restart PowerShell
5. Verify: `py -3.11 --version`
6. Run: `.\clean-and-install.ps1`

---

## Why Not Python 3.14?

- Python 3.14 is very new (released recently)
- Many packages don't have pre-built binaries yet
- `pydantic-core` needs to be compiled from Rust source
- Compilation requires additional tools (Rust compiler, Visual Studio)
- **Python 3.11** is stable and all packages work perfectly

---

## Quick Commands

```powershell
# Check current venv
.\check-current-venv.ps1

# Fix Python 3.14 issue
.\clean-and-install.ps1

# Check if Python 3.11 is available
.\check-python311.ps1

# Start server after fix
.\start-ai-service.ps1
```

---

## Still Having Issues?

Check if you have multiple Python installations:

```powershell
py --list
```

Make sure Python 3.11 is in the list. If not, install it first.
