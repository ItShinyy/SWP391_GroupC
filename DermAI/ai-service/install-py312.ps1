# Installation script for Python 3.12 (Recommended - has pre-built wheels)
# Run: .\install-py312.ps1

Write-Host "=== Installing AI Service with Python 3.12 ===" -ForegroundColor Cyan

# Step 1: Check Python 3.12
Write-Host "`n[1/4] Checking Python 3.12..."
try {
    $version = py -3.12 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $version" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "ERROR: Python 3.12 not found!" -ForegroundColor Red
    Write-Host "`nInstall Python 3.12:" -ForegroundColor Yellow
    Write-Host "Download: https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "Choose: Python 3.12.x (Windows installer 64-bit)" -ForegroundColor White
    Write-Host "CHECK: Add Python to PATH" -ForegroundColor White
    Write-Host "`nAvailable versions:" -ForegroundColor Yellow
    py --list 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    exit 1
}

# Step 2: Clean old venv if exists
if (Test-Path "venv") {
    Write-Host "`n[2/4] Removing old venv..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv
    Write-Host "OK: Old venv removed" -ForegroundColor Green
}

# Step 3: Create virtual environment
Write-Host "`n[3/4] Creating virtual environment..."
py -3.12 -m venv venv
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: venv created with Python 3.12" -ForegroundColor Green
} else {
    Write-Host "ERROR: Failed to create venv" -ForegroundColor Red
    exit 1
}

# Step 4: Install packages
Write-Host "`n[4/4] Installing packages..."
Write-Host "This may take a few minutes..." -ForegroundColor Gray

& venv\Scripts\python.exe -m pip install --upgrade pip --quiet
Write-Host "  - pip upgraded" -ForegroundColor Gray

& venv\Scripts\python.exe -m pip install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: All packages installed successfully!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Package installation failed" -ForegroundColor Red
    exit 1
}

# Setup .env.local
Write-Host "`nSetting up .env.local..."
if (-not (Test-Path ".env.local")) {
    if (Test-Path ".env.local.example") {
        Copy-Item .env.local.example .env.local
        Write-Host "OK: .env.local created" -ForegroundColor Green
        Write-Host "WARNING: Edit .env.local before running!" -ForegroundColor Yellow
    }
} else {
    Write-Host "OK: .env.local exists" -ForegroundColor Green
}

# Verify installation
Write-Host "`n=== Verifying installation ===" -ForegroundColor Cyan
$packages = @("fastapi", "uvicorn", "pydantic", "numpy", "onnxruntime")
$allOk = $true

foreach ($pkg in $packages) {
    $test = & venv\Scripts\python.exe -c "import $($pkg.Replace('-', '_')); print('OK')" 2>$null
    if ($test -eq "OK") {
        Write-Host "  OK: $pkg" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $pkg" -ForegroundColor Red
        $allOk = $false
    }
}

if ($allOk) {
    Write-Host "`n=== Installation Complete! ===" -ForegroundColor Cyan
    Write-Host "`nNext steps:" -ForegroundColor Green
    Write-Host "  1. Edit .env.local (set AI_SERVICE_API_KEY and AI_MODELS_ROOT)" -ForegroundColor White
    Write-Host "  2. Run: .\start-ai-service.ps1" -ForegroundColor White
    Write-Host "`nHealth check: http://127.0.0.1:8000/health" -ForegroundColor Cyan
} else {
    Write-Host "`nERROR: Some packages failed to install" -ForegroundColor Red
    exit 1
}
