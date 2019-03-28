import Vapor
import FluentPostgreSQL

/// Controls basic operations for User object.
final class UsersController: RouteCollection {

    public static let uri = "/users"

    func boot(router: Router) throws {
        router.get(UsersController.uri, String.parameter, use: profile)
        router.put(UserDto.self, at: UsersController.uri, String.parameter, use: update)
        router.delete(UsersController.uri, String.parameter, use: delete)
    }

    /// User profile.
    func profile(request: Request) throws -> Future<UserDto> {

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let userNameNormalized = try request.parameters.next(String.self).replacingOccurrences(of: "@", with: "").uppercased()

        let userFuture = User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first()
        let userNameFromTokenFuture = try authorizationService.getUserNameFromBearerToken(request: request)

        return map(to: UserDto.self, userFuture, userNameFromTokenFuture) { userFromDb, userNameFromToken in
            try self.getUserProfile(on: request,
                                    userFromDb: userFromDb,
                                    userNameFromRequest: userNameNormalized,
                                    userNameFromToken: userNameFromToken)
        }
    }

    /// Update user data.
    func update(request: Request, userDto: UserDto) throws -> Future<UserDto> {

        try userDto.validate()

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let userNameFuture = try authorizationService.getUserNameFromBearerTokenOrAbort(on: request)

        return userNameFuture.flatMap(to: User.self) { userNameFromToken in
            let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

            let isProfileOwner = userNameFromToken.uppercased() == userNameNormalized
            guard isProfileOwner else {
                throw EntityForbiddenError.userForbidden
            }

            return try self.updateUser(on: request, userDto: userDto, userNameNormalized: userNameNormalized)
        }.map { user in
            let userDto = UserDto(from: user)
            return userDto
        }
    }

    /// Delete user.
    func delete(request: Request) throws -> Future<HTTPStatus> {

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let userNameFuture = try authorizationService.getUserNameFromBearerTokenOrAbort(on: request)

        return userNameFuture.flatMap(to: Void.self) { userNameFromToken in
            let userNameNormalized = try request.parameters.next(String.self).uppercased().replacingOccurrences(of: "@", with: "")

            return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: Void.self) { userFromDb in

                guard let user = userFromDb else {
                    throw EntityNotFoundError.userNotFound
                }

                let isProfileOwner = userNameFromToken.uppercased() == userNameNormalized
                guard isProfileOwner else {
                    throw EntityForbiddenError.userForbidden
                }

                return user.delete(on: request)
            }
        }.transform(to: HTTPStatus.ok)
    }

    private func getUserProfile(on request: Request,
                                userFromDb: User?,
                                userNameFromRequest: String,
                                userNameFromToken: String?) throws -> UserDto {
        guard let user = userFromDb else {
            throw EntityNotFoundError.userNotFound
        }

        let userDto = UserDto(from: user)

        
        let isProfileOwner = userNameFromToken?.uppercased() == userNameFromRequest
        if !isProfileOwner {
            userDto.email = nil
            userDto.birthDate = nil
        }

        return userDto
    }

    private func updateUser(on request: Request, userDto: UserDto, userNameNormalized: String) throws -> Future<User> {
        return User.query(on: request).filter(\.userNameNormalized == userNameNormalized).first().flatMap(to: User.self) { userFromDb in

            guard let user = userFromDb else {
                throw EntityNotFoundError.userNotFound
            }

            user.name = userDto.name
            user.bio = userDto.bio
            user.birthDate = userDto.birthDate
            user.location = userDto.location
            user.website = userDto.website

            return user.update(on: request)
        }
    }
}
