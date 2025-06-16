# BitNet.cpp Migration Guide for Coding Agents

## Overview

This document provides complete instructions for migrating the existing `bitnet-inference` Docker setup from llama.cpp to Microsoft's official bitnet.cpp framework. This migration will provide 2-6x performance improvements and 55-82% energy reduction.

## Current State Analysis

**Repository**: `https://github.com/Code4me2/bitnet-inference`

**Current Architecture**:
- Docker-based inference server using llama.cpp
- REST API endpoints: `/completion`, `/chat/completions`, `/health`
- N8N integration support
- Basic environment configuration

**Performance Issues**:
- Using llama.cpp instead of optimized bitnet.cpp (2-6x slower)
- Basic threading configuration (OMP_NUM_THREADS=4)
- No kernel optimization (I2_S/TL1/TL2)
- Missing CPU affinity settings

## Migration Objectives

1. **Replace llama.cpp with bitnet.cpp** while preserving all existing functionality
2. **Implement optimal kernel selection** (I2_S, TL1, TL2)
3. **Add dynamic CPU detection and threading**
4. **Maintain Docker containerization and API compatibility**
5. **Preserve N8N integration capabilities**

## File Structure Analysis

```
bitnet-inference/
├── Dockerfile                 # MODIFY: Replace llama.cpp with bitnet.cpp
├── docker-compose.yml         # MODIFY: Add new environment variables
├── README.md                  # UPDATE: New configuration options
├── scripts/                   # NEW: Add optimization scripts
│   ├── detect_cpu.sh         # NEW: CPU detection and optimization
│   ├── select_kernel.sh      # NEW: Kernel selection logic
│   └── benchmark.sh          # NEW: Performance testing
└── models/                    # MODIFY: Update model setup process
```

## Step-by-Step Migration Instructions

### Step 1: Update Dockerfile

**File**: `Dockerfile`

**Action**: Replace the entire Dockerfile with bitnet.cpp implementation

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    taskset \
    hwloc-nox \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install huggingface-hub requests

# Clone bitnet.cpp repository
WORKDIR /app
RUN git clone --recursive https://github.com/microsoft/BitNet.git
WORKDIR /app/BitNet

# Build bitnet.cpp
RUN python setup_env.py --build-only

# Create models directory
RUN mkdir -p /models

# Copy scripts
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Set working directory
WORKDIR /app/BitNet

# Expose port
EXPOSE 8081

# Default environment variables
ENV OMP_NUM_THREADS=auto
ENV MODEL_PATH=/models/ggml-model-i2_s.gguf
ENV BITNET_KERNEL=auto
ENV CPU_AFFINITY=auto
ENV HOST=0.0.0.0
ENV PORT=8081

# Startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
```

### Step 2: Create CPU Detection Script

**File**: `scripts/detect_cpu.sh`

**Action**: Create new file

```bash
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
    local cpu_info=$(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2 | xargs)
    echo "CPU_MODEL=$cpu_info"
    
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
```

### Step 3: Create Kernel Selection Script

**File**: `scripts/select_kernel.sh`

**Action**: Create new file

```bash
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
```

### Step 4: Create Startup Script

**File**: `start.sh`

**Action**: Create new file

```bash
#!/bin/bash

# BitNet.cpp Optimized Startup Script

set -e

echo "Starting BitNet.cpp inference server..."

# Source CPU detection
source /app/scripts/detect_cpu.sh
CPU_INFO=$(detect_cpu_info)
eval "$CPU_INFO"

echo "Detected: $CPU_CORES cores, $MEMORY_GB GB RAM, $CPU_TYPE"

# Determine optimal configuration
if [[ $BITNET_KERNEL == "auto" ]]; then
    source /app/scripts/select_kernel.sh
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

