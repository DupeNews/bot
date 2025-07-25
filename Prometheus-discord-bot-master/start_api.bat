@echo off
echo Starting Prometheus Obfuscator API...
echo.

echo Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Building project...
call npm run build
if %errorlevel% neq 0 (
    echo Failed to build project
    pause
    exit /b 1
)

echo.
echo Starting API server on port 3000...
echo You can test it at: http://localhost:3000/health
echo.
call npm run start:api
