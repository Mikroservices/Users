import FluentPostgreSQL
import Vapor

/// A single entry of a Role list.
final class Role: PostgreSQLUUIDModel {

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
         hasSuperPrivileges: Bool,
         isDefault: Bool
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.description = description
        self.hasSuperPrivileges = hasSuperPrivileges
        self.isDefault = isDefault
    }
}

/// Users connected to role.
extension Role {
    var users: Siblings<Role, User, UserRole> {
        return siblings()
    }
}

/// Allows `Role` to be used as a dynamic migration.
extension Role: Migration { }

/// Allows `Role` to be encoded to and decoded from HTTP messages.
extension Role: Content { }

/// Allows `Role` to be used as a dynamic parameter in route definitions.
extension Role: Parameter { }
