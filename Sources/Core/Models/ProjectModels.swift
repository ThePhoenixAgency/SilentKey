//
//  ProjectModels.swift
//  SilentKey
//

import Foundation
import SwiftUI

/// Modèle de projet développeur avec relations multiples
struct ProjectItem: SecretItemProtocol, Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var version: Int
    var createdAt: Date
    var modifiedAt: Date
    
    // Propriétés spécifiques au projet
    var description: String
    var tags: Set<String>
    var status: ProjectStatus
    var icon: ProjectIcon
    var color: String // Hex color
    
    // Relations multiples (N-N)
    var relatedAPIKeys: [UUID]
    var relatedSecrets: [UUID]
    var relatedBankingAccounts: [UUID]
    var relatedCertificates: [UUID]
    var relatedPasswords: [UUID]
    
    // Métadonnées
    var notes: String?
    var url: String? // URL du dépôt Git ou site web
    var environment: ProjectEnvironment
    var isFavorite: Bool
    
    // MARK: - Initialisation
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        tags: Set<String> = [],
        status: ProjectStatus = .active,
        icon: ProjectIcon = .folder,
        color: String = "#007AFF",
        notes: String? = nil,
        url: String? = nil,
        environment: ProjectEnvironment = .development,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.version = 1
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.description = description
        self.tags = tags
        self.status = status
        self.icon = icon
        self.color = color
        self.relatedAPIKeys = []
        self.relatedSecrets = []
        self.relatedBankingAccounts = []
        self.relatedCertificates = []
        self.relatedPasswords = []
        self.notes = notes
        self.url = url
        self.environment = environment
        self.isFavorite = isFavorite
    }
    
    // MARK: - Relations Management
    
    /// Ajoute une relation vers un API Key
    mutating func addAPIKey(_ keyID: UUID) {
        if !relatedAPIKeys.contains(keyID) {
            relatedAPIKeys.append(keyID)
            modifiedAt = Date()
        }
    }
    
    /// Supprime une relation vers un API Key
    mutating func removeAPIKey(_ keyID: UUID) {
        relatedAPIKeys.removeAll { $0 == keyID }
        modifiedAt = Date()
    }
    
    /// Ajoute une relation vers un Secret
    mutating func addSecret(_ secretID: UUID) {
        if !relatedSecrets.contains(secretID) {
            relatedSecrets.append(secretID)
            modifiedAt = Date()
        }
    }
    
    /// Supprime une relation vers un Secret
    mutating func removeSecret(_ secretID: UUID) {
        relatedSecrets.removeAll { $0 == secretID }
        modifiedAt = Date()
    }
    
    /// Ajoute une relation vers un compte bancaire
    mutating func addBankingAccount(_ accountID: UUID) {
        if !relatedBankingAccounts.contains(accountID) {
            relatedBankingAccounts.append(accountID)
            modifiedAt = Date()
        }
    }
    
    /// Supprime une relation vers un compte bancaire
    mutating func removeBankingAccount(_ accountID: UUID) {
        relatedBankingAccounts.removeAll { $0 == accountID }
        modifiedAt = Date()
    }
    
    /// Compte total des relations
    var totalRelations: Int {
        relatedAPIKeys.count + relatedSecrets.count + 
        relatedBankingAccounts.count + relatedCertificates.count + 
        relatedPasswords.count
    }
    
    /// Vérifie si le projet a des relations
    var hasRelations: Bool {
        totalRelations > 0
    }
    
    // MARK: - SecretItemProtocol Conformance
    
    var category: SecretCategory {
        return .custom
    }
    
    var iconName: String {
        return icon.systemImage
    }
    
    func encryptedData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func validate() throws {
        if title.isEmpty {
            throw ProjectValidationError.emptyTitle
        }
    }
    
    func searchableText() -> String {
        let tagsText = tags.joined(separator: " ")
        return "\(title) \(description) \(tagsText) \(notes ?? "")"
    }
}

// MARK: - Project Validation Error

enum ProjectValidationError: Error {
    case emptyTitle
}

// MARK: - Project Status

enum ProjectStatus: String, Codable, CaseIterable {
    case active = "Actif"
    case archived = "Archivé"
    case paused = "En pause"
    case completed = "Terminé"
    case planning = "Planification"
    
    var color: Color {
        switch self {
        case .active:
            return .green
        case .archived:
            return .gray
        case .paused:
            return .orange
        case .completed:
            return .blue
        case .planning:
            return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .active:
            return "play.circle.fill"
        case .archived:
            return "archivebox.fill"
        case .paused:
            return "pause.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        case .planning:
            return "lightbulb.fill"
        }
    }
}

// MARK: - Project Icon

enum ProjectIcon: String, Codable, CaseIterable {
    case folder = "folder.fill"
    case globe = "globe"
    case server = "server.rack"
    case cloud = "cloud.fill"
    case mobile = "iphone"
    case desktop = "desktopcomputer"
    case code = "chevron.left.forwardslash.chevron.right"
    case database = "cylinder.fill"
    case api = "network"
    case web = "safari.fill"
    case ios = "apple.logo"
    case android = "a.square.fill"
    case terminal = "terminal.fill"
    case gear = "gearshape.fill"
    case lock = "lock.fill"
    case key = "key.fill"
    case shield = "shield.fill"
    case cpu = "cpu.fill"
    case chart = "chart.line.uptrend.xyaxis"
    case rocket = "rocket.fill"
    
