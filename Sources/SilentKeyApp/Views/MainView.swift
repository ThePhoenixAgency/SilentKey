//
//  MainView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "MainView")

/**
 TabItem (v2.4.0)
 Navigation categories for the sidebar.
 */
enum TabItem: String, CaseIterable, Identifiable {
    case vault, projects, trash, settings
    var id: String { rawValue }
}

/**
 MainView (v2.4.0)
 The core navigation hub of SILENT KEY.
 Features:
 - Responsive Sidebar for macOS.
 - Permanent Footer with versioning and copyright.
 - Dynamic Language Switching.
 */
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var localization = LocalizationManager.shared
    @State private var selectedTab: TabItem = .vault
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        } detail: {
            VStack(spacing: 0) {
                ZStack {
                    backgroundGradient
                    
                    Group {
                        switch selectedTab {
                        case .vault: VaultView()
                        case .projects: ProjectsView()
                        case .trash: TrashView()
                        case .settings: SettingsView()
                        }
                    }
                    .transition(.opacity)
                }
                
                // RESPONSIVE FOOTER: Locked at the bottom of the detail view.
                PermanentFooterView()
                    .background(Color.black.opacity(0.1))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            logger.info("MainView active. Current Language: \(localization.currentLanguage.rawValue)")
        }
    }
    
    // MARK: - Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.15, blue: 0.3),
                Color(red: 0.08, green: 0.1, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }
    
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            List(selection: $selectedTab) {
                Section {
                    Label(localization.localized(.vault), systemImage: "shield.fill")
                        .tag(TabItem.vault)
                } header: {
                    Text(localization.localized(.appName).uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.blue)
                }
                
                Section {
                    Label(localization.localized(.projects), systemImage: "folder.fill")
                        .tag(TabItem.projects)
                    
                    Label(localization.localized(.trash), systemImage: "trash.fill")
                        .tag(TabItem.trash)
                } header: {
                    Text("ORGANIZATION").font(.system(size: 10, weight: .black))
                }
            }
            .listStyle(.sidebar)
            
            Divider().opacity(0.1)
            
            // BOTTOM BAR: Settings & Logout (User requirement)
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { selectedTab = .settings }) {
                    Label(localization.localized(.settings), systemImage: "gearshape.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(selectedTab == .settings ? .blue : .white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                
                Button(action: { authManager.logout() }) {
                    Label(localization.localized(.logout), systemImage: "lock.open.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 15)
            .background(Color.white.opacity(0.02))
        }
    }
}

// MARK: - Subviews

struct ProjectsView: View {
    @StateObject private var localization = LocalizationManager.shared
    var body: some View {
        VStack {
            Text(localization.localized(.projects).uppercased())
                .font(.system(size: 32, weight: .black, design: .rounded)).tracking(4)
            Spacer()
            Image(systemName: "folder.badge.plus").font(.system(size: 80)).foregroundStyle(.white.opacity(0.1))
            Text("NO PROJECTS DETECTED").font(.system(size: 14, weight: .black)).opacity(0.3)
            Spacer()
        }
        .padding(30)
    }
}

struct TrashView: View {
    var body: some View {
        VStack {
            Text("TRASH").font(.system(size: 32, weight: .black, design: .rounded)).tracking(4)
            Spacer()
            Image(systemName: "trash.slash.fill").font(.system(size: 80)).foregroundStyle(.white.opacity(0.1))
            Text("TRASH IS EMPTY").font(.system(size: 14, weight: .black)).opacity(0.3)
            Spacer()
        }
        .padding(30)
    }
}

struct SettingsView: View {
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(localization.localized(.settings).uppercased())
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(4)
                Spacer()
            }
            .padding(30)
            
            List {
                Section("LOCALIZATION") {
                    Picker("Application Language", selection: $localization.currentLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("SECURITY") {
                    Toggle("Auto-lock on idle", isOn: .constant(true))
                    Toggle("Biometric unlock (Touch ID)", isOn: .constant(true))
                }
                
                Section("ABOUT") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("0.7.2 (STAGING)")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - App Helpers

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
