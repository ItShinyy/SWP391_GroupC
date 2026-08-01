@echo off
setlocal
cd /d "%~dp0"
echo Loading development seed into SWP391...
sqlcmd -S . -C -b -d SWP391 -i 07_SeedData\001_DevelopmentSeed.sql
if errorlevel 1 (
    echo Seed failed.
    pause
    exit /b 1
)
echo Seed completed. Active model row is ready if AI_MODELS_ROOT/active and models/...901 packages exist.
pause
