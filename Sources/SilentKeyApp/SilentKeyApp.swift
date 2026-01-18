//
//  SilentKeyApp.swift
//  SilentKey
//
//  Point d'entrée principal de l'application SilentKey.
//  Compatible iOS 16+ et macOS 13+.
//
//  Créé le 17/01/2026.
//  Licence MIT.
//

import SwiftUI

/// Point d'entrée principal de l'application SilentKey.
/// Gère le cycle de vie de l'app et la navigation initiale.
@main
struct SilentKeyApp: App {
    
    // MARK: - Propriétés
    
    /// Gestionnaire d'état global de l'application.
    @StateObject private var appState = AppState()
    
    /// Gestionnaire d'authentification biométrique.
    @StateObject private var authManager = AuthenticationManager()
    
    // MARK: - Body
    
    var body: some Scene {
        #if os(macOS)
        // Configuration pour macOS avec support menu bar
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    configureAppearance()
                }
        }
        .commands {
            // Commandes personnalisées pour macOS
            CommandGroup(replacing: .newItem) {
                Button("Nouveau Secret") {
                    appState.showNewSecretSheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Button("Recherche Rapide") {
                    appState.showQuickSearch = true
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }
        
        #else
        // Configuration pour iOS
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .onAppear {
                    configureAppearance()
                }
        }
        #endif
    }
    
    // MARK: - Méthodes Privées
    
    /// Configure l'apparence globale de l'application.
    /// Définit les couleurs, polices et styles par défaut.
    private func configureAppearance() {
        // Configuration du thème par défaut
        #if os(iOS)
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        #endif
        
        // Log du démarrage de l'application
        print("[SilentKey] Application démarrée - Version 1.0.0")
    }
}

// MARK: - AppState

/// Gestionnaire d'état global de l'application.
/// Centralise les états partagés entre les différentes vues.
class AppState: ObservableObject {
    
    /// Indique si la feuille de création de nouveau secret est affichée.
    @Published var showNewSecretSheet: Bool = false
    
    /// Indique si la recherche rapide est affichée.
    @Published var showQuickSearch: Bool = false
    
    /// Indique si l'utilisateur est authentifié.
    @Published var isAuthenticated: Bool = false
    
    /// Thème de l'application (clair/sombre/auto).
    @Published var theme: Theme = .system
    
    /// Initialise l'état de l'application avec les valeurs par défaut.
    init() {
        // Chargement des préférences utilisateur depuis UserDefaults
        loadUserPreferences()
    }
    
    /// Charge les préférences utilisateur depuis le stockage local.
    private func loadUserPreferences() {
        // TODO: Implémenter le chargement depuis UserDefaults
    }
}

// MARK: - Theme

/// Énumération des thèmes disponibles dans l'application.
enum Theme: String, CaseIterable {
    /// Thème clair.
    case light = "Clair"
    
    /// Thème sombre.
    case dark = "Sombre"
    
    /// Thème automatique (suit les préférences système).
    case system = "Automatique"
}
