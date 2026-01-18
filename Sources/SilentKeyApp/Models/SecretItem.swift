//
//  SecretItem.swift
//  SilentKey - Temporary UI model
//

import Foundation

// Temporary simple model for UI - should be replaced with proper SecretItemProtocol usage
struct SecretItem: Identifiable {
    let id: UUID
    var title: String
    var type: SecretType
    
    init(id: UUID = UUID(), title: String, type: SecretType) {
        self.id = id
        self.title = title
        self.type = type
    }
}

enum SecretType: String, CaseIterable {
    case apiKey = "API Key"
    case token = "Token"
    case credential = "Credential"
    case sshKey = "SSH Key"
    case generic = "Generic"
}
