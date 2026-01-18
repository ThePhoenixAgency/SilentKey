//
//  AuthenticationView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import LocalAuthentication
import SilentKeyCore
import os.log

private let logger = os.Logger(subsystem: "com.thephoenixagency.silentkey", category: "Authentication")

/**
 AuthenticationView (v0.9.0)
 Locking page for Silent Key. 
 Features:
 - "Organic Dots" visual feedback for locked status.
 - Dynamic authentication method selection.
 - Professional glassmorphism UI.
 */
struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var keyManager = SecurityKeyManager.shared
    
    @State private var masterPassword = ""
    @State private var isPasswordVisible = false
    @State private var isAuthenticating = false
    @State private var appearanceAnimate = false
    @State private var showAuthChoice = true // Start with choices if configured
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.5), Color(red: 0.05, green: 0.1, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            MeshGradientView().opacity(0.5).blur(radius: 60).allowsHitTesting(false)
            
            VStack(spacing: 0) {
                languageSelectorBar
                Spacer()
                
                VStack(spacing: 45) {
                    brandingHeader
                    
                    if showAuthChoice && !keyManager.registeredKeys.isEmpty {
                        securityMethodPicker
                    } else {
                        VStack(spacing: 30) {
                            passwordInputSection
                            unlockActionArea
                            mfaSupportRow
                        }
                    }
                }
                .padding(60)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 0.1, green: 0.15, blue: 0.35))
                        .shadow(color: .black.opacity(0.6), radius: 50, y: 30)
                )
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.15), lineWidth: 1.5))
                .frame(width: 560)
                .scaleEffect(appearanceAnimate ? 1.0 : 0.98)
                .opacity(appearanceAnimate ? 1.0 : 0)
                
                Spacer()
                footerSection
            }
        }
        .onAppear { 
            appearanceAnimate = true
            // Only show auth choice if we have something other than password
            if keyManager.registeredKeys.isEmpty {
                showAuthChoice = false
            }
        }
    }
    
    // MARK: - Components
    
    private var securityMethodPicker: some View {
        VStack(spacing: 20) {
            Text("CHOOSE YOUR KEY").font(.system(size: 14, weight: .black)).opacity(0.6).tracking(2)
            
            Button(action: { triggerBiometrics() }) {
                authMethodRow(icon: biometricIcon, title: localization.localized(.biometricAccess), subtitle: "INSTANT FACE/TOUCH UNLOCK")
            }
            .buttonStyle(.plain)
            
            Button(action: { triggerFIDO() }) {
                authMethodRow(icon: "key.radiowaves.forward.fill", title: "SECURITY KEY", subtitle: "\(keyManager.registeredKeys.count) DEVICES LINKED")
            }
            .buttonStyle(.plain)
            
            Button(action: { showAuthChoice = false }) {
                Text("ENTER MASTER PASSWORD").font(.caption).bold().opacity(0.5).padding(.top, 10)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func authMethodRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon).font(.system(size: 30)).foregroundStyle(.blue)
            VStack(alignment: .leading) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right").opacity(0.3)
        }
        .padding(20).background(Color.white.opacity(0.05)).cornerRadius(16)
    }
    
    private var brandingHeader: some View {
        VStack(spacing: 25) {
            LogoView(size: 130)
            Text(localization.localized(.appName).uppercased())
                .font(.system(size: 42, weight: .black, design: .rounded))
                .tracking(8).foregroundStyle(.white)
        }
    }
    
    private var passwordInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localized(.masterPassword).uppercased())
                .font(.system(size: 14, weight: .black)).foregroundStyle(.white.opacity(0.8)).tracking(2)
            
            HStack {
                Image(systemName: "lock.shield.fill").font(.system(size: 20)).foregroundStyle(.blue)
                
                #if os(macOS)
                // "Organic display of dots": We use a placeholder of dots to represent the secure state
                NativeTextField(text: $masterPassword, isSecure: !isPasswordVisible, placeholder: "••••••••••••••••••••", onCommit: performUnlock)
                    .frame(height: 30)
                #else
                SecureField("••••••••••••••••••••", text: $masterPassword)
                    .textFieldStyle(.plain).font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                #endif
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye").font(.system(size: 18)).foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24).padding(.vertical, 16).background(Color.black.opacity(0.7)).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 2))
        }
    }
    
    private var unlockActionArea: some View {
        Button(action: { performUnlock() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color.blue, Color(red: 0.1, green: 0.4, blue: 0.9)], startPoint: .top, endPoint: .bottom))
                if isAuthenticating {
                    ProgressView().controlSize(.small).tint(.white)
                } else {
                    Text(localization.localized(.unlock).uppercased()).font(.system(size: 18, weight: .black)).foregroundStyle(.white)
                }
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain).disabled(masterPassword.isEmpty || isAuthenticating).opacity(masterPassword.isEmpty ? 0.3 : 1.0)
    }
    
    private var mfaSupportRow: some View {
        HStack(spacing: 20) {
            secondaryAuthButton(icon: biometricIcon, title: localization.localized(.biometricAccess)) { triggerBiometrics() }
            if !keyManager.registeredKeys.isEmpty {
                secondaryAuthButton(icon: "key.fill", title: localization.localized(.securityKey)) { showAuthChoice = true }
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 30) {
            Link(destination: URL(string: "http://thephoenixagency.github.io")!) {
                Text("PhoenixProject").font(.system(size: 16, weight: .black)).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 12).background(Color.blue.opacity(0.5)).clipShape(Capsule())
            }
            .padding(.bottom, 50)
        }
    }
    
    private var languageSelectorBar: some View {
        HStack {
            Spacer()
            HStack(spacing: 15) {
                ForEach(AppLanguage.allCases) { lang in
                    Button(action: { localization.currentLanguage = lang }) {
                        Text(lang.flag).font(.system(size: 22)).padding(8)
                            .background(localization.currentLanguage == lang ? Color.white.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 40).padding(.horizontal, 40)
    }
    
    // MARK: - Actions
    
    private func performUnlock() {
        guard !masterPassword.isEmpty && !isAuthenticating else { return }
        isAuthenticating = true
        Task {
            await authManager.authenticate(with: masterPassword)
            await MainActor.run { 
                isAuthenticating = false 
                if authManager.authError != nil {
                    masterPassword = ""
                }
            }
        }
    }
    
    private func triggerBiometrics() {
        Task { await authManager.authenticate(with: "BIOMETRIC_BYPASS") }
    }
    
    private func triggerFIDO() {
        // Here we would trigger the ASAuthorizationPlatformPublicKeyCredentialProvider
        Task { await authManager.authenticate(with: "BIOMETRIC_BYPASS") }
    }
    
    private func secondaryAuthButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) { Image(systemName: icon).font(.system(size: 16)); Text(title.uppercased()).font(.system(size: 13, weight: .black)) }
            .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.white.opacity(0.12)).cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private var biometricIcon: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        #if os(macOS)
        return "touchid"
        #else
        return context.biometryType == .faceID ? "faceid" : "touchid"
        #endif
    }
}

#if os(macOS)
struct NativeTextField: NSViewRepresentable {
    @Binding var text: String
    var isSecure: Bool
    var placeholder: String
    var onCommit: () -> Void
    func makeNSView(context: Context) -> NSTextField {
        let textField = isSecure ? NSSecureTextField() : NSTextField()
        textField.placeholderString = placeholder
        textField.isBordered = false; textField.drawsBackground = false; textField.focusRingType = .none
        textField.textColor = .white; textField.font = .systemFont(ofSize: 20, weight: .semibold)
        textField.delegate = context.coordinator
        DispatchQueue.main.async { textField.becomeFirstResponder() }
        return textField
    }
    func updateNSView(_ nsView: NSTextField, context: Context) { if nsView.stringValue != text { nsView.stringValue = text } }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NativeTextField
        init(_ parent: NativeTextField) { self.parent = parent }
        func controlTextDidChange(_ obj: Notification) { if let textField = obj.object as? NSTextField { parent.text = textField.stringValue } }
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) { parent.onCommit(); return true }
            return false
        }
    }
}
#endif
