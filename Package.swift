// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MLXUtilsLibrary",
    platforms: [
      .iOS(.v18), .macOS(.v15)
    ],
    products: [
        .library(
            name: "MLXUtilsLibrary",
            type: .static,
            targets: ["MLXUtilsLibrary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
            name: "MLXUtilsLibrary",
            dependencies: ["ZIPFoundation"]
        ),
        .testTarget(
            name: "MLXUtilsLibraryTests",
            dependencies: ["MLXUtilsLibrary"]
        ),
    ]
)
