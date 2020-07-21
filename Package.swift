// swift-tools-version:5.3

import PackageDescription

struct PackageMetadata {
    static let version: String = "4.4.1-srg3"
    static let checksum: String = "55985ae9737dcb3aecc1ced1553f10232caa4d0c058dcf74e103c2870df78e28"
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
