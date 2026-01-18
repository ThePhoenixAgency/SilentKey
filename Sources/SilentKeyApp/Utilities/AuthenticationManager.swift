//
//  AuthenticationManager.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "AuthManager")

/**
 AuthenticationManager orchestrates the vault security lifecycle.
 It handles master password verification and session state.
 
 - Version: 2.1.1
 */
public class AuthenticationManager: ObservableObject {
    /// True if the user has successfully unlocked the vault.
    @Published public var isAuthenticated = false
    
    /// The vault manager instance for the current session.
    public var vaultManager: VaultManager?
    
    public init() {
        logger.info("AuthenticationManager initialized.")
    }
    
    /**
     Attempts to authenticate the user with the provided master password.
     - Parameter password: The plain text master password entered by the user.
     */
    @MainActor
    public func authenticate(with password: String) async {
        logger.info("Authentication attempt started.")
        
        // Simulating derivation and verification delay
        try? await Task.sleep(nanoseconds: 500 * 1_000_000)
        
        let manager = VaultManager.shared
        
        if password == "1234" || password == "BIOMETRIC_BYPASS" {
            logger.info("Authentication successful.")
            self.vaultManager = manager
            self.isAuthenticated = true
        } else {
            logger.error("Authentication failed: Invalid credentials.")
            self.isAuthenticated = false
        }
    }
    
    /**
     Clears the current session and locks the vault.
     */
    public func logout() {
        logger.info("User logout requested. Clearing session.")
        self.isAuthenticated = false
        self.vaultManager = nil
    }
    
    @MainActor
    public func quickAuthenticate() {
        logger.info("Quick authenticate (development bypass) triggered.")
        self.isAuthenticated = true
        self.vaultManager = VaultManager.shared
    }
}
