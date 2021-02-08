// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = "4.4.1-srg4+b2"
    static let checksum: String = "9c503cbf59502b1e4c2c8ebbfb4d24fa1ff92d9bdc147fe3dae98ee824c7246a"
}

let package = Package(
    name: "TCSDK",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "TCSDK",
            targets: ["TCSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "TCSDK",
            url: "https://github.com/SRGSSR/TCSDK-xcframework-apple/releases/download/\(PackageMetadata.version)/TCSDK.xcframework.zip",
            checksum: PackageMetadata.checksum
        )
    ]
)
