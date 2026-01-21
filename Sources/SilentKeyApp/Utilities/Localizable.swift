//
//  Localizable.swift
//  SilentKey
//
//  Localization system
//

import Foundation
import SwiftUI
import os.log

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .french: return "🇫🇷"
        }
    }
}

class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    // Persistent storage of language choice
    @AppStorage("selected_language") private var storedLanguage: String = AppLanguage.french.rawValue
    
    @Published public var currentLanguage: AppLanguage {
        didSet {
            storedLanguage = currentLanguage.rawValue
            logger.info("Language updated and persisted: \(self.currentLanguage.rawValue)")
        }
    }
    
    private init() {
        let savedLang = UserDefaults.standard.string(forKey: "selected_language") ?? AppLanguage.french.rawValue
        self.currentLanguage = AppLanguage(rawValue: savedLang) ?? .french
        logger.info("LocalizationManager initialized with language: \(self.currentLanguage.rawValue)")
    }
    
    public func localized(_ key: LocalizedKey) -> String {
        return key.localized(for: currentLanguage)
    }
}

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "Localization")

enum LocalizedKey {
    // Authentication
    case appName
    case appTagline
    case masterPassword
    case unlock
    case authenticating
    case useBiometric
    case touchID
    case faceID
    case biometry
    case authError
    case dataEncryptedLocally
    case securityKey
    case biometricAccess
    
    // Main Interface
    case vault
    case projects
    case trash
    case settings
    case search
    case newSecret
    case quickSearch
    
    // Vault
    case secrets
    case secured
    case recent
    case noSecrets
    case noSecretsMessage
    case createSecret
    
    // Settings
    case general
    case autoLock
    case notifications
    case security
    case biometricAuth
    case changeMasterPassword
    case about
    case version
    case build
    
    // Secret Types
    case apiKey
    case token
    case credential
    case sshKey
    case generic
    
    // Actions
    case cancel
    case save
    case delete
    case edit
    case copy
    case share
    case logout
    case addSecret
    
    // Common
    case title
    case type
    case value
    case information
    case secretValue
    
    func localized(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return englishTranslation
        case .french:
            return frenchTranslation
        }
    }
    
    private var englishTranslation: String {
        switch self {
        // Authentication
        case .appName: return "Silent Key"
        case .appTagline: return "Secure Secrets Manager"
        case .masterPassword: return "Master Password"
        case .unlock: return "Unlock"
        case .authenticating: return "Authenticating..."
        case .useBiometric: return "Use"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .biometry: return "Biometry"
        case .authError: return "Authentication Error"
        case .dataEncryptedLocally: return "Your secrets are encrypted locally"
        case .securityKey: return "Security Key"
        case .biometricAccess: return "Biometrics"
        
        // Main Interface
        case .vault: return "Vault"
        case .projects: return "Projects"
        case .trash: return "Trash"
        case .settings: return "Settings"
        case .search: return "Search..."
        case .newSecret: return "New Secret"
        case .quickSearch: return "Quick Search"
        
        // Vault
        case .secrets: return "Secrets"
        case .secured: return "Secured"
        case .recent: return "Recent"
        case .noSecrets: return "No Secrets"
        case .noSecretsMessage: return "Start by creating your first secure secret"
        case .createSecret: return "Create Secret"
        
        // Settings
        case .general: return "General"
        case .autoLock: return "Auto Lock"
        case .notifications: return "Notifications"
        case .security: return "Security"
        case .biometricAuth: return "Biometric Authentication"
        case .changeMasterPassword: return "Change Master Password"
        case .about: return "About"
        case .version: return "Version"
        case .build: return "Build"
        
        // Secret Types
        case .apiKey: return "API Key"
        case .token: return "Token"
        case .credential: return "Credential"
        case .sshKey: return "SSH Key"
        case .generic: return "Generic"
        
        // Actions
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .delete: return "Delete"
        case .edit: return "Edit"
        case .copy: return "Copy"
        case .share: return "Share"
        case .logout: return "Logout"
        case .addSecret: return "Add Secret"
        
        // Common
        case .title: return "Title"
        case .type: return "Type"
        case .value: return "Value"
        case .information: return "Information"
        case .secretValue: return "Secret Value"
        }
    }
    
    private var frenchTranslation: String {
        switch self {
        // Authentication
        case .appName: return "Silent Key"
        case .appTagline: return "Gestionnaire de Secrets Sécurisé"
        case .masterPassword: return "Mot de passe maître"
        case .unlock: return "Déverrouiller"
        case .authenticating: return "Authentification..."
        case .useBiometric: return "Utiliser"
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .biometry: return "Biométrie"
        case .authError: return "Erreur d'authentification"
        case .dataEncryptedLocally: return "Vos secrets sont chiffrés localement"
        case .securityKey: return "Clé de sécurité"
        case .biometricAccess: return "Biométrie"
        
        // Main Interface
        case .vault: return "Coffre-fort"
        case .projects: return "Projets"
        case .trash: return "Poubelle"
        case .settings: return "Réglages"
        case .search: return "Rechercher..."
        case .newSecret: return "Nouveau Secret"
        case .quickSearch: return "Recherche Rapide"
        
        // Vault
        case .secrets: return "Secrets"
        case .secured: return "Sécurisés"
        case .recent: return "Récents"
        case .noSecrets: return "Aucun Secret"
        case .noSecretsMessage: return "Commencez par créer votre premier secret sécurisé"
        case .createSecret: return "Créer un Secret"
        
        // Settings
        case .general: return "Général"
        case .autoLock: return "Verrouillage Auto"
        case .notifications: return "Notifications"
        case .security: return "Sécurité"
        case .biometricAuth: return "Authentification Biométrique"
        case .changeMasterPassword: return "Changer le Mot de Passe Maître"
        case .about: return "À Propos"
        case .version: return "Version"
        case .build: return "Build"
        
        // Secret Types
        case .apiKey: return "Clé API"
        case .token: return "Jeton"
        case .credential: return "Identifiant"
        case .sshKey: return "Clé SSH"
        case .generic: return "Générique"
        
        // Actions
        case .cancel: return "Annuler"
        case .save: return "Enregistrer"
        case .delete: return "Supprimer"
        case .edit: return "Modifier"
        case .copy: return "Copier"
        case .share: return "Partager"
        case .logout: return "Déconnexion"
        case .addSecret: return "Ajouter un secret"
        
        // Common
        case .title: return "Titre"
        case .type: return "Type"
        case .value: return "Valeur"
        case .information: return "Informations"
        case .secretValue: return "Valeur Secrète"
        }
    }
}

// Helper extension
extension View {
    func localized(_ key: LocalizedKey) -> String {
        LocalizationManager.shared.localized(key)
    }
}
