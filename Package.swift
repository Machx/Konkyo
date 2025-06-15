// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Konkyo",
	platforms: [
		.macOS(.v15),
		.iOS(.v18),
	],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Konkyo",
            targets: ["Konkyo"]),
    ],
    dependencies: [
        // will update versions later, for now just specify branch
		.package(url: "https://github.com/Machx/LoggingKit.git", .branch("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "Konkyo",
			dependencies: [],
			swiftSettings: [
				//.enableExperimentalFeature("StrictConcurrency")
			]),
        .testTarget(
            name: "KonkyoTests",
            dependencies: ["Konkyo"]),
    ],
	swiftLanguageModes: [.v5, .v6]
)