# Start server with optimal settings
if [[ $CPU_AFFINITY != "auto" ]] && [[ $CPU_AFFINITY != "" ]]; then
    echo "Starting with CPU affinity..."
    exec taskset -c $CPU_AFFINITY ./build/bin/llama-server \
        -m "$MODEL_PATH" \
        --host "$HOST" \
        --port "$PORT" \
        --threads "$OMP_NUM_THREADS" \
        --ctx-size 4096 \
        --batch-size 512
else
    echo "Starting without CPU affinity..."
    exec ./build/bin/llama-server \
        -m "$MODEL_PATH" \
        --host "$HOST" \
        --port "$PORT" \
        --threads "$OMP_NUM_THREADS" \
        --ctx-size 4096 \
        --batch-size 512
fi
```

### Step 5: Update Docker Compose

**File**: `docker-compose.yml`

**Action**: Replace existing content

```yaml
version: '3.8'

services:
  bitnet:
    build: .
    container_name: bitnet-server
    ports:
      - "8081:8081"
    volumes:
      - ./models:/models
    environment:
      # Basic Configuration
      - MODEL_PATH=/models/ggml-model-i2_s.gguf
      - HOST=0.0.0.0
      - PORT=8081
      
      # Performance Optimization (auto-detection by default)
      - OMP_NUM_THREADS=auto
      - BITNET_KERNEL=auto
      - CPU_AFFINITY=auto
      
      # Advanced Configuration
      - USE_CASE=balanced  # Options: high_performance, balanced, memory_efficient
      - MODEL_SIZE=medium  # Options: small, medium, large
      
    # Resource limits (adjust based on your system)
    deploy:
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G
    
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    restart: unless-stopped

  # Optional: Web UI (uncomment if needed)
  # webui:
  #   image: nginx:alpine
  #   ports:
  #     - "8082:80"
  #   depends_on:
  #     - bitnet
```

### Step 6: Create Model Setup Script

**File**: `scripts/setup_model.sh`

**Action**: Create new file

```bash
#!/bin/bash

# Model Setup and Conversion Script for BitNet.cpp

MODEL_REPO=${1:-"microsoft/BitNet-b1.58-2B-4T"}
OUTPUT_DIR=${2:-"./models"}
KERNEL_TYPE=${3:-"i2_s"}

echo "Setting up BitNet model..."
echo "Repository: $MODEL_REPO"
echo "Output Directory: $OUTPUT_DIR"
echo "Kernel Type: $KERNEL_TYPE"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Download model based on kernel type
case $KERNEL_TYPE in
    "i2_s")
        echo "Downloading GGUF model for I2_S kernel..."
        huggingface-cli download "$MODEL_REPO-gguf" \
            --local-dir "$OUTPUT_DIR/$(basename $MODEL_REPO)" \
            --include "*.gguf"
        ;;
    "tl1"|"tl2")
        echo "Downloading BF16 model for TL1/TL2 conversion..."
        huggingface-cli download "$MODEL_REPO-bf16" \
            --local-dir "$OUTPUT_DIR/$(basename $MODEL_REPO)-bf16"
        
        # Convert to appropriate quantization
        cd /app/BitNet
        python ./utils/convert-helper-bitnet.py \
            "$OUTPUT_DIR/$(basename $MODEL_REPO)-bf16" \
            --outtype "$KERNEL_TYPE"
        ;;
    *)
        echo "Unknown kernel type: $KERNEL_TYPE"
        exit 1
        ;;
esac

echo "Model setup complete!"
```

### Step 7: Create Benchmark Script

**File**: `scripts/benchmark.sh`

**Action**: Create new file

```bash
#!/bin/bash

# Performance Benchmark Script

MODEL_PATH=${1:-"/models/ggml-model-i2_s.gguf"}
OUTPUT_FILE=${2:-"/tmp/benchmark_results.txt"}

echo "Running BitNet.cpp benchmark..."
echo "Model: $MODEL_PATH"
echo "Results will be saved to: $OUTPUT_FILE"

# Source configuration
source /app/scripts/detect_cpu.sh
CPU_INFO=$(detect_cpu_info)
eval "$CPU_INFO"

