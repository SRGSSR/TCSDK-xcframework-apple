// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = "4.4.1-srg3"
    static let checksum: String = "78c3fca0826341606186f926622a6796529123d940554e4fcfabe1677037ed6c"
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
