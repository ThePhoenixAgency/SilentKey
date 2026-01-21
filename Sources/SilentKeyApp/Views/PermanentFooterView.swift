//
//  PermanentFooterView.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI

/**
 PermanentFooterView (v0.7.3)
 Consistent footer for all application pages:
 - Center: Copyright + PhoenixProject Link
 - Bottom Right: Semantic Version (Staging 0.x.x)
 Improved visibility for staging tags (WCAG compliant).
 */
struct PermanentFooterView: View {
    let version = "0.7.3" // Staging Semantic Version
    let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Center: Branding & Link
            HStack(spacing: 8) {
                Text("© \(String(currentYear)) SILENT KEY •")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6)) // Increased from 0.4
                
                Link(destination: URL(string: "http://thephoenixagency.github.io")!) {
                    Text("PhoenixProject")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.blue.opacity(0.8)) // Increased from 0.6
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
            // Bottom Right: Versioning
            HStack {
                Spacer()
                Text("v\(version)-STAGING")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7)) // Increased from 0.3 (Much clearer)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12)) // Made background slightly more visible too
                    )
            }
            .padding(.bottom, 12)
            .padding(.trailing, 16)
        }
        .frame(height: 60)
    }
}
