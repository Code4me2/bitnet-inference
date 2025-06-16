#!/bin/bash

# BitNet.cpp Optimized Startup Script

set -e

echo "Starting BitNet.cpp inference server..."

# Source CPU detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "/app/scripts" ]]; then
    # Running in Docker
    source /app/scripts/detect_cpu.sh
elif [[ -d "$SCRIPT_DIR/scripts" ]]; then
    # Running locally
    source "$SCRIPT_DIR/scripts/detect_cpu.sh"
else
    echo "Error: Cannot find scripts directory"
    exit 1
fi
CPU_INFO=$(detect_cpu_info)
eval "$CPU_INFO"

echo "Detected: $CPU_CORES cores, $MEMORY_GB GB RAM, $CPU_TYPE"

# Determine optimal configuration
if [[ $BITNET_KERNEL == "auto" ]]; then
    if [[ -d "/app/scripts" ]]; then
        source /app/scripts/select_kernel.sh
    else
        source "$SCRIPT_DIR/scripts/select_kernel.sh"
    fi
    KERNEL_INFO=$(select_optimal_kernel $CPU_CORES $MEMORY_GB "medium" "balanced")
    eval "$KERNEL_INFO"
    BITNET_KERNEL=$RECOMMENDED_KERNEL
    echo "Auto-selected kernel: $BITNET_KERNEL"
fi

# Set optimal thread count
if [[ $OMP_NUM_THREADS == "auto" ]]; then
    THREAD_INFO=$(optimize_threading $CPU_CORES $BITNET_KERNEL $MEMORY_GB)
    eval "$THREAD_INFO"
    export OMP_NUM_THREADS=$OPTIMAL_THREADS
    echo "Auto-configured threads: $OMP_NUM_THREADS"
fi

# Set CPU affinity
if [[ $CPU_AFFINITY == "auto" ]]; then
    AFFINITY_INFO=$(generate_cpu_affinity $OMP_NUM_THREADS $CPU_CORES)
    eval "$AFFINITY_INFO"
    CPU_AFFINITY=$CPU_AFFINITY_MASK
    echo "CPU affinity: $CPU_AFFINITY"
fi

# Validate model exists
if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Error: Model file not found at $MODEL_PATH"
    echo "Please ensure the model is downloaded and mounted correctly."
    exit 1
fi

# Print configuration summary
echo "=== BitNet.cpp Configuration ==="
echo "Model: $MODEL_PATH"
echo "Kernel: $BITNET_KERNEL"
echo "Threads: $OMP_NUM_THREADS"
echo "CPU Affinity: $CPU_AFFINITY"
echo "Host: $HOST"
echo "Port: $PORT"
echo "================================"

# Find llama-server binary
if command -v llama-server &> /dev/null; then
    LLAMA_SERVER="llama-server"
elif [[ -f "/app/BitNet/build/bin/llama-server" ]]; then
    LLAMA_SERVER="/app/BitNet/build/bin/llama-server"
elif [[ -f "/usr/local/bin/llama-server" ]]; then
    LLAMA_SERVER="/usr/local/bin/llama-server"
elif [[ -f "./BitNet/build/bin/llama-server" ]]; then
    LLAMA_SERVER="./BitNet/build/bin/llama-server"
elif [[ -f "$SCRIPT_DIR/BitNet/build/bin/llama-server" ]]; then
    LLAMA_SERVER="$SCRIPT_DIR/BitNet/build/bin/llama-server"
else
    echo "Error: llama-server binary not found!"
    exit 1
fi

echo "Using llama-server at: $LLAMA_SERVER"

# Start server with optimal settings
if [[ $CPU_AFFINITY != "auto" ]] && [[ $CPU_AFFINITY != "" ]]; then
    echo "Starting with CPU affinity..."
    exec taskset -c $CPU_AFFINITY $LLAMA_SERVER \
        -m "$MODEL_PATH" \
        --host "$HOST" \
        --port "$PORT" \
        --threads "$OMP_NUM_THREADS" \
        --ctx-size 4096 \
        --batch-size 512
else
    echo "Starting without CPU affinity..."
    exec $LLAMA_SERVER \
        -m "$MODEL_PATH" \
        --host "$HOST" \
        --port "$PORT" \
        --threads "$OMP_NUM_THREADS" \
        --ctx-size 4096 \
        --batch-size 512
fi