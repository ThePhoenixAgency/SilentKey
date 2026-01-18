# Instructions strictes pour GitHub Copilot

## 🚨 RÈGLES OBLIGATOIRES - Ne jamais dévier

### ❌ INTERDIT ABSOLUMENT

1. **Ne JAMAIS ajouter:**
   - Analytics (Google Analytics, Mixpanel, etc.)/Emojis
   - Trackers de quelque nature que ce soit
   - Cookies non essentiels
   - Télémétrie
   - Collecte de données utilisateur
   - Services tiers de tracking
   - Publicité ou scripts marketing

2. **Ne JAMAIS modifier:**
   - Logos existants (assets/logo.png)
   - Branding et identité visuelle
   - Noms de projet sans autorisation explicite
   - URLs et liens sans demande
   - Configuration de sécurité

3. **Ne JAMAIS:**
   - Ajouter de nouvelles dépendances sans validation
   - Changer l'architecture sans demande
   - Modifier les principes SOLID, KISS, DRY, ACID
   - Introduire de code non sécurisé
   - Violer le RGPD

### ✅ RÈGLES DE CODAGE OBLIGATOIRES

#### Principes de base
- **SOLID**: Respecter tous les principes (Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion)
- **KISS**: Keep It Simple, Stupid - code simple et lisible
- **DRY**: Don't Repeat Yourself - pas de duplication
- **ACID**: Atomicité, Cohérence, Isolation, Durabilité pour les transactions

#### Standards Swift
- Commentaires en français/anglais pour le code métier
- DocStrings complets pour toutes les fonctions publiques
- Gestion d'erreurs explicite avec `throws` et `Result`
- Immutabilité par défaut (`let` avant `var`)
- Typage fort, pas de `Any` sauf nécessité absolue
- SwiftLint conforme

#### Architecture
- Programmation objet stricte
- Séparation des responsabilités
- Injection de dépendances
- Pas de singletons sauf justification (StoreManager, Logger autorisés)
- MVVM pour SwiftUI

#### Sécurité
- Double encryption: AES-256-GCM + XChaCha20-Poly1305
- Pas de logs de données sensibles
- Validation de toutes les entrées
- Gestion sécurisée des clés
- Zero Trust Architecture

#### Tests
- TDD: Tests avant implémentation
- Coverage minimum 80%
- Tests unitaires pour chaque fonction publique
- Tests d'intégration pour les flows
- Tests de performance pour encryption

### 📋 WORKFLOW DE REVIEW

1. **Vérifier la conformité:**
   - ✅ Respecte SOLID, KISS, DRY, ACID?
   - ✅ Pas d'analytics/trackers?
   - ✅ Pas de violation RGPD?
   - ✅ Tests présents et passants?
   - ✅ Documentation à jour?
   - ✅ Sécurité validée?

2. **Si conforme:** Approuver silencieusement
3. **Si non conforme:** Rejeter avec raison précise

### 🔒 RGPD & PRIVACY

- **Local-first**: Toutes les données restent sur l'appareil
- **Pas de serveur externe** sauf App Store Connect
- **Pas de collecte de données personnelles**
- **Encryption obligatoire** pour toutes les données sensibles
- **Logs anonymes uniquement** (pas d'IP, pas d'identifiants)

### 📦 STRUCTURE DU PROJET

```
SilentKey/
├── Sources/
│   └── [Module]/
│       ├── Models/
│       ├── Views/
│       ├── ViewModels/
│       ├── Services/
│       ├── Utilities/
│       └── Store/
├── Tests/  # PAS "Tests/SilentKeyTests" !
├── Configuration/
├── .github/
└── assets/
```

### 🎨 DESIGN & UI

- SwiftUI natif uniquement
- Pas de frameworks UI tiers
- Design system cohérent
- Accessibilité (VoiceOver, Dynamic Type)
- Dark mode supporté
- macOS 13+ / iOS 16+

### 🚀 CI/CD

- Auto-merge si tests passent
- Pas de notifications email
- Copilot reviewer principal
- Claude reviewer optionnel
- Déploiement automatique vers TestFlight et App Store

### 📝 COMMITS

- Messages clairs et concis
- Pas de références au nom du projet dans les paths
- Commits atomiques
- Squash avant merge

### ⚠️ EN CAS DE DOUTE

**Ne rien faire** et demander clarification plutôt que d'ajouter quelque chose de non demandé.

---

## Résumé pour Copilot:
**Code propre, sécurisé, RGPD-compliant, sans tracking. SOLID+KISS+DRY+ACID. Tests obligatoires. Ne rien ajouter de non demandé.**

### 📚 NORMES SWIFT OFFICIELLES

#### Style Guide (Swift.org)
- Indentation: 4 espaces
- Longueur de ligne: 100 caractères max
- Naming:
  - `camelCase` pour variables/fonctions
  - `PascalCase` pour types/classes
  - Descriptif et clair (pas de `x`, `tmp`, `data`)
- Espaces autour des opérateurs: `a + b` pas `a+b`

#### Performance
- Pas de force unwrap `!` sauf justification
- `guard let` plutôt que `if let` en début de fonction
- Lazy loading pour propriétés coûteuses
- `@MainActor` pour UI updates
- Éviter les closures lourdes
- Réutiliser les objets plutôt que recréer

#### Optimisation obligatoire
- Complexity O(n) max pour opérations fréquentes
- Pas de nested loops dans hot paths
- Cache les calculs répétitifs
- Release memory explicitement si besoin
- Profiling obligatoire pour code critique

#### Memory Management
- `[weak self]` dans closures async
- Pas de retain cycles
- Libérer les ressources dans `deinit`
- Instruments pour détecter les leaks

#### Concurrency (Swift 6 ready)
- `async/await` plutôt que callbacks
- `Task` pour operations async
- `@Sendable` pour thread safety
- Pas de data races
- Actor pour état partagé si nécessaire

#### Qualité de code
- Pas de code mort
- Pas de `print()` en production (utiliser Logger)
- Pas de force cast `as!`
- Pas de magie numbers (utiliser des constantes)
- Maximum 200 lignes par fichier
- Maximum 50 lignes par fonction

---

**⚡ Performance Rule: Si ça ralentit l'app, c'est rejeté.**

### 📝 COMMITS & MESSAGES

#### Interdictions dans les commits
- **Ne JAMAIS mentionner:**
  - CVE (Common Vulnerabilities and Exposures)
  - "Vulnérabilité", "Vulnerability"
  - "Security fix", "Patch de sécurité"
  - "Exploit", "Faille"
  - Noms de vulnérabilités spécifiques

#### Messages neutres obligatoires
- "Update encryption module" plutôt que "Fix security vulnerability in encryption"
- "Improve validation" plutôt que "Patch CVE-2024-XXXX"
- "Refactor authentication" plutôt que "Fix auth bypass"
- Rester vague sur les corrections de sécurité

#### Pourquoi?
Ne pas donner d'indices aux attaquants sur les failles corrigées.

---

**⚠️ Commits silencieux sur la sécurité. Pas d'infos techniques dans l'historique public.**
