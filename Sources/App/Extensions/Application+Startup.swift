import Vapor
import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import ExtendedError
import JWT

extension Application {

    /// Called before your application initializes.
    public func configure() throws {

        // Register routes to the router.
        try routes()

        // Register middleware.
        registerMiddlewares()

        // Configure database.
        try configureDatabase()
        
        // Migrate database.
        try migrateDatabase()
        
        // Seed database.
        try seedDatabase()
        
        // Read configuration from database.
        try loadConfiguration()
    }

    /// Register your application's routes here.
    private func routes() throws {

        // Basic response.
        self.get { req in
            return "Service is up and running!"
        }

        // Configuring controllers.
        try self.register(collection: UsersController())
        try self.register(collection: AccountController())
        try self.register(collection: RegisterController())
        try self.register(collection: ForgotPasswordController())
        try self.register(collection: RolesController())
        try self.register(collection: UserRolesController())
    }
    
    private func registerMiddlewares() {

        // Cors middleware.
        let corsConfiguration = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
        )
        let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
        self.middleware.use(corsMiddleware)

        // Catches errors and converts to HTTP response.
        let errorMiddleware = CustomErrorMiddleware()
        self.middleware.use(errorMiddleware)
    }

    private func configureDatabase(clearDatabase: Bool = false) throws {

        // In testing environmebt we are using in memory database.
        if self.environment == .testing {
            self.logger.info("In memory SQLite is used during testing")
            self.databases.use(.sqlite(.memory), as: .sqlite)
            return
        }
        
        // Retrieve connection string from Env variables.
        guard let connectionString = Environment.get("MIKROSERVICE_USERS_CONNECTION_STRING") else {
            self.logger.info("In memory SQLite is used during testing")
            self.databases.use(.sqlite(.memory), as: .sqlite)
            return
        }
        
        // When environment variable is not configured we are using in memory database.
        guard let connectionUrl = URL(string: connectionString) else {
            self.logger.warning("No 'MIKROSERVICE_USERS_CONNECTION_STRING' environment variable configured. In memory SQLite is used.")
            self.databases.use(.sqlite(.memory), as: .sqlite)
            return
        }
            
        // Configuration for Postgres.
        if connectionUrl.scheme?.hasPrefix("postgres") == true {
            self.logger.info("Postgres database is configured in environment variable (host: \(connectionUrl.host ?? ""), db: \(connectionUrl.path))")
            try self.configurePostgres(connectionUrl: connectionUrl)
            return
        }
        
        // When we have environment variable but it's not Postgres we are trying to run SQLite in file.
        self.logger.info("SQLite file database is configured in environment variable (file: \(connectionUrl.path))")
        self.databases.use(.sqlite(.file(connectionUrl.path)), as: .sqlite)
    }
    
    private func migrateDatabase() throws {

        // Configure migrations
        self.migrations.add(CreateUsers())
        self.migrations.add(CreateRefreshTokens())
        self.migrations.add(CreateSettings())
        self.migrations.add(CreateRoles())
        self.migrations.add(CreateUserRoles())
        
        try self.autoMigrate().wait()
    }

    private func loadConfiguration() throws {
        let settings = try self.services.settingsService.get(on: self).wait()
        
        guard let privateKey = settings.getString(.jwtPrivateKey)?.data(using: .ascii) else {
            throw Abort(.internalServerError, reason: "Private key is not configured in database.")
        }
        
        let rsaKey: RSAKey = try .private(pem: privateKey)
        self.jwt.signers.use(.rs512(key: rsaKey))
        
        self.settings.configuration = ApplicationSettings(
            application: self,
            emailServiceAddress: settings.getString(.emailServiceAddress),
            isRecaptchaEnabled: settings.getBool(.isRecaptchaEnabled) ?? false,
            recaptchaKey: settings.getString(.recaptchaKey) ?? ""
        )
    }
    
    private func configurePostgres(connectionUrl: URL) throws {
        var tlsConfiguration = TLSConfiguration.forClient()
        tlsConfiguration.certificateVerification = .none
        
        guard let username = connectionUrl.user else {
            throw DatabaseConnectionError.userNameNotSpecified
        }
        guard let password = connectionUrl.password else {
            throw DatabaseConnectionError.passwordNotSpecified
        }
        guard let hostname = connectionUrl.host else {
            throw DatabaseConnectionError.hostNotSpecified
        }
        guard let port = connectionUrl.port else {
            throw DatabaseConnectionError.portNotSpecified
        }
        guard let database = connectionUrl.path.split(separator: "/").last.flatMap(String.init) else {
            throw DatabaseConnectionError.databaseNotSpecified
        }
        
        self.databases.use(.postgres(
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            database: database,
            tlsConfiguration: tlsConfiguration
        ), as: .psql)
    }
}
