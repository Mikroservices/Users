// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Users",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.1"),

        // 🖋 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc.2"),

        // 🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc.1.1"),
        
        // 🗄 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-rc.1.1"),

        // 🔏 JSON Web Token signing and verification (HMAC, RSA).
        .package(url: "https://github.com/mczachurski/jwt-kit.git", .branch("feature/microsoft-jwks")),
        .package(url: "https://github.com/mczachurski/jwt.git", .branch("feature/microsoft-jwks")),

        // 🔑 Google Recaptcha for securing anonymous endpoints.
        .package(url: "https://github.com/Mikroservices/Recaptcha.git", from: "2.0.0"),

        // 🐞 Custom error middleware for Vapor.
        .package(url: "https://github.com/Mikroservices/ExtendedError.git", from: "2.0.0"),
        
        // 📖 Apple logger hander.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "JWT", package: "jwt"),
            .product(name: "JWTKit", package: "jwt-kit"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "ExtendedError", package: "ExtendedError"),
            .product(name: "Recaptcha", package: "Recaptcha")
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App")
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .product(name: "XCTVapor", package: "vapor"),
            .target(name: "App")
        ])
    ]
)
