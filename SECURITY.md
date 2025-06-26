# Security Policy

## Supported Versions

Currently, we support security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### 1. Do NOT create a public issue

Security vulnerabilities should not be reported through public GitHub issues.

### 2. Report privately

Please report security vulnerabilities by emailing the maintainers directly or through GitHub's private vulnerability reporting:

1. Go to the Security tab of the repository
2. Click on "Report a vulnerability"
3. Follow the private disclosure process

### 3. Include details

When reporting, please include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information

### 4. Response timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 5 business days
- **Resolution target**: Within 30 days for critical issues

## Security Best Practices

When using BitNet Inference:

### Network Security
- The server binds to `0.0.0.0` by default, making it accessible from the network
- For production use, implement proper authentication and authorization
- Consider using a reverse proxy (nginx) with SSL/TLS
- Restrict network access using firewalls

### API Security
- Implement rate limiting to prevent abuse
- Validate and sanitize all input data
- Monitor for unusual usage patterns
- Keep logs for security auditing

### Model Security
- Only use trusted model files
- Verify model checksums when downloading
- Be aware of potential model poisoning attacks
- Limit model file permissions

### Container Security
- Run containers with minimal privileges
- Use specific version tags, not `latest`
- Regularly update base images
- Scan images for vulnerabilities

## Security Features

### Current Security Measures
- Input validation on API endpoints
- Configurable host binding
- Resource limits (context size, batch size)
- Process isolation when using containers

### Planned Security Enhancements
- Built-in authentication support
- API key management
- Request signing
- Audit logging

## Dependencies

We regularly update dependencies to patch security vulnerabilities. Key dependencies:

- **llama.cpp**: Core inference engine
- **Python packages**: Listed in requirements.txt
- **System libraries**: CMake, GCC/Clang

Run security audits with:
```bash
# For Python dependencies
pip audit

# For system packages
# Ubuntu/Debian
sudo apt update && sudo apt upgrade

# macOS
brew update && brew upgrade
```

## Compliance

This project follows security best practices but has not been formally audited. For production use in regulated environments, conduct your own security assessment.

## Contact

For security concerns, contact the maintainers through:
- GitHub Security Advisory
- Private message to repository maintainers

Thank you for helping keep BitNet Inference secure!