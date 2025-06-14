#!/bin/bash

# BitNet Inference Quick Setup Script

echo "🚀 BitNet Inference Server Setup"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and docker-compose are installed"

# Create models directory
echo "📁 Creating models directory..."
mkdir -p models

# Download model if not exists
MODEL_FILE="models/ggml-model-i2_s.gguf"
if [ ! -f "$MODEL_FILE" ]; then
    echo "📥 Downloading BitNet model (this may take a while)..."
    wget -O "$MODEL_FILE" \
        "https://huggingface.co/microsoft/BitNet-b1.58-2B-4T/resolve/main/ggml-model-i2_s.gguf" \
        --show-progress
    echo "✅ Model downloaded successfully"
else
    echo "✅ Model already exists"
fi

# Build Docker image
echo "🔨 Building Docker image..."
docker-compose build

# Start services
echo "🚀 Starting BitNet server..."
docker-compose up -d

# Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 10

# Check if server is running
if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ BitNet server is running!"
    echo ""
    echo "🎉 Setup complete! You can now:"
    echo "   - Test the API: curl http://localhost:8081/health"
    echo "   - View the web UI: http://localhost:8082"
    echo "   - Check logs: docker-compose logs -f bitnet"
    echo ""
    echo "📚 See README.md for API usage examples"
else
    echo "❌ Server failed to start. Check logs with: docker-compose logs bitnet"
    exit 1
fi