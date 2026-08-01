# Installation script for Python 3.11 (Official version for this project)
# Run: .\install-py311.ps1

Write-Host "=== Installing AI Service with Python 3.11 ===" -ForegroundColor Cyan

# Step 1: Check Python 3.11
Write-Host "`n[1/5] Checking Python 3.11..."
try {
    $version = py -3.11 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $version" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "ERROR: Python 3.11 not found!" -ForegroundColor Red
    Write-Host "`nInstall Python 3.11:" -ForegroundColor Yellow
    Write-Host "Download: https://www.python.org/downloads/release/python-3118/" -ForegroundColor White
    Write-Host "Choose: Windows installer (64-bit)" -ForegroundColor White
    Write-Host "IMPORTANT: Check 'Add Python to PATH' during installation" -ForegroundColor White
    Write-Host "`nCurrently installed:" -ForegroundColor Yellow
    py --list 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    exit 1
}

# Step 2: Clean old venv if exists
if (Test-Path "venv") {
    Write-Host "`n[2/5] Removing old venv..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv
    Write-Host "OK: Old venv removed" -ForegroundColor Green
} else {
    Write-Host "`n[2/5] No old venv to remove" -ForegroundColor Gray
}

# Step 3: Create virtual environment
Write-Host "`n[3/5] Creating virtual environment with Python 3.11..."
py -3.11 -m venv venv
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to create venv" -ForegroundColor Red
    exit 1
}

# Step 4: Upgrade pip
Write-Host "`n[4/5] Upgrading pip..."
& venv\Scripts\python.exe -m pip install --upgrade pip --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: pip upgraded" -ForegroundColor Green
} else {
    Write-Host "WARNING: pip upgrade had issues (not critical)" -ForegroundColor Yellow
}

# Step 5: Install packages
Write-Host "`n[5/5] Installing packages from requirements.txt..."
Write-Host "This will take 2-3 minutes. Please wait..." -ForegroundColor Gray
Write-Host ""

& venv\Scripts\python.exe -m pip install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nOK: All packages installed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nERROR: Package installation failed" -ForegroundColor Red
    Write-Host "Try running manually:" -ForegroundColor Yellow
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
    Write-Host "  pip install -r requirements.txt" -ForegroundColor White
    exit 1
}

# Setup .env.local
Write-Host "`n=== Setting up configuration ===" -ForegroundColor Cyan
if (-not (Test-Path ".env.local")) {
    if (Test-Path ".env.local.example") {
        Copy-Item .env.local.example .env.local
        Write-Host "OK: .env.local created from example" -ForegroundColor Green
        Write-Host "WARNING: You must edit .env.local before running!" -ForegroundColor Yellow
        Write-Host "  Required: AI_SERVICE_API_KEY" -ForegroundColor White
        Write-Host "  Required: AI_MODELS_ROOT" -ForegroundColor White
    } else {
        Write-Host "WARNING: .env.local.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "OK: .env.local already exists" -ForegroundColor Green
}

# Verify installation
Write-Host "`n=== Verifying installation ===" -ForegroundColor Cyan
$packages = @(
    @{Name="fastapi"; Import="fastapi"},
    @{Name="uvicorn"; Import="uvicorn"},
    @{Name="pydantic"; Import="pydantic"},
    @{Name="opencv-python-headless"; Import="cv2"},
    @{Name="numpy"; Import="numpy"},
    @{Name="onnxruntime"; Import="onnxruntime"}
)
$allOk = $true

foreach ($pkg in $packages) {
    $test = & venv\Scripts\python.exe -c "import $($pkg.Import); print('OK')" 2>$null
    if ($test -eq "OK") {
        Write-Host "  OK: $($pkg.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $($pkg.Name)" -ForegroundColor Red
        $allOk = $false
    }
}

# Final summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "  Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. Edit .env.local:" -ForegroundColor White
    Write-Host "     - Set AI_SERVICE_API_KEY (must match local.properties)" -ForegroundColor Gray
    Write-Host "     - Set AI_MODELS_ROOT (path to models folder with active/)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Start server:" -ForegroundColor White
    Write-Host "     .\start-ai-service.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Or manually:" -ForegroundColor White
    Write-Host "     .\venv\Scripts\Activate.ps1" -ForegroundColor Gray
    Write-Host "     python -m uvicorn app.main:app --host 127.0.0.1 --port 8000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Health check: http://127.0.0.1:8000/health" -ForegroundColor Cyan
} else {
    Write-Host "  Installation Failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`nSome packages failed to install." -ForegroundColor Red
    Write-Host "Try installing manually or check error messages above." -ForegroundColor Yellow
    exit 1
}
