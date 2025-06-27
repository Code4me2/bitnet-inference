#!/bin/bash
# BitNet Bloat Cleanup Script
# Removes unnecessary files to save disk space

echo "BitNet Bloat Cleanup Script"
echo "==========================="

# Get initial size
INITIAL_SIZE=$(du -sh . | cut -f1)
echo "Initial directory size: $INITIAL_SIZE"

# Remove unused regenerated models
if [ -d "BitNet/models/BitNet-b1.58-2B-4T-regenerated" ]; then
    echo "Removing unused regenerated model directory..."
    rm -rf BitNet/models/BitNet-b1.58-2B-4T-regenerated/
    echo "  ✓ Removed 4.3GB of unused model files"
fi

# Remove log files
echo "Removing log files..."
find . -name "*.log" -type f -exec rm -f {} \; 2>/dev/null
echo "  ✓ Removed log files"

# Remove Python cache files
echo "Removing Python cache files..."
find . -name "__pycache__" -type d -exec rm -rf {} \; 2>/dev/null
find . -name "*.pyc" -type f -exec rm -f {} \; 2>/dev/null
echo "  ✓ Removed Python cache"

# Optional: Remove build artifacts (commented out by default)
# echo "Remove build artifacts? This will require rebuilding. (y/N)"
# read -r response
# if [[ "$response" =~ ^[Yy]$ ]]; then
#     cd BitNet/build && make clean 2>/dev/null || true
#     cd ../..
#     echo "  ✓ Cleaned build artifacts"
# fi

# Get final size
FINAL_SIZE=$(du -sh . | cut -f1)
echo ""
echo "Cleanup complete!"
echo "Final directory size: $FINAL_SIZE"
echo "Space saved: ~4.3GB (if regenerated model was present)"

# Note about cmake-local
if [ -d "BitNet/cmake-local" ]; then
    echo ""
    echo "Note: cmake-local (165MB) is kept because system CMake is not installed."
    echo "Install CMake 3.14+ system-wide to remove this directory."
fi