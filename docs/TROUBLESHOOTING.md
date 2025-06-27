# Troubleshooting Guide

## Common Issues and Solutions

### Setup Issues

#### Model download fails
```bash
# Alternative: Manual download
cd BitNet
mkdir -p models/BitNet-b1.58-2B-4T
wget -O models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
  https://huggingface.co/microsoft/BitNet-b1.58-2B-4T-gguf/resolve/main/ggml-model-i2_s.gguf
```

#### Build fails with compiler errors
- Ensure you have GCC 7+ or Clang 6+
- Check CMake version: `cmake --version` (need 3.14+)
- Try cleaning and rebuilding:
  ```bash
  rm -rf build/
  python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
  ```

### Server Issues

#### Port already in use
```bash
# Find process using port 8081
lsof -i :8081
# Kill the process or use a different port:
./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf --port 8082
```

#### Server crashes immediately
- Check available memory: `free -h` (need ~4GB)
- Try reducing context size:
  ```bash
  ./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
    --ctx-size 2048 --batch-size 512
  ```

#### Slow performance
- Check CPU usage: `htop`
- Try different thread counts:
  ```bash
  export OMP_NUM_THREADS=4  # Adjust based on your CPU
  ./start-server.sh
  ```

### Docker Issues

⚠️ **Note**: Docker builds are currently not supported due to BitNet's architecture-specific compilation requirements. Use the local build method instead.

### API Issues

#### Empty responses
- Check server logs for errors
- Verify the model path is correct
- Try increasing `max_tokens` in your request

#### Connection refused
- Ensure server is running: `curl http://localhost:8081/health`
- Check firewall settings if accessing remotely
- Verify the host/port in your requests

### Performance Issues

#### High CPU usage
- Normal during inference
- Reduce thread count if system becomes unresponsive
- See [Performance Tuning](./PERFORMANCE.md) for optimization

#### Out of memory
- Use TL2 kernel for memory efficiency:
  ```bash
  python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q tl2
  ```

## Getting Help

1. Check server logs for detailed error messages
2. Run diagnostics: `./scripts/diagnose.sh`
3. Open an issue: https://github.com/Code4me2/bitnet-inference/issues