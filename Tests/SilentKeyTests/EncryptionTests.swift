//
//  EncryptionTests.swift
//  SilentKeyTests
//
//  Tests unitaires pour les systèmes de chiffrement
//  Valide AES-256-GCM et XChaCha20-Poly1305
//

import XCTest
@testable import SilentKeyApp

final class EncryptionTests: XCTestCase {
    
    // MARK: - Configuration
    
    override func setUp() {
        super.setUp()
        AppLogger.shared.info("Démarrage des tests de chiffrement", category: .system)
    }
    
    override func tearDown() {
        super.tearDown()
        AppLogger.shared.info("Fin des tests de chiffrement", category: .system)
    }
    
    // MARK: - Tests AES-256-GCM
    
    func testAESEncryptionDecryption() throws {
        let testData = "Secret super confidentiel".data(using: .utf8)!
        let password = "MotDePasseTrèsSécurisé123!"
        
        // Chiffrement
        let encrypted = try AESEncryption.encrypt(data: testData, password: password)
        XCTAssertNotEqual(encrypted, testData, "Les données chiffrées doivent différer des données originales")
        
        // Déchiffrement
        let decrypted = try AESEncryption.decrypt(data: encrypted, password: password)
        XCTAssertEqual(decrypted, testData, "Les données déchiffrées doivent correspondre aux données originales")
    }
    
    func testAESWithWrongPassword() {
        let testData = "Secret".data(using: .utf8)!
        let correctPassword = "correct123"
        let wrongPassword = "wrong456"
        
        do {
            let encrypted = try AESEncryption.encrypt(data: testData, password: correctPassword)
            _ = try AESEncryption.decrypt(data: encrypted, password: wrongPassword)
            XCTFail("Le déchiffrement avec un mauvais mot de passe devrait échouer")
        } catch {
            // Comportement attendu
            XCTAssertTrue(true, "Le déchiffrement avec un mauvais mot de passe a correctement échoué")
        }
    }
    
    func testAESWithEmptyData() throws {
        let emptyData = Data()
        let password = "password123"
        
        let encrypted = try AESEncryption.encrypt(data: emptyData, password: password)
        let decrypted = try AESEncryption.decrypt(data: encrypted, password: password)
        
        XCTAssertEqual(decrypted, emptyData, "Les données vides doivent rester vides après chiffrement/déchiffrement")
    }
    
    func testAESWithLargeData() throws {
        // Tester avec 1 MB de données
        let largeData = Data(repeating: 0x42, count: 1_000_000)
        let password = "password123"
        
        let encrypted = try AESEncryption.encrypt(data: largeData, password: password)
        let decrypted = try AESEncryption.decrypt(data: encrypted, password: password)
        
        XCTAssertEqual(decrypted, largeData, "Les grandes quantités de données doivent être chiffrées correctement")
    }
    
    // MARK: - Tests XChaCha20-Poly1305
    
    func testXChaChaEncryptionDecryption() throws {
        let testData = "Données ultra-secrètes".data(using: .utf8)!
        let password = "PassPhraseTrèsComplexe!"
        
        // Chiffrement
        let encrypted = try XChaChaEncryption.encrypt(data: testData, password: password)
        XCTAssertNotEqual(encrypted, testData)
        
        // Déchiffrement
        let decrypted = try XChaChaEncryption.decrypt(data: encrypted, password: password)
        XCTAssertEqual(decrypted, testData)
    }
    
