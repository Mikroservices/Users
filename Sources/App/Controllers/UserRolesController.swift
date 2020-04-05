import Vapor

/// Connect/disconnect user with role.
final class UserRolesController: RouteCollection {

    public static let uri: PathComponent = .constant("user-roles")
    
    func boot(routes: RoutesBuilder) throws {
        let userRolesGroup = routes
            .grouped(UserRolesController.uri)
            .grouped(UserAuthenticator().middleware())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
        
        userRolesGroup.post("connect", use: connect)
        userRolesGroup.post("disconnect", use: disconnect)
    }
    
    /// Connect role to the user.
    func connect(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let userRoleDto = try request.content.decode(UserRoleDto.self)

        let userFuture = User.find(userRoleDto.userId, on: request.db).unwrap(or: EntityNotFoundError.userNotFound)
        let roleFuture = Role.find(userRoleDto.roleId, on: request.db).unwrap(or: EntityNotFoundError.roleNotFound)

        let attachFuture = userFuture.and(roleFuture).map { (user, role) in
            user.$roles.attach(role, on: request.db)
        }

        return attachFuture.transform(to: HTTPStatus.ok)
    }

    /// Disconnects role and user.
    func disconnect(request: Request) throws -> EventLoopFuture<HTTPResponseStatus> {
        let userRoleDto = try request.content.decode(UserRoleDto.self)

        let userFuture = User.find(userRoleDto.userId, on: request.db).unwrap(or: EntityNotFoundError.userNotFound)
        let roleFuture = Role.find(userRoleDto.roleId, on: request.db).unwrap(or: EntityNotFoundError.roleNotFound)

        let attachFuture = userFuture.and(roleFuture).map { (user, role) in
            user.$roles.detach(role, on: request.db)
        }

        return attachFuture.transform(to: HTTPStatus.ok)
    }
}
