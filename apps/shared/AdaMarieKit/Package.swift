// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AdaMarieKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "AdaMarieProtocol", targets: ["AdaMarieProtocol"]),
        .library(name: "AdaMarieKit", targets: ["AdaMarieKit"]),
        .library(name: "AdaMarieChatUI", targets: ["AdaMarieChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "AdaMarieProtocol",
            path: "Sources/AdaMarieProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AdaMarieKit",
            dependencies: [
                "AdaMarieProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/AdaMarieKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "AdaMarieChatUI",
            dependencies: [
                "AdaMarieKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/AdaMarieChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "AdaMarieKitTests",
            dependencies: ["AdaMarieKit", "AdaMarieChatUI"],
            path: "Tests/AdaMarieKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
