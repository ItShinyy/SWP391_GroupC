@echo off
setlocal
cd /d "%~dp0"

echo Deploying the SWP391 database project...
sqlcmd -S .\SQLEXPRESS -U sa -P 123 -C -b -i Master_Deploy.sql
if errorlevel 1 (
    echo Deployment failed. Review the sqlcmd output above.
    pause
    exit /b 1
)

echo Deployment completed successfully.
pause
