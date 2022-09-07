// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownText",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "MarkdownText",
            targets: ["MarkdownText"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown", branch: "main"),
        .package(url: "https://github.com/shaps80/SwiftUIBackports", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "MarkdownText",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .byName(name: "SwiftUIBackports")
            ]
        )
    ]
)
