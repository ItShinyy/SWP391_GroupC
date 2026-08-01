# Create dummy model files for testing (service will start but won't classify correctly)
# Run from DermAI root: .\scripts\create-dummy-model.ps1

Write-Host "=== Creating Dummy Model Files for Testing ===" -ForegroundColor Cyan
Write-Host "WARNING: This creates placeholder files. AI classification will NOT work!" -ForegroundColor Yellow
Write-Host "Use this only to test if the service starts up correctly.`n" -ForegroundColor Yellow

$activePath = "c:\Users\admin\Downloads\DermAI\DermAI\DermAI-private-artifacts\active"

if (-not (Test-Path $activePath)) {
    New-Item -ItemType Directory -Path $activePath -Force | Out-Null
    Write-Host "Created: $activePath" -ForegroundColor Green
}

# Create dummy labels.json
$labelsJson = @"
{
  "acne": "ACNE",
  "chickenpox": "CHICKENPOX",
  "eczema": "ECZEMA",
  "ringworm": "RINGWORM"
}
"@

$labelsPath = Join-Path $activePath "labels.json"
Set-Content -Path $labelsPath -Value $labelsJson -Encoding UTF8
Write-Host "Created: labels.json" -ForegroundColor Green

# Create dummy metadata.json
$metadataJson = @"
{
  "package_version": "1",
  "name": "DermAI Dummy Model",
  "version": "0.0.1-dummy",
  "confidence_threshold": 0.90,
  "quality": {
    "minWidth": 224,
    "minHeight": 224,
    "minBlurVariance": 100.0,
    "minBrightness": 20.0,
    "maxBrightness": 235.0,
    "minSkinRatio": 0.3
  }
}
"@

$metadataPath = Join-Path $activePath "metadata.json"
Set-Content -Path $metadataPath -Value $metadataJson -Encoding UTF8
Write-Host "Created: metadata.json" -ForegroundColor Green

Write-Host "`nWARNING: Cannot create dummy ONNX model and reference_features.npz" -ForegroundColor Yellow
Write-Host "These require actual trained model data." -ForegroundColor Yellow
Write-Host "`nTo complete the setup, you need:" -ForegroundColor Cyan
Write-Host "  1. model.onnx - The actual ONNX model file" -ForegroundColor White
Write-Host "  2. reference_features.npz - NumPy archive with OOD detection data" -ForegroundColor White
Write-Host "`nContact your team for these files or train a model using:" -ForegroundColor Yellow
Write-Host "  ai-service\exporter\export_model.py" -ForegroundColor Gray

Write-Host "`n=== Files created ===" -ForegroundColor Cyan
Write-Host "Location: $activePath" -ForegroundColor White
Get-ChildItem $activePath | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host "`nMissing (required for service to work):" -ForegroundColor Yellow
Write-Host "  - model.onnx" -ForegroundColor Red
Write-Host "  - reference_features.npz" -ForegroundColor Red
