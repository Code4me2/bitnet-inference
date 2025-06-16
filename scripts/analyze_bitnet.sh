#!/bin/bash

# BitNet.cpp Analysis Script
# Identifies BitNet.cpp usage patterns and estimates energy efficiency

echo "==================================="
echo "BitNet.cpp Analysis Tool"
echo "==================================="
echo ""

# Function to check if server is running
check_server() {
    if curl -s -f http://localhost:8081/health > /dev/null 2>&1; then
        echo "✓ BitNet server is running on port 8081"
        return 0
    else
        echo "✗ BitNet server is not running"
        return 1
    fi
}

# Function to analyze model information
analyze_model() {
    echo ""
    echo "Model Information:"
    echo "------------------"
    
    # Check model file
    if [[ -f "$MODEL_PATH" ]]; then
        MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
        echo "• Model file: $MODEL_PATH"
        echo "• Model size: $MODEL_SIZE"
        
        # Extract model info from filename
        if [[ "$MODEL_PATH" == *"i2_s"* ]]; then
            echo "• Quantization: I2_S (2-bit ternary)"
            echo "• Kernel type: High-performance I2_S kernel"
        elif [[ "$MODEL_PATH" == *"tl1"* ]]; then
            echo "• Quantization: TL1 (lookup table)"
            echo "• Kernel type: Balanced TL1 kernel"
        elif [[ "$MODEL_PATH" == *"tl2"* ]]; then
            echo "• Quantization: TL2 (lookup table v2)"
            echo "• Kernel type: Memory-efficient TL2 kernel"
        fi
    else
        echo "• Model file not found at: ${MODEL_PATH:-/models/ggml-model-i2_s.gguf}"
    fi
}

# Function to analyze BitNet-specific features
analyze_bitnet_features() {
    echo ""
    echo "BitNet.cpp Features Detected:"
    echo "-----------------------------"
    
    # Check binary
    if command -v llama-server &> /dev/null; then
        echo "✓ BitNet-optimized llama-server found"
        
        # Check if it's actually BitNet by looking for specific symbols
        if strings $(which llama-server) 2>/dev/null | grep -q "bitnet"; then
            echo "✓ Binary contains BitNet-specific optimizations"
        fi
    fi
    
    # Check for BitNet kernels
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "$(dirname "$SCRIPT_DIR")/BitNet" ]]; then
        echo "✓ BitNet source directory found"
    fi
    
    # Check optimization settings
    echo ""
    echo "Optimization Settings:"
    if [[ "$OMP_NUM_THREADS" == "auto" ]]; then
        echo "• Thread count: Auto-detected (currently: $(nproc))"
    else
        echo "• Thread count: ${OMP_NUM_THREADS:-4}"
    fi
    
    if [[ "$BITNET_KERNEL" == "auto" ]]; then
        echo "• Kernel selection: Auto-detected"
    else
        echo "• Kernel selection: ${BITNET_KERNEL:-i2_s}"
    fi
    
    if [[ "$CPU_AFFINITY" == "auto" ]]; then
        echo "• CPU affinity: Auto-configured"
    else
        echo "• CPU affinity: ${CPU_AFFINITY:-none}"
    fi
}

# Function to estimate energy efficiency
estimate_energy_efficiency() {
    echo ""
    echo "Energy Efficiency Estimation:"
    echo "----------------------------"
    
    # Base estimates from BitNet paper
    echo "Compared to traditional FP16 models:"
    echo "• BitNet 1.58b uses ~1.5-2 bits per weight"
    echo "• Traditional models use 16 bits per weight"
    echo "• Theoretical reduction: ~87-90% in weight memory"
    
    echo ""
    echo "Expected improvements over FP16 LLMs:"
    
    # Get CPU info
    CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
    
    # Estimate based on kernel type
    if [[ "$MODEL_PATH" == *"i2_s"* ]] || [[ "$BITNET_KERNEL" == "i2_s" ]]; then
        echo "• Energy reduction: 71-82% (I2_S kernel)"
        echo "• Speed improvement: 2.0-2.7x"
        echo "• Best for: High-performance systems"
    elif [[ "$MODEL_PATH" == *"tl1"* ]] || [[ "$BITNET_KERNEL" == "tl1" ]]; then
        echo "• Energy reduction: 65-75% (TL1 kernel)"
        echo "• Speed improvement: 1.8-2.3x"
        echo "• Best for: Balanced performance"
    elif [[ "$MODEL_PATH" == *"tl2"* ]] || [[ "$BITNET_KERNEL" == "tl2" ]]; then
        echo "• Energy reduction: 55-65% (TL2 kernel)"
        echo "• Speed improvement: 1.5-2.0x"
        echo "• Best for: Memory-constrained systems"
    else
        echo "• Energy reduction: 55-82% (varies by kernel)"
        echo "• Speed improvement: 1.5-2.7x"
    fi
    
    echo ""
    echo "Key factors for energy efficiency:"
    echo "• 1-bit weights reduce memory bandwidth by 16x"
    echo "• Ternary operations (-1, 0, 1) eliminate multiplications"
    echo "• CPU-optimized kernels maximize instruction efficiency"
}

