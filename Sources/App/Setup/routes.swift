import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic response.
    router.get { req in
        return "Service is up and running!"
    }

    // Configuring controllers.
    try router.register(collection: UsersController())
    try router.register(collection: AccountController())
    try router.register(collection: RegisterController())
    try router.register(collection: ForgotPasswordController())
    try router.register(collection: RolesController())
    try router.register(collection: UserRolesController())
}
