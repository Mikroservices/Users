import Vapor

final class RolesController: RouteCollection {

    public static let uri: PathComponent = .constant("roles")
    
    func boot(routes: RoutesBuilder) throws {
        let rolesGroup = routes
            .grouped(RolesController.uri)
            .grouped(UserAuthenticator().middleware())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
        
        rolesGroup
            .grouped(EventHandlerMiddleware(.rolesCreate))
            .post(use: create)
        
        rolesGroup
            .grouped(EventHandlerMiddleware(.rolesList))
            .get(use: list)
        
        rolesGroup
            .grouped(EventHandlerMiddleware(.rolesRead))
            .get(":id", use: read)
        
        rolesGroup
            .grouped(EventHandlerMiddleware(.rolesUpdate))
            .put(":id", use: update)
        
        rolesGroup
            .grouped(EventHandlerMiddleware(.rolesDelete))
            .delete(":id", use: delete)
    }

    /// Create new role.
    func create(request: Request) throws -> EventLoopFuture<Response> {
        let rolesService = request.application.services.rolesService
        let roleDto = try request.content.decode(RoleDto.self)
        try RoleDto.validate(request)

        let validateCodeFuture = rolesService.validateCode(on: request, code: roleDto.code, roleId: nil)
        let createRoleFuture = validateCodeFuture.map { _ in
            self.createRole(on: request, roleDto: roleDto)
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
        return Role.query(on: request.db).all().map { roles in
            roles.map { role in RoleDto(from: role) }
        }
    }

    /// Get specific role.
    func read(request: Request) throws -> EventLoopFuture<RoleDto> {
        
        guard let roleId = request.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return self.getRoleById(on: request, roleId: roleId).map { role in
            RoleDto(from: role)
        }
    }

    /// Update specific role.
    func update(request: Request) throws -> EventLoopFuture<RoleDto> {
        let rolesService = request.application.services.rolesService

        guard let roleId = request.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let roleDto = try request.content.decode(RoleDto.self)
        try RoleDto.validate(request)

        let roleFuture = self.getRoleById(on: request, roleId: roleId)
        let validateCodeFuture = roleFuture.flatMap { role in
            rolesService.validateCode(on: request, code: roleDto.code, roleId: role.id).transform(to: role)
        }

        let updateFuture = validateCodeFuture.flatMap { role in
            self.updateRole(on: request, from: roleDto, to: role).transform(to: role)
        }

        return updateFuture.map { role in
            RoleDto(from: role)
        }
    }

    /// Delete specific role.
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let roleId = request.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        let roleFuture = self.getRoleById(on: request, roleId: roleId)
        let deleteFuture = roleFuture.flatMap { role in 
            role.delete(on: request.db)
        }

        return deleteFuture.transform(to: HTTPStatus.ok)
    }

    private func createRole(on request: Request, roleDto: RoleDto) -> EventLoopFuture<Role> {
        let role = Role(from: roleDto)
        return role.save(on: request.db).transform(to: role)
    }

    private func createNewRoleResponse(on request: Request, role: Role) throws -> EventLoopFuture<Response> {
        let createdRoleDto = RoleDto(from: role)
                
        return createdRoleDto.encodeResponse(for: request).map { response in
            response.headers.replaceOrAdd(name: .location, value: "/\(RolesController.uri)/\(role.id?.uuidString ?? "")")
            response.status = .created

            return response
        }
    }

    private func getRoleById(on request: Request, roleId: UUID) -> EventLoopFuture<Role> {
        return Role.find(roleId, on: request.db).unwrap(or: EntityNotFoundError.roleNotFound)
    }

    private func updateRole(on request: Request, from roleDto: RoleDto, to role: Role) -> EventLoopFuture<Void> {
        role.title = roleDto.title
        role.code = roleDto.code
        role.description = roleDto.description
        role.hasSuperPrivileges = roleDto.hasSuperPrivileges
        role.isDefault = roleDto.isDefault

        return role.update(on: request.db)
    }
}
