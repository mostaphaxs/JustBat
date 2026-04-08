@echo off
setlocal

:: Configuration
set BACKEND_DIR=app2BackEnd
set FRONTEND_EXE=MyAmical.exe
set APP_API_URL=http://127.0.0.1:8000/api
set DB_DATABASE=%CD%\%BACKEND_DIR%\database\database.sqlite

echo Starting MyAmical Application...

:: 1. Start Backend in a separate window
echo Starting Backend (Laravel)...
cd %BACKEND_DIR%
:: Ensure dependencies and migrations (optional but recommended)
:: start /min cmd /c "php artisan migrate --force"
start "MyAmical Backend" /min php artisan serve --port=8000
cd ..

:: 2. Start Frontend
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
