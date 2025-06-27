#!/bin/bash
# BitNet Server Shutdown Script
# Gracefully stops the BitNet inference server

echo "BitNet Server Shutdown"
echo "====================="

# Find llama-server process
SERVER_PID=$(pgrep -f "llama-server.*--port 8081")

if [ -z "$SERVER_PID" ]; then
    echo "✓ BitNet server is not running"
    exit 0
fi

echo "Found BitNet server running with PID: $SERVER_PID"

# First try graceful shutdown with SIGTERM
echo "Sending shutdown signal..."
kill -TERM $SERVER_PID 2>/dev/null

# Wait up to 5 seconds for graceful shutdown
for i in {1..5}; do
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        echo "✓ Server stopped gracefully"
        exit 0
    fi
    echo "  Waiting for server to stop... ($i/5)"
    sleep 1
done

# If still running, force kill
if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "Server didn't stop gracefully, forcing shutdown..."
    kill -KILL $SERVER_PID 2>/dev/null
    sleep 1
    
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        echo "✓ Server forcefully stopped"
    else
        echo "✗ Failed to stop server"
        exit 1
    fi
fi

# Clean up any stray processes
pkill -f "llama-server.*--port 8081" 2>/dev/null

echo ""
echo "Shutdown complete!"