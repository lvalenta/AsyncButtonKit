// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncButtonKit",
    platforms: [
        .iOS(.v13), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AsyncButtonKit",
            targets: ["AsyncButtonKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncButtonKit",
            dependencies: []
        ),
        .testTarget(
            name: "AsyncButtonKitTests",
            dependencies: ["AsyncButtonKit"]),
    ]
)
