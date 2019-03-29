import Vapor

final class RoleDto: Reflectable {

    var id: UUID?
    var name: String
    var code: String
    var description: String?
    var hasSuperPrivileges: Bool
    var isDefault: Bool

    init(id: UUID?,
         name: String,
         code: String,
         description: String?,
         hasSuperPrivileges: Bool,
         isDefault: Bool) {
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

    /// See `Validatable`.
    static func validations() throws -> Validations<RoleDto> {
        var validations = Validations(RoleDto.self)

        try validations.add(\.name, .count(...50))
        try validations.add(\.code, .count(...20))
        try validations.add(\.description, .count(...200) || .nil)

        return validations
    }
}
