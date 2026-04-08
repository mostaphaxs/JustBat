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

echo "Starting MyAmical Application..."

# 2. Start Backend in the background
echo "Starting Backend (Laravel) in $TARGET_BACKEND..."
cd "$TARGET_BACKEND"
# Start server and redirect output to a log file
php artisan serve --port=8000 > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "Backend started with PID $BACKEND_PID"

# 3. Start Frontend
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
