#!/bin/bash
# BitNet Server Startup Script - VERIFIED WORKING
# Tested on: $(date)

# Navigate to BitNet directory
cd "$(dirname "$0")/BitNet" || exit 1

# Check if model exists
if [ ! -f "models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf" ]; then
    echo "Error: Model not found. Please run setup first:"
    echo "  python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s"
    exit 1
fi

# Check if server binary exists
if [ ! -f "build/bin/llama-server" ]; then
    echo "Error: Server binary not found. Please run setup first:"
    echo "  python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s"
    exit 1
fi

# Check if server is already running
if pgrep -f "llama-server.*--port 8081" > /dev/null; then
    echo "Warning: BitNet server is already running on port 8081"
    echo "Use ./stop-server.sh to stop it first, or ./restart-server.sh to restart"
    exit 1
fi

# Start server with verified working parameters
echo "Starting BitNet server on port 8081..."
./build/bin/llama-server \
    -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
    --host 0.0.0.0 \
    --port 8081

# Server output will show:
# main: HTTP server is listening, hostname: 0.0.0.0, port: 8081