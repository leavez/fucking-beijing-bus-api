// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fucking-beijing-bus-api",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "fucking-beijing-bus-api",
            targets: ["fucking-beijing-bus-api"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.7.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "fucking-beijing-bus-api",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "fucking-beijing-bus-apiTests",
            dependencies: ["fucking-beijing-bus-api"]),
    ]
)

