# Build a DermAI package zip for Admin upload from prepared ONNX + OOD + labels.
param(
    [Parameter(Mandatory = $true)][string]$OnnxPath,
    [Parameter(Mandatory = $true)][string]$OodPath,
    [Parameter(Mandatory = $true)][string]$LabelsPath,
    [Parameter(Mandatory = $true)][string]$OutputZip,
    [string]$Name = 'DermAI',
    [string]$Version = 'yolo26s-v2'
)

$ErrorActionPreference = 'Stop'
$stage = Join-Path $env:TEMP ("dermai-pkg-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $stage | Out-Null
Copy-Item -LiteralPath $OnnxPath -Destination (Join-Path $stage 'model.onnx')
Copy-Item -LiteralPath $OodPath -Destination (Join-Path $stage 'reference_features.npz')
Copy-Item -LiteralPath $LabelsPath -Destination (Join-Path $stage 'labels.json')
$metadata = @{
    package_version = '1'
    name = $Name
    version = $Version
    confidence_threshold = 0.90
    quality = @{
        minWidth = 64
        minHeight = 64
        minBlurVariance = 10.0
        minBrightness = 15.0
        maxBrightness = 245.0
        minSkinRatio = 0.05
    }
} | ConvertTo-Json -Depth 5
Set-Content -LiteralPath (Join-Path $stage 'metadata.json') -Value $metadata -Encoding utf8
if (Test-Path $OutputZip) { Remove-Item -LiteralPath $OutputZip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $OutputZip
Remove-Item -LiteralPath $stage -Recurse -Force
Write-Host "Wrote $OutputZip"
