//
//  ErrorHandling.swift
//  SilentKey
//
//  Système de gestion d'erreurs robuste et professionnel façon Apple
//  Aucune erreur ne doit faire planter l'application
//

import Foundation
import os.log

// MARK: - Erreurs SilentKey

/// Hiérarchie complète des erreurs avec codes et descriptions localisées
enum SilentKeyError: Error {
    // Erreurs de chiffrement
    case encryptionFailed(underlying: Error?)
    case decryptionFailed(underlying: Error?)
    case invalidKey
    case keyDerivationFailed
    case invalidCiphertext
    
    // Erreurs de stockage
    case storageNotAvailable
    case fileReadError(path: String, underlying: Error?)
    case fileWriteError(path: String, underlying: Error?)
    case dataCorrupted(details: String)
    case insufficientDiskSpace
    
    // Erreurs de validation
    case invalidInput(field: String, reason: String)
    case emptyValue(field: String)
    case valueTooLong(field: String, maxLength: Int)
    case invalidFormat(field: String, expectedFormat: String)
    
    // Erreurs de génération de mots de passe
    case passwordGenerationFailed(reason: String)
    case insufficientEntropy
    case weakPassword(reason: String)
    
    // Erreurs système
    case keychainError(status: OSStatus)
    case securityError(String)
    case unexpectedNil(context: String)
    case networkError(underlying: Error?)
    
    // Erreurs métier
    case duplicateEntry(name: String)
    case notFound(id: String)
    case operationCancelled
    case concurrentModification
}

// MARK: - Descriptions localisées

extension SilentKeyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        // Chiffrement
        case .encryptionFailed(let error):
            return "Échec du chiffrement" + (error.map { ": \($0.localizedDescription)" } ?? "")
        case .decryptionFailed(let error):
            return "Échec du déchiffrement" + (error.map { ": \($0.localizedDescription)" } ?? "")
        case .invalidKey:
            return "Clé de chiffrement invalide"
        case .keyDerivationFailed:
            return "Impossible de dériver la clé de chiffrement"
        case .invalidCiphertext:
            return "Données chiffrées corrompues ou invalides"
        
        // Stockage
        case .storageNotAvailable:
            return "Stockage non disponible"
        case .fileReadError(let path, let error):
            return "Impossible de lire le fichier \(path)" + (error.map { ": \($0.localizedDescription)" } ?? "")
        case .fileWriteError(let path, let error):
            return "Impossible d'écrire dans le fichier \(path)" + (error.map { ": \($0.localizedDescription)" } ?? "")
        case .dataCorrupted(let details):
            return "Données corrompues: \(details)"
        case .insufficientDiskSpace:
            return "Espace disque insuffisant"
        
        // Validation
        case .invalidInput(let field, let reason):
            return "Entrée invalide pour \(field): \(reason)"
        case .emptyValue(let field):
            return "Le champ \(field) ne peut pas être vide"
        case .valueTooLong(let field, let maxLength):
            return "Le champ \(field) dépasse la longueur maximale de \(maxLength) caractères"
        case .invalidFormat(let field, let expectedFormat):
            return "Format invalide pour \(field). Format attendu: \(expectedFormat)"
        
        // Génération de mots de passe
        case .passwordGenerationFailed(let reason):
            return "Échec de la génération du mot de passe: \(reason)"
        case .insufficientEntropy:
            return "Entropie insuffisante pour générer un mot de passe sécurisé"
        case .weakPassword(let reason):
            return "Mot de passe trop faible: \(reason)"
        
        // Système
        case .keychainError(let status):
            return "Erreur Keychain (code \(status))"
        case .securityError(let message):
            return "Erreur de sécurité: \(message)"
        case .unexpectedNil(let context):
            return "Valeur nulle inattendue dans \(context)"
        case .networkError(let error):
            return "Erreur réseau" + (error.map { ": \($0.localizedDescription)" } ?? "")
        
        // Métier
        case .duplicateEntry(let name):
            return "Une entrée nommée '\(name)' existe déjà"
        case .notFound(let id):
            return "Élément introuvable (ID: \(id))"
        case .operationCancelled:
            return "Opération annulée par l'utilisateur"
        case .concurrentModification:
            return "Modification concurrente détectée"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .encryptionFailed, .decryptionFailed:
            return "Problème de chiffrement"
        case .storageNotAvailable, .fileReadError, .fileWriteError:
            return "Problème d'accès au stockage"
        case .invalidInput, .emptyValue, .valueTooLong:
            return "Données d'entrée invalides"
        case .passwordGenerationFailed, .weakPassword:
            return "Problème de génération de mot de passe"
        default:
            return nil
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .storageNotAvailable:
            return "Vérifiez que l'application a les permissions nécessaires"
        case .insufficientDiskSpace:
            return "Libérez de l'espace disque"
        case .weakPassword:
            return "Utilisez le générateur de mots de passe sécurisé"
        case .dataCorrupted:
            return "Restaurez depuis une sauvegarde"
        case .keychainError:
            return "Redémarrez l'application"
        default:
            return "Veuillez réessayer"
        }
    }
}

