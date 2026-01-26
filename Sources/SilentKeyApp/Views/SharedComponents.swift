//
//  SharedComponents.swift
//  SilentKey
//
//  Created by Assistant AI on 18/01/2026.
//

import SwiftUI

/**
 LogoView (v2.4.0)
 Renders the raster logo inside a solid white pastille.
 */
struct LogoView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 15, y: 10)
            
            if let image = getLogoImage() {
                #if os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.12)
                    .clipShape(Circle())
                #else
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.12)
                    .clipShape(Circle())
                #endif
            }
        }
        .frame(width: size, height: size)
    }
    
    #if os(macOS)
    private func getLogoImage() -> NSImage? {
        let devPath = "/Users/ethanbernier/Library/CloudStorage/OneDrive-Phoenix/GitHub/SilentKey/docs/assets/logo.png"
        return NSImage(contentsOfFile: devPath)
    }
    #else
    private func getLogoImage() -> UIImage? {
        return UIImage(named: "Logo")
    }
    #endif
}

/**
 MeshGradientView (v2.4.0)
 Provides atmospheric background highlights.
 */
struct MeshGradientView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            #if os(macOS)
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 800, height: 800)
                .offset(x: animate ? 200 : -200, y: animate ? -200 : 200)
            Circle()
                .fill(Color.teal.opacity(0.4))
                .frame(width: 700, height: 700)
                .offset(x: animate ? -250 : 250, y: animate ? 150 : -150)
            #else
            Circle()
                .fill(Color.blue.opacity(0.4))
                .frame(width: 400, height: 400)
                .offset(x: animate ? 100 : -100, y: animate ? -100 : 100)
            #endif
        }
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
    }
}
