//
//  KeyDerivation.swift
//  SilentKey
//
//  Service de dérivation de clés cryptographiques avec Argon2id.
//  Compatible iOS 16+ et macOS 13+.
//

import Foundation
import CryptoKit

/// Service responsable de la dérivation des clés maîtres et dérivées.
/// Utilise PBKDF2-SHA512 (CryptoKit natif) en attendant implémentation Argon2id.
public struct KeyDerivationService {
    
    // MARK: - Constantes
    
    /// Nombre d'itérations pour PBKDF2 (600 000 pour équivalence Argon2id).
    private static let iterations: Int = 600_000
    
    /// Longueur du sel en octets.
    private static let saltLength: Int = 16
    
    /// Longueur de la clé dérivée en octets (256 bits).
    private static let keyLength: Int = 32
    
    // MARK: - Erreurs
    
    /// Erreurs possibles lors de la dérivation de clés.
    public enum KeyDerivationError: LocalizedError {
        case invalidPassword
        case invalidSalt
        case derivationFailed
        case insufficientEntropy
        
        public var errorDescription: String? {
            switch self {
            case .invalidPassword:
                return "Le mot de passe fourni est invalide ou vide."
            case .invalidSalt:
                return "Le sel cryptographique est invalide."
            case .derivationFailed:
                return "Échec de la dérivation de la clé."
            case .insufficientEntropy:
                return "Entropie insuffisante pour générer le sel."
            }
        }
    }
    
    // MARK: - Génération de Sel
    
    /// Génère un sel cryptographique aléatoire.
    /// - Returns: Sel de 16 octets.
    /// - Throws: `KeyDerivationError.insufficientEntropy` si la génération échoue.
    public static func generateSalt() throws -> Data {
        var salt = Data(count: saltLength)
        let result = salt.withUnsafeMutableBytes { ptr in
            SecRandomCopyBytes(kSecRandomDefault, saltLength, ptr.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            throw KeyDerivationError.insufficientEntropy
        }
        
        return salt
    }
    
    // MARK: - Dérivation de Clé Maître
    
    /// Dérive une clé maître à partir d'un mot de passe et d'un sel.
    /// Utilise PBKDF2-SHA512 avec 600 000 itérations.
    /// - Parameters:
    ///   - password: Mot de passe utilisateur (chaîne UTF-8).
    ///   - salt: Sel cryptographique unique pour ce coffre.
    /// - Returns: Clé maître de 32 octets (256 bits).
    /// - Throws: `KeyDerivationError` en cas d'échec.
    public static func deriveMasterKey(from password: String, salt: Data) throws -> SymmetricKey {
        // Validation du mot de passe
        guard !password.isEmpty else {
            throw KeyDerivationError.invalidPassword
        }
        
        // Validation du sel
        guard salt.count == saltLength else {
            throw KeyDerivationError.invalidSalt
        }
        
        // Conversion du mot de passe en données
        guard let passwordData = password.data(using: .utf8) else {
            throw KeyDerivationError.invalidPassword
        }
        
        // Dérivation avec PBKDF2-SHA512
        // Note: CryptoKit ne fournit pas PBKDF2 directement,
        // on utilise CommonCrypto via l'API sécurisée
        var derivedKey = Data(count: keyLength)
        let status = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                passwordData.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passwordData.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        keyLength
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw KeyDerivationError.derivationFailed
        }
        
        return SymmetricKey(data: derivedKey)
    }
    
    // MARK: - Dérivation de Sous-Clés
    
    /// Dérive deux clés indépendantes depuis la clé maître via HKDF.
    /// - Parameter masterKey: Clé maître générée par `deriveMasterKey`.
    /// - Returns: Tuple contenant (vaultKey pour DB, itemKeySeed pour secrets).
    /// - Throws: `KeyDerivationError` en cas d'échec.
    public static func deriveSubkeys(from masterKey: SymmetricKey) throws -> (vaultKey: SymmetricKey, itemKeySeed: SymmetricKey) {
        // Utilisation d'HKDF pour dériver deux clés indépendantes
        let info1 = "silentkey.vault.encryption".data(using: .utf8)!
        let info2 = "silentkey.item.seed".data(using: .utf8)!
        
        let vaultKey = HKDF<SHA512>.deriveKey(
            inputKeyMaterial: masterKey,
            info: info1,
            outputByteCount: keyLength
        )
        
        let itemKeySeed = HKDF<SHA512>.deriveKey(
            inputKeyMaterial: masterKey,
            info: info2,
            outputByteCount: keyLength
        )
        
        return (vaultKey, itemKeySeed)
    }
}

// MARK: - CommonCrypto Bridge

// Import des fonctions CommonCrypto pour PBKDF2
import CommonCrypto
