import Vapor
import Recaptcha
import FluentPostgreSQL
import ExtendedError

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    /// Register routes to the router.
    try registerRoutes(services: &services)

    /// Register middleware.
    registerMiddlewares(services: &services)

    /// Register database providers first.
    try configureDatabaseProvider(services: &services)

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

private func configureDatabaseProvider(services: inout Services) throws {
    try services.register(FluentPostgreSQLProvider())
}

private func configureDatabase(services: inout Services) throws {

    let connectionString = try Environment.require("MIKROSERVICE_USERS_CONNECTION_STRING")

    // Configure a PostgreSQL database
    guard let databaseConfig = PostgreSQLDatabaseConfig(url: connectionString, transport: .unverifiedTLS) else {
        throw Abort(.internalServerError, reason: "Database connection string has wrong format.")
    }

    let postgresql = PostgreSQLDatabase(config: databaseConfig)

    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    migrations.add(model: Setting.self, database: .psql)
    migrations.add(model: Role.self, database: .psql)
    migrations.add(model: UserRole.self, database: .psql)
    services.register(migrations)
}
