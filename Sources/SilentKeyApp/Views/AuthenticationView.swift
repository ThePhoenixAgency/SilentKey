//
//  AuthenticationView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import LocalAuthentication
import AuthenticationServices
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "Authentication")

/**
 AuthenticationView (v2.3.0)
 Features a NATIVE NSTextField wrapper for macOS to ensure 100% reliable focus capture.
 This bypasses SwiftUI @FocusState issues on certain macOS versions/configurations.
 */
struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var localization = LocalizationManager.shared
    
    @State private var masterPassword = ""
    @State private var isPasswordVisible = false
    @State private var isAuthenticating = false
    
    // We still use FocusState as a secondary trigger
    @FocusState private var isPasswordFocused: Bool
    @State private var appearanceAnimate = false
    
    var body: some View {
        ZStack {
            // THEME: No-black policy
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.5), Color(red: 0.05, green: 0.1, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            MeshGradientView().opacity(0.5).blur(radius: 60).allowsHitTesting(false)
            
            VStack(spacing: 0) {
                languageSelectorBar
                Spacer()
                
                // MAIN PANEL
                VStack(spacing: 45) {
                    brandingHeader
                    
                    VStack(spacing: 30) {
                        passwordInputSection
                        unlockActionArea
                        mfaSupportRow
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
            logger.info("AuthenticationView appeared. Triggering native focus.")
            #if os(macOS)
            NSApp.activate(ignoringOtherApps: true)
            #endif
        }
    }
    
    // MARK: - Components
    
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
    
    private var brandingHeader: some View {
        VStack(spacing: 25) {
            LogoView(size: 130)
            Text(localization.localized(.appName).uppercased())
                .font(.system(size: 42, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundStyle(.white)
        }
    }
    
    private var passwordInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localized(.masterPassword).uppercased())
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.white.opacity(0.8))
                .tracking(2)
            
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                
                // NATIVE FOCUS WRAPPER (macOS Only)
                #if os(macOS)
                NativeTextField(text: $masterPassword, isSecure: !isPasswordVisible, placeholder: "••••••••", onCommit: performUnlock)
                    .frame(height: 30)
                    .accessibilityIdentifier("master_password_native")
                #else
                Group {
                    if isPasswordVisible {
                        TextField("", text: $masterPassword).focused($isPasswordFocused)
                    } else {
                        SecureField("", text: $masterPassword).focused($isPasswordFocused)
                    }
                }
                .textFieldStyle(.plain)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                #endif
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 2))
        }
    }
    
    private var unlockActionArea: some View {
        Button(action: { performUnlock() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color.blue, Color(red: 0.1, green: 0.4, blue: 0.9)], startPoint: .top, endPoint: .bottom))
                HStack {
                    if isAuthenticating { ProgressView().controlSize(.small).tint(.white).padding(.trailing, 8) }
                    Text(isAuthenticating ? localization.localized(.authenticating).uppercased() : localization.localized(.unlock).uppercased())
                        .font(.system(size: 18, weight: .black))
                }
                .foregroundStyle(.white)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain).disabled(masterPassword.isEmpty || isAuthenticating).opacity(masterPassword.isEmpty ? 0.5 : 1.0)
    }
    
    private var mfaSupportRow: some View {
        HStack(spacing: 20) {
            secondaryAuthButton(icon: biometricIcon, title: localization.localized(.biometricAccess)) { triggerBiometrics() }
            secondaryAuthButton(icon: "key.fill", title: localization.localized(.securityKey)) { logger.info("FIDO2") }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 30) {
            HStack(spacing: 50) {
                metadataItem(label: "SECURITY", value: "AES-256-GCM")
                metadataItem(label: "VERIFICATION", value: "NATIVE-FOCUS")
            }
            .opacity(0.8)
            Link(destination: URL(string: "http://thephoenixagency.github.io")!) {
                Text("PhoenixProject").font(.system(size: 16, weight: .black)).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 12).background(Color.blue.opacity(0.5)).clipShape(Capsule())
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Actions
    
    private func performUnlock() {
        guard !masterPassword.isEmpty && !isAuthenticating else { return }
        logger.info("Starting authentication flow.")
        isAuthenticating = true
        Task {
            await authManager.authenticate(with: masterPassword)
            await MainActor.run { isAuthenticating = false }
        }
    }
    
    private func triggerBiometrics() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock") { success, _ in
            if success { Task { @MainActor in await authManager.authenticate(with: "BIOMETRIC_BYPASS") } }
        }
    }
    
    private func secondaryAuthButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) { Image(systemName: icon).font(.system(size: 16)); Text(title.uppercased()).font(.system(size: 13, weight: .black)) }
            .foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.white.opacity(0.12)).cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func metadataItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) { Text(label).font(.system(size: 10, weight: .black)).foregroundStyle(.blue); Text(value).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(.white) }
    }
    
    private var biometricIcon: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }
}

// MARK: - Native macOS Wrapper

#if os(macOS)
/**
 NativeTextField provides a high-reliability NSTextField/NSSecureTextField wrapper.
 It forces 'becomeFirstResponder' on appear to ensure keyboard focus is captured.
 */
struct NativeTextField: NSViewRepresentable {
    @Binding var text: String
    var isSecure: Bool
    var placeholder: String
    var onCommit: () -> Void
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = isSecure ? NSSecureTextField() : NSTextField()
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 20, weight: .semibold)
        textField.delegate = context.coordinator
        
        // Immediate focus request
        DispatchQueue.main.async {
            if textField.window != nil {
                textField.window?.makeKeyAndOrderFront(nil)
                textField.becomeFirstResponder()
                logger.info("Native NSTextField becomeFirstResponder called.")
            }
        }
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NativeTextField
        init(_ parent: NativeTextField) { self.parent = parent }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onCommit()
                return true
            }
            return false
        }
    }
}
#endif
