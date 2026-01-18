//
//  Color+Extensions.swift
//  SilentKey
//

import SwiftUI

extension Color {
    static var adaptiveBackground: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }
    
    static var adaptiveControlBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
    
    static var adaptiveTextBackground: Color {
        #if os(macOS)
        return Color(nsColor: .textBackgroundColor)
        #else
        return Color(uiColor: .tertiarySystemBackground)
        #endif
    }
}
