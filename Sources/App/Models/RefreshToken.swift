import Fluent
import FluentPostgresDriver
import Vapor
import Crypto

final class RefreshToken: Model {

    static let schema = "RefreshTokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "expiryDate")
    var expiryDate: Date
    
    @Field(key: "revoked")
    var revoked: Bool

    @Parent(key: "userId")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil,
         userId: UUID,
         token: String,
         expiryDate: Date,
         revoked: Bool = false
    ) {
        self.id = id
        self.token = token
        self.expiryDate = expiryDate
        self.revoked = revoked
        
        self.$user.id = userId
    }
}

/// Allows `RefreshToken` to be used as a dynamic migration.
extension RefreshToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("RefreshTokens")
            .id()
            .field("token", .string, .required)
            .field("expiryDate", .datetime, .required)
            .field("revoked", .bool, .required)
            .field("userId", .uuid, .references("Users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("RefreshTokens").delete()
    }
}

/// Allows `RefreshToken` to be encoded to and decoded from HTTP messages.
extension RefreshToken: Content { }
