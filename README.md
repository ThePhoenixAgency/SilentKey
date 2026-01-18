# SilentKey

<div align="center">

**Local-first developer secrets vault with double-layer encryption**

[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey.svg)](https://github.com/ThePhoenixAgency/SilentKey)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue.svg)](https://developer.apple.com/xcode/swiftui/)

[English](#english) | [Francais](#francais)

</div>

---

## English

### Overview

SilentKey is a professional, local-first secrets vault designed specifically for developers who need to securely manage API keys, tokens, credentials, SSH keys, and sensitive data. Built with SwiftUI, it runs natively on both iOS and macOS with no cloud dependency, no telemetry, and complete transparency.

### Key Features

- **Double-Layer Encryption**: AES-256-GCM + ChaCha20-Poly1305 for maximum security
- **Local-First Architecture**: All data stays on your device, no cloud sync required
- **Cross-Platform**: Native SwiftUI app for iOS 16+ and macOS 13+
- **Biometric Authentication**: Touch ID / Face ID integration
- **Developer-Focused**: Optimized for API keys, tokens, credentials, SSH keys, database connections
- **Zero Telemetry**: No tracking, no analytics, no data collection
- **Modern UI**: Professional, clean interface with dark mode support
- **Export/Import**: Encrypted backup and restore functionality
- **Project Management**: Link secrets to projects with multiple relations
- **Smart Trash**: 30-day retention with automatic conflict resolution
- **Push Notifications**: Native macOS alerts for security events
- **Apple Intelligence**: On-device AI for smart suggestions (macOS 15+)
- **HaveIBeenPwned**: Automatic password breach detection

### Security Model

**Encryption Layers:**
1. **Layer 1 - Field Level**: AES-256-GCM for individual secret fields
2. **Layer 2 - Container**: ChaCha20-Poly1305 for the entire vault
3. **Key Derivation**: Argon2id for master key generation

**Security Principles:**
- Zero plaintext storage on disk
- RAM-only decryption with automatic cleanup
- Sandboxed macOS environment
- Code signing and notarization (macOS 10.15+)
- OWASP compliance

### Supported Secret Types

- API Keys (REST, GraphQL, OAuth, JWT, Bearer)
- SSH Keys (RSA, ED25519, ECDSA, DSA)
- Database Credentials (PostgreSQL, MySQL, MongoDB, Redis)
- Cloud Provider Credentials (AWS, Azure, GCP, DigitalOcean)
- Banking Information (encrypted account details)
- Credit Cards (encrypted)
- Secure Notes
- Certificates (SSL/TLS)
- License Keys
- Custom Types (extensible via plugins)

### Build from Source

```bash
git clone https://github.com/ThePhoenixAgency/SilentKey.git
cd SilentKey
open SilentKey.xcodeproj
```

1. Select your target (iOS or macOS)
2. Build and run (Cmd+R)

### Architecture

```
SilentKey/
├── SilentKeyApp/          # Main app entry
├── Core/                  # Core infrastructure
│   ├── Crypto/            # Encryption modules
│   ├── Models/            # Data models
│   ├── Security/          # Security utilities
│   └── Errors/            # Error handling
├── Features/              # Feature modules
│   ├── Secrets/           # Secret management
│   ├── ApiKeys/           # API key handling
│   ├── Tokens/            # Token management
│   ├── Credentials/       # Credentials
│   ├── SSH/               # SSH key manager
│   ├── Backup/            # Export/import
│   ├── Settings/          # App settings
│   └── QuickSearch/       # Global search
├── Infrastructure/        # Infrastructure
│   ├── Persistence/       # Local storage
│   ├── Keychain/          # Keychain integration
│   └── Biometrics/        # Face ID / Touch ID
├── UI/                    # Shared UI components
└── Docs/                  # Documentation
    ├── en/                # English docs
    └── fr/                # French docs
```

### Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [Templates & Plugins](docs/TEMPLATES.md)
- [Development Roadmap](docs/BACKLOG.md)

### Features

- Secure vault for all developer secrets
- Field-level encryption
- Import/Export encrypted backups
- Biometric unlock (Touch ID / Face ID)
- Auto-fill support (macOS)
- Quick search (Cmd+K)
- Dark mode
- Multiple vaults
- Team sharing (E2E encrypted)
- Password generator
- Import from .env files
- Export to various formats

### Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Security

For security vulnerabilities, please open a private security advisory on GitHub or submit an issue.

### License

Commercial License - see [LICENSE](LICENSE) for details.

### Support

For support requests:
- Submit an issue on GitHub: https://github.com/ThePhoenixAgency/SilentKey/issues
- Use the in-app support form (coming soon)

---

## Francais

### Vue d'ensemble

SilentKey est un coffre-fort professionnel de secrets, local-first, concu specifiquement pour les developpeurs qui doivent gerer de maniere securisee des cles API, tokens, identifiants, cles SSH et donnees sensibles. Construit avec SwiftUI, il fonctionne nativement sur iOS et macOS sans dependance cloud, sans telemetrie et avec une transparence complete.

### Fonctionnalites principales

- **Chiffrement double couche**: AES-256-GCM + ChaCha20-Poly1305 pour une securite maximale
- **Architecture Local-First**: Toutes les donnees restent sur votre appareil, pas de sync cloud
- **Multi-plateforme**: Application SwiftUI native pour iOS 16+ et macOS 13+
- **Authentification biometrique**: Integration Touch ID / Face ID
- **Oriente developpeurs**: Optimise pour cles API, tokens, identifiants, cles SSH, connexions BDD
- **Zero telemetrie**: Aucun tracking, aucune analytique, aucune collecte de donnees
- **Interface moderne**: Interface professionnelle et epuree avec support du mode sombre
- **Export/Import**: Fonctionnalite de sauvegarde et restauration chiffree
- **Gestion projets**: Liaison de secrets a des projets avec relations multiples
- **Corbeille intelligente**: Retention 30 jours avec resolution automatique des conflits
- **Notifications push**: Alertes macOS natives pour evenements securite
- **Apple Intelligence**: IA on-device pour suggestions intelligentes (macOS 15+)
- **HaveIBeenPwned**: Detection automatique des fuites de mots de passe

### Modele de securite

**Couches de chiffrement:**
1. **Couche 1 - Niveau champ**: AES-256-GCM pour les champs individuels
2. **Couche 2 - Conteneur**: ChaCha20-Poly1305 pour l'ensemble du coffre
3. **Derivation de cles**: Argon2id pour generation cle maitre

**Principes de securite:**
- Zero stockage en clair sur disque
- Dechiffrement en RAM uniquement avec nettoyage automatique
- Environnement macOS en sandbox
- Signature de code et notarisation (macOS 10.15+)
- Conformite OWASP

### Types de secrets supportes

- Cles API (REST, GraphQL, OAuth, JWT, Bearer)
- Cles SSH (RSA, ED25519, ECDSA, DSA)
- Identifiants BDD (PostgreSQL, MySQL, MongoDB, Redis)
- Identifiants Cloud (AWS, Azure, GCP, DigitalOcean)
- Informations bancaires (details de compte chiffres)
- Cartes bancaires (chiffrees)
- Notes securisees
- Certificats (SSL/TLS)
- Cles de licence
- Types personnalises (extensible via plugins)

### Compiler depuis les sources

```bash
git clone https://github.com/ThePhoenixAgency/SilentKey.git
cd SilentKey
open SilentKey.xcodeproj
```

1. Selectionnez votre cible (iOS ou macOS)
2. Compiler et executer (Cmd+R)

### Documentation

- [Guide d'architecture](docs/ARCHITECTURE.md)
- [Templates & Plugins](docs/TEMPLATES.md)
- [Feuille de route](docs/BACKLOG.md)

### Fonctionnalites

- Coffre-fort securise pour tous les secrets developpeur
- Chiffrement au niveau des champs
- Import/Export de sauvegardes chiffrees
- Deverrouillage biometrique (Touch ID / Face ID)
- Support auto-remplissage (macOS)
- Recherche rapide (Cmd+K)
- Mode sombre
- Plusieurs coffres
- Partage d'equipe (E2E chiffre)
- Generateur de mots de passe
- Import depuis fichiers .env
- Export vers differents formats

### Contribution

Les contributions sont les bienvenues ! Veuillez lire [CONTRIBUTING.md](CONTRIBUTING.md) pour les directives.

### Securite

Pour les vulnerabilites de securite, veuillez ouvrir un avis de securite prive sur GitHub ou soumettre une issue.

### Licence

Licence Commerciale - voir [LICENSE](LICENSE) pour les details.

### Support

Pour les demandes de support:
- Soumettez une issue sur GitHub: https://github.com/ThePhoenixAgency/SilentKey/issues
- Utilisez le formulaire de support dans l'application (a venir)

---

Developped by ThePhoenixAgency for professional developers.
