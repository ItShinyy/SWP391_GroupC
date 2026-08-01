# Installation script for Python 3.14
# Run: .\install-py314.ps1

Write-Host "=== Installing AI Service with Python 3.14 ===" -ForegroundColor Cyan

# Step 1: Check Python 3.14
Write-Host "`n[1/4] Checking Python 3.14..."
try {
    $version = py -3.14 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $version" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "ERROR: Python 3.14 not found!" -ForegroundColor Red
    Write-Host "Try: py --list to see installed versions" -ForegroundColor Yellow
    exit 1
}

# Step 2: Create virtual environment
Write-Host "`n[2/4] Creating virtual environment..."
if (-not (Test-Path "venv")) {
    py -3.14 -m venv venv
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: venv created" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to create venv" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OK: venv already exists" -ForegroundColor Green
}

# Step 3: Install packages
Write-Host "`n[3/4] Installing packages..."
Write-Host "This may take a few minutes..." -ForegroundColor Gray

& venv\Scripts\python.exe -m pip install --upgrade pip --quiet
& venv\Scripts\python.exe -m pip install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: All packages installed" -ForegroundColor Green
} else {
    Write-Host "ERROR: Package installation failed" -ForegroundColor Red
    Write-Host "Try running manually:" -ForegroundColor Yellow
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
    Write-Host "  pip install -r requirements.txt" -ForegroundColor White
    exit 1
}

# Step 4: Setup .env.local
Write-Host "`n[4/4] Setting up .env.local..."
if (-not (Test-Path ".env.local")) {
    if (Test-Path ".env.local.example") {
        Copy-Item .env.local.example .env.local
        Write-Host "OK: .env.local created from example" -ForegroundColor Green
        Write-Host "WARNING: Edit .env.local before running!" -ForegroundColor Yellow
    } else {
        Write-Host "WARNING: .env.local.example not found" -ForegroundColor Yellow
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
        Write-Host "OK: $pkg" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $pkg not installed" -ForegroundColor Red
        $allOk = $false
    }
}

if ($allOk) {
    Write-Host "`n=== Installation Complete ===" -ForegroundColor Cyan
    Write-Host "`nTo run the server:" -ForegroundColor Green
    Write-Host "  .\start-ai-service.ps1" -ForegroundColor White
    Write-Host "`nOr manually:" -ForegroundColor Green
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
    Write-Host "  python -m uvicorn app.main:app --host 127.0.0.1 --port 8000" -ForegroundColor White
    Write-Host "`nHealth check: http://127.0.0.1:8000/health" -ForegroundColor Cyan
} else {
    Write-Host "`nERROR: Some packages failed to install" -ForegroundColor Red
    exit 1
}
