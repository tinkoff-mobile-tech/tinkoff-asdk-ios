// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinkoffASDKCore",
    defaultLocalization: "ru",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "TinkoffASDKCore",
            targets: ["TinkoffASDKCore"]
        )
    ],
    targets: [
        .target(
            name: "TinkoffASDKCore",
            path: "TinkoffASDKCore"
        ),
        .testTarget(
            name: "TinkoffASDKCoreTests",
            dependencies: ["TinkoffASDKCore"],
            path: "TinkoffASDKCoreTests",
            exclude: ["Info.plist"]
        ),
    ]
)
