#!/bin/bash

# Kernel Selection Logic for BitNet.cpp

select_optimal_kernel() {
    local cpu_cores=$1
    local memory_gb=$2
    local model_size=$3
    local use_case=$4
    
    # Auto-detect optimal kernel based on system resources
    if [[ $use_case == "high_performance" ]] && [[ $cpu_cores -ge 8 ]] && [[ $memory_gb -ge 16 ]]; then
        echo "i2_s"
    elif [[ $memory_gb -lt 8 ]] || [[ $model_size == "large" ]]; then
        echo "tl2"  # Best for memory-constrained environments
    elif [[ $cpu_cores -le 4 ]]; then
        echo "tl1"  # Good balance for limited CPU resources
    else
        echo "i2_s"  # Default for good systems
    fi
}

get_quantization_type() {
    local kernel=$1
    
    case $kernel in
        "i2_s")
            echo "i2_s"
            ;;
        "tl1")
            echo "tl1"
            ;;
        "tl2")
            echo "tl1"  # TL2 uses same quantization as TL1
            ;;
        *)
            echo "i2_s"  # Default
            ;;
    esac
}

validate_kernel_availability() {
    local kernel=$1
    local model_path=$2
    
    # Check if model file exists with correct quantization
    local expected_suffix=""
    case $kernel in
        "i2_s") expected_suffix="i2_s" ;;
        "tl1"|"tl2") expected_suffix="tl1" ;;
    esac
    
    if [[ $model_path == *"$expected_suffix"* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    CPU_CORES=${1:-$(nproc)}
    MEMORY_GB=${2:-$(free -g | awk '/^Mem:/{print $2}')}
    MODEL_SIZE=${3:-"medium"}
    USE_CASE=${4:-"balanced"}
    
    OPTIMAL_KERNEL=$(select_optimal_kernel $CPU_CORES $MEMORY_GB $MODEL_SIZE $USE_CASE)
    echo "RECOMMENDED_KERNEL=$OPTIMAL_KERNEL"
    echo "QUANTIZATION_TYPE=$(get_quantization_type $OPTIMAL_KERNEL)"
fi