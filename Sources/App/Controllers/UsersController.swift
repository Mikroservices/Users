import Vapor

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    public static let uri: PathComponent = .constant("users")
    
    func boot(routes: RoutesBuilder) throws {
        let usersGroup = routes
            .grouped(UsersController.uri)
            .grouped(UserAuthenticator().middleware())
        
        usersGroup.get(":name", use: read)

        usersGroup
            .grouped(UserPayload.guardMiddleware())
            .put(":name", use: update)
        
        usersGroup
            .grouped(UserPayload.guardMiddleware())
            .delete(":name", use: delete)
    }

    /// User profile.
    func read(request: Request) throws -> EventLoopFuture<UserDto> {

        guard let userName = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        let usersService = request.application.services.usersService
        let userNameNormalized = userName.replacingOccurrences(of: "@", with: "").uppercased()
        let userFuture = usersService.get(on: request, userName: userNameNormalized)

        return userFuture.flatMap { userFromDb in
            guard let user = userFromDb else {
                return request.fail(EntityNotFoundError.userNotFound)
            }
            
            let userProfile = self.cleanUserProfile(on: request,
                                                    user: user,
                                                    userNameFromRequest: userNameNormalized)
            
            return request.success(userProfile)
        }
    }

    /// Update user data.
    func update(request: Request) throws -> EventLoopFuture<UserDto> {

        guard let userName = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }

        let userNameNormalized = userName.replacingOccurrences(of: "@", with: "").uppercased()
        let userNameFromToken = request.auth.get(UserPayload.self)?.userName

        let isProfileOwner = userNameFromToken?.uppercased() == userNameNormalized
        guard isProfileOwner else {
            throw EntityForbiddenError.userForbidden
        }
        
        let userDto = try request.content.decode(UserDto.self)
        try UserDto.validate(request)
        
        let usersService = request.application.services.usersService
        return usersService.updateUser(on: request, userDto: userDto, userNameNormalized: userNameNormalized).map { user in
            UserDto(from: user)
        }
    }

    /// Delete user.
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {

        guard let userName = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        let userNameNormalized = userName.replacingOccurrences(of: "@", with: "").uppercased()
        let userNameFromToken = request.auth.get(UserPayload.self)?.userName

        let isProfileOwner = userNameFromToken?.uppercased() == userNameNormalized
        guard isProfileOwner else {
            throw EntityForbiddenError.userForbidden
        }
        
        let usersService = request.application.services.usersService
        return usersService.deleteUser(on: request, userNameNormalized: userNameNormalized)
            .transform(to: HTTPStatus.ok)
    }

    private func cleanUserProfile(on request: Request, user: User, userNameFromRequest: String) -> UserDto {
        var userDto = UserDto(from: user)

        let userNameFromToken = request.auth.get(UserPayload.self)?.userName
        let isProfileOwner = userNameFromToken?.uppercased() == userNameFromRequest

        if !isProfileOwner {
            userDto.email = nil
            userDto.birthDate = nil
        }

        return userDto
    }
}
