import Vapor
import Fluent
import FluentPostgresDriver
import ExtendedError

/// Controls basic operations for Role object.
final class RolesController: RouteCollection {

    public static let uri = "/roles"

    func boot(routes: RoutesBuilder) throws {
        // routes.post(RoleDto.self, at: RolesController.uri, use: create)
        // routes.get(RolesController.uri, use: list)
        // routes.get(RolesController.uri, String.parameter, use: read)
        // routes.put(RoleDto.self, at: RolesController.uri, String.parameter, use: update)
        // routes.delete(RolesController.uri, String.parameter, use: delete)
    }
/*
    /// Create new role.
    func create(request: Request, roleDto: RoleDto) throws -> EventLoopFuture<Response> {

        try RoleDto.validate(request)

        let authorizationService = request.application.services.authorizationService
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let validateCodeFuture = verifySuperUserFuture.flatMapThrowing {
            try self.validateCode(on: request, code: roleDto.code)
        }

        let createRoleFuture = validateCodeFuture.flatMapThrowing { _ in
            try self.createRole(on: request, roleDto: roleDto)
        }.flatMap { roleFuture in
            return roleFuture
        }

        return createRoleFuture.flatMapThrowing { role -> EventLoopFuture<Response> in
            try self.createNewRoleResponse(on: request, role: role)
        }.flatMap { roleFuture in
            return roleFuture
        }
    }

    /// Get all roles.
    func list(request: Request) throws -> EventLoopFuture<[RoleDto]> {
        let authorizationService = request.application.services.authorizationService
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let allRolesFuture = verifySuperUserFuture.flatMap {
            Role.query(on: request).all()
        }

        return allRolesFuture.map { roles in
            roles.map { role in RoleDto(from: role) }
        }
    }

    /// Get specific role.
    func read(request: Request) throws -> EventLoopFuture<RoleDto> {
        let authorizationService = request.application.services.authorizationService
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        return roleFuture.map { role in 
            RoleDto(from: role)
        }
    }

    /// Update specific role.
    func update(request: Request, roleDto: RoleDto) throws -> EventLoopFuture<RoleDto> {

        try RoleDto.validate(request)

        let authorizationService = request.application.services.authorizationService
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        let validateCodeFuture = roleFuture.flatMap(to: Role.self) { role in
            return try self.validateCode(on: request, code: roleDto.code, roleId: role.id).map {
                return role
            }
        }

        let updateFuture = validateCodeFuture.flatMap { role in
            try self.updateRole(on: request, from: roleDto, to: role)
        }

        return updateFuture.map { role in
            RoleDto(from: role)
        }
    }

    /// Delete specific role.
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authorizationService = request.application.services.authorizationService
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        let deleteFuture = roleFuture.flatMap { role in 
            role.delete(on: request)
        }

        return deleteFuture.transform(to: HTTPStatus.ok)
    }

    private func validateCode(on request: Request, code: String, roleId: UUID? = nil) throws -> EventLoopFuture<Void> {
        if let unwrapedRoleId = roleId {
            return Role.query(on: request).group(.and) { verifyCodeGroup in
                verifyCodeGroup.filter(\.code == code)
                verifyCodeGroup.filter(\.id != unwrapedRoleId)
            }.first().map { role in
                if role != nil {
                    throw RoleError.roleWithCodeExists
                }
            }
        } else {
            return Role.query(on: request).filter(\.code == code).first().map { role in
                if role != nil {
                    throw RoleError.roleWithCodeExists
                }
            }
        }
    }

    private func createRole(on request: Request, roleDto: RoleDto) throws -> EventLoopFuture<Role> {
        let role = Role(from: roleDto)
        return role.save(on: request)
    }

    private func createNewRoleResponse(on request: Request, role: Role) throws -> EventLoopFuture<Response> {
        let createdRoleDto = RoleDto(from: role)
        return try createdRoleDto.encode(for: request).map { response in
            response.http.headers.replaceOrAdd(name: .location, value: "\(RolesController.uri)/\(role.id?.uuidString ?? "")")
            response.http.status = .created

            return response
        }
    }

    private func getRoleById(on request: Request) throws -> EventLoopFuture<Role> {
        let roleId = try request.parameters.next(String.self)
        guard let uuidRoleId = UUID(uuidString: roleId) else {
            throw RoleError.incorrectRoleId
        }

        return Role.find(uuidRoleId, on: request).unwrap(or: EntityNotFoundError.roleNotFound)
    }

    private func updateRole(on request: Request, from roleDto: RoleDto, to role: Role) throws -> EventLoopFuture<Role> {
        role.name = roleDto.name
        role.code = roleDto.code
        role.description = roleDto.description
        role.hasSuperPrivileges = roleDto.hasSuperPrivileges
        role.isDefault = roleDto.isDefault

        return role.update(on: request)
    }
*/
}
