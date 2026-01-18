//
//  AuthenticationManager.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import LocalAuthentication
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "AuthManager")

/**
 AuthenticationManager (v0.9.0)
 Orchestrates the vault security lifecycle. Supports optional master password,
 strict security policies, and first-time onboarding flow.
 */
public class AuthenticationManager: ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var authError: String?
    
    public var vaultManager: VaultManager?
    private let keychain = KeychainManager.shared
    
    public init() {
        logger.info("AuthenticationManager initialized (v0.9.0).")
        checkInitialAuthState()
    }
    
    /**
     Determines if the user should be automatically logged in (first time or no password).
     */
    private func checkInitialAuthState() {
        if !keychain.isVaultProtected {
            logger.info("Vault is not protected. Enabling automatic access for onboarding.")
            self.isAuthenticated = true
            self.vaultManager = VaultManager.shared
        } else {
            logger.info("Vault is protected by a master password.")
            self.isAuthenticated = false
        }
    }
    
    /**
     Attempts to authenticate the user.
     */
    @MainActor
    public func authenticate(with password: String) async {
        self.authError = nil
        
        if password == "BIOMETRIC_BYPASS" {
            await performBiometricAuth()
            return
        }
        
        if let storedPassword = keychain.getMasterPassword() {
            if password == storedPassword {
                completeAuthentication()
            } else {
                self.authError = "Invalid Master Password"
            }
        } else {
            // No password set, allow entry
            completeAuthentication()
        }
    }
    
    private func completeAuthentication() {
        logger.info("Authentication successful.")
        self.vaultManager = VaultManager.shared
        self.isAuthenticated = true
    }
    
    /**
     Updates the master password with strict validation.
     Policies:
     - Min 10 chars.
     - Majuscule, Chiffre, Caractère spécial.
     - No more than 2 consecutive numbers.
     - No more than 3 identical characters.
     */
    public func setMasterPassword(_ password: String) -> Result<Bool, String> {
        let validation = validatePassword(password)
        if case .failure(let error) = validation {
            return .failure(error)
        }
        
        if keychain.saveMasterPassword(password) {
            logger.info("Master password successfully updated.")
            return .success(true)
        }
        return .failure("Keychain storage error")
    }
    
    /**
     Validates a password against the strict policy requested by the user.
     */
    public func validatePassword(_ p: String) -> Result<Void, String> {
        if p.count < 10 { return .failure("Minimum 10 characters required") }
        
        let hasUppercase = p.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasDigit = p.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = p.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:'\",.<>/?")) != nil
        
        if !hasUppercase || !hasDigit || !hasSpecial {
            return .failure("Must include Uppercase, Number, and Special character")
        }
        
        // Consecutive numbers check (no more than 2)
        let chars = Array(p)
        for i in 0..<(chars.count - 2) {
            if chars[i].isNumber && chars[i+1].isNumber && chars[i+2].isNumber {
                return .failure("No more than 2 consecutive numbers allowed")
            }
        }
        
        // Identical characters check (no more than 3)
        for i in 0..<(chars.count - 3) {
            if chars[i] == chars[i+1] && chars[i+1] == chars[i+2] && chars[i+2] == chars[i+3] {
                return .failure("No more than 3 identical characters allowed")
            }
        }
        
        return .success(())
    }
    
    /**
     Generates a unique secure password following the same strict policy.
     */
    public func generateSecurePassword() -> String {
        let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lower = "abcdefghijklmnopqrstuvwxyz"
        let digits = "0123456789"
        let special = "!@#$%^&*()-_=+"
        
        // Start with required characters to guarantee the policy
        var password = ""
        password.append(upper.randomElement()!)
        password.append(digits.randomElement()!)
        password.append(special.randomElement()!)
        
        let all = upper + lower + digits + special
        while password.count < 12 {
            let next = all.randomElement()!
            // Fast check for consecutive numbers or identical chars during generation
            let current = Array(password)
            if current.count >= 2 && next.isNumber && current[current.count-1].isNumber && current[current.count-2].isNumber {
                continue 
            }
            if current.count >= 3 && next == current[current.count-1] && next == current[current.count-2] && next == current[current.count-3] {
                continue
            }
            password.append(next)
        }
        
        return String(password.shuffled())
    }
    
    private func performBiometricAuth() async {
        let context = LAContext()
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your SILENT KEY Vault")
            if success { await MainActor.run { completeAuthentication() } }
        } catch {
            logger.error("Biometric error: \(error.localizedDescription)")
        }
    }
    
    public func logout() {
        self.isAuthenticated = false
        self.vaultManager = nil
    }
}
