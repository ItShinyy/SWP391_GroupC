# Clean old venv and reinstall with Python 3.11
# Run: .\clean-and-install.ps1

Write-Host "=== Clean and Reinstall AI Service ===" -ForegroundColor Cyan

# Step 1: Check Python 3.11
Write-Host "`n[1/4] Checking Python 3.11..."
try {
    $version = py -3.11 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $version" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "ERROR: Python 3.11 not found!" -ForegroundColor Red
    Write-Host "`nInstall Python 3.11 from:" -ForegroundColor Yellow
    Write-Host "https://www.python.org/downloads/release/python-3118/" -ForegroundColor White
    Write-Host "`nCurrently available:" -ForegroundColor Yellow
    py --list 2>&1
    exit 1
}

# Step 2: Remove old venv
Write-Host "`n[2/4] Removing old virtual environment..."
if (Test-Path "venv") {
    Write-Host "Deleting venv folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv -ErrorAction Stop
    Write-Host "OK: Old venv removed" -ForegroundColor Green
} else {
    Write-Host "No old venv found" -ForegroundColor Gray
}

# Step 3: Create new venv with Python 3.11
Write-Host "`n[3/4] Creating new virtual environment with Python 3.11..."
py -3.11 -m venv venv

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: Virtual environment created" -ForegroundColor Green
    
    # Verify venv Python version
    $venvPython = & venv\Scripts\python.exe --version
    Write-Host "Venv Python: $venvPython" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Failed to create venv" -ForegroundColor Red
    exit 1
}

# Step 4: Install packages
Write-Host "`n[4/4] Installing packages..."
Write-Host "Upgrading pip..." -ForegroundColor Gray
& venv\Scripts\python.exe -m pip install --upgrade pip --quiet

Write-Host "Installing from requirements.txt (this takes 2-3 minutes)..." -ForegroundColor Gray
& venv\Scripts\python.exe -m pip install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: All packages installed!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Package installation failed" -ForegroundColor Red
    exit 1
}

# Verify
Write-Host "`n=== Verifying Installation ===" -ForegroundColor Cyan

$testResult = & venv\Scripts\python.exe -c @"
import sys
print(f'Python: {sys.version}')
import fastapi
print(f'fastapi: {fastapi.__version__}')
import uvicorn
print(f'uvicorn: {uvicorn.__version__}')
import pydantic
print(f'pydantic: {pydantic.__version__}')
import numpy
print(f'numpy: {numpy.__version__}')
import onnxruntime
print(f'onnxruntime: {onnxruntime.__version__}')
print('ALL OK')
"@ 2>&1

if ($testResult -match "ALL OK") {
    Write-Host $testResult -ForegroundColor Green
    Write-Host "`n=== Installation Complete! ===" -ForegroundColor Cyan
    Write-Host "`nNext: Edit .env.local and run .\start-ai-service.ps1" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: Verification failed" -ForegroundColor Red
    Write-Host $testResult
    exit 1
}
