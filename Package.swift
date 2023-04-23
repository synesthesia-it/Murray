// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: [Target.Dependency] = ["Files", "Rainbow", "Stencil", "StencilSwiftKit", "XcodeProj", "Yams"]

let package = Package(
    name: "Murray",
    products: [
        .executable(name: "murray", targets: ["Murray"]),
        .library(name: "MurrayKit", targets: ["MurrayKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(
            name: "Files",
            url: "https://github.com/johnsundell/files.git",
            from: "4.0.0"
        ),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", from: "8.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.3"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit", from: "2.10.1")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "MurrayKit",
                dependencies: dependencies),
        .target(name: "Murray",
                dependencies: ["MurrayKit", "Commander"] + dependencies),
        .testTarget(name: "MurrayKitTests",
                    dependencies: ["MurrayKit"] + dependencies,
                    resources: [.copy("Mocks")])
    ]
)
