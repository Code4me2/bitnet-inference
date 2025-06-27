# BitNet Server - Quick Start Guide

## 🚨 Start Server in 5 Minutes

### Prerequisites Check (30 seconds)
```bash
# You need ALL of these:
python3 --version  # 3.8+ required
gcc --version      # GCC 7+ required
cmake --version    # 3.14+ required
```

### Setup (4 minutes)
```bash
# 1. Clone repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference/BitNet

# 2. Download model and build (this takes ~3-4 minutes)
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

### Start Server (30 seconds)
```bash
# 3. Start the server
./build/bin/llama-server \
  -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081

# You should see:
# llama server listening at http://0.0.0.0:8081
```

### Test It Works
```bash
# 4. In a new terminal:
curl http://localhost:8081/health

# Should return: {"status": "ok"}
```

## 🎯 That's it! Server is running at http://localhost:8081

---

## Common Problems

### "command not found: llama-server"
The build failed. Re-run: `python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s`

### "Address already in use"  
Change port: Add `--port 8082` to the server command

### "Out of memory"
Add `--ctx-size 512` to the server command

### Server is slow
Use fewer threads: Add `--threads 4` to the server command

---

## Test Chat
```bash
curl -X POST http://localhost:8081/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 50}'
```