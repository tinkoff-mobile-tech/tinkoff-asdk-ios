// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinkoffASDKUI",
    defaultLocalization: "ru",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "TinkoffASDKUI",
            targets: ["TinkoffASDKUI"]
        )
    ],
    dependencies: [.package(name: "TinkoffASDKCore", path: "../TinkoffASDKCore")],
    targets: [
        .target(
            name: "TinkoffASDKUI",
            dependencies: [
                .product(name: "TinkoffASDKCore", package: "TinkoffASDKCore")
            ],
            path: "TinkoffASDKUI",
            exclude: ["Info.plist"],
            resources: [
                .copy("Images/Images/tinkoff_40/tinkoff_40@2x.png"),
                .copy("Images/Images/tinkoff_40/tinkoff_40@3x.png")
            ]
        ),
        .testTarget(
            name: "TinkoffASDKUITests",
            dependencies: ["TinkoffASDKUI"],
            path: "TinkoffASDKUITests",
            exclude: ["Info.plist"]
        ),
    ]
)
