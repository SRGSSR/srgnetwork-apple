// swift-tools-version:5.3

import PackageDescription

struct ProjectSettings {
    static let marketingVersion: String = "3.0.0"
}

let package = Package(
    name: "SRGNetwork",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
        .tvOS(.v12),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "SRGNetwork",
            targets: ["SRGNetwork"]
        )
    ],
    dependencies: [
        .package(name: "libextobjc", url: "https://github.com/SRGSSR/libextobjc.git", .branch("master")),
        .package(name: "MAKVONotificationCenter", url: "https://github.com/SRGSSR/MAKVONotificationCenter.git", .branch("master")),
        .package(name: "SRGLogger", url: "https://github.com/SRGSSR/srglogger-apple.git", .branch("develop"))
    ],
    targets: [
        .target(
            name: "SRGNetwork",
            dependencies: ["libextobjc", "MAKVONotificationCenter", "SRGLogger"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .define("MARKETING_VERSION", to: "\"\(ProjectSettings.marketingVersion)\"")
            ]
        ),
        .testTarget(
            name: "SRGNetworkTests",
            dependencies: ["SRGNetwork"]
        )
    ]
)
