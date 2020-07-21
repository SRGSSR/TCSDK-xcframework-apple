// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = ""
    static let checksum: String = ""
}

let package = Package(
    name: "TCSDK",
    platforms: [
        .iOS(.v8),
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
