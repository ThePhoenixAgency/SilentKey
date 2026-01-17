# SilentKey Development Backlog

<!--🤖 INSTRUCTIONS POUR IA - FICHIER: docs/BACKLOG.md
Ce fichier doit être maintenu à jour par toute IA travaillant sur le projet SilentKey.

RÈGLES DE MAINTENANCE:
1. TOUJOURS mettre à jour la version et la date en haut du fichier
2. Ajouter les nouvelles tâches dans la section appropriée (Critique/Sprint/Backlog)
3. Déplacer les tâches complétées vers "✅ Tâches Terminées"
4. Maintenir la structure actuelle du fichier
5. Vérifier que les chemins de fichiers correspondent à la structure réelle
6. Ajouter un commentaire de changement dans l'historique des versions

FORMAT DES VERSIONS:
- Version X.Y.Z (Date JJ/MM/AAAA)
  - Liste des changements

PRIORISATION:
🔴 Critique > 🟡 Sprint actuel > 🟢 Prochain sprint > 🔵 UX > ⚪ Nice-to-have
-->

---

# 📋 SilentKey Development Backlog

**Version:** 1.2.0  
**Date:** 18/01/2026  
**Status:** Développement actif - Phase d'architecture étendue

## 📝 Historique des Versions

### Version 1.2.0 (18/01/2026)
- Ajout gestion documents privés (photos, papiers notariaux, assurances, pièces d'identité)
- Ajout contacts d'urgence internationaux en cas de piratage (par pays)
- Ajout procédures de recovery/backup/export/import
- Ajout détection doublons et mots de passe réutilisés
- Ajout intégration HaveIBeenPwned API (gratuit) pour vérification fuites
- Ajout système de paiement App Store (In-App Purchase)
- Ajout exigences code signing et notarisation macOS
- Ajout politique de stockage sécurisé (rien en local non chiffré)
- Comparaison avec top 10 apps sécurisées (Bitwarden, Vault, 1Password)

### Version 1.1.0 (18/01/2026)
- Ajout section sécurité des données sensibles
- Ajout modèles d'identité (SSN, passeport, permis, carte ID)
- Ajout stratégies de stockage local et cloud
- Ajout considérations de sécurité cloud
- Documentation sur protection contre piratage via cloud

### Version 1.0.0 (18/01/2026)
- Création initiale du backlog
- Documentation structure existante
- Définition sprints 1, 2, 3
- Liste des tâches critiques

---

## 📁 Structure Actuelle (Ce qui existe)

### ✅ Fichiers Créés

```
Sources/Core/
├── Crypto/
│   └── (fichiers de chiffrement existants)
├── Models/
│   ├── BankingModels.swift ✅ CRÉÉ
│   ├── APIKeyModels.swift ✅ CRÉÉ
│   └── SecretItem.swift ✅ EXISTE
├── Plugins/
│   └── PluginSystem.swift ✅ CRÉÉ
├── Protocols/
│   └── SecretItemProtocol.swift ✅ CRÉÉ
└── ErrorHandling.swift ✅ EXISTE

docs/
├── BACKLOG.md ✅ CE FICHIER
└── ARCHITECTURE.md ⚠️ À CORRIGER (références invalides)
```

---

## 🔴 Tâches Critiques - À Faire Immédiatement

### 1. Audit & Corrections Documentation (PRIORITÉ MAXIMALE)
- [ ] **Vérifier TOUS les fichiers markdown** pour références inexistantes
- [ ] Corriger ARCHITECTURE.md - supprimer références à fichiers/dossiers inexistants
- [ ] Créer liste exhaustive de tous les fichiers/dossiers manquants
- [ ] Créer le dossier `Security/` s'il est référencé
- [ ] Mapper la structure réelle vs structure documentée

### 2. Fichiers Manquants Core (BLOQUANT)
- [ ] `Sources/Core/Crypto/EncryptionManager.swift` (mentionné mais absent)
- [ ] `Sources/Core/Models/PasswordModels.swift`
- [ ] `Sources/Core/Models/CertificateModels.swift`
- [ ] `Sources/Core/Storage/VaultManager.swift`
- [ ] `Sources/Core/Storage/FileStorage.swift`
- [ ] `Sources/Core/Security/` (dossier complet)

### 3. Tests Manquants
- [ ] `Tests/SilentKeyTests/ProtocolTests.swift`
- [ ] `Tests/SilentKeyTests/BankingModelsTests.swift`
- [ ] `Tests/SilentKeyTests/APIKeyModelsTests.swift`
- [ ] `Tests/SilentKeyTests/PluginSystemTests.swift`
- [ ] `Tests/SilentKeyTests/EncryptionTests.swift`

---

## 🟡 Fonctionnalités Principales - Sprint 1

### A. Gestion Documents Privés (NOUVEAU)
- [ ] **Modèle DocumentItem.swift**
  - Photos chiffrées
  - Documents scannés (PDF, images)
  - Catégories: Notarial, Identité, Assurance, Médical, Financier
  - Métadonnées: date d'expiration, pays émetteur
  - Tags personnalisés
- [ ] **Stockage sécurisé documents**
  - Chiffrement AES-256 avant stockage
  - Compression optionnelle
  - Limite taille fichier
  - Gestion versions
- [ ] **Import/Export documents**
  - Import depuis Photos, Scanner, Fichiers
  - Export chiffré (format propriétaire)
  - Preview sécurisé dans l'app

### B. Gestion Mots de Passe Avancée (NOUVEAU)
- [ ] **Détection réutilisation**
  - Hash comparaison (SHA-256)
  - Alert si mot de passe déjà utilisé
  - Suggestion changement
  - Historique des mots de passe par site
- [ ] **Détection doublons**
  - Mapping parfait des entrées
  - Fusion intelligente des doublons
  - Prévention création doublons
- [ ] **HaveIBeenPwned Integration**
  - API Pwned Passwords (GRATUIT, k-Anonymity)
  - Check automatique à la création/modification
  - Alert si mot de passe compromis
  - Batch check de tous les mots de passe
  - Privacy: envoi seulement 5 premiers caractères du SHA-1
- [ ] **Générateur mots de passe**
  - Longueur configurable
  - Complexité paramétrable
  - Exclusion caractères ambigus
  - Passphrase diceware

### C. Recovery & Backup (NOUVEAU - CRITIQUE)
- [ ] **Système de backup chiffré**
  - Export complet vault (format chiffré propriétaire)
  - Backup automatique local
  - Backup manuel sur demande
  - Vérification intégrité backup
- [ ] **Import/Export universel**
  - Import depuis 1Password, Bitwarden, LastPass, Dashlane
  - Export CSV chiffré
  - Format interchange JSON chiffré
  - Mapping intelligent des champs
- [ ] **Recovery key**
  - Génération clé maître recovery
  - QR Code de recovery
  - Split key (Shamir Secret Sharing)
  - Stockage sécurisé hors app

### D. Contacts Urgence Internationaux (NOUVEAU)
- [ ] **Base de données contacts par pays**
  - Numéros urgence fraude bancaire (par pays + international)
  - Emails support plateformes (Google, Apple, Microsoft, etc.)
  - Contacts autorités cyber (CNIL France, IC3 USA, etc.)
  - Ambassades/consulats
  - Opérateurs télécom
- [ ] **Détection pays utilisateur**
  - Géolocalisation optionnelle
  - Sélection manuelle pays
  - Liste pays multiples
- [ ] **Actions rapides urgence**
  - Bouton panic "J'ai été piraté"
  - Checklist actions immédiates
  - Accès rapide contacts
  - Log des actions prises

---

## 🟢 Fonctionnalités Principales - Sprint 2

### E. Sécurité & Chiffrement (RENFORCÉ)
- [ ] **Politique "Zero local storage non chiffré"**
  - JAMAIS de données en clair sur disque
  - RAM uniquement pour données déchiffrées
  - Effacement RAM après usage
  - Sandboxing strict macOS
- [ ] **Double-layer encryption**
  - Layer 1: AES-256-GCM (données)
  - Layer 2: ChaCha20-Poly1305 (conteneur)
  - Clés dérivées via Argon2id
  - Salt unique par entrée
- [ ] **Code signing & Notarization**
  - Developer ID Application certificate
  - Notarization obligatoire (macOS 10.15+)
  - Hardened Runtime
  - Secure Timestamp
- [ ] **Audit sécurité**
  - Conformité OWASP
  - Comparaison avec Bitwarden/1Password
  - Penetration testing
  - Security.txt publication

### F. Stockage & Sync Cloud (SÉCURISÉ)
- [ ] **iCloud Keychain integration**
  - Sync optionnel via CloudKit
  - Chiffrement end-to-end
  - Minimal metadata exposure
- [ ] **Custom cloud backend (optionnel)**
  - Chiffrement côté client AVANT upload
  - Zero-knowledge architecture
  - Serveur ne voit que blob chiffré
  - Protection contre piratage cloud
- [ ] **Offline-first**
  - Fonctionnement 100% local par défaut
  - Sync optionnel uniquement
  - Conflit resolution

### G. Monétisation (NOUVEAU)
- [ ] **In-App Purchase (StoreKit)**
  - Produit: SilentKey Pro (non-consommable)
  - Features Pro: sync cloud, documents illimités, support prioritaire
  - Configuration App Store Connect
  - Gestion achats restaurés
  - Période essai gratuite (optionnel)
- [ ] **App Store submission**
  - Conformité App Store Guidelines
  - Privacy Policy
  - EULA
  - Screenshots & descriptions
  - App Store Optimization (ASO)

---

## 🔵 Fonctionnalités Principales - Sprint 3

### H. Modèles de Données Étendus
- [ ] **IdentityModels.swift** (compléter)
  - Passeports (avec scan)
  - Cartes identité
  - Permis de conduire
  - Cartes vitale/sécu sociale
  - Documents notariaux
  - Contrats assurance
- [ ] **Validation données sensibles**
  - Format numéro sécu selon pays
  - Validation IBAN/BIC
  - Validation numéro passeport
  - Date expiration alertes
- [ ] **Attachments système**
  - Photos de documents
  - PDF scannés
  - Fichiers multiples par entrée
  - Indexation recherche

### I. UI/UX Excellence
- [ ] Interface SwiftUI moderne
- [ ] Dark mode optimisé
- [ ] Animations fluides
- [ ] Drag & drop documents
- [ ] Search performant
- [ ] Quick actions (Cmd+K)
- [ ] Touch Bar support

### J. Plugins & Extensibilité (MODULAIRE)
- [ ] Architecture plugins documentée
- [ ] Templates plugins
- [ ] API plugins sécurisée
- [ ] Browser extensions (Safari)
- [ ] CLI tool
- [ ] Alfred/Raycast workflow

---

## ⚪ Backlog Long Terme

### Intégrations Tierces
- [ ] Import Bitwarden
- [ ] Import 1Password (OPVault)
- [ ] Import LastPass
- [ ] Import KeePass
- [ ] Import Chrome passwords
- [ ] Import CSV générique

### Fonctionnalités Avancées
- [ ] Authentification biométrique (Touch ID, Face ID)
- [ ] Yubikey support
- [ ] SSH key management
- [ ] Code signing certificates
- [ ] TOTP/2FA generator
- [ ] Secure notes
- [ ] Password sharing (chiffré)
- [ ] Audit trail complet
- [ ] Breach monitoring continu

### DevOps
- [ ] CI/CD GitHub Actions
- [ ] Tests automatisés (>80% coverage)
- [ ] Sécurité: SAST, DAST
- [ ] Documentation complète
- [ ] Contribution guidelines

---

## 📊 Comparaison Top 10 Apps Sécurisées

### Apps à Analyser
1. **Bitwarden** ✅ (open source, référence)
2. **1Password** (UX gold standard)
3. **Dashlane** (features riches)
4. **LastPass** (legacy leader)
5. **KeePassXC** (offline, open source)
6. **HashiCorp Vault** ✅ (entreprise, infrastructure)
7. **Infisical** ✅ (secrets management dev)
8. **NordPass** (password manager)
9. **Keeper** (enterprise, famille)
10. **Enpass** (offline-first)

### Points Clés à Retenir
- **Bitwarden**: Open source, audit public, zero-knowledge, gratuit
- **1Password**: UX exemplaire, travel mode, watchtower
- **KeePassXC**: 100% offline, pas de cloud, portable
- **Vault**: Infrastructure secrets, enterprise-grade
- **SilentKey Différenciateurs**:
  - Documents privés (photos, papiers notariaux)
  - Contacts urgence internationaux
  - HaveIBeenPwned intégré
  - Modulaire avec plugins
  - Compatible banking
  - Zero local storage non chiffré

---

## 🔒 Faisabilité Technique Vérifiée

### ✅ HaveIBeenPwned API
- **Statut**: FAISABLE et GRATUIT
- **API**: Pwned Passwords (k-Anonymity model)
- **Privacy**: Envoi seulement 5 premiers caractères SHA-1 hash
- **Coût**: GRATUIT (pas de clé API nécessaire pour passwords)
- **Implementation**: Simple requête HTTPS
- **Référence**: haveibeenpwned.com/API/v3

### ✅ App Store Code Signing
- **Statut**: OBLIGATOIRE et FAISABLE
- **Requis**: Developer ID Application certificate ($99/an)
- **Process**: Code signing + Notarization (macOS 10.15+)
- **Tools**: Xcode, notarytool, Hardened Runtime
- **Référence**: support.apple.com/guide/security/sec3ad8e6e53

### ✅ In-App Purchase (StoreKit)
- **Statut**: STANDARD et FAISABLE
- **Framework**: StoreKit (natif Apple)
- **Config**: App Store Connect
- **Types**: Non-consumable (SilentKey Pro)
- **Apple Fees**: 15-30% commission
- **Référence**: developer.apple.com/storekit

---

## 🎯 Priorités Immédiates

### Cette Semaine
1. ✅ Backlog complet créé (v1.2.0)
2. 🔴 **CRITIQUE**: Audit TOUS les fichiers markdown
3. 🔴 **CRITIQUE**: Créer fichiers manquants Core
4. 🟡 Créer PasswordModels.swift
5. 🟡 Créer DocumentItem.swift

### Semaine Prochaine
1. Implémenter HaveIBeenPwned client
2. Créer système backup/recovery
3. Implémenter détection doublons
4. Base de données contacts urgence
5. Tests unitaires core

### Mois 1
1. Architecture complète
2. Tous les modèles de données
3. Chiffrement double-layer
4. UI SwiftUI basique
5. Tests >50% coverage

---

## 📌 Notes Importantes

### Sécurité IRRÉPROCHABLE
- ❌ JAMAIS stocker données en clair localement
- ✅ TOUJOURS chiffrer avant écriture disque
- ✅ Effacer RAM après usage
- ✅ Audit code avant release
- ✅ Conformité OWASP Top 10
- ✅ Code signing + notarization obligatoires

### Architecture Modulaire
- Plugin system pour extensibilité
- Templates pour nouveaux plugins
- API claire et documentée
- Banking compatible dès le départ

### UX Premium
- Inspiration 1Password
- SwiftUI moderne
- Animations fluides
- Dark mode parfait

---

## 📞 Support & Contribution

**Maintenance IA**: Ce fichier doit être mis à jour à chaque changement significatif
**Format**: Markdown avec emojis pour lisibilité
**Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)

---

*Dernière mise à jour: 18/01/2026 - Version 1.2.0*
*Maintenu par: IA Assistant pour ThePhoenixAgency*
