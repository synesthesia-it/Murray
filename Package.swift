// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Murray",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
	.package(
            url: "https://github.com/johnsundell/files.git",
            from: "2.0.0"
        ),
    .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Murray", dependencies: ["MurrayCore"]),
        .target(name: "MurrayCore", dependencies:
            ["Files","ShellOut","Commander","Rainbow"]
        ),
        .testTarget(
            name: "MurrayTests",
            dependencies: ["MurrayCore", "Files"]
        )
        ]
)
