# Script to fix all hardcoded paths for current user (admin)
# Run from DermAI root: .\scripts\fix-paths-for-admin.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== Fixing Paths for Current User ===" -ForegroundColor Cyan

# Get current user
$currentUser = $env:USERNAME
Write-Host "`nCurrent user: $currentUser" -ForegroundColor Yellow

# Define paths
$projectRoot = "c:\Users\admin\Downloads\DermAI\DermAI"
$modelsPath = "c:\Users\admin\Downloads\DermAI\DermAI\DermAI-private-artifacts"

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host "Models path: $modelsPath" -ForegroundColor Gray

# Create models directory if it doesn't exist
if (-not (Test-Path $modelsPath)) {
    Write-Host "`nCreating models directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $modelsPath -Force | Out-Null
    
    # Create active subdirectory
    $activePath = Join-Path $modelsPath "active"
    New-Item -ItemType Directory -Path $activePath -Force | Out-Null
    
    Write-Host "OK: Created $modelsPath" -ForegroundColor Green
    Write-Host "OK: Created $activePath" -ForegroundColor Green
    Write-Host "`nWARNING: You need to put model files in the active/ folder:" -ForegroundColor Yellow
    Write-Host "  - model.onnx" -ForegroundColor White
    Write-Host "  - labels.json" -ForegroundColor White
    Write-Host "  - reference_features.npz" -ForegroundColor White
    Write-Host "  - metadata.json" -ForegroundColor White
} else {
    Write-Host "`nOK: Models directory already exists" -ForegroundColor Green
}

# Fix local.properties
Write-Host "`nFixing local.properties..." -ForegroundColor Yellow
$localPropsPath = Join-Path $projectRoot "local.properties"

if (Test-Path $localPropsPath) {
    $content = Get-Content $localPropsPath -Raw
    $oldPath = "C:/Users/phong/Downloads/SWP391/DermAI-private-artifacts"
    $newPath = $modelsPath.Replace('\', '/')
    
    if ($content -match [regex]::Escape($oldPath)) {
        $content = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content -Path $localPropsPath -Value $content -NoNewline
        Write-Host "OK: Updated local.properties" -ForegroundColor Green
        Write-Host "   Changed: $oldPath" -ForegroundColor Gray
        Write-Host "   To:      $newPath" -ForegroundColor Gray
    } else {
        Write-Host "OK: local.properties already has correct path" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: local.properties not found" -ForegroundColor Yellow
}

# Fix ai-service/.env.local
Write-Host "`nFixing ai-service/.env.local..." -ForegroundColor Yellow
$envLocalPath = Join-Path $projectRoot "ai-service\.env.local"

if (Test-Path $envLocalPath) {
    $content = Get-Content $envLocalPath -Raw
    $oldPath = "C:/Users/phong/Downloads/SWP391/DermAI-private-artifacts"
    $newPath = $modelsPath.Replace('\', '/')
    
    if ($content -match [regex]::Escape($oldPath)) {
        $content = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content -Path $envLocalPath -Value $content -NoNewline
        Write-Host "OK: Updated .env.local" -ForegroundColor Green
        Write-Host "   Changed: $oldPath" -ForegroundColor Gray
        Write-Host "   To:      $newPath" -ForegroundColor Gray
    } else {
        Write-Host "OK: .env.local already has correct path" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: .env.local not found" -ForegroundColor Yellow
    Write-Host "Run: cd ai-service; copy .env.local.example .env.local" -ForegroundColor White
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "`nPaths configured:" -ForegroundColor Green
Write-Host "  Models root: $modelsPath" -ForegroundColor White
Write-Host "  Active dir:  $modelsPath\active" -ForegroundColor White

Write-Host "`nFiles updated:" -ForegroundColor Green
if (Test-Path $localPropsPath) {
    Write-Host "  [OK] local.properties" -ForegroundColor White
}
if (Test-Path $envLocalPath) {
    Write-Host "  [OK] ai-service\.env.local" -ForegroundColor White
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Put ONNX model files in: $modelsPath\active" -ForegroundColor White
Write-Host "     Required files:" -ForegroundColor Gray
Write-Host "       - model.onnx" -ForegroundColor Gray
Write-Host "       - labels.json" -ForegroundColor Gray
Write-Host "       - reference_features.npz" -ForegroundColor Gray
Write-Host "       - metadata.json" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Restart AI service: cd ai-service; .\start-ai-service.ps1" -ForegroundColor White
Write-Host ""
Write-Host "  3. Rebuild Java app if needed" -ForegroundColor White
