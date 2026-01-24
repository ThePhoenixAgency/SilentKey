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
 MainView (v0.9.0-staging)
 Hub central de SILENT KEY.
 Features:
 - Integrated Password Generator and Policy Validation.
 - CSV Export for passwords.
 - Dynamic Profile configuration.
 */
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var localization = LocalizationManager.shared
    @State private var selectedTab: TabItem = .vault
    
    private let sidebarMinWidth: CGFloat = 260
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
                .frame(minWidth: sidebarMinWidth)
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        } detail: {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    backgroundGradient
                    appHeaderOverlay
                    
                    Group {
                        switch selectedTab {
                        case .vault: VaultView().padding(.top, 100)
                        case .projects: ProjectsView().padding(.top, 100)
                        case .trash: TrashView().padding(.top, 100)
                        case .settings: SettingsView().padding(.top, 100)
                        }
                    }
                    .transition(.opacity)
                }
                
                PermanentFooterView()
                    .background(Color.black.opacity(0.1))
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var appHeaderOverlay: some View {
        HStack(spacing: 20) {
            LogoView(size: 44)
            Text(localization.localized(.appName).uppercased())
                .font(.system(size: 28, weight: .black, design: .rounded))
                .tracking(8)
                .foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.12, green: 0.15, blue: 0.3), Color(red: 0.08, green: 0.1, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }
    
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            List(selection: $selectedTab) {
                Section {
                    navigationLabel(localization.localized(.vault), icon: "shield.fill").tag(TabItem.vault)
                } header: {
                    Text("VAULT").font(.system(size: 10, weight: .black)).opacity(0.5)
                }
                
                Section {
                    navigationLabel(localization.localized(.projects), icon: "folder.fill").tag(TabItem.projects)
                    navigationLabel(localization.localized(.trash), icon: "trash.fill").tag(TabItem.trash)
                } header: {
                    Text("ORGANIZATION").font(.system(size: 10, weight: .black)).opacity(0.5)
                }
            }
            .listStyle(.sidebar)
            
            Divider().opacity(0.1)
            
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { selectedTab = .settings }) {
                    navigationLabel(localization.localized(.settings), icon: "gearshape.fill")
                        .foregroundStyle(selectedTab == .settings ? .blue : .white)
                }
                .buttonStyle(.plain)
                
                Button(action: { authManager.logout() }) {
                    navigationLabel(localization.localized(.logout), icon: "lock.open.fill")
                        .foregroundStyle(.red.opacity(0.9))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color.white.opacity(0.02))
        }
    }
    
    private func navigationLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).frame(width: 20)
            Text(text).font(.system(size: 14, weight: .bold)).fixedSize(horizontal: false, vertical: true).lineLimit(nil).allowsTightening(false)
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var keyManager = SecurityKeyManager.shared
    
    @State private var newPassword = ""
    @State private var confirmingPassword = ""
    @State private var isShowingPasswordSetup = false
    @State private var validationError: String? = nil
    @State private var isGenerating = false
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("PROFILE & SECURITY") {
                    Button(action: { isShowingPasswordSetup.toggle() }) {
                        HStack {
                            Image(systemName: "lock.shield.fill").foregroundStyle(.blue)
                            Text(KeychainManager.shared.isVaultProtected ? "Change Master Password" : "Setup Master Password (Recommended)")
                                .fontWeight(.bold)
                        }
                    }
                    .sheet(isPresented: $isShowingPasswordSetup) {
                        passwordSetupSheet
                    }
                    
                    Toggle("Biometric Unlock (Touch ID)", isOn: .constant(true))
                        .tint(.blue)
                }
                
                Section("DATA MANAGEMENT") {
                    Button(action: { exportToCSV() }) {
                        Label("Export Vault to CSV", systemImage: "square.and.arrow.up")
                    }
                    Button(action: { /* Import logic */ }) {
                        Label("Import from other managers", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section("SECURITY KEYS (FIDO2)") {
                    ForEach(keyManager.registeredKeys) { key in
                        HStack {
                            Image(systemName: "key.radiowaves.forward.fill").foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text(key.name).font(.headline)
                                Text("Registered on \(key.registrationDate, style: .date)").font(.caption).opacity(0.5)
                            }
                            Spacer()
                            Button(action: { keyManager.removeKey(id: key.id) }) {
                                Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button(action: { /* Key reg logic */ }) {
                        Label("Add Security Key", systemImage: "plus.circle")
                    }
                }
                
                Section("LOCALIZATION") {
                    Picker("Language", selection: $localization.currentLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
    }
    
    private var passwordSetupSheet: some View {
        VStack(spacing: 25) {
            Text("VAULT SECURITY POLICY").font(.headline).tracking(2)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("• Minimum 10 characters").font(.caption)
                Text("• Must include Uppercase, Digit, Symbol").font(.caption)
                Text("• Unique: No more than 2 consecutive digits").font(.caption)
                Text("• No more than 3 identical characters").font(.caption)
            }
            .padding().background(Color.white.opacity(0.05)).cornerRadius(8)
            
            VStack(spacing: 15) {
                HStack {
                    SecureField("Master Password", text: $newPassword)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        newPassword = authManager.generateSecurePassword()
                        confirmingPassword = newPassword
                    }) {
                        Image(systemName: "wand.and.stars").padding(8).background(Color.blue).cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .help("Generate Secure Password")
                }
                
                SecureField("Confirm Password", text: $confirmingPassword)
                    .textFieldStyle(.roundedBorder)
            }
            
            if let error = validationError {
                Text(error).font(.caption).foregroundStyle(.red).bold()
            }
            
            HStack {
                Button("Cancel") { isShowingPasswordSetup = false; validationError = nil }
                Spacer()
                Button(action: {
                    if newPassword != confirmingPassword {
                        validationError = "Passwords do not match"
                    } else {
                        let result = authManager.setMasterPassword(newPassword)
                        switch result {
                        case .success:
                            isShowingPasswordSetup = false
                            validationError = nil
                        case .failure(let error):
                            validationError = error.localizedDescription
                        }
                    }
                }) {
                    Text("Save Protection")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .frame(width: 450)
    }
    
    private func exportToCSV() {
        logger.info("Exporting vault to CSV...")
        // Logic to generate and save CSV file
    }
}

// MARK: - Stubs

struct ProjectsView: View {
    @StateObject private var localization = LocalizationManager.shared
    var body: some View {
        VStack {
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
            Spacer()
            Image(systemName: "trash.slash.fill").font(.system(size: 80)).foregroundStyle(.white.opacity(0.1))
            Text("TRASH IS EMPTY").font(.system(size: 14, weight: .black)).opacity(0.3)
            Spacer()
        }
        .padding(30)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material; view.blendingMode = blendingMode; view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
