import Vapor
import Recaptcha
import FluentPostgreSQL
import ExtendedError

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    /// Register database providers first.
    try configureDatabaseProvider(services: &services)

    // Register authorization key service.
    try registerAuthorizationPrivateKey(services: &services)

    // Register reCaptcha.
    try registerRecaptchaServices(services: &services)

    /// Register routes to the router.
    try registerRoutes(services: &services)

    /// Register middleware.
    registerMiddlewares(services: &services)

    // Configure database.
    try configureDatabase(services: &services)
}

private func registerMiddlewares(services: inout Services) {
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)

    // Catches errors and converts to HTTP response
    services.register(CustomErrorMiddleware.self)
    middlewares.use(CustomErrorMiddleware.self)
    
    services.register(middlewares)
}

private func registerRoutes(services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

private func registerAuthorizationPrivateKey(services: inout Services) throws {
    guard let privateKey = Environment.get("LETTERER_PRIVATE_KEY") else { throw Abort(.internalServerError) }
    guard let emailServiceAddress = Environment.get("LETTERER_EMAIL_SERVICE_ADDRESS") else { throw Abort(.internalServerError) }

    services.register { container -> SettingsStorage in
        let privateKeyWithNewLines = privateKey.replacingOccurrences(of: "<br>", with: "\n")
        return SettingsStorage(privateKey: privateKeyWithNewLines, emailServiceAddress: emailServiceAddress)
    }
}

private func registerRecaptchaServices(services: inout Services) throws {
    guard let recaptchaIsEnabled = Environment.get("LETTERER_RECAPTCHA_ENABLED") else { throw Abort(.internalServerError) }
    if recaptchaIsEnabled == "YES" {
        guard let recaptchaKey = Environment.get("LETTERER_RECAPTCHA_KEY") else { throw Abort(.internalServerError) }

        let captchaConfig = GoogleCaptchaConfig(secretKey: recaptchaKey)
        try services.register(GoogleCaptchaProvider(config: captchaConfig))
    } else {
        try services.register(MockCaptchaProvider())
    }
}

private func configureDatabaseProvider(services: inout Services) throws {
    try services.register(FluentPostgreSQLProvider())
}

private func configureDatabase(services: inout Services) throws {

    guard let connectionString = Environment.get("LETTERER_USERS_CONNECTION_STRING") else { throw Abort(.internalServerError) }

    // Configure a PostgreSQL database
    guard let databaseConfig = PostgreSQLDatabaseConfig(url: connectionString) else {
        return
    }

    let postgresql = PostgreSQLDatabase(config: databaseConfig)

    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    services.register(migrations)
}
