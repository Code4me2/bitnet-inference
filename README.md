# BitNet Inference Server

Run 1-bit LLMs on your CPU in 4 simple steps. Powered by Microsoft's BitNet.cpp.

## 🚀 Quick Setup (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference/BitNet

# 2. Download model and build (3-4 minutes)
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# 3. Start server
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf --host 0.0.0.0 --port 8081

# 4. Test it works
curl http://localhost:8081/health
```

✅ **Done!** Server is running at http://localhost:8081

## 🎯 What You Can Do

### Chat with the model
```bash
curl -X POST http://localhost:8081/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello!"}], "max_tokens": 50}'
```

### Use interactive chat
```bash
cd BitNet && ./bitnet-chat.sh
```

### Quick server restart
```bash
./start-server.sh
```

## 📚 Learn More

- **Having issues?** → [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)
- **Want better performance?** → [Performance Tuning](./docs/PERFORMANCE.md)
- **Need API docs?** → [API Reference](./docs/API.md)
- **Integration with N8N?** → [N8N Setup](./docs/N8N_INTEGRATION.md)
- **Advanced usage?** → [Advanced Configuration](./docs/ADVANCED.md)

## 💡 System Requirements

- Python 3.8+, GCC/Clang, CMake 3.14+
- 2-4GB RAM, ~2GB disk space
- Linux/macOS (Windows via WSL2)

## 🚀 Performance

BitNet.cpp achieves 2-6x speedup over llama.cpp with significantly lower energy consumption.

---

**License**: MIT | **Model**: [BitNet-b1.58-2B-4T](https://huggingface.co/microsoft/BitNet-b1.58-2B-4T)