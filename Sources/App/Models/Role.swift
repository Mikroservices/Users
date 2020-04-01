import Fluent
import FluentPostgresDriver
import Vapor

final class Role: Model {

    static let schema = "Roles"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "role")
    var role: String

    @Field(key: "code")
    var code: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "hasSuperPrivileges")
    var hasSuperPrivileges: Bool
    
    @Field(key: "isDefault")
    var isDefault: Bool
    
    @Siblings(through: UserRole.self, from: \.$role, to: \.$user)
    var users: [User]

    init() { }
    
    init(id: UUID? = nil,
         role: String,
         code: String,
         description: String?,
         hasSuperPrivileges: Bool,
         isDefault: Bool
    ) {
        self.id = id
        self.role = role
        self.code = code
        self.description = description
        self.hasSuperPrivileges = hasSuperPrivileges
        self.isDefault = isDefault
    }
}

/// Allows `Role` to be used as a dynamic migration.
extension Role: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("Roles")
            .id()
            .field("role", .string, .required)
            .field("code", .string, .required)
            .field("description", .string)
            .field("hasSuperPrivileges", .bool, .required)
            .field("isDefault", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Roles").delete()
    }
}

/// Allows `Role` to be encoded to and decoded from HTTP messages.
extension Role: Content { }

extension Role {
    convenience init(from roleDto: RoleDto) {
        self.init(role: roleDto.role,
                  code: roleDto.code,
                  description: roleDto.description,
                  hasSuperPrivileges: roleDto.hasSuperPrivileges,
                  isDefault: roleDto.isDefault
        )
    }
}