    var systemImage: String {
        return self.rawValue
    }
}

// MARK: - Project Environment

enum ProjectEnvironment: String, Codable, CaseIterable {
    case development = "Développement"
    case staging = "Staging"
    case production = "Production"
    case testing = "Test"
    case local = "Local"
    
    var color: Color {
        switch self {
        case .development:
            return .blue
        case .staging:
            return .orange
        case .production:
            return .red
        case .testing:
            return .purple
        case .local:
            return .gray
        }
    }
    
    var badge: String {
        switch self {
        case .development:
            return "DEV"
        case .staging:
            return "STG"
        case .production:
            return "PROD"
        case .testing:
            return "TEST"
        case .local:
            return "LOCAL"
        }
    }
}

// MARK: - Project Relation

/// Représente une relation entre un projet et un autre item
struct ProjectRelation: Identifiable, Codable, Hashable {
    let id: UUID
    let projectID: UUID
    let relatedItemID: UUID
    let relationType: RelationType
    let createdDate: Date
    var notes: String
    
    init(
        id: UUID = UUID(),
        projectID: UUID,
        relatedItemID: UUID,
        relationType: RelationType,
        notes: String = ""
    ) {
        self.id = id
        self.projectID = projectID
        self.relatedItemID = relatedItemID
        self.relationType = relationType
        self.createdDate = Date()
        self.notes = notes
    }
}

// MARK: - Relation Type

enum RelationType: String, Codable, CaseIterable {
    case apiKey = "Clé API"
    case secret = "Secret"
    case bankingAccount = "Compte bancaire"
    case certificate = "Certificat"
    case password = "Mot de passe"
    case document = "Document"
    case sshKey = "Clé SSH"
    
    var icon: String {
        switch self {
        case .apiKey:
            return "key.fill"
        case .secret:
            return "lock.fill"
        case .bankingAccount:
            return "creditcard.fill"
        case .certificate:
            return "doc.text.fill"
        case .password:
            return "lock.shield.fill"
        case .document:
            return "doc.fill"
        case .sshKey:
            return "terminal.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .apiKey:
            return .blue
        case .secret:
            return .purple
        case .bankingAccount:
            return .green
        case .certificate:
            return .orange
        case .password:
            return .red
        case .document:
            return .gray
        case .sshKey:
            return .cyan
        }
    }
}

// MARK: - Project Statistics

/// Statistiques d'un projet
struct ProjectStatistics: Codable {
    let projectID: UUID
    let totalAPIKeys: Int
    let totalSecrets: Int
    let totalBankingAccounts: Int
    let totalCertificates: Int
    let totalPasswords: Int
    let lastAccessDate: Date?
    let accessCount: Int
    
    var totalItems: Int {
        totalAPIKeys + totalSecrets + totalBankingAccounts + 
        totalCertificates + totalPasswords
    }
}

// MARK: - Project Filter

/// Options de filtrage pour les projets
struct ProjectFilter {
    var searchText: String = ""
    var statuses: Set<ProjectStatus> = Set(ProjectStatus.allCases)
    var environments: Set<ProjectEnvironment> = Set(ProjectEnvironment.allCases)
    var tags: Set<String> = []
    var hasRelations: Bool? = nil
    var sortBy: ProjectSortOption = .lastModified
    var sortAscending: Bool = false
    
    func matches(_ project: ProjectItem) -> Bool {
        // Recherche textuelle
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            let matchesTitle = project.title.lowercased().contains(searchLower)
            let matchesDescription = project.description.lowercased().contains(searchLower)
            let matchesTags = project.tags.contains { $0.lowercased().contains(searchLower) }
            
            if !matchesTitle && !matchesDescription && !matchesTags {
                return false
            }
        }
        
        // Filtres
        if !statuses.contains(project.status) {
            return false
        }
        
        if !environments.contains(project.environment) {
            return false
        }
        
        if !tags.isEmpty && tags.isDisjoint(with: Set(project.tags)) {
            return false
        }
        
        if let hasRelations = hasRelations {
            if hasRelations != project.hasRelations {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Project Sort Option

enum ProjectSortOption: String, CaseIterable {
    case title = "Nom"
    case createdDate = "Date de création"
    case lastModified = "Dernière modification"
    case status = "Statut"
    case relationsCount = "Nombre de relations"
    
    func compare(_ lhs: ProjectItem, _ rhs: ProjectItem, ascending: Bool) -> Bool {
        let result: Bool
        
        switch self {
        case .title:
            result = lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        case .createdDate:
            result = lhs.createdAt < rhs.createdAt
        case .lastModified:
            result = lhs.modifiedAt < rhs.modifiedAt
        case .status:
            result = lhs.status.rawValue < rhs.status.rawValue
        case .relationsCount:
            result = lhs.totalRelations < rhs.totalRelations
        }
        
        return ascending ? result : !result
    }
}
