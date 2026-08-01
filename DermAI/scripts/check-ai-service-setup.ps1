# Check AI Service setup
# Run: .\scripts\check-ai-service-setup.ps1

Write-Host "=== Checking AI Service Setup ===" -ForegroundColor Cyan

$allOk = $true

# Check 1: local.properties
Write-Host "`n[1/5] Checking local.properties..." -ForegroundColor Yellow
$localProps = "local.properties"
if (Test-Path $localProps) {
    $content = Get-Content $localProps -Raw
    if ($content -match "AI_MODELS_ROOT=(.+)") {
        $modelsRoot = $matches[1].Trim()
        Write-Host "  AI_MODELS_ROOT: $modelsRoot" -ForegroundColor White
        
        if ($modelsRoot -match "phong") {
            Write-Host "  WARNING: Still has old path with 'phong'" -ForegroundColor Red
            Write-Host "  Run: .\scripts\fix-paths-for-admin.ps1" -ForegroundColor Yellow
            $allOk = $false
        } else {
            Write-Host "  OK: Path looks correct" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ERROR: local.properties not found" -ForegroundColor Red
    $allOk = $false
}

# Check 2: ai-service/.env.local
Write-Host "`n[2/5] Checking ai-service/.env.local..." -ForegroundColor Yellow
$envLocal = "ai-service\.env.local"
if (Test-Path $envLocal) {
    $content = Get-Content $envLocal -Raw
    if ($content -match "AI_MODELS_ROOT=(.+)") {
        $modelsRoot = $matches[1].Trim()
        Write-Host "  AI_MODELS_ROOT: $modelsRoot" -ForegroundColor White
        
        if ($modelsRoot -match "phong") {
            Write-Host "  WARNING: Still has old path with 'phong'" -ForegroundColor Red
            Write-Host "  Run: .\scripts\fix-paths-for-admin.ps1" -ForegroundColor Yellow
            $allOk = $false
        } else {
            Write-Host "  OK: Path looks correct" -ForegroundColor Green
        }
    }
    
    if ($content -match "AI_SERVICE_API_KEY=(.+)") {
        Write-Host "  OK: AI_SERVICE_API_KEY is set" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: AI_SERVICE_API_KEY missing" -ForegroundColor Red
        $allOk = $false
    }
} else {
    Write-Host "  ERROR: .env.local not found" -ForegroundColor Red
    Write-Host "  Run: cd ai-service; copy .env.local.example .env.local" -ForegroundColor Yellow
    $allOk = $false
}

# Check 3: Models directory
Write-Host "`n[3/5] Checking models directory..." -ForegroundColor Yellow
$modelsPath = "c:\Users\admin\Downloads\DermAI\DermAI\DermAI-private-artifacts"
$activePath = Join-Path $modelsPath "active"

if (Test-Path $modelsPath) {
    Write-Host "  OK: Models root exists: $modelsPath" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Models root missing: $modelsPath" -ForegroundColor Red
    Write-Host "  Run: .\scripts\fix-paths-for-admin.ps1" -ForegroundColor Yellow
    $allOk = $false
}

if (Test-Path $activePath) {
    Write-Host "  OK: Active directory exists: $activePath" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Active directory missing: $activePath" -ForegroundColor Red
    $allOk = $false
}

# Check 4: Required model files
Write-Host "`n[4/5] Checking required model files..." -ForegroundColor Yellow
$requiredFiles = @("model.onnx", "labels.json", "reference_features.npz", "metadata.json")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    $filePath = Join-Path $activePath $file
    if (Test-Path $filePath) {
        $size = (Get-Item $filePath).Length
        Write-Host "  OK: $file ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $file" -ForegroundColor Red
        $missingFiles += $file
        $allOk = $false
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`n  You need to add these files to: $activePath" -ForegroundColor Yellow
    Write-Host "  Contact your team for the actual model files." -ForegroundColor White
}

# Check 5: AI Service
Write-Host "`n[5/5] Checking AI Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "  OK: AI Service is running" -ForegroundColor Green
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "  NOT RUNNING: AI Service is not responding" -ForegroundColor Yellow
    Write-Host "  Start with: cd ai-service; .\start-ai-service.ps1" -ForegroundColor Gray
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($allOk -and $missingFiles.Count -eq 0) {
    Write-Host "All checks passed! AI Service should work." -ForegroundColor Green
} elseif ($missingFiles.Count -gt 0) {
    Write-Host "Setup is correct but model files are missing." -ForegroundColor Yellow
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Get model files from your team" -ForegroundColor White
    Write-Host "  2. Copy them to: $activePath" -ForegroundColor White
    Write-Host "  3. Restart AI service" -ForegroundColor White
} else {
    Write-Host "Some checks failed. Fix the issues above." -ForegroundColor Red
    Write-Host "`nQuick fix: .\scripts\fix-paths-for-admin.ps1" -ForegroundColor Yellow
}