# Function to run a simple benchmark
run_efficiency_test() {
    if ! check_server > /dev/null 2>&1; then
        return
    fi
    
    echo ""
    echo "Running Efficiency Test:"
    echo "-----------------------"
    
    # Record start time and CPU stats
    START_TIME=$(date +%s.%N)
    CPU_BEFORE=$(grep 'cpu ' /proc/stat)
    
    # Run a test inference
    RESPONSE=$(curl -s -X POST http://localhost:8081/completion \
        -H "Content-Type: application/json" \
        -d '{
            "prompt": "The capital of France is",
            "n_predict": 20,
            "temperature": 0.1
        }' 2>/dev/null)
    
    # Record end time and CPU stats
    END_TIME=$(date +%s.%N)
    CPU_AFTER=$(grep 'cpu ' /proc/stat)
    
    # Calculate metrics
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    
    if [[ -n "$RESPONSE" ]]; then
        TOKENS=$(echo "$RESPONSE" | grep -o '"tokens_predicted":[0-9]*' | cut -d: -f2)
        if [[ -n "$TOKENS" ]]; then
            TOKENS_PER_SEC=$(echo "scale=2; $TOKENS / $DURATION" | bc)
            echo "• Inference time: ${DURATION}s"
            echo "• Tokens generated: $TOKENS"
            echo "• Throughput: ${TOKENS_PER_SEC} tokens/second"
            
            # Extract timing info if available
            PROMPT_MS=$(echo "$RESPONSE" | grep -o '"prompt_ms":[0-9.]*' | cut -d: -f2)
            PREDICT_MS=$(echo "$RESPONSE" | grep -o '"predicted_ms":[0-9.]*' | cut -d: -f2)
            
            if [[ -n "$PROMPT_MS" ]] && [[ -n "$PREDICT_MS" ]]; then
                echo "• Prompt processing: ${PROMPT_MS}ms"
                echo "• Token generation: ${PREDICT_MS}ms"
            fi
        fi
    fi
}

# Function to provide recommendations
provide_recommendations() {
    echo ""
    echo "Optimization Recommendations:"
    echo "----------------------------"
    
    # Get system info
    CORES=$(nproc)
    MEM_GB=$(free -g | awk '/^Mem:/{print $2}')
    
    echo "System: $CORES cores, ${MEM_GB}GB RAM"
    echo ""
    
    if [[ $CORES -ge 8 ]] && [[ $MEM_GB -ge 16 ]]; then
        echo "• Recommended kernel: I2_S (high-performance)"
        echo "• Set BITNET_KERNEL=i2_s for maximum speed"
        echo "• Use OMP_NUM_THREADS=$CORES for full CPU utilization"
    elif [[ $MEM_GB -lt 8 ]]; then
        echo "• Recommended kernel: TL2 (memory-efficient)"
        echo "• Set BITNET_KERNEL=tl2 to reduce memory usage"
        echo "• Use OMP_NUM_THREADS=$((CORES/2)) to balance load"
    else
        echo "• Recommended kernel: TL1 (balanced)"
        echo "• Current auto-configuration should work well"
    fi
    
    echo ""
    echo "To maximize energy efficiency:"
    echo "• Use CPU affinity to dedicate cores"
    echo "• Disable CPU frequency scaling"
    echo "• Monitor with: ./scripts/benchmark.sh"
}

# Main execution
main() {
    # Check if running in Docker
    if [[ -f /.dockerenv ]]; then
        echo "Running inside Docker container"
    else
        echo "Running on host system"
    fi
    
    # Set default model path if not provided
    MODEL_PATH=${MODEL_PATH:-/models/ggml-model-i2_s.gguf}
    
    # Run analysis functions
    check_server
    analyze_model
    analyze_bitnet_features
    estimate_energy_efficiency
    run_efficiency_test
    provide_recommendations
    
    echo ""
    echo "==================================="
    echo "Analysis complete!"
    echo "==================================="
}

# Run main function
main "$@"