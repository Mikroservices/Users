import Fluent
import FluentPostgresDriver
import Vapor

final class Setting: Model {
    static let schema = "Settings"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String

    init() { }
    
    init(id: UUID? = nil,
         key: String,
         value: String
    ) {
        self.id = id
        self.key = key
        self.value = value
    }
}

extension Setting: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("Settings")
            .id()
            .field("key", .string, .required)
            .field("value", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("Settings").delete()
    }
}

/// Allows `Setting` to be encoded to and decoded from HTTP messages.
extension Setting: Content { }
