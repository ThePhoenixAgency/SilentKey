//
//  KeychainManager.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import Foundation
import Security
import os.log

private let logger = os.Logger(subsystem: "com.thephoenixagency.silentkey", category: "Keychain")

/**
 KeychainManager (v0.9.0)
 Provides secure storage for sensitive data in the macOS Keychain.
 Updated to track if the vault is protected by a master password.
 */
public class KeychainManager {
    public static let shared = KeychainManager()
    
    private let service = "com.thephoenixagency.silentkey"
    private let masterPasswordAccount = "master_password"
    private let isProtectedKey = "is_vault_protected"
    
    private init() {}
    
    /**
     Saves data to the keychain.
     */
    public func save(_ data: Data, for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            logger.info("Successfully saved data to keychain for account: \(account)")
            return true
        } else {
            logger.error("Failed to save data to keychain. Status: \(status)")
            return false
        }
    }
    
    /**
     Reads data from the keychain.
     */
    public func read(for account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {
            return nil
        }
    }
    
    /**
     Deletes data from the keychain.
     */
    public func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Master Password Logic
    
    public func saveMasterPassword(_ password: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }
        let success = save(data, for: masterPasswordAccount)
        if success {
            UserDefaults.standard.set(true, forKey: isProtectedKey)
        }
        return success
    }
    
    public func getMasterPassword() -> String? {
        guard let data = read(for: masterPasswordAccount) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func removeMasterPassword() {
        delete(for: masterPasswordAccount)
        UserDefaults.standard.set(false, forKey: isProtectedKey)
    }
    
    /// Returns true if the user has explicitly set a master password.
    public var isVaultProtected: Bool {
        return UserDefaults.standard.bool(forKey: isProtectedKey) && getMasterPassword() != nil
    }
}
