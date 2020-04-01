import Vapor

final class RoleDto {

    var id: UUID?
    var name: String
    var code: String
    var description: String?
    var hasSuperPrivileges: Bool
    var isDefault: Bool

    init(id: UUID? = nil,
         name: String,
         code: String,
         description: String?,
         hasSuperPrivileges: Bool = false,
         isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.code = code
        self.description = description
        self.hasSuperPrivileges = hasSuperPrivileges
        self.isDefault = isDefault
    }
}

extension RoleDto {
    convenience init(from role: Role) {
        self.init(
            id: role.id,
            name: role.name,
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
        validations.add("name", as: String.self, is: .count(...50))
        validations.add("code", as: String.self, is: .count(...20))
        validations.add("description", as: String?.self, is: .count(...200) || .nil)
    }
}
