# Script cai dat va chay AI Service (FastAPI)
# Chay tu thu muc ai-service: .\setup-ai-service.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== DermAI AI Service Setup ===" -ForegroundColor Cyan

# 1. Kiem tra Python (3.11+ recommended)
Write-Host "`n[1/5] Kiem tra Python..." -ForegroundColor Yellow

$pythonCmd = $null
$pythonVersion = $null

# Try Python 3.14 first
try {
    $pythonVersion = & py -3.14 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $pythonCmd = "py -3.14"
        Write-Host "OK: $pythonVersion (using 3.14)" -ForegroundColor Green
    }
} catch {}

# Fall back to 3.11
if (-not $pythonCmd) {
    try {
        $pythonVersion = & py -3.11 --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = "py -3.11"
            Write-Host "OK: $pythonVersion (using 3.11)" -ForegroundColor Green
        }
    } catch {}
}

# Try default Python
if (-not $pythonCmd) {
    try {
        $pythonVersion = & python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = "python"
            Write-Host "OK: $pythonVersion (using default python)" -ForegroundColor Green
        }
    } catch {}
}

if (-not $pythonCmd) {
    Write-Host "ERROR: Python not found!" -ForegroundColor Red
    Write-Host "`nInstall Python 3.11 or newer:" -ForegroundColor Yellow
    Write-Host "Download: https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "CHECK: 'Add Python to PATH'" -ForegroundColor White
    Write-Host "CHECK: 'Install launcher for all users (py)'" -ForegroundColor White
    exit 1
}

# 2. Setup .env.local
Write-Host "`n[2/5] Setup .env.local..." -ForegroundColor Yellow

$envExample = ".env.local.example"
$envLocal = ".env.local"

if (-not (Test-Path $envLocal)) {
    if (Test-Path $envExample) {
        Copy-Item $envExample $envLocal
        Write-Host "OK: Da tao .env.local tu example" -ForegroundColor Green
        Write-Host "WARNING: Can chinh sua cac gia tri sau trong .env.local:" -ForegroundColor Yellow
        Write-Host "  - AI_SERVICE_API_KEY (phai khop voi local.properties)" -ForegroundColor White
        Write-Host "  - AI_MODELS_ROOT (duong dan den models folder)" -ForegroundColor White
    } else {
        Write-Host "ERROR: Khong tim thay .env.local.example" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OK: .env.local da ton tai" -ForegroundColor Green
}

# 3. Tao virtual environment
Write-Host "`n[3/5] Tao virtual environment..." -ForegroundColor Yellow

if (-not (Test-Path "venv")) {
    Write-Host "Dang tao venv voi $pythonCmd..." -ForegroundColor White
    Invoke-Expression "$pythonCmd -m venv venv"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: Virtual environment da duoc tao" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Khong the tao virtual environment" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OK: Virtual environment da ton tai" -ForegroundColor Green
}

# 4. Activate venv va cai packages
Write-Host "`n[4/5] Cai dat dependencies..." -ForegroundColor Yellow

# Activate venv
$activateScript = "venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    Write-Host "Activating virtual environment..." -ForegroundColor White
    & $activateScript
    
    # Upgrade pip
    Write-Host "Upgrading pip..." -ForegroundColor White
    & venv\Scripts\python.exe -m pip install --upgrade pip --quiet
    
    # Install requirements
    Write-Host "Installing packages from requirements.txt..." -ForegroundColor White
    & venv\Scripts\python.exe -m pip install -r requirements.txt
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: Da cai dat tat ca dependencies" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Loi khi cai dat dependencies" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: Khong tim thay activation script" -ForegroundColor Red
    exit 1
}

# 5. Verify installation
Write-Host "`n[5/5] Verify installation..." -ForegroundColor Yellow

$packages = @("fastapi", "uvicorn", "pydantic", "numpy", "onnxruntime")
$allInstalled = $true

foreach ($package in $packages) {
    $testCmd = "import sys; import $($package.Replace('-', '_')); print('OK')"
    $installed = & venv\Scripts\python.exe -c $testCmd 2>$null
    if ($installed -eq "OK") {
        Write-Host "OK: $package" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $package" -ForegroundColor Red
        $allInstalled = $false
    }
}

if (-not $allInstalled) {
    Write-Host "`nWARNING: Mot so package chua duoc cai dung" -ForegroundColor Yellow
    exit 1
}

# Summary
Write-Host "`n=== Setup hoan tat ===" -ForegroundColor Cyan
Write-Host "`nDe chay AI Service:" -ForegroundColor Green
Write-Host "   1. Activate venv:    .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "   2. Chay server:      python -m uvicorn app.main:app --host 127.0.0.1 --port 8000" -ForegroundColor White
Write-Host "   3. Hoac dung script: .\start-ai-service.ps1" -ForegroundColor White

Write-Host "`nTruoc khi chay, kiem tra .env.local:" -ForegroundColor Yellow
Write-Host "   - AI_SERVICE_API_KEY" -ForegroundColor Gray
Write-Host "   - AI_MODELS_ROOT (phai co thu muc active/ ben trong)" -ForegroundColor Gray
Write-Host "   - AI_MAX_INPUT_BYTES" -ForegroundColor Gray
Write-Host "   - HARD_MAX_AI_CONCURRENCY" -ForegroundColor Gray

Write-Host "`nHealth check: http://127.0.0.1:8000/health" -ForegroundColor Cyan
