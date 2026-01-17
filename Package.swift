// swift-tools-version: 5.9
// Package manifest pour SilentKey
// Compatible iOS 16+ et macOS 13+

import PackageDescription

let package = Package(
    name: "SilentKey",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SilentKeyCore",
            targets: ["SilentKeyCore"]
        ),
        .executable(
            name: "SilentKey",
            targets: ["SilentKeyApp"]
        )
    ],
    dependencies: [
        // Pas de dépendances externes pour maximiser la sécurité
        // Crypto natif via CryptoKit
    ],
    targets: [
        // MARK: - App Target
        .executableTarget(
            name: "SilentKeyApp",
            dependencies: ["SilentKeyCore"],
            path: "Sources/SilentKeyApp"
        ),
        
        // MARK: - Core Library
        .target(
            name: "SilentKeyCore",
            dependencies: [],
            path: "Sources/Core"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "SilentKeyTests",
            dependencies: ["SilentKeyCore"],
            path: "Tests/SilentKeyTests"        ),
    ]
)
