// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CoffeeServer",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/vapor/jwt.git", .upToNextMajor(from: "4.2.1")),
        .package(url: "https://github.com/JohnSundell/Plot.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/swift-calendar/icalendarkit.git", .upToNextMajor(from: "1.0.2")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Plot", package: "Plot"),
                .product(name: "ICalendarKit", package: "ICalendarKit"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
