import Vapor
import Fluent
import FluentPostgresDriver
import ExtendedError

final class RolesController: RouteCollection {

    public static let uri: PathComponent = .constant("roles")
    
    func boot(routes: RoutesBuilder) throws {
        let rolesGroup = routes
            .grouped(RolesController.uri)
            .grouped(UserAuthenticator().middleware())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
        
        rolesGroup.post(use: create)
        rolesGroup.get(use: list)
        rolesGroup.get(":id", use: read)
        rolesGroup.put(":id", use: update)
        rolesGroup.delete(":id", use: delete)
    }

    /// Create new role.
    func create(request: Request) throws -> EventLoopFuture<Response> {        
        let roleDto = try request.content.decode(RoleDto.self)
        try RoleDto.validate(request)

        let validateCodeFuture = self.validateCode(on: request, code: roleDto.code)
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
        
        guard let roleId = request.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let roleDto = try request.content.decode(RoleDto.self)
        try RoleDto.validate(request)

        let roleFuture = self.getRoleById(on: request, roleId: roleId)
        let validateCodeFuture = roleFuture.flatMap { role in
            self.validateCode(on: request, code: roleDto.code, roleId: role.id).transform(to: role)
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

    private func validateCode(on request: Request, code: String, roleId: UUID? = nil) -> EventLoopFuture<Void> {
        if let unwrapedRoleId = roleId {
            return Role.query(on: request.db).group(.and) { verifyCodeGroup in
                verifyCodeGroup.filter(\.$code == code)
                verifyCodeGroup.filter(\.$id != unwrapedRoleId)
            }.first().flatMap { role -> EventLoopFuture<Void> in
                if role != nil {
                    return request.fail(RoleError.roleWithCodeExists)
                }
                
                return request.success()
            }
        } else {
            return Role.query(on: request.db).filter(\.$code == code).first().flatMap { role -> EventLoopFuture<Void> in
                if role != nil {
                    return request.fail(RoleError.roleWithCodeExists)
                }
                
                return request.success()
            }
        }
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
        role.role = roleDto.role
        role.code = roleDto.code
        role.description = roleDto.description
        role.hasSuperPrivileges = roleDto.hasSuperPrivileges
        role.isDefault = roleDto.isDefault

        return role.update(on: request.db)
    }
}
