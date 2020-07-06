// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ASDKCore",
	
	products: [
		.library( name: "ASDKCore", targets: ["ASDKCore"]),
	],
	
	dependencies: [],
	
	targets: [
		.target( name: "ASDKCore", path: "ASDKCore"),
		.testTarget( name: "ASDKCoreTests",  dependencies: ["ASDKCore"], path: "ASDKCoreTests"),
	]
)