// MARK: - Système de logging professionnel

/// Logger centralisé avec niveaux et catégories
struct AppLogger {
    private static let subsystem = "com.silentkey.app"
    
    enum Category: String {
        case encryption = "Encryption"
        case storage = "Storage"
        case ui = "UI"
        case security = "Security"
        case network = "Network"
        case general = "General"
        case performance = "Performance"
    }
    
    private let logger: OSLog
    private let category: Category
    
    init(category: Category) {
        self.category = category
        self.logger = OSLog(subsystem: AppLogger.subsystem, category: category.rawValue)
    }
    
    // MARK: - Niveaux de log
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let context = "[\(fileName(from: file))]:\(line) \(function)"
        os_log(.debug, log: logger, "%{public}@ - %{public}@", context, message)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function) {
        os_log(.info, log: logger, "[%{public}@] %{public}@", function, message)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function) {
        os_log(.default, log: logger, "⚠️ [%{public}@] %{public}@", function, message)
    }
    
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let context = "[\(fileName(from: file))]:\(line) \(function)"
        if let error = error {
            os_log(.error, log: logger, "❌ %{public}@ - %{public}@: %{public}@", context, message, error.localizedDescription)
        } else {
            os_log(.error, log: logger, "❌ %{public}@ - %{public}@", context, message)
        }
    }
    
    func fault(_ message: String, error: Error? = nil, file: String = #file, function: String = #function) {
        if let error = error {
            os_log(.fault, log: logger, "💥 FAULT [%{public}@] %{public}@: %{public}@", function, message, error.localizedDescription)
        } else {
            os_log(.fault, log: logger, "💥 FAULT [%{public}@] %{public}@", function, message)
        }
    }
    
    // MARK: - Helpers
    
    private func fileName(from path: String) -> String {
        return (path as NSString).lastPathComponent
    }
}

// MARK: - Gestionnaire d'erreurs global

/// Gestionnaire centralisé qui garantit qu'aucune erreur ne fait planter l'app
class ErrorHandler {
    static let shared = ErrorHandler()
    private let logger = AppLogger(category: .general)
    
    private init() {}
    
    /// Gère une erreur de manière sûre sans crasher
    func handle(_ error: Error, context: String = "", recoveryAction: (() -> Void)? = nil) {
        logger.error("Error in \(context)", error: error)
        
        // Stratégies de récupération selon le type d'erreur
        if let silentKeyError = error as? SilentKeyError {
            handleSilentKeyError(silentKeyError, recoveryAction: recoveryAction)
        } else {
            // Erreur système inconnue
            logger.warning("Unknown error type: \(type(of: error))")
            recoveryAction?()
        }
    }
    
    private func handleSilentKeyError(_ error: SilentKeyError, recoveryAction: (() -> Void)?) {
        switch error {
        case .dataCorrupted:
            logger.fault("Data corruption detected", error: error)
            // Tentative de récupération automatique
            recoveryAction?()
            
        case .keychainError(let status):
            logger.error("Keychain error with status: \(status)")
            // Retry logic pourrait être implémentée ici
            
        case .insufficientDiskSpace:
            logger.warning("Disk space low")
            // Notification utilisateur
            
        default:
            recoveryAction?()
        }
    }
    
    /// Execute une opération avec gestion d'erreur automatique
    @discardableResult
    func safely<T>(
        _ operation: () throws -> T,
        context: String = "",
        defaultValue: T,
        onError: ((Error) -> Void)? = nil
    ) -> T {
        do {
            return try operation()
        } catch {
            logger.error("Safe execution failed in \(context)", error: error)
            onError?(error)
            return defaultValue
        }
    }
    
    /// Version async
    func safely<T>(
        _ operation: () async throws -> T,
        context: String = "",
        defaultValue: T,
        onError: ((Error) -> Void)? = nil
    ) async -> T {
        do {
            return try await operation()
        } catch {
            logger.error("Safe async execution failed in \(context)", error: error)
            onError?(error)
            return defaultValue
        }
    }
}

// MARK: - Result type extensions

extension Result {
    /// Log automatique des erreurs
    func logError(logger: AppLogger, context: String = "") -> Result<Success, Failure> {
        if case .failure(let error) = self {
            logger.error("Operation failed in \(context)", error: error)
        }
        return self
    }
}
