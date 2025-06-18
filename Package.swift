// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CardanoKit",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CardanoKit",
            targets: ["CardanoKit"]),
    ],dependencies: [
        .package(
            url: "https://github.com/TokeoPay/csl-mobile-bridge.git",
            revision: "b689f7fdad195fc48cce99842424b28f36d89aac"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CardanoKit",
            dependencies: [
                .product(name: "CSLKit", package: "csl-mobile-bridge")
            ]
        ),
        .testTarget(
            name: "CardanoKitTests",
            dependencies: ["CardanoKit"]
        ),
    ]
)
