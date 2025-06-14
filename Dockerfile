# Multi-stage build for BitNet inference server
FROM ubuntu:22.04 as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Clone BitNet repository with submodules
WORKDIR /build
RUN git clone --recursive https://github.com/microsoft/BitNet.git

# Build BitNet
WORKDIR /build/BitNet
RUN mkdir build && cd build && \
    cmake .. -DGGML_NATIVE=OFF && \
    make -j$(nproc) llama-server

# Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built binaries
COPY --from=builder /build/BitNet/build/bin/llama-server /usr/local/bin/

# Create directory for models
RUN mkdir -p /models

# Download the BitNet model (optional - can be mounted instead)
# Uncomment the following lines to include the model in the image
# RUN wget -O /models/ggml-model-i2_s.gguf \
#     https://huggingface.co/microsoft/BitNet-b1.58-2B-4T/resolve/main/ggml-model-i2_s.gguf

# Expose port
EXPOSE 8081

# Default environment variables
ENV OMP_NUM_THREADS=4
ENV MODEL_PATH=/models/ggml-model-i2_s.gguf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

# Default command
CMD ["sh", "-c", "llama-server -m ${MODEL_PATH} --host 0.0.0.0 --port 8081 -c 2048"]