// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodexCore",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(
            name: "CodexCore",
            targets: ["CodexCore"]
        ),
    ],
    targets: [
        .target(
            name: "CodexCore",
            dependencies: []
        ),
        .testTarget(
            name: "CodexCoreTests",
            dependencies: ["CodexCore"]
        ),
    ]
)