    func testXChaChaWithWrongPassword() {
        let testData = "Secret".data(using: .utf8)!
        let correctPassword = "correct"
        let wrongPassword = "wrong"
        
        do {
            let encrypted = try XChaChaEncryption.encrypt(data: testData, password: correctPassword)
            _ = try XChaChaEncryption.decrypt(data: encrypted, password: wrongPassword)
            XCTFail("Le déchiffrement avec un mauvais mot de passe devrait échouer")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    // MARK: - Tests Double Encryption
    
    func testDoubleEncryptionDecryption() throws {
        let testData = "Secret avec double chiffrement".data(using: .utf8)!
        let password = "SuperSecurePassword123!"
        
        // Double chiffrement: AES puis XChaCha
        let aesEncrypted = try AESEncryption.encrypt(data: testData, password: password)
        let doubleEncrypted = try XChaChaEncryption.encrypt(data: aesEncrypted, password: password)
        
        // Double déchiffrement: XChaCha puis AES
        let xchachaDecrypted = try XChaChaEncryption.decrypt(data: doubleEncrypted, password: password)
        let finalDecrypted = try AESEncryption.decrypt(data: xchachaDecrypted, password: password)
        
        XCTAssertEqual(finalDecrypted, testData, "Le double chiffrement doit être réversible")
    }
    
    // MARK: - Tests Key Derivation
    
    func testKeyDerivationConsistency() throws {
        let password = "password123"
        let salt = "testsalt".data(using: .utf8)!
        
        // Générer deux fois la même clé
        let key1 = try KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 32)
        let key2 = try KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 32)
        
        XCTAssertEqual(key1, key2, "La dérivation de clé doit être déterministe")
    }
    
    func testKeyDerivationWithDifferentSalts() throws {
        let password = "password123"
        let salt1 = "salt1".data(using: .utf8)!
        let salt2 = "salt2".data(using: .utf8)!
        
        let key1 = try KeyDerivation.deriveKey(from: password, salt: salt1, keyLength: 32)
        let key2 = try KeyDerivation.deriveKey(from: password, salt: salt2, keyLength: 32)
        
        XCTAssertNotEqual(key1, key2, "Des sels différents doivent produire des clés différentes")
    }
    
    func testKeyDerivationKeyLength() throws {
        let password = "password123"
        let salt = "salt".data(using: .utf8)!
        
        let key16 = try KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 16)
        let key32 = try KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 32)
        let key64 = try KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 64)
        
        XCTAssertEqual(key16.count, 16)
        XCTAssertEqual(key32.count, 32)
        XCTAssertEqual(key64.count, 64)
    }
    
    // MARK: - Tests Password Generator
    
    func testPasswordGeneration() throws {
        let password = PasswordGenerator.generate(length: 32, includeSymbols: true)
        
        XCTAssertEqual(password.count, 32, "Le mot de passe doit avoir la longueur spécifiée")
        XCTAssertFalse(password.isEmpty, "Le mot de passe ne doit pas être vide")
    }
    
    func testPasswordComplexity() throws {
        let password = PasswordGenerator.generate(length: 20, includeSymbols: true)
        
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasLowercase = password.contains(where: { $0.isLowercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        
        XCTAssertTrue(hasUppercase, "Le mot de passe doit contenir des majuscules")
        XCTAssertTrue(hasLowercase, "Le mot de passe doit contenir des minuscules")
        XCTAssertTrue(hasNumber, "Le mot de passe doit contenir des chiffres")
    }
    
    func testPasswordUniqueness() throws {
        let password1 = PasswordGenerator.generate(length: 32)
        let password2 = PasswordGenerator.generate(length: 32)
        
        XCTAssertNotEqual(password1, password2, "Deux mots de passe générés doivent être différents")
    }
    
    // MARK: - Performance Tests
    
    func testEncryptionPerformance() throws {
        let testData = Data(repeating: 0x42, count: 100_000) // 100 KB
        let password = "performance_test_password"
        
        measure {
            _ = try? AESEncryption.encrypt(data: testData, password: password)
        }
    }
    
    func testDecryptionPerformance() throws {
        let testData = Data(repeating: 0x42, count: 100_000) // 100 KB
        let password = "performance_test_password"
        let encrypted = try AESEncryption.encrypt(data: testData, password: password)
        
        measure {
            _ = try? AESEncryption.decrypt(data: encrypted, password: password)
        }
    }
    
    func testKeyDerivationPerformance() throws {
        let password = "performance_test"
        let salt = "salt".data(using: .utf8)!
        
        measure {
            _ = try? KeyDerivation.deriveKey(from: password, salt: salt, keyLength: 32)
        }
    }
}
