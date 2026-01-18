//
//  SecurityKeyManager.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import Foundation
import os.log

private let logger = os.Logger(subsystem: "com.thephoenixagency.silentkey", category: "SecurityKeys")

public struct SecurityKey: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public let registrationDate: Date
    
    public init(id: UUID = UUID(), name: String, registrationDate: Date = Date()) {
        self.id = id
        self.name = name
        self.registrationDate = registrationDate
    }
}

/**
 SecurityKeyManager (v0.8.0)
 Manages FIDO2/U2F security keys registration and storage.
 */
public class SecurityKeyManager: ObservableObject {
    public static let shared = SecurityKeyManager()
    
    @Published public var registeredKeys: [SecurityKey] = []
    
    private let storageKey = "registered_security_keys"
    
    private init() {
        loadKeys()
    }
    
    public func registerKey(name: String) {
        let newKey = SecurityKey(name: name)
        registeredKeys.append(newKey)
        saveKeys()
        logger.info("New security key registered: \(name)")
    }
    
    public func removeKey(id: UUID) {
        registeredKeys.removeAll { $0.id == id }
        saveKeys()
        logger.info("Security key removed: \(id)")
    }
    
    private func saveKeys() {
        if let encoded = try? JSONEncoder().encode(registeredKeys) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadKeys() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SecurityKey].self, from: data) {
            registeredKeys = decoded
        }
    }
}
