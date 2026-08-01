@echo off
setlocal
cd /d "%~dp0"

echo WARNING: This permanently deletes SWP391 and all of its data.
choice /C YN /N /M "Continue"
if errorlevel 2 exit /b 0

sqlcmd -S .\SQLEXPRESS -U sa -P 123 -C -b -d master -i WipeDatabase.sql
if errorlevel 1 (
    echo Database wipe failed. Review the sqlcmd output above.
    pause
    exit /b 1
)

echo SWP391 was deleted. Run Deploy.bat, then Seed.bat.
pause
