import Vapor
import Recaptcha
import Fluent
import FluentPostgresDriver
import ExtendedError
import JWT

extension Application {

    /// Called before your application initializes.
    public func configure(clearDatabase: Bool = false) throws {

        // Register routes to the router.
        try routes()

        // Register middleware.
        registerMiddlewares()

        // Configure database.
        try configureDatabase(clearDatabase: clearDatabase)
        
        // Seed database.
        try seed()
        
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
        
        self.databases.use(.postgres(
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            database: connectionUrl.path.split(separator: "/").last.flatMap(String.init),
            tlsConfiguration: tlsConfiguration
        ), as: .psql)

        // Configure migrations
        self.migrations.add(User())
        self.migrations.add(RefreshToken())
        self.migrations.add(Setting())
        self.migrations.add(Role())
        self.migrations.add(UserRole())

        if clearDatabase {
            try self.autoRevert().wait()
        }
        
        try self.autoMigrate().wait()
    }

    private func loadConfiguration() throws {
        let settings = try self.services.settingsService.get(on: self).wait()
        
        self.settings.configuration = ApplicationSettings(
            application: self,
            emailServiceAddress: settings.getString(.emailServiceAddress),
            isRecaptchaEnabled: settings.getBool(.isRecaptchaEnabled) ?? false,
            recaptchaKey: settings.getString(.recaptchaKey) ?? "",
            jwtPrivateKey: settings.getString(.jwtPrivateKey) ?? ""
        )
        
        if self.settings.configuration.jwtPrivateKey != "" {
            guard let privateKey = self.settings.configuration.jwtPrivateKey.data(using: .ascii) else {
                throw Abort(.internalServerError, reason: "Private key is not configured in database.")
            }
            
            let rsaKey: RSAKey = try .private(pem: privateKey)
            self.jwt.signers.use(.rs512(key: rsaKey))
        }
    }
}
