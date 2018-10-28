import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic response.
    router.get { req in
        return "Service is up and running!"
    }

    // Configuring a users controller.
    let usersController = UsersController()
    try usersController.boot(router: router)
}
