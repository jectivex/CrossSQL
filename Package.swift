// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CrossSQL",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(name: "CrossSQL", targets: ["CrossSQL"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/jectivex/CrossFile", branch: "main"),
        .package(url: "https://github.com/jectivex/Skiff", branch: "main"),
    ],
    targets: [
        .target(name: "CrossSQL", dependencies: [], resources: [.process("i18n"), .copy("Resources")]),
        .testTarget(name: "CrossSQLTests", dependencies: ["CrossSQL", "Skiff"]),
    ]
)

#if os(Linux)
package.dependencies += [
    .package(url: "https://github.com/stephencelis/CSQLite.git", from: "0.0.3")
]
package.targets.first?.dependencies += [
    .product(name: "CSQLite", package: "CSQLite")
]
#endif
