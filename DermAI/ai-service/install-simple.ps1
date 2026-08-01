# Simple installation script
# Run: .\install-simple.ps1

Write-Host "Installing AI Service..." -ForegroundColor Cyan

# Check Python
Write-Host "`n[1] Checking Python 3.11..."
$pythonCheck = py -3.11 --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Python 3.11 not found!" -ForegroundColor Red
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}
Write-Host "OK: $pythonCheck" -ForegroundColor Green

# Create venv
Write-Host "`n[2] Creating virtual environment..."
if (-not (Test-Path "venv")) {
    py -3.11 -m venv venv
    Write-Host "OK: venv created" -ForegroundColor Green
} else {
    Write-Host "OK: venv exists" -ForegroundColor Green
}

# Install packages
Write-Host "`n[3] Installing packages..."
& venv\Scripts\python.exe -m pip install --upgrade pip
& venv\Scripts\python.exe -m pip install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: All packages installed" -ForegroundColor Green
} else {
    Write-Host "ERROR: Installation failed" -ForegroundColor Red
    exit 1
}

# Setup .env.local
Write-Host "`n[4] Setting up .env.local..."
if (-not (Test-Path ".env.local")) {
    if (Test-Path ".env.local.example") {
        Copy-Item .env.local.example .env.local
        Write-Host "OK: .env.local created" -ForegroundColor Green
        Write-Host "WARNING: Edit .env.local before running!" -ForegroundColor Yellow
    }
} else {
    Write-Host "OK: .env.local exists" -ForegroundColor Green
}

Write-Host "`n=== Installation Complete ===" -ForegroundColor Cyan
Write-Host "`nTo run server:" -ForegroundColor Green
Write-Host "  .\start-ai-service.ps1" -ForegroundColor White
Write-Host "`nOr manually:" -ForegroundColor Green
Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "  python -m uvicorn app.main:app --host 127.0.0.1 --port 8000" -ForegroundColor White
