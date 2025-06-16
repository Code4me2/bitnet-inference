#!/bin/bash

# Model Setup and Conversion Script for BitNet.cpp

MODEL_REPO=${1:-"microsoft/BitNet-b1.58-2B-4T"}
OUTPUT_DIR=${2:-"./models"}
KERNEL_TYPE=${3:-"i2_s"}

echo "Setting up BitNet model..."
echo "Repository: $MODEL_REPO"
echo "Output Directory: $OUTPUT_DIR"
echo "Kernel Type: $KERNEL_TYPE"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Download model based on kernel type
case $KERNEL_TYPE in
    "i2_s")
        echo "Downloading GGUF model for I2_S kernel..."
        huggingface-cli download "$MODEL_REPO-gguf" \
            --local-dir "$OUTPUT_DIR/$(basename $MODEL_REPO)" \
            --include "*.gguf"
        ;;
    "tl1"|"tl2")
        echo "Downloading BF16 model for TL1/TL2 conversion..."
        huggingface-cli download "$MODEL_REPO-bf16" \
            --local-dir "$OUTPUT_DIR/$(basename $MODEL_REPO)-bf16"
        
        # Convert to appropriate quantization
        cd /app/BitNet
        python ./utils/convert-helper-bitnet.py \
            "$OUTPUT_DIR/$(basename $MODEL_REPO)-bf16" \
            --outtype "$KERNEL_TYPE"
        ;;
    *)
        echo "Unknown kernel type: $KERNEL_TYPE"
        exit 1
        ;;
esac

echo "Model setup complete!"