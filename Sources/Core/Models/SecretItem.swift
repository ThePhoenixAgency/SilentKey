//
//  SecretItem.swift
//  SilentKey - Modèle de données pour secret
//

import Foundation

/// Type de secret stocké.
public enum SecretType: String, Codable {
    case apiKey = "API Key"
    case token = "Token"
    case credential = "Credential"
    case sshKey = "SSH Key"
    case generic = "Generic"
}

/// Représente un secret chiffré dans le coffre.
public struct SecretItem: Identifiable, Codable {
    public let id: UUID
    public var title: String
    public var type: SecretType
    public var encryptedValue: Data
    public var notes: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        type: SecretType,
        encryptedValue: Data,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.encryptedValue = encryptedValue
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
