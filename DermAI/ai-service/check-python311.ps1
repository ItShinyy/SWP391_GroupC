# Quick check for Python 3.11
Write-Host "=== Checking for Python 3.11 ===" -ForegroundColor Cyan

Write-Host "`nAll installed Python versions:" -ForegroundColor Yellow
try {
    py --list 2>&1 | ForEach-Object { Write-Host $_ }
} catch {
    Write-Host "Python launcher (py) not available" -ForegroundColor Red
}

Write-Host "`nChecking Python 3.11 specifically:" -ForegroundColor Yellow
try {
    $version = py -3.11 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $version" -ForegroundColor Green
        Write-Host "`nYou can proceed with installation:" -ForegroundColor Cyan
        Write-Host "  .\install-py311.ps1" -ForegroundColor White
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "NOT FOUND: Python 3.11" -ForegroundColor Red
    Write-Host "`nTo install Python 3.11:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://www.python.org/downloads/release/python-3118/" -ForegroundColor White
    Write-Host "2. Run installer and CHECK:" -ForegroundColor White
    Write-Host "   [x] Add Python to PATH" -ForegroundColor Green
    Write-Host "   [x] Install launcher for all users" -ForegroundColor Green
    Write-Host "3. Restart PowerShell" -ForegroundColor White
    Write-Host "4. Run this check again" -ForegroundColor White
}
