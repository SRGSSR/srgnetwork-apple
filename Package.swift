// swift-tools-version:5.3

import PackageDescription

struct ProjectSettings {
    static let marketingVersion: String = "3.0.4"
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
        .package(name: "libextobjc", url: "https://github.com/SRGSSR/libextobjc.git", .exact("0.6.0-srg3")),
        .package(name: "MAKVONotificationCenter", url: "https://github.com/SRGSSR/MAKVONotificationCenter.git", .exact("1.0.0-srg5")),
        .package(name: "SRGLogger", url: "https://github.com/SRGSSR/srglogger-apple.git", .upToNextMinor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "SRGNetwork",
            dependencies: ["libextobjc", "MAKVONotificationCenter", "SRGLogger"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .define("MARKETING_VERSION", to: "\"\(ProjectSettings.marketingVersion)\""),
                .define("NS_BLOCK_ASSERTIONS", to: "1", .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "SRGNetworkTests",
            dependencies: ["SRGNetwork"]
        )
    ]
)