# Run benchmark
cd /app/BitNet

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
```

### Step 8: Update README.md

**File**: `README.md`

**Action**: Replace with optimized documentation

```markdown
# BitNet.cpp Inference Server

High-performance inference server for 1-bit LLMs using Microsoft's official BitNet.cpp framework. Achieves 2-6x speedup and 55-82% energy reduction compared to standard implementations.

## Quick Start

```bash
# Clone repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference

# Download model (one-time setup)
mkdir -p models
docker run --rm -v $(pwd)/models:/models bitnet-inference:latest \
  /app/scripts/setup_model.sh microsoft/BitNet-b1.58-2B-4T /models i2_s

# Start optimized server
docker-compose up -d

# Test inference
curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is BitNet?", "n_predict": 50}'
```

## Performance Optimization

The server automatically detects your hardware and optimizes:

- **Kernel Selection**: I2_S (high-performance), TL1 (balanced), TL2 (memory-efficient)
- **Thread Configuration**: Auto-scales based on CPU cores and kernel type
- **CPU Affinity**: Dedicated core assignment for optimal performance
- **Memory Management**: Adaptive batch sizes and context windows

## Manual Configuration

Override auto-detection with environment variables:

```yaml
environment:
  - BITNET_KERNEL=i2_s          # i2_s, tl1, tl2
  - OMP_NUM_THREADS=8           # Number of threads
  - CPU_AFFINITY=0-7            # CPU core assignment
  - USE_CASE=high_performance   # balanced, memory_efficient
```

## Benchmarking

```bash
# Run performance benchmark
docker exec bitnet-server /app/scripts/benchmark.sh
```

## N8N Integration

Connect from N8N workflows:
- Docker network: `http://bitnet:8081`
- Host network: `http://localhost:8081`

Compatible with the [N8N BitNet custom node](https://github.com/Code4me2/data-compose).
```

## Migration Validation

### Step 9: Testing Checklist

After completing the migration, verify:

1. **Build Test**:
   ```bash
   docker build -t bitnet-inference:migrated .
   ```

2. **API Compatibility**:
   ```bash
   # Test all endpoints
   curl http://localhost:8081/health
   curl -X POST http://localhost:8081/completion -H "Content-Type: application/json" -d '{"prompt":"test"}'
   curl -X POST http://localhost:8081/chat/completions -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"test"}]}'
   ```

3. **Performance Validation**:
   ```bash
   docker exec bitnet-server /app/scripts/benchmark.sh
   ```

4. **Auto-Configuration Test**:
   ```bash
   # Verify auto-detection works
   docker logs bitnet-server | grep -E "(Auto-selected|Auto-configured)"
   ```

### Step 10: Rollback Plan

If migration fails, rollback steps:

1. **Keep original branch**: `git checkout main`
2. **Backup original files** before migration
3. **Test rollback**: Ensure original setup still works
4. **Document issues** encountered during migration

## Performance Expectations

**Expected improvements after migration**:
- **Speed**: 2-6x faster inference
- **Energy**: 55-82% reduction in power consumption
- **Memory**: Better utilization with optimized kernels
- **Throughput**: Higher tokens/second, especially for larger models

## Troubleshooting

**Common issues and solutions**:

1. **Model not found**: Ensure correct model format for selected kernel
2. **Low performance**: Check auto-configuration logs, may need manual tuning
3. **Memory errors**: Switch to TL2 kernel for memory-constrained environments
4. **Build failures**: Ensure all dependencies installed and submodules cloned

## Success Criteria

Migration is successful when:
- [ ] All API endpoints respond correctly
- [ ] Performance shows measurable improvement
- [ ] Auto-configuration works properly
- [ ] Docker container starts without errors
- [ ] N8N integration remains functional
- [ ] Benchmark results show expected speedup

This migration preserves all existing functionality while providing significant performance improvements through Microsoft's optimized BitNet.cpp framework.
