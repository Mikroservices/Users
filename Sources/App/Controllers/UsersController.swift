import Vapor
import Fluent
import FluentPostgresDriver

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    public static let uri: PathComponent = .constant("users")
    
    func boot(routes: RoutesBuilder) throws {
        let usersGroup = routes
            .grouped(UsersController.uri)
            .grouped(UserAuthenticator().middleware())
            .grouped(UserPayload.guardMiddleware())
        
        usersGroup.get(":name", use: read)
        usersGroup.put(":name", use: update)
        usersGroup.delete(":name", use: delete)
    }

    /// User profile.
    func read(request: Request) throws -> EventLoopFuture<UserDto> {

        guard let userName = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        let userNameNormalized = userName.replacingOccurrences(of: "@", with: "").uppercased()
        let userFuture = User.query(on: request.db).filter(\.$userNameNormalized == userNameNormalized).first()

        return userFuture.flatMap { userFromDb in
            guard let user = userFromDb else {
                return request.fail(EntityNotFoundError.userNotFound)
            }
            
            let userProfile = self.getUserProfile(on: request,
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
        
        let userDto = try request.content.decode(UserDto.self)
        try UserDto.validate(request)

        let userNameNormalized = userName.replacingOccurrences(of: "@", with: "").uppercased()
        let userNameFromToken = request.auth.get(UserPayload.self)?.userName

        let isProfileOwner = userNameFromToken?.uppercased() == userNameNormalized
        guard isProfileOwner else {
            throw EntityForbiddenError.userForbidden
        }
        
        return self.updateUser(on: request, userDto: userDto, userNameNormalized: userNameNormalized).map { user in
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
        
        return self.deleteUser(on: request, userNameNormalized: userNameNormalized)
            .transform(to: HTTPStatus.ok)
    }

    private func getUserProfile(on request: Request, user: User, userNameFromRequest: String) -> UserDto {
        let userDto = UserDto(from: user)

        let userNameFromToken = request.auth.get(UserPayload.self)?.userName
        let isProfileOwner = userNameFromToken?.uppercased() == userNameFromRequest

        if !isProfileOwner {
            userDto.email = nil
            userDto.birthDate = nil
        }

        return userDto
    }

    private func updateUser(on request: Request, userDto: UserDto, userNameNormalized: String) -> EventLoopFuture<User> {
        return User.query(on: request.db).filter(\.$userNameNormalized == userNameNormalized).first().flatMap { userFromDb in

            guard let user = userFromDb else {
                return request.fail(EntityNotFoundError.userNotFound)
            }

            user.name = userDto.name
            user.bio = userDto.bio
            user.birthDate = userDto.birthDate
            user.location = userDto.location
            user.website = userDto.website

            return user.update(on: request.db).transform(to: user)
        }
    }
    
    private func deleteUser(on request: Request, userNameNormalized: String) -> EventLoopFuture<Void> {
        return User.query(on: request.db).filter(\.$userNameNormalized == userNameNormalized).first().flatMap { userFromDb -> EventLoopFuture<Void> in
            guard let user = userFromDb else {
                return request.fail(EntityNotFoundError.userNotFound)
            }
            
            return user.delete(on: request.db)
        }
    }
}
