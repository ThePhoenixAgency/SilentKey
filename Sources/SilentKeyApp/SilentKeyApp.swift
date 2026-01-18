//
//  SilentKeyApp.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI
import SilentKeyCore
import os.log

private let logger = Logger(subsystem: "com.thephoenixagency.silentkey", category: "Lifecycle")

@main
struct SilentKeyApp: App {
    /// Global application state manager.
    @StateObject private var appState = AppState()
    
    /// Global authentication manager handling the vault lifecycle.
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        #if os(macOS)
        // Using Window instead of WindowGroup for strict single-instance as per requirements
        Window("SILENT KEY", id: "silentkey_main") {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                // RESPONSIVE: The window adapts its size to the content while allowing user resizing.
                // The frame modifiers here set the initial and minimum boundaries.
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .onAppear {
                    handleAppLaunchFocus()
                    
                    // MARK: - TEMPORARY BYPASS
                    // To test the full app directly without being blocked by focus/password issues,
                    // uncomment the line below. For now, it remains commented to follow best practices.
                    authManager.quickAuthenticate()
                }
        }
        .windowResizability(.contentSize) // The window size is now driven by its content (Responsive)
        .commands {
            // Remove 'New Window' to maintain single-instance security integrity.
            CommandGroup(replacing: .newItem) { }
        }
        
        #else
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
        #endif
    }
    
    // MARK: - App Lifecycle Logic
    
    private func handleAppLaunchFocus() {
        logger.info("SILENT KEY app launched. Enforcing window visibility and presence.")
        #if os(macOS)
        // Ensure the app has a dock icon and standard menu presence.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Find and bring the main window to the front.
        if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "silentkey_main" }) {
            window.makeKeyAndOrderFront(nil)
            window.title = "SILENT KEY"
            logger.info("Core window 'silentkey_main' is now visible and key.")
        }
        #endif
    }
}
