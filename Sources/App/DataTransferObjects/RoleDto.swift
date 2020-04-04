import Vapor

struct RoleDto {
    var id: UUID?
    var role: String
    var code: String
    var description: String?
    var hasSuperPrivileges: Bool
    var isDefault: Bool
}

extension RoleDto {
    init(from role: Role) {
        self.init(
            id: role.id,
            role: role.role,
            code: role.code,
            description: role.description,
            hasSuperPrivileges: role.hasSuperPrivileges,
            isDefault: role.isDefault
        )
    }
}

extension RoleDto: Content { }

extension RoleDto: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("role", as: String.self, is: .count(...50))
        validations.add("code", as: String.self, is: .count(...20))
        validations.add("description", as: String?.self, is: .count(...200) || .nil)
    }
}
