# Contributing to BitNet Inference

Thank you for your interest in contributing to BitNet Inference! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please read and follow our [Code of Conduct](BitNet/CODE_OF_CONDUCT.md) to ensure a welcoming environment for all contributors.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists in the [Issues](https://github.com/Code4me2/bitnet-inference/issues) section
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (if applicable)
   - Expected vs actual behavior
   - System information (OS, hardware, Python version)
   - Relevant logs or error messages

### Suggesting Features

1. Check existing issues and discussions for similar proposals
2. Open a new issue with the "Feature Request" template
3. Provide:
   - Clear use case
   - Proposed implementation approach (if any)
   - Potential impact on existing functionality

### Submitting Code

1. **Fork the repository** and create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Set up your development environment**:
   ```bash
   cd BitNet
   python3 setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s
   ```

3. **Make your changes**:
   - Follow existing code style and conventions
   - Add tests for new functionality
   - Update documentation as needed
   - Ensure all tests pass

4. **Test your changes**:
   ```bash
   # Run the server
   ./build/bin/llama-server -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
     --host 0.0.0.0 --port 8081
   
   # In another terminal, run tests
   curl http://localhost:8081/health
   ```

5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```
   
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for test additions/changes
   - `refactor:` for code refactoring
   - `perf:` for performance improvements

6. **Push and create a Pull Request**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Pull Request Guidelines

1. **PR Title**: Use conventional commit format
2. **Description**: 
   - Explain what changes you made and why
   - Reference any related issues
   - Include screenshots for UI changes
3. **Requirements**:
   - All CI checks must pass
   - Code must be tested
   - Documentation must be updated
   - No merge conflicts

## Development Guidelines

### Code Style

- Python: Follow PEP 8
- C++: Follow the existing llama.cpp style
- Use meaningful variable and function names
- Add comments for complex logic

### Testing

- Add unit tests for new functionality
- Ensure existing tests pass
- Test on multiple platforms if possible
- Include performance benchmarks for optimization changes

### Documentation

- Update README.md for user-facing changes
- Add inline documentation for new functions
- Update setup guides if installation steps change
- Include examples for new features

## Performance Contributions

When contributing performance improvements:

1. Run benchmarks before and after:
   ```bash
   cd BitNet && python3 ../python/benchmarks/run_benchmark.py
   ```

2. Document:
   - Hardware tested on
   - Performance gains observed
   - Any trade-offs or limitations

3. Consider kernel-specific optimizations:
   - Test with different kernels (I2_S, TL1, TL2)
   - Document kernel-specific behaviors

## Areas for Contribution

### High Priority
- Docker build fixes
- Additional model support
- Performance optimizations
- API compatibility improvements

### Good First Issues
- Documentation improvements
- Test coverage expansion
- Code cleanup and refactoring
- Example scripts

### Advanced
- Kernel optimizations
- Hardware-specific acceleration
- New quantization methods
- Distributed inference support

## Questions?

- Open a [Discussion](https://github.com/Code4me2/bitnet-inference/discussions) for general questions
- Check the [Documentation](./docs/) for detailed guides
- Review existing issues and PRs for context

Thank you for contributing to BitNet Inference!