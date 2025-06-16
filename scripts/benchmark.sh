#!/bin/bash

# Performance Benchmark Script

MODEL_PATH=${1:-"/models/ggml-model-i2_s.gguf"}
OUTPUT_FILE=${2:-"/tmp/benchmark_results.txt"}

echo "Running BitNet.cpp benchmark..."
echo "Model: $MODEL_PATH"
echo "Results will be saved to: $OUTPUT_FILE"

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect_cpu.sh"
CPU_INFO=$(detect_cpu_info)
eval "$CPU_INFO"

# Run benchmark
cd "$(dirname "$SCRIPT_DIR")/BitNet"

echo "=== System Information ===" > "$OUTPUT_FILE"
echo "CPU: $CPU_MODEL" >> "$OUTPUT_FILE"
echo "Cores: $CPU_CORES" >> "$OUTPUT_FILE"
echo "Memory: ${MEMORY_GB}GB" >> "$OUTPUT_FILE"
echo "Architecture: $CPU_ARCH" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "=== Benchmark Results ===" >> "$OUTPUT_FILE"

# Test different configurations
for kernel in i2_s; do
    for threads in 2 4 8 $CPU_CORES; do
        if [[ $threads -le $CPU_CORES ]]; then
            echo "Testing: Kernel=$kernel, Threads=$threads" | tee -a "$OUTPUT_FILE"
            
            # Run inference benchmark
            python utils/e2e_benchmark.py \
                -m "$MODEL_PATH" \
                -p 256 \
                -n 128 \
                -t $threads 2>&1 | tee -a "$OUTPUT_FILE"
            
            echo "---" >> "$OUTPUT_FILE"
        fi
    done
done

echo "Benchmark complete! Results saved to $OUTPUT_FILE"