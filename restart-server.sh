#!/bin/bash
# BitNet Server Restart Script
# Stops and restarts the BitNet inference server

echo "BitNet Server Restart"
echo "===================="

# Stop the server
echo "Stopping server..."
./stop-server.sh

# Wait a moment to ensure port is released
sleep 2

# Start the server
echo ""
echo "Starting server..."
./start-server.sh