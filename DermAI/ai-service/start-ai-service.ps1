# Script khoi dong AI Service nhanh
# Chay tu thu muc ai-service: .\start-ai-service.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== Khoi dong AI Service ===" -ForegroundColor Cyan

# Kiem tra venv
if (-not (Test-Path "venv\Scripts\python.exe")) {
    Write-Host "ERROR: Virtual environment chua duoc tao!" -ForegroundColor Red
    Write-Host "Chay .\setup-ai-service.ps1 truoc" -ForegroundColor Yellow
    exit 1
}

# Kiem tra .env.local
if (-not (Test-Path ".env.local")) {
    Write-Host "ERROR: .env.local chua ton tai!" -ForegroundColor Red
    Write-Host "Copy .env.local.example sang .env.local va chinh sua" -ForegroundColor Yellow
    exit 1
}

Write-Host "OK: Virtual environment OK" -ForegroundColor Green
Write-Host "OK: .env.local OK" -ForegroundColor Green

Write-Host "`nDang khoi dong FastAPI server..." -ForegroundColor Yellow
Write-Host "URL: http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "Health: http://127.0.0.1:8000/health" -ForegroundColor Cyan
Write-Host "Docs: http://127.0.0.1:8000/docs" -ForegroundColor Cyan
Write-Host "`nNhan Ctrl+C de dung..." -ForegroundColor Gray
Write-Host ""

# Activate va chay
& venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
