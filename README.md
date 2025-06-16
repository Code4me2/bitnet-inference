# BitNet.cpp Inference Server

High-performance inference server for 1-bit LLMs using Microsoft's official BitNet.cpp framework. Achieves 2-6x speedup and 55-82% energy reduction compared to standard implementations.

## 🚀 Quick Start

### Option 1: Run Locally (Recommended)
```bash
# Clone repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference

# Run the server using pre-built binary
./run_local.sh

# Test inference
curl -X POST http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is BitNet?", "n_predict": 50}'
```

### Option 2: Docker (Experimental)
```bash
# Note: Docker support is currently being improved
# For now, we recommend running locally with ./run_local.sh
```

### Model Setup
If you don't have the model file yet:
```bash
# Download model manually
mkdir -p models
wget -O models/ggml-model-i2_s.gguf \
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
# Run performance benchmark
./scripts/benchmark.sh

# Analyze BitNet usage and energy efficiency
./scripts/analyze_bitnet.sh

# Monitor energy usage
python3 ./scripts/monitor_energy.py

# View auto-configuration logs (when using Docker)
docker logs bitnet-server | grep -E "(Auto-selected|Auto-configured)"
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

## 🛠️ Docker Support

**Note**: Docker build is currently experimental due to BitNet.cpp's complex build process. For production use, we recommend running locally with `./run_local.sh`.

If you want to experiment with Docker:
```bash
# Build the image (this may take a while)
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f bitnet

# Stop services
docker-compose down
```

## 📈 Performance Expectations

After migration to optimized BitNet.cpp:
- **Speed**: 2-6x faster inference
- **Energy**: 55-82% reduction in power consumption
- **Memory**: Better utilization with optimized kernels
- **Throughput**: Higher tokens/second

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
- [Migration Guide](./docs/MIGRATION_GUIDE.md)

## 🔒 Security Notes

- The server binds to `0.0.0.0` by default (accessible from network)
- For production use, implement proper authentication
- Consider using a reverse proxy (nginx) with SSL

## 📄 License

This project follows the MIT License. See the BitNet submodule for its specific licensing terms.

## 🙏 Acknowledgments

- Microsoft Research for BitNet
- The llama.cpp community for the inference framework