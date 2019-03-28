import Vapor
import FluentPostgreSQL
import ExtendedError

/// Controls basic operations for User object.
final class RolesController: RouteCollection {

    public static let uri = "/roles"

    func boot(router: Router) throws {
        router.post(RoleDto.self, at: RolesController.uri, use: create)
//        router.get(RolesController.uri, String.parameter, use: read)
//        router.get(RolesController.uri, String.parameter, use: readAll)
//        router.put(RoleDto.self, at: RolesController.uri, String.parameter, use: update)
//        router.delete(RolesController.uri, String.parameter, use: delete)
    }

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

//    func read(request: Request) throws -> Future<RoleDto> {
//    }

//    func readAll(request: Request) throws -> Future<[RoleDto]> {
//    }

//    func update(request: Request, userDto: RoleDto) throws -> Future<RoleDto> {
//
//        try roleDto.validate()
//    }

//    func delete(request: Request) throws -> Future<HTTPStatus> {
//    }


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
}
