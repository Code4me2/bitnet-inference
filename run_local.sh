#!/bin/bash

# Simple local runner for BitNet server
# Uses the already-built binary in BitNet/build/bin/llama-server

# Set defaults
export MODEL_PATH="${MODEL_PATH:-$(pwd)/models/ggml-model-i2_s.gguf}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8081}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-$(nproc)}"

# Check if model exists
if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Error: Model not found at $MODEL_PATH"
    echo "Please download the model first:"
    echo "  wget -O models/ggml-model-i2_s.gguf https://huggingface.co/microsoft/BitNet-b1.58-2B-4T-gguf/resolve/main/ggml-model-i2_s.gguf"
    exit 1
fi

# Check if binary exists
LLAMA_SERVER="./BitNet/build/bin/llama-server"
if [[ ! -f "$LLAMA_SERVER" ]]; then
    echo "Error: llama-server not found at $LLAMA_SERVER"
    echo "Please build BitNet first"
    exit 1
fi

echo "Starting BitNet server..."
echo "Model: $MODEL_PATH"
echo "Host: $HOST:$PORT"
echo "Threads: $OMP_NUM_THREADS"

# Run the server
exec $LLAMA_SERVER \
    -m "$MODEL_PATH" \
    --host "$HOST" \
    --port "$PORT" \
    --threads "$OMP_NUM_THREADS" \
    --ctx-size 4096 \
    --batch-size 512