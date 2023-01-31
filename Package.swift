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
        .package(url: "https://github.com/jectivex/CrossFoundation", branch: "main"),
        .package(url: "https://github.com/jectivex/Skiff", branch: "main"),
    ],
    targets: [
        .target(name: "CrossSQL", dependencies: [
            "CrossFoundation",
        ], resources: [.process("i18n"), .copy("Resources")],
        swiftSettings: [
            .unsafeFlags(["-emit-symbol-graph", "-emit-symbol-graph-dir", ".build", "-symbol-graph-minimum-access-level", "internal"], .when(configuration: .debug)),
        ]),
        .testTarget(name: "CrossSQLTests", dependencies: [
            "CrossSQL",
            .product(name: "Skiff", package: "Skiff", condition: .when(platforms: [.macOS, .linux]))
        ]),
    ]
)

#if os(Linux) // on Linux we need a shim module to export sqlite symbols
package.dependencies += [
    .package(url: "https://github.com/stephencelis/CSQLite.git", from: "0.0.3")
]
package.targets.first?.dependencies += [
    .product(name: "CSQLite", package: "CSQLite")
]
#endif
