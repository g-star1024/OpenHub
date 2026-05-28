// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OpenHub",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "OpenHub", targets: ["GitHubAppHub"])
    ],
    targets: [
        .executableTarget(
            name: "GitHubAppHub",
            path: "Sources/GitHubAppHub"
        )
    ]
)
