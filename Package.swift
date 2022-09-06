// swift-tools-version: 5.4
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
    dependencies: [
        .package(name: "TinkoffASDKCore", path: "TinkoffASDKCore")
    ],
    targets: [
        .binaryTarget(
            name: "TdsSdkIos",
            path: "ThirdParty/TdsSdkIos.xcframework"
        ),
        .binaryTarget(
            name: "ThreeDSWrapper",
            path: "ThirdParty/ThreeDSWrapper.xcframework"
        ),
        .target(
            name: "TinkoffASDKUI",
            dependencies: [
                .product(name: "TinkoffASDKCore", package: "TinkoffASDKCore"),
                .target(name: "TdsSdkIos"),
                .target(name: "ThreeDSWrapper")
            ],
            path: "TinkoffASDKUI/TinkoffASDKUI",
            exclude: ["Resources/Info.plist"],
            resources: [
                .copy("Images/Images/tinkoff_40/tinkoff_40@2x.png"),
                .copy("Images/Images/tinkoff_40/tinkoff_40@3x.png")
            ]
        ),
        .testTarget(
            name: "TinkoffASDKUITests",
            dependencies: ["TinkoffASDKUI"],
            path: "TinkoffASDKUI/TinkoffASDKUITests",
            exclude: ["Info.plist"]
        ),
    ]
)
