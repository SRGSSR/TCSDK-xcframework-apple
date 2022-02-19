TCSDK XCFramework
==================

XCFramework binaries are currently not provided by Tag Commander. Until they are this repository provides XCFrameworks for versions we use at SRG SSR, with a Swift Package Manager manifest for easy integration in projects. Binaries are currently packaged for iOS and tvOS, and built from source since we had to implement tvOS support ourselves.

## Integration

Use [Swift Package Manager](https://swift.org/package-manager) directly [within Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). You can also declare the library as a dependency of another one directly in the associated `Package.swift` manifest.

## Generation

We have a quite recent [mirror of the source code](https://github.com/SRGSSR/tagcommander-src-apple), kept private, which can be used to build all binary flavors, then combined as an XCFramework.

**You should first consider releasing an update to [TCCore](https://github.com/SRGSSR/TCCore-xcframework-apple), as TCSDK depends on it. Note that there is no binary dependency declared in the SPM manifest, as dependencies are currently not supported for binaries**.

### Building the XCFramework

To build the XCFramework:

1. Clone the Tag Commander source code repository: `$ git clone https://github.com/SRGSSR/tagcommander-src-apple.git`.
2. Switch to the tag you want to produce an XCFramework for: `$ git switch --detach <tag>`
3. Use the script to package the framework, providing the checked out repository path as parameter: `$ ./tcsdk_xcframework.sh /path/to/repository`

If everything goes well a zip of the XCFramework will be generated where the script was executed, with the corresponding checksum displayed. **Save the binary zip and the checksum somewhere safe.**

### Make the XCFramework available

To make the generated framework available:

1. Update the `Package.swift` in this repository with the framework version number and the checksum of the zip you just generated.
2. Commit the changes on `master` and create a corresponding tag.
3. Push the commit and the tag to GitHub.
4. Attach the binary to the tag on GitHub.

Do not commit the binaries in the repository, as this would slow done checkouts made by SPM as the repository grows.