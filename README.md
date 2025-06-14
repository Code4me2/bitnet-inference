# BitNet Inference Server

Easy-to-deploy BitNet inference server with Docker support for running 1-bit LLMs efficiently on CPU.

## 🚀 Quick Start (Docker)

The easiest way to get started is using Docker:

```bash
# Clone the repository
git clone https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference

# Download the model (one-time setup)
mkdir -p models
wget -O models/ggml-model-i2_s.gguf \
  https://huggingface.co/microsoft/BitNet-b1.58-2B-4T/resolve/main/ggml-model-i2_s.gguf

# Start the server
docker-compose up -d

# Check if it's running
curl http://localhost:8081/health
```

## 📦 What's Included

- **BitNet Server**: High-performance inference server for 1-bit LLMs
- **Docker Configuration**: Pre-configured for easy deployment
- **Model Support**: BitNet b1.58 2B model (2.4B parameters)
- **N8N Integration**: Ready for workflow automation

## 🔧 Configuration

### Environment Variables

- `OMP_NUM_THREADS`: Number of CPU threads (default: 4)
- `MODEL_PATH`: Path to the GGUF model file (default: `/models/ggml-model-i2_s.gguf`)

### Ports

- `8081`: BitNet inference server
- `8082`: Optional web UI (if enabled)

## 🐳 Docker Commands

```bash
# Build the image
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f bitnet

# Stop services
docker-compose down

# Update and rebuild
git pull
docker-compose build --no-cache
docker-compose up -d
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

This server is designed to work with the [N8N BitNet custom node](https://github.com/Code4me2/data-compose). 

To connect from N8N:
- If N8N is in Docker: Use `http://bitnet:8081` (same network) or `http://host.docker.internal:8081`
- If N8N is on host: Use `http://localhost:8081`

## 📊 Performance Tuning

For optimal performance:

1. **CPU Threads**: Set `OMP_NUM_THREADS` to match your CPU cores
2. **Memory**: Allocate at least 4GB RAM for the 2B model
3. **CPU Affinity**: Use `taskset` for dedicated CPU cores:
   ```bash
   docker-compose exec bitnet taskset -c 0-3 llama-server ...
   ```

## 🛠️ Building from Source

If you prefer to build from source:

```bash
# Clone with submodules
git clone --recursive https://github.com/Code4me2/bitnet-inference.git
cd bitnet-inference

# Follow BitNet build instructions
cd BitNet
pip install -r requirements.txt
python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# Run the server
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  --host 0.0.0.0 --port 8081
```

## 📚 Documentation

- [BitNet Official Repository](https://github.com/microsoft/BitNet)
- [Model on Hugging Face](https://huggingface.co/microsoft/BitNet-b1.58-2B-4T)
- [N8N Integration Guide](./BITNET_N8N_OPTIMIZATION_PLAN.md)

## 🔒 Security Notes

- The server binds to `0.0.0.0` by default (accessible from network)
- For production use, implement proper authentication
- Consider using a reverse proxy (nginx) with SSL

## 📄 License

This project follows the MIT License. See the BitNet submodule for its specific licensing terms.

## 🙏 Acknowledgments

- Microsoft Research for BitNet
- The llama.cpp community for the inference framework