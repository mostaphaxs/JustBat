@echo off
setlocal

:: Configuration
set BACKEND_DIR=app2BackEnd
set FRONTEND_EXE=MyAmical.exe
set APP_API_URL=http://127.0.0.1:8000/api

:: 1. Detect Backend Location
if exist "%BACKEND_DIR%" (
    set TARGET_BACKEND=%BACKEND_DIR%
) else if exist "resources\%BACKEND_DIR%" (
    set TARGET_BACKEND=resources\%BACKEND_DIR%
) else (
    echo [ERROR] %BACKEND_DIR% folder not found!
    pause
    exit /b
)

set DB_DATABASE=%CD%\%TARGET_BACKEND%\database\database.sqlite

:: 2. Initialize Database
echo [PROCESS] Checking Database at %DB_DATABASE%...
if not exist "%DB_DATABASE%" (
    echo [INFO] Database file not found. Creating a new one...
    for %%I in ("%DB_DATABASE%") do if not exist "%%~dpI" mkdir "%%~dpI"
    copy /y nul "%DB_DATABASE%" >nul
    if errorlevel 1 (
        echo [ERROR] Failed to create database file at %DB_DATABASE%
        pause
        exit /b
    )
    echo [SUCCESS] Database file created.
)

cd %TARGET_BACKEND%

:: 3. Prevent Duplicate Processes (Close existing PHP server on port 8000)
echo [PROCESS] Closing any existing backend server...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000') do taskkill /f /pid %%a >nul 2>&1

echo [PROCESS] Synchronizing Database schema (Migrations)...
php artisan migrate --force --no-interaction
if errorlevel 1 (
    echo [ERROR] Migration failed! Please check your PHP installation and .env file.
    cd ..
    pause
    exit /b
)
echo [SUCCESS] Database is ready.

:: 3. Start Backend in a separate window
echo [PROCESS] Starting Backend server on port 8000...
start "MyAmical Backend" /min php artisan serve --port=8000
cd ..

:: 4. Start Frontend
echo [PROCESS] Starting Frontend (%FRONTEND_EXE%)...
if exist "%FRONTEND_EXE%" (
    start "" "%FRONTEND_EXE%"
) else (
    echo [ERROR] %FRONTEND_EXE% not found! 
    echo Please make sure you have built the application and placed the .exe in this folder.
    pause
)

echo Application started!
endlocal
