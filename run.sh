#!/bin/bash

# Configuration
# 1. Detect Backend Location
if [ -d "$BACKEND_DIR" ]; then
    TARGET_BACKEND="$BACKEND_DIR"
elif [ -d "resources/$BACKEND_DIR" ]; then
    TARGET_BACKEND="resources/$BACKEND_DIR"
else
    echo "[ERROR] $BACKEND_DIR folder not found!"
    exit 1
fi

export DB_DATABASE="$(pwd)/$TARGET_BACKEND/database/database.sqlite"

# 2. Initialize Database
echo "[PROCESS] Checking Database at $DB_DATABASE..."
if [ ! -f "$DB_DATABASE" ]; then
    echo "[INFO] Database file not found. Creating a new one..."
    mkdir -p "$(dirname "$DB_DATABASE")"
    touch "$DB_DATABASE"
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create database file at $DB_DATABASE"
        exit 1
    fi
    echo "[SUCCESS] Database file created."
fi

cd "$TARGET_BACKEND"

# 3. Prevent Duplicate Processes (Close existing PHP server on port 8000)
echo "[PROCESS] Closing any existing backend server..."
fuser -k 8000/tcp > /dev/null 2>&1

echo "[PROCESS] Synchronizing Database schema (Migrations)..."
php artisan migrate --force --no-interaction
if [ $? -ne 0 ]; then
    echo "[ERROR] Migration failed! Please check your PHP installation and .env file."
    cd ..
    exit 1
fi
echo "[SUCCESS] Database is ready."

# 3. Start Backend in the background
echo "[PROCESS] Starting Backend server on port 8000..."
# Start server and redirect output to a log file
php artisan serve --port=8000 > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "[SUCCESS] Backend started with PID $BACKEND_PID"

# 4. Start Frontend
echo "[PROCESS] Starting Frontend ($FRONTEND_BIN)..."
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
