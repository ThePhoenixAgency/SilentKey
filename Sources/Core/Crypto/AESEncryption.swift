//
//  AESEncryption.swift
//  SilentKey - Couche 1 de chiffrement AES-256-GCM
//

import Foundation
import CryptoKit

/// Service de chiffrement AES-256-GCM (couche 1).
public struct AESEncryptionService {
    
    public enum EncryptionError: LocalizedError {
        case encryptionFailed
        case decryptionFailed
        case invalidKey
        
        public var errorDescription: String? {
            switch self {
            case .encryptionFailed: return "Échec du chiffrement AES."
            case .decryptionFailed: return "Échec du déchiffrement AES."
            case .invalidKey: return "Clé AES invalide."
            }
        }
    }
    
    /// Chiffre des données avec AES-256-GCM.
    /// - Parameters:
    ///   - plaintext: Données à chiffrer.
    ///   - key: Clé symétrique 256-bit.
    /// - Returns: Données chiffrées avec nonce et tag intégrés.
    public static func encrypt(_ plaintext: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        guard let combinedData = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combinedData
    }
    
    /// Déchiffre des données AES-256-GCM.
    /// - Parameters:
    ///   - ciphertext: Données chiffrées (nonce + tag + données).
    ///   - key: Clé symétrique.
    /// - Returns: Données déchiffrées.
    public static func decrypt(_ ciphertext: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
