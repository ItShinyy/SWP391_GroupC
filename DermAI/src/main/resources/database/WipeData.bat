@echo off
setlocal
cd /d "%~dp0"

echo WARNING: This permanently deletes all SWP391 data but keeps the schema.
choice /C YN /N /M "Continue"
if errorlevel 2 exit /b 0

sqlcmd -S . -C -b -d SWP391 -i WipeData.sql
if errorlevel 1 (
    echo Data wipe failed. Review the sqlcmd output above.
    pause
    exit /b 1
)

echo All SWP391 data was deleted. Run Seed.bat to reload development fixtures.
pause
