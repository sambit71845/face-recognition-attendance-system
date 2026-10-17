#!/usr/bin/env bash
set -e

# Face Recognition Attendance System - All-in-One Launcher

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

echo "=========================================================="
echo "🚀 Starting Face Recognition Attendance System"
echo "=========================================================="

# Check Python environment
if [ ! -d "$BACKEND_DIR/venv" ]; then
    echo "⚠️  Backend venv not found. Creating virtual environment..."
    python3 -m venv "$BACKEND_DIR/venv"
    "$BACKEND_DIR/venv/bin/pip" install -r "$BACKEND_DIR/requirements.txt"
fi

# Cleanup on exit (Ctrl+C)
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    if [ -n "$BACKEND_PID" ]; then
        kill "$BACKEND_PID" 2>/dev/null || true
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# Start Backend
echo "📡 [1/2] Launching Backend (FastAPI on http://localhost:8000)..."
(
    cd "$BACKEND_DIR"
    ./venv/bin/python main.py
) &
BACKEND_PID=$!

# Wait briefly for backend to initialize
sleep 2

# Start Frontend
echo "💻 [2/2] Launching Frontend (Next.js on http://localhost:3000)..."
(
    cd "$FRONTEND_DIR"
    pnpm dev
)
