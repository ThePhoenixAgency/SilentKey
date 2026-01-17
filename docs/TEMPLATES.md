# SilentKey Templates Guide

**Version:** 1.0.0  
**Date:** 18/01/2026

This guide explains how to create custom secret types, plugins, and templates for SilentKey.

---

## Table of Contents

1. [Creating Custom Secret Types](#creating-custom-secret-types)
2. [Creating Templates](#creating-templates)
3. [Creating Plugins](#creating-plugins)
4. [Best Practices](#best-practices)
5. [Examples](#examples)

---

## Creating Custom Secret Types

### Step 1: Define Your Secret Struct

Create a new struct that conforms to `SecretItemProtocol`:

```swift
import Foundation

public struct MyCustomSecret: SecretItemProtocol, EncryptableSecret, ExportableSecret {
    // Required by SecretItemProtocol
    public let id: UUID
    public var title: String
    public var tags: Set<String>
    public var createdAt: Date
    public var modifiedAt: Date
    public var category: SecretCategory { .custom }
    
    // Your custom fields
    public var customField1: String
    public var customField2: Int
    
    // Required by EncryptableSecret
    public var encryptedFields: [String: Data]
    
    public init(
        id: UUID = UUID(),
        title: String,
        tags: Set<String> = [],
        customField1: String,
        customField2: Int
    ) {
        self.id = id
        self.title = title
        self.tags = tags
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.customField1 = customField1
        self.customField2 = customField2
        self.encryptedFields = [:]
    }
}
```

### Step 2: Implement Encryption

```swift
extension MyCustomSecret {
    public mutating func encrypt(field: String, value: String, using key: Data) throws {
        // Implementation of field encryption
        let encryptedData = try AESEncryption.encrypt(value, with: key)
        encryptedFields[field] = encryptedData
    }
    
    public func decrypt(field: String, using key: Data) throws -> String {
        guard let encryptedData = encryptedFields[field] else {
            throw EncryptionError.fieldNotFound
        }
        return try AESEncryption.decrypt(encryptedData, with: key)
    }
}
```

### Step 3: Implement Export

```swift
extension MyCustomSecret {
    public func export(format: ExportFormat) throws -> Data {
        switch format {
        case .json:
            return try JSONEncoder().encode(self)
        case .csv:
            let csvString = "\(title),\(customField1),\(customField2)\n"
            return csvString.data(using: .utf8)!
        default:
            throw ExportError.unsupportedFormat
        }
    }
    
    public var supportedExportFormats: [ExportFormat] {
        [.json, .csv, .encryptedVault]
    }
}
```

---

## Creating Templates

### Step 1: Conform to SecretTemplate

```swift
extension MyCustomSecret: SecretTemplate {
    public static var templateName: String {
        "My Custom Secret"
    }
    
    public static var requiredFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "title",
                type: .string,
                displayName: "Title",
                isEncrypted: false
            ),
            FieldDefinition(
                name: "customField1",
                type: .string,
                displayName: "Custom Field 1",
                isEncrypted: true
            )
        ]
    }
    
    public static var optionalFields: [FieldDefinition] {
        [
            FieldDefinition(
                name: "customField2",
                type: .integer,
                displayName: "Custom Field 2",
                isEncrypted: false
            )
        ]
    }
    
    public static func create(from fields: [String: Any]) throws -> MyCustomSecret {
        guard let title = fields["title"] as? String,
              let customField1 = fields["customField1"] as? String else {
            throw TemplateError.missingRequiredField
        }
        
        let customField2 = fields["customField2"] as? Int ?? 0
        
        return MyCustomSecret(
            title: title,
            customField1: customField1,
            customField2: customField2
        )
    }
}
```

### Step 2: Register Template

```swift
// In your app initialization
TemplateManager.shared.register(MyCustomSecret.self)
```

---

## Creating Plugins

### Step 1: Define Plugin Struct

```swift
public struct MyValidationPlugin: SecretPlugin {
    public let id = "com.mycompany.validation"
    public let name = "My Validation Plugin"
    public let version = "1.0.0"
    public let description = "Validates custom secrets"
    
    public var supportedCategories: [SecretCategory] {
        [.custom]
    }
    
    public var supportedActions: [PluginAction] {
        [.validate, .transform]
    }
}
```

### Step 2: Implement Plugin Logic

```swift
extension MyValidationPlugin {
    public func performAction(
        _ action: PluginAction,
        on secret: any SecretItemProtocol
    ) async throws -> PluginResult {
        switch action {
        case .validate:
            return try await validate(secret)
        case .transform:
            return try await transform(secret)
        default:
            throw PluginError.unsupportedAction
        }
    }
    
    private func validate(_ secret: any SecretItemProtocol) async throws -> PluginResult {
        // Validation logic
        guard !secret.title.isEmpty else {
            return .failure(error: "Title cannot be empty")
        }
        return .success(message: "Validation passed")
    }
    
    private func transform(_ secret: any SecretItemProtocol) async throws -> PluginResult {
        // Transformation logic
        return .success(message: "Transformation complete")
    }
}
```

### Step 3: Register Plugin

```swift
// In your app initialization
PluginManager.shared.register(MyValidationPlugin())
```

---

## Best Practices

### Security
- Always encrypt sensitive fields
- Use strong encryption (AES-256-GCM minimum)
- Never store encryption keys in plain text
- Implement proper key derivation (Argon2id)

### Performance
- Use value types (struct) over reference types (class)
- Implement lazy loading for large data
- Cache frequently accessed data
- Use async/await for I/O operations

### Code Quality
- Write comprehensive unit tests
- Document public APIs
- Follow Swift naming conventions
- Use protocol composition for flexibility

### Validation
- Validate all user inputs
- Check field lengths and formats
- Provide meaningful error messages
- Handle edge cases gracefully

---

## Examples

### Example 1: Database Credential Secret

```swift
public struct DatabaseCredential: SecretItemProtocol, EncryptableSecret {
    public let id: UUID
    public var title: String
    public var tags: Set<String>
    public var createdAt: Date
    public var modifiedAt: Date
    public var category: SecretCategory { .custom }
    
    public var hostname: String
    public var port: Int
    public var database: String
    public var encryptedFields: [String: Data] // username, password
    
    public init(
        title: String,
        hostname: String,
        port: Int,
        database: String
    ) {
        self.id = UUID()
        self.title = title
        self.tags = []
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.hostname = hostname
        self.port = port
        self.database = database
        self.encryptedFields = [:]
    }
}
```

### Example 2: License Key Plugin

```swift
public struct LicenseKeyValidator: SecretPlugin {
    public let id = "com.silentkey.licensevalidator"
    public let name = "License Key Validator"
    public var supportedCategories: [SecretCategory] { [.license] }
    
    public func performAction(
        _ action: PluginAction,
        on secret: any SecretItemProtocol
    ) async throws -> PluginResult {
        guard let license = secret as? LicenseSecret else {
            throw PluginError.incompatibleSecretType
        }
        
        // Validate license key format
        let isValid = validateFormat(license.licenseKey)
        
        if isValid {
            return .success(message: "License key format is valid")
        } else {
            return .failure(error: "Invalid license key format")
        }
    }
    
    private func validateFormat(_ key: String) -> Bool {
        // License key format validation logic
        let pattern = "^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$"
        return key.range(of: pattern, options: .regularExpression) != nil
    }
}
```

### Example 3: Project Relations Secret

```swift
public struct ProjectSecret: SecretItemProtocol {
    public let id: UUID
    public var title: String
    public var tags: Set<String>
    public var createdAt: Date
    public var modifiedAt: Date
    public var category: SecretCategory { .custom }
    
    // Project-specific fields
    public var projectName: String
    public var description: String
    public var relatedAPIKeys: Set<UUID>
    public var relatedPasswords: Set<UUID>
    public var relatedSSHKeys: Set<UUID>
    
    public init(
        title: String,
        projectName: String,
        description: String
    ) {
        self.id = UUID()
        self.title = title
        self.tags = []
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.projectName = projectName
        self.description = description
        self.relatedAPIKeys = []
        self.relatedPasswords = []
        self.relatedSSHKeys = []
    }
    
    // Methods to manage relations
    public mutating func addRelation(apiKeyId: UUID) {
        relatedAPIKeys.insert(apiKeyId)
    }
    
    public mutating func removeRelation(apiKeyId: UUID) {
        relatedAPIKeys.remove(apiKeyId)
    }
}
```

---

## Testing Your Templates and Plugins

### Unit Testing Example

```swift
import XCTest
@testable import SilentKey

class MyCustomSecretTests: XCTestCase {
    func testSecretCreation() {
        let secret = MyCustomSecret(
            title: "Test Secret",
            customField1: "Value 1",
            customField2: 42
        )
        
        XCTAssertEqual(secret.title, "Test Secret")
        XCTAssertEqual(secret.customField1, "Value 1")
        XCTAssertEqual(secret.customField2, 42)
    }
    
    func testEncryption() throws {
        var secret = MyCustomSecret(
            title: "Test",
            customField1: "Sensitive",
            customField2: 0
        )
        
        let key = Data(repeating: 0, count: 32)
        try secret.encrypt(field: "customField1", value: "Sensitive", using: key)
        
        let decrypted = try secret.decrypt(field: "customField1", using: key)
        XCTAssertEqual(decrypted, "Sensitive")
    }
}
```

---

## Template and Plugin Guidelines

### DO:
- Follow protocol-oriented design
- Implement proper error handling
- Write comprehensive tests
- Document your code
- Use type-safe APIs
- Handle edge cases
- Validate all inputs

### DON'T:
- Store sensitive data in plain text
- Ignore errors silently
- Use force-unwrapping
- Mix concerns (keep plugins focused)
- Break existing APIs
- Skip validation

---

## Additional Resources

- [ARCHITECTURE.md](ARCHITECTURE.md) - Overall architecture guide
- [BACKLOG.md](BACKLOG.md) - Development roadmap
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

---

**Last Updated:** 18/01/2026  
**Version:** 1.0.0  
**Maintained by:** SilentKey Development Team
