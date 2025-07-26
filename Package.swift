// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-node-tree-struct",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "NodeTreeStruct", targets: ["NodeTreeStruct"]),
    ],
    dependencies: [
        .package(url: "https://github.com/inekipelov/swift-codable-advance.git", from: "0.1.0"),
        .package(url: "https://github.com/inekipelov/swift-collection-advance.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "NodeTreeStruct",
            dependencies: [
                .product(name: "CodableAdvance", package: "swift-codable-advance"),
                .product(name: "CollectionAdvance", package: "swift-collection-advance"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources"
        ),
        .testTarget(name: "NodeTreeStructTests", dependencies: ["NodeTreeStruct"], path: "Tests"),
    ]
)
