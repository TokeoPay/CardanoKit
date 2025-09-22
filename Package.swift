// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let useLocalCSKKit = true

var package = Package(
    name: "CardanoKit",
    platforms: [.macOS(.v15), .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CardanoKit",
            targets: ["CardanoKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tesseract-one/Bip39.swift.git", from: "0.2.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        useLocalCSKKit ?
            .package(
                name: "csl-mobile-bridge", path: "../csl-mobile-bridge/CSLKit"
            ) :
            .package(
                url: "https://github.com/TokeoPay/csl-mobile-bridge.git",
                exact: "0.0.1-alpha.12"
            ),
    ],
    targets: [
//        .binaryTarget(name: "msg_signing_lib", path: "../message-signing-bridge/ios/build/message_signing_bridge.artifactbundle/message_signing_bridge.xcframework"),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CardanoKit",
            dependencies: [
                .product(name: "Bip39", package: "bip39.swift"),
                .product(name: "CSLKit", package: "csl-mobile-bridge"),
                .product(name: "Alamofire", package: "Alamofire"),
//                "msg_signing_lib",
            ],
        ),
        .testTarget(
            name: "CardanoKitTests",
            dependencies: ["CardanoKit"]
        ),
    ]
)
