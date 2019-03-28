import FluentPostgreSQL
import Vapor

/// Connection between users and roles.
struct UserRole: ModifiablePivot, PostgreSQLUUIDModel {
    typealias Left = User
    typealias Right = Role

    static var leftIDKey: LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.roleId

    var id: UUID?
    var userId: UUID
    var roleId: UUID

    init(_ user: User, _ role: Role) throws {
        self.userId = try user.requireID()
        self.roleId = try role.requireID()
    }
}

/// Allows `UserRole` to be used as a dynamic migration.
extension UserRole: Migration { }

/// Allows `UserRole` to be encoded to and decoded from HTTP messages.
extension UserRole: Content { }

/// Allows `UserRole` to be used as a dynamic parameter in route definitions.
extension UserRole: Parameter { }
