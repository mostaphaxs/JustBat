#!/bin/bash

# Configuration
BACKEND_DIR="app2BackEnd"
FRONTEND_BIN="./MyAmical"
export APP_API_URL="http://127.0.0.1:8000/api"
export DB_DATABASE="$(pwd)/$BACKEND_DIR/database/database.sqlite"

echo "Starting MyAmical Application..."

# 1. Start Backend in the background
echo "Starting Backend (Laravel)..."
if [ -d "$BACKEND_DIR" ]; then
    cd "$BACKEND_DIR"
    # Start server and redirect output to a log file
    php artisan serve --port=8000 > ../backend.log 2>&1 &
    BACKEND_PID=$!
    cd ..
    echo "Backend started with PID $BACKEND_PID"
else
    echo "[ERROR] $BACKEND_DIR not found!"
    exit 1
fi

# 2. Start Frontend
echo "Starting Frontend ($FRONTEND_BIN)..."
if [ -f "$FRONTEND_BIN" ]; then
    chmod +x "$FRONTEND_BIN"
    "$FRONTEND_BIN"
else
    echo "[ERROR] $FRONTEND_BIN not found!"
    echo "Please build the application and place the binary in this folder."
    # Kill backend if frontend fails
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Cleanup: Kill backend when frontend exits
echo "Application closed. Cleaning up..."
kill $BACKEND_PID 2>/dev/null
