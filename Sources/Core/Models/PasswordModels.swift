//
// PasswordModels.swift
// SilentKey
//
// Models for passwords and login credentials
//

import Foundation

public struct PasswordSecret: SecretItemProtocol, EncryptableSecret, ExportableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    public var username: String
    public var url: String?
    public var encryptedFields: [String: Data]
    
    public var category: SecretCategory {
        .password
    }
    
    public var iconName: String {
        category.icon
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        username: String,
        url: String? = nil,
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.username = username
        self.url = url
        self.notes = notes
        self.tags = tags
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isFavorite = isFavorite
        self.encryptedFields = [:]
    }
    
    public func encryptedData() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    public func validate() throws {
        guard !title.isEmpty else { throw ValidationError.emptyTitle }
        guard !username.isEmpty else { throw ValidationError.emptyUsername }
    }
    
    public func searchableText() -> String {
        [title, username, url ?? "", notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let data = value.data(using: .utf8) else { throw PasswordError.encryptionFailed }
        encryptedFields[field] = data
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let data = encryptedFields[field] else { throw PasswordError.fieldNotFound }
        guard let value = String(data: data, encoding: .utf8) else { throw PasswordError.decryptionFailed }
        return value
    }
    
    public var supportedExportFormats: [ExportFormat] {
        [.json, .encrypted, .csv]
    }
    
    public func export(format: ExportFormat) throws -> Data {
        switch format {
        case .json: return try JSONEncoder().encode(self)
        case .encrypted: return try encryptedData()
        default: throw PasswordError.unsupportedFormat
        }
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyUsername
    }
}

public enum PasswordError: Error {
    case encryptionFailed
    case decryptionFailed
    case fieldNotFound
    case unsupportedFormat
}

extension PasswordSecret: SecretTemplate {
    public static var templateName: String { "Password" }
    public static var templateDescription: String { "Standard login credentials" }
    public static var requiredFields: [FieldDefinition] {
        [
            FieldDefinition(name: "title", displayName: "Name", type: .text, isSecure: false, placeholder: "My Account", validationPattern: nil),
            FieldDefinition(name: "username", displayName: "Username/Email", type: .text, isSecure: false, placeholder: "user@example.com", validationPattern: nil),
            FieldDefinition(name: "password", displayName: "Password", type: .password, isSecure: true, placeholder: "Password", validationPattern: nil)
        ]
    }
    public static var optionalFields: [FieldDefinition] {
        [
            FieldDefinition(name: "url", displayName: "Website URL", type: .url, isSecure: false, placeholder: "https://example.com", validationPattern: nil)
        ]
    }
    public static func create(from fields: [String: Any]) throws -> PasswordSecret {
        guard let title = fields["title"] as? String,
              let username = fields["username"] as? String else {
            throw PasswordError.encryptionFailed
        }
        return PasswordSecret(title: title, username: username, url: fields["url"] as? String)
    }
}
