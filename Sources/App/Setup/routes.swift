import Vapor

/// Register your application's routes here.
public func routes(_ app: Application) throws {

    // Basic response.
    app.get { req in
        return "Service is up and running!"
    }

    // Configuring controllers.
    try app.register(collection: UsersController())
    try app.register(collection: AccountController())
    try app.register(collection: RegisterController())
    try app.register(collection: ForgotPasswordController())
    try app.register(collection: RolesController())
    try app.register(collection: UserRolesController())
}
