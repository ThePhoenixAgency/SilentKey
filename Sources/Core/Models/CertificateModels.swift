//
// CertificateModels.swift
// SilentKey
//
// Models for SSL/TLS certificates and other digital certs
//

import Foundation

public struct CertificateSecret: SecretItemProtocol, EncryptableSecret, ExportableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    public var certificateName: String
    public var issuer: String
    public var expirationDate: Date?
    public var encryptedFields: [String: Data]
    
    public var category: SecretCategory {
        .certificate
    }
    
    public var iconName: String {
        category.icon
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        certificateName: String,
        issuer: String,
        expirationDate: Date? = nil,
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.certificateName = certificateName
        self.issuer = issuer
        self.expirationDate = expirationDate
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
        guard !certificateName.isEmpty else { throw ValidationError.emptyCertName }
    }
    
    public func searchableText() -> String {
        [title, certificateName, issuer, notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let data = value.data(using: .utf8) else { throw CertificateError.encryptionFailed }
        encryptedFields[field] = data
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let data = encryptedFields[field] else { throw CertificateError.fieldNotFound }
        guard let value = String(data: data, encoding: .utf8) else { throw CertificateError.decryptionFailed }
        return value
    }
    
    public var supportedExportFormats: [ExportFormat] {
        [.json, .encrypted]
    }
    
    public func export(format: ExportFormat) throws -> Data {
        switch format {
        case .json: return try JSONEncoder().encode(self)
        case .encrypted: return try encryptedData()
        default: throw CertificateError.unsupportedFormat
        }
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyCertName
    }
}

public enum CertificateError: Error {
    case encryptionFailed
    case decryptionFailed
    case fieldNotFound
    case unsupportedFormat
}

extension CertificateSecret: SecretTemplate {
    public static var templateName: String { "Certificate" }
    public static var templateDescription: String { "SSL/TLS and other digital certificates" }
    public static var requiredFields: [FieldDefinition] {
        [
            FieldDefinition(name: "title", displayName: "Name", type: .text, isSecure: false, placeholder: "Server Cert", validationPattern: nil),
            FieldDefinition(name: "certificateName", displayName: "Certificate Common Name", type: .text, isSecure: false, placeholder: "example.com", validationPattern: nil)
        ]
    }
    public static var optionalFields: [FieldDefinition] {
        [
            FieldDefinition(name: "issuer", displayName: "Issuer", type: .text, isSecure: false, placeholder: "Let's Encrypt", validationPattern: nil)
        ]
    }
    public static func create(from fields: [String: Any]) throws -> CertificateSecret {
        guard let title = fields["title"] as? String,
              let certName = fields["certificateName"] as? String else {
            throw CertificateError.encryptionFailed
        }
        return CertificateSecret(title: title, certificateName: certName, issuer: (fields["issuer"] as? String) ?? "Unknown")
    }
}
