# Check current venv Python version
Write-Host "=== Checking Current Setup ===" -ForegroundColor Cyan

# Check if venv exists
if (Test-Path "venv\Scripts\python.exe") {
    Write-Host "`nVirtual environment exists" -ForegroundColor Green
    
    # Check venv Python version
    Write-Host "`nVenv Python version:" -ForegroundColor Yellow
    $venvVersion = & venv\Scripts\python.exe --version
    Write-Host $venvVersion -ForegroundColor Cyan
    
    # Check if it's 3.11
    if ($venvVersion -match "3\.11") {
        Write-Host "OK: Using Python 3.11 (correct)" -ForegroundColor Green
    } elseif ($venvVersion -match "3\.14") {
        Write-Host "PROBLEM: Using Python 3.14 (causes pydantic-core build error)" -ForegroundColor Red
        Write-Host "`nSolution: Run .\clean-and-install.ps1 to reinstall with Python 3.11" -ForegroundColor Yellow
    } else {
        Write-Host "WARNING: Using unexpected Python version" -ForegroundColor Yellow
    }
    
    # Check if packages are installed
    Write-Host "`nChecking installed packages:" -ForegroundColor Yellow
    $packages = @("fastapi", "uvicorn", "pydantic", "numpy", "onnxruntime")
    foreach ($pkg in $packages) {
        $test = & venv\Scripts\python.exe -c "import $($pkg.Replace('-', '_'))" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  OK: $pkg" -ForegroundColor Green
        } else {
            Write-Host "  MISSING: $pkg" -ForegroundColor Red
        }
    }
} else {
    Write-Host "`nNo virtual environment found" -ForegroundColor Red
    Write-Host "Run .\install-py311.ps1 to create one" -ForegroundColor Yellow
}

# Check system Python
Write-Host "`n=== System Python Versions ===" -ForegroundColor Cyan
py --list 2>&1 | ForEach-Object { Write-Host $_ }

Write-Host "`n=== Recommendation ===" -ForegroundColor Cyan
if (Test-Path "venv\Scripts\python.exe") {
    $venvVersion = & venv\Scripts\python.exe --version
    if ($venvVersion -match "3\.14") {
        Write-Host "Run: .\clean-and-install.ps1" -ForegroundColor Yellow
    } elseif ($venvVersion -match "3\.11") {
        Write-Host "Everything looks good! Run: .\start-ai-service.ps1" -ForegroundColor Green
    }
} else {
    Write-Host "Run: .\install-py311.ps1" -ForegroundColor Yellow
}
