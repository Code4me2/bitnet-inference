# BitNet Inference Documentation

## Quick Links

### Getting Started
- [Main README](../README.md) - Start here! 4-step setup
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and solutions

### Usage Guides  
- [API Reference](./API.md) - Endpoints and parameters
- [Performance Tuning](./PERFORMANCE.md) - Optimization guide
- [N8N Integration](./N8N_INTEGRATION.md) - Workflow automation

### Advanced Topics
- [Advanced Configuration](./ADVANCED.md) - Environment variables, custom builds
- [BitNet Documentation](../BitNet/docs/) - Upstream BitNet.cpp docs

## Overview

This documentation covers the BitNet inference server, which provides:

- **Easy Setup**: Get running in 4 simple steps
- **High Performance**: 2-6x faster than llama.cpp
- **OpenAI Compatible**: Drop-in replacement API
- **CPU Optimized**: No GPU required

## Documentation Structure

```
docs/
├── README.md                 # This file
├── TROUBLESHOOTING.md       # Fix common issues
├── PERFORMANCE.md           # Speed optimization
├── API.md                   # API reference
├── N8N_INTEGRATION.md       # N8N workflows
└── ADVANCED.md              # Advanced configuration
```

## Quick Command Reference

```bash
# Start server
./start-server.sh

# Interactive chat
cd BitNet && ./bitnet-chat.sh

# Test performance
node test-token-speed.js

# Monitor server
./monitor_server.sh
```

## Contributing

To improve documentation:
1. Keep it concise and clear
2. Test all commands before documenting
3. Include expected outputs
4. Link to related sections

## Support

- Issues: https://github.com/Code4me2/bitnet-inference/issues
- Model: https://huggingface.co/microsoft/BitNet-b1.58-2B-4T
- Upstream: https://github.com/microsoft/BitNet