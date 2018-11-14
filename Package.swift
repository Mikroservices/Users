// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Users",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // 🔏 JSON Web Token signing and verification (HMAC, RSA).
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),

        // 🔑 Google Recaptcha for securing anonymous endpoints.
        .package(url: "https://github.com/Letterer/Recaptcha.git", from: "1.0.1"),

        // 🐞 Custom error middleware for Vapor
        .package(url: "https://github.com/Letterer/ExtendedError.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "JWT", "Recaptcha", "ExtendedError"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

