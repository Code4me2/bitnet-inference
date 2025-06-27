# BitNet.cpp Inference Server

High-performance inference server for 1-bit LLMs using Microsoft's official BitNet.cpp framework.

## 📋 Prerequisites & Storage Requirements

### System Requirements
- **Storage**: ~7GB total (1.2GB model + 5.8GB build files)
- **RAM**: 4GB minimum for 2B model
- **CPU**: x86_64 or ARM64 processor
- **OS**: Linux, macOS, or WSL2 on Windows

### Software Requirements
```bash
# Check if you have required tools
python3 --version  # Need 3.8+
gcc --version      # Need GCC 7+ or Clang 6+
cmake --version    # Need 3.14+
git --version      # Need 2.x+
```

## 🚀 Step-by-Step Server Setup

### Step 1: Clone and Enter Directory
```bash
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference
```

### Step 2: Initialize BitNet Submodule
```bash
cd BitNet
git submodule update --init --recursive
```

### Step 3: Setup Environment and Download Model
```bash
# This downloads the model (~1.2GB) and builds BitNet
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# If the above fails, try manual model download:
mkdir -p models/BitNet-b1.58-2B-4T
wget -O models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  https://huggingface.co/microsoft/BitNet-b1.58-2B-4T-gguf/resolve/main/ggml-model-i2_s.gguf
```

### Step 4: Start the Server
```bash
# Make sure you're in the BitNet directory
./build/bin/llama-server \
  -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 \
  --port 8081 \
  --ctx-size 2048 \
  --threads 8

# You should see:
# llm_load_tensors: ggml ctx size = 1179.81 MB
# llama server listening at http://0.0.0.0:8081
```

### Step 5: Verify Server is Running
```bash
# In a new terminal, test the server
curl http://localhost:8081/health

# Expected response:
# {"status": "ok"}
```

## ✅ Testing the Server

### Quick Test - Text Completion
```bash
curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "The capital of France is",
    "n_predict": 20,
    "temperature": 0.7
  }'
```

### Chat Completion Test
```bash
curl -X POST http://localhost:8081/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "What is 2+2?"}
    ],
    "max_tokens": 50
  }'
```

### Interactive Chat
```bash
# From the bitnet-inference directory
cd BitNet && ./bitnet-chat.sh
```

## 🔧 Common Issues & Solutions

### Issue: "command not found: llama-server"
**Solution**: Build didn't complete. Re-run setup:
```bash
cd BitNet
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

### Issue: "Address already in use"
**Solution**: Port 8081 is taken. Use different port:
```bash
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8082
```

### Issue: "Out of memory"
**Solution**: Reduce context size:
```bash
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 --ctx-size 512
```

### Issue: Server crashes or slow performance
**Solution**: Adjust thread count based on CPU:
```bash
# Check CPU cores
nproc

# Use 75% of cores (e.g., 6 threads for 8-core CPU)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 --threads 6
```

## 📊 Performance Tuning

### Test Your Setup Performance
```bash
# From bitnet-inference root directory
node test-token-speed.js

# Expected output:
# Average token generation speed: 20-30 tokens/second
```

### Optimize for Your Hardware
```bash
cd BitNet
python3 utils/kernel_tuning.py

# This will test different configurations and suggest optimal settings
```

### Server Parameters
```bash
# High Performance (16GB+ RAM, 8+ cores)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 \
  --ctx-size 4096 --batch-size 512 --threads 16

# Balanced (8GB RAM, 4-8 cores)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 \
  --ctx-size 2048 --batch-size 256 --threads 8

# Low Resource (4GB RAM, 2-4 cores)
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 \
  --ctx-size 512 --batch-size 128 --threads 4
```

## 🔍 Monitoring & Logs

### View Server Logs
```bash
# Start server with logging
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 --log-file server.log

# Monitor logs in real-time
tail -f server.log
```

### Monitor Resource Usage
```bash
# From bitnet-inference directory
./monitor_server.sh
```

## 🐳 Docker Status

⚠️ **Docker build is currently broken** due to BitNet's architecture-specific compilation requirements. Use the local build method above instead.

## 🤝 Integration with N8N

Once server is running, connect from N8N:
- Use URL: `http://localhost:8081` (or your custom port)
- Compatible with [N8N BitNet custom node](https://github.com/Code4me2/data-compose)

## 📚 Additional Resources

- [Detailed Setup Guide](./BitNet/docs/getting-started/setup-guide.md)
- [Performance Optimization](./BitNet/docs/performance/optimization.md)
- [API Documentation](./BitNet/docs/api/endpoints.md)
- [Troubleshooting Guide](./BitNet/docs/getting-started/debugging.md)

## ❓ Still Having Issues?

1. Check server is actually running: `ps aux | grep llama-server`
2. Check port is accessible: `netstat -tlnp | grep 8081`
3. Review build logs: `cat BitNet/setup.log`
4. Open an issue with:
   - Your OS and hardware specs
   - Exact error messages
   - Steps you've tried