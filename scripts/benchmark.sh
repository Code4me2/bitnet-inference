#!/bin/bash

# BitNet Performance Benchmark Script

echo "Running BitNet performance benchmark..."

# Navigate to BitNet directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")/BitNet" || exit 1

# Check if model exists
MODEL_PATH="models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf"
if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model not found at $MODEL_PATH"
    echo "Please ensure the model is downloaded first."
    exit 1
fi

# Get system info
CPU_CORES=$(nproc)
echo "=== System Information ==="
echo "CPU Cores: $CPU_CORES"
echo "Architecture: $(uname -m)"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo ""

# Run the actual benchmark
if [ -f "python/benchmarks/benchmark.py" ]; then
    echo "Starting comprehensive benchmark..."
    python3 python/benchmarks/benchmark.py
elif [ -f "utils/e2e_benchmark.py" ]; then
    echo "Starting end-to-end benchmark..."
    python3 utils/e2e_benchmark.py -m "$MODEL_PATH" -p 256 -n 128
else
    echo "Running basic performance test..."
    echo "Testing with different thread counts..."
    
    for threads in 1 2 4 8 $CPU_CORES; do
        if [[ $threads -le $CPU_CORES ]]; then
            echo ""
            echo "=== Testing with $threads threads ==="
            python3 python/benchmarks/run_inference.py \
                -m "$MODEL_PATH" \
                -p "The quick brown fox jumps over the lazy dog. This is a comprehensive test to measure the inference performance of the BitNet model." \
                -n 100 \
                -t $threads
        fi
    done
fi

echo ""
echo "Benchmark complete!"