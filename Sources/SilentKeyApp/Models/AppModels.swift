//
//  AppModels.swift
//  SilentKey
//

import SwiftUI

/// Global Application State
class AppState: ObservableObject {
    @Published var showNewSecretSheet: Bool = false
    @Published var showQuickSearch: Bool = false
    @Published var theme: Theme = .dark
    
    init() {}
}

enum Theme: String, CaseIterable {
    case light, dark, system
}

/// Navigation Items
enum TabItem: String, Identifiable, CaseIterable {
    case vault, projects, trash, settings
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .vault: return "lock.shield.fill"
        case .projects: return "folder.fill"
        case .trash: return "trash.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var localizationKey: LocalizedKey {
        switch self {
        case .vault: return .vault
        case .projects: return .projects
        case .trash: return .trash
        case .settings: return .settings
        }
    }
}
