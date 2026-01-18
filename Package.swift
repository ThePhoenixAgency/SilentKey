// swift-tools-version: 5.9
// Compatible iOS 16+ and macOS 13+
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
                // Native crypto via CryptoKit
    ],
    targets: [
        // MARK: - App Target
        .executableTarget(
            name: "SilentKeyApp",
            dependencies: ["SilentKeyCore"],
            path: "Sources/SilentKeyApp",
            resources: [
                .process("Resources")
            ]
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
