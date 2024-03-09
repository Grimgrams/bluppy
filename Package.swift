// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bluppy",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/vapor/postgres-kit.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/samiyr/SwiftyPing.git", branch: "master"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "bluppy", dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PostgresKit", package: "postgres-kit"),
                .product(name: "PostgresClientKit", package: "postgresclientkit"),
                .product(name: "SwiftyPing", package: "swiftyping"),
                .product(name: "SwiftyJSON", package: "swiftyjson"),
                    ]),
    ]
)
