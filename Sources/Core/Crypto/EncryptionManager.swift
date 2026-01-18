//
//  EncryptionManager.swift
//  SilentKey
//
//  Gestionnaire centralisé du chiffrement pour VaultManager
//

import Foundation
import CryptoKit

/// Gestionnaire de chiffrement pour le coffre-fort
public actor EncryptionManager {
    public static let shared = EncryptionManager()
    
    private init() {}
    
    /// Dérive une clé depuis un mot de passe
    /// - Parameter password: Mot de passe maître
    /// - Returns: Clé symétrique dérivée, ou nil en cas d'échec
    public func deriveKey(from password: String) async throws -> SymmetricKey? {
        guard !password.isEmpty else {
            return nil
        }
        
        do {
            // Générer ou récupérer le sel (pour démo, on génère un nouveau sel)
            // En production, le sel devrait être stocké de manière persistante
            let salt = try KeyDerivationService.generateSalt()
            let masterKey = try KeyDerivationService.deriveMasterKey(from: password, salt: salt)
            return masterKey
        } catch {
            return nil
        }
    }
    
    /// Chiffre un item codable
    /// - Parameters:
    ///   - item: Item à chiffrer
    ///   - key: Clé de chiffrement
    /// - Returns: Données chiffrées
    public func encrypt<T: Encodable>(_ item: T, using key: SymmetricKey) async throws -> Data {
        let encoder = JSONEncoder()
        let plainData = try encoder.encode(item)
        return try AESEncryptionService.encrypt(plainData, with: key)
    }
    
    /// Déchiffre des données vers un type codable
    /// - Parameters:
    ///   - data: Données chiffrées
    ///   - type: Type cible
    ///   - key: Clé de déchiffrement
    /// - Returns: Item déchiffré
    public func decrypt<T: Decodable>(_ data: Data, as type: T.Type, using key: SymmetricKey) async throws -> T {
        let plainData = try AESEncryptionService.decrypt(data, with: key)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: plainData)
    }
}
