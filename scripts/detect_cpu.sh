#!/bin/bash

# CPU Detection and Optimization Script for BitNet.cpp

detect_cpu_info() {
    local cpu_cores=$(nproc)
    local cpu_arch=$(uname -m)
    local memory_gb=$(free -g | awk '/^Mem:/{print $2}')
    
    echo "CPU_CORES=$cpu_cores"
    echo "CPU_ARCH=$cpu_arch"
    echo "MEMORY_GB=$memory_gb"
    
    # Detect CPU brand and model
    local cpu_info=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs | sed 's/[()]//g')
    echo "CPU_MODEL=\"$cpu_info\""
    
    # Check for specific optimizations
    if [[ $cpu_info == *"Apple"* ]]; then
        echo "CPU_TYPE=apple_silicon"
    elif [[ $cpu_info == *"Intel"* ]]; then
        echo "CPU_TYPE=intel_x86"
    elif [[ $cpu_info == *"AMD"* ]]; then
        echo "CPU_TYPE=amd_x86"
    else
        echo "CPU_TYPE=generic"
    fi
}

optimize_threading() {
    local cpu_cores=$1
    local kernel_type=$2
    local memory_gb=$3
    
    if [[ $kernel_type == "i2_s" ]]; then
        # I2_S performs best with high thread count
        echo "OPTIMAL_THREADS=$cpu_cores"
    elif [[ $kernel_type == "tl1" ]] || [[ $kernel_type == "tl2" ]]; then
        # TL1/TL2 perform better with limited threads
        local limited_threads=$((cpu_cores / 2))
        if [[ $limited_threads -lt 2 ]]; then
            limited_threads=2
        fi
        echo "OPTIMAL_THREADS=$limited_threads"
    else
        # Default fallback
        echo "OPTIMAL_THREADS=4"
    fi
}

generate_cpu_affinity() {
    local thread_count=$1
    local cpu_cores=$2
    
    if [[ $thread_count -ge $cpu_cores ]]; then
        echo "CPU_AFFINITY_MASK=0-$((cpu_cores-1))"
    else
        echo "CPU_AFFINITY_MASK=0-$((thread_count-1))"
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_cpu_info
fi