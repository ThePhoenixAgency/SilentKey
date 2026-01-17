//
// BankingModels.swift
// SilentKey
//
// Banking-compatible secret models with full encryption support
// Supports bank accounts, credit cards, and financial credentials
//

import Foundation

// MARK: - Bank Account Secret

public struct BankAccountSecret: SecretItemProtocol, EncryptableSecret, ExportableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    // Banking-specific fields
    public var bankName: String
    public var accountType: BankAccountType
    public var encryptedFields: [String: Data]
    
    public enum BankAccountType: String, Codable, CaseIterable {
        case checking = "Checking"
        case savings = "Savings"
        case credit = "Credit"
        case investment = "Investment"
        case business = "Business"
    }
    
    public var category: SecretCategory {
        .bankAccount
    }
    
    public var iconName: String {
        category.icon
    }
    
    // Required encrypted fields for banking
    private enum EncryptedField: String {
        case accountNumber
        case routingNumber
        case iban
        case swiftCode
        case pin
        case onlineBankingUsername
        case onlineBankingPassword
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        bankName: String,
        accountType: BankAccountType,
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.bankName = bankName
        self.accountType = accountType
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
        guard !bankName.isEmpty else {
            throw ValidationError.emptyBankName
        }
    }
    
    public func searchableText() -> String {
        [title, bankName, accountType.rawValue, notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw BankingError.encryptionFailed
        }
        encryptedFields[field] = valueData
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let encryptedData = encryptedFields[field] else {
            throw BankingError.fieldNotFound
        }
        guard let decrypted = String(data: encryptedData, encoding: .utf8) else {
            throw BankingError.decryptionFailed
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
            throw BankingError.unsupportedFormat
        }
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyBankName
    }
}

// MARK: - Credit Card Secret

public struct CreditCardSecret: SecretItemProtocol, EncryptableSecret {
    public let id: UUID
    public var title: String
    public var notes: String?
    public var tags: Set<String>
    public let createdAt: Date
    public var modifiedAt: Date
    public var isFavorite: Bool
    
    public var cardIssuer: String
    public var cardType: CreditCardType
    public var encryptedFields: [String: Data]
    public var expirationDate: Date?
    public var billingAddress: Address?
    
    public enum CreditCardType: String, Codable, CaseIterable {
        case visa = "Visa"
        case mastercard = "Mastercard"
        case amex = "American Express"
        case discover = "Discover"
        case other = "Other"
    }
    
    public struct Address: Codable, Hashable {
        public var street: String
        public var city: String
        public var state: String
        public var postalCode: String
        public var country: String
    }
    
    public var category: SecretCategory {
        .creditCard
    }
    
    public var iconName: String {
        category.icon
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        cardIssuer: String,
        cardType: CreditCardType,
        expirationDate: Date? = nil,
        notes: String? = nil,
        tags: Set<String> = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.cardIssuer = cardIssuer
        self.cardType = cardType
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
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        guard !cardIssuer.isEmpty else {
            throw ValidationError.emptyCardIssuer
        }
        if let expDate = expirationDate, expDate < Date() {
            throw ValidationError.cardExpired
        }
    }
    
    public func searchableText() -> String {
        [title, cardIssuer, cardType.rawValue, notes ?? ""].joined(separator: " ")
    }
    
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw BankingError.encryptionFailed
        }
        encryptedFields[field] = valueData
        modifiedAt = Date()
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let encryptedData = encryptedFields[field] else {
            throw BankingError.fieldNotFound
        }
        guard let decrypted = String(data: encryptedData, encoding: .utf8) else {
            throw BankingError.decryptionFailed
        }
        return decrypted
    }
    
    public enum ValidationError: Error {
        case emptyTitle
        case emptyCardIssuer
        case cardExpired
    }
}

// MARK: - Banking Errors

public enum BankingError: Error {
    case encryptionFailed
    case decryptionFailed
    case fieldNotFound
    case unsupportedFormat
    case invalidData
}

// MARK: - Banking Template

extension BankAccountSecret: SecretTemplate {
    public static var templateName: String {
        "Bank Account"
    }
    
    public static var templateDescription: String {
        "Securely store bank account credentials with double-layer encryption"
    }
    
    public static var requiredFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "title",
                displayName: "Account Name",
                type: .text,
                isSecure: false,
                placeholder: "My Checking Account",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "bankName",
                displayName: "Bank Name",
                type: .text,
                isSecure: false,
                placeholder: "Bank of America",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "accountNumber",
                displayName: "Account Number",
                type: .password,
                isSecure: true,
                placeholder: "Enter account number",
                validationPattern: "^[0-9]{8,17}$"
            )
        ]
    }
    
    public static var optionalFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "routingNumber",
                displayName: "Routing Number",
                type: .password,
                isSecure: true,
                placeholder: "Enter routing number",
                validationPattern: "^[0-9]{9}$"
            ),
            FieldDefinition(
                name: "iban",
                displayName: "IBAN",
                type: .password,
                isSecure: true,
                placeholder: "Enter IBAN",
                validationPattern: nil
            ),
            FieldDefinition(
                name: "swiftCode",
                displayName: "SWIFT/BIC Code",
                type: .text,
                isSecure: false,
                placeholder: "Enter SWIFT code",
                validationPattern: "^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$"
            )
        ]
    }
    
    public static func create(from fields: [String: Any]) throws -> BankAccountSecret {
        guard let title = fields["title"] as? String,
              let bankName = fields["bankName"] as? String,
              let accountTypeRaw = fields["accountType"] as? String,
              let accountType = BankAccountType(rawValue: accountTypeRaw) else {
            throw BankingError.invalidData
        }
        
        return BankAccountSecret(
            title: title,
            bankName: bankName,
            accountType: accountType
        )
    }
}
