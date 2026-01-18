//
//  PermanentFooterView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI

/**
 PermanentFooterView (v0.1.0)
 Consistent footer for all application pages:
 - Center: Copyright + PhoenixProject Link
 - Bottom Right: Semantic Version (Staging 0.x.x)
 */
struct PermanentFooterView: View {
    let version = "0.7.2" // Staging Semantic Version
    let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Center: Branding & Link
            HStack(spacing: 8) {
                Text("© \(String(currentYear)) SILENT KEY •")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                
                Link(destination: URL(string: "http://thephoenixagency.github.io")!) {
                    Text("PhoenixProject")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.blue.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
            // Bottom Right: Versioning
            HStack {
                Spacer()
                Text("v\(version)-staging")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(15)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                    )
            }
            .padding(.bottom, 10)
            .padding(.trailing, 10)
        }
        .frame(height: 60)
    }
}
