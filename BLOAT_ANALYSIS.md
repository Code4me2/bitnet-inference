# BitNet-Inference Directory Bloat Analysis

## Current Size: 6.9GB Total

### Size Breakdown

```
5.8GB   BitNet/              (84% of total)
├── 5.4GB   models/          (78% of total, 93% of BitNet)
├── 165MB   cmake-local/     (2.4% of total)
├── 83MB    .git/            (1.2% of total)
├── 80MB    3rdparty/        (1.2% of total)
├── 57MB    build/           (0.8% of total)
└── ~10MB   other files      (0.1% of total)

1.2GB   models/              (separate from BitNet)
40KB    scripts/
32KB    bitnet-env/
12KB    web-ui/
```

## Major Space Consumers

### 1. Model Files (5.4GB in BitNet/models/)
- **4.3GB** - `BitNet-b1.58-2B-4T-regenerated/`
  - 3.2GB - `ggml-model-working.gguf` (appears to be unused)
  - 1.1GB - `model.safetensors` (duplicate of original model)
- **1.2GB** - `BitNet-b1.58-2B-4T/`
  - 1.2GB - `ggml-model-i2_s.gguf` ✅ (REQUIRED - active model)

### 2. Build System (302MB total)
- **165MB** - `cmake-local/` (local CMake installation)
- **80MB** - `3rdparty/` (llama.cpp submodule)
- **57MB** - `build/` (compiled binaries and objects)

### 3. Git History (83MB)
- Standard git repository metadata

## Bloat Assessment

### ❌ Unnecessary Files (4.3GB can be removed)
1. **BitNet-b1.58-2B-4T-regenerated/** - Entire directory appears unused
   - Contains duplicate/experimental model files
   - Not referenced in any documentation or scripts
   - Safe to remove: **saves 4.3GB**

### ⚠️ Potentially Removable (165MB)
1. **cmake-local/** - Local CMake installation
   - Only needed if system CMake is too old
   - Check with: `cmake --version` (need 3.14+)
   - If system has CMake 3.14+: **saves 165MB**

### ✅ Required Files
1. **models/BitNet-b1.58-2B-4T/** - Active model (1.2GB)
2. **build/** - Compiled server binaries (57MB)
3. **3rdparty/** - Required llama.cpp dependency (80MB)
4. **.git/** - Version control history (83MB)

## Cleanup Commands

### Safe Cleanup (removes 4.3GB)
```bash
# Remove unused regenerated model
rm -rf BitNet/models/BitNet-b1.58-2B-4T-regenerated/

# Remove any log files
rm -f BitNet/server.log BitNet/*.log
```

### Optional Cleanup (check requirements first)
```bash
# IF your system has CMake 3.14+ installed:
cmake --version  # Check version first
rm -rf BitNet/cmake-local/  # Saves 165MB

# Clean build artifacts (keeps binaries)
cd BitNet/build
make clean 2>/dev/null || true
```

### Aggressive Cleanup (removes build files - requires rebuild)
```bash
# Remove all build files (saves 57MB but requires rebuild)
rm -rf BitNet/build/

# Would need to rebuild with:
# cd BitNet && python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
```

## Summary

- **Immediate savings**: 4.3GB by removing unused model
- **Potential savings**: 165MB by removing local CMake
- **Total possible reduction**: 4.5GB (65% of current size)
- **Minimal required size**: ~2.4GB (with cleanup)

The main bloat comes from the unused regenerated model directory which contains duplicate model files in different formats.