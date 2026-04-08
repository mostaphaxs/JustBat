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

echo Starting MyAmical Application...

:: 2. Start Backend in a separate window
echo Starting Backend (Laravel) in %TARGET_BACKEND%...
cd %TARGET_BACKEND%
start "MyAmical Backend" /min php artisan serve --port=8000
cd ..

:: 3. Start Frontend
echo Starting Frontend (%FRONTEND_EXE%)...
if exist "%FRONTEND_EXE%" (
    start "" "%FRONTEND_EXE%"
) else (
    echo [ERROR] %FRONTEND_EXE% not found! 
    echo Please make sure you have built the application and placed the .exe in this folder.
    pause
)

echo Application started!
endlocal
