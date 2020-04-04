import Vapor
import Fluent

struct CreateRoles: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Role.schema)
            .id()
            .field("role", .string, .required)
            .field("code", .string, .required)
            .field("description", .string)
            .field("hasSuperPrivileges", .bool, .required)
            .field("isDefault", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Role.schema).delete()
    }
}
