@echo off
REM ðŸš€ CHETOS Bot - Prometheus API Windows Installer
REM This script installs the Prometheus Obfuscator API on Windows

setlocal enabledelayedexpansion

echo ================================
echo ðŸš€ CHETOS Bot - Prometheus API Installer
echo ================================
echo.

REM Configuration
set REPO_URL=https://github.com/DupeNews/bot.git
set PROJECT_DIR=bot
set API_DIR=Prometheus-discord-bot-master
set API_PORT=3000

echo [INFO] Starting Windows installation...
echo [INFO] Repository: %REPO_URL%
echo [INFO] Installation Directory: %PROJECT_DIR%
echo [INFO] API Port: %API_PORT%
echo.

REM Check if Node.js is installed
echo [INFO] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed!
    echo [INFO] Please install Node.js from: https://nodejs.org/
    echo [INFO] Download the LTS version and run this script again.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Node.js is installed: 
    node --version
)

REM Check if npm is available
echo [INFO] Checking npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not available!
    echo [INFO] Please reinstall Node.js from: https://nodejs.org/
    pause
    exit /b 1
) else (
    echo [SUCCESS] npm is available: 
    npm --version
)

REM Check if Git is installed
echo [INFO] Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed!
    echo [INFO] Please install Git from: https://git-scm.com/download/win
    echo [INFO] Download and install Git, then run this script again.
    pause
    exit /b 1
) else (
    echo [SUCCESS] Git is installed: 
    git --version
)

echo.
echo [INFO] All prerequisites are installed!
echo.

REM Ask for confirmation
set /p confirm="Continue with installation? (y/N): "
if /i not "%confirm%"=="y" (
    echo [INFO] Installation cancelled.
    pause
    exit /b 0
)

echo.
echo ================================
echo Cloning Repository
echo ================================

REM Remove existing directory if it exists
if exist "%PROJECT_DIR%" (
    echo [WARNING] Directory %PROJECT_DIR% already exists.
    set /p remove="Remove and re-clone? (y/N): "
    if /i "!remove!"=="y" (
        echo [INFO] Removing existing directory...
        rmdir /s /q "%PROJECT_DIR%"
    ) else (
        echo [INFO] Using existing directory.
        goto :install_deps
    )
)

echo [INFO] Cloning repository from %REPO_URL%...
git clone "%REPO_URL%" "%PROJECT_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone repository!
    pause
    exit /b 1
)
echo [SUCCESS] Repository cloned successfully.

:install_deps
echo.
echo ================================
echo Installing Dependencies
echo ================================

cd "%PROJECT_DIR%\%API_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Could not enter directory %PROJECT_DIR%\%API_DIR%
    pause
    exit /b 1
)

if not exist "package.json" (
    echo [ERROR] package.json not found in %API_DIR%
    pause
    exit /b 1
)

echo [INFO] Installing npm dependencies...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies!
    pause
    exit /b 1
)

echo [INFO] Building the project...
npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build project!
    pause
    exit /b 1
)

echo [SUCCESS] Dependencies installed and project built successfully.

echo.
echo ================================
echo Installing PM2 Process Manager
echo ================================

echo [INFO] Installing PM2 globally...
npm install -g pm2
if %errorlevel% neq 0 (
    echo [WARNING] Failed to install PM2 globally. You may need to run as administrator.
    echo [INFO] You can start the API manually with: npm run start:api
    goto :start_manual
)

echo [SUCCESS] PM2 installed successfully.

echo.
echo ================================
echo Starting Services
echo ================================

echo [INFO] Starting API with PM2...
pm2 start npm --name "prometheus-api" -- run start:api
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start with PM2. Trying manual start...
    goto :start_manual
)

pm2 save
echo [SUCCESS] API started with PM2.
goto :test_api

:start_manual
echo [INFO] Starting API manually...
echo [WARNING] This will run in the current window. Close this window to stop the API.
echo [INFO] Press Ctrl+C to stop the API when needed.
echo.
start /b npm run start:api
timeout /t 5 /nobreak >nul

:test_api
echo.
echo ================================
echo Testing Installation
echo ================================

echo [INFO] Waiting for API to start...
timeout /t 5 /nobreak >nul

echo [INFO] Testing API health endpoint...
curl -s http://localhost:%API_PORT%/health >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Could not test API with curl. Please test manually.
    echo [INFO] Open your browser and go to: http://localhost:%API_PORT%/health
) else (
    echo [SUCCESS] API is responding on port %API_PORT%
)

echo.
echo ================================
echo Installation Complete!
echo ================================
echo.
echo ðŸŽ‰ Prometheus Obfuscator API has been successfully installed!
echo.
echo ðŸ“‹ Installation Summary:
echo   â€¢ Repository: %REPO_URL%
echo   â€¢ Installation Directory: %cd%
echo   â€¢ API Port: %API_PORT%
echo.
echo ðŸ”— API Endpoints:
echo   â€¢ Health Check: http://localhost:%API_PORT%/health
echo   â€¢ Available Presets: http://localhost:%API_PORT%/presets
echo   â€¢ Obfuscate Text: http://localhost:%API_PORT%/obfuscate-text
echo   â€¢ Obfuscate File: http://localhost:%API_PORT%/obfuscate
echo.
echo ðŸ› ï¸ Management Commands:
echo   â€¢ Check Status: pm2 status
echo   â€¢ View Logs: pm2 logs prometheus-api
echo   â€¢ Restart API: pm2 restart prometheus-api
echo   â€¢ Stop API: pm2 stop prometheus-api
echo.
echo âš™ï¸ Configuration:
echo   â€¢ Update your bot's prometheus_config.py file
echo   â€¢ Set PROMETHEUS_API_URL = "http://localhost:%API_PORT%"
echo   â€¢ Or use your server's public IP/domain
echo.
echo ðŸ“ Next Steps:
echo   1. Update your Discord bot configuration
echo   2. Test the API: http://localhost:%API_PORT%/health
echo   3. Use /prometheus-status command in Discord to verify connection
echo.
echo âœ… Your Prometheus API is now running and ready to use!
echo.

cd ..\..

pause
