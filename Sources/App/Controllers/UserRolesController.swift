import Vapor
import Fluent
import FluentPostgresDriver
import ExtendedError

/// Connect/disconnect user with role.
final class UserRolesController: RouteCollection {

    public static let uri = "/user-roles"

    func boot(routes: RoutesBuilder) throws {
        // routes.post(UserRoleDto.self, at: "\(UserRolesController.uri)/connect", use: connect)
        // routes.post(UserRoleDto.self, at: "\(UserRolesController.uri)/disconnect", use: disconnect)
    }
/*
    func connect(request: Request, userRoleDto: UserRoleDto) throws -> Future<HTTPResponseStatus> {

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)


        let attachFuture = verifySuperUserFuture.flatMap(to: Void.self) {
            let userFuture = User.find(userRoleDto.userId, on: request).unwrap(or: EntityNotFoundError.userNotFound)
            let roleFuture = Role.find(userRoleDto.roleId, on: request).unwrap(or: EntityNotFoundError.roleNotFound)

            return map(to: Void.self, userFuture, roleFuture) { user, role in
                _ = user.roles.attach(role, on: request)
            }
        }

        return attachFuture.transform(to: HTTPStatus.ok)
    }

    func disconnect(request: Request, userRoleDto: UserRoleDto) throws -> Future<HTTPResponseStatus> {

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)


        let detachFuture = verifySuperUserFuture.flatMap(to: Void.self) {
            let userFuture = User.find(userRoleDto.userId, on: request).unwrap(or: EntityNotFoundError.userNotFound)
            let roleFuture = Role.find(userRoleDto.roleId, on: request).unwrap(or: EntityNotFoundError.roleNotFound)

            return map(to: Void.self, userFuture, roleFuture) { user, role in
                _ = user.roles.detach(role, on: request)
            }
        }

        return detachFuture.transform(to: HTTPStatus.ok)
    }
*/
}
