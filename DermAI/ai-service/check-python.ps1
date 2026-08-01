# Check available Python versions
Write-Host "=== Checking Python Installations ===" -ForegroundColor Cyan

# Check py launcher
Write-Host "`n[1] Python Launcher (py):" -ForegroundColor Yellow
try {
    py --list 2>&1 | ForEach-Object { Write-Host $_ }
} catch {
    Write-Host "Python launcher not available" -ForegroundColor Red
}

# Check specific versions
Write-Host "`n[2] Testing specific versions:" -ForegroundColor Yellow

$versions = @("3.14", "3.13", "3.12", "3.11", "3.10")
foreach ($ver in $versions) {
    try {
        $result = py -$ver --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OK: Python $ver - $result" -ForegroundColor Green
        }
    } catch {
        Write-Host "NOT FOUND: Python $ver" -ForegroundColor Gray
    }
}

# Check default python
Write-Host "`n[3] Default Python:" -ForegroundColor Yellow
try {
    $default = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $default" -ForegroundColor Green
    }
} catch {
    Write-Host "NOT FOUND: python command" -ForegroundColor Red
}

Write-Host "`n[4] Recommendation:" -ForegroundColor Yellow
Write-Host "For this project, use Python 3.11 or newer (3.14 works too)" -ForegroundColor White
Write-Host "To install specific version:" -ForegroundColor White
Write-Host "  py -3.14 -m venv venv" -ForegroundColor Gray
