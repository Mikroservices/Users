import Vapor

struct RoleDto {
    var id: UUID?
    var title: String
    var code: String
    var description: String?
    var hasSuperPrivileges: Bool
    var isDefault: Bool
}

extension RoleDto {
    init(from role: Role) {
        self.init(
            id: role.id,
            title: role.title,
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
        validations.add("title", as: String.self, is: .count(...50))
        validations.add("code", as: String.self, is: .count(...20))
        validations.add("description", as: String?.self, is: .count(...200) || .nil, required: false)
    }
}
