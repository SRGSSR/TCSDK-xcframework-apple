// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = "4.4.1-srg4+b1"
    static let checksum: String = "0c0fd2abdc2b2d0e6a2ff075c1850d17f09f8eee274cfcf0f20aea454ff17b70"
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
