import Vapor
import Recaptcha
import Fluent
import FluentPostgresDriver
import ExtendedError
import JWT

/// Called before your application initializes.
public func configure(_ app: Application) throws {

    // Register routes to the router.
    try routes(app)

    // Register middleware.
    registerMiddlewares(app)

    // Configure database.
    try configureDatabase(app)
    
    // Seed database.
    try DatabaseSeed.execute(app)
    
    // Read configuration from database.
    try loadConfiguration(app)
}

private func registerMiddlewares(_ app: Application) {

    // Cors middleware.
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware)

    // Catches errors and converts to HTTP response.
    let errorMiddleware = CustomErrorMiddleware()
    app.middleware.use(errorMiddleware)
}

private func configureDatabase(_ app: Application) throws {

    // Retrieve connection string from Env variables.
    let connectionString = try Environment.require("MIKROSERVICE_USERS_CONNECTION_STRING")
    guard let connectionUrl = URL(string: connectionString) else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    
    // Configure a PostgreSQL database.
    var tlsConfiguration = TLSConfiguration.forClient()
    tlsConfiguration.certificateVerification = .none
    
    guard connectionUrl.scheme?.hasPrefix("postgres") == true else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    guard let username = connectionUrl.user else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    guard let password = connectionUrl.password else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    guard let hostname = connectionUrl.host else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    guard let port = connectionUrl.port else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }
    
    app.databases.use(.postgres(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: connectionUrl.path.split(separator: "/").last.flatMap(String.init),
        tlsConfiguration: tlsConfiguration
    ), as: .psql)

    // Configure migrations
    app.migrations.add(User())
    app.migrations.add(RefreshToken())
    app.migrations.add(Setting())
    app.migrations.add(Role())
    app.migrations.add(UserRole())

    try app.autoMigrate().wait()
}

private func loadConfiguration(_ app: Application) throws {
    let configuration = try app.services.settingsService.get(on: app).wait()
    
    app.settings.configuration = ApplicationSettings(
        application: app,
        emailServiceAddress: configuration.getString(.emailServiceAddress),
        isRecaptchaEnabled: configuration.getBool(.isRecaptchaEnabled) ?? false,
        recaptchaKey: configuration.getString(.recaptchaKey) ?? "",
        jwtPrivateKey: configuration.getString(.jwtPrivateKey) ?? ""
    )
    
    if app.settings.configuration.jwtPrivateKey != "" {
        guard let privateKey = app.settings.configuration.jwtPrivateKey.data(using: .ascii) else {
            throw Abort(.internalServerError, reason: "Private key is not configured in database.")
        }
        
        let rsaKey: RSAKey = try .private(pem: privateKey)
        app.jwt.signers.use(.rs512(key: rsaKey))
    }
}
