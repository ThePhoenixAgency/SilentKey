# SilentKey Development Backlog

## Structure Actuelle (Ce qui existe)

### ✅ Fichiers Créés

```
Sources/Core/
├── Crypto/
│   └── (fichiers de chiffrement existants)
├── Models/
│   ├── BankingModels.swift       ✅ CRÉÉ
│   ├── APIKeyModels.swift         ✅ CRÉÉ
│   └── SecretItem.swift           ✅ EXISTE
├── Plugins/
│   └── PluginSystem.swift         ✅ CRÉÉ
├── Protocols/
│   └── SecretItemProtocol.swift   ✅ CRÉÉ
└── ErrorHandling.swift            ✅ EXISTE

docs/
└── ARCHITECTURE.md                ✅ CRÉÉ (À CORRIGER)
```

## 🔴 Tâches Critiques - À Faire Immédiatement

### 1. Corrections Documentation (PRIORITÉ MAXIMALE)
- [ ] Corriger ARCHITECTURE.md - supprimer références à fichiers inexistants
- [ ] Terminer TEMPLATES.md avec structure réelle
- [ ] Créer/Mettre à jour README.md principal
- [ ] Vérifier TOUS les chemins de fichiers dans docs/

### 2. Fichiers Manquants Core
- [ ] Sources/Core/Crypto/EncryptionManager.swift (mentionné mais absent)
- [ ] Sources/Core/Models/PasswordModels.swift
- [ ] Sources/Core/Models/CertificateModels.swift
- [ ] Sources/Core/Storage/VaultManager.swift
- [ ] Sources/Core/Storage/FileStorage.swift

### 3. Tests
- [ ] Tests/SilentKeyTests/ProtocolTests.swift
- [ ] Tests/SilentKeyTests/BankingModelsTests.swift
- [ ] Tests/SilentKeyTests/APIKeyModelsTests.swift
- [ ] Tests/SilentKeyTests/PluginSystemTests.swift
- [ ] Tests/SilentKeyTests/EncryptionTests.swift

## 🟡 Fonctionnalités Principales - Sprint 1

### Configuration Swift Package Manager
- [ ] Package.swift avec toutes les dépendances
- [ ] Définir les targets correctement
- [ ] Ajouter CryptoKit, KeychainAccess
- [ ] Configuration pour macOS 13+

### Interface SwiftUI
- [ ] SilentKeyApp/Views/MainView.swift
- [ ] SilentKeyApp/Views/SecretListView.swift
- [ ] SilentKeyApp/Views/SecretDetailView.swift
- [ ] SilentKeyApp/Views/AddSecretView.swift
- [ ] SilentKeyApp/ViewModels/VaultViewModel.swift

### Chiffrement
- [ ] Implémenter AES-256-GCM
- [ ] Gestion des clés avec Keychain
- [ ] Double-layer encryption
- [ ] Key derivation avec PBKDF2

## 🟢 Fonctionnalités Avancées - Sprint 2

### Export/Import
- [ ] Export JSON
- [ ] Export CSV
- [ ] Export encrypted vault
- [ ] Import de fichiers
- [ ] Validation à l'import

### Recherche et Filtrage
- [ ] Recherche full-text
- [ ] Filtres par catégorie
- [ ] Filtres par tags
- [ ] Tri personnalisé

### Plugins Additionnels
- [ ] Plugin de sync iCloud (optionnel)
- [ ] Plugin d'audit de sécurité
- [ ] Plugin de génération de mots de passe
- [ ] Plugin d'expiration automatique

## 🔵 Améliorations UX - Sprint 3

### Interface
- [ ] Thème clair/sombre
- [ ] Icônes personnalisées par type
- [ ] Glisser-déposer pour organisation
- [ ] Raccourcis clavier
- [ ] Touch Bar support

### Sécurité
- [ ] Auto-lock après inactivité
- [ ] Authentification biométrique (Touch ID)
- [ ] Clipboard auto-clear
- [ ] Screenshot protection

## ⚪ Nice-to-Have - Backlog

### Intégrations
- [ ] Extension Safari
- [ ] CLI pour automation
- [ ] Alfred workflow
- [ ] Raycast extension

### Avancé
- [ ] Support multi-vault
- [ ] Partage sécurisé (un-à-un)
- [ ] Historique des modifications
- [ ] Sauvegarde automatique versionnée

## 📋 Modèles de Secrets à Ajouter

### Priorité Haute
- [x] Bank Account
- [x] Credit Card
- [x] API Key
- [x] SSH Key
- [ ] Password (générique)
- [ ] Secure Note

### Priorité Moyenne  
- [ ] Database Credentials
- [ ] Server Credentials
- [ ] WiFi Password
- [ ] Software License
- [ ] SSL Certificate

### Priorité Basse
- [ ] Passport
- [ ] Driver License
- [ ] Insurance Card
- [ ] Custom Fields

## 🐛 Bugs Connus

_Aucun pour le moment (projet en développement initial)_

## 📝 Notes Techniques

### Dépendances Prévues
```swift
.package(url: "https://github.com/apple/swift-crypto", from: "3.0.0")
.package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2")
```

### Versions Minimales
- macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## 🔄 Processus de Mise à Jour du Backlog

1. Réviser chaque semaine
2. Déplacer les tâches complétées vers "Terminé"
3. Ajouter nouvelles tâches selon feedback
4. Prioriser selon: Sécurité > Fonctionnalités Core > UX > Nice-to-have

## ✅ Tâches Terminées

- [x] Supprimer config.yml du template d'issues
- [x] Créer SecretItemProtocol avec architecture modulaire
- [x] Ajouter BankAccountSecret
- [x] Ajouter CreditCardSecret
- [x] Ajouter APIKeySecret
- [x] Ajouter SSHKeySecret
- [x] Créer PluginManager
- [x] Ajouter exemple plugins (Banking, Export, Backup)
- [x] Créer TemplateManager
- [x] Documenter architecture dans ARCHITECTURE.md

---

**Dernière mise à jour:** Janvier 2026
**Statut:** Développement actif - Phase d'architecture
