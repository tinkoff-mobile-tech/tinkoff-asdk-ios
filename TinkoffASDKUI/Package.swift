// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
	name: "ASDKUI",
    
	products: [
		.library( name: "ASDKUI", targets: ["ASDKUI"] ),
    ],
	
	dependencies: [
		.package(path: "../ASDKCore")
	],
	
    targets: [
		.target( name: "ASDKUI", dependencies: ["ASDKCore"], path: "ASDKUI" ),
		.testTarget( name: "ASDKUITests", dependencies: ["ASDKUI"], path: "ASDKUITests" ),
    ]
)
