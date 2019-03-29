import Vapor
import FluentPostgreSQL
import ExtendedError

/// Controls basic operations for Role object.
final class RolesController: RouteCollection {

    public static let uri = "/roles"

    func boot(router: Router) throws {
        router.post(RoleDto.self, at: RolesController.uri, use: create)
        router.get(RolesController.uri, use: list)
        router.get(RolesController.uri, String.parameter, use: read)
        router.put(RoleDto.self, at: RolesController.uri, String.parameter, use: update)
        router.delete(RolesController.uri, String.parameter, use: delete)
    }

    /// Create new role.
    func create(request: Request, roleDto: RoleDto) throws -> Future<Response> {

        try roleDto.validate()

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let validateCodeFuture = verifySuperUserFuture.flatMap {
            try self.validateCode(on: request, code: roleDto.code)
        }

        let createRoleFuture = validateCodeFuture.flatMap {
            try self.createRole(on: request, roleDto: roleDto)
        }

        return createRoleFuture.flatMap { role in
            try self.createNewRoleResponse(on: request, role: role)
        }
    }

    /// Get all roles.
    func list(request: Request) throws -> Future<[RoleDto]> {
        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let allRolesFuture = verifySuperUserFuture.flatMap {
            Role.query(on: request).all()
        }

        return allRolesFuture.map { roles in
            roles.map { role in RoleDto(from: role) }
        }
    }

    /// Get specific role.
    func read(request: Request) throws -> Future<RoleDto> {
        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        return roleFuture.map { role in 
            RoleDto(from: role)
        }
    }

    /// Update specific role.
    func update(request: Request, roleDto: RoleDto) throws -> Future<RoleDto> {

        try roleDto.validate()

        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        let updateFuture = roleFuture.flatMap { role in 
            try self.updateRole(on: request, from: roleDto, to: role)
        }

        return updateFuture.map { role in
            RoleDto(from: role)
        }
    }

    /// Delete specific role.
    func delete(request: Request) throws -> Future<HTTPStatus> {
        let authorizationService = try request.make(AuthorizationServiceType.self)
        let verifySuperUserFuture = try authorizationService.verifySuperUser(request: request)

        let roleFuture = verifySuperUserFuture.flatMap {
            try self.getRoleById(on: request)
        }

        let deleteFuture = roleFuture.flatMap { role in 
            role.delete(on: request)
        }

        return deleteFuture.transform(to: HTTPStatus.ok)
    }

    private func validateCode(on request: Request, code: String) throws -> Future<Void> {
        return Role.query(on: request).filter(\.code == code).first().map { role in
            if role != nil {
                throw RoleError.roleWithCodeExists
            }
        }
    }

    private func createRole(on request: Request, roleDto: RoleDto) throws -> Future<Role> {
        let role = Role(from: roleDto)
        return role.save(on: request)
    }

    private func createNewRoleResponse(on request: Request, role: Role) throws -> Future<Response> {
        let createdRoleDto = RoleDto(from: role)
        return try createdRoleDto.encode(for: request).map { response in
            response.http.headers.replaceOrAdd(name: .location, value: "\(RolesController.uri)/\(role.id?.uuidString ?? "")")
            response.http.status = .created

            return response
        }
    }

    private func getRoleById(on request: Request) throws -> Future<Role> {
        let roleId = try request.parameters.next(String.self)
        guard let uuidRoleId = UUID(uuidString: roleId) else {
            throw RoleError.incorrectRoleId
        }

        return Role.find(uuidRoleId, on: request).unwrap(or: EntityNotFoundError.roleNotFound)
    }

    private func updateRole(on request: Request, from roleDto: RoleDto, to role: Role) throws -> Future<Role> {
        role.name = roleDto.name
        role.code = roleDto.code
        role.description = roleDto.description
        role.hasSuperPrivileges = roleDto.hasSuperPrivileges
        role.isDefault = roleDto.isDefault

        return role.update(on: request)
    }
}
