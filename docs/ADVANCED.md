# Advanced Configuration

## Environment Variables

### Performance Tuning
```bash
# Kernel selection
export BITNET_KERNEL=i2_s          # Options: i2_s, tl1, tl2

# Threading
export OMP_NUM_THREADS=8           # Number of OpenMP threads
export CPU_AFFINITY=0-7            # Pin to specific CPU cores

# Use case profiles
export USE_CASE=high_performance   # Options: high_performance, balanced, memory_efficient
```

### Memory Management
```bash
# Context and batch sizes
export LLAMA_CTX_SIZE=2048         # Context window size
export LLAMA_BATCH_SIZE=512        # Batch processing size

# Memory limits
export LLAMA_MEMORY_LIMIT=4G       # Maximum memory usage
```

## Kernel Tuning

Run the kernel tuning utility to find optimal settings:

```bash
cd BitNet
python3 utils/kernel_tuning.py
```

This will:
1. Test different thread configurations
2. Benchmark various kernel types
3. Generate `best_kernel_config.json`
4. Apply optimal settings automatically

## Custom Model Support

### Using Different Models
```bash
# Download and setup custom model
python3 setup_env.py -md models/YourModel -q i2_s

# Start with custom model
./build/bin/llama-server -m models/YourModel/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081
```

### Supported Quantization Types
- `i2_s` - 2-bit symmetric (fastest)
- `tl1` - Ternary lookup v1 (balanced)
- `tl2` - Ternary lookup v2 (memory efficient)

## Build Options

### Custom CMake Flags
```bash
cd BitNet
mkdir build && cd build
cmake .. \
  -DLLAMA_NATIVE=ON \
  -DLLAMA_BUILD_SERVER=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_CCACHE=OFF
make -j$(nproc)
```

### Platform-Specific Builds
```bash
# ARM optimization
cmake .. -DLLAMA_ARM_NEON=ON

# x86 with AVX2
cmake .. -DLLAMA_AVX2=ON

# Apple Silicon
cmake .. -DLLAMA_METAL=ON
```

## Monitoring and Diagnostics

### Performance Monitoring
```bash
# Real-time server stats
./monitor_server.sh

# Detailed diagnostics
./scripts/diagnose.sh
```

### Logging
```bash
# Enable debug logging
export LLAMA_LOG_LEVEL=debug

# Log to file
./build/bin/llama-server ... 2>&1 | tee server.log
```

## Security Configuration

### Network Security
```bash
# Bind to localhost only
./build/bin/llama-server -m model.gguf --host 127.0.0.1 --port 8081

# Use with reverse proxy (nginx example)
server {
    listen 443 ssl;
    location /api/ {
        proxy_pass http://localhost:8081/;
        proxy_set_header Host $host;
    }
}
```

### Access Control
Implement at application level:
- API key authentication
- Rate limiting
- Request validation

## Integration Examples

### Python Client Library
```python
class BitNetClient:
    def __init__(self, base_url="http://localhost:8081"):
        self.base_url = base_url
    
    def chat(self, message, **kwargs):
        response = requests.post(
            f"{self.base_url}/chat/completions",
            json={
                "messages": [{"role": "user", "content": message}],
                **kwargs
            }
        )
        return response.json()["choices"][0]["message"]["content"]

# Usage
client = BitNetClient()
response = client.chat("Hello!", temperature=0.7, max_tokens=100)
```

### Batch Processing
```python
import asyncio
import aiohttp

async def process_batch(prompts):
    async with aiohttp.ClientSession() as session:
        tasks = []
        for prompt in prompts:
            task = session.post(
                "http://localhost:8081/chat/completions",
                json={"messages": [{"role": "user", "content": prompt}]}
            )
            tasks.append(task)
        responses = await asyncio.gather(*tasks)
        return [await r.json() for r in responses]
```

## Troubleshooting Advanced Issues

### Memory Profiling
```bash
# Use valgrind
valgrind --leak-check=full ./build/bin/llama-server ...

# Monitor with htop
htop -p $(pgrep llama-server)
```

### Performance Profiling
```bash
# CPU profiling
perf record -g ./build/bin/llama-server ...
perf report

# Thread analysis
./BitNet/test_thread_scaling.py
```

### Debug Build
```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug -DLLAMA_DEBUG=ON
make -j$(nproc)
gdb ./build/bin/llama-server
```