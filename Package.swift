// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = "4.4.1-srg4"
    static let checksum: String = "fc99419de060f5c95ce5cb9ead106d892dd15fbd969658755c11bea8f79fcc4a"
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
