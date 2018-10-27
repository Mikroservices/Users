import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic response.
    router.get { req in
        return "Service is up and running!"
    }

    // Configuring a users controller.
    let usersController = UsersController()
    router.get("users", use: usersController.index)
    router.post("users", use: usersController.create)
    router.post("users/sign-in", use: usersController.signIn)
}
