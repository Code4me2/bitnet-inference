# BitNet Server Troubleshooting Guide

## 🔍 Diagnostic Commands

### 1. Check if Server is Running
```bash
# See if llama-server process exists
ps aux | grep llama-server

# Check if port is listening
sudo netstat -tlnp | grep 8081
# or
sudo lsof -i :8081
```

### 2. Test Server Health
```bash
# Basic health check
curl -v http://localhost:8081/health

# If no response, try:
wget -O- http://localhost:8081/health
```

## 🚨 Common Issues & Solutions

### Build/Setup Issues

#### "ModuleNotFoundError: No module named 'huggingface_hub'"
```bash
pip3 install huggingface-hub requests tqdm
```

#### "CMake Error: Could not find cmake module file"
```bash
# Install build tools
sudo apt-get update
sudo apt-get install build-essential cmake
```

#### "setup_env.py fails to download model"
```bash
# Manual model download
cd BitNet
mkdir -p models/BitNet-b1.58-2B-4T
wget -O models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  https://huggingface.co/microsoft/BitNet-b1.58-2B-4T-gguf/resolve/main/ggml-model-i2_s.gguf
```

### Server Startup Issues

#### "error while loading shared libraries"
```bash
# Find and set library path
find . -name "*.so" -type f
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/build/lib
```

#### "GGML_ASSERT: ggml.c:4563: ggml_can_mul_mat"
```bash
# Wrong model format, re-download with correct quantization
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

#### "illegal hardware instruction" or "Segmentation fault"
```bash
# CPU doesn't support required instructions
# Use different kernel:
export BITNET_KERNEL=tl2  # More compatible kernel
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf --host 0.0.0.0 --port 8081
```

### Performance Issues

#### Server is Very Slow
```bash
# 1. Check CPU usage
top -p $(pgrep llama-server)

# 2. Reduce thread count to match physical cores
nproc  # Shows total cores
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 --threads 4  # Use half of nproc value
```

#### High Memory Usage
```bash
# Monitor memory
free -h
watch -n 1 free -h

# Reduce memory usage
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081 \
  --ctx-size 512 \
  --batch-size 128
```

### Network/Connection Issues

#### "Connection refused"
```bash
# 1. Check server is running on correct interface
curl http://127.0.0.1:8081/health  # Try localhost
curl http://0.0.0.0:8081/health    # Try all interfaces

# 2. Check firewall
sudo ufw status
sudo ufw allow 8081  # If using ufw

# 3. For Docker/VM users, check port forwarding
```

#### "Timeout" Errors
```bash
# Increase timeout in curl
curl -m 30 http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello", "n_predict": 10}'
```

### Model Issues

#### "could not load model"
```bash
# 1. Check model file exists and has correct permissions
ls -la models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf

# 2. Verify model integrity
md5sum models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf
# Expected: Check against HuggingFace page

# 3. Re-download if corrupted
rm models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

## 📊 Performance Diagnostics

### Check Token Generation Speed
```bash
# From bitnet-inference directory
node test-token-speed.js

# Manual test
time curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Count to ten:", "n_predict": 50}'
```

### System Resource Check
```bash
# Create diagnostic script
cat > check_system.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "Cores: $(nproc)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Available RAM: $(free -h | grep Mem | awk '{print $7}')"
echo "Disk Space: $(df -h . | tail -1 | awk '{print $4}') free"
echo "OS: $(uname -a)"
echo "Python: $(python3 --version)"
echo "GCC: $(gcc --version | head -1)"
echo "CMake: $(cmake --version | head -1)"
EOF

chmod +x check_system.sh
./check_system.sh
```

## 🆘 Getting Help

If none of the above solutions work:

1. **Collect Diagnostic Info**:
```bash
# Save this output
./check_system.sh > diagnostic.txt
./build/bin/llama-server --version >> diagnostic.txt 2>&1
ls -la models/ >> diagnostic.txt
tail -n 50 server.log >> diagnostic.txt  # If you have logs
```

2. **Check Existing Issues**: 
   - https://github.com/Code4me2/bitnet-inference/issues
   - https://github.com/microsoft/BitNet/issues

3. **Create New Issue** with:
   - Your diagnostic.txt contents
   - Exact commands you ran
   - Full error messages
   - What you expected vs what happened