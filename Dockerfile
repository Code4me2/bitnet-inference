# Multi-stage build for BitNet.cpp inference server
FROM ubuntu:22.04 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone BitNet repository
WORKDIR /build
RUN git clone --recursive https://github.com/microsoft/BitNet.git

# Install Python dependencies
WORKDIR /build/BitNet
RUN pip3 install --no-cache-dir -r requirements.txt

# Download the model and build BitNet.cpp
# This step downloads the model and builds the C++ components
RUN pip3 install --no-cache-dir huggingface-hub && \
    huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf \
    --local-dir models/BitNet-b1.58-2B-4T

# Run setup_env.py which builds the project
RUN python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libstdc++6 \
    wget \
    curl \
    python3 \
    python3-pip \
    util-linux \
    hwloc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies for monitoring
RUN pip3 install --no-cache-dir huggingface-hub requests psutil

# Copy built binaries and necessary files from builder
COPY --from=builder /build/BitNet/build/bin/llama-server /usr/local/bin/
COPY --from=builder /build/BitNet/models /models

# Create necessary directories
RUN mkdir -p /app/scripts

# Copy optimization scripts
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8081

# Default environment variables
ENV OMP_NUM_THREADS=auto
ENV MODEL_PATH=/models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf
ENV BITNET_KERNEL=auto
ENV CPU_AFFINITY=auto
ENV HOST=0.0.0.0
ENV PORT=8081
ENV USE_CASE=balanced
ENV MODEL_SIZE=medium

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

# Use optimized startup script
CMD ["/app/start.sh"]