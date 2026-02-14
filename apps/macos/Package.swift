// swift-tools-version: 6.2
// Package manifest for the AdaMarie macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "AdaMarie",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "AdaMarieIPC", targets: ["AdaMarieIPC"]),
        .library(name: "AdaMarieDiscovery", targets: ["AdaMarieDiscovery"]),
        .executable(name: "AdaMarie", targets: ["AdaMarie"]),
        .executable(name: "adamarie-mac", targets: ["AdaMarieCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/AdaMarieKit"),
        // TODO: Swabble was OpenClaw's custom auto-updater — replace with our own or Sparkle direct
        // .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "AdaMarieIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AdaMarieDiscovery",
            dependencies: [
                .product(name: "AdaMarieKit", package: "AdaMarieKit"),
            ],
            path: "Sources/AdaMarieDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "AdaMarie",
            dependencies: [
                "AdaMarieIPC",
                "AdaMarieDiscovery",
                .product(name: "AdaMarieKit", package: "AdaMarieKit"),
                .product(name: "AdaMarieChatUI", package: "AdaMarieKit"),
                .product(name: "AdaMarieProtocol", package: "AdaMarieKit"),
                // TODO: SwabbleKit (auto-updater) removed — wire Sparkle directly
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/AdaMarie.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "AdaMarieCLI",
            dependencies: [
                "AdaMarieDiscovery",
                .product(name: "AdaMarieKit", package: "AdaMarieKit"),
                .product(name: "AdaMarieProtocol", package: "AdaMarieKit"),
            ],
            path: "Sources/AdaMarieCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "AdaMarieIPCTests",
            dependencies: [
                "AdaMarieIPC",
                "AdaMarie",
                "AdaMarieDiscovery",
                .product(name: "AdaMarieProtocol", package: "AdaMarieKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
