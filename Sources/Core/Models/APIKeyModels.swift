//
// APIKeyModels.swift
// SilentKey
//
// API Key and Token secret models with encryption support
// Supports various API authentication methods
//

import Foundation

// MARK: - API Key Secret

public struct APIKeySecret: SecretItemProtocol, EncryptableSecret, ExportableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    // API Key specific fields
    public var serviceName: String
    public var apiKeyType: APIKeyType
    public var encryptedFields: [String: Data]
    public var expirationDate: Date?
    public var scopes: Set<String>
    
    public enum APIKeyType: String, Codable, CaseIterable {
        case restAPI = "REST API"
        case graphQL = "GraphQL"
        case oauth = "OAuth"
        case jwt = "JWT"
        case basicAuth = "Basic Auth"
        case bearerToken = "Bearer Token"
    }
    
    public var category: SecretCategory {
        .apiKey
    }
    
    public var iconName: String {
        category.icon
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        serviceName: String,
        apiKeyType: APIKeyType,
        expirationDate: Date? = nil,
        scopes: Set<String> = [],
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.serviceName = serviceName
        self.apiKeyType = apiKeyType
        self.expirationDate = expirationDate
        self.scopes = scopes
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
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        guard !serviceName.isEmpty else {
            throw ValidationError.emptyServiceName
        }
    }
    
    public func searchableText() -> String {
        [title, serviceName, apiKeyType.rawValue, notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw APIKeyError.encryptionFailed
        }
        encryptedFields[field] = valueData
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let encryptedData = encryptedFields[field] else {
            throw APIKeyError.fieldNotFound
        }
        guard let decrypted = String(data: encryptedData, encoding: .utf8) else {
            throw APIKeyError.decryptionFailed
        }
        return decrypted
    }
    
    public var supportedExportFormats: [ExportFormat] {
        [.json, .encrypted]
    }
    
    public func export(format: ExportFormat) throws -> Data {
        switch format {
        case .json:
            return try JSONEncoder().encode(self)
        case .encrypted:
            return try encryptedData()
        default:
            throw APIKeyError.unsupportedFormat
        }
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyServiceName
    }
}

// MARK: - SSH Key Secret

public struct SSHKeySecret: SecretItemProtocol, EncryptableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    // SSH Key specific fields
    public var hostname: String
    public var username: String
    public var keyType: SSHKeyType
    public var encryptedFields: [String: Data]
    public var port: Int
    
    public enum SSHKeyType: String, Codable, CaseIterable {
        case rsa = "RSA"
        case ed25519 = "ED25519"
        case ecdsa = "ECDSA"
        case dsa = "DSA"
    }
    
    public var category: SecretCategory {
        .sshKey
    }
    
    public var iconName: String {
        category.icon
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        hostname: String,
        username: String,
        keyType: SSHKeyType,
        port: Int = 22,
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.hostname = hostname
        self.username = username
        self.keyType = keyType
        self.port = port
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
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        guard !hostname.isEmpty else {
            throw ValidationError.emptyHostname
        }
        guard port > 0 && port <= 65535 else {
            throw ValidationError.invalidPort
        }
    }
    
    public func searchableText() -> String {
        [title, hostname, username, keyType.rawValue, notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw APIKeyError.encryptionFailed
        }
        encryptedFields[field] = valueData
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let encryptedData = encryptedFields[field] else {
            throw APIKeyError.fieldNotFound
        }
        guard let decrypted = String(data: encryptedData, encoding: .utf8) else {
            throw APIKeyError.decryptionFailed
        }
        return decrypted
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyHostname
        case invalidPort
    }
}

// MARK: - API Key Errors

public enum APIKeyError: Error {
    case encryptionFailed
    case decryptionFailed
    case fieldNotFound
    case unsupportedFormat
    case invalidData
    case keyExpired
}

// MARK: - API Key Template

extension APIKeySecret: SecretTemplate {
    public static var templateName: String {
        "API Key"
    }
    
    public static var templateDescription: String {
        "Securely store API keys and access tokens"
    }
    
    public static var requiredFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "title",
                displayName: "API Key Name",
                type: .text,
                isSecure: false,
                placeholder: "OpenAI API Key",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "serviceName",
                displayName: "Service Name",
                type: .text,
                isSecure: false,
                placeholder: "OpenAI",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "apiKey",
                displayName: "API Key",
                type: .password,
                isSecure: true,
                placeholder: "Enter API key",
                validationPattern: nil
            )
        ]
    }
    
    public static var optionalFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "secretKey",
                displayName: "Secret Key",
                type: .password,
                isSecure: true,
                placeholder: "Enter secret key (if applicable)",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "apiEndpoint",
                displayName: "API Endpoint",
                type: .url,
                isSecure: false,
                placeholder: "https://api.service.com",
                validationPattern: nil
            )
        ]
    }
    
    public static func create(from fields: [String: Any]) throws -> APIKeySecret {
        guard let title = fields["title"] as? String,
              let serviceName = fields["serviceName"] as? String,
              let apiKeyTypeRaw = fields["apiKeyType"] as? String,
              let apiKeyType = APIKeyType(rawValue: apiKeyTypeRaw) else {
            throw APIKeyError.invalidData
        }
        
        return APIKeySecret(
            title: title,
            serviceName: serviceName,
            apiKeyType: apiKeyType
        )
    }
}
