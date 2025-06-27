# Performance Tuning Guide

## Quick Optimization

The server auto-detects your hardware and optimizes accordingly. To override:

```bash
# High performance (8+ cores, 16GB+ RAM)
export BITNET_KERNEL=i2_s
export OMP_NUM_THREADS=$(nproc)

# Balanced (default)
export BITNET_KERNEL=tl1
export OMP_NUM_THREADS=$(($(nproc) / 2))

# Memory efficient
export BITNET_KERNEL=tl2
export OMP_NUM_THREADS=4
```

## Kernel Selection

### I2_S (High Performance)
- **Best for**: Servers, workstations
- **Speed**: Fastest (2.37x - 6.17x vs llama.cpp)
- **Memory**: Higher usage
- **Build**: `python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s`

### TL1 (Balanced)
- **Best for**: Most desktop systems
- **Speed**: Good (1.5x - 4x vs llama.cpp)
- **Memory**: Moderate usage
- **Build**: `python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q tl1`

### TL2 (Memory Efficient)
- **Best for**: Limited RAM, laptops
- **Speed**: Slower but stable
- **Memory**: Lowest usage
- **Build**: `python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q tl2`

## Thread Optimization

Find optimal thread count:
```bash
cd BitNet
python3 test_thread_scaling.py
```

Manual configuration:
```bash
# Example for 8-core CPU
export OMP_NUM_THREADS=10  # Often optimal is cores + 2
export CPU_AFFINITY=0-7    # Pin to specific cores
```

## Benchmarking

### Quick benchmark
```bash
node test-token-speed.js
```

### Comprehensive benchmark
```bash
cd BitNet
python3 utils/kernel_tuning.py    # Find best kernel config
python3 test_token_speed.py       # Test token generation
./scripts/benchmark.sh            # Full system benchmark
```

## Server Tuning

### Context and batch sizes
```bash
# Large context (slower, more memory)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --ctx-size 4096 --batch-size 1024

# Small context (faster, less memory)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --ctx-size 1024 --batch-size 256
```

### Advanced flags
```bash
--threads N          # Override thread count
--threads-batch N    # Batch processing threads
--no-mmap           # Disable memory mapping (if issues)
--numa              # Enable NUMA optimizations
```

## Monitoring

```bash
# Real-time monitoring
./monitor_server.sh

# Resource usage
htop                # CPU/Memory
iotop               # Disk I/O
nethogs             # Network
```

## Expected Performance

With optimal settings on modern hardware:

| Hardware | Kernel | Tokens/sec | Memory |
|----------|--------|------------|---------|
| 16-core server | I2_S | 45-60 | 6-8GB |
| 8-core desktop | TL1 | 25-35 | 4-6GB |
| 4-core laptop | TL2 | 15-20 | 2-4GB |

## Tips

1. **CPU Governor**: Use performance mode
   ```bash
   sudo cpupower frequency-set -g performance
   ```

2. **Disable Hyperthreading**: Can improve consistency
   
3. **Memory**: Ensure no swap usage (`free -h`)

4. **Background Processes**: Minimize for best results

5. **Temperature**: Monitor CPU temps, throttling reduces performance