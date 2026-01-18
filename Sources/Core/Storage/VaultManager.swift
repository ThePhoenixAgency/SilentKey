//
//  VaultManager.swift
//  SilentKey
//

import Foundation
import CryptoKit

/// Gestionnaire principal du coffre-fort chiffré
actor VaultManager {
    static let shared = VaultManager()
    
    private let encryptionManager: EncryptionManager
    private let fileStorage: FileStorage
    private let logger = Logger.shared
    
    private(set) var isUnlocked: Bool = false
    private var masterKey: SymmetricKey?
    
    // MARK: - Initialisation
    
    private init() {
        self.encryptionManager = EncryptionManager.shared
        self.fileStorage = FileStorage.shared
    }
    
    // MARK: - Unlock/Lock
    
    /// Déverrouille le coffre avec le mot de passe maître
    func unlock(masterPassword: String) async throws {
        logger.log("Tentative de déverrouillage du coffre", level: .info, category: .security)
        
        // Dériver la clé maître depuis le mot de passe
        guard let derivedKey = try? await encryptionManager.deriveKey(from: masterPassword) else {
            logger.log("Échec de dérivation de la clé maître", level: .error, category: .security)
            throw VaultError.invalidMasterPassword
        }
        
        masterKey = derivedKey
        isUnlocked = true
        
        logger.log("Coffre déverrouillé avec succès", level: .info, category: .security)
    }
    
    /// Verrouille le coffre et efface la clé de la RAM
    func lock() {
        logger.log("Verrouillage du coffre", level: .info, category: .security)
        
        // Effacer la clé de la RAM
        masterKey = nil
        isUnlocked = false
        
        logger.log("Coffre verrouillé", level: .info, category: .security)
    }
    
    // MARK: - CRUD Operations
    
    /// Crée un nouvel item dans le coffre
    func create<T: SecretItemProtocol>(_ item: T) async throws -> T {
        guard isUnlocked, let key = masterKey else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Création d'un nouvel item: \(item.title)", level: .info, category: .storage)
        
        // Chiffrer l'item
        let encryptedData = try await encryptionManager.encrypt(item, using: key)
        
        // Sauvegarder
        try await fileStorage.save(encryptedData, forID: item.id)
        
        logger.log("Item créé avec succès", level: .info, category: .storage)
        return item
    }
    
    /// Lit un item depuis le coffre
    func read<T: SecretItemProtocol>(id: UUID, as type: T.Type) async throws -> T {
        guard isUnlocked, let key = masterKey else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Lecture de l'item: \(id)", level: .debug, category: .storage)
        
        // Charger les données chiffrées
        let encryptedData = try await fileStorage.load(forID: id)
        
        // Déchiffrer
        let item = try await encryptionManager.decrypt(encryptedData, as: type, using: key)
        
        return item
    }
    
    /// Met à jour un item existant
    func update<T: SecretItemProtocol>(_ item: T) async throws -> T {
        guard isUnlocked, let key = masterKey else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Mise à jour de l'item: \(item.title)", level: .info, category: .storage)
        
        // Créer une nouvelle version avec modifiedAt mis à jour
        var updatedItem = item
        updatedItem.modifiedAt = Date()
        
        // Chiffrer et sauvegarder
        let encryptedData = try await encryptionManager.encrypt(updatedItem, using: key)
        try await fileStorage.save(encryptedData, forID: updatedItem.id)
        
        logger.log("Item mis à jour avec succès", level: .info, category: .storage)
        return updatedItem
    }
    
    /// Supprime un item (soft delete vers la poubelle)
    func delete(id: UUID) async throws {
        guard isUnlocked else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Suppression de l'item: \(id)", level: .info, category: .storage)
        
        // Déplacer vers la poubelle au lieu de supprimer
        try await fileStorage.moveToTrash(forID: id)
        
        logger.log("Item déplacé vers la poubelle", level: .info, category: .storage)
    }
    
    /// Liste tous les items d'un type donné
    func list<T: SecretItemProtocol>(type: T.Type) async throws -> [T] {
        guard isUnlocked, let key = masterKey else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Liste des items de type: \(type)", level: .debug, category: .storage)
        
        let ids = try await fileStorage.listAllIDs()
        var items: [T] = []
        
        for id in ids {
            do {
                let item = try await read(id: id, as: type)
                items.append(item)
            } catch {
                logger.log("Erreur lecture item \(id): \(error)", level: .warning, category: .storage)
            }
        }
        
        return items
    }
    
    // MARK: - Backup & Recovery
    
    /// Crée un backup chiffré complet du coffre
    func createBackup(to url: URL) async throws {
        guard isUnlocked, let key = masterKey else {
            throw VaultError.vaultLocked
        }
        
        logger.log("Création d'un backup", level: .info, category: .storage)
        
        let backup = try await fileStorage.createBackup()
        let encryptedBackup = try await encryptionManager.encrypt(backup, using: key)
        
        try encryptedBackup.write(to: url)
        
        logger.log("Backup créé avec succès", level: .info, category: .storage)
    }
    
    /// Restaure le coffre depuis un backup
    func restoreBackup(from url: URL, masterPassword: String) async throws {
        logger.log("Restauration depuis backup", level: .info, category: .storage)
        
        let encryptedBackup = try Data(contentsOf: url)
        
        // Dériver la clé depuis le mot de passe
        guard let derivedKey = try? await encryptionManager.deriveKey(from: masterPassword) else {
            throw VaultError.invalidMasterPassword
        }
        
        let backup = try await encryptionManager.decrypt(encryptedBackup, as: Data.self, using: derivedKey)
        try await fileStorage.restoreBackup(backup)
        
        logger.log("Backup restauré avec succès", level: .info, category: .storage)
    }
}

// MARK: - Vault Errors

public enum VaultError: LocalizedError {
    case vaultLocked
    case invalidMasterPassword
    case itemNotFound
    case encryptionFailed
    case decryptionFailed
    
    var errorDescription: String? {
        switch self {
        case .vaultLocked:
            return "Le coffre est verrouillé. Veuillez le déverrouiller d'abord."
        case .invalidMasterPassword:
            return "Mot de passe maître invalide."
        case .itemNotFound:
            return "Item non trouvé."
        case .encryptionFailed:
            return "Échec du chiffrement."
        case .decryptionFailed:
            return "Échec du déchiffrement."
        }
    }
}
