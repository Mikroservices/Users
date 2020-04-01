import Fluent
import FluentPostgresDriver
import Vapor

final class UserRole: Model {
    static let schema: String = "UserRoles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "userId")
    var user: User

    @Parent(key: "roleId")
    var role: Role

    init() {}

    init(userId: UUID, roleId: UUID) {
        self.$user.id = userId
        self.$role.id = roleId
    }

}

/// Allows `UserRole` to be used as a dynamic migration.
extension UserRole: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("UserRoles")
            .id()
            .field("userId", .uuid, .required, .references("Users", "id"))
            .field("roleId", .uuid, .required, .references("Roles", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("UserRoles").delete()
    }
}

/// Allows `UserRole` to be encoded to and decoded from HTTP messages.
extension UserRole: Content { }
