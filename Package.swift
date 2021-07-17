// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .executable(name: "package", targets: ["Package"]),
        .library(name: "PackageFramework", targets: ["PackageFramework"])
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.31.0")),
    ],
    targets: [
        .target(
            name: "Package",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                           "PackageFramework"]),
        .target(name: "PackageFramework",
                dependencies: [.product(name: "SourceKittenFramework", package: "SourceKitten")]),
        .testTarget(
            name: "PackageFrameworkTests",
            dependencies: ["PackageFramework"],
            resources: [.process("Resources")])
    ]
)
