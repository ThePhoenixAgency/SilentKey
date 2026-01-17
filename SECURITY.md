# Security Policy

## Reporting a Vulnerability

If you discover a vulnerability in SilentKey, please report it responsibly:

- **Email**: Create a private security advisory on GitHub
- **Do NOT** open a public issue for vulnerabilities
- Include detailed information about the vulnerability
- Allow reasonable time for a fix before public disclosure

## Supported Versions

| Version | Supported |
|---------|----------|
| 1.x.x   | ✅ Yes    |
| < 1.0   | ❌ No     |

## Cryptographic Implementation

SilentKey uses industry-standard cryptography:

- **Key Derivation**: Argon2id with 600,000 iterations
- **Encryption Layer 1**: AES-256-GCM
- **Encryption Layer 2**: XChaCha20-Poly1305
- **Random Generation**: CryptoKit secure random

All cryptographic implementations are based on Apple's CryptoKit framework.

## Audit Status

This project has not yet undergone a formal audit. Use at your own risk.

## Contact

For sensitive issues, contact: [@EthanBellichaBernier](https://github.com/EthanBellichaBernier)
