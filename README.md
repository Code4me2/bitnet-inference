# BitNet.cpp Inference Server

High-performance inference server for 1-bit LLMs using Microsoft's official BitNet.cpp framework. Achieves significant performance improvements with optimized kernels.

## 🚀 Quick Start

### Working Method: Local Build and Run
```bash
# Clone repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference/BitNet

# Download model (one-time setup)
python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# Start the server
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081

# In another terminal, test inference
curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is BitNet?", "n_predict": 50}'
```

### Docker Status
⚠️ **Note**: The Docker build is currently not working due to BitNet's architecture-specific compilation requirements. Use the local build method above.

### Interactive Chat
```bash
# After starting the server, use the chat interface
cd BitNet && ./bitnet-chat.sh
```

### Alternative: Manual Model Download
If `setup_env.py` fails to download the model:
```bash
cd BitNet
mkdir -p models/BitNet-b1.58-2B-4T
wget -O models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  https://huggingface.co/microsoft/BitNet-b1.58-2B-4T-gguf/resolve/main/ggml-model-i2_s.gguf
```

## 🎯 Performance Optimization

The server automatically detects your hardware and optimizes:

- **Kernel Selection**: I2_S (high-performance), TL1 (balanced), TL2 (memory-efficient)
- **Thread Configuration**: Auto-scales based on CPU cores and kernel type
- **CPU Affinity**: Dedicated core assignment for optimal performance
- **Memory Management**: Adaptive batch sizes and context windows

### Manual Configuration

Override auto-detection with environment variables:

```yaml
environment:
  - BITNET_KERNEL=i2_s          # i2_s, tl1, tl2
  - OMP_NUM_THREADS=8           # Number of threads
  - CPU_AFFINITY=0-7            # CPU core assignment
  - USE_CASE=high_performance   # balanced, memory_efficient
```

## 📊 Benchmarking and Analysis

```bash
# Test token generation speed
node test-token-speed.js

# Monitor server health and resource usage
./monitor_server.sh

# Run comprehensive benchmark
./scripts/benchmark.sh

# Run kernel tuning for optimal performance (from BitNet directory)
cd BitNet && python3 utils/kernel_tuning.py
```

## 🔌 API Usage

### Health Check
```bash
curl http://localhost:8081/health
```

### Text Completion
```bash
curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What is artificial intelligence?",
    "n_predict": 50,
    "temperature": 0.7
  }'
```

### Chat Completion
```bash
curl -X POST http://localhost:8081/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is BitNet?"}
    ],
    "temperature": 0.7,
    "max_tokens": 50
  }'
```

## 🤝 N8N Integration

Connect from N8N workflows:
- Docker network: `http://bitnet:8081`
- Host network: `http://localhost:8081`

Compatible with the [N8N BitNet custom node](https://github.com/Code4me2/data-compose).

## 🛠️ Prerequisites

- Python 3.8+
- GCC/Clang compiler
- CMake 3.14+
- ~4GB RAM for the 2B model
- ~20GB disk space for model and build files

## 📁 Project Structure

```
bitnet-inference/
├── BitNet/              # Core BitNet implementation (submodule)
│   ├── build/bin/       # Compiled binaries (after setup)
│   ├── models/          # Model files (after download)
│   ├── docs/            # Comprehensive documentation
│   └── setup_env.py     # Main setup script
├── scripts/             # Helper scripts
├── .github/             # GitHub workflows and configs
└── test-token-speed.js  # Token speed testing utility
```

## 📈 Performance Expectations

Optimized BitNet.cpp performance:
- **ARM**: 1.37x - 5.07x speedup vs llama.cpp
- **x86**: 2.37x - 6.17x speedup vs llama.cpp
- **Energy**: Significant reduction in power consumption
- **Memory**: Efficient 1-bit quantization reduces memory usage
- **Throughput**: Higher tokens/second with optimized kernels

## 🔧 Advanced Configuration

### Kernel Types
- **I2_S**: Best for high-performance systems (8+ cores, 16GB+ RAM)
- **TL1**: Balanced performance for mid-range systems
- **TL2**: Memory-efficient for constrained environments

### Use Cases
- **high_performance**: Maximum speed, higher resource usage
- **balanced**: Default, good performance vs resource balance
- **memory_efficient**: Minimal memory usage, slower performance

## 📚 Documentation

- [BitNet Official Repository](https://github.com/microsoft/BitNet)
- [Model on Hugging Face](https://huggingface.co/microsoft/BitNet-b1.58-2B-4T)
- [Installation Guide](./BitNet/docs/getting-started/installation.md)
- [Setup Guide](./BitNet/docs/getting-started/setup-guide.md)
- [Debugging Guide](./BitNet/docs/development/debugging.md)
- [Performance Optimization](./BitNet/docs/performance/optimization.md)

## 🔒 Security Notes

- The server binds to `0.0.0.0` by default (accessible from network)
- For production use, implement proper authentication
- Consider using a reverse proxy (nginx) with SSL

## 📄 License

This project follows the MIT License. See the BitNet submodule for its specific licensing terms.

## 🙏 Acknowledgments

- Microsoft Research for BitNet
- The llama.cpp community for the inference framework