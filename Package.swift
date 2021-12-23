// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "slox",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "slox",
            targets: ["Slox"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "cli",
            dependencies: [
                "Slox"
            ]
        ),
        .target(
            name: "Slox",
            dependencies: []
        ),

        .testTarget(
            name: "SloxTests",
            dependencies: ["Slox"]
        ),
    ]
)
